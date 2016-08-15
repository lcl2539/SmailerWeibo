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

- (NSArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSArray alloc]init];
    }
    return _dataArr;
}

- (void)setdataArr:(NSArray *)dataArr{
    _dataArr = dataArr;
    [self.tableView reloadData];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"放开加载"];
    [self.refreshControl endRefreshing];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSomeSetting];
    [self.tableView reloadData];
    [self.refreshControl beginRefreshing];
}

- (void)loadSomeSetting{
    self.navigationController.hidesBarsOnSwipe = NO;
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"放开加载"];
    [self.refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, -10, 0, 0);
    self.tableView.estimatedRowHeight = 100;
    self.tableView.backgroundColor = [UIColor whiteColor];
}

- (void)loadData{
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"正在加载"];
    if (self.reloadDate) {
        self.reloadDate(self);
    }
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StatusCell *cell = [StatusCell statusCellWithTableView:tableView];
    StatusModel *model = self.dataArr[indexPath.row];
    cell.model = model;
    if (indexPath.row == self.dataArr.count-3) {
        if (self.loadMoreDate) {
            self.loadMoreDate(self);
        }
    }
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
//    if (!cell) {
//        cell = [[UITableViewCell alloc]init];
//    }
//    cell.textLabel.text = self.dataArr[indexPath.row];
    return cell;
}


@end
