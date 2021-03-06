//
//  AppDelegate.m
//  Smaller Weibo
//
//  Created by 鲁成龙 on 16/8/4.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "PrefixHeader.pch"
#import "UIView+extend.h"
#import "LoginViewController.h"
#import "SendStatus.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    if (!Theme) {
        [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"ColorTheme"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    if (!userId) {
        self.window.rootViewController = [[LoginViewController alloc]init];
    }else{
        self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[[ViewController alloc]init]];
    }
    self.send = [SendStatus shareSendStatus];
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)loadMainViewController{
    ViewController *mainVc= [[ViewController alloc]init];
    [_window setRootViewController:[[UINavigationController alloc]initWithRootViewController:mainVc]];
    //[vc.view toastWithString:@"登陆成功" type:kLabPostionTypeBottom];
}
@end
