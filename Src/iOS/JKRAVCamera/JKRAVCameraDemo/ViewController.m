//
//  ViewController.m
//  JKRAVCameraDemo
//
//  Created by tronsis_ios on 16/8/31.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import "ViewController.h"
#import "JKRCameraView.h"

@interface ViewController ()

@property (nonatomic, strong) JKRCameraView *cameraView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITextView *textView;
    [textView.layoutManager boundingRectForGlyphRange:NSMakeRange(0, 1) inTextContainer:textView.textContainer];
    
    _cameraView = [[JKRCameraView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_cameraView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
