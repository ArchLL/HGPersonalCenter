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

@property (weak, nonatomic) IBOutlet UISwitch *iphoneXSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *enlargeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *refreshSwitch;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.iphoneXSwitch.on = [IS_IPHONEX integerValue] == 1 ? YES : NO;
}

//进入个人中心
- (IBAction)intoCenterAction:(UIButton *)sender {
    PersonalCenterViewController *personalCenterVC = [[PersonalCenterViewController alloc]init];
    personalCenterVC.isEnlarge = _enlargeSwitch.on;
    personalCenterVC.selectIndex = 0;
    [self.navigationController pushViewController:personalCenterVC animated:YES];
}

//开启iphone X适配
- (IBAction)fitIphoneXAction:(UISwitch *)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if (sender.on == YES ) {
            [userDefaults setObject:@"1" forKey:@"FitIphoneX"];
        }else {
            [userDefaults setObject:@"0" forKey:@"FitIphoneX"];
        }
}


@end
