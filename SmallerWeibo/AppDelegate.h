//
//  AppDelegate.h
//  Smaller Weibo
//
//  Created by 鲁成龙 on 16/8/4.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SendStatus;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SendStatus *send;
- (void)loadMainViewController;

@end
