//
//  LoginViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "LoginViewController.h"
#import "MBProgressHUD+DDHUD.h"
#import "UserManager.h"
#import "WeChatManager.h"
#import "UserLoginWXRequest.h"
#import <WXApi.h>

@interface LoginViewController ()

@property (nonatomic, assign) BOOL hasDDObserver;

@property (nonatomic, strong) UIButton * loginButton;
@property (nonatomic, strong) UIButton * agreementButton;
@property (nonatomic, assign) BOOL isAgreement;

@property (nonatomic, assign) BOOL isInstallWeChat;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //判断是否是微信登录
    self.isInstallWeChat = [WXApi isWXAppInstalled];
    
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
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    self.loginButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColorFromRGB(0x0ABB07) colorWithAlphaComponent:.82f] title:@"微信登录"];
    [self.loginButton setImage:[UIImage imageNamed:@"wxlogo"] forState:UIControlStateNormal];
    [self.loginButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [self.loginButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    [DDViewFactoryTool cornerRadius:6 withView:self.loginButton];
//    self.loginButton.alpha = 0;
    [self.loginButton addTarget:self action:@selector(loginWithWeChat) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginButton];
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.bottom.mas_equalTo(-568 * scale);
        make.height.mas_equalTo(144 * scale);
    }];
    
    self.agreementButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.agreementButton setImage:[UIImage imageNamed:@"singleno"] forState:UIControlStateNormal];
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:@"阅读并同意《地到用户注册协议》" attributes:@{NSFontAttributeName:kPingFangRegular(42 * scale), NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [attributedString addAttributes:@{NSFontAttributeName:kPingFangRegular(42 * scale), NSForegroundColorAttributeName:[[UIColor whiteColor] colorWithAlphaComponent:.7f]} range:NSMakeRange(0, 5)];
    [self.agreementButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    [self.agreementButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20 * scale, 0, 0)];
    [self.view addSubview:self.agreementButton];
    [self.agreementButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(72 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.top.mas_equalTo(self.loginButton.mas_bottom).offset(40 * scale);
    }];
    [self.agreementButton addTarget:self action:@selector(agreementButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * registerButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:[UIColor whiteColor] title:@"注册地到账号"];
    [self.view addSubview:registerButton];
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(80 * scale);
        make.height.mas_equalTo(60 * scale);
        make.top.mas_equalTo(self.loginButton.mas_bottom).offset(250 * scale);
    }];
    
    UIButton * passwordButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:[UIColor whiteColor] title:@"账号密码登录"];
    [self.view addSubview:passwordButton];
    [passwordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-80 * scale);
        make.height.mas_equalTo(60 * scale);
        make.top.mas_equalTo(self.loginButton.mas_bottom).offset(250 * scale);
    }];
    
    [registerButton addTarget:self action:@selector(registerButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [passwordButton addTarget:self action:@selector(passwordButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self showLoginWithWeChatButton];
    
//    if ([UserManager shareManager].isLogin) {
//         [self performSelector:@selector(showLoginWithWeChatButton) withObject:nil afterDelay:.5f];
//    }else{
//        [self performSelector:@selector(showLoginWithWeChatButton) withObject:nil afterDelay:.5f];
//    }
}

- (void)registerButtonDidClicked
{
    
}

- (void)passwordButtonDidClicked
{
    
}

- (void)agreementButtonDidClicked
{
    self.isAgreement = !self.isAgreement;
    if (self.isAgreement) {
        [self.agreementButton setImage:[UIImage imageNamed:@"singleyes"] forState:UIControlStateNormal];
    }else{
        [self.agreementButton setImage:[UIImage imageNamed:@"singleno"] forState:UIControlStateNormal];
    }
}

- (void)loginDDUserWithCode:(NSString *)code
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"登录中..." inView:self.view];
    UserLoginWXRequest * request = [[UserLoginWXRequest alloc] initWithWeCode:code];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary * data = [response objectForKey:@"data"];
            if (data && [data isKindOfClass:[NSDictionary class]]) {
                [[UserManager shareManager] loginWithDictionary:data];
                [[UserManager shareManager] saveUserInfo];
                [self loginSuccess];
                [MBProgressHUD showTextHUDWithText:@"登录成功" inView:[UIApplication sharedApplication].keyWindow];
            }else{
                [MBProgressHUD showTextHUDWithText:@"登录失败" inView:self.view];
            }
            
        }else{
            [MBProgressHUD showTextHUDWithText:@"登录失败" inView:self.view];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"登录失败" inView:self.view];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"登录失败" inView:self.view];
        
    }];
}

- (void)loginSuccess
{
    if (self.loginSucess) {
        self.loginSucess();
    }
}

- (void)loginWithWeChat
{
    [[WeChatManager shareManager] loginWithWeChat];
}

- (void)userLoginWith:(NSNotification *)notification
{
    SendAuthResp * resp = notification.object;
    if (resp.errCode) {
        [MBProgressHUD showTextHUDWithText:@"授权失败" inView:self.view];
    }else{
        if (isEmptyString(resp.code)) {
            [MBProgressHUD showTextHUDWithText:@"授权失败" inView:self.view];
        }else{
            [self loginDDUserWithCode:resp.code];
        }
    }
}

- (void)addDDObserver
{
    if (!self.hasDDObserver) {
        self.hasDDObserver = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginWith:) name:DDUserDidGetWeChatCodeNotification object:nil];
    }
}

- (void)removeDDObserver
{
    if (self.hasDDObserver) {
        self.hasDDObserver = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:DDUserDidGetWeChatCodeNotification object:nil];
    }
}

- (void)dealloc
{
    [self removeDDObserver];
}

- (void)showLoginWithWeChatButton
{
    self.loginButton.alpha = 1;
    [self addDDObserver];
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
