//
//  JKRVideosManager.m
//  JKRAVCameraDemo
//
//  Created by tronsis_ios on 16/9/1.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import "JKRVideosManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation JKRVideo

@end

@implementation JKRVideosManager

+ (NSArray<JKRVideo *> *)videos {
    NSMutableArray<JKRVideo *> *videos = [NSMutableArray array];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *videosPath = kVideoPath;
    
    BOOL isDirectory = NO;
    if (![manager fileExistsAtPath:videosPath isDirectory:&isDirectory]) return videos;
    if (!isDirectory) return videos;
    NSEnumerator *enmumerator = [manager enumeratorAtPath:videosPath];
    for (NSString *subPath in enmumerator) {
        if (![subPath hasSuffix:@".MOV"]) continue;
        NSString *fullPath = [videosPath stringByAppendingPathComponent:subPath];
        NSLog(@"%@", fullPath);
        UIImage *image = getImageFromVideoPath(fullPath);
        JKRVideo *video = [JKRVideo new];
        video.path = fullPath;
        video.image = image;
        video.name = subPath;
        [videos addObject:video];
    }
    return videos;
}

static inline UIImage * getImageFromVideoPath(NSString *path) {
    UIImage *image;
    NSURL *url = [NSURL fileURLWithPath:path];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

@end
