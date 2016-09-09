//
//  ThemeViewController.m
//  SmallerWeibo
//
//  Created by qingyun on 2016/9/9.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//
#import "ThemeViewController.h"
#import "NSString+Extend.h"
#import "AppDelegate.h"
@interface ThemeViewController ()
{
    __weak UILabel *_title;
    __weak IBOutlet UIView *_backView;
}
@property (nonatomic,copy)NSArray *colors;
@property (nonatomic,assign)NSInteger currentColor;
@end

@implementation ThemeViewController

- (NSArray *)colors{
    if (!_colors) {
        _colors = @[[UIColor flatSkyBlueColor],
                     [UIColor flatPinkColor],
                     [UIColor flatWatermelonColor],
                     [UIColor flatOrangeColor],
                     [UIColor flatGreenColorDark],
                     [UIColor flatMintColorDark],
                     [UIColor flatTealColor],
                     [UIColor flatMagentaColor],
                     [UIColor flatBlackColor]];
    }
    return _colors;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _backView.layer.cornerRadius = 3;
    _backView.clipsToBounds = YES;
    self.currentColor = [[[NSUserDefaults standardUserDefaults]objectForKey:@"ColorTheme"] integerValue];
    for (UIView *view in _backView.subviews) {
        if ([view isKindOfClass:[UIButton class]] && view.tag == self.currentColor) {
            ((UIButton *)view).selected = YES;
        }
    }
}

- (IBAction)didChooseColor:(UIButton *)sender {
    for (UIView *view in _backView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            ((UIButton *)view).selected = NO;
        }
    }
    Theme *theme = [Theme shareColor];
    theme.color = self.colors[sender.tag];
    sender.selected = YES;
    [NSString writeUserInfoWithKey:@"ColorTheme" value:[NSString stringWithFormat:@"%ld",sender.tag]];
    if (sender.tag != self.currentColor) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTheme" object:nil];
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate loadMainViewController];
    }
}



- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    if (!CGRectContainsPoint(_backView.frame, point)) {
        [UIView animateWithDuration:0.25 animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
    }
}
@end
