//
//  FansViewController.h
//  SmallerWeibo
//
//  Created by qingyun on 16/8/29.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserModel;
typedef enum : NSUInteger {
    kFriendsVcFans,
    kFriendsVcFollows
} kFriendsType;
@interface FriendsViewController : UIViewController
@property (nonatomic,assign)kFriendsType type;
@property (nonatomic,strong)UserModel *model;
@property (nonatomic,strong)UIViewController *fromVc;
- (void)show;
@end
