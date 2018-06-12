//
//  DDTabBarController.m
//  功能调研
//
//  Created by 郭春城 on 2018/5/7.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDTabBarController.h"
#import "DDTabBar.h"
#import "DDNavigationViewController.h"
#import "DDDTieViewController.h"
#import "DDFoundViewController.h"
#import "DDMailViewController.h"
#import "DDMineViewController.h"

@interface DDTabBarController ()

@end

@implementation DDTabBarController

- (instancetype)init
{
    if (self = [super init]) {
        [self customTabBarController];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)customTabBarController
{
    [self setValue:[[DDTabBar alloc] init] forKey:@"tabBar"];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xB721FF)} forState:UIControlStateSelected];
    
    NSMutableArray * vcArray = [NSMutableArray new];
    
    DDDTieViewController * DTie = [[DDDTieViewController alloc] init];
    DDNavigationViewController * na = [[DDNavigationViewController alloc] initWithRootViewController:DTie];
    UITabBarItem * tabBarItem1 = [self tabBarItemWithImageName:@"Dtie" selectName:@"DtieSelect" title:@"D帖"];
    [na setTabBarItem:tabBarItem1];
    [vcArray addObject:na];
    
    DDFoundViewController * found = [[DDFoundViewController alloc] init];
    DDNavigationViewController * foundNa = [[DDNavigationViewController alloc] initWithRootViewController:found];
    UITabBarItem * tabBarItem2 = [self tabBarItemWithImageName:@"found" selectName:@"foundselect" title:@"发现"];
    [foundNa setTabBarItem:tabBarItem2];
    [vcArray addObject:foundNa];
    
    DDMailViewController * mail = [[DDMailViewController alloc] init];
    DDNavigationViewController * mailNa = [[DDNavigationViewController alloc] initWithRootViewController:mail];
    UITabBarItem * tabBarItem3 = [self tabBarItemWithImageName:@"mail" selectName:@"mailSelect" title:@"邮筒"];
    tabBarItem3.imageInsets = UIEdgeInsetsMake(-4, 0, 0, 0);
    [mailNa setTabBarItem:tabBarItem3];
    [vcArray addObject:mailNa];
    
    DDMineViewController * mine = [[DDMineViewController alloc] init];
    DDNavigationViewController * mineNa = [[DDNavigationViewController alloc] initWithRootViewController:mine];
    UITabBarItem * tabBarItem4 = [self tabBarItemWithImageName:@"mine" selectName:@"mineSelect" title:@"我的"];
    [mineNa setTabBarItem:tabBarItem4];
    [vcArray addObject:mineNa];
    
    [self setViewControllers:vcArray];
}

- (UITabBarItem *)tabBarItemWithImageName:(NSString *)name selectName:(NSString *)selectName title:(NSString *)title
{
    UIImage * image = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage * selectImage = [[UIImage imageNamed:selectName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem * item = [[UITabBarItem alloc] initWithTitle:title image:image selectedImage:selectImage];
    if (KIsiPhoneX) {
        item.titlePositionAdjustment = UIOffsetMake(0, 2);
    }else{
        item.titlePositionAdjustment = UIOffsetMake(0, -2);
    }
    
    return item;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
