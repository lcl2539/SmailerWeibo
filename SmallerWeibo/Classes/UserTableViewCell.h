//
//  UserTableViewCell.h
//  SmallerWeibo
//
//  Created by qingyun on 16/8/29.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    kUserFriendsFollowing,
    kUserFriendsFollowMe,
    kUserFriendsAll
} UserFriendsType;
@class UserModel;
@interface UserTableViewCell : UITableViewCell
@property (nonatomic,strong)UserModel *model;
@property (nonatomic,assign)UserFriendsType followType;
- (void)showUser;
+ (instancetype)userCellWithTableView:(UITableView *)tableview;
@end
