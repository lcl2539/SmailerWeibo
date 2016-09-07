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
#import "StatusCell.h"
#import "StatusModel.h"
#import "UserModel.h"
#import "ReViewImgAnimation.h"
#import <MJRefresh.h>
@interface UserShowViewController ()<UITableViewDelegate,UITableViewDataSource,UserHeadDelegate>
{
    __weak UITableView *_statusList;
    __weak UserInfoHeadView *_head;
}
@property (nonatomic,assign)BOOL isFinish;
@property (nonatomic,copy)NSArray *data;
@property (nonatomic,assign)CGRect lastFrame;
@property (nonatomic,assign)NSInteger height;
@property (nonatomic,assign)CGFloat lastOffsetY;
@property (nonatomic,assign)CGPoint lastCenter;
@property (nonatomic,strong)NSString *lastVc;
@end

@implementation UserShowViewController

- (NSArray *)data{
    if (!_data) {
        _data = [NSArray array];
    }
    return _data;
}

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
        [self httpRequest];
        if (self.placeHoldView) {
            _head.userImage = self.placeHoldView.image;
            _head.alpha = 0;
            _statusList.alpha = 0;
            [self.view addSubview:self.placeHoldView];
        }else{
            [_head userImgShow];
            CGRect frame = CGRectMake(0, 0, 0, CGFLOAT_MIN);
            _statusList.tableHeaderView = [[UIView alloc]initWithFrame:frame];
        }
        [self.view sendSubviewToBack:_statusList];
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
        self.placeHoldView.transform = CGAffineTransformMakeScale(1.4, 1.4);
        self.placeHoldView.center = CGPointMake(self.view.center.x, 55);
        _head.alpha = 1;
        _statusList.alpha = 1;
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

- (void)httpRequest{
    __weak typeof(self) weakSelf = self;
    NSInteger page = 1;
    page = self.data.count/20 + 1;
    page = (self.data.count%20 > 0) ? page + 1 : page;
    [HttpRequest userShowHttpRequestWithId:self.model.strIdstr page:page success:^(id object) {
        [weakSelf loadDataWithArr:object[@"statuses"]];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)loadDataWithArr:(NSArray *)arr{
    NSMutableArray *arrTemp = [self.data mutableCopy];
    for (NSDictionary *dict in arr) {
        StatusModel *model = [StatusModel statusModelWithDictionary:dict];
        [arrTemp addObject:model];
    }
    if (arrTemp.count == self.data.count) {
        [_statusList.mj_footer endRefreshingWithNoMoreData];
    }else{
        [_statusList.mj_footer endRefreshing];
    }
    [_statusList.mj_header endRefreshing];
    self.data = arrTemp;
    [_statusList reloadData];
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
    UITableView *tab = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:tab];
    [tab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_head.mas_bottom);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
    _statusList = tab;
    tab.delegate = self;
    tab.dataSource = self;
    tab.estimatedRowHeight = 100;
    tab.separatorInset  =UIEdgeInsetsMake(0, 66, 0, 0);
    tab.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    tab.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.data = [[NSArray alloc]init];
        [weakSelf httpRequest];
    }];
    tab.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf httpRequest];
    }];
}

- (void)back{
    if (self.placeHoldView) {
        self.placeHoldView.alpha = 1;
        [_head userImgShow];
        [UIView animateWithDuration:0.3 animations:^{
            _head.alpha = 0;
            _statusList.alpha = 0;
            self.placeHoldView.transform = CGAffineTransformMakeScale(1, 1);
            self.placeHoldView.center = self.lastCenter;
        }];
        self.navigationController.delegate = self;
    }
    [self.fromVc.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id model = self.data[indexPath.row];
    StatusCell *cell = [StatusCell statusCellWithTableView:tableView];
    cell.model = model;
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.y < 0 || scrollView.contentOffset.y > [UIScreen mainScreen].bounds.size.height )return;
    NSInteger value = self.lastOffsetY - scrollView.contentOffset.y;
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
    self.lastOffsetY = scrollView.contentOffset.y;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    ReViewImgAnimation *animation = [ReViewImgAnimation shareAnimation];
    animation.type = (fromVC == self) ? kPopAnimationType : kPushAnimationType;
    return animation;
}

@end
