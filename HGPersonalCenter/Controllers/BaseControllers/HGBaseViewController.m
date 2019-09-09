//
//  HGBaseViewController.m
//  HGPersonalCenter
//
//  Created by Arch on 2017/6/19.
//  Copyright © 2017年 mint_bin. All rights reserved.
//

#import "HGBaseViewController.h"

@interface HGBaseViewController ()
@property (nonatomic, strong) UIButton *backButton;
@end

@implementation HGBaseViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setBaseNavigationbar];
}

#pragma mark - Private Methods
- (void)setBaseNavigationbar {
    if (self.navigationController) {
        self.gk_navBackgroundColor = kRGBA(28, 162, 223, 1.0);
        self.gk_navTitleFont = [UIFont systemFontOfSize:18];
        self.gk_navTitleColor = [UIColor whiteColor];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
        self.gk_navItemLeftSpace = 8;
        self.gk_navItemRightSpace = 12;
        if (self.navigationController.childViewControllers.count > 1) {
            self.gk_navLeftBarButtonItem = backItem;
        }
    }
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Getters
- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _backButton.tintColor = [UIColor whiteColor];
        [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [_backButton sizeToFit];
    }
    return _backButton;
}

@end

