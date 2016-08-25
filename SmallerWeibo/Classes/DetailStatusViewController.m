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

@interface DetailStatusViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak UITableView *_commentsTabview;
}
@property (nonatomic,copy)NSArray *data;
@end

@implementation DetailStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)loadCommentsTableview{
    UITableView *tab = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:tab];
    _commentsTabview = tab;
    _commentsTabview.delegate = self;
    _commentsTabview.dataSource = self;
    _commentsTabview.estimatedRowHeight = 100;
    _commentsTabview.sectionHeaderHeight = 1;
    _commentsTabview.sectionFooterHeight = 5;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        StatusCell *cell = [StatusCell statusCellWithTableView:tableView];
        //cell.delegate = self;
        cell.model = self.Statusmodel;
        return cell;
    }else{
        
    }
    return nil;
}

@end
