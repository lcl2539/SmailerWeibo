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
#import <Masonry.h>
#import "LStatusTableVC.h"
@interface TopicViewController ()
{
    __weak TitleView *_title;
    __weak LStatusTableVC *_statusLists;
}
@end

@implementation TopicViewController

- (void)setTopic:(NSString *)topic{
    _topic = topic;
    [_title title:topic];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadTitleView];
    [self loadStatusTableview];
    [self httpRequestWithIsReload:YES];
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
    LStatusTableVC *tab = [[LStatusTableVC alloc]initWithStyle:UITableViewStyleGrouped];
    [self addChildViewController:tab];
    [self.view addSubview:tab.tableView];
    [tab.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_title.mas_bottom);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
    _statusLists = tab;
    __weak typeof(self) weakSelf = self;
    _statusLists.reloadDate = ^(LStatusTableVC *vc,BOOL isReload){
        [weakSelf httpRequestWithIsReload:isReload];
    };
}

- (void)httpRequestWithIsReload:(BOOL)isReload{
    __weak typeof(self) weakSelf = self;
    NSInteger page = 1;
    if (!isReload) {
        page = _statusLists.dataArr.count/20 + 1;
        page = (_statusLists.dataArr.count%20 > 0) ? page + 1 : page;
    }
    [HttpRequest topicStatusWithTopic:self.topic page:page success:^(id object) {
        [weakSelf loadDataWithArr:object[@"statuses"]];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)loadDataWithArr:(NSArray *)arr{
    NSMutableArray *arrTemp = [_statusLists.dataArr mutableCopy];
    NSArray *ar = [arr copy];
    for (NSDictionary *dict in ar) {
        StatusModel *model = [StatusModel statusModelWithDictionary:dict];
        [arrTemp addObject:model];
    }
    _statusLists.dataArr = arrTemp;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
