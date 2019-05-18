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
#import "HGPersonalCenterExtend.h"

@interface HGPersonalCenterViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, HGSegmentedPageViewControllerDelegate, HGPageViewControllerDelegate>
@property (nonatomic, strong) UIButton *messageButton;
@property (nonatomic, strong) HGCenterBaseTableView *tableView;
@property (nonatomic, strong) HGHeaderImageView *headerImageView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) HGSegmentedPageViewController *segmentedPageViewController;
@property (nonatomic) BOOL cannotScroll;

@end

@implementation HGPersonalCenterViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self setupNavigationBar];
    [self setupSubViews];
}

#pragma mark - Private Methods
- (void)setupNavigationBar {
    self.gk_navBarAlpha = 0;
    UIBarButtonItem *messageItem = [[UIBarButtonItem alloc] initWithCustomView:self.messageButton];
    self.gk_navRightBarButtonItem = messageItem;
}

- (void)setupSubViews {
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.headerImageView];
    [self addChildViewController:self.segmentedPageViewController];
    [self.footerView addSubview:self.segmentedPageViewController.view];
    [self.segmentedPageViewController didMoveToParentViewController:self];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.segmentedPageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.footerView);
    }];
}

- (void)changeNavigationBarAlpha {
    CGFloat alpha = 0;
    CGFloat currentOffsetY = self.tableView.contentOffset.y;
    if (-currentOffsetY <= TOP_BAR_HEIGHT) {
        alpha = 1;
    } else if ((-currentOffsetY > TOP_BAR_HEIGHT) && -currentOffsetY < HeaderImageViewHeight) {
        alpha = (HeaderImageViewHeight + currentOffsetY) / (HeaderImageViewHeight - TOP_BAR_HEIGHT);
    } else {
        alpha = 0;
    }
    self.gk_navBarAlpha = alpha;
}

- (void)viewMessage {
    HGMessageViewController *vc = [[HGMessageViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    [self.segmentedPageViewController.currentPageViewController makePageViewControllerScrollToTop];
    return YES;
}

/**
 * 处理联动
 * 因为要实现下拉头部放大的问题，tableView设置了contentInset，所以试图刚加载的时候会调用一遍这个方法，所以要做一些特殊处理，
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //第一部分：处理导航栏
    [self changeNavigationBarAlpha];
    
    //第二部分：处理手势冲突
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    //吸顶临界点(此时的临界点不是视觉感官上导航栏的底部，而是当前屏幕的顶部相对scrollViewContentView的位置)
    CGFloat criticalPointOffsetY = [self.tableView rectForSection:0].origin.y - TOP_BAR_HEIGHT;
    
    //利用contentOffset处理内外层scrollView的滑动冲突问题
    if (contentOffsetY >= criticalPointOffsetY) {
        /*
         * 到达临界点：
         * 1.未吸顶状态 -> 吸顶状态
         * 2.维持吸顶状态(pageViewController.scrollView.contentOffsetY > 0)
         */
        //“进入吸顶状态”以及“维持吸顶状态”
        self.cannotScroll = YES;
        scrollView.contentOffset = CGPointMake(0, criticalPointOffsetY);
        [self.segmentedPageViewController.currentPageViewController makePageViewControllerScroll:YES];
    } else {
        /*
         * 未达到临界点：
         * 1.吸顶状态 -> 不吸顶状态
         * 2.维持吸顶状态(pageViewController.scrollView.contentOffsetY > 0)
         */
        if (self.cannotScroll) {
            //“维持吸顶状态”
            scrollView.contentOffset = CGPointMake(0, criticalPointOffsetY);
        } else {
            /* 吸顶状态 -> 不吸顶状态
             * pageViewController.scrollView.contentOffsetY <= 0时，会通过代理HGPageViewControllerDelegate来改变当前控制器self.cannotScroll的值；
             */
        }
    }
    
    //第三部分：
    /**
     * 处理头部自定义背景视图 (如: 下拉放大)
     * 图片会被拉伸多出状态栏的高度
     */
    if (contentOffsetY <= -HeaderImageViewHeight) {
        if (self.isEnlarge) {
            CGRect frame = self.headerImageView.frame;
            //改变HeadImageView的frame
            //上下放大
            frame.origin.y = contentOffsetY;
            frame.size.height = -contentOffsetY;
            //左右放大
            frame.origin.x = (contentOffsetY * SCREEN_WIDTH / HeaderImageViewHeight + SCREEN_WIDTH) / 2;
            frame.size.width = -contentOffsetY * SCREEN_WIDTH / HeaderImageViewHeight;
            //改变头部视图的frame
            self.headerImageView.frame = frame;
        } else{
            scrollView.bounces = NO;
        }
    } else {
        scrollView.bounces = YES;
    }
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

//解决tableView在group类型下tableView头部和底部多余空白的问题
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

#pragma mark - HGSegmentedPageViewControllerDelegate
- (void)segmentedPageViewControllerWillBeginDragging {
    self.tableView.scrollEnabled = NO;
}

- (void)segmentedPageViewControllerDidEndDragging {
    self.tableView.scrollEnabled = YES;
}

#pragma mark - HGPageViewControllerDelegate
- (void)pageViewControllerLeaveTop {
    self.cannotScroll = NO;
}

#pragma mark - Lazy
- (UIButton *)messageButton {
    if (!_messageButton) {
        _messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_messageButton setTitle:@"消息" forState:UIControlStateNormal];
        [_messageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _messageButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_messageButton addTarget:self action:@selector(viewMessage) forControlEvents:UIControlEventTouchUpInside];
        [_messageButton sizeToFit];
    }
    return _messageButton;
}

- (HGHeaderImageView *)headerImageView {
    if (!_headerImageView) {
        _headerImageView = [[HGHeaderImageView alloc] initWithFrame:CGRectMake(0, -HeaderImageViewHeight, SCREEN_WIDTH, HeaderImageViewHeight)];
    }
    return _headerImageView;
}

- (UIView *)footerView {
    if (!_footerView) {
        //如果当前控制器存在TabBar/ToolBar, 还需要减去TabBarHeight/ToolBarHeight和SAFE_AREA_INSERTS_BOTTOM
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - TOP_BAR_HEIGHT)];
    }
    return _footerView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[HGCenterBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = self.footerView;
        _tableView.contentInset = UIEdgeInsetsMake(HeaderImageViewHeight, 0, 0, 0);
        [_tableView setContentOffset:CGPointMake(0, -HeaderImageViewHeight)];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (HGSegmentedPageViewController *)segmentedPageViewController {
    if (!_segmentedPageViewController) {
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
            controller.delegate = self;
            [controllers addObject:controller];
        }
        _segmentedPageViewController = [[HGSegmentedPageViewController alloc] init];
        _segmentedPageViewController.pageViewControllers = controllers;
        _segmentedPageViewController.categoryView.titles = titles;
        _segmentedPageViewController.categoryView.alignment = HGCategoryViewAlignmentLeft;
        _segmentedPageViewController.categoryView.originalIndex = self.selectedIndex;
        _segmentedPageViewController.categoryView.itemSpacing = 25;
        _segmentedPageViewController.categoryView.backgroundColor = [UIColor yellowColor];
        _segmentedPageViewController.categoryView.isEqualParts = YES;
        _segmentedPageViewController.delegate = self;
    }
    return _segmentedPageViewController;
}

@end

