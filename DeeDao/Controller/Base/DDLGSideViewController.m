//
//  DDLGSideViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/15.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDLGSideViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "DDFoundViewController.h"

@interface DDLGSideViewController ()

@end

@implementation DDLGSideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.leftViewPresentationStyle = LGSideMenuPresentationStyleSlideAbove;
    
    CGFloat width = kMainBoundsHeight > kMainBoundsWidth ? kMainBoundsWidth : kMainBoundsHeight;
    
    self.leftViewWidth = width / 3 * 2;
    self.leftViewStatusBarStyle = UIStatusBarStyleLightContent;
    self.leftViewSwipeGestureEnabled = NO;
    self.rootViewLayerShadowRadius = 0.f;
}

-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (motion == UIEventSubtypeMotionShake) {
        UINavigationController * na = (UINavigationController *)self.rootViewController;
        if ([na.topViewController isKindOfClass:[DDFoundViewController class]]) {
            NSLog(@"手机开始摇动");
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);//让手机震动
            DDFoundViewController * vc = (DDFoundViewController *)na.topViewController;
            [vc motionHandle];
        }
    }
}

- (void) motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    //摇动取消
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    
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
