//
//  UIImage+image.h
//  JKRAVCameraDemo
//
//  Created by Lucky on 2016/10/22.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (image)

+ (instancetype)iconImageNamed:(NSString *)name;
+ (instancetype)imageWithColor:(UIColor *)color size:(CGSize)size;
- (instancetype)imageClipCircle;

@end
