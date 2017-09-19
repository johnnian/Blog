//
//  NSString+FileSize.m
//  JKRCameraDemo
//
//  Created by tronsis_ios on 16/8/31.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import "NSString+FileSize.h"
#import <UIKit/UIKit.h>

@implementation NSString (FileSize)

- (NSInteger)fileSize
{
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL exist = [manager fileExistsAtPath:self isDirectory:&isDirectory];
    if (exist== NO) return 0;
    if (isDirectory) {  //是文件夹
        NSInteger size = 0;
        NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:self];
        for (NSString *subPath in enumerator) {
            NSString *fullPath = [self stringByAppendingPathComponent:subPath];
            NSDictionary *attrs = [manager attributesOfItemAtPath:fullPath error:nil];
            if ([attrs[NSFileType] isEqualToString:NSFileTypeDirectory]) continue;
            size += [attrs[NSFileSize] integerValue];
        }
        return size;
    }
    return [[manager attributesOfItemAtPath:self error:nil][NSFileSize] integerValue];
}

- (NSString *)fileSizeString
{
    NSInteger fileSize = self.fileSize;
    CGFloat unit = 1000.0;
    if (fileSize >= unit *unit * unit) {
        return  [NSString stringWithFormat:@"%.1fGB",fileSize/(unit * unit * unit)];
    }else if (fileSize >= unit * unit)
    {
        return  [NSString stringWithFormat:@"%.1fMB",fileSize/(unit * unit)];
    }
    else if (fileSize >=unit)
    {
        return [NSString stringWithFormat:@"%.1fKB",fileSize/unit];
    }
    else return [NSString stringWithFormat:@"%zdB",fileSize];
}

@end
