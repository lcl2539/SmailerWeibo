//
//  WebViewController.m
//  SmallerWeibo
//
//  Created by qingyun on 2016/9/14.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "WebViewController.h"
#import "TitleView.h"
#import <Masonry.h>

@interface WebViewController ()<UIWebViewDelegate>
{
    __weak TitleView *_title;
    __weak UIWebView *_web;
}
@end

@implementation WebViewController

- (void)setUrl:(NSString *)url{
    _url = url;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [_web loadRequest:request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSomeSetting];
    [self loadTitleView];
    [self loadWebView];
}

- (void)loadSomeSetting{
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)loadTitleView{
    TitleView *view = [TitleView titleViewWithTitle:@"查看网页"];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo(40 + [UIApplication sharedApplication].statusBarFrame.size.height);
    }];
    _title = view;
}

- (void)loadWebView{
    UIWebView *view = [[UIWebView alloc]init];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_title.mas_bottom);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
    _web.delegate = self;
    _web = view;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
}

@end
