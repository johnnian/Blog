//
//  JKRVideoEditView.m
//  JKRAVCameraDemo
//
//  Created by tronsis_ios on 16/9/2.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import "JKRVideoEditView.h"
#import "JKRVideoBackGroundView.h"
#import "GPUImage.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "RQShineLabel.h"
#import <time.h>

@interface JKRVideoEditView ()<JKRVideoBackGroundViewDelegate>

@property (nonatomic, strong) JKRVideoBackGroundView *backgroudView;
@property (nonatomic, strong) JKRVideo *video;
@property (nonatomic, strong) JKRVideo *mergeVideo;
@property (nonatomic, strong) GPUImageView *filterView;
@property (nonatomic, strong) AVPlayer *videoPlayer;
@property (nonatomic, strong) AVPlayerItem *item;
@property (nonatomic, strong) GPUImageMovie *movieFile;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filters;
@property (nonatomic, strong) GPUImageMovieWriter *videoWriter;
@property (nonatomic, assign) BOOL hasDisappear;

@end

@implementation JKRVideoEditView

- (instancetype)initWithFrame:(CGRect)frame video:(JKRVideo *)video {
    self = [super initWithFrame:frame];
    _filters = [GPUImageFilter new];
    self.filterView = [GPUImageView new];
    self.filterView.frame = self.bounds;
    self.filterView.backgroundColor = [UIColor redColor];
    [self addSubview:_filterView];
    [self.filters addTarget:_filterView];
    
    _backgroudView = [[JKRVideoBackGroundView alloc] init];
    _backgroudView.frame = self.bounds;
    _backgroudView.delegate = self;
    [self addSubview:_backgroudView];

    self.video = video;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActiveNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    return self;
}

-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
    self.item = [notification object];
    [self.item seekToTime:kCMTimeZero];
    [self videoPlay];
}

// 后台
- (void)resignActiveNotification{
    [self.movieFile cancelProcessing];
    [self videoStop];
}

// 前台
- (void)enterForegroundNotification{
    [self.movieFile startProcessing];
    [self videoPlay];
}

- (void)setVideo:(JKRVideo *)video {
    _video = video;
    [self setCurrentPlayVideo:_video];
}

- (void)setCurrentPlayVideo:(JKRVideo *)video {
    self.videoPlayer = nil;
    [self.movieFile removeAllTargets];
    self.movieFile = nil;
    [self.filters removeAllTargets];
    
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:video.path]];
    self.item = [AVPlayerItem playerItemWithAsset:asset];
    self.videoPlayer = [AVPlayer playerWithPlayerItem:_item];
    
    AVAssetTrack *videoAssetTrack = [[AVAsset assetWithURL:[NSURL fileURLWithPath:_video.path]] tracksWithMediaType:AVMediaTypeVideo].lastObject;
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        NSLog(@"垂直拍摄");
        videoTransform = CGAffineTransformMakeRotation(M_PI_2);
    }else if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        NSLog(@"倒立拍摄");
        videoTransform = CGAffineTransformMakeRotation(-M_PI_2);
    }else if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        NSLog(@"Home键右侧水平拍摄");
        videoTransform = CGAffineTransformMakeRotation(0);
    }else if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        NSLog(@"Home键左侧水平拍摄");
        videoTransform = CGAffineTransformMakeRotation(M_PI);
    }
    [self.filterView setTransform:videoTransform];
    self.filterView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    self.movieFile = [[GPUImageMovie alloc] initWithPlayerItem:_item];
    self.movieFile.runBenchmark = NO;
    self.movieFile.playAtActualSpeed = YES;
    [self.movieFile addTarget:_filters];
    
    [self.movieFile startProcessing];
    
    [self.filters addTarget:_filterView];
    [self videoPlay];
}

- (void)videoPlay {
    [self.videoPlayer play];
}

- (void)videoStop{
    [self.videoPlayer pause];
}

- (UIViewController *)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)videoBackGroundViewDidClickBack {
    [self.videoPlayer pause];
    [self.movieFile removeAllTargets];
    [self.filters removeAllTargets];
    [self.filterView removeFromSuperview];
    
    __weak UIViewController *vc = [self viewController];
    [vc dismissViewControllerAnimated:YES completion:nil];
}

- (void)videoBackGroundViewDidClickAdd {
    [self videoStop];
    [self mergeVoiceToVidoeComleted:^(JKRVideo *mergeVideo) {
        _mergeVideo = mergeVideo;
        [self setCurrentPlayVideo:_mergeVideo];
        [self setFilter];
    }];
}

- (void)mergeVoiceToVidoeComleted:(void(^)(JKRVideo *mergeVideo))completed {
    if (!_video.path) return;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:_video.path]];
        
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
        
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"back" ofType:@"mp3"]] options:nil];
        AVAssetTrack *voiceAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:voiceAssetTrack atTime:kCMTimeZero error:nil];
        
        NSString *outPath = [kCachePath stringByAppendingPathComponent:[self movieName]];
        NSURL *mergeFileURL = [NSURL fileURLWithPath:outPath];
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
        exporter.outputURL = mergeFileURL;
        exporter.outputFileType = AVFileTypeMPEG4;
        exporter.shouldOptimizeForNetworkUse = YES;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            JKRVideo *video = [[JKRVideo alloc] init];
            video.name = _video.name;
            video.path = outPath;
            video.image = getImageFromVideoPath(outPath);
            dispatch_async(dispatch_get_main_queue(), ^{
                completed(video);
            });
        }];
    });
}

- (void)setFilter {
    _hasDisappear = NO;
    [self.filters removeAllTargets];
    [self.movieFile removeAllTargets];
    
    NSArray *strs = @[@"Hello joker", @"Joker AVCamera", @"HH Happy", @"J O K E R"];
    
    GPUImageColorMatrixFilter *filter = [[GPUImageColorMatrixFilter alloc] init];
    filter.intensity = 1.0;
    filter.colorMatrix = (GPUMatrix4x4) {
        {0.3588, 0.7044, 0.1368, 0.0},
        {0.2990, 0.5870, 0.1140, 0.0},
        {0.2392, 0.4696, 0.0912 ,0.0},
        {0,0,0,1.0},
    };
    [self.movieFile addTarget:filter];
    
    UIView *content = [[UIView alloc] init];
    
    NSLog(@"filter view frame: %@", NSStringFromCGRect(self.filterView.frame));
    
    RQShineLabel *label = [RQShineLabel new];
    label.font = [UIFont systemFontOfSize:25];
    label.text = @"Joker888";
    label.frame = CGRectMake(self.filterView.frame.size.height * 0.5 - 100, self.filterView.frame.size.width * 0.5 - 50, 200, 100);
    label.textAlignment = NSTextAlignmentCenter;
    [label shine];
    NSLog(@"text view frame: %@", NSStringFromCGRect(label.frame));
    label.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [content addSubview:label];
    content.frame = CGRectMake(0, 0, self.filterView.frame.size.height, self.filterView.frame.size.width);
    content.backgroundColor = [UIColor clearColor];
    
    
    GPUImageUIElement *uielement = [[GPUImageUIElement alloc] initWithView:content];
    
    GPUImageAlphaBlendFilter *filters = [[GPUImageAlphaBlendFilter alloc] init];
    filters.mix = 1.0;
    [filter addTarget:filters];
    [uielement addTarget:filters];
    
    // 视频刷新，每秒60次
    __block CGFloat lastTime = 0;
    [filter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime ctime) {
        
        if (ctime.value/ctime.timescale >= lastTime) {
            lastTime += 3;
            _hasDisappear = YES;
            [label fadeOutWithCompletion:^{
                srand((unsigned)time(0));
                long index = 0 + rand() % strs.count;
                NSLog(@"str index %lu", index);
                label.text = strs[index];
                [label shine];
            }];
        }
        
        [uielement updateWithTimestamp:ctime];
    }];
    
    [filters addTarget:self.filters];
    [self.filters addTarget:self.filterView];
    [self videoPlay];
}

- (void)videoBackGroundViewDidClickRemove {
    [self setCurrentPlayVideo:_video];
}

#pragma mark - 内部处理方法
- (NSString *)movieName {
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    return [timeSp stringByAppendingString:@".MOV"];
}

static inline UIImage * getImageFromVideoPath(NSString *path) {
    UIImage *image;
    NSURL *url = [NSURL fileURLWithPath:path];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

- (void)dealloc {
    
}

@end
