//
//  UIView+Toast.m
//  toast
//
//  Created by 鲁成龙 on 16/8/19.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "UIView+Toast.h"

@implementation UIView (Toast)
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
    [self addSubview:lab];
    [self performSelector:@selector(removeToast:) withObject:lab afterDelay:2];
}

- (void)removeToast:(UIView *)view{
    [UIView animateWithDuration:1 animations:^{
        view.alpha = 0;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}
@end
