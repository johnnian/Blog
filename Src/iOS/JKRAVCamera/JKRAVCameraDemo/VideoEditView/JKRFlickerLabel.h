//
//  JKRFlickerLabel.h
//  JKRAVCameraDemo
//
//  Created by tronsis_ios on 16/9/9.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JKRFlickerLabel : UILabel

@property (nonatomic, assign) CFTimeInterval shineDuration;
@property (nonatomic, assign) CFTimeInterval fadeoutDuration;
@property (nonatomic, assign, getter=isAutoStart) BOOL autoStart;
@property (nonatomic, assign, getter=isShining) BOOL shining;
@property (nonatomic, assign, getter=isVisible) BOOL visible;

- (void)shine;
- (void)shineWithCompletion:(void (^)())completion;
- (void)fadeOut;
- (void)fadeOutWithCompletion:(void (^)())completion;

@end
