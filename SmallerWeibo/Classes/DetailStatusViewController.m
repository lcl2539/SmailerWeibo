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
#import "TitleView.h"
#import <Masonry.h>
@interface DetailStatusViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak UITableView *_commentsTabview;
    __weak TitleView *_titleView;
}
@property (nonatomic,copy)NSString *strTitle;
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
    _strTitle = @"微博详情";
    [self httprRequest];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadTitleView];
    [self loadCommentsTableview];
}

- (void)loadTitleView{
    TitleView *view = [TitleView titleViewWithTitle:self.strTitle];
    [self.view addSubview:view];
    _titleView = view;
    [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo([UIApplication sharedApplication].statusBarFrame.size.height + 40);
    }];
}

- (void)loadCommentsTableview{
    UITableView *tab = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:tab];
    [tab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleView.mas_bottom);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
    _commentsTabview = tab;
    _commentsTabview.delegate = self;
    _commentsTabview.dataSource = self;
    _commentsTabview.estimatedRowHeight = 50;
    _commentsTabview.separatorInset = UIEdgeInsetsMake(0, -10, 0, 0);
    _commentsTabview.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(httprRequest)];
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
@end
