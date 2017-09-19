//
//  JKREditViewController.m
//  JKRAVCameraDemo
//
//  Created by tronsis_ios on 16/9/1.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import "JKREditViewController.h"
#import "JKRVideoEditView.h"

@interface JKREditViewController ()

@property (nonatomic, strong) JKRVideoEditView *editView;

@end

@implementation JKREditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _editView = [[JKRVideoEditView alloc] initWithFrame:self.view.bounds video:_video];
    [self.view addSubview:_editView];
}

- (void)dealloc {
    
}

@end
