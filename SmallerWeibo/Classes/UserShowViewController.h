//
//  UserShowViewController.h
//  SmallerWeibo
//
//  Created by qingyun on 16/8/30.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserModel;
@interface UserShowViewController : UIViewController
@property (nonatomic,strong)UserModel *model;
@property (nonatomic,strong)UIView *placeHoldView;
@property (nonatomic,strong)UIViewController *fromVc;
- (void)show;
@end
