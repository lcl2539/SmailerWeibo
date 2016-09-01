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

#define baseUrl [NSString stringWithFormat:@"https://open.weibo.cn/oauth2/authorize?client_id=%@&redirect_uri=%@&scope=all&response_type=code&display=mobile&packagename=com.eico.weico&key_hash=1e6e33db08f9192306c4afa0a61ad56c",client_Id,redirect_Url]
#define gsidUrl [NSString stringWithFormat:@"http://api.weibo.cn/2/account/login?access_token=%@&source=%d",myToken,3]

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
    __weak typeof(self) weakSelf = self;
    if ([request.URL.absoluteString containsString:@"access_token"]) {
        [webView loadHTMLString:@"\n请稍等" baseURL:nil];
        NSArray *arr = [[request.URL.absoluteString componentsSeparatedByString:@"?"].lastObject componentsSeparatedByString:@"&"];
        for (NSString *str in arr) {
            if ([str containsString:@"access"] || [str containsString:@"uid"]) {
                NSArray *arr = [str componentsSeparatedByString:@"="];
                [NSString writeUserInfoWithKey:arr.firstObject value:arr.lastObject];
            }
        }
        AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
        manger.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:type_json, nil];
        [manger POST:gsidUrl parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [NSString writeUserInfoWithKey:@"gsid" value:responseObject[@"gsid"]];
            [weakSelf successForAccess_Token];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
        return NO;
    }
    return YES;
}

- (void)successForAccess_Token{
    AppDelegate *appDeleagte = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDeleagte loadMainViewController];
}
@end
