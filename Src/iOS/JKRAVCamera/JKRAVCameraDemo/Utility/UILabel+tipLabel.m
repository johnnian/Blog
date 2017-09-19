//
//  UILabel+tipLabel.m
//  JKRAVCameraDemo
//
//  Created by Lucky on 2016/10/22.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import "UILabel+tipLabel.h"

@implementation UILabel (tipLabel)

+ (instancetype)tipLabelWithText:(NSString *)text {
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor redColor];
    label.text = text;
    return label;
}

@end
