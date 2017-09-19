//
//  JKRCameraProgressView.h
//  JKRCameraDemo
//
//  Created by tronsis_ios on 16/8/31.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JKRCameraProgressViewDelegate <NSObject>

@required
- (void)cameraProgressViewDidFullTime;

@end

@interface JKRCameraProgressView : UIView

@property (nonatomic, weak) id<JKRCameraProgressViewDelegate> delegate;

- (void)start;
- (void)stop;
- (void)deleteClick;
- (void)deleteSure;

- (void)reset;

@end
