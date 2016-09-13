//
//  NewStatusViewController.h
//  SmallerWeibo
//
//  Created by qingyun on 16/9/3.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//
#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    kSearchTypeNormal,
    kSearchTypeMini
} SearchVcType;
@interface NewStatusViewController : UIViewController
@property (nonatomic,strong)UIViewController *fromVc;
@property (nonatomic,assign)CGPoint lastPoint;
@property (nonatomic,assign)SearchVcType type;
- (void)show;
@end
