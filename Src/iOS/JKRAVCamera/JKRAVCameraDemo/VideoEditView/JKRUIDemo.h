//
//  JKRUIDemo.h
//  JKRAVCameraDemo
//
//  Created by tronsis_ios on 16/9/8.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CMTime.h>

@interface JKRUIDemo : UIView

@property (nonatomic, readonly) CMTime time;
@property (nonatomic, copy) NSString *firstString;
@property (nonatomic, copy) NSString *secondString;

@end
