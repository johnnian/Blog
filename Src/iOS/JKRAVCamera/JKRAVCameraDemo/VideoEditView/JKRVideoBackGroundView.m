//
//  JKRVideoBackGroundView.m
//  JKRAVCameraDemo
//
//  Created by tronsis_ios on 16/9/2.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import "JKRVideoBackGroundView.h"

@interface JKRVideoBackGroundView ()

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIButton *removeButton;
@property (nonatomic, strong) UIButton *saveButton;

@end

@implementation JKRVideoBackGroundView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    
    _backButton = [UIButton new];
    _backButton.frame = CGRectMake(10, 10, 50, 50);
    [_backButton setTitle:@"返回" forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backButton];
    
    _addButton = [UIButton new];
    _addButton.frame = CGRectMake(10, 60, 50, 50);
    [_addButton setTitle:@"添加" forState:UIControlStateNormal];
    [_addButton addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_addButton];
    
    _removeButton = [UIButton new];
    _removeButton.frame = CGRectMake(10, 110, 50, 50);
    [_removeButton setTitle:@"移除" forState:UIControlStateNormal];
    [_removeButton addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_removeButton];
    
    _saveButton = [UIButton new];
    _saveButton.frame = CGRectMake(10, 160, 50, 50);
    [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_saveButton];
    
    return self;
}

- (void)back {
    [self.delegate videoBackGroundViewDidClickBack];
}

- (void)add {
    [self.delegate videoBackGroundViewDidClickAdd];
}

- (void)remove {
    [self.delegate videoBackGroundViewDidClickRemove];
}

- (void)save {
    
}

@end
