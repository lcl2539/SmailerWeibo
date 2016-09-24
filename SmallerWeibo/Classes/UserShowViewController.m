//
//  UserShowViewController.m
//  SmallerWeibo
//
//  Created by qingyun on 16/8/30.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "UserShowViewController.h"
#import "UserInfoHeadView.h"
#import <Masonry.h>
#import "HttpRequest.h"
#import "StatusModel.h"
#import "UserModel.h"
#import "ReViewImgAnimation.h"
#import "LStatusTableVC.h"
@interface UserShowViewController ()<UserHeadDelegate>
{
    __weak LStatusTableVC *_statusList;
    __weak UserInfoHeadView *_head;
}
@property (nonatomic,assign)BOOL isFinish;
@property (nonatomic,assign)CGRect lastFrame;
@property (nonatomic,assign)NSInteger height;
@property (nonatomic,assign)CGFloat lastOffsetY;
@property (nonatomic,assign)CGPoint lastCenter;
@property (nonatomic,strong)NSString *lastVc;
@end

@implementation UserShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self judgeDoWhat];
}

- (void)judgeDoWhat{
    if (self.model) {
        [self loadHeadView];
        [self loadTableView];
        [self httpRequestWithIsReload:YES];
        if (self.placeHoldView) {
            _head.userImage = self.placeHoldView.image;
            _head.alpha = 0;
            _statusList.tableView.alpha = 0;
            [self.view addSubview:self.placeHoldView];
        }else{
            [_head userImgShow];
            CGRect frame = CGRectMake(0, 0, 0, CGFLOAT_MIN);
            _statusList.tableView.tableHeaderView = [[UIView alloc]initWithFrame:frame];
        }
        [self.view sendSubviewToBack:_statusList.tableView];
    }else{
        __weak typeof(self) weakSelf = self;
        [HttpRequest userModelFromUserName:self.name success:^(id object) {
            weakSelf.model = [UserModel userModelWithDictionary:object];
            [weakSelf judgeDoWhat];
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.lastVc || !self.placeHoldView) {
        return;
    }
    if (self.lastFrame.size.height == 0) {
        self.lastCenter = self.placeHoldView.center;
        self.lastFrame = self.placeHoldView.frame;
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.placeHoldView.transform = CGAffineTransformMakeScale(1.75, 1.75);
        self.placeHoldView.center = CGPointMake(self.view.center.x, 55);
        _head.alpha = 1;
        _statusList.tableView.alpha = 1;
    } completion:^(BOOL finished) {
        [_head userImgShow];
        if (self.isFinish) {
            self.placeHoldView.alpha = 0;
        }else{
            self.isFinish = YES;
        }
    }];
    self.lastVc = nil;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.lastVc = NSStringFromClass([self.navigationController.viewControllers.lastObject class]);
}

- (void)show{
    [self.fromVc.navigationController pushViewController:self animated:YES];
}
- (void)loadHeadView{
    UserInfoHeadView *head = [UserInfoHeadView headView];
    [self.view addSubview:head];
    _head = head;
    __weak typeof(self) weakSelf = self;
    head.downloadFinish = ^{
        if (weakSelf.isFinish) {
            weakSelf.placeHoldView.alpha = 1;
        }else{
            weakSelf.isFinish = YES;
        }
    };
    head.delegate = self;
    head.model = self.model;
    self.height = 200;
    [head mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo(self.height);
    }];
}

- (void)loadTableView{
    __weak typeof(self) weakSelf = self;
    LStatusTableVC *tab = [[LStatusTableVC alloc]initWithStyle:UITableViewStyleGrouped];
    [self addChildViewController:tab];
    [self.view addSubview:tab.tableView];
    [tab.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_head.mas_bottom);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
    _statusList = tab;
    _statusList.reloadDate = ^(LStatusTableVC *vc,BOOL isReLoad){
        [weakSelf httpRequestWithIsReload:isReLoad];
    };
    _statusList.didScroll = ^{
        if(_statusList.tableView.contentOffset.y < 0 || _statusList.tableView.contentOffset.y > [UIScreen mainScreen].bounds.size.height )return;
        NSInteger value = self.lastOffsetY - _statusList.tableView.contentOffset.y;
        self.height += value;
        if (self.height < 50) {
            self.height = 50;
        }
        if (self.height > 200) {
            self.height = 200;
        }
        [_head mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.equalTo(self.view);
            make.height.mas_equalTo(self.height);
        }];
        CGFloat alpha = (self.height - 50) / 150.0;
        [_head changeAlpha:alpha];
        CGFloat scale = ((20.0 * alpha) + 50) / 70.0;
        if (self.placeHoldView) {
            self.placeHoldView.transform = CGAffineTransformMakeScale(scale+0.4, scale+0.4);
            self.placeHoldView.center = CGPointMake(self.view.center.x, 20 + 35.0 *scale);
        }
        self.lastOffsetY = _statusList.tableView.contentOffset.y;
    };
}

- (void)httpRequestWithIsReload:(BOOL)isReload{
    __weak typeof(self) weakSelf = self;
    NSInteger page = 1;
    if (!isReload) {
        page = _statusList.dataArr.count/20 + 1;
        page = (_statusList.dataArr.count%20 > 0) ? page + 1 : page;
    }
    [HttpRequest userShowHttpRequestWithId:self.model.strIdstr page:page success:^(id object) {
        [weakSelf loadDataWithArr:object[@"statuses"]];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)loadDataWithArr:(NSArray *)arr{
    NSMutableArray *arrTemp = [_statusList.dataArr mutableCopy];
    for (NSDictionary *dict in arr) {
        StatusModel *model = [StatusModel statusModelWithDictionary:dict];
        [arrTemp addObject:model];
    }
    _statusList.dataArr = arrTemp;
}

- (void)back{
    if (self.placeHoldView) {
        self.placeHoldView.alpha = 1;
        [_head userImgShow];
        [UIView animateWithDuration:0.3 animations:^{
            _head.alpha = 0;
            _statusList.tableView.alpha = 0;
            self.placeHoldView.transform = CGAffineTransformMakeScale(1, 1);
            self.placeHoldView.center = self.lastCenter;
        }];
        self.navigationController.delegate = self;
    }
    [self.fromVc.navigationController popViewControllerAnimated:YES];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    ReViewImgAnimation *animation = [ReViewImgAnimation shareAnimation];
    animation.type = (fromVC == self) ? kPopAnimationType : kPushAnimationType;
    return animation;
}

@end
