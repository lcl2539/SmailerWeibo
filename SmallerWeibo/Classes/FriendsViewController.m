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
@interface FriendsViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak UITableView *_tab;
}
@property (nonatomic,copy)NSArray *data;
@end

@implementation FriendsViewController

- (NSArray *)data{
    if (!_data) {
        _data = [NSArray array];
    }
    return _data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadTabView];
    [self httpRequest];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:0 target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = back;
    back.tintColor = [UIColor whiteColor];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)loadTabView{
    UITableView *tab = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:tab];
    _tab = tab;
    _tab.estimatedRowHeight = 50;
    tab.delegate = self;
    tab.dataSource = self;
}

- (void)httpRequest{
    __weak typeof(self) weakSelf = self;
    [HttpRequest friendsHttpRequestWithSuccess:^(id object) {
        [weakSelf loadData:object[@"users"]];
    } failure:^(NSError *error) {
        
    } cursor:0 type:self.type];
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)back{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
