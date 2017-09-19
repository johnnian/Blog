
//
//  UIImage+runtime.m
//  runtime02
//
//  Created by Lucky on 2016/12/31.
//  Copyright © 2016年 Lucky. All rights reserved.
//

#import "UIImage+runtime.h"
#import <objc/message.h>

@implementation UIImage (runtime)

+ (void)load {
    method_exchangeImplementations(class_getClassMethod([self class], @selector(imageNamed:)), class_getClassMethod([self class], @selector(jkr_imageNamed:)));
}

+ (UIImage *)jkr_imageNamed:(NSString *)name {
    //这里不是看起来是自己调自己，其实因为方法交换，这里调用的是系统方法，如果不这样写，会循环调用
    UIImage *image = [UIImage jkr_imageNamed:name];
    if (image) {
        NSLog(@"=======> load success");
    } else {
        NSLog(@"=======> load failed");
    }
    return image;
}

@end
