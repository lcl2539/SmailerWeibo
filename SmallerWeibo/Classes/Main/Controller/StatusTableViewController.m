//
//  StatusTableViewController.m
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/12.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "StatusTableViewController.h"
#import "StatusCell.h"
#import "ReviewImgController.h"
#import <MJRefresh.h>
@interface StatusTableViewController ()<StatusCellDelegate>
@property (nonatomic,assign)NSInteger lastOffsetY;
@end

@implementation StatusTableViewController

- (void)viewWillAppear:(BOOL)animated{
    self.lastOffsetY = 0;
}

- (void)setDataArr:(NSArray *)dataArr{
    if (_dataArr.count == dataArr.count) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        return;
    }
    _dataArr = dataArr;
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSomeSetting];
}

- (void)loadSomeSetting{
    self.tableView.separatorInset = UIEdgeInsetsMake(0, -10, 0, 0);
    self.tableView.estimatedRowHeight = 100;
    self.tableView.sectionHeaderHeight = 3;
    self.tableView.sectionFooterHeight = 3;
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 3)];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
}

- (void)loadData{
    BOOL isReLoad = NO;
    if (self.tableView.contentOffset.y <= 100) {
        isReLoad = YES;
    }
    if (self.reloadDate) {
        self.reloadDate(self,isReLoad);
    }
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StatusCell *cell = [StatusCell statusCellWithTableView:tableView];
    StatusModel *model = self.dataArr[indexPath.section];
    cell.model = model;
    cell.delegate = self;
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.lastOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y < 0) return;
    if (scrollView.contentOffset.y >= scrollView.contentSize.height-[UIScreen mainScreen].bounds.size.height)return;
    NSInteger value = self.lastOffsetY - scrollView.contentOffset.y;
    if (self.changeTop) {
        self.changeTop(value,self.index);
    }
    self.lastOffsetY = scrollView.contentOffset.y;
}

- (void)showImgWithArr:(NSArray *)imgArr index:(NSInteger)index{
    ReviewImgController *vc = [[ReviewImgController alloc]init];
    vc.picArr = imgArr;
    vc.showWhichImg = index;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
