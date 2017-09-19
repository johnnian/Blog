//
//  NSObject+runtime.m
//  runtime02
//
//  Created by Lucky on 2016/12/31.
//  Copyright © 2016年 Lucky. All rights reserved.
//

#import "NSObject+runtime.h"
#import <objc/message.h>

@implementation NSObject (runtime)

- (void)setName:(NSString *)name {
    objc_setAssociatedObject(self, @"name", name, OBJC_ASSOCIATION_COPY);
}

- (NSString *)name {
    return objc_getAssociatedObject(self, @"name");
}

@end
