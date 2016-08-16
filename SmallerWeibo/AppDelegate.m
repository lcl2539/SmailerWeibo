//
//  AppDelegate.m
//  Smaller Weibo
//
//  Created by 鲁成龙 on 16/8/4.
//  Copyright © 2016年 鲁成龙. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <WeiboSDK.h>
#import "PrefixHeader.pch"
@interface AppDelegate ()<WeiboSDKDelegate>

@end

@implementation AppDelegate

-(void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    
}

-(void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    WBAuthorizeResponse *userInfo = (WBAuthorizeResponse *)response;
    [[NSUserDefaults standardUserDefaults]setObject:userInfo.accessToken forKey:@"access_token"];
    [[NSUserDefaults standardUserDefaults]setObject:userInfo.userID forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults]setObject:userInfo.expirationDate forKey:@"expirationDate"];
    [[NSUserDefaults standardUserDefaults]setObject:userInfo.refreshToken forKey:@"refreshToken"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self loadMainViewController];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[[ViewController alloc]init]];
    [self.window makeKeyAndVisible];
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:client_Id];
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
    [_window setRootViewController:[[UINavigationController alloc]initWithRootViewController:[[ViewController alloc]init]]];
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [WeiboSDK handleOpenURL:url delegate:self];
}
@end
