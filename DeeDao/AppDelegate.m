//
//  AppDelegate.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "DDTool.h"
#import "WeChatManager.h"
#import "DDTabBarController.h"
#import <BaiduMapAPI_Base/BMKMapManager.h>
#import "DDLocationManager.h"
#import "UserManager.h"

@interface AppDelegate ()

@property (nonatomic, strong) BMKMapManager * mapManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [DDTool configApplication];
    
    //百度地图
    self.mapManager = [[BMKMapManager alloc] init];
    BOOL temp = [self.mapManager start:BMK_KEY generalDelegate:nil];
    if (temp) {
        NSLog(@"百度地图调起成功");
    }else{
        NSLog(@"百度地图调起失败");
    }
    temp = [BMKMapManager setCoordinateTypeUsedInBaiduMapSDK:BMK_COORDTYPE_COMMON];
    
    //开始定位
    [[DDLocationManager shareManager] performSelector:@selector(startLocationService) withObject:nil afterDelay:.5f];
    
    [self createRootViewController];
    
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:DDUserDidLoginOutNotification object:nil];
    
    return YES;
}

//用户登出
- (void)userDidLogout
{
    [[UserManager shareManager] logoutAccount];
    [self createRootViewController];
}

- (void)createRootViewController
{
    LoginViewController * login = [[LoginViewController alloc] init];
    self.window.rootViewController = login;
    login.loginSucess = ^{
        
        DDTabBarController * tab = [[DDTabBarController alloc] init];
        self.window.rootViewController = tab;
        
    };
}

// 支持所有iOS系统
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result = [WXApi handleOpenURL:url delegate:[WeChatManager shareManager]];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL result = [WXApi handleOpenURL:url delegate:[WeChatManager shareManager]];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
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
