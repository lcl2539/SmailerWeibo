//
//  ViewController.m
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/7.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//
#define navFrame self.navigationController.navigationBar.bounds
#define tableViewFrame(index) CGRectMake(index * self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)
#define dictKey(index) [NSString stringWithFormat:@"%ld",index]
#import "ViewController.h"
#import "NavigationScroll.h"
#import "StatusTableViewController.h"
#import "HttpRequest.h"
#import "StatusModel.h"
#import "PrefixHeader.pch"
#import <WeiboSDK.h>
#import <Masonry.h>
@interface ViewController ()<NavigationScrollDeleagte,UIScrollViewDelegate>
{
    __weak NavigationScroll *_navigationScroll;
    __weak UIScrollView *_mainScroll;
    __weak UIView *_contentView;
}
@property (nonatomic,strong)NSMutableSet *visibleTabViewControllers;
@property (nonatomic,strong)NSMutableSet *reusedTableViewControllers;
@property (nonatomic,strong)NSMutableDictionary *allData;
@property (nonatomic,assign)NSInteger top;
@end

@implementation ViewController

- (NSMutableSet *)visibleTabViewControllers{
    if (!_visibleTabViewControllers) {
        _visibleTabViewControllers = [[NSMutableSet alloc]init];
    }
    return _visibleTabViewControllers;
}

- (NSMutableSet *)reusedTableViewControllers{
    if (!_reusedTableViewControllers) {
        _reusedTableViewControllers = [[NSMutableSet alloc]init];
    }
    return _reusedTableViewControllers;
}

- (NSMutableDictionary *)allData{
    if (!_allData) {
        _allData = [[NSMutableDictionary alloc]init];
    }
    return _allData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSomeSetting];
    [self judgeLogin];
}

- (void)judgeLogin{
    NSString *access_token = myToken;
    if (!access_token) {
        WBAuthorizeRequest *request = [WBAuthorizeRequest request];
        request.redirectURI = redirect_Url;
        request.scope = @"all";
        [WeiboSDK sendRequest:request];
    }else{
        [self loadNavgationBarSetting];
        [self loadMianScrollView];
        [_navigationScroll changeNavgationScrollValue:0];
    }
}

- (void)loadSomeSetting{
    self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBarHidden = YES;
}

- (void)loadNavgationBarSetting{
    NavigationScroll *scroll = [[NavigationScroll alloc]init];
    [self.view addSubview:scroll];
    [scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo([UIApplication sharedApplication].statusBarFrame.size.height + navFrame.size.height + 30);
    }];
    _navigationScroll = scroll;
    _navigationScroll.delegate = self;
}

- (void)loadMianScrollView{
    UIScrollView *mainScrollView = [[UIScrollView alloc]init];
    [self.view addSubview:mainScrollView];
    [mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_navigationScroll.mas_bottom);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
    mainScrollView.pagingEnabled = YES;
    mainScrollView.showsVerticalScrollIndicator = NO;
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.delegate = self;
    mainScrollView.bounces = NO;
    _mainScroll = mainScrollView;
    UIView *contentView = [[UIView alloc]init];
    [_mainScroll addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.equalTo(_mainScroll);
        make.centerY.equalTo(_mainScroll.mas_centerY);
        make.width.mas_equalTo(self.view.frame.size.width*7);
    }];
    _contentView = contentView;
    [self showSatusViewAtIndex:0];
    [self loadVisibleTableViewData:0];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self judgeStatusScrollIndex];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [_navigationScroll changeNavgationScrollValue:(_mainScroll.bounds.origin.x/_mainScroll.bounds.size.width)];
    
}

- (void)loadVisibleTableViewData:(NSInteger)index{
    for (StatusTableViewController *vc in self.visibleTabViewControllers) {
        if (vc.index == index) {
            NSArray *arr = [self.allData valueForKey:dictKey(index)];
            if (arr) {
                vc.dataArr = arr;
            }else{
                [self tableViewLoadData:vc isReLoad:NO];
            }
        }
    }
}

- (void)tableViewLoadData:(StatusTableViewController *)vc isReLoad:(BOOL)isReLoad{
    __weak typeof(self) weakSelf = self;
    NSInteger page = 0;
    NSArray *arrTemp = self.allData[[NSString stringWithFormat:@"%ld",vc.index]];
    page = arrTemp.count/20 + 1;
    if (isReLoad && page >= 1) {
        page = 1;
        [self.allData setObject:[NSArray array] forKey:dictKey(vc.index)];
    }
    [HttpRequest statusHttpRequestWithType:vc.index page:page success:^(id Object) {
        [weakSelf loadDataWithArr:Object[@"statuses"] tableView:vc];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)loadDataWithArr:(NSArray *)arr tableView:(StatusTableViewController *)vc {
    NSArray *arrOrigin = self.allData[dictKey(vc.index)];
    NSMutableArray *arrTemp = [arrOrigin mutableCopy];
    if (!arrTemp || arrTemp.count == 0) {
        arrTemp = [[NSMutableArray alloc]init];
    }
    for (NSDictionary *dict in arr) {
        StatusModel *model = [StatusModel statusModelWithDictionary:dict];
        [arrTemp addObject:model];
    }
    [self.allData setObject:arrTemp forKey:dictKey(vc.index)];
    vc.dataArr = [arrTemp copy];
}

- (void)judgeStatusScrollIndex{
    CGRect visiblesBounds = _mainScroll.bounds;
    CGFloat minX = CGRectGetMinX(visiblesBounds);
    CGFloat maxX = CGRectGetMaxX(visiblesBounds);
    CGFloat width = CGRectGetWidth(visiblesBounds);
    NSInteger firstIndex = (NSInteger)floorf(minX/width);
    NSInteger lastIndex = (NSInteger)floorf(maxX/width);
    if (firstIndex < 0) {
        firstIndex = 0;
    }
    if (lastIndex >= 7) {
        lastIndex = 6;
    }
    for (StatusTableViewController *vc in self.visibleTabViewControllers) {
        if (vc.index < firstIndex || vc.index > lastIndex) {
            [self.reusedTableViewControllers addObject:vc];
            [vc removeFromParentViewController];
            [vc.tableView removeFromSuperview];
        }
    }
    [self.visibleTabViewControllers minusSet:self.reusedTableViewControllers];
    for (NSInteger index = firstIndex; index <= lastIndex; index++) {
        BOOL isShow = NO;
        for (StatusTableViewController *vc in self.visibleTabViewControllers) {
            if (vc.index == index) {
                isShow = YES;
            }
        }
        if (!isShow) {
            [self showSatusViewAtIndex:index];
        }
    }
}

- (void)showSatusViewAtIndex:(NSInteger)index{
    __weak typeof(self) weakSelf = self;
    StatusTableViewController *vc = [self.reusedTableViewControllers anyObject];
    if (vc) {
        [self.reusedTableViewControllers removeObject:vc];
    }else{
        StatusTableViewController *childVc = [[StatusTableViewController alloc]initWithStyle:UITableViewStyleGrouped];
        vc = childVc;
        vc.reloadDate = ^(StatusTableViewController *vc,BOOL isReLoad){
            [weakSelf tableViewLoadData:vc isReLoad:isReLoad];
        };
        vc.changeTop = ^(NSInteger value,NSInteger vcIndex){
            if ((NSInteger)floorf(_mainScroll.contentOffset.x/self.view.frame.size.width) != vcIndex) return ;
            if(value == 0)return;
            if (self.top+value >= 0) {
                self.top = 0;
            }else if(self.top+value <= -50){
                self.top = -50;
            }else{
                self.top += value;
            }
            [_navigationScroll mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_top).offset(self.top);
                make.leading.trailing.equalTo(self.view);
                make.height.mas_equalTo([UIApplication sharedApplication].statusBarFrame.size.height + navFrame.size.height + 30);
            }];
        };
    }
    vc.index = index;
    [self addChildViewController:vc];
    vc.dataArr = nil;
    [_contentView addSubview:vc.tableView];
    [vc.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(_contentView);
        make.width.mas_equalTo(self.view.frame.size.width);
        make.leading.mas_equalTo(index * self.view.frame.size.width);
    }];
    [self.visibleTabViewControllers addObject:vc];
    [self loadVisibleTableViewData:index];
}

- (void)navigationScrollValueDidChange:(NSInteger)value{
    [_mainScroll setContentOffset:CGPointMake(value * self.view.frame.size.width, 0) animated:YES];
}

@end
