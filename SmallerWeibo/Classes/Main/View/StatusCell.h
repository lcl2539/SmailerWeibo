//
//  StatusCell.h
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/8.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface StatusCell : UITableViewCell
@property (nonatomic,strong)id model;
+ (instancetype)statusCellWithTableView:(UITableView *)tableView;
@end
