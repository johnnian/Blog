//
//  JKRMenuTableViewCell.m
//  JKRAVCameraDemo
//
//  Created by Lucky on 2016/10/22.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import "JKRMenuTableViewCell.h"

@interface JKRMenuTableViewCell ()

@property (nonatomic, strong) UIImageView *videoImageView;
@property (nonatomic, strong) UILabel *videoNameLabel;

@end

@implementation JKRMenuTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *const cellID = @"MENU_CELL";
    JKRMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) cell = [[JKRMenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _videoImageView = [UIImageView new];
    _videoImageView.contentMode = UIViewContentModeScaleAspectFill;
    _videoImageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth);
    _videoImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:_videoImageView];
    _videoNameLabel = [UILabel new];
    _videoNameLabel.frame = CGRectMake(10, kScreenWidth - 25, kScreenWidth - 20, 25);
    _videoNameLabel.font = [UIFont systemFontOfSize:23];
    _videoNameLabel.textColor = [UIColor redColor];
    [self.contentView addSubview:_videoNameLabel];
    return self;
}

- (void)setVideo:(JKRVideo *)video {
    _video = video;
    _videoImageView.image = video.image;
    _videoNameLabel.text = video.name;
}

@end
