//
//  DetailStatusViewController.m
//  SmallerWeibo
//
//  Created by qingyun on 16/8/25.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "DetailStatusViewController.h"
#import "HttpRequest.h"
#import "StatusCell.h"
#import "commentsModel.h"
#import "CommentsTableViewCell.h"
#import "StatusModel.h"
#import <MJRefresh.h>
@interface DetailStatusViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak UITableView *_commentsTabview;
}
@property (nonatomic,copy)NSArray *data;
@end

@implementation DetailStatusViewController

- (NSArray *)data{
    if (!_data) {
        _data = [NSArray array];
    }
    return _data;
}

- (void)setStatusModel:(StatusModel *)statusModel{
    _statusModel = statusModel;
    [self httprRequest];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self loadCommentsTableview];
    [self loadNavBar];
}

- (void)loadCommentsTableview{
    UITableView *tab = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:tab];
    _commentsTabview = tab;
    _commentsTabview.delegate = self;
    _commentsTabview.dataSource = self;
    _commentsTabview.estimatedRowHeight = 50;
    _commentsTabview.separatorInset = UIEdgeInsetsMake(0, -10, 0, 0);
    _commentsTabview.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(httprRequest)];
}

- (void)loadNavBar{
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:0 target:self action:@selector(back)];
    back.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)httprRequest{
    [_commentsTabview.mj_footer beginRefreshing];
    __weak typeof(self) weakSelf = self;
    NSInteger page = 0;
    NSArray *arrTemp = self.data;
    page = arrTemp.count/30 + 1;
    if (arrTemp.count>0 && page == 1) {
        page += 1;
    }
    [HttpRequest detailsStatusHttpRequestWithStatusID:self.statusModel.strIdstr page:page success:^(id object) {
        NSArray *arr = object[@"comments"];
        [weakSelf loadData:arr];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)loadData:(NSArray *)arr{
    if (arr.count == 0 && self.data.count == 0) {
        [_commentsTabview.mj_footer endRefreshingWithNoMoreData];
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 50)];
        lab.text = @"还没有人评论~~~";
        lab.textColor = [UIColor darkTextColor];
        lab.textAlignment = NSTextAlignmentCenter;
        _commentsTabview.tableFooterView = lab;
    }else{
        if (arr.count == 0) {
            [_commentsTabview.mj_footer endRefreshingWithNoMoreData];
        }else{
            [_commentsTabview.mj_footer endRefreshing];
            NSMutableArray *arrTemp = [self.data mutableCopy];
            for (NSDictionary *dict in arr) {
                commentsModel *model = [commentsModel commentsModleWithDict:dict];
                [arrTemp addObject:model];
            }
            self.data = arrTemp;
            [_commentsTabview reloadData];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else{
        return self.data.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        StatusCell *cell = [StatusCell statusCellWithTableView:tableView];
        //cell.delegate = self;
        cell.model = self.statusModel;
        return cell;
    }else{
        CommentsTableViewCell *cell = [CommentsTableViewCell commentsCellWithTableview:tableView];
        commentsModel *model = self.data[indexPath.row];
        cell.model = model;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)back{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
