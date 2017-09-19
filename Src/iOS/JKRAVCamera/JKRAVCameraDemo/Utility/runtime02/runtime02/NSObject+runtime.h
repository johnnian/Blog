//
//  NSObject+runtime.h
//  runtime02
//
//  Created by Lucky on 2016/12/31.
//  Copyright © 2016年 Lucky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (runtime)

// @property在分类中只会生成get，set方法声明，不回生成实现，也不生成_name成员属性
@property NSString *name;

@end
