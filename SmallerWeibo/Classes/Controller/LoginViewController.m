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
#define gsidUrl [NSString stringWithFormat:@"http://api.weibo.cn/2/account/login?access_token=%@&source=%d",self.token,3]

@interface LoginViewController ()<UIWebViewDelegate>
{
    __weak UIWebView *_web;
}
@property (nonatomic,strong)NSMutableArray *allUser;
@property (nonatomic,strong)NSMutableDictionary *user;
@property (nonatomic,copy)NSString *token;
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    __weak typeof(self) weakSelf = self;
    if ([request.URL.absoluteString containsString:@"access_token"]) {
        [webView loadHTMLString:@"\n请稍等" baseURL:nil];
        NSArray *arr = [[request.URL.absoluteString componentsSeparatedByString:@"?"].lastObject componentsSeparatedByString:@"&"];
        for (NSString *str in arr) {
            if ([str containsString:@"access"] || [str containsString:@"uid"]) {
                NSArray *arr = [str componentsSeparatedByString:@"="];
                [self.user setObject:arr.lastObject forKey:arr.firstObject];
                if ([str containsString:@"access"]) {
                    self.token = arr.lastObject;
                }
            }
        }
        AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
        manger.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:type_json, nil];
        [manger POST:gsidUrl parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [weakSelf.user setObject:responseObject[@"gsid"] forKey:@"gsid"];
            for (NSDictionary *user in weakSelf.allUser) {
                if ([user[@"uid"] isEqualToString:self.user[@"uid"]]) {
                    weakSelf.isHave = YES;
                }
            }
            if (!weakSelf.isHave) {
                [weakSelf.allUser addObject:weakSelf.user];
            }
            [weakSelf successForAccess_Token];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
        return NO;
    }
    
    return YES;
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
