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
    _dataArr = dataArr;
    [self.tableView reloadData];
    [self.tableView.mj_footer endRefreshing];
    [self.tableView.mj_header endRefreshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSomeSetting];
    //[self.refreshControl beginRefreshing];
    
}

- (void)loadSomeSetting{
    //self.refreshControl = [[UIRefreshControl alloc]init];
    //self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"放开加载"];
    //[self.refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, -10, 0, 0);
    self.tableView.estimatedRowHeight = 100;
    self.tableView.sectionHeaderHeight = 3;
    self.tableView.sectionFooterHeight = 3;
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 3)];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    //[self.tableView.mj_header beginRefreshing];
}

- (void)loadData{
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"正在加载"];
    if (self.reloadDate) {
        self.reloadDate(self);
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
