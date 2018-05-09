//
//  LoginViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "LoginViewController.h"
#import <UMShare/UMShare.h>
#import "DDViewFactoryTool.h"

@interface LoginViewController ()

@property (nonatomic, strong) UIButton * loginButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createViews];
}

- (void)createViews
{
    UIImageView * bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    NSString * bgImagePath = [[NSBundle mainBundle] pathForResource:@"BG" ofType:@"png"];
    UIImage * image;
    if (bgImagePath) {
        image = [UIImage imageWithContentsOfFile:bgImagePath];
    }else{
        image = [UIImage imageNamed:@"BG.png"];
    }
    
    [bgImageView setImage:image];
    
    [self.view addSubview:bgImageView];
    
    CGFloat widthScale = DpToPxScale * kMainBoundsWidth / 414.f;
    CGFloat heightScale = DpToPxScale * kMainBoundsHeight / 736.f;
    self.loginButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(20 + widthScale, kMainBoundsHeight - 204 * heightScale, 320 * widthScale, 48 * heightScale) font:kPingFangRegular(16 * widthScale) titleColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColorFromRGB(0x0ABB07) colorWithAlphaComponent:.82f] title:@"使用微信登录"];
    [DDViewFactoryTool cornerRadius:4 * heightScale withView:self.loginButton];
    self.loginButton.alpha = 0;
    [self.view addSubview:self.loginButton];
    [self performSelector:@selector(showLoginWithWeChatButton) withObject:nil afterDelay:.5f];
    [self.loginButton addTarget:self action:@selector(loginWithWeChat) forControlEvents:UIControlEventTouchUpInside];
}

- (void)loginWithWeChat
{
    if ([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_WechatSession]) {
        [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_WechatSession currentViewController:self completion:^(id result, NSError *error) {
            
            if (nil == error && [result isKindOfClass:[UMSocialUserInfoResponse class]]) {
                
//                [MBProgressHUD showTextHUDWithText:@"授权成功" inView:self.navigationController.view];
//                [[UserManager shareManager] configWithUMengResponse:result];
//                [[UserManager shareManager] saveUserInfo];
//                [ZXTools weixinLoginUpdate];
//                [[NSNotificationCenter defaultCenter] postNotificationName:ZXUserDidLoginSuccessNotification object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            }else{
//                [MBProgressHUD showTextHUDWithText:@"授权失败" inView:self.view];
            }
        }];
    }else{
//        [MBProgressHUD showTextHUDWithText:@"请安装微信后使用" inView:self.view];
    }
}

- (void)showLoginWithWeChatButton
{
    [UIView animateWithDuration:.5f animations:^{
        self.loginButton.alpha = 1;
    }];
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
