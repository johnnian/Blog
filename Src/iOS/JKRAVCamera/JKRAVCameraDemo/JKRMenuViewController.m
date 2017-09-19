//
//  JKRMenuViewController.m
//  JKRAVCameraDemo
//
//  Created by tronsis_ios on 16/9/1.
//  Copyright © 2016年 tronsis_ios. All rights reserved.
//

#import "JKRMenuViewController.h"
#import "JKRVideosManager.h"
#import "NSString+FileSize.h"
#import "JKREditViewController.h"
#import "JKRMenuTableViewCell.h"

@interface JKRMenuViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<JKRVideo *> *videos;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *clearButton;

@end

@implementation JKRMenuViewController

static NSString *const identifier = @"VIDEO_LIST_CELL_IDENTIFIER";

- (instancetype)init {
    self = [super init];
    _tableView = [UITableView new];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _videos = [NSMutableArray array];
    _statusLabel = [UILabel new];
    _backButton = [UIButton new];
    _clearButton = [UIButton new];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect frame = self.view.bounds;
    frame.size.height -= 45;
    _tableView.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 65);
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    [self.view addSubview:_tableView];
    
    _statusLabel.frame = CGRectMake(0, frame.size.height, frame.size.width - 100, 45);
    _statusLabel.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:_statusLabel];
    
    _backButton.frame = CGRectMake(CGRectGetMaxX(_statusLabel.frame), frame.size.height, 100, 45);
    _backButton.backgroundColor = [UIColor blueColor];
    [_backButton setTitle:@"返回" forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
    
    _clearButton.frame = CGRectMake(_backButton.frame.origin.x - 100, frame.size.height, 100, 45);
    _clearButton.backgroundColor = [UIColor redColor];
    [_clearButton setTitle:@"清空" forState:UIControlStateNormal];
    [_clearButton addTarget:self action:@selector(clearClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_clearButton];
    
    [self loadVideosComplted:^(NSArray<JKRVideo *> *videos) {
        [_videos removeAllObjects];
        [_videos addObjectsFromArray:videos];
        [_tableView reloadData];
    }];
}

- (void)loadVideosComplted:(void(^)(NSArray<JKRVideo *> *videos))complted {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.frame = CGRectMake((self.view.frame.size.width - 80) * 0.5, (self.view.frame.size.height - 80) * 0.5, 80, 80);
    indicator.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.6];
    indicator.layer.cornerRadius = 6;
    indicator.clipsToBounds = YES;
    [indicator startAnimating];
    [self.view addSubview:indicator];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray<JKRVideo *> *videos = [JKRVideosManager videos];
        NSAttributedString *statusText = [self statusText];
        dispatch_async(dispatch_get_main_queue(), ^{
            _statusLabel.attributedText = statusText;
            [indicator removeFromSuperview];
            complted(videos);
        });
    });
}

- (void)backClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clearClick:(UIButton *)sender {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *cachePath = kVideoPath;
    [manager removeItemAtPath:cachePath error:nil];
    
    BOOL isDirectory = NO;
    if ([manager fileExistsAtPath:cachePath isDirectory:&isDirectory]) {
        NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:cachePath];
        for (NSString *subPath in enumerator) {
            NSString *fullPath = [cachePath stringByAppendingPathComponent:subPath];
            NSDictionary *attrs = [manager attributesOfItemAtPath:fullPath error:nil];
            
            if ([attrs[NSFileType] isEqualToString:NSFileTypeDirectory]) continue;
            [manager removeItemAtPath:fullPath error:nil];
        }
    }
    [self loadVideosComplted:^(NSArray<JKRVideo *> *videos) {
        [_videos removeAllObjects];
        [_videos addObjectsFromArray:videos];
        [_tableView reloadData];
    }];
}

- (NSAttributedString *)statusText {
    NSString *fileSize = kVideoPath.fileSizeString;

    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    
    NSAttributedString *sizeStr = [[NSAttributedString alloc] initWithString:fileSize attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20], NSForegroundColorAttributeName: [UIColor orangeColor]}];
    NSAttributedString *headerStr = [[NSAttributedString alloc] initWithString:@"缓存文件：" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18], NSForegroundColorAttributeName: [UIColor greenColor]}];
    [text appendAttributedString:headerStr];
    [text appendAttributedString:sizeStr];
    return text;
}

#pragma mark - tableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kScreenWidth + 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _videos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JKRMenuTableViewCell *cell = [JKRMenuTableViewCell cellWithTableView:tableView];
    cell.video = _videos[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JKREditViewController *controller = [[JKREditViewController alloc] init];
    controller.video = self.videos[indexPath.row];
    [self presentViewController:controller animated:YES completion:nil];
}

@end
