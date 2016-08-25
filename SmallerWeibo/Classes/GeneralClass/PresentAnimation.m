//
//  PresentAnimation.m
//  SmallerWeibo
//
//  Created by qingyun on 16/8/25.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "PresentAnimation.h"

@implementation PresentAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.1;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:fromVc.view];
    [containerView addSubview:toVc.view];
    toVc.view.alpha = 0;
    [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext] delay:0 options:0 animations:^{
        toVc.view.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

@end
