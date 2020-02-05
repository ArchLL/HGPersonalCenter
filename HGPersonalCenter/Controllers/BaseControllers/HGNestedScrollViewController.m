//
//  HGNestedScrollViewController.m
//  HGPersonalCenterExtend
//
//  Created by Arch on 2020/1/16.
//  Copyright © 2020 mint_bin@163.com. All rights reserved.
//

#import "HGNestedScrollViewController.h"

@interface HGNestedScrollViewController () <HGSegmentedPageViewControllerDelegate>
@property (nonatomic, strong) HGCenterBaseTableView *tableView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) HGSegmentedPageViewController *segmentedPageViewController;
@property (nonatomic) BOOL cannotScroll;
@end

@implementation HGNestedScrollViewController
@synthesize headerView = _headerView;

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    // 解决pop手势中断后tableView偏移问题
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self setupSubViews];
}

#pragma mark - Private Methods
- (void)setupSubViews {
    [self.tableView addSubview:self.headerImageView];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self addChildViewController:self.segmentedPageViewController];
    [self.footerView addSubview:self.segmentedPageViewController.view];
    [self.segmentedPageViewController didMoveToParentViewController:self];
    [self.segmentedPageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.footerView);
    }];
}

- (void)changeNavigationBarAlpha {
    CGFloat alpha = 0;
    CGFloat currentOffsetY = self.tableView.contentOffset.y;
    if (-currentOffsetY - HGDeviceHelper.topBarHeight <= FLT_EPSILON) {
        alpha = 1;
    } else if (self.headerImageView.initialHeight > HGDeviceHelper.topBarHeight) {
        alpha = (self.headerImageView.initialHeight + currentOffsetY) / (self.headerImageView.initialHeight - HGDeviceHelper.topBarHeight);
    }
    self.gk_navBarAlpha = alpha;
}

#pragma mark - UIScrollViewDelegate
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    [self.segmentedPageViewController makePageViewControllersScrollToTop];
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 第一部分：处理导航栏
    [self changeNavigationBarAlpha];
    
    // 第二部分：处理手势冲突
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    // 吸顶临界点(此时的临界点不是视觉感官上导航栏的底部，而是当前屏幕的顶部相对scrollViewContentView的位置)
    CGFloat criticalPointOffsetY = [self.tableView rectForSection:0].origin.y - HGDeviceHelper.topBarHeight;
    
    // 利用contentOffset处理内外层scrollView的滑动冲突问题
    if (contentOffsetY >= criticalPointOffsetY) {
        /*
         * 到达临界点：
         * 1.未吸顶状态 -> 吸顶状态
         * 2.维持吸顶状态(pageViewController.scrollView.contentOffsetY > 0)
         */
        self.cannotScroll = YES;
        scrollView.contentOffset = CGPointMake(0, criticalPointOffsetY);
        [self.segmentedPageViewController makePageViewControllersScrollState:YES];
    } else {
        /*
         * 未达到临界点：
         * 1.吸顶状态 -> 不吸顶状态
         * 2.维持吸顶状态(pageViewController.scrollView.contentOffsetY > 0)
         */
        if (self.cannotScroll) {
            // “维持吸顶状态”
            scrollView.contentOffset = CGPointMake(0, criticalPointOffsetY);
        } else {
            // 吸顶状态 -> 不吸顶状态
            [self.segmentedPageViewController makePageViewControllersScrollToTop];
        }
    }
    
    // 第三部分：
    /**
     * 处理头部自定义背景视图 (如: 下拉放大)
     * 图片会被拉伸多出状态栏的高度
     */
    if (contentOffsetY <= -self.headerImageView.initialHeight) {
        if (self.isEnlarge) {
            CGRect frame = self.headerImageView.frame;
            // 改变HeadImageView的frame
            // 上下放大
            frame.origin.y = contentOffsetY;
            frame.size.height = -contentOffsetY;
            // 左右放大
            frame.origin.x = (contentOffsetY * SCREEN_WIDTH / self.headerImageView.initialHeight + SCREEN_WIDTH) / 2;
            frame.size.width = -contentOffsetY * SCREEN_WIDTH / self.headerImageView.initialHeight;
            // 改变头部视图的frame
            self.headerImageView.frame = frame;
        } else{
            scrollView.bounces = NO;
        }
    } else {
        scrollView.bounces = YES;
    }
}

#pragma mark - HGSegmentedPageViewControllerDelegate
- (void)segmentedPageViewControllerLeaveTop {
    self.cannotScroll = NO;
}

- (void)segmentedPageViewControllerWillBeginDragging {
    self.tableView.scrollEnabled = NO;
}

- (void)segmentedPageViewControllerDidEndDragging {
    self.tableView.scrollEnabled = YES;
}

#pragma mark - Getters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[HGCenterBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.tableHeaderView = self.headerView;
        _tableView.tableFooterView = self.footerView;
        _tableView.contentInset = UIEdgeInsetsMake(self.headerImageView.initialHeight, 0, 0, 0);
        [_tableView setContentOffset:CGPointMake(0, -self.headerImageView.initialHeight)];
    }
    return _tableView;
}

- (HGHeaderImageView *)headerImageView {
    if (!_headerImageView) {
        _headerImageView = [[HGHeaderImageView alloc] initWithFrame:CGRectMake(0, -240, SCREEN_WIDTH, 240)];
    }
    return _headerImageView;
}

- (UIView *)headerView {
    if (!_headerView) {
        // 这里的height不能设置为0，否则系统会给tableHeaderView设置一个默认的高度
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MIN)];
    }
    return _headerView;
}

- (UIView *)footerView {
    if (!_footerView) {
        // 如果当前控制器底部存在TabBar/ToolBar/自定义的bottomBar, 还需要减去barHeight和SAFE_AREA_INSERTS_BOTTOM的高度
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - HGDeviceHelper.topBarHeight)];
    }
    return _footerView;
}

- (HGSegmentedPageViewController *)segmentedPageViewController {
    if (!_segmentedPageViewController) {
        _segmentedPageViewController = [[HGSegmentedPageViewController alloc] init];
        _segmentedPageViewController.delegate = self;
    }
    return _segmentedPageViewController;
}

#pragma mark - Setters
- (void)setHeaderView:(UIView *)headerView {
    _headerView = headerView;
    self.tableView.tableHeaderView = headerView;
}

@end
