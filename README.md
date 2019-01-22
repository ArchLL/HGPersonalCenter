# HGPersonalCenter

## Requirements

- iOS 8.0+ 
- Objective-C
- Xcode 9+

## Installation
我通过自己另一个支持`CocoaPods`的库快速集成 - [HGPersonalCenterExtend](https://github.com/ArchLL/HGPersonalCenter)


```ruby
platform :ios, '8.0'

target 'HGPersonalCenter' do

  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!
  pod 'HGPersonalCenterExtend', '~> 0.1.1'
  
end

```

## Blog 
[简书](https://www.jianshu.com/p/8b87837d9e3a)


## Show  

![image](https://github.com/ArchLL/HGPersonalCenter/blob/master/show.gif)


## Usage

例如你的CenterViewController是`HGPersonalCenterViewController`
```Objc
在 HGPersonalCenterViewController 下进行如下操作：

#import "HGSegmentedPageViewController.h"
#import "HGCenterBaseTableView.h"

@interface HGPersonalCenterViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, HGSegmentedPageViewControllerDelegate, HGPageViewControllerDelegate>
@property (nonatomic, strong) HGCenterBaseTableView *tableView;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) HGSegmentedPageViewController *segmentedPageViewController;
@property (nonatomic) BOOL cannotScroll;

@end

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;  
    [self.tableView addSubview:self.headerImageView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

//将segmentedPageViewController添加在cell上，你也可以用（https://github.com/ArchLL/HGPersonalCenter）中的做法添加在footerView上
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self addChildViewController:self.segmentedPageViewController];
    [cell.contentView addSubview:self.segmentedPageViewController.view];
    [self.segmentedPageViewController didMoveToParentViewController:self];
    [self.segmentedPageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(cell.contentView);
    }];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT;
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

#pragma mark - UIScrollViewDelegate
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    [self.segmentedPageViewController.currentPageViewController makePageViewControllerScrollToTop];
    return YES;
}

/**
 * 处理联动, demo中有详细注释
 * 因为要实现下拉头部放大的问题，tableView设置了contentInset，试图刚加载的时候会调用一遍这个方法，所以要做一些特殊处理
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //处理滑动冲突
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat criticalPointOffsetY = [self.tableView rectForSection:0].origin.y - NAVIGATION_BAR_HEIGHT;
    if (contentOffsetY >= criticalPointOffsetY) {
        self.cannotScroll = YES;
        scrollView.contentOffset = CGPointMake(0, criticalPointOffsetY);
        [self.segmentedPageViewController.currentPageViewController makePageViewControllerScroll:YES];
    } else {
        if (self.cannotScroll) {
            scrollView.contentOffset = CGPointMake(0, criticalPointOffsetY);
        }
    }
    
    //处理下拉放大
    if (contentOffsetY <= -HeaderImageViewHeight) {
        if (self.isEnlarge) {
            CGRect f = self.headerImageView.frame;
            f.origin.y = contentOffsetY;
            f.size.height = -contentOffsetY;
            f.origin.x = (contentOffsetY * SCREEN_WIDTH / HeaderImageViewHeight + SCREEN_WIDTH) / 2;
            f.size.width = -contentOffsetY * SCREEN_WIDTH / HeaderImageViewHeight;
            self.headerImageView.frame = f;
        } else {
            scrollView.bounces = NO;
        }
    }else {
        scrollView.bounces = YES;
    }
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
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[HGCenterBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.contentInset = UIEdgeInsetsMake(HeaderImageViewHeight, 0, 0, 0);
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (UIImageView *)headerImageView {
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -HeaderImageViewHeight, SCREEN_WIDTH, HeaderImageViewHeight)];
        _headerImageView.image = [UIImage imageNamed:@"center_bg.jpg"];
    }
    return _headerImageView;
}

/*设置segmentedPageViewController的categoryView以及pageViewControllers
 *这里可以对categoryView进行自定义，包括高度、背景颜色，字体颜色和大小等
 *这里用到的pageViewController需要继承自HGPageViewController
 */
- (HGSegmentedPageViewController *)segmentedPageViewController {
    if (!_segmentedPageViewController) {
        NSMutableArray *controllers = [NSMutableArray array];
        NSArray *titles = @[@"华盛顿", @"夏威夷", @"拉斯维加斯", @"纽约", @"西雅图", @"底特律", @"费城", @"旧金山", @"芝加哥"];
        for (int i = 0; i < titles.count; i ++) {
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
        _segmentedPageViewController.pageViewControllers = controllers.copy;
        _segmentedPageViewController.categoryView.titles = titles;
        _segmentedPageViewController.categoryView.originalIndex = self.selectedIndex;
        _segmentedPageViewController.delegate = self;
    }
    return _segmentedPageViewController;
}

```

⚠️ 如果你的pageViewController下的scrollView是UICollectionView类型，需要进行如下设置：
```Objc
//解决categoryView在吸顶状态下，且collectionView的显示内容不满屏时，出现竖直方向滑动失效的问题
_collectionView.alwaysBounceVertical = YES;
```


## Author

Arch, mint_bin@163.com

## License

HGPersonalCenterExtend is available under the MIT license. See the LICENSE file for more info.
