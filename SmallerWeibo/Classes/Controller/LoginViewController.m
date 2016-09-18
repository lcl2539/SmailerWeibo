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
#import "UIView+extend.h"
#define baseUrl [NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?forcelogin=true&scope=all&client_id=%@&response_type=code&redirect_uri=%@",weiboXClient_Id,weiboXredirect_Url]
#define weicoUrl [NSString stringWithFormat:@"https://open.weibo.cn/oauth2/authorize?client_id=%@&redirect_uri=%@&scope=all&response_type=code&display=mobile&packagename=com.eico.weico&key_hash=1e6e33db08f9192306c4afa0a61ad56c",client_Id,redirect_Url]
@interface LoginViewController ()<UIWebViewDelegate>
{
    __weak UIWebView *_web;
}
@property (nonatomic,strong)NSMutableArray *allUser;
@property (nonatomic,strong)NSMutableDictionary *user;
@property (nonatomic,assign)BOOL isHave;
@end

@implementation LoginViewController

- (NSMutableArray *)allUser{
    if (!_allUser) {
        _allUser = [[NSUserDefaults standardUserDefaults]objectForKey:@"AllUser"] ? [[[NSUserDefaults standardUserDefaults]objectForKey:@"AllUser"] mutableCopy] : [[NSMutableArray alloc]init];;
    }
    return _allUser;
}

- (NSMutableDictionary *)user{
    if (!_user) {
        _user = [[NSMutableDictionary alloc]init];
    }
    return _user;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSomeSetting];
}

- (void)loadSomeSetting{
    self.view.backgroundColor =[UIColor whiteColor];
    if (self.navigationController) {
        [self loadNavbar];
    }
    UIWebView *web = [[UIWebView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:web];
    web.delegate = self;
    _web = web;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:weicoUrl]];
    [web loadRequest:request];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.allUser.count == 0){
        [self.view toastWithString:@"首次使用，请登录！" type:kLabPostionTypeBottom];
    }
}

- (void)loadNavbar{
    [self.navigationController setNavigationBarHidden:NO];
    self.title = @"添加账号";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:0 target:self action:@selector(back)];
    btn.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = btn;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([request.URL.absoluteString containsString:weiboXredirect_Url])return YES;
    if ([request.URL.absoluteString containsString:@"access_token"]) {
        [webView loadHTMLString:@"\n请稍等" baseURL:nil];
        NSArray *arr = [[request.URL.absoluteString componentsSeparatedByString:@"?"].lastObject componentsSeparatedByString:@"&"];
        for (NSString *str in arr) {
            if ([str containsString:@"access"] || [str containsString:@"uid"]) {
                NSArray *arr = [str componentsSeparatedByString:@"="];
                [self.user setObject:arr.lastObject forKey:arr.firstObject];
                if ([str containsString:@"access"]) {
                    for ( NSDictionary *dict in self.allUser) {
                        if ([dict[@"uid"] isEqualToString:arr.lastObject]) {
                            self.isHave = YES;
                        }
                    }
                }
            }
        }
        [_web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:baseUrl]]];
        [self.view toastWithString:@"请再次登录以获取高级授权" type:kLabPostionTypeBottom];
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *jsToGetHTMLSource = @"document.getElementsByTagName('html')[0].innerHTML";
    NSString *responseObject = [webView stringByEvaluatingJavaScriptFromString:jsToGetHTMLSource];
    if ([responseObject containsString:@"验证成功"]) {
        NSRange left = [responseObject rangeOfString:@"done?"];
        NSRange right = [responseObject rangeOfString:@"setTime"];
        NSRange range = NSMakeRange(left.location + left.length,right.location - left.location + left.length -right.length -6);
        NSArray *Temp = [[responseObject substringWithRange:range]componentsSeparatedByString:@"&"];
        for (NSString *str in Temp) {
            if ([str containsString:@"access"]) {
                NSArray *arr = [str componentsSeparatedByString:@"="];
                [self.user setObject:arr.lastObject forKey:@"access_token_weiboX"];
            }
        }
        [self.allUser addObject:self.user];
        [self.view toastWithString:@"登陆成功" type:kLabPostionTypeBottom];
        [self successForAccess_Token];
        [_web removeFromSuperview];
    }
}

- (void)back{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)successForAccess_Token{
    [NSString writeUserInfoWithKey:@"AllUser" value:self.allUser];
    if (self.addUserFinish) {
        if (!self.isHave) {
            self.addUserFinish(self.user);
        }else{
            self.addUserFinish(nil);
        }
    }else{
        [NSString writeUserInfoWithKey:@"CurrentUser" value:self.user];
        AppDelegate *appDeleagte = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDeleagte loadMainViewController];
    }
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
