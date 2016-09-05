//
//  TitleView.m
//  SmallerWeibo
//
//  Created by qingyun on 16/9/1.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "TitleView.h"
#import "UIView+extend.h"
@interface TitleView ()
{
    __weak IBOutlet UILabel *_title;
}
@end
@implementation TitleView

+ (instancetype)titleViewWithTitle:(NSString *)title{
    TitleView *view = [[NSBundle mainBundle]loadNibNamed:@"TitleView" owner:nil options:nil].firstObject;
    view->_title.text = title;
    return view;
}

- (void)title:(NSString *)title{
    _title.text = title;
}

- (IBAction)back:(id)sender {
    UIViewController *superVc = [self superViewController];
    Class detailStatusClass = NSClassFromString(@"DetailStatusViewController");
    if ([superVc isKindOfClass:[detailStatusClass class]]) {
        superVc.navigationController.delegate = nil;
    }
    [superVc.navigationController popViewControllerAnimated:YES];
}
@end
