//
//  LStatusTableVC.m
//  SmallerWeibo
//
//  Created by qingyun on 2016/9/20.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "LStatusTableVC.h"
#import <MJRefresh.h>
#import "StatusCell.h"
#import "UIView+extend.h"
#import "NSString+Extend.h"
#import "StatusModel.h"
#import "CommentsStatusModel.h"
#import "LPreviewImgVC.h"
@interface LStatusTableVC ()<UIViewControllerPreviewingDelegate>
@property (nonatomic,assign)NSInteger lastOffsetY;
@property (nonatomic,strong)NSMutableDictionary *indexs;
@property (nonatomic,strong)NSMutableDictionary *statusBtnStatus;
@end

@implementation LStatusTableVC
- (void)viewWillAppear:(BOOL)animated{
    self.lastOffsetY = 0;
}

- (void)setHaveReload:(BOOL)haveReload{
    _haveReload = haveReload;
    if (!haveReload) {
        self.tableView.mj_header = nil;
    }
}

- (void)setDataArr:(NSArray *)dataArr{
    if (_dataArr.count == dataArr.count && _dataArr) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        return;
    }
    _dataArr = dataArr;
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
}

- (NSMutableDictionary *)statusBtnStatus{
    if (!_statusBtnStatus) {
        _statusBtnStatus = [NSMutableDictionary dictionary];
    }
    return _statusBtnStatus;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSomeSetting];
    [self loadBackGroundView];
    [self loadForceTouch];
}

- (void)loadSomeSetting{
    self.haveReload = YES;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 66, 0, 0);
    self.tableView.estimatedRowHeight = 100;
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0.1)];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.dataArr = [NSArray array];
}

- (void)loadBackGroundView{
    UILabel *lab = [[UILabel alloc]init];
    lab.text = @"比较小的微博";
    lab.textColor = [UIColor flatGrayColor];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.font = [UIFont systemFontOfSize:25];
    self.tableView.backgroundView = lab;
}

- (void)loadForceTouch{
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:self.tableView];
    }
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit{
    
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    StatusCell *cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForRowAtPoint:location]];
    __block LPreviewImgVC *vc = nil;
    __weak typeof(self) weakSelf = self;
    [cell imageWithLocotion:[cell convertPoint:location fromView:self.tableView] result:^(CGRect frame, NSString *url) {
        if (url) {
            [previewingContext setSourceRect:[weakSelf.tableView convertRect:frame fromView:weakSelf.tableView.window]];
            vc = [[LPreviewImgVC alloc]init];
            vc.url = url;
        }
    }];
    if (vc) {
        return vc;
    }
    return nil;
}
- (void)loadData{
    BOOL isReLoad = NO;
    if (self.tableView.contentOffset.y <= 100) {
        isReLoad = YES;
    }
    if (isReLoad) {
        self.dataArr = nil;
    }
    self.reloadDate(self,isReLoad);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = self.dataArr[indexPath.row];
    StatusCell *cell = [StatusCell statusCellWithTableView:tableView];
    if (!cell.btnDidClick) {
        __weak typeof(self) weakSelf = self;
        cell.btnDidClick = ^ (StatusCell *cell,BtnType type){
            NSIndexPath *cellIndex = [tableView indexPathForCell:cell];
            if (cellIndex) {
                NSMutableArray *arrTemp = weakSelf.statusBtnStatus[cellIndex];
                if (!arrTemp) {
                    arrTemp = [NSMutableArray array];
                }
                [arrTemp addObject:[NSNumber numberWithInteger:type]];
                [weakSelf.statusBtnStatus setObject:arrTemp forKey:cellIndex];
            }
        };
    }
    cell.model = model;
    NSArray *arr = self.statusBtnStatus[indexPath];
    if (arr) {
        for (id obj in arr) {
            [cell changeBtnStatuWithType:[obj integerValue]];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.lastOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.didScroll) {
        self.didScroll();
    }
    if (self.changeTop) {
        if (scrollView.contentOffset.y < 0) return;
        if (scrollView.contentOffset.y >= scrollView.contentSize.height-[UIScreen mainScreen].bounds.size.height)return;
        NSInteger value = self.lastOffsetY - scrollView.contentOffset.y;
            self.changeTop(value,self.index);
    }
    self.lastOffsetY = scrollView.contentOffset.y;
}

- (void)statusCell:(StatusCell *)cell videoWithDict:(NSDictionary *)dict{
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    [self.tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)toastWithString:(NSString *)str{
    [self.view toastWithString:str type:kLabPostionTypeBottom];
}


@end
