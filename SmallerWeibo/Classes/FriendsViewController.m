//
//  FansViewController.m
//  SmallerWeibo
//
//  Created by qingyun on 16/8/29.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "FriendsViewController.h"
#import "UserModel.h"
#import "UserTableViewCell.h"
#import "HttpRequest.h"
#import <MJRefresh.h>
#import "TitleView.h"
#import <Masonry.h>
@interface FriendsViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak UITableView *_tab;
    __weak TitleView *_titleView;
}
@property (nonatomic,copy)NSArray *data;
@property (nonatomic,copy)NSString *strTitle;
@end

@implementation FriendsViewController

- (NSArray *)data{
    if (!_data) {
        _data = [NSArray array];
    }
    return _data;
}

- (void)setModel:(UserModel *)model{
    _model = model;
    _strTitle = (self.type == kFriendsVcFollows) ? [NSString stringWithFormat:@"%@的粉丝",model.strScreenName] :[NSString stringWithFormat:@"%@的关注",model.strScreenName];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadTitleView];
    [self loadTabView];
    [self httpRequest];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_titleView title:self.strTitle];
}

- (void)loadTitleView{
    TitleView *view = [TitleView titleViewWithTitle:self.strTitle];
    [self.view addSubview:view];
    _titleView = view;
    [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo([[UIApplication sharedApplication]statusBarFrame].size.height+50);
    }];
}

- (void)loadTabView{
    UITableView *tab = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:tab];
    _tab = tab;
    _tab.estimatedRowHeight = 40;
    tab.delegate = self;
    tab.dataSource = self;
    [_tab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleView.mas_bottom);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
}

- (void)httpRequest{
    __weak typeof(self) weakSelf = self;
    [HttpRequest friendsHttpRequestWithSuccess:^(id object) {
        [weakSelf loadData:object[@"users"]];
    } failure:^(NSError *error) {
        
    } cursor:0 type:self.type userID:self.model.strIdstr];
}

- (void)loadData:(NSArray *)arr{
    NSMutableArray *arrTemp = [NSMutableArray arrayWithCapacity:arr.count];
    for (NSDictionary *dict in arr) {
        UserModel *model = [UserModel userModelWithDictionary:dict];
        [arrTemp addObject:model];
    }
    self.data = arrTemp;
    [_tab reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserTableViewCell *cell = [UserTableViewCell userCellWithTableView:tableView];
    UserModel *model = self.data[indexPath.row];
    cell.model = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (void)show{
    [self.fromVc.navigationController pushViewController:self animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell showUser];
}

@end
