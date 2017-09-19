//
//  JKRVideosManager.h
//  JKRAVCameraDemo
//
//  Created by tronsis_ios on 16/9/1.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKRVideo : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) UIImage *image;

@end

@interface JKRVideosManager : NSObject

+ (NSArray<JKRVideo *> *) videos;

@end

