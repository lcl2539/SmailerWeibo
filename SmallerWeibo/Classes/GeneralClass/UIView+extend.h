//
//  UIView+extend.h
//  SmallerWeibo
//
//  Created by qingyun on 16/8/31.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserModel;
@class StatusModel;
@interface UIView (extend)
- (void)toastWithString:(NSString *)str;
- (UIViewController *)superViewController;
- (void)showReViewImgVCWithImageArr:(NSArray *)arr frameArr:(NSArray *)frameArr button:(UIButton *)btn;
- (void)showUserShowVcWithUserModel:(UserModel *)model button:(UIButton *)sender;
- (void)showFriendsVcWithType:(NSInteger)type userModel:(UserModel *)model;
- (void)showDetailStatusVcWithModel:(StatusModel *)model;
- (void)showUserShowVcWithUserName:(NSString *)name;
- (void)showTopicVcWithTopic:(NSString *)topic;
- (void)showNewStatusVc;
@end
