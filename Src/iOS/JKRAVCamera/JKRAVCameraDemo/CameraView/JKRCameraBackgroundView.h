//
//  JKRCameraBackgroundView.h
//  JKRCameraDemo
//
//  Created by tronsis_ios on 16/8/30.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKRCameraProgressView.h"
#import "JKRMenuViewController.h"

@protocol JKRCameraBackgroundViewDelegate <NSObject>

- (void)cameraBackgroundDidClickOpenFlash;
- (void)cameraBackgroundDidClickCloseFlash;
- (void)cameraBackgroundDidClickChangeFront;
- (void)cameraBackgroundDidClickChangeBack;
- (void)cameraBackgroundDidChangeFocus:(CGFloat)focus;
- (void)cameraBackgroundDidChangeZoom:(CGFloat)zoom;
- (void)cameraBackgroundDidChangeISO:(CGFloat)iso;
- (void)cameraBackgroundDidTap:(CGPoint)point;
- (void)cameraBackgroundDidClickPlay;
- (void)cameraBackgroundDidClickPause;
- (void)cameraBackgroundDidClickSave;
- (void)cameraBackgroundDidClickDeleteCompleted:(void(^)())completed;
- (void)cameraBackgroundDidClickOpenFast;
- (void)cameraBackgroundDidClickCloseFast;
- (void)cameraBackgroundDidClickOpenSlow;
- (void)cameraBackgroundDidClickCloseSlow;
- (void)cameraBackgroundDidClickOpenAntiShake;
- (void)cameraBackgroundDidClickCloseAntiShake;

@end

@protocol JKRCameraBackgroundViewDatasource <NSObject>

- (NSArray *)cameraBackgroundMovies;

@end

@interface JKRCameraBackgroundView : UIView

@property (nonatomic, strong) UIButton *flashButton;                     ///< 闪光灯开关
@property (nonatomic, strong) UIButton *frontAndBackChange;              ///< 前后摄像头切换
@property (nonatomic, strong) UIButton *playButton;                      ///< 播放暂停按钮
@property (nonatomic, strong) UIButton *saveButton;                      ///< 保存按钮
@property (nonatomic, strong) UIButton *deleteButton;                    ///< 删除按钮
@property (nonatomic, strong) UIButton *menuButton;                      ///< 菜单按钮
@property (nonatomic, strong) UIButton *slowButton;                      ///< 慢动作按钮
@property (nonatomic, strong) UIButton *fastButton;                      ///< 开动作按钮
@property (nonatomic, strong) UIButton *antiShakeButton;                 ///< 光学防抖开关

@property (nonatomic, strong) UISlider *focusSilder;                     
@property (nonatomic, strong) UISlider *zoomSilder;
@property (nonatomic, strong) UISlider *isoSilder;
@property (nonatomic, assign) CGFloat zoomValue;
@property (nonatomic, strong) CAShapeLayer *focusLayer;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, assign) BOOL deleteHasClick;
@property (nonatomic, strong) JKRCameraProgressView *progressView;
@property (nonatomic, assign) BOOL isFront;
@property (nonatomic, assign) BOOL isFast;
@property (nonatomic, assign) BOOL isSlow;
@property (nonatomic, assign) BOOL isAntiShake;

@property (nonatomic, weak) id<JKRCameraBackgroundViewDelegate> delegate;
@property (nonatomic, weak) id<JKRCameraBackgroundViewDatasource> datasource;

- (void)setOrientation:(UIDeviceOrientation)orientation;
- (void)reset;

@end
