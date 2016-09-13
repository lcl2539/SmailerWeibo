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
#import "HttpRequest.h"
#import "UIView+extend.h"
#import "SendStatus.h"
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_statusText beginEdit];
}

- (void)loadSomeSetting{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(editChange:) name:UIKeyboardDidShowNotification object:nil];
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
    __weak typeof(self) weakSelf = self;
    view.sendStatus = ^(){
        [weakSelf sendStatus];
    };
    _statusText = view;
    if (self.type == kSearchTypeMini) {
        [_statusText changeTypeToMini];
    }
}

- (void)editChange:(NSNotification *)noti{
    CGRect keyboardBounds = [noti.userInfo[@"UIKeyboardBoundsUserInfoKey"] CGRectValue];
    CGFloat height = ([noti.name isEqualToString:@"UIKeyboardDidShowNotification"]) ? self.view.frame.size.height - (40 + [UIApplication sharedApplication].statusBarFrame.size.height + keyboardBounds.size.height) : (self.view.frame.size.height - (40 + [UIApplication sharedApplication].statusBarFrame.size.height));
    [_statusText mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_title.mas_bottom);
        make.leading.trailing.equalTo(_title);
        make.height.mas_equalTo(height);
    }];
}

- (void)sendStatus{
    SendStatus *send = [SendStatus shareSendStatus];
    NewStatusModel *model = [NewStatusModel newStatusMoldeWithStatus:_statusText.status imgArr:_statusText.imgArr];
    [[send mutableArrayValueForKey:@"status"] addObject:model];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)show{
    [self.fromVc.navigationController pushViewController:self animated:YES];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
