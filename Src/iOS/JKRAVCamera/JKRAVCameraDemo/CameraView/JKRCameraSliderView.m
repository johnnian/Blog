
//
//  JKRCameraSliderView.m
//  JKRAVCameraDemo
//
//  Created by Lucky on 2016/10/22.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import "JKRCameraSliderView.h"

@implementation JKRCameraSliderView {
    double _progress;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor whiteColor] setFill];
    UIBezierPath *path0 = [UIBezierPath bezierPathWithRect:rect];
    CGContextAddPath(context, path0.CGPath);
    CGContextFillPath(context);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(48, 5, kScreenWidth - 96, 6) cornerRadius:2];
    [[UIColor orangeColor] setFill];
    CGContextAddPath(context, path.CGPath);
    CGContextFillPath(context);
    
    UIBezierPath *path1 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(48, 5, (kScreenWidth - 96) * _progress, 6) cornerRadius:2.01];
    UIBezierPath *path2 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(40.01 + (kScreenWidth - 96) * _progress, 0, 15.99, 15.99) cornerRadius:7.99];
    [[UIColor darkGrayColor] setFill];
    CGContextAddPath(context, path1.CGPath);
    CGContextAddPath(context, path2.CGPath);
    CGContextFillPath(context);
    
    if ([self.delegate respondsToSelector:@selector(slideView:changeProgress:)])
        [self.delegate slideView:self changeProgress:_progress];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    if (point.x < 40 || point.x > kScreenWidth - 40) return;
    if (point.x < 48) _progress = 0;
    else if (point.x > kScreenWidth - 48) _progress = 1;
    else _progress = (point.x - 48) / (kScreenWidth - 96);
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    if (point.x < 40 || point.x > kScreenWidth - 40) return;
    if (point.x < 48) _progress = 0;
    else if (point.x > kScreenWidth - 48) _progress = 1;
    else _progress = (point.x - 48) / (kScreenWidth - 96);
    [self setNeedsDisplay];
}

@end
