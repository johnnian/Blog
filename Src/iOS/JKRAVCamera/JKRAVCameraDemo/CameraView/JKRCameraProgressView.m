//
//  JKRCameraProgressView.m
//  JKRCameraDemo
//
//  Created by ;; on 16/8/31.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import "JKRCameraProgressView.h"
#import "JKRCameraProgressHistoryLayer.h"

@interface JKRCameraProgressView ()

@property (nonatomic, assign) CGFloat totalTime;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat historyTime;
@property (nonatomic, assign) CGFloat currentTime;
@property (nonatomic, strong) CALayer *progressLayer;
@property (nonatomic, assign) BOOL ifFull;
@property (nonatomic, strong) NSMutableArray<JKRCameraProgressHistoryLayer *> *historyLayers;

@end

@implementation JKRCameraProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _totalTime = 50.0;
    _progressLayer = [[CAShapeLayer alloc] init];
    _progressLayer.backgroundColor = [UIColor orangeColor].CGColor;
    _progressLayer.frame = CGRectMake(0, 0, 0, self.frame.size.height);
    _progressLayer.hidden = YES;
    [self.layer addSublayer:_progressLayer];
    self.backgroundColor = [UIColor clearColor];
    _historyLayers = [NSMutableArray array];
    _historyTime = 0.0;
    return self;
}

- (void)start {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (self.historyLayers.count) {
        self.historyLayers.lastObject.backgroundColor = [UIColor orangeColor].CGColor;
        _progressLayer.frame = CGRectMake(CGRectGetMaxX(self.historyLayers.lastObject.frame) + 1, 0, 0, self.frame.size.height);
    }
    else _progressLayer.frame = CGRectMake(0, 0, 0, self.frame.size.height);
    _progressLayer.hidden = NO;
    [CATransaction commit];
    _currentTime = 0.0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(timeLapse) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stop {
    [_timer invalidate];
    _timer = nil;
    _progressLayer.hidden = YES;
    
    _historyTime += _currentTime;
    JKRCameraProgressHistoryLayer *layer = [[JKRCameraProgressHistoryLayer alloc] init];
    layer.time = _currentTime;
    //    layer.frame = CGRectMake(_progressLayer.frame.origin.x, _progressLayer.frame.origin.y, (_progressLayer.frame.size.width - 1) < 1 ? 1 : _progressLayer.frame.size.width - 1, _progressLayer.frame.size.height);
    layer.frame = CGRectMake(_progressLayer.frame.origin.x, _progressLayer.frame.origin.y, _ifFull ? _progressLayer.frame.size.width : _progressLayer.frame.size.width - 1, _progressLayer.frame.size.height);
    layer.backgroundColor = [UIColor orangeColor].CGColor;
    [self.layer addSublayer:layer];
    [_historyLayers addObject:layer];
}

- (void)deleteClick {
    self.historyLayers.lastObject.backgroundColor = [UIColor redColor].CGColor;
}

- (void)deleteSure {
    _historyTime -= self.historyLayers.lastObject.time;
    [self.historyLayers.lastObject removeFromSuperlayer];
    [self.historyLayers removeLastObject];
}

- (void)timeLapse {
    _currentTime += 0.03;
    [self setNeedsDisplay];
    if (_currentTime + _historyTime >= _totalTime) {
        _ifFull = YES;
        [self.delegate cameraProgressViewDidFullTime];
    }
}

- (void)drawRect:(CGRect)rect {
    _progressLayer.frame = CGRectMake(_progressLayer.frame.origin.x, 0, self.frame.size.width * (_currentTime / _totalTime), self.frame.size.height);
}

- (void)reset {
    [_timer invalidate];
    _timer = nil;
    _progressLayer.hidden = YES;
    [self.historyLayers enumerateObjectsUsingBlock:^(JKRCameraProgressHistoryLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperlayer];
    }];
    [self.historyLayers removeAllObjects];
    _historyTime = 0.0;
    _currentTime = 0.0;
}

@end
