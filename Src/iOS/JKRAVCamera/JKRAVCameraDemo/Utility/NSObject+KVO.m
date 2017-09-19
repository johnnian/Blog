//
//  NSObject+KVO.m
//  JKRAVCameraDemo
//
//  Created by tronsis_ios on 16/9/1.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import "NSObject+KVO.h"
#import <objc/runtime.h>

@implementation NSObject (KVO)

+ (void)load {
    [self switchMethod];
}

+ (void)switchMethod {
    SEL removeSel = @selector(removeObserver:forKeyPath:);
    SEL removeJKRSel = @selector(removeJKRObserver:forKeyPath:);
    Method systemMethod = class_getClassMethod([self class], removeSel);
    Method myMethod = class_getClassMethod([self class], removeJKRSel);
    method_exchangeImplementations(systemMethod, myMethod);
}

- (void)removeJKRObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    @try {
        [self removeJKRObserver:observer forKeyPath:keyPath];
    } @catch (NSException *exception) {
    } @finally {
    }
}

@end
