//
//  Person.m
//  runtime02
//
//  Created by Lucky on 2016/12/29.
//  Copyright © 2016年 Lucky. All rights reserved.
//

#import "Person.h"
#import <objc/message.h>

@implementation Person

NSString *const name = @"123";

- (void)eat {
    NSLog(@"person eat");
}

- (void)eat:(NSString *)food food2:(NSString *)food2{
    NSLog(@"person eat some %@ and some %@", food, food2);
}

// 任何方法默认都有两个隐式参数，self和_cmd
void aaa(id self, SEL _cmd, NSString *str) {
    NSLog(@"===> eat some %@!!!!", str);
}

// 处理实例方法
// 只要一个对象调用一个未实现的方法就回调用这个方法进行处理
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSLog(@"%@", NSStringFromSelector(sel));
    
    if (sel == NSSelectorFromString(@"eat")) {
        // 参数1:给哪个对象添加方法
        // 参数2:添加哪个方法
        // 参数3:方法实现，函数入口＝>函数名
        // 参数4:type：方法类型 void id SEL
        class_addMethod(self, sel, (IMP)aaa, "v@:@");
        return YES;
    }
    
    return [super resolveInstanceMethod:sel];
}

@end
