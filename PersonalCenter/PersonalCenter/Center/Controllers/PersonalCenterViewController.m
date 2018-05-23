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
#import "MyMessageViewController.h"

#define headimageHeight   240 //头部视图的高度

@interface PersonalCenterViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) CenterTouchTableView   * mainTableView;
@property (nonatomic, strong) CenterSegmentView      * segmentView;//分栏视图，头部视图下方区域
@property (nonatomic, strong) UIView                 * naviView;//自定义导航栏
@property (nonatomic, strong) UIImageView            * headImageView; //头部背景视图
@property (nonatomic, strong) UIView                 * headContentView;//头部内容视图，放置用户信息，如：姓名，昵称、座右铭等(作用：背景放大不会影响内容的位置)
@property (nonatomic, strong) UIImageView            * avatarImage;//头像
@property (nonatomic,   copy) UILabel                * nickNameLB;//昵称

@property (nonatomic, assign) BOOL canScroll;//mainTableView是否可以滚动
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabView;//到达顶部(临界点)不能移动mainTableView
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabViewPre;//到达顶部(临界点)不能移动子控制器的tableView

@end

@implementation PersonalCenterViewController
{
    NSInteger _naviBarHeight;//导航栏的高度+状态栏的高度
    BOOL _isRefresh;//控制下拉放大时刷新数据的次数，做到下拉放大值刷新一次，避免重复刷新
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    //接收宏定义的值，因为下面要做运算，这个宏含有三目运算不能直接拿来运算,会出错
    _naviBarHeight = NaviBarHeight;
    //如果使用自定义的按钮去替换系统默认返回按钮，会出现滑动返回手势失效的情况，解决方法如下：
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self setUI];
    [self requestData];
    //注册允许外层tableView滚动通知-解决和分页视图的上下滑动冲突问题
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"leaveTop" object:nil];
    //注册允许外层tableView滚动通知-解决子视图左右滑动和外层tableView上下滑动的冲突问题
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsgOfSubView:) name:@"isScroll" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -- 设置界面
- (void)setUI {
    self.title = @"个人中心";
    self.view.backgroundColor = [UIColor whiteColor];
    //添加tableView
    [self.view addSubview:self.mainTableView];
    
    //添加头部背景视图
    [_mainTableView addSubview:self.headImageView];
    
    //添加自定义导航栏
    [self.view addSubview:self.naviView];
    
    //添加头部内容视图
    [_headImageView addSubview:self.headContentView];
    [_headContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_headImageView).offset(0);
        make.centerX.mas_equalTo(_headImageView.mas_centerX);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(headimageHeight);
    }];
    //添加头像
    [_headContentView addSubview:self.avatarImage];
    [_avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_headContentView);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(80);
        make.bottom.mas_equalTo(-70);
    }];
    
    //添加昵称
    [_headImageView addSubview:self.nickNameLB];
    [_nickNameLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_headContentView);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(25);
        make.bottom.mas_equalTo(-40);
    }];
}

//请求数据
- (void)requestData {
    [MBProgressHUD showOnlyLoadToView:self.view];
    //模拟数据请求
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:2];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

//接收通知
- (void)acceptMsg:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSString *canScroll = userInfo[@"canScroll"];
    if ([canScroll isEqualToString:@"1"]) {
        _canScroll = YES;
    }
}

- (void)acceptMsgOfSubView:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSString *canScroll = userInfo[@"canScroll"];
    if ([canScroll isEqualToString:@"1"]) {
        _mainTableView.scrollEnabled = YES;
    }else if([canScroll isEqualToString:@"0"]) {
        _mainTableView.scrollEnabled = NO;
    }
}

/**
 * 处理联动
 * 因为要实现下拉头部放大的问题，tableView设置了contentInset，所以试图刚加载的时候会调用一遍这个方法，所以要做一些特殊处理，
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _mainTableView) {
        
        //当前偏移量
        CGFloat yOffset  = scrollView.contentOffset.y;
        //临界点偏移量(吸顶临界点)
        CGFloat tabyOffset = [_mainTableView rectForSection:0].origin.y - _naviBarHeight;
        
        //第一部分：
        //更改导航栏的背景图的透明度
        CGFloat alpha = 0;
        if (-yOffset <= _naviBarHeight) {
            alpha = 1;
        }else if(_naviBarHeight < -yOffset && -yOffset < headimageHeight){
            alpha = (headimageHeight + yOffset)/(headimageHeight-_naviBarHeight);
        }else {
            alpha = 0;
        }
        self.naviView.backgroundColor = kRGBA(255,126,15,alpha);
        
        //第二部分：
        //利用contentOffset处理内外层scrollView的滑动冲突问题
        if (yOffset >= tabyOffset) {
            //当分页视图滑动至导航栏时，禁止外层tableView滑动
            scrollView.contentOffset = CGPointMake(0, tabyOffset);
            _isTopIsCanNotMoveTabView = YES;
        }else{
            //当分页视图和顶部导航栏分离时，允许外层tableView滑动
            _isTopIsCanNotMoveTabView = NO;
        }
        
        //取反
        _isTopIsCanNotMoveTabViewPre = !_isTopIsCanNotMoveTabView;
        
        if (!_isTopIsCanNotMoveTabViewPre) {
            NSLog(@"分页选择部分滑动到顶端");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"goTop" object:nil userInfo:@{@"canScroll":@"1"}];
            _canScroll = NO;
        }else {
            NSLog(@"页面滑动到底部后开始下拉");
            if (!_canScroll) {
                NSLog(@"分页选择部分保持在顶端");
                _mainTableView.contentOffset = CGPointMake(0, tabyOffset);
            }
        }
        
        //第三部分：
        /**
         * 处理头部自定义背景视图 (如: 下拉放大)
         * 图片会被拉伸多出状态栏的高度
         */
        if(yOffset <= -headimageHeight) {
            if (_isEnlarge) {
                CGRect f = self.headImageView.frame;
                //改变HeadImageView的frame
                //上下放大
                f.origin.y = yOffset;
                f.size.height =  -yOffset;
                //左右放大
                f.origin.x = (yOffset*kScreenWidth/headimageHeight+kScreenWidth)/2;
                f.size.width = -yOffset*kScreenWidth/headimageHeight;
                //改变头部视图的frame
                self.headImageView.frame = f;
                //刷新数据，保证刷新一次
                if (yOffset ==  - headimageHeight) {
                    _isRefresh = YES;
                }
                if (yOffset < -headimageHeight - 30 && _isRefresh) {
                    [self requestData];
                    _isRefresh = NO;
                }
            }else{
                scrollView.bounces = NO;
                if (yOffset == -headimageHeight) {
                    //刷新数据
                    [self requestData];
                }
            }
            //刷新数据
            if (_isRefreshOfdownPull) {
                [self requestData];
            }
        }else {
            scrollView.bounces = YES;
        }
    }
}

#pragma mark - 返回上一界面
- (void)backAction {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 查看消息
- (void)checkMessage {
    NSLog(@"查看消息");
    MyMessageViewController *myMessageVC = [[MyMessageViewController alloc]init];
    [self.navigationController pushViewController:myMessageVC animated:YES];
}

#pragma mark - tableDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kScreenHeight-_naviBarHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //添加segementView
    [cell.contentView addSubview:self.setPageViewControllers];
    return cell;
}

#pragma mark - 懒加载
- (UIView *)naviView {
    if (!_naviView) {
        _naviView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth,_naviBarHeight)];
        _naviView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];//该透明色设置不会影响子视图
        //添加返回按钮
        UIButton *backButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [backButton setImage:[UIImage imageNamed:@"back"] forState:(UIControlStateNormal)];
        backButton.frame = CGRectMake(5, 28 + _naviBarHeight - 64, 28, 25);
        backButton.adjustsImageWhenHighlighted = NO;
        [backButton addTarget:self action:@selector(backAction) forControlEvents:(UIControlEventTouchUpInside)];
        [_naviView addSubview:backButton];
        //添加消息按钮
        UIButton *messageButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [messageButton setImage:[UIImage imageNamed:@"message"] forState:(UIControlStateNormal)];
        messageButton.frame = CGRectMake(kScreenWidth-35, 28 + _naviBarHeight - 64, 25, 25);
        messageButton.adjustsImageWhenHighlighted = NO;
        [messageButton addTarget:self action:@selector(checkMessage) forControlEvents:(UIControlEventTouchUpInside)];
        [_naviView addSubview:messageButton];
    }
    return _naviView;
}

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        //⚠️这里的属性初始化一定要放在mainTableView.contentInset的设置滚动之前, 不然首次进来视图就会偏移到临界位置，contentInset会调用scrollViewDidScroll这个方法。
        //初始化变量
        _canScroll = YES;
        _isTopIsCanNotMoveTabView = NO;
        
        _mainTableView = [[CenterTouchTableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.showsVerticalScrollIndicator = NO;
        //注意：这里不能使用动态高度_headimageHeight, 不然tableView会往下移，在iphone X下，头部不放大的时候，上方依然会有白色空白
        _mainTableView.contentInset = UIEdgeInsetsMake(headimageHeight, 0, 0, 0);//内容视图开始正常显示的坐标为(0,_headimageHeight)
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
        _avatarImage.image = [UIImage imageNamed:@"center_avatar.jpeg"];
        _avatarImage.userInteractionEnabled = YES;
        _avatarImage.layer.masksToBounds = YES;
        _avatarImage.layer.borderWidth = 1;
        _avatarImage.layer.borderColor = kRGBA(255, 253, 253, 1.).CGColor;
        _avatarImage.layer.cornerRadius = 40;
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
        _nickNameLB.text = @"撒哈拉下雪了";
    }
    return _nickNameLB;
}

- (UIImageView *)headImageView {
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"center_bg.jpg"]];
        _headImageView.backgroundColor = [UIColor greenColor];
        _headImageView.userInteractionEnabled = YES;
        _headImageView.frame = CGRectMake(0, -headimageHeight, kScreenWidth, headimageHeight);
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
        FirstViewController   * firstVC  = [[FirstViewController alloc]init];
        SecondViewController  * secondVC = [[SecondViewController alloc]init];
        ThirdViewController   * thirdVC  = [[ThirdViewController alloc]init];
        SecondViewController  * fourthVC = [[SecondViewController alloc]init];
        NSArray *controllers = @[firstVC,secondVC,thirdVC,fourthVC];
        NSArray *titleArray  = @[@"普吉岛",@"夏威夷",@"洛杉矶",@"新泽西"];
        CenterSegmentView *segmentView = [[CenterSegmentView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight -_naviBarHeight) controllers:controllers titleArray:(NSArray *)titleArray ParentController:self selectBtnIndex:(NSInteger)index lineWidth:kScreenWidth/5 lineHeight:3];
        _segmentView = segmentView;
    }
    return _segmentView;
}

@end

