//
//  JKRCameraSliderView.h
//  JKRAVCameraDemo
//
//  Created by Lucky on 2016/10/22.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JKRCameraSliderViewDelegate;
@interface JKRCameraSliderView : UIView

@property (nonatomic, weak) id<JKRCameraSliderViewDelegate> delegate;

@end

@protocol JKRCameraSliderViewDelegate <NSObject>

- (void)slideView:(JKRCameraSliderView *)slideView changeProgress:(CGFloat)progress;

@end
