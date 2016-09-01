//
//  CommentsTableViewCell.h
//  SmallerWeibo
//
//  Created by qingyun on 16/8/25.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>
@class commentsModel;
@interface CommentsTableViewCell : UITableViewCell
@property (nonatomic,strong)commentsModel *model;
+ (instancetype)commentsCellWithTableview:(UITableView *)tabelview;
@end
