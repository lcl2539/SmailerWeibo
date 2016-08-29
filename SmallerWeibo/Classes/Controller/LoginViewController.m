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
#define baseUrl [NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?forcelogin=true&scope=all&client_id=%@&response_type=code&redirect_uri=%@",client_Id,redirect_Url]
#define tokenUrl(code) [NSString stringWithFormat:@"https://api.weibo.com/oauth2/access_token?client_id=%@&code=%@&redirect_uri=%@&client_secret=%@&grant_type=authorization_code",client_Id,code,redirect_Url,client_Secret]
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
    if ([request.URL.absoluteString containsString:@"code="]) {
        [webView loadHTMLString:@"\n请稍等" baseURL:nil];
        NSString *code = [request.URL.absoluteString componentsSeparatedByString:@"="].lastObject;
        AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
        manger.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:type_text, nil];
        NSString *url = tokenUrl(code);
        [manger POST:url parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            for (NSString *key in responseObject) {
                if ([key isEqualToString:@"access_token"] || [key isEqualToString:@"uid"]) {
                    [NSString writeUserInfoWithKey:key value:responseObject[key]];
                }
            }
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
