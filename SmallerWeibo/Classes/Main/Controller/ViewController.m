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
#import "MainScrollView.h"
#import "StatusTableViewController.h"
#import "HttpRequest.h"
#import "StatusModel.h"
@interface ViewController ()<NavigationScrollDeleagte,UIScrollViewDelegate>
{
    __weak NavigationScroll *_navigationScroll;
    __weak UIScrollView *_mainScroll;
}
@property (nonatomic,strong)NSMutableSet *visibleTabViewControllers;
@property (nonatomic,strong)NSMutableSet *reusedTableViewControllers;
@property (nonatomic,strong)NSMutableDictionary *allData;
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
    [self loadNavgationBarSetting];
    [self loadMianScrollView];
    [_navigationScroll changeNavgationScrollValue:0];
}

- (void)loadSomeSetting{
    self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
    self.view.backgroundColor=[UIColor darkGrayColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.shadowImage = nil;
}

- (void)loadNavgationBarSetting{
    NavigationScroll *scroll = [[NavigationScroll alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width,30)];
    [self.view addSubview:scroll];
    _navigationScroll = scroll;
    _navigationScroll.delegate = self;
}

- (void)loadMianScrollView{
    UIScrollView *mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 30, self.view.frame.size.width,self.view.frame.size.height)];
    [self.view addSubview:mainScrollView];
    mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width * 7, 0);
    mainScrollView.pagingEnabled = YES;
    mainScrollView.showsVerticalScrollIndicator = NO;
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.delegate = self;
    mainScrollView.bounces = NO;
    _mainScroll = mainScrollView;
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
                [self tableViewLoadData:vc];
            }
        }
    }
}

- (void)tableViewLoadData:(StatusTableViewController *)vc{
    __weak typeof(self) weakSelf = self;
    [HttpRequest statusHttpRequestWithType:vc.index success:^(id Object) {
        [weakSelf loadDataWithArr:Object[@"statuses"] tableView:vc];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)loadDataWithArr:(NSArray *)arr tableView:(StatusTableViewController *)vc {
    NSMutableArray *arrTemp = [[NSMutableArray alloc]init];
    for (NSDictionary *dict in arr) {
        StatusModel *model = [StatusModel statusModelWithDictionary:dict];
        [arrTemp addObject:model];
    }
    [self.allData setObject:arrTemp forKey:dictKey(vc.index)];
    vc.dataArr = arrTemp;
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
        vc.reloadDate = ^(StatusTableViewController *vc){
            [weakSelf tableViewLoadData:vc];
        };
        vc.loadMoreDate = ^(StatusTableViewController *vc){
            
        };
    }
    vc.index = index;
    vc.dataArr = nil;
    [self addChildViewController:vc];
    [_mainScroll addSubview:vc.tableView];
    vc.tableView.frame = tableViewFrame(index);
    [self.visibleTabViewControllers addObject:vc];
    [vc.refreshControl beginRefreshing];
    [self loadVisibleTableViewData:index];
}

- (void)navigationScrollValueDidChange:(NSInteger)value{
    [_mainScroll setContentOffset:CGPointMake(value * self.view.frame.size.width, 0) animated:YES];
}

@end
