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
#import "DDFoundViewController.h"
#import "DDMineViewController.h"
#import "DDNavigationViewController.h"
#import "DDLGSideViewController.h"
#import <BaiduMapAPI_Base/BMKMapManager.h>
#import "DDLocationManager.h"
#import "UserManager.h"
#import "WeChatManager.h"
#import "DTieNewEditViewController.h"
#import "MBProgressHUD+DDHUD.h"
#import "DDTelLoginViewController.h"
#import "GuidePageView.h"
#import "SettingModel.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <WXApi.h>
#import "DDNotificationViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) BMKMapManager * mapManager;
@property (nonatomic, strong) NSDictionary * notificationUserInfo;

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
    
//    //个性化地图模板文件路径
//    NSString* path = [[NSBundle mainBundle] pathForResource:@"custom_config_0323" ofType:@""];
//    //设置个性化地图样式
//    [BMKMapView customMapStyle:path];
//    [BMKMapView enableCustomMapStyle:YES];//打开个性化地图
    
    [self createRootViewController];
    
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:DDUserDidLoginOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userShouldRelogin) name:@"UserShouldBackToRelogin" object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //开始定位
        [[DDLocationManager shareManager] startLocationService];
    });
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey]) {
        UILocalNotification * notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        [self handleNotificationWithUserInfo:notification.userInfo];
    }
    
    return YES;
}

- (void)userShouldRelogin
{
    [[UserManager shareManager] logoutAccount];
    [self createRootViewController];
    [MBProgressHUD showTextHUDWithText:@"登录状态已失效，请重新登录" inView:self.window];
}

//用户登出
- (void)userDidLogout
{
    [[UserManager shareManager] logoutAccount];
    [self createRootViewController];
}

- (void)createRootViewController
{
    SettingModel * model = [[SettingModel alloc] initWithType:SettingType_AlertTip];
    if ([WXApi isWXAppInstalled]) {
        LoginViewController * login = [[LoginViewController alloc] init];
        self.window.rootViewController = login;
        login.loginSucess = ^{
            
            DDFoundViewController * found = [[DDFoundViewController alloc] init];
            DDNavigationViewController * foundNa = [[DDNavigationViewController alloc] initWithRootViewController:found];
            DDMineViewController * mine = [[DDMineViewController alloc] init];
            DDLGSideViewController * side = [[DDLGSideViewController alloc] initWithRootViewController:foundNa leftViewController:mine rightViewController:nil];
            self.window.rootViewController = side;
            if (model.status) {
//                GuidePageView * guide = [[GuidePageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//                [[UIApplication sharedApplication].keyWindow addSubview:guide];
            }
            
            if ([WeChatManager shareManager].miniProgramPostID > 0) {
                [DDTool WXMiniProgramHandleWithPostID:[WeChatManager shareManager].miniProgramPostID];
            }
            if (self.notificationUserInfo) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self handleNotificationWithUserInfo:self.notificationUserInfo];
                });
            }
        };
    }else{
        DDTelLoginViewController * login = [[DDTelLoginViewController alloc] initWithDDTelLoginType:DDTelLoginPageType_Register];
        self.window.rootViewController = login;
        login.loginSucess = ^{
            
            DDFoundViewController * found = [[DDFoundViewController alloc] init];
            DDNavigationViewController * foundNa = [[DDNavigationViewController alloc] initWithRootViewController:found];
            DDMineViewController * mine = [[DDMineViewController alloc] init];
            DDLGSideViewController * side = [[DDLGSideViewController alloc] initWithRootViewController:foundNa leftViewController:mine rightViewController:nil];
            self.window.rootViewController = side;
            if (model.status) {
//                GuidePageView * guide = [[GuidePageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//                [[UIApplication sharedApplication].keyWindow addSubview:guide];
            }
            
            if ([WeChatManager shareManager].miniProgramPostID > 0) {
                [DDTool WXMiniProgramHandleWithPostID:[WeChatManager shareManager].miniProgramPostID];
            }
            if (self.notificationUserInfo) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self handleNotificationWithUserInfo:self.notificationUserInfo];
                });
            }
        };
    }
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

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    BOOL result = [WXApi handleOpenURL:url delegate:[WeChatManager shareManager]];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSDictionary * userInfo = notification.userInfo;
    [self handleNotificationWithUserInfo:userInfo];
}

- (void)handleNotificationWithUserInfo:(NSDictionary *)userInfo
{
    NSInteger remindId = [[userInfo objectForKey:@"remindId"] integerValue];
    DDLGSideViewController * lg = (DDLGSideViewController *)self.window.rootViewController;
    if ([lg isKindOfClass:[DDLGSideViewController class]]) {
        if (lg.leftViewShowing) {
            [lg hideLeftViewAnimated];
        }
        UINavigationController * na = (UINavigationController *)lg.rootViewController;
        if ([na.topViewController isKindOfClass:[DDNotificationViewController class]]) {
            [na popViewControllerAnimated:NO];
            DDNotificationViewController * notification = [[DDNotificationViewController alloc] initWithNotificationID:remindId];
            [na pushViewController:notification animated:YES];
        }else{
            DDNotificationViewController * notification = [[DDNotificationViewController alloc] initWithNotificationID:remindId];
            [na pushViewController:notification animated:YES];
        }
    }else{
        self.notificationUserInfo = userInfo;
    }
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
    
    if ([WeChatManager shareManager].isShare) {
        [WeChatManager shareManager].isShare = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:DTieDidCreateNewNotification object:nil];
    }
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DDUserDidLoginOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UserShouldBackToRelogin" object:nil];
}

@end
