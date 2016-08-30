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
@interface UserShowViewController ()<UITableViewDelegate,UITableViewDataSource,UIViewControllerTransitioningDelegate,UserHeadDelegate>
{
    __weak UITableView *_statusList;
    __weak UserInfoHeadView *_head;
}
@property (nonatomic,assign)BOOL isFinish;
@property (nonatomic,copy)NSArray *data;
@property (nonatomic,assign)CGRect lastFrame;
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
    [self loadHeadView];
    [self loadTableView];
    [self httpRequest];
    _head.alpha = 0;
    _statusList.alpha = 0;
    [self.view addSubview:self.placeHoldView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    Class class = NSClassFromString(@"ReviewImgController");
    if ([self.presentedViewController isKindOfClass:[class class]]) {
        return;
    }
    self.lastFrame = self.placeHoldView.frame;
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
}

- (void)show{
    self.fromVc.transitioningDelegate = self;
    self.transitioningDelegate = self;
    [self.fromVc presentViewController:self animated:YES completion:nil];
}

- (void)httpRequest{
    __weak typeof(self) weakSelf = self;
    NSInteger page = 1;
    page = self.data.count/20 + 1;
    page = (self.data.count%20 > 0) ? page + 1 : page;
    [HttpRequest userShowHttpRequestWithName:self.model.strScreenName page:page success:^(id object) {
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
    [head mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.height.equalTo(@200);
    }];
}

- (void)loadTableView{
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
}

- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section{
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id model = self.data[indexPath.section];
    StatusCell *cell = [StatusCell statusCellWithTableView:tableView];
    cell.model = model;
    return cell;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    ReViewImgAnimation *animation = [[ReViewImgAnimation alloc]init];
    animation.type = kPresentAnimationType;
    return animation;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    ReViewImgAnimation *animation = [[ReViewImgAnimation alloc]init];
    animation.type = kDismissAnimationType;
    return animation;
}
@end
