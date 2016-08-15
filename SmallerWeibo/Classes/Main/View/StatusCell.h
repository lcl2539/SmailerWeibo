//
//  StatusCell.h
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/8.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>
@class StatusModel;
@interface StatusCell : UITableViewCell
@property (nonatomic,strong)StatusModel *model;
+ (instancetype)statusCellWithTableView:(UITableView *)tableView;
@end
