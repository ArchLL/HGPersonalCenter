//
//  PersonalCenterViewController.m
//  PersonalCenter
//
//  Created by 中资北方 on 2017/6/16.
//  Copyright © 2017年 mint_bin. All rights reserved.
//

#import "PersonalCenterViewController.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "CenterSegmentView.h"
#import "CenterTouchTableView.h"
#import <Masonry.h>

#define kScreenHeight     [[UIScreen mainScreen] bounds].size.height
#define kScreenWidth      [[UIScreen mainScreen] bounds].size.width
#define kRGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define segmentMenuHeight 41  //分页菜单栏的高度
#define headViewHeight    180


@interface PersonalCenterViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) CenterTouchTableView  * mainTableView;
@property (nonatomic, strong) CenterSegmentView     * segmentView;
@property (nonatomic, strong) UIImageView           * headImageView;  //头部背景视图
@property (nonatomic, strong) UIView                * headContentView;//头部内容视图，放置用户信息，如：姓名，昵称、座右铭等(作用：背景放大不会影响内容的位置)
@property (nonatomic, strong) UIImageView           * avatarImage;    //头像
@property (nonatomic,   copy) UILabel               * nickNameLB;     //昵称

@property (nonatomic, assign) BOOL canScroll;
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabView;   //到达顶部不能移动mainTableView
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabViewPre;//到达顶部不能移动子控制器的tableView

@end

@implementation PersonalCenterViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self configureNavigation];
    [self setUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"leaveTop" object:nil];
}

//设置高斯模糊，以及自定义导航视图的隐藏和出现
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
}


#pragma mark -- 设置导航栏
- (void)configureNavigation {
    //设置导航栏的样式
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    //设置导航栏内容的颜色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //设置透明的背景图
    [self.navigationController.navigationBar setBackgroundImage:[self drawPngImageWithAlpha:0] forBarMetrics:(UIBarMetricsDefault)];
    //消除导航栏底部的黑线
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)setUI {
    [self.view addSubview:self.mainTableView];
    //头部背景视图
    [_mainTableView addSubview:self.headImageView];
  
    //头部内容视图
    [_headImageView addSubview:self.headContentView];
    [_headContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_headImageView).offset(0);
        make.centerX.mas_equalTo(_headImageView.mas_centerX);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(headViewHeight);
    }];

    //头像
    [_headContentView addSubview:self.avatarImage];
    [_avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_headContentView);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(80);
        make.bottom.mas_equalTo(-70);
    }];
    
    //昵称
    [_headImageView addSubview:self.nickNameLB];
    [_nickNameLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_headContentView);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(25);
        make.bottom.mas_equalTo(-40);
    }];
}

//接收通知
-(void)acceptMsg:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSString *canScroll = userInfo[@"canScroll"];
    if ([canScroll isEqualToString:@"1"]) {
        _canScroll = YES;
    }
}

/**
 * 处理联动
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    /**
     * 处理联动
     */
    //获取滚动视图y值的偏移量
    CGFloat yOffset  = scrollView.contentOffset.y;
    CGFloat tabyOffset = [_mainTableView rectForSection:0].origin.y-64;//外层tableView的偏移量
    
    _isTopIsCanNotMoveTabViewPre = _isTopIsCanNotMoveTabView;
    if (yOffset>=tabyOffset) {
        scrollView.contentOffset = CGPointMake(0, tabyOffset);
        _isTopIsCanNotMoveTabView = YES;
    }else{
        _isTopIsCanNotMoveTabView = NO;
    }
    
    //更改导航栏的背景图的透明度
    CGFloat newyOffset = -yOffset-64;
    CGFloat alpha = 0;
    if (newyOffset <= 0) {
        alpha = 1;
    }else{
        alpha = 0;
    }
    [self.navigationController.navigationBar setBackgroundImage:[self drawPngImageWithAlpha:alpha] forBarMetrics:(UIBarMetricsDefault)];
    
    if (_isTopIsCanNotMoveTabView != _isTopIsCanNotMoveTabViewPre) {
        if (!_isTopIsCanNotMoveTabViewPre && _isTopIsCanNotMoveTabView) {
            //NSLog(@"滑动到顶端");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"goTop" object:nil userInfo:@{@"canScroll":@"1"}];
            _canScroll = NO;
        }
        if(_isTopIsCanNotMoveTabViewPre && !_isTopIsCanNotMoveTabView){
            //NSLog(@"离开顶端");
            if (!_canScroll) {
                scrollView.contentOffset = CGPointMake(0, tabyOffset);
            }
        }
    }
    
    /**
     * 处理头部背景视图
     */
    if(yOffset < -headViewHeight) {
        CGRect f = self.headImageView.frame;
        //上下放大
        f.origin.y = yOffset ;
        f.size.height =  -yOffset;
        f.origin.y = yOffset;
        //左右放大
        f.origin.x = (yOffset*kScreenWidth/headViewHeight+kScreenWidth)/2;
        f.size.width = -yOffset*kScreenWidth/headViewHeight;
        //改变头部视图的frame
        self.headImageView.frame = f;
    }
    
}

#pragma marl - tableDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kScreenHeight-64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //添加segementView
    [cell.contentView addSubview:self.setPageViewControllers];
    return cell;
}

#pragma maek - 懒加载
- (UITableView *)mainTableView {
    if (!_mainTableView){
        _mainTableView= [[CenterTouchTableView alloc]initWithFrame:CGRectMake(0,0,kScreenWidth,kScreenHeight)];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.showsVerticalScrollIndicator = NO;
        _mainTableView.contentInset = UIEdgeInsetsMake(headViewHeight,0, 0, 0);
        _mainTableView.backgroundColor = [UIColor clearColor];
    }
    return _mainTableView;
}

- (UIView *)headContentView {
    if (!_headContentView) {
        _headContentView = [[UIView alloc]init];
        _headContentView.backgroundColor = [UIColor clearColor];
    }
    return _headContentView;
}

- (UIImageView *)avatarImage {
    if (!_avatarImage) {
        _avatarImage = [[UIImageView alloc] init];
        _avatarImage.userInteractionEnabled = YES;
        _avatarImage.layer.masksToBounds = YES;
        _avatarImage.layer.borderWidth = 1;
        _avatarImage.layer.borderColor =[[UIColor colorWithRed:255/255. green:253/255. blue:253/255. alpha:1.] CGColor];
        _avatarImage.layer.cornerRadius = 40;
        _avatarImage.image = [UIImage imageNamed:@"center_avatar.jpeg"];
    }
    return _avatarImage;
}

- (UILabel *)nickNameLB {
    if (!_nickNameLB) {
        _nickNameLB = [[UILabel alloc] init];
        _nickNameLB.font = [UIFont systemFontOfSize:16.];
        _nickNameLB.textColor = [UIColor whiteColor];
        _nickNameLB.textAlignment = NSTextAlignmentCenter;
        _nickNameLB.lineBreakMode = NSLineBreakByWordWrapping;
        _nickNameLB.numberOfLines = 0;
        _nickNameLB.text = @"我的名字叫Anna";
    }
    return _nickNameLB;
}

- (UIImageView *)headImageView
{
    if (!_headImageView)
    {
        _headImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"center_bg.jpg"]];
        _headImageView.backgroundColor = [UIColor greenColor];
        _headImageView.userInteractionEnabled = YES;
        _headImageView.frame = CGRectMake(0, 0,kScreenWidth,headViewHeight);
    }
    return _headImageView;
}


/*
 * 这里可以设置替换你喜欢的segmentView
 */
-(UIView *)setPageViewControllers
{
    if (!_segmentView) {
        //设置子控制器
        FirstViewController  * firstVC = [[FirstViewController alloc]init];
        SecondViewController * secondVC = [[SecondViewController alloc]init];
        ThirdViewController  * thirdVC =[[ThirdViewController alloc]init];
        
        NSArray *controllers=@[firstVC,secondVC,thirdVC];
        NSArray *titleArray =@[@"普吉岛",@"夏威夷",@"洛杉矶"];
        CenterSegmentView *segmentView = [[CenterSegmentView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64) controllers:controllers titleArray:(NSArray *)titleArray ParentController:self selectBtnIndex:(NSInteger)index lineWidth:kScreenWidth/5 lineHeight:3];
        _segmentView = segmentView;
    }
    return _segmentView;
}

#pragma mark ---根据透明度绘制图片
- (UIImage *)drawPngImageWithAlpha:(CGFloat)alpha{
    //透明色(可设置初始颜色，当alpha=0时，为透明色)
    UIColor *color = kRGBA(255, 126, 15, alpha);
    //位图大小
    CGSize size = CGSizeMake(1, 1);
    //绘制位图
    UIGraphicsBeginImageContext(size);
    //获取当前创建的内容
    CGContextRef content = UIGraphicsGetCurrentContext();
    //充满指定的填充颜色
    CGContextSetFillColorWithColor(content, color.CGColor);
    //指定充满整个矩形
    CGContextFillRect(content, CGRectMake(0, 0, 1, 1));
    //绘制image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //结束绘制
    UIGraphicsEndImageContext();
    return image;
}




@end
