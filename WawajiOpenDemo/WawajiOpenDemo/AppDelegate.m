//
//  AppDelegate.m
//  WawajiOpenDemo
//
//  Created by mikey on 2018/8/24.
//  Copyright © 2018年 mikey. All rights reserved.
//

#import "AppDelegate.h"

#import <XHWaWaJi/XHWaWaJi.h>

const int TENCLOUDAPPID = 0;
const int TENCLOUDACCOUNTTYPE = 0;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // ****************************************************
    // 腾讯云互动直播不支持模拟器调试视频，务必使用真机调试
    // ****************************************************
    
    // 初始化腾讯云互动直播sdk
    [[XHLiveManager sharedManager] initSdk:TENCLOUDAPPID accountType:TENCLOUDACCOUNTTYPE];
    [[XHLiveManager sharedManager] disableLogPrint];
    
    // 登录校验腾讯云互动直播用户，登录成功的用户才可以加入视频房间
    NSString *UserId = @"";
    NSString *UserSig = @"";
    [[XHLiveManager sharedManager] loginWithUserId:UserId sig:UserSig success:^{
        NSLog(@"互动直播用户登录成功");
    } failure:^(NSString *module, int errId, NSString *errMsg) {
        NSLog(@"互动直播用户登录失败");
    }];
    
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


@end
