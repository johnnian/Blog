//
//  JKRCameraView.m
//  JKRCameraDemo
//
//  Created by tronsis_ios on 16/8/30.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import "JKRCameraView.h"
#import "JKRCameraBackgroundView.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "NSString+FileSize.h"
#import <CoreMotion/CoreMotion.h>

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);
typedef void(^setVideoSpeedBlock)();

@interface JKRCameraView ()<AVCaptureFileOutputRecordingDelegate, JKRCameraBackgroundViewDelegate, JKRCameraBackgroundViewDatasource>
@property (nonatomic, strong) JKRCameraBackgroundView *backgroundView; // 控制界面
@property (nonatomic, strong) NSString *currentMoviePath;  // 当前到出的视频路径
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *moviePaths;  // 录制的原始视频数组
@property (nonatomic, strong) NSMutableArray<NSString *> *processedVideoPaths; // 处理播放速度后的视频数组
@property (nonatomic, strong) AVCaptureDeviceFormat *defaultFormat;
@property (nonatomic) CMTime defaultMinFrameDuration;
@property (nonatomic) CMTime defaultMaxFrameDuration;


/// 负责输入和输出设备之间的数据传递
@property (nonatomic, strong) AVCaptureSession *captureSession;
/// 负责从AVCaptureDevice获得视频输入流
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;
/// 负责从AVCaptureDevice获得音频输入流
@property (nonatomic, strong) AVCaptureDeviceInput *audioCaptureDeviceInput;
/// 视频输出流
@property (nonatomic, strong) AVCaptureMovieFileOutput *captureMovieFileOutput;
/// 相机拍摄预览图层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
/// 重力感应管理者
@property (nonatomic, strong) CMMotionManager *motionManager;
/// 当前方向
@property (nonatomic, assign) UIDeviceOrientation deviceOrientation;
/// 是否快速
@property (nonatomic, assign) BOOL isFast;
/// 是否慢速
@property (nonatomic, assign) BOOL isSlow;
/// 视频index
@property (nonatomic, assign) NSInteger index;
/// 视频速度处理完成回调
@property (nonatomic, copy) setVideoSpeedBlock setVideoSpeedBlock;

@property (nonatomic, strong) NSString *timeStr;


@end

@implementation JKRCameraView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor blueColor];
    
    // 创建AVCaptureSession
    _captureSession = [[AVCaptureSession alloc] init];
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) _captureSession.sessionPreset = AVCaptureSessionPreset1280x720;

    // 获取摄像设备
    AVCaptureDevice *videoCaptureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    if (!videoCaptureDevice)  {
        // Handle the error appropriately.
    }

    // 获取视频输入流
    NSError *error = nil;
    _captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
    if (error) {
        // Handle the error appropriately.
    }

    // 获取录音设备
    AVCaptureDevice *audioCaptureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];

    // 获取音频输入流
    _audioCaptureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
    if (error) {
        // Handle the error appropriately.
    }

    // 将视频和音频输入添加到AVCaptureSession
    if ([_captureSession canAddInput:_captureDeviceInput] && [_captureSession canAddInput:_audioCaptureDeviceInput]) {
        [_captureSession addInput:_captureDeviceInput];
        [_captureSession addInput:_audioCaptureDeviceInput];
    }

    // 创建输出流
    _captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];

    // 将输出流添加到AVCaptureSession
    if ([_captureSession canAddOutput:_captureMovieFileOutput]) {
        [_captureSession addOutput:_captureMovieFileOutput];
        // 根据设备输出获得连接
        AVCaptureConnection *captureConnection = [_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        // 判断是否支持光学防抖
        if ([videoCaptureDevice.activeFormat isVideoStabilizationModeSupported:AVCaptureVideoStabilizationModeCinematic]) {
            // 如果支持防抖就打开防抖
            captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeCinematic;
        }
    }

    // 保存默认的AVCaptureDeviceFormat
    _defaultFormat = videoCaptureDevice.activeFormat;
    _defaultMinFrameDuration = videoCaptureDevice.activeVideoMinFrameDuration;
    _defaultMaxFrameDuration = videoCaptureDevice.activeVideoMaxFrameDuration;

    // 创建预览图层
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//填充模式
    _captureVideoPreviewLayer.frame = self.bounds;

    [self.layer addSublayer:_captureVideoPreviewLayer];

    // 开始捕获
    [self.captureSession startRunning];
    
    
    _backgroundView = [[JKRCameraBackgroundView alloc] initWithFrame:self.bounds];
    _backgroundView.delegate = self;
    _backgroundView.datasource = self;
    [self addSubview:_backgroundView];
    
    _moviePaths = [NSMutableArray array];
    
    [self getCacheCompleted:^(NSString *string) {
        NSLog(@"Cache: %@", string);
        [self clearCache];
        [self getCacheCompleted:^(NSString *string) {
            NSLog(@"Cache: %@", string);
        }];
    }];
    
    [[self.captureDeviceInput device] addObserver:self forKeyPath:@"ISO" options:NSKeyValueObservingOptionNew context:NULL];
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.deviceMotionUpdateInterval = 1/15.0;
    if (_motionManager.deviceMotionAvailable) {
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
        }];
    } else {
        NSLog(@"No device motion on device");
    }
    
    _processedVideoPaths = [NSMutableArray array];
    
    [self addObserver:self forKeyPath:@"deviceOrientation" options:NSKeyValueObservingOptionNew context:NULL];
    
    return self;
}

/// 获取摄像头设备
- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            if ([device supportsAVCaptureSessionPreset:AVCaptureSessionPreset1280x720]) return device;
            return nil;
        }
    }
    return nil;
}

#pragma mark - 切换到后摄像头
- (void)cameraBackgroundDidClickChangeBack {
    [[self.captureDeviceInput device] removeObserver:self forKeyPath:@"ISO"];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition = AVCaptureDevicePositionBack;
    toChangeDevice = [self getCameraDeviceWithPosition:toChangePosition];
    AVCaptureDeviceInput *toChangeDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:toChangeDevice error:nil];
    [self.captureSession beginConfiguration];
    [self.captureSession removeInput:self.captureDeviceInput];
    if ([self.captureSession canAddInput:toChangeDeviceInput]) {
        [self.captureSession addInput:toChangeDeviceInput];
        self.captureDeviceInput = toChangeDeviceInput;
    }
    [self.captureSession commitConfiguration];
}

#pragma mark - 切换到前摄像头
- (void)cameraBackgroundDidClickChangeFront {
    [[self.captureDeviceInput device] removeObserver:self forKeyPath:@"ISO"];
    
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition = AVCaptureDevicePositionFront;
    toChangeDevice = [self getCameraDeviceWithPosition:toChangePosition];
    AVCaptureDeviceInput *toChangeDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:toChangeDevice error:nil];
    [self.captureSession beginConfiguration];
    [self.captureSession removeInput:self.captureDeviceInput];
    if ([self.captureSession canAddInput:toChangeDeviceInput]) {
        [self.captureSession addInput:toChangeDeviceInput];
        self.captureDeviceInput = toChangeDeviceInput;
    }
    [self.captureSession commitConfiguration];
    
    [[self.captureDeviceInput device] addObserver:self forKeyPath:@"ISO" options:NSKeyValueObservingOptionNew context:NULL];
}

#pragma mark - 打开闪光灯
- (void)cameraBackgroundDidClickOpenFlash {
    AVCaptureDevice *captureDevice = [self.captureDeviceInput device];
    NSError *error;
    if ([captureDevice lockForConfiguration:&error]) {
        if ([captureDevice isTorchModeSupported:AVCaptureTorchModeOn]) [captureDevice setTorchMode:AVCaptureTorchModeOn];
    }else{
        // Handle the error appropriately.
    }
}

#pragma mark - 关闭闪光灯
- (void)cameraBackgroundDidClickCloseFlash {
    AVCaptureDevice *captureDevice = [self.captureDeviceInput device];
    NSError *error;
    if ([captureDevice lockForConfiguration:&error]) {
        if ([captureDevice isTorchModeSupported:AVCaptureTorchModeOff]) [captureDevice setTorchMode:AVCaptureTorchModeOff];
    }else{
        // Handle the error appropriately.
    }
}

#pragma mark - 调节焦距
- (void)cameraBackgroundDidChangeFocus:(CGFloat)focus {
    AVCaptureDevice *captureDevice = [self.captureDeviceInput device];
    NSError *error;
    if ([captureDevice lockForConfiguration:&error]) {
        if ([captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) [captureDevice setFocusModeLockedWithLensPosition:focus completionHandler:nil];
    }else{
        // Handle the error appropriately.
    }
}

#pragma mark - 数码变焦 1-3倍
- (void)cameraBackgroundDidChangeZoom:(CGFloat)zoom {
    AVCaptureDevice *captureDevice = [self.captureDeviceInput device];
    NSError *error;
    if ([captureDevice lockForConfiguration:&error]) {
        [captureDevice rampToVideoZoomFactor:zoom withRate:50];
    }else{
        // Handle the error appropriately.
    }
}

#pragma mark - 调节ISO，光感度
- (void)cameraBackgroundDidChangeISO:(CGFloat)iso {
    [[self.captureDeviceInput device] removeObserver:self forKeyPath:@"ISO"];
    AVCaptureDevice *captureDevice = [self.captureDeviceInput device];
    NSError *error;
    if ([captureDevice lockForConfiguration:&error]) {
        CGFloat minISO = captureDevice.activeFormat.minISO;
        CGFloat maxISO = captureDevice.activeFormat.maxISO;
        CGFloat currentISO = (maxISO - minISO) * iso + minISO;
        [captureDevice setExposureModeCustomWithDuration:AVCaptureExposureDurationCurrent ISO:currentISO completionHandler:nil];
        [captureDevice unlockForConfiguration];
    }else{
        // Handle the error appropriately.
    }
}

#pragma mark - 点击屏幕对焦
- (void)cameraBackgroundDidTap:(CGPoint)point {
    AVCaptureDevice *captureDevice = [self.captureDeviceInput device];
    NSError *error;
    if ([captureDevice lockForConfiguration:&error]) {
        CGPoint location = point;
        CGPoint pointOfInerest = CGPointMake(0.5, 0.5);
        CGSize frameSize = self.captureVideoPreviewLayer.frame.size;
        if ([captureDevice position] == AVCaptureDevicePositionFront) location.x = frameSize.width - location.x;
        pointOfInerest = CGPointMake(location.y / frameSize.height, 1.f - (location.x / frameSize.width));
        [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:pointOfInerest];
        
        [[self.captureDeviceInput device] addObserver:self forKeyPath:@"ISO" options:NSKeyValueObservingOptionNew context:NULL];
    }else{
        // Handle the error appropriately.
    }
}

-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    AVCaptureDevice *captureDevice = [self.captureDeviceInput device];
    NSError *error;
    if ([captureDevice lockForConfiguration:&error]) {
        if ([captureDevice isFocusModeSupported:focusMode]) [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        if ([captureDevice isFocusPointOfInterestSupported]) [captureDevice setFocusPointOfInterest:point];
        if ([captureDevice isExposureModeSupported:exposureMode]) [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        if ([captureDevice isExposurePointOfInterestSupported]) [captureDevice setExposurePointOfInterest:point];
    }else{
        // Handle the error appropriately.
    }
}

#pragma mark - 录制
- (void)cameraBackgroundDidClickPlayWith:(NSString *)timestr {
    // 根据设备输出获得连接
//    AVCaptureConnection *captureConnection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    // 根据连接取得设备输出的数据
    if (![self.captureMovieFileOutput isRecording]) {
   //        captureConnection.videoOrientation = (AVCaptureVideoOrientation)_deviceOrientation; // 视频方向和手机方向一致
        _timeStr = timestr;
        NSString *outputFilePath = [kCachePath stringByAppendingPathComponent:[self movieName]];
        NSURL *fileURL = [NSURL fileURLWithPath:outputFilePath];
        [self.captureMovieFileOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
        _currentMoviePath = outputFilePath;
        
    }
}


/// 重力感应回调
- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion{
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;

    CGAffineTransform videoTransform;
    
    if (fabs(y) >= fabs(x)) {
        if (y >= 0) {
            videoTransform = CGAffineTransformMakeRotation(M_PI);
            _deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
        } else {
            videoTransform = CGAffineTransformMakeRotation(0);
            _deviceOrientation = UIDeviceOrientationPortrait;
        }
    } else {
        if (x >= 0) {
            videoTransform = CGAffineTransformMakeRotation(-M_PI_2);
            _deviceOrientation = UIDeviceOrientationLandscapeRight;    // Home键左侧水平拍摄
        } else {
            videoTransform = CGAffineTransformMakeRotation(M_PI_2);
            _deviceOrientation = UIDeviceOrientationLandscapeLeft;     // Home键右侧水平拍摄
        }
    }
    [self.backgroundView setOrientation:_deviceOrientation];
}

#pragma mark - 暂停
- (void)cameraBackgroundDidClickPause {
    NSMutableDictionary *moviePath = [NSMutableDictionary dictionary];
    moviePath[kMoviePath] = _currentMoviePath;
    NSString *speed = kMovieSpeed_Normal;
    if (_isFast) speed = kMovieSpeed_Fast;
    if (_isSlow) speed = kMovieSpeed_Slow;
    moviePath[kMovieSpeed] = speed;
    [self.moviePaths insertObject:moviePath atIndex:0];
    [self.captureMovieFileOutput stopRecording];
}

#pragma mark - 录制代理
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    NSLog(@"开始录制");
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    NSLog(@"录制完成");
}

#pragma mark - 快速开
- (void)cameraBackgroundDidClickOpenFast {
    _isSlow = NO;
    _isFast = YES;
    [self cameraBackgroundDidClickCloseSlow];
}

#pragma mark - 快速关
- (void)cameraBackgroundDidClickCloseFast {
    _isFast = NO;
}

#pragma mark - 慢速开
- (void)cameraBackgroundDidClickOpenSlow {
    _isSlow = YES;
    _isFast = NO;
    [self.captureSession stopRunning];
    CGFloat desiredFPS = 240.0;
    AVCaptureDevice *videoDevice = self.captureDeviceInput.device;
    AVCaptureDeviceFormat *selectedFormat = nil;
    int32_t maxWidth = 0;
    AVFrameRateRange *frameRateRange = nil;
    for (AVCaptureDeviceFormat *format in [videoDevice formats]) {
        for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
            CMFormatDescriptionRef desc = format.formatDescription;
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(desc);
            int32_t width = dimensions.width;
            if (range.minFrameRate <= desiredFPS && desiredFPS <= range.maxFrameRate && width >= maxWidth) {
                selectedFormat = format;
                frameRateRange = range;
                maxWidth = width;
            }
        }
    }
    if (selectedFormat) {
        if ([videoDevice lockForConfiguration:nil]) {
            NSLog(@"selected format: %@", selectedFormat);
            videoDevice.activeFormat = selectedFormat;
            videoDevice.activeVideoMinFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            [videoDevice unlockForConfiguration];
        }
    }
    [self.captureSession startRunning];
}

#pragma mark - 慢速关
- (void)cameraBackgroundDidClickCloseSlow {
    _isSlow = NO;
    [self.captureSession stopRunning];
    CGFloat desiredFPS = 60.0;
    AVCaptureDevice *videoDevice = self.captureDeviceInput.device;
    AVCaptureDeviceFormat *selectedFormat = nil;
    int32_t maxWidth = 0;
    AVFrameRateRange *frameRateRange = nil;
    for (AVCaptureDeviceFormat *format in [videoDevice formats]) {
        for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
            CMFormatDescriptionRef desc = format.formatDescription;
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(desc);
            int32_t width = dimensions.width;
            if (range.minFrameRate <= desiredFPS && desiredFPS <= range.maxFrameRate && width >= maxWidth) {
                selectedFormat = format;
                frameRateRange = range;
                maxWidth = width;
            }
        }
    }
    if (selectedFormat) {
        if ([videoDevice lockForConfiguration:nil]) {
            NSLog(@"selected format: %@", selectedFormat);
            videoDevice.activeFormat = _defaultFormat;
            videoDevice.activeVideoMinFrameDuration = _defaultMinFrameDuration;
            videoDevice.activeVideoMaxFrameDuration = _defaultMaxFrameDuration;
            [videoDevice unlockForConfiguration];
        }
    }
    [self.captureSession startRunning];
}

#pragma mark - 防抖开
- (void)cameraBackgroundDidClickOpenAntiShake {
    AVCaptureConnection *captureConnection = [_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    NSLog(@"change captureConnection: %@", captureConnection);
    AVCaptureDevice *videoDevice = self.captureDeviceInput.device;
    NSLog(@"set format: %@", videoDevice.activeFormat);
    if ([videoDevice.activeFormat isVideoStabilizationModeSupported:AVCaptureVideoStabilizationModeCinematic]) {
        captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeCinematic;
    }
}

#pragma mark - 防抖关
- (void)cameraBackgroundDidClickCloseAntiShake {
    AVCaptureConnection *captureConnection = [_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    NSLog(@"change captureConnection: %@", captureConnection);
    AVCaptureDevice *videoDevice = self.captureDeviceInput.device;
    if ([videoDevice.activeFormat isVideoStabilizationModeSupported:AVCaptureVideoStabilizationModeOff]) {
        captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeOff;
    }
}

#pragma mark - 保存
- (void)cameraBackgroundDidClickSave {
    NSLog(@"%@", self.moviePaths);
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.frame = CGRectMake((self.frame.size.width - 80) * 0.5, (self.frame.size.height - 80) * 0.5, 80, 80);
    indicator.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.6];
    indicator.layer.cornerRadius = 6;
    indicator.clipsToBounds = YES;
    [indicator startAnimating];
    [self addSubview:indicator];
    
    typeof(self) weakSelf = self;
    
    self.setVideoSpeedBlock = ^ {
        NSMutableArray *paths = weakSelf.processedVideoPaths;
        NSLog(@"%@", paths);
        [weakSelf mergeVideosWithPaths:paths completed:^(NSString *videoPath) {
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            if (![library videoAtPathIsCompatibleWithSavedPhotosAlbum:[NSURL URLWithString:videoPath]]) return;
            [library writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:videoPath] completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [weakSelf reset];
                    [indicator removeFromSuperview];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
                                                                   delegate:weakSelf cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [weakSelf reset];
                    [indicator removeFromSuperview];
                }
            }];
        }];
    };
    
    [self setVideoSpeedCompleted:self.setVideoSpeedBlock];
}
#pragma mark - 处理视频速度
- (void)setVideoSpeedCompleted:(setVideoSpeedBlock)block {
    [self setVideoSpeed];
}

/// 递归处理按顺序视频
- (void)setVideoSpeed{
    typeof(self) weakSelf = self;
    [self setSpeedWithVideo:self.moviePaths[_index++] completed:^{
        NSLog(@"%zd--%zd", weakSelf.index, weakSelf.moviePaths.count);
        if (_index == weakSelf.moviePaths.count) {
            weakSelf.setVideoSpeedBlock();
            return;
        };
        [weakSelf setVideoSpeed];
    }];
}

/// 处理速度视频
- (void)setSpeedWithVideo:(NSDictionary *)video completed:(void(^)())completed {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"video set thread: %@", [NSThread currentThread]);
        // 获取视频
        AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:video[kMoviePath]] options:nil];
        // 视频混合
        AVMutableComposition* mixComposition = [AVMutableComposition composition];
        // 视频轨道
        AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        // 音频轨道
        AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        
        // 视频的方向
        CGAffineTransform videoTransform = [videoAsset tracksWithMediaType:AVMediaTypeVideo].lastObject.preferredTransform;
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
        // 根据视频的方向同步视频轨道方向
        compositionVideoTrack.preferredTransform = videoTransform;
        compositionVideoTrack.naturalTimeScale = 600;
        
        // 插入视频轨道
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(videoAsset.duration.value, videoAsset.duration.timescale)) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:kCMTimeZero error:nil];
        // 插入音频轨道
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(videoAsset.duration.value, videoAsset.duration.timescale)) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject] atTime:kCMTimeZero error:nil];
        
        // 适配视频速度比率
        CGFloat scale = 1.0;
        if([video[kMovieSpeed] isEqualToString:kMovieSpeed_Fast]){
            scale = 0.2f;  // 快速 x5
        } else if ([video[kMovieSpeed] isEqualToString:kMovieSpeed_Slow]) {
            scale = 4.0f;  // 慢速 x4
        }
        
        // 根据速度比率调节音频和视频
        [compositionVideoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(videoAsset.duration.value, videoAsset.duration.timescale)) toDuration:CMTimeMake(videoAsset.duration.value * scale , videoAsset.duration.timescale)];
        [compositionAudioTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(videoAsset.duration.value, videoAsset.duration.timescale)) toDuration:CMTimeMake(videoAsset.duration.value * scale, videoAsset.duration.timescale)];
        
        // 配置导出
        AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPreset1280x720];
        // 导出视频的临时保存路径
        NSString *exportPath = [kCachePath stringByAppendingPathComponent:[self movieName]];
        NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
        
        // 导出视频的格式 .MOV
        _assetExport.outputFileType = AVFileTypeQuickTimeMovie;
        _assetExport.outputURL = exportUrl;
        _assetExport.shouldOptimizeForNetworkUse = YES;
        
        // 导出视频
        [_assetExport exportAsynchronouslyWithCompletionHandler:
         ^(void ) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_processedVideoPaths addObject:exportPath];
                 // 将导出的视频保存到相册
                 ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                 if (![library videoAtPathIsCompatibleWithSavedPhotosAlbum:[NSURL URLWithString:exportPath]]){
                     NSLog(@"cache can't write");
                     completed();
                     return;
                 }
                 [library writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:exportPath] completionBlock:^(NSURL *assetURL, NSError *error) {
                     if (error) {
                         completed();
                         NSLog(@"cache write error");
                     } else {
                         completed();
                         NSLog(@"cache write success");
                     }
                 }];
             });
         }];
    });
}

#pragma mark - 重置状态
- (void)reset {
    [self clearCache];
    _currentMoviePath = nil;
    _index = 0;
    [_moviePaths removeAllObjects];
    [_backgroundView reset];
}

#pragma mark - 删除
- (void)cameraBackgroundDidClickDeleteCompleted:(void (^)())completed {
    if (!self.moviePaths.count) {
        completed();
        return;
    };
    [self getCacheCompleted:^(NSString *string) {
        NSLog(@"删除前%@", string);
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString *cachePath = self.moviePaths.lastObject[kMoviePath];
        [manager removeItemAtPath:cachePath error:nil];
        [self.moviePaths removeLastObject];
        completed();
        [self getCacheCompleted:^(NSString *string) {
            NSLog(@"删除后%@", string);
        }];
    }];
}

#pragma mark - 将分段视频合称为一个视频
- (void)mergeVideosWithPaths:(NSArray *)paths completed:(void(^)(NSString *videoPath))completed {
    if (!paths.count) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        videoTrack.preferredTransform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2);
        
        CMTime totalDuration = kCMTimeZero;
        
//        NSMutableArray<AVMutableVideoCompositionLayerInstruction *> *instructions = [NSMutableArray array];
        
        for (int i = 0; i < paths.count; i++) {
            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:paths[i]]];
            
            
            AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
            AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
            
            NSLog(@"%lld", asset.duration.value/asset.duration.timescale);
            
            NSError *erroraudio = nil;
            BOOL ba = [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetAudioTrack atTime:totalDuration error:&erroraudio];
            NSLog(@"erroraudio:%@--%d", erroraudio, ba);
            
            NSError *errorVideo = nil;

            BOOL bl = [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetVideoTrack atTime:totalDuration error:&errorVideo];
            NSLog(@"errorVideo:%@--%d",errorVideo,bl);
            
//            AVMutableVideoCompositionLayerInstruction *instruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
//            UIImageOrientation assetOrientation = UIImageOrientationUp;
//            BOOL isAssetPortrait = NO;
//            // 根据视频的实际拍摄方向来调整视频的方向
//            CGAffineTransform videoTransform = assetVideoTrack.preferredTransform;
//            if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
//                NSLog(@"垂直拍摄");
//                assetOrientation = UIImageOrientationRight;
//                isAssetPortrait = YES;
//            }else if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
//                NSLog(@"倒立拍摄");
//                assetOrientation = UIImageOrientationLeft;
//                isAssetPortrait = YES;
//            }else if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
//                NSLog(@"Home键右侧水平拍摄");
//                assetOrientation = UIImageOrientationUp;
//            }else if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
//                NSLog(@"Home键左侧水平拍摄");
//                assetOrientation = UIImageOrientationDown;
//            }
//            CGFloat assetScaleToFitRatio = 720.0 / assetVideoTrack.naturalSize.width;
//            if (isAssetPortrait) {
//                assetScaleToFitRatio = 720.0 / assetVideoTrack.naturalSize.height;
//                CGAffineTransform assetSacleFactor = CGAffineTransformMakeScale(assetScaleToFitRatio, assetScaleToFitRatio);
//                [instruction setTransform:CGAffineTransformConcat(assetVideoTrack.preferredTransform, assetSacleFactor) atTime:totalDuration];
//            } else {
//                /**
//                 竖直方向视频尺寸：720*1280
//                 水平方向视频尺寸：720*405
//                 水平方向视频需要剧中的y值：（1280 － 405）／ 2 ＝ 437.5
//                 **/
//                CGAffineTransform assetSacleFactor = CGAffineTransformMakeScale(assetScaleToFitRatio, assetScaleToFitRatio);
//                [instruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(assetVideoTrack.preferredTransform, assetSacleFactor), CGAffineTransformMakeTranslation(0, 437.5)) atTime:totalDuration];
//            }
//            // 把新的插入到最上面，最后是按照数组顺序播放的。
//            [instructions insertObject:instruction atIndex:0];
//            totalDuration = CMTimeAdd(totalDuration, asset.duration);
//            // 在当前视频时间点结束后需要清空尺寸，否则如果第二个视频尺寸比第一个小，它会显示在第二个视频的下方。
//            [instruction setCropRectangle:CGRectZero atTime:totalDuration];
        }
        
//        AVMutableVideoCompositionInstruction *mixInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//        mixInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
//        mixInstruction.layerInstructions = instructions;
        
//        AVMutableVideoComposition *mixVideoComposition = [AVMutableVideoComposition videoComposition];
//        mixVideoComposition.instructions = [NSArray arrayWithObject:mixInstruction];
//        mixVideoComposition.frameDuration = CMTimeMake(1, 25);
//        mixVideoComposition.renderSize = CGSizeMake(720.0, 1280.0);
//
        NSString *outPath = [kVideoPath stringByAppendingPathComponent:[self movieName]];
        NSURL *mergeFileURL = [NSURL fileURLWithPath:outPath];
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
        exporter.outputURL = mergeFileURL;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
//        exporter.videoComposition = mixVideoComposition;
        exporter.shouldOptimizeForNetworkUse = YES;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
             dispatch_async(dispatch_get_main_queue(), ^{
                 completed(outPath);
             });
         }];
    });
}

#pragma mark - 返回录制时间
- (NSArray *)cameraBackgroundMovies {
    return self.moviePaths;
}

#pragma mark - 内部处理方法
- (NSString *)movieName {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddHHmmssSSS"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString =[NSString stringWithFormat:@"%@",_timeStr];
    return [currentTimeString stringByAppendingString:@".MOV"];
}

#pragma mark - 清除临时文件
- (void)clearCache {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *cachePath = kCachePath;
    [manager removeItemAtPath:cachePath error:nil];
    
    BOOL isDirectory = NO;
    if ([manager fileExistsAtPath:cachePath isDirectory:&isDirectory]) {
        NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:cachePath];
        for (NSString *subPath in enumerator) {
            NSString *fullPath = [cachePath stringByAppendingPathComponent:subPath];
            NSDictionary *attrs = [manager attributesOfItemAtPath:fullPath error:nil];
            
            if ([attrs[NSFileType] isEqualToString:NSFileTypeDirectory]) continue;
            [manager removeItemAtPath:fullPath error:nil];
        }
    }
    [self getCacheCompleted:^(NSString *string) {
        NSLog(@"after delete: %@", string);
    }];
}

#pragma mark - 缓存大小
- (void)getCacheCompleted:(void(^)(NSString *string))completed {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *creatPath = kCachePath;
        NSString *fileSize=creatPath.fileSizeString;
        CGFloat size = 0.0;
        if ([fileSize hasSuffix:@"KB"]) {
            size += [fileSize doubleValue] * 0.001;
        } else if ([fileSize hasSuffix:@"MB"]) {
            size += [fileSize doubleValue];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completed([NSString stringWithFormat:@"%.1lfM", size]);
        });
    });
}

#pragma mark - KVO回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"ISO"]) {
        CGFloat minISO = self.captureDeviceInput.device.activeFormat.minISO;
        CGFloat maxISO = self.captureDeviceInput.device.activeFormat.maxISO;
        CGFloat currentISO = self.captureDeviceInput.device.ISO;
        CGFloat value = (currentISO - minISO) / (maxISO - minISO);
        _backgroundView.isoSilder.value = value;
    }
}

@end
