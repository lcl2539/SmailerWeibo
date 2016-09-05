//
//  NewStatusViewController.m
//  SmallerWeibo
//
//  Created by qingyun on 16/9/3.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "NewStatusViewController.h"
#import <Masonry.h>
#import "FaceKeyBoard.h"
#import "TitleView.h"
#import "StatusTextView.h"
@interface NewStatusViewController ()
{
    __weak TitleView *_title;
    __weak StatusTextView *_statusText;
}
@end

@implementation NewStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadTitleView];
    [self loadTextView];
    [self loadSomeSetting];
}

- (void)loadSomeSetting{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(editChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(editChange:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)loadTitleView{
    TitleView *view = [TitleView titleViewWithTitle:@"发微博"];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo(40 + [UIApplication sharedApplication].statusBarFrame.size.height);
    }];
    _title = view;
}

- (void)loadTextView{
    StatusTextView *view = [StatusTextView statusTextView];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_title.mas_bottom);
        make.leading.trailing.equalTo(_title);
        make.height.mas_equalTo(self.view.frame.size.height - (40 + [UIApplication sharedApplication].statusBarFrame.size.height));
    }];
    _statusText = view;
}

- (void)editChange:(NSNotification *)noti{
    CGRect keyboardBounds = [noti.userInfo[@"UIKeyboardBoundsUserInfoKey"] CGRectValue];
    CGFloat height = ([noti.name isEqualToString:@"UIKeyboardWillShowNotification"]) ? self.view.frame.size.height - (40 + [UIApplication sharedApplication].statusBarFrame.size.height + keyboardBounds.size.height) : (self.view.frame.size.height - (40 + [UIApplication sharedApplication].statusBarFrame.size.height));
    [_statusText mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_title.mas_bottom);
        make.leading.trailing.equalTo(_title);
        make.height.mas_equalTo(height);
    }];
}

- (void)show{
    [self.fromVc.navigationController pushViewController:self animated:YES];
}


@end
