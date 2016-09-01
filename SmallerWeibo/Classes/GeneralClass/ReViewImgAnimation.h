//
//  PresentAnimation.h
//  SmallerWeibo
//
//  Created by qingyun on 16/8/25.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef enum : NSInteger {
    kPresentAnimationType,
    kDismissAnimationType
} AnimationType;
@interface ReViewImgAnimation : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic,assign)AnimationType type;
@end
