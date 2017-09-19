//
//  Person.h
//  runtime02
//
//  Created by Lucky on 2016/12/29.
//  Copyright © 2016年 Lucky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) BOOL isReg;
@property (nonatomic, strong) Person *man;

//- (void)eat;

@end
