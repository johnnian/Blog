//
//  JKRCameraBackgroundView.m
//  JKRCameraDemo
//
//  Created by tronsis_ios on 16/8/30.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import "JKRCameraBackgroundView.h"
#import "UIImage+image.h"
#import "JKRCameraTipView.h"
#import <CoreMotion/CoreMotion.h>

@interface JKRCameraBackgroundView ()<JKRCameraProgressViewDelegate>
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSFileHandle* fileHandle;

@end

@implementation JKRCameraBackgroundView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _flashButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 30, 30)];
    _flashButton.backgroundColor = [UIColor clearColor];
    [_flashButton setImage:[UIImage iconImageNamed:@"flash_off"] forState:UIControlStateNormal];
    [_flashButton setImage:[UIImage iconImageNamed:@"flash_on"] forState:UIControlStateSelected];
    [_flashButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    [_flashButton addTarget:self action:@selector(changeFlash) forControlEvents:UIControlEventTouchUpInside];
    
    _frontAndBackChange = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_flashButton.frame) + 20, 30, 30)];
    _frontAndBackChange.backgroundColor = [UIColor clearColor];
    [_frontAndBackChange setImage:[UIImage iconImageNamed:@"switch_camera"] forState:UIControlStateNormal];
    [_frontAndBackChange setImage:[UIImage iconImageNamed:@"switch_camera"] forState:UIControlStateSelected];
    [_frontAndBackChange setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    [_frontAndBackChange addTarget:self action:@selector(changeFrontAndBack) forControlEvents:UIControlEventTouchUpInside];
    
    _fastButton = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_frontAndBackChange.frame) + 20, 30, 30)];
    _fastButton.backgroundColor = [UIColor clearColor];
    [_fastButton setImage:[UIImage iconImageNamed:@"running_close"] forState:UIControlStateNormal];
    [_fastButton setImage:[UIImage iconImageNamed:@"running_open"] forState:UIControlStateSelected];
    [_fastButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    [_fastButton addTarget:self action:@selector(fast) forControlEvents:UIControlEventTouchUpInside];
    
    _slowButton = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_fastButton.frame) + 20, 30, 30)];
    _slowButton.backgroundColor = [UIColor clearColor];
    [_slowButton setImage:[UIImage iconImageNamed:@"whiplash"] forState:UIControlStateNormal];
    [_slowButton setImage:[UIImage iconImageNamed:@"burn"] forState:UIControlStateSelected];
    [_slowButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    [_slowButton addTarget:self action:@selector(slow) forControlEvents:UIControlEventTouchUpInside];
    
    _antiShakeButton = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_slowButton.frame) + 20, 30, 30)];
    _antiShakeButton.backgroundColor = [UIColor clearColor];
    [_antiShakeButton setImage:[UIImage iconImageNamed:@"antiShake_open"] forState:UIControlStateNormal];
    [_antiShakeButton setImage:[UIImage iconImageNamed:@"antiShake_close"] forState:UIControlStateSelected];
    [_antiShakeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    [_antiShakeButton addTarget:self action:@selector(antiShake) forControlEvents:UIControlEventTouchUpInside];
    
    _saveButton = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_antiShakeButton.frame) + 20, 30, 30)];
    _saveButton.backgroundColor = [UIColor clearColor];
    [_saveButton setImage:[UIImage iconImageNamed:@"save"] forState:UIControlStateNormal];
    [_saveButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    [_saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    _saveButton.enabled = NO;
    
    _deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_saveButton.frame) + 20, 30, 30)];
    _deleteButton.backgroundColor = [UIColor clearColor];
    [_deleteButton setImage:[UIImage iconImageNamed:@"delete"] forState:UIControlStateNormal];
    [_deleteButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    [_deleteButton addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
    _deleteButton.enabled = NO;
    
    _menuButton = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_deleteButton.frame) + 20, 30, 30)];
    _menuButton.backgroundColor = [UIColor clearColor];
    [_menuButton setImage:[UIImage iconImageNamed:@"list"] forState:UIControlStateNormal];
    [_menuButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    [_menuButton addTarget:self action:@selector(menu) forControlEvents:UIControlEventTouchUpInside];
    
    CALayer *bgLayer = [CALayer new];
    bgLayer.frame = CGRectMake(8, CGRectGetMinY(_flashButton.frame) - 2, 34, CGRectGetMaxY(_menuButton.frame) - CGRectGetMinY(_flashButton.frame) + 2);
    bgLayer.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5].CGColor;
    [self.layer addSublayer:bgLayer];
    
    _playButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 75) / 2, kScreenHeight - 80, 75, 75)];
    _playButton.backgroundColor = [UIColor clearColor];
    [_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateSelected];
    _playButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_playButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    [_playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    
    _focusSilder = [[UISlider alloc] initWithFrame:CGRectMake(frame.size.width - 250, 50, 200, 20)];
    [self setSider:_focusSilder withText:@"手动对焦"];
    _focusSilder.minimumValue = 0.0;
    _focusSilder.maximumValue = 1.0;
    _focusSilder.value = 0.0;
    [_focusSilder addTarget:self action:@selector(changeFocus:) forControlEvents:UIControlEventValueChanged];
    
    _zoomSilder = [[UISlider alloc] initWithFrame:CGRectMake(frame.size.width - 250, 100, 200, 20)];
    [self setSider:_zoomSilder withText:@"焦距调节"];
    _zoomSilder.minimumValue = 1.0;
    _zoomSilder.maximumValue = 3.0;
    _zoomSilder.value = 1.0;
    _zoomValue = _zoomSilder.value;
    [_zoomSilder addTarget:self action:@selector(changeZoom:) forControlEvents:UIControlEventValueChanged];
    
    _isoSilder = [[UISlider alloc] initWithFrame:CGRectMake(frame.size.width - 250, 150, 200, 20)];
    [self setSider:_isoSilder withText:@"感光度调节"];
    _isoSilder.minimumValue = 0.0;
    _isoSilder.maximumValue = 1.0;
    _isoSilder.value = 0.0;
    [_isoSilder addTarget:self action:@selector(changeISO:) forControlEvents:UIControlEventValueChanged];
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureRecognizerAction:)];
    [self addGestureRecognizer:pinchGestureRecognizer];
    
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:_flashButton];
    [self addSubview:_frontAndBackChange];
    [self addSubview:_focusSilder];
    [self addSubview:_zoomSilder];
    [self addSubview:_isoSilder];
    [self addSubview:_playButton];
    [self addSubview:_saveButton];
    [self addSubview:_deleteButton];
    [self addSubview:_menuButton];
    [self addSubview:_fastButton];
    [self addSubview:_slowButton];
    [self addSubview:_antiShakeButton];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerAction:)];
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGestureRecognizer];
    
    _focusLayer = [[CAShapeLayer alloc] init];
    _focusLayer.lineWidth = 4;
    _focusLayer.strokeColor = [UIColor orangeColor].CGColor;
    _focusLayer.fillColor = [UIColor clearColor].CGColor;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 100, 100)];
    [path closePath];
    _focusLayer.path = path.CGPath;
    [self.layer addSublayer:_focusLayer];
    _focusLayer.hidden = YES;
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 45, frame.size.width, 45)];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.font = [UIFont systemFontOfSize:20];
    [self addSubview:_timeLabel];
    
    _progressView = [[JKRCameraProgressView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 6, frame.size.width, 6)];
    _progressView.delegate = self;
    [self addSubview:_progressView];
    
    JKRCameraTipView *tipView = [JKRCameraTipView new];
    tipView.frame = self.bounds;
    [self addSubview:tipView];
    
    //初始化陀螺仪管理对象
    _motionManager = [[CMMotionManager alloc] init];
    _queue = [[NSOperationQueue alloc] init];
    
    return self;
}

- (void)setSider:(UISlider *)silder withText:(NSString *)text {
    UIImage *bgImage = [UIImage imageWithColor:[UIColor orangeColor] size:CGSizeMake(200, 5)];
    UIImage *slImage = [[UIImage imageWithColor:[UIColor brownColor] size:CGSizeMake(12, 12)] imageClipCircle];
    [silder setMinimumTrackImage:bgImage forState:UIControlStateNormal];
    [silder setMaximumTrackImage:bgImage forState:UIControlStateNormal];
    [silder setThumbImage:slImage forState:UIControlStateNormal];
    [silder setThumbImage:slImage forState:UIControlStateNormal];
    CATextLayer *textLayer = [CATextLayer new];
    textLayer.fontSize = 13;
    textLayer.frame = CGRectMake(CGRectGetMinX(silder.frame) + 20, CGRectGetMinY(silder.frame) - 15, 100, 15);
    textLayer.foregroundColor = [UIColor redColor].CGColor;
    textLayer.string = text;
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:textLayer];
}

#pragma mark - 闪光灯开关
- (void)changeFlash {
    _flashButton.selected = !_flashButton.selected;
    if (_flashButton.selected) [self.delegate cameraBackgroundDidClickOpenFlash];
    else [self.delegate cameraBackgroundDidClickCloseFlash];
}

#pragma mark - 前后摄像头切换
- (void)changeFrontAndBack {
    _frontAndBackChange.selected = !_frontAndBackChange.selected;
    if (_frontAndBackChange.selected) {
        [self.delegate cameraBackgroundDidClickChangeFront];
        _flashButton.selected = NO;
        _flashButton.enabled = NO;
        _fastButton.selected = NO;
        _slowButton.selected = NO;
        _antiShakeButton.selected = NO;
        _fastButton.enabled = NO;
        _antiShakeButton.enabled = NO;
        _fastButton.enabled = NO;
        _slowButton.enabled = NO;
        _isFront = YES;
    } else {
        _flashButton.enabled = YES;
        [self.delegate cameraBackgroundDidClickChangeBack];
        _isFront = NO;
        _antiShakeButton.selected = YES;
        _fastButton.enabled = YES;
        _antiShakeButton.enabled = YES;
        _fastButton.enabled = YES;
        _slowButton.enabled = YES;
    }
}

#pragma mark - 快速
- (void)fast {
    _slowButton.selected = NO;
    _fastButton.selected = !_fastButton.selected;
    _isSlow = NO;
    if (_fastButton.selected) {
        _isFast = YES;
        [self.delegate cameraBackgroundDidClickOpenFast];
    } else {
        _isFast = NO;
        [self.delegate cameraBackgroundDidClickCloseFast];
    }
}

#pragma mark - 慢速
- (void)slow {
    _isFast = NO;
    _fastButton.selected = NO;
    _slowButton.selected = !_slowButton.selected;
    if (_slowButton.selected) {
        _isSlow = YES;
        [self.delegate cameraBackgroundDidClickOpenSlow];
    } else {
        _isSlow = NO;
        [self.delegate cameraBackgroundDidClickCloseSlow];
    }
}

#pragma mark - 录制／暂停
- (void)play {
    _playButton.selected = !_playButton.selected;
    if (_playButton.selected) {
        NSLog(@"played");
        
        [self startGyroUpdatesToQueue];
        
        
        [self.delegate cameraBackgroundDidClickPlay];
        _deleteHasClick = NO;
        [_progressView start];
        if (_isFront) _frontAndBackChange.selected = NO;
        _frontAndBackChange.enabled = NO;
        if (_isSlow) _slowButton.selected = NO;
        if (_isFast) _fastButton.selected = NO;
        if (!_isAntiShake) _antiShakeButton.selected = NO;
        _slowButton.enabled = NO;
        _fastButton.enabled = NO;
        _saveButton.enabled = NO;
        _deleteButton.enabled = NO;
        _menuButton.enabled = NO;
        _antiShakeButton.enabled = NO;
    } else {
        NSLog(@"paused");
        
        [self stopGyroUpdatesToQueue];
        
        if (_isFront) _frontAndBackChange.selected = YES;
        _frontAndBackChange.enabled = YES;
        [self.delegate cameraBackgroundDidClickPause];
        if (_isFast) _fastButton.selected = YES;
        if (_isSlow) _slowButton.selected = YES;
        [_progressView stop];
        _slowButton.enabled = YES;
        _fastButton.enabled = YES;
        _menuButton.enabled = YES;
        if (!_isAntiShake) _antiShakeButton.selected = YES;
        self.saveButton.enabled = [self.datasource cameraBackgroundMovies].count;
        self.deleteButton.enabled = [self.datasource cameraBackgroundMovies].count;
        _antiShakeButton.enabled = YES;
    }
}

#pragma mark - 保存视频
- (void)save {
    [self.delegate cameraBackgroundDidClickSave];
    
    [self savestartGyroData];
}



#pragma mark -螺旋仪器操作

- (void)startGyroUpdatesToQueue {

    NSLog(@"开启了螺旋仪...");
    //判断陀螺仪可不可以，判断陀螺仪是不是开启
    if ([_motionManager isGyroAvailable] && ![_motionManager isGyroActive]){
        
        //创建CVS文件
        [self createFile];
        
        //告诉manager，更新频率是100Hz
        _motionManager.gyroUpdateInterval = 0.01;
        
        __weak typeof(self) weakSelf = self;
        
        //Push方式获取和处理数据
        [_motionManager startGyroUpdatesToQueue:_queue
                             withHandler:^(CMGyroData *gyroData, NSError *error)
         {
             NSLog(@"Gyro Rotation x = %.04f", gyroData.rotationRate.x);
             NSLog(@"Gyro Rotation y = %.04f", gyroData.rotationRate.y);
             NSLog(@"Gyro Rotation z = %.04f", gyroData.rotationRate.z);
             
             [weakSelf writeCSVData:gyroData.rotationRate.x with:gyroData.rotationRate.y with:gyroData.rotationRate.z];
             
         }];
    }
}

- (void)stopGyroUpdatesToQueue {
    
    NSLog(@"关闭了螺旋仪...");
    //判断陀螺仪可不可以，判断陀螺仪是不是开启
    if ([_motionManager isGyroAvailable] && [_motionManager isGyroActive]){
        //Push方式获取和处理数据
        [_motionManager stopGyroUpdates];
    }
}

- (void)savestartGyroData {
    
    if (_fileHandle != nil) {
        
        [_fileHandle closeFile];
    }

}

#pragma mark -保存CVS格式文件

-(void)createFile{
   
    NSArray *paths  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *homePath = [paths objectAtIndex:0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddHHmmssSSS"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    NSString *fileName = [NSString stringWithFormat:@"%@.csv",currentTimeString];
    
    _filePath = [homePath stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:_filePath]) //如果不存在
    {
        NSString *str = [NSString stringWithFormat:@"陀螺仪数据生成时间：%@， 格式如下：\n 时间, X, Y, Z\n",currentTimeString];
        [str writeToFile:_filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    _fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:_filePath];
    [_fileHandle seekToEndOfFile];  //将节点跳到文件的末尾
    
}


-(void)writeCSVData:(double) x with:(double) y with:(double) z {
    
   NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddHHmmssSSS"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    

    NSString *str = [NSString stringWithFormat:@"%@, %.04f,%.04f,%.04f\n", currentTimeString, x, y, z];
    
    NSData *stringData = [str dataUsingEncoding:NSUTF8StringEncoding];
    //追加写入数据
    [_fileHandle writeData:stringData];

    
}


#pragma mark - 删除视频
- (void)delete {
    if (_deleteHasClick) {
        _deleteHasClick = NO;
        [self.delegate cameraBackgroundDidClickDeleteCompleted:^{
            _saveButton.enabled = [self.datasource cameraBackgroundMovies].count;
            _deleteButton.enabled = [self.datasource cameraBackgroundMovies].count;
            _deleteHasClick = NO;
            _playButton.enabled = YES;
            [_progressView deleteSure];
        }];
    } else {
        _deleteHasClick = YES;
        [_progressView deleteClick];
    }
}

#pragma mark - 视频列表
- (void)menu {
    JKRMenuViewController *controller = [[JKRMenuViewController alloc] init];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - 防抖
- (void)antiShake {
    _antiShakeButton.selected = !_antiShakeButton.selected;
    if (!_antiShakeButton.selected) {
        _isAntiShake = YES;
        [self.delegate cameraBackgroundDidClickOpenAntiShake];
    } else {
        _isAntiShake = NO;
        [self.delegate cameraBackgroundDidClickCloseAntiShake];
    }
}

#pragma mark - 改变焦距
- (void)changeFocus:(UISlider *)sender {
    [self.delegate cameraBackgroundDidChangeFocus:sender.value];
}

#pragma mark - 改变取景框
- (void)changeZoom:(UISlider *)sender {
    NSLog(@"%f", sender.value);
    _zoomValue = sender.value;
    [self.delegate cameraBackgroundDidChangeZoom:sender.value];
}

#pragma mark - 改变ISO
- (void)changeISO:(UISlider *)sender {
    [self.delegate cameraBackgroundDidChangeISO:sender.value];
}

#pragma mark - 捏合屏幕改变焦距
- (void)pinchGestureRecognizerAction:(UIPinchGestureRecognizer *)pin {
    if (pin.state == UIGestureRecognizerStateBegan) {
        
    } else if (pin.state == UIGestureRecognizerStateChanged) {
        CGFloat newValue;
        if (pin.scale > 1) {
            newValue = _zoomValue * (1 + pin.scale  / 200);
            if (newValue > 3) newValue = 3;
        } else {
            newValue = _zoomValue - (3.0 * (1 - pin.scale)) * 0.02;
            NSLog(@"%f--%f--%f", pin.scale, _zoomValue, newValue);
            if (newValue < 1) newValue = 1;
        }
        _zoomValue = newValue;
        _zoomSilder.value = _zoomValue;
        [self.delegate cameraBackgroundDidChangeZoom:_zoomSilder.value];
    } else if (pin.state == UIGestureRecognizerStateEnded) {
        
    }
}

#pragma mark -点击屏幕自动对焦
- (void)tapGestureRecognizerAction:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [tap locationInView:self];
        [self.delegate cameraBackgroundDidTap:location];
        [self addFocusLayerWithPoint:location];
    }
}

- (void)addFocusLayerWithPoint:(CGPoint)point {
    CGPoint position = CGPointMake(point.x - 50, point.y - 50);
    [_focusLayer setPosition:position];
    [_focusLayer removeAllAnimations];
    _focusLayer.hidden = NO;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.focusLayer.hidden = YES;
    });
}

#pragma mark - 录制时间已满
- (void)cameraProgressViewDidFullTime {
    [self play];
    _playButton.enabled = NO;
}

#pragma mark - 重置状态
- (void)reset {
    _playButton.enabled = YES;
    _saveButton.enabled = [self.datasource cameraBackgroundMovies].count;
    _deleteButton.enabled = [self.datasource cameraBackgroundMovies].count;
    [_progressView reset];
}

#pragma mark - 旋转
- (void)setOrientation:(UIDeviceOrientation)orientation {
    CGAffineTransform videoTransform = CGAffineTransformMakeRotation(0);
    if (orientation == UIDeviceOrientationPortraitUpsideDown) {
        videoTransform = CGAffineTransformMakeRotation(M_PI);
    }
    if (orientation == UIDeviceOrientationPortrait) {
        videoTransform = CGAffineTransformMakeRotation(0);
    }
    if (orientation == UIDeviceOrientationLandscapeRight) {
        videoTransform = CGAffineTransformMakeRotation(-M_PI_2);
    }
    if (orientation == UIDeviceOrientationLandscapeLeft) {
        videoTransform = CGAffineTransformMakeRotation(M_PI_2);
    }
    CABasicAnimation *anima = [CABasicAnimation animationWithKeyPath:@"transform"];
    anima.duration=2.0;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[UIButton class]]) return;
        obj.layer.anchorPoint = CGPointMake(0.5, 0.5);
        
        anima.toValue=[NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(videoTransform)];
        anima.removedOnCompletion=NO;
        anima.fillMode=kCAFillModeForwards;
        [obj.layer addAnimation:anima forKey:nil];
    }];
}

@end
