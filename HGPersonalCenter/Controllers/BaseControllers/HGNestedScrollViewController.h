//
//  HGNestedScrollViewController.h
//  HGPersonalCenterExtend
//
//  Created by Arch on 2020/1/16.
//  Copyright © 2020 mint_bin@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGPersonalCenterExtend.h"
#import "HGHeaderImageView.h"

@interface HGNestedScrollViewController : HGBaseViewController
@property (nonatomic, strong, readonly) HGCenterBaseTableView *tableView;
@property (nonatomic, strong) HGHeaderImageView *headerImageView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong, readonly) UIView *footerView;
@property (nonatomic, strong, readonly) HGSegmentedPageViewController *segmentedPageViewController;
@property (nonatomic, assign) BOOL isEnlarge;
@end
