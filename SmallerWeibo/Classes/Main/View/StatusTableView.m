//
//  StatusTableView.m
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/8.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "StatusTableView.h"
#import "StatusCell.h"
#import "HttpRequest.h"
#import "PrefixHeader.pch"
#import "StatusModel.h"
#import "NSString+Extend.h"
#import "SDWebImageDownloader.h"
@interface StatusTableView ()<UITableViewDelegate,UITableViewDataSource>

@end
NSInteger num = 0;
@implementation StatusTableView

- (NSArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSArray alloc]init];
    }
    return _dataArr;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self = [super initWithFrame:frame style:style]) {
        [self loadSomeSetting];
    }
    return self;
}

- (void)loadSomeSetting{
    self.delegate = self;
    self.dataSource = self;
    self.estimatedRowHeight = 100;
    self.backgroundColor = [UIColor whiteColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
}
#pragma make Tableview Delagate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    StatusCell *cell = [StatusCell statusCellWithTableView:tableView];
    StatusModel *model = self.dataArr[indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
