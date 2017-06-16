//
//  SegmentViewController.h
//  PersonalCenter
//
//  Created by 中资北方 on 2017/6/16.
//  Copyright © 2017年 mint_bin. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kScreenHeight   [[UIScreen mainScreen] bounds].size.height
#define kScreenWidth    [[UIScreen mainScreen] bounds].size.width
#define segmentMenuHeight 41 //分页菜单栏的高度

//此类为子控制器的父类
@interface SegmentViewController : UIViewController

@property(strong, nonatomic)UIScrollView *scrollView;
@property (nonatomic, assign) BOOL canScroll;  //是否可以滚动

@end
