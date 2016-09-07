//
//  PresentAnimation.m
//  SmallerWeibo
//
//  Created by qingyun on 16/8/25.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "ReViewImgAnimation.h"
@implementation ReViewImgAnimation

+ (instancetype)shareAnimation{
    static ReViewImgAnimation *animation;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        animation = [[self alloc]init];
    });
    return animation;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:fromVc.view];
    [containerView addSubview:toVc.view];
    toVc.view.frame = fromVc.view.frame;
    if (self.type == kPushAnimationType) {
        toVc.view.backgroundColor = [UIColor clearColor];
        [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext] delay:0 options:2 animations:^{
            toVc.view.backgroundColor = [UIColor whiteColor];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:finished];
        }];
    }else{
        [containerView bringSubviewToFront:fromVc.view];
        [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext] delay:0 options:0 animations:^{
            fromVc.view.backgroundColor = [UIColor clearColor];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:finished];
        }];
    }
}

@end
