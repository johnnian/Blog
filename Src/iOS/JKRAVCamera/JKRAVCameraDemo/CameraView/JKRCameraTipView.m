//
//  JKRCameraTipView.m
//  JKRAVCameraDemo
//
//  Created by Lucky on 2016/10/22.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import "JKRCameraTipView.h"
#import "UILabel+tipLabel.h"

@implementation JKRCameraTipView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    UILabel *l1 = [UILabel tipLabelWithText:@"闪光灯开关"];
    l1.frame = CGRectMake(55, 20, 200, 30);
    [self addSubview:l1];
    
    UILabel *l2 = [UILabel tipLabelWithText:@"前后摄像头切换"];
    l2.frame = CGRectMake(55, CGRectGetMaxY(l1.frame) + 20, 200, 30);
    [self addSubview:l2];
    
    UILabel *l3 = [UILabel tipLabelWithText:@"快动作录制"];
    l3.frame = CGRectMake(55, CGRectGetMaxY(l2.frame) + 20, 200, 30);
    [self addSubview:l3];
    
    UILabel *l4 = [UILabel tipLabelWithText:@"慢动作录制"];
    l4.frame = CGRectMake(55, CGRectGetMaxY(l3.frame) + 20, 200, 30);
    [self addSubview:l4];
    
    UILabel *l5 = [UILabel tipLabelWithText:@"光学防抖开关"];
    l5.frame = CGRectMake(55, CGRectGetMaxY(l4.frame) + 20, 200, 30);
    [self addSubview:l5];
    
    UILabel *l6 = [UILabel tipLabelWithText:@"合并并保存视频"];
    l6.frame = CGRectMake(55, CGRectGetMaxY(l5.frame) + 20, 200, 30);
    [self addSubview:l6];
    
    UILabel *l7 = [UILabel tipLabelWithText:@"删除最后一段视频"];
    l7.frame = CGRectMake(55, CGRectGetMaxY(l6.frame) + 20, 200, 30);
    [self addSubview:l7];
    
    UILabel *l8 = [UILabel tipLabelWithText:@"浏览视频列表"];
    l8.frame = CGRectMake(55, CGRectGetMaxY(l7.frame) + 20, 200, 30);
    [self addSubview:l8];
    
    UILabel *l9 = [UILabel tipLabelWithText:@"暂停／继续"];
    l9.textAlignment = NSTextAlignmentCenter;
    l9.frame = CGRectMake((kScreenWidth - 200) / 2, kScreenHeight - 100, 200, 30);
    [self addSubview:l9];
    
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self removeFromSuperview];
}

@end
