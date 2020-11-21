//
//  HGPersonalCenterViewController.m
//  HGPersonalCenter
//
//  Created by Arch on 2017/6/16.
//  Copyright © 2017年 mint_bin. All rights reserved.
//

#import "HGPersonalCenterViewController.h"
#import "HGFirstViewController.h"
#import "HGSecondViewController.h"
#import "HGThirdViewController.h"
#import "HGCenterBaseTableView.h"
#import "HGHeaderImageView.h"
#import "HGMessageViewController.h"

@interface HGPersonalCenterViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIButton *messageButton;
@end

@implementation HGPersonalCenterViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    [self setupTableView];
    // 可以在请求数据成功后设置/改变pageViewControllers, 但是要保证titles.count=pageViewControllers.count
    [self setupPageViewControllers];
}

#pragma mark - Private Methods
- (void)setupNavigationBar {
    self.gk_navBarAlpha = 0;
    UIBarButtonItem *messageItem = [[UIBarButtonItem alloc] initWithCustomView:self.messageButton];
    self.gk_navRightBarButtonItem = messageItem;
}

- (void)setupTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
}

#pragma mark - Private Methods
- (void)setupPageViewControllers {
    NSMutableArray *controllers = [NSMutableArray array];
    NSArray *titles = @[@"主页", @"动态", @"关注", @"粉丝"];
    for (int i = 0; i < titles.count; i++) {
        HGPageViewController *controller;
        if (i % 3 == 0) {
            controller = [[HGThirdViewController alloc] init];
        } else if (i % 2 == 0) {
            controller = [[HGSecondViewController alloc] init];
        } else {
            controller = [[HGFirstViewController alloc] init];
        }
        [controllers addObject:controller];
    }
    self.segmentedPageViewController.pageViewControllers = controllers;
    self.segmentedPageViewController.categoryView.titles = titles;
    self.segmentedPageViewController.categoryView.alignment = HGCategoryViewAlignmentLeft;
    self.segmentedPageViewController.categoryView.originalIndex = self.selectedIndex;
    self.segmentedPageViewController.categoryView.itemSpacing = 25;
    self.segmentedPageViewController.categoryView.backgroundColor = [UIColor yellowColor];
    self.segmentedPageViewController.categoryView.isEqualParts = YES;
}

- (void)viewMessage {
    HGMessageViewController *vc = [[HGMessageViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UITableViewCell new];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CGFLOAT_MIN;
}

// 解决tableView在group类型下tableView头部和底部多余空白的问题
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

#pragma mark - Getters
- (UIButton *)messageButton {
    if (!_messageButton) {
        _messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_messageButton setTitle:@"消息" forState:UIControlStateNormal];
        [_messageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _messageButton.titleLabel.font = [UIFont systemFontOfSize:17];
        _messageButton.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12);
        [_messageButton addTarget:self action:@selector(viewMessage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _messageButton;
}

@end

