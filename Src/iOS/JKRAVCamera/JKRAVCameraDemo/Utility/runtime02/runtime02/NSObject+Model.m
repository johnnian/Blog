
//
//  NSObject+Model.m
//  runtime02
//
//  Created by Lucky on 2016/12/31.
//  Copyright © 2016年 Lucky. All rights reserved.
//

#import "NSObject+Model.h"
#import <objc/message.h>

@implementation NSObject (Model)

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    id objc = [[self alloc] init];
    
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList([self class], &count);
    for (unsigned int i = 0; i < count; i++) {
        Ivar ivar = ivarList[i];
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        NSString *key = [ivarName substringFromIndex:1];
        id value = dictionary[key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSString *typeName = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
            typeName = [typeName substringWithRange:NSMakeRange(2, typeName.length - 3)];
            if (![typeName hasPrefix:@"NS"]) {
                Class modelClass = NSClassFromString(typeName);
                value = [modelClass modelWithDictionary:value];
            }
        }
        
        if (value) {
            [objc setValue:value forKey:key];
        }
    }
    
    return objc;
}

@end
