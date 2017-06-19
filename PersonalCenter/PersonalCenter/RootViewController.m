//
//  RootViewController.m
//  PersonalCenter
//
//  Created by 中资北方 on 2017/6/16.
//  Copyright © 2017年 mint_bin. All rights reserved.
//

#import "RootViewController.h"
#import "PersonalCenterViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
}

//进入个人中心
- (IBAction)intoCenterAction:(UIButton *)sender {
    PersonalCenterViewController *personalCenterVC = [[PersonalCenterViewController alloc]init];
    [self.navigationController pushViewController:personalCenterVC animated:YES];
}

@end
