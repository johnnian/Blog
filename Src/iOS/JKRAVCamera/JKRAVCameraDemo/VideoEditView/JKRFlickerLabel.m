//
//  JKRFlickerLabel.m
//  JKRAVCameraDemo
//
//  Created by tronsis_ios on 16/9/9.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import "JKRFlickerLabel.h"

@interface JKRFlickerLabel ()

@property (nonatomic, strong) NSMutableAttributedString *attributedString;
@property (nonatomic, strong) NSMutableArray *characterAnimationDurations;
@property (nonatomic, strong) NSMutableArray *characterAnimationDelays;
@property (nonatomic, strong) CADisplayLink *displaylink;
@property (nonatomic, assign) CFTimeInterval beginTime;
@property (nonatomic, assign) CFTimeInterval endTime;
@property (nonatomic, assign, getter=isFadedOut) BOOL fadedOut;
@property (nonatomic, copy) void(^completion)();

@end

@implementation JKRFlickerLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self _init];
    return self;
}

- (void)_init {
    _shineDuration = 2.5;
    _fadeoutDuration = 2.5;
    _autoStart = NO;
    _fadedOut = YES;
    self.textColor = [UIColor whiteColor];
    
    _characterAnimationDurations = [NSMutableArray array];
    _characterAnimationDelays = [NSMutableArray array];
    
    _displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateAttributedString)];
    _displaylink.paused = YES;
    [_displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (BOOL)isShining {
    return !self.displaylink.isPaused;
}

- (BOOL)isVisible {
    return !self.isFadedOut;
}

- (void)shine {
    [self shineWithCompletion:NULL];
}

- (void)shineWithCompletion:(void (^)())completion {
    if (!self.isShining && self.isFadedOut) {
        self.completion = completion;
        self.fadedOut = NO;
        [self startAnimationWithDuration:self.shineDuration];
    }
}

- (void)fadeOut {
    [self fadeOutWithCompletion:NULL];
}

- (void)fadeOutWithCompletion:(void (^)())completion {
    if (!self.isShining && !self.isFadedOut) {
        self.completion = completion;
        self.fadedOut = YES;
        [self startAnimationWithDuration:self.fadeoutDuration];
    }
}

- (void)startAnimationWithDuration:(CFTimeInterval)duration {
    self.beginTime = CACurrentMediaTime();
    self.endTime = self.beginTime + self.shineDuration;
    self.displaylink.paused = NO;
}

- (void)didMoveToWindow {
    if (self.window && self.autoStart) {
        [self shine];
    }
}

- (void)setText:(NSString *)text {
    self.attributedText = [[NSAttributedString alloc] initWithString:text];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    self.attributedText = [self initialAttributedStringFromAttributedString:attributedText];
    [super setAttributedText:self.attributedText];
    for (NSUInteger i = 0; i < attributedText.length; i++) {
        self.characterAnimationDelays[i] = @(arc4random_uniform(self.shineDuration / 2 * 100) / 100.0);
        CGFloat remain = self.shineDuration - [self.characterAnimationDelays[i] floatValue];
        self.characterAnimationDurations[i] = @(arc4random_uniform(remain * 100) / 100.0);
    }
}

- (NSMutableAttributedString *)initialAttributedStringFromAttributedString:(NSAttributedString *)attributedString {
    NSMutableAttributedString *mutableAttributedString = [attributedString mutableCopy];
    UIColor *color = [self.textColor colorWithAlphaComponent:0];
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, mutableAttributedString.length)];
    return mutableAttributedString;
}

- (void)updateAttributedString {
    CFTimeInterval now = CACurrentMediaTime();
    for (NSUInteger i = 0; i < self.attributedString.length; i++) {
        if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[self.attributedString.string characterAtIndex:i]]) {
            continue;
        }
        [self.attributedString enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(i, 1) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            CGFloat currentAlpha = CGColorGetAlpha([(UIColor *)value CGColor]);
            BOOL shouldUpdateAlpha = (self.isFadedOut && currentAlpha > 0) || (!self.isFadedOut && currentAlpha < 1) || (now - self.beginTime) >= [self.characterAnimationDelays[i] floatValue];
            if (!shouldUpdateAlpha) return;
            CGFloat percentage = (now - self.beginTime - [self.characterAnimationDelays[i] floatValue]) / ([self.characterAnimationDurations[i] floatValue]);
            if (self.isFadedOut) percentage = 1 - percentage;
            UIColor *color = [self.textColor colorWithAlphaComponent:percentage];
            [self.attributedString addAttribute:NSForegroundColorAttributeName value:color range:range];
        }];
    }
    [super setAttributedText:self.attributedString];
    if (now > self.endTime) {
        self.displaylink.paused = YES;
        if (self.completion) self.completion();
    }
}

@end
