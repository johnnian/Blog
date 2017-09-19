//
//  ViewController.m
//  runtime02
//
//  Created by Lucky on 2016/12/29.
//  Copyright © 2016年 Lucky. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import <objc/message.h>
#import "NSObject+Model.h"

@interface ViewController ()

@end

@implementation ViewController

UIKIT_EXTERN NSString *const name;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@", name);

//int const a = 3;
//const int b = 3;
//    
//int *const p1;          // p1:只读 *p1:变量
//int const *p2;          // p2:变量 *p2:只读
//const int *p3;          // p3:变量 *p3:只读
//const int *const p4;    // p4:只读 *p4:只读
//int const *const p5;    // p5:只读 *p5:只读
    
    
    
   // id objc = ((NSObject *(*)(id, SEL))(void *)objc_msgSend)([NSObject class], @selector(alloc));
    //id objc = ((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSObject"), sel_registerName("alloc"));
   //id objc = objc_msgSend(objc_getClass("NSObject"), sel_registerName("alloc"));
   // id objc = objc_msgSend([NSObject class], @selector(alloc));
    
   // Person *p = objc_msgSend(objc_getClass("Person"), sel_registerName("alloc"));
   // p = objc_msgSend(p, sel_registerName("init"));
   // NSLog(@"%@", p);
   // objc_msgSend(p, sel_registerName("eat"));
   // objc_msgSend(p, sel_registerName("eat:food2:"), @"fash", @"meet");
    
//    UIImage *image = [UIImage imageNamed:@"123"];
//    
//    NSDictionary *dict = @{
//                           @"name":@"Joker",
//                           @"age":@12,
//                           @"isReg":@1,
//                           @"man":@{
//                                   @"name":@"Joker",
//                                   @"age":@12,
//                                   @"isReg":@1
//                                   }
//                           };
//    Person *p = [Person modelWithDictionary:dict];
//    NSLog(@"%@", p);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
