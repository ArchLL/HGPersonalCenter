//
//  HGHomeViewController.m
//  HGPersonalCenter
//
//  Created by Arch on 2017/6/16.
//  Copyright © 2017年 mint_bin. All rights reserved.
//

#import "HGHomeViewController.h"
#import "HGPersonalCenterViewController.h"

@interface HGHomeViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *enlargeSwitch;
@end

@implementation HGHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gk_navTitle = @"主页";
}

// 进入个人中心
- (IBAction)enterCenterAction:(UIButton *)sender {
    HGPersonalCenterViewController *vc = [[HGPersonalCenterViewController alloc] init];
    vc.isEnlarge = self.enlargeSwitch.on;
    vc.selectedIndex = 0;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
