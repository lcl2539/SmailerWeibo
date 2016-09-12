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
#define baseUrl [NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?forcelogin=true&scope=all&client_id=%@&response_type=code&redirect_uri=%@",client_Id,redirect_Url]

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
    self.view.backgroundColor = Color(255, 255, 255, 1);
    if (self.navigationController) {
        [self loadNavbar];
    }
    UIWebView *web = [[UIWebView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:web];
    web.delegate = self;
    _web = web;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:baseUrl]];
    [web loadRequest:request];
}

- (void)loadNavbar{
    [self.navigationController setNavigationBarHidden:NO];
    self.title = @"添加账号";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:0 target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = btn;
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
        [self.allUser addObject:self.user];
        [self.view toastWithString:@"登陆成功" type:kLabPostionTypeBottom];
        [self successForAccess_Token];
    }
}

- (void)back{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)successForAccess_Token{
    [NSString writeUserInfoWithKey:@"AllUser" value:self.allUser];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
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
}
@end
