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
#import <Masonry.h>

#define segmentMenuHeight 41  //分页菜单栏的高度
#define headimageHeight    240   //头部视图的高度


@interface PersonalCenterViewController () <UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic, strong) CenterTouchTableView   * mainTableView;
@property (nonatomic, strong) CenterSegmentView       * segmentView;
@property (nonatomic, strong) UIView                          * naviView;//自定义导航栏
@property (nonatomic, strong) UIButton                       * backButton;//导航栏-返回按钮
@property (nonatomic, strong) UIButton                       * messageButton;//导航栏-消息按钮

@property (nonatomic, strong) UIImageView                 * headImageView; //头部背景视图
@property (nonatomic, strong) UIView                          * headContentView;//头部内容视图，放置用户信息，如：姓名，昵称、座右铭等(作用：背景放大不会影响内容的位置)
@property (nonatomic, strong) UIImageView                  * avatarImage;//头像
@property (nonatomic,   copy) UILabel                          * nickNameLB;//昵称

@property (nonatomic, assign) BOOL canScroll;
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabView; //到达顶部不能移动mainTableView
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabViewPre;//到达顶部不能移动子控制器的tableView

@end

@implementation PersonalCenterViewController
{
   NSInteger _topHeight;//导航栏的高度+状态栏的高度
   BOOL _isRefresh;//控制下拉放大时刷新数据的次数，做到下拉放大值刷新一次，避免重复刷新
    CGFloat _headViewHeight;//头部视图的高度
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化
    _isRefresh = YES;
    if (IS_IPHONEX) {
        _headViewHeight = headimageHeight + 44;
    }else {
        _headViewHeight = headimageHeight;
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    //接收宏定义的值，因为下面要做运算，宏不能直接拿来运算
    _topHeight = TopHeight;
    //如果使用自定义的按钮去替换系统默认返回按钮，会出现滑动返回手势失效的情况，解决方法如下：
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    //设置界面
    [self setUI];
    //请求数据
    [self requestData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"leaveTop" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    self.naviView.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
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
        make.height.mas_equalTo(_headViewHeight);
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

/**
 * 处理联动
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //获取滚动视图y值的偏移量
    CGFloat yOffset  = scrollView.contentOffset.y;//内层分页视图的偏移量
    CGFloat tabyOffset = [_mainTableView rectForSection:0].origin.y -_topHeight;//外层tableView的偏移量
    
     _isTopIsCanNotMoveTabViewPre = _isTopIsCanNotMoveTabView;//默认值为NO，都可以滑动
    
    if (yOffset >= tabyOffset) {
            //当分页视图滑动至导航栏时，禁止外层tableView滑动
            scrollView.contentOffset = CGPointMake(0, tabyOffset);
            _isTopIsCanNotMoveTabView = YES;
    }else{
            //当分页视图和顶部导航栏分离时，允许外层tableView滑动
            _isTopIsCanNotMoveTabView = NO;
    }
    
    //更改导航栏的背景图的透明度
    CGFloat newyOffset = -yOffset-_topHeight;
    CGFloat alpha = 0;
    if (newyOffset <= 0) {
        alpha = 1;
    }else{
        alpha = 0;
    }
    self.naviView.backgroundColor = kRGBA(255,126,15,alpha);
    
    if (_isTopIsCanNotMoveTabView != _isTopIsCanNotMoveTabViewPre) {
        if (!_isTopIsCanNotMoveTabViewPre && _isTopIsCanNotMoveTabView) {
            NSLog(@"滑动到顶端");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"goTop" object:nil userInfo:@{@"canScroll":@"1"}];
            _canScroll = NO;
        }
        if(_isTopIsCanNotMoveTabViewPre && !_isTopIsCanNotMoveTabView) {
            NSLog(@"离开顶端");
            if (!_canScroll) {
                scrollView.contentOffset = CGPointMake(0, tabyOffset);
            }
        }
    }
    
    /**
     * 处理头部背景视图
     * 图片会被拉伸多出状态栏的高度
     */
    if(yOffset <= -_headViewHeight) {
        if (_isEnlarge) {
            CGRect f = self.headImageView.frame;
            //改变HeadImageView的frame
            //上下放大
            f.origin.y = yOffset;
            f.size.height =  -yOffset;
            //左右放大
            f.origin.x = (yOffset*kScreenWidth/_headViewHeight+kScreenWidth)/2;
            f.size.width = -yOffset*kScreenWidth/_headViewHeight;
            //改变头部视图的frame
            self.headImageView.frame = f;
            //刷新数据，保证刷新一次
            if (yOffset ==  - _headViewHeight) {
                _isRefresh = YES;
            }
            if (yOffset < -_headViewHeight - 30 && _isRefresh) {
                [self requestData];
                _isRefresh = NO;
            }
        }else{
             _mainTableView.bounces = NO;
            if (yOffset == -_headViewHeight) {
                //刷新数据
                [self requestData];
            }
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
    return kScreenHeight-_topHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //添加segementView
    [cell.contentView addSubview:self.setPageViewControllers];
    return cell;
}

#pragma maek - 懒加载
- (UIView *)naviView {
    if (!_naviView) {
        _naviView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth,_topHeight)];
        _naviView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];//该透明色设置不会影响子视图
        //添加返回按钮
        self.backButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_backButton setImage:[UIImage imageNamed:@"back"] forState:(UIControlStateNormal)];
        _backButton.frame = CGRectMake(5, 28 + _topHeight - 64, 28, 25);
        _backButton.adjustsImageWhenHighlighted = NO;
        [_backButton addTarget:self action:@selector(backAction) forControlEvents:(UIControlEventTouchUpInside)];
        [_naviView addSubview:_backButton];
        //添加消息按钮
        self.messageButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_messageButton setImage:[UIImage imageNamed:@"message"] forState:(UIControlStateNormal)];
        _messageButton.frame = CGRectMake(kScreenWidth-35, 28 + _topHeight - 64, 25, 25);
        _messageButton.adjustsImageWhenHighlighted = NO;
        [_messageButton addTarget:self action:@selector(checkMessage) forControlEvents:(UIControlEventTouchUpInside)];
        [_naviView addSubview:_messageButton];
    }
    return _naviView;
}

#pragma mark - 懒加载
- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[CenterTouchTableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.showsVerticalScrollIndicator = NO;
        //注意：这里不能使用动态高度_headViewHeight, 不然tableView会往下移，在iphone X下，头部不放大的时候，上方依然会有白色空白
        _mainTableView.contentInset = UIEdgeInsetsMake(headimageHeight, 0, 0, 0);//内容视图开始正常显示的坐标为(0,_headViewHeight)
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

- (UIImageView *)headImageView
{
    if (!_headImageView)
    {
        _headImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"center_bg.jpg"]];
        _headImageView.backgroundColor = [UIColor greenColor];
        _headImageView.userInteractionEnabled = YES;
        _headImageView.frame = CGRectMake(0, -_headViewHeight, kScreenWidth, _headViewHeight);
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
        FirstViewController      * firstVC  = [[FirstViewController alloc]init];
        SecondViewController  * secondVC = [[SecondViewController alloc]init];
        ThirdViewController     * thirdVC  = [[ThirdViewController alloc]init];
        SecondViewController  * fourthVC = [[SecondViewController alloc]init];
        NSArray *controllers = @[firstVC,secondVC,thirdVC,fourthVC];
        NSArray *titleArray   = @[@"普吉岛",@"西雅图",@"洛杉矶",@"新泽西"];
        CenterSegmentView *segmentView = [[CenterSegmentView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth,    kScreenHeight - _topHeight) controllers:controllers titleArray:titleArray ParentController:self selectBtnIndex:_selectIndex lineWidth:kScreenWidth/5 lineHeight:3];
        _segmentView = segmentView;
    }
    return _segmentView;
}

@end
