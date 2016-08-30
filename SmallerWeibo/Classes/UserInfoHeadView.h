//
//  UserInfoHeadView.h
//  SmallerWeibo
//
//  Created by qingyun on 16/8/29.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserModel;
@protocol UserHeadDelegate <NSObject>
- (void)back;
@end
@interface UserInfoHeadView : UIView
@property (nonatomic,strong)UIImage *userImage;
@property (nonatomic,strong)UserModel *model;
@property (nonatomic,assign)CGRect userImgFrame;
@property (nonatomic,copy)void (^downloadFinish)();
@property (nonatomic,weak)id <UserHeadDelegate> delegate;
- (void)userImgShow;
- (void)changeAlpha:(CGFloat)alpha;
+ (instancetype)headView;
@end
