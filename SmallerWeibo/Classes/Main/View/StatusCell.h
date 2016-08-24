//
//  StatusCell.h
//  SmallerWeibo
//
//  Created by 鲁成龙 on 16/8/8.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>
@class StatusModel;
@protocol StatusCellDelegate <NSObject>

- (void)showImgWithArr:(NSArray *)imgArr index:(NSInteger)index;
- (void)cellBtnActionWithIndex:(NSInteger)index withStatusId:(NSInteger)statusId;

@end
@interface StatusCell : UITableViewCell
@property (nonatomic,strong)id model;
@property (nonatomic,weak)id <StatusCellDelegate> delegate;
+ (instancetype)statusCellWithTableView:(UITableView *)tableView;
@end
