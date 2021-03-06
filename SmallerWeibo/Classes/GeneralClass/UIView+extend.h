//
//  UIView+extend.h
//  SmallerWeibo
//
//  Created by qingyun on 16/8/31.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    kLabPostionTypeTop,
    kLabPostionTypeCenter,
    kLabPostionTypeBottom
} LabPostionType;
@class UserModel;
@class StatusModel;
@interface UIView (extend)
- (void)toastWithString:(NSString *)str type:(LabPostionType)type;
- (UIViewController *)superViewController;
- (void)showReViewImgVCWithImageArr:(NSArray *)arr frameArr:(NSArray *)frameArr placeHoldImages:(NSArray *)placeHoldImages button:(UIButton *)btn;
- (void)showUserShowVcWithUserModel:(UserModel *)model button:(UIButton *)sender;
- (void)showFriendsVcWithType:(NSInteger)type userModel:(UserModel *)model;
- (void)showDetailStatusVcWithModel:(StatusModel *)model;
- (void)showUserShowVcWithUserName:(NSString *)name;
- (void)showTopicVcWithTopic:(NSString *)topic;
- (void)showNewStatusVcWithType:(NSInteger)type StatusId:(NSString *)statusId;
- (void)showSearchVc;
- (void)showWebVcWithUrl:(NSString *)url;
- (void)followUser:(NSString *)uid isFollowed:(BOOL)isFollowed success:(void (^)())success;
@end
