//
//  JKRVideoBackGroundView.h
//  JKRAVCameraDemo
//
//  Created by tronsis_ios on 16/9/2.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JKRVideoBackGroundViewDelegate <NSObject>

@required
- (void)videoBackGroundViewDidClickBack;
- (void)videoBackGroundViewDidClickRemove;
- (void)videoBackGroundViewDidClickAdd;

@end

@interface JKRVideoBackGroundView : UIView

@property (nonatomic, weak) id<JKRVideoBackGroundViewDelegate> delegate;

@end
