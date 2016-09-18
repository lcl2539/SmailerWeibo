//
//  AboutViewController.m
//  SmallerWeibo
//
//  Created by qingyun on 2016/9/18.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
