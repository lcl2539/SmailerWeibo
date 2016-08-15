//
//  LoginViewController.m
//  Smaller Weibo
//
//  Created by 鲁成龙 on 16/8/5.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "LoginViewController.h"
#import "PrefixHeader.pch"
#import <AFNetworking.h>
#import "ViewController.h"
#import "AppDelegate.h"
#import "HttpRequest.h"
#import "NSString+Extend.h"
#import "UserModel.h"
#pragma mark 宏定义
#define baseUrl [NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?client_id=%@&response_type=code&redirect_uri=%@&scope=all&display=mobile",client_Id,redirect_Url]
@interface LoginViewController ()<UIWebViewDelegate>
{
    __weak UIWebView *_web;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSomeSetting];
}

- (void)loadSomeSetting{
    self.view.backgroundColor = Color(255, 255, 255, 1);
    UIWebView *web = [[UIWebView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:web];
    web.delegate = self;
    _web = web;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:baseUrl]];
    [web loadRequest:request];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([request.URL.absoluteString containsString:@"code="]) {
        NSString *code = [[request.URL.absoluteString componentsSeparatedByString:@"="] lastObject];
        [self makeAccess_tokenWithCode:code];
        return NO;
    }
    return YES;
}

- (void)makeAccess_tokenWithCode:(NSString *)code{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", nil];
    __weak typeof(self) weakSelf = self;
    [manager POST:[NSString stringWithFormat:@"https://api.weibo.com/oauth2/access_token?client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=%@",client_Id,client_Secret,redirect_Url,code] parameters:nil progress:nil
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[NSUserDefaults standardUserDefaults]setObject:responseObject[@"access_token"] forKey:@"access_token"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [_web loadHTMLString:@"请稍等" baseURL:nil];
        [weakSelf loadUserID];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}


- (void)loadUserID{
    __weak typeof(self) weakSelf = self;
    NSString *uid = userId;
    if (!uid) {
        [HttpRequest httpRequestWithUrl:@"https://api.weibo.com/oauth2/get_token_info" parameter:nil success:^(id object){
            [NSString writeUserInfoWithKey:@"userId" value:object[@"uid"]];
            [NSString writeUserInfoWithKey:@"lastTime" value:@([object[@"expire_in"] integerValue] + (NSInteger)[[NSDate date]timeIntervalSince1970])];
            [weakSelf loadUserData];
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
        } isGET:NO type:type_text];
    }
}

- (void)loadUserData{
    __weak typeof(self) weakSelf = self;
    [HttpRequest httpRequestWithUrl:@"https://api.weibo.com/2/users/show.json" parameter:@{@"uid":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]} success:^(id object) {
        [UserModel myInfo:object];
        [weakSelf successForAccess_Token];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    } isGET:YES type:type_json];
}

- (void)successForAccess_Token{
    AppDelegate *appDeleagte = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDeleagte loadMainViewController];
}
@end
