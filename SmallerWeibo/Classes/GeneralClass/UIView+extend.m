//
//  UIView+extend.m
//  SmallerWeibo
//
//  Created by qingyun on 16/8/31.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "UIView+extend.h"
#import "UserModel.h"
#import "StatusModel.h"
#import "ReviewImgController.h"
#import "UserShowViewController.h"
#import "FriendsViewController.h"
#import "DetailStatusViewController.h"
#import "ReViewImgAnimation.h"
@implementation UIView (extend)
- (void)toastWithString:(NSString *)str{
    UILabel *lab = [[UILabel alloc]init];
    UIFont *font = [UIFont systemFontOfSize:15];
    CGRect frame = [str boundingRectWithSize:self.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil];
    frame.size.width += 40;
    frame.size.height +=10;
    frame.origin.x = ([UIScreen mainScreen].bounds.size.width - frame.size.width)/2;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - 80;
    lab.frame = frame;
    lab.text = str;
    lab.layer.cornerRadius = frame.size.height/2;
    lab.clipsToBounds = YES;
    lab.backgroundColor = [UIColor blackColor];
    lab.textColor = [UIColor whiteColor];
    lab.alpha = 0.8;
    lab.textAlignment = NSTextAlignmentCenter;
    UIWindow *keyWindow = [[UIApplication sharedApplication]keyWindow];
    [keyWindow addSubview:lab];
    [keyWindow bringSubviewToFront:lab];
    [self performSelector:@selector(removeToast:) withObject:lab afterDelay:1];
}

- (void)removeToast:(UIView *)view{
    [UIView animateWithDuration:1 animations:^{
        view.alpha = 0;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}

- (UIViewController *)superViewController{
    UIResponder *responder = self;
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    return nil;
}

- (void)showReViewImgVCWithImageArr:(NSArray *)arr frameArr:(NSArray *)frameArr button:(UIButton *)btn {
    ReviewImgController *vc = [[ReviewImgController alloc]init];
    vc.picArr = arr;
    vc.showWhichImg = btn.tag;
    UIImageView *view = [[UIImageView alloc]init];
    view.image = btn.currentBackgroundImage;
    view.frame = [frameArr[btn.tag] CGRectValue];
    vc.lastFrame = [frameArr[btn.tag] CGRectValue];
    vc.frameArr = frameArr;
    vc.placeHoldimageView = view;
    vc.fromVc = [self superViewController];
    vc.fromVc.navigationController.delegate = vc;
    vc.navigationController.delegate = vc;
    [vc show];
}

- (void)showUserShowVcWithUserModel:(UserModel *)model button:(UIButton *)sender{
    if ([[self superViewController] isKindOfClass:[UserShowViewController class]])return;
    UserShowViewController *vc = [[UserShowViewController alloc]init];
    vc.model = model;
    UIImageView *view = [[UIImageView alloc]init];
    view.frame = [self.window convertRect:sender.frame fromView:sender.superview];
    view.layer.cornerRadius = view.frame.size.width/2;
    view.clipsToBounds = YES;
    view.image = sender.currentImage;
    vc.placeHoldView = view;
    vc.fromVc = [self superViewController];
    if (vc.placeHoldView) {
        vc.fromVc.navigationController.delegate = vc;
        vc.navigationController.delegate = vc;
    }
    [vc show];
}

- (void)showFriendsVcWithType:(NSInteger)type userModel:(UserModel *)model{
    FriendsViewController *vc = [[FriendsViewController alloc]init];
    vc.type = type;
    vc.model = model;
    vc.fromVc = [self superViewController];
    vc.fromVc.navigationController.delegate = nil;
    [vc show];
}

- (void)showDetailStatusVcWithModel:(StatusModel *)model{
    if ([[self superViewController] isKindOfClass:[DetailStatusViewController class]])return;
    DetailStatusViewController *vc = [[DetailStatusViewController alloc]init];
    vc.statusModel = model;
    [self superViewController].navigationController.delegate = nil;
    [[self superViewController].navigationController pushViewController:vc animated:YES];
}

@end
