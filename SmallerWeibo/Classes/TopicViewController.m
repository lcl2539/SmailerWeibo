//
//  TopicViewController.m
//  SmallerWeibo
//
//  Created by qingyun on 16/9/2.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "TopicViewController.h"
#import "TitleView.h"
#import "StatusModel.h"
#import "HttpRequest.h"
#import "StatusCell.h"
#import <Masonry.h>
#import <MJRefresh.h>
@interface TopicViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak TitleView *_title;
    __weak UITableView *_statusLists;
}
@property (nonatomic,copy)NSArray *data;
@end

@implementation TopicViewController

- (NSArray *)data{
    if (!_data) {
        _data = [[NSArray alloc]init];
    }
    return _data;
}

- (void)setTopic:(NSString *)topic{
    _topic = topic;
    [_title title:topic];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadTitleView];
    [self loadStatusTableview];
    [self httpRequest];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)loadTitleView{
    TitleView *view = [TitleView titleViewWithTitle:self.topic];
    [self.view addSubview:view];
    _title = view;
    [_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo([UIApplication sharedApplication].statusBarFrame.size.height + 40);
    }];
}

- (void)loadStatusTableview{
    UITableView *tab = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:tab];
    [tab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_title.mas_bottom);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
    tab.separatorInset  =UIEdgeInsetsMake(0, 66, 0, 0);
    _statusLists = tab;
    _statusLists.delegate = self;
    _statusLists.dataSource = self;
    _statusLists.estimatedRowHeight = 50;
    _statusLists.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    _statusLists.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(httpRequest)];
    __weak typeof(self) weakSelf = self;
    _statusLists.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.data = nil;
        [weakSelf httpRequest];
    }];
    [_statusLists.mj_header beginRefreshing];
}

- (void)httpRequest{
    __weak typeof(self) weakSelf = self;
    NSInteger page = 0;
    NSArray *arrTemp = self.data;
    page = arrTemp.count/20 + 1;
    if (arrTemp.count>0 && page == 1) {
        page += 1;
    }
    [HttpRequest topicStatusWithTopic:self.topic page:page success:^(id object) {
        [weakSelf loadDataWithArr:object[@"statuses"]];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)loadDataWithArr:(NSArray *)arr{
    NSMutableArray *arrTemp = [self.data mutableCopy];
    NSArray *ar = [arr copy];
    for (NSDictionary *dict in ar) {
        StatusModel *model = [StatusModel statusModelWithDictionary:dict];
        [arrTemp addObject:model];
    }
    self.data = arrTemp;
    [_statusLists.mj_header endRefreshing];
    [_statusLists.mj_footer endRefreshing];
    [_statusLists reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    StatusCell *cell = [StatusCell statusCellWithTableView:tableView];
    cell.model = self.data[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
