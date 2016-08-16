//
//  StatusTableViewController.m
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/12.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "StatusTableViewController.h"
#import "StatusCell.h"
@interface StatusTableViewController ()

@end

@implementation StatusTableViewController

- (void)setDataArr:(NSArray *)dataArr{
    _dataArr = dataArr;
    [self.tableView reloadData];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"放开加载"];
    [self.refreshControl endRefreshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSomeSetting];
    [self.refreshControl beginRefreshing];
}

- (void)loadSomeSetting{
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"放开加载"];
    [self.refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, -10, 0, 0);
    self.tableView.estimatedRowHeight = 100;
    self.tableView.sectionHeaderHeight = 3;
    self.tableView.sectionFooterHeight = 3;
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 3)];
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
    if (indexPath.row == self.dataArr.count-3) {
        if (self.loadMoreDate) {
            self.loadMoreDate(self);
        }
    }
    return cell;
}

@end
