//
//  NewStatusViewController.h
//  SmallerWeibo
//
//  Created by qingyun on 16/9/3.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//
#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    kNewStatusTypeNormal,
    kNewStatusTypeRepate,
    kNewStatusTypeComment
} NewStatusVcType;
@interface NewStatusViewController : UIViewController
@property (nonatomic,strong)UIViewController *fromVc;
@property (nonatomic,assign)CGPoint lastPoint;
@property (nonatomic,assign)NewStatusVcType type;
@property (nonatomic,copy)NSString *statusId;
- (void)show;
@end
