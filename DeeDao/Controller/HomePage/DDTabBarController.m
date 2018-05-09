//
//  DDTabBarController.m
//  功能调研
//
//  Created by 郭春城 on 2018/5/7.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDTabBarController.h"
#import "DDTabBar.h"

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
    NSMutableArray * vcArray = [NSMutableArray new];
    for (NSInteger i = 0; i < 4; i++) {
        UIViewController * vc = [[UIViewController alloc] init];
        UITabBarItem * tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:i];
        [vc setTabBarItem:tabBarItem];
        [vcArray addObject:vc];
    }
    
    [self setViewControllers:vcArray];
    
    [self setValue:[[DDTabBar alloc] init] forKey:@"tabBar"];
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
