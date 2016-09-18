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
    if (self.type != kNewStatusTypeNormal) {
        [_title title:(self.type == kNewStatusTypeRepate) ? @"转发微博" : @"评论微博"];
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
    __weak typeof(UIView) *weakKeyWindows = [UIApplication sharedApplication].keyWindow;
    if (self.type != kNewStatusTypeNormal) {
        [HttpRequest repateAndCommentsWithstatusId:self.statusId status:_statusText.status success:^(id object) {
            [weakKeyWindows toastWithString:(self.type == kNewStatusTypeComment) ? @"评论成功" : @"转发成功" type:kLabPostionTypeBottom];
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
        } isComment:self.type == kNewStatusTypeComment];
    }else{
        SendStatus *send = [SendStatus shareSendStatus];
        NewStatusModel *model = [NewStatusModel newStatusMoldeWithStatus:_statusText.status imgArr:_statusText.imgArr];
        [[send mutableArrayValueForKey:@"status"] addObject:model];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)show{
    [self.fromVc.navigationController pushViewController:self animated:YES];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
