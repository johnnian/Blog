//
//  NSString+FileSize.h
//  JKRCameraDemo
//
//  Created by tronsis_ios on 16/8/31.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FileSize)

- (NSInteger)fileSize;        ///< 计算文件大小

- (NSString *)fileSizeString; ///< 将获取的文件的小转换成GB,MB,等形式:如1.2GB

@end
