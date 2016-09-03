//
//  NewStatusViewController.h
//  SmallerWeibo
//
//  Created by qingyun on 16/9/3.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewStatusViewController : UIViewController
@property (nonatomic,strong)UIViewController *fromVc;
@property (nonatomic,assign)CGPoint lastPoint;
- (void)show;
@end
