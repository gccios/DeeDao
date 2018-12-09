//
//  DDTelLoginViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/4.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDTelLoginViewController.h"
#import "RDAlertView.h"
#import "SetPassWordViewController.h"
#import "GetTelCodeRequest.h"
#import "UserLoginWXRequest.h"
#import "MBProgressHUD+DDHUD.h"
#import "UserManager.h"
#import "WeChatManager.h"
#import "AgreementViewController.h"
#import <AFHTTPSessionManager.h>

@interface DDTelLoginViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) DDTelLoginPageType type;

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UITextField * telNumberField;
@property (nonatomic, strong) UITextField * passwordField;
@property (nonatomic, strong) UITextField * codeField;
@property (nonatomic, strong) UIButton * codeButton;
@property (nonatomic, assign) NSInteger codeTime;
@property (nonatomic, strong) UILabel * tipLabel;
@property (nonatomic, strong) UIButton * forgetButton;

@property (nonatomic, strong) UIButton * leftHandleButton;
@property (nonatomic, strong) UIButton * rightHandleButton;

@property (nonatomic, strong) UIButton * loginButton;
@property (nonatomic, strong) UIButton * agreementButton;
@property (nonatomic, assign) BOOL isAgreement;

@property (nonatomic, strong) UIView * baseView;
@property (nonatomic, strong) UITableView * tableView;

@end

@implementation DDTelLoginViewController

- (instancetype)initWithDDTelLoginType:(DDTelLoginPageType)type
{
    if (self = [super init]) {
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
}

- (void)codeButtonDidClicked
{
    NSString * telNumber = self.telNumberField.text;
    
    if (!self.isAgreement) {
        [MBProgressHUD showTextHUDWithText:@"请仔细阅读并同意用户注册协议" inView:self.view];
        return;
    }
    
//    if (telNumber.length < 11) {
//        [MBProgressHUD showTextHUDWithText:@"请输入11位手机号码" inView:self.view];
//        return;
//    }
    
    [GetTelCodeRequest cancelRequest];
    GetTelCodeRequest * request = [[GetTelCodeRequest alloc] initWithTelNumber:telNumber];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        self.codeButton.enabled = NO;
        self.codeTime = 59;
        [self codeTimeDidCount];
        [MBProgressHUD showTextHUDWithText:@"验证码已发送" inView:self.view];
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [MBProgressHUD showTextHUDWithText:@"获取验证码失败" inView:self.view];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:self.view];
    }];
}

- (void)loginButtonDidClicked
{
    NSString * telNumber = self.telNumberField.text;
    NSString * code = self.codeField.text;
    
    if (!self.isAgreement) {
        [MBProgressHUD showTextHUDWithText:@"请仔细阅读并同意用户注册协议" inView:self.view];
        return;
    }
    
//    if (telNumber.length < 11) {
//        [MBProgressHUD showTextHUDWithText:@"请输入11位手机号码" inView:self.view];
//        return;
//    }
    
    if (code.length < 4) {
        [MBProgressHUD showTextHUDWithText:@"请输入有效验证码" inView:self.view];
        return;
    }
    
    if (self.type == DDTelLoginPageType_BindMobile) {
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在绑定" inView:self.view];
        
        UserLoginWXRequest * request = [[UserLoginWXRequest alloc] initCheckMobile:telNumber code:code];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            NSInteger status = [[response objectForKey:@"status"] integerValue];
            if (status != 1100) {
                [hud hideAnimated:YES];
                [MBProgressHUD showTextHUDWithText:@"验证码无效" inView:self.view];
                return;
            }
            
            AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            
            NSString * url = [NSString stringWithFormat:@"%@/api/open/completingPhoneNum", HOSTURL];
            
            [manager POST:url parameters:@{@"phoneNum":telNumber} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [hud hideAnimated:YES];
                [MBProgressHUD showTextHUDWithText:@"绑定成功" inView:self.view];
                
                [UserManager shareManager].user.phone = telNumber;
                [[UserManager shareManager] saveUserInfo];
                
                [self sureBtnClicked];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [hud hideAnimated:YES];
                [MBProgressHUD showTextHUDWithText:@"绑定失败" inView:self.view];
            }];
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"绑定失败" inView:self.view];
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"绑定失败" inView:self.view];
            
        }];
        
        return;
    }
    
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在登录" inView:self.view];
    UserLoginWXRequest * request = [[UserLoginWXRequest alloc] initWithTelNumber:telNumber code:code];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [MBProgressHUD showTextHUDWithText:@"登录成功" inView:[UIApplication sharedApplication].keyWindow];
        
        [hud hideAnimated:YES];
        if ([response isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary * data = [response objectForKey:@"data"];
            if (data && [data isKindOfClass:[NSDictionary class]]) {
                [[UserManager shareManager] loginWithDictionary:data];
                [[UserManager shareManager] saveUserInfo];
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
                if (self.loginSucess) {
                    self.loginSucess();
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:DDUserDidLoginWithTelNumberNotification object:nil];
                
                [MBProgressHUD showTextHUDWithText:@"登录成功" inView:[UIApplication sharedApplication].keyWindow];
            }else{
                [MBProgressHUD showTextHUDWithText:@"登录失败" inView:self.view];
            }
        }
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"登录失败" inView:self.view];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:self.view];
    }];
    
//    SetPassWordViewController * setPassword = [[SetPassWordViewController alloc] init];
//    [self presentViewController:setPassword animated:YES completion:nil];
}

- (void)forgetButtonDidClicked
{
    RDAlertView * alertView = [[RDAlertView alloc] initWithTitle:@"密码找回" message:@"为了保护您账号资料的安全，请使用手机验证码登录系统后，进入系统设置页进行密码重置操作，感谢您的理解与支持。"];
    
    RDAlertAction * action = [[RDAlertAction alloc] initWithTitle:@"知道了" handler:^{
        
    } bold:NO];
    [alertView addActions:@[action]];
    [alertView show];
}

- (void)leftHandleButtonDidClicked
{
    if (self.type == DDTelLoginPageType_Register) {
        self.type = DDTelLoginPageType_Login;
    }else if (self.type == DDTelLoginPageType_Login) {
        self.type = DDTelLoginPageType_Register;
    }
    [self reloadLoginView];
}

- (void)rightHandleButtonDidClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)codeTimeDidCount
{
    if (self.codeTime < 1) {
        [self.codeButton setTitle:@"请输入验证码" forState:UIControlStateNormal];
        [self.codeButton setTitleColor:UIColorFromRGB(0xDB6283) forState:UIControlStateNormal];
        self.codeButton.enabled = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(codeTimeDidCount) object:nil];
    }else{
        
        [self.codeButton setTitle:[NSString stringWithFormat:@"重新获取(%lds)", self.codeTime] forState:UIControlStateNormal];
        [self.codeButton setTitleColor:UIColorFromRGB(0xCCCCCC) forState:UIControlStateNormal];
        self.codeTime--;
        [self performSelector:@selector(codeTimeDidCount) withObject:nil afterDelay:1.f];
    }
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
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView * effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.alpha = .97f;
    [bgImageView addSubview:effectView];
    [effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 1750 * scale)];
    
    self.titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(120 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentCenter];
    self.titleLabel.text = @"欢迎您来地到";
    [self.baseView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(200 * scale + kStatusBarHeight);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(200 * scale);
    }];
    
    self.tipLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xCCCCCC) alignment:NSTextAlignmentCenter];
    self.tipLabel.text = @"短信验证即登录，未注册将自动创建账号";
    if (self.type == DDTelLoginPageType_BindMobile) {
        self.tipLabel.text = @"微信绑定手机后将只能用微信账号登录";
    }
    
    //手机号输入
    self.telNumberField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.telNumberField.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.telNumberField.keyboardType = UIKeyboardTypeNumberPad;
    self.telNumberField.placeholder = @"请输入手机号码";
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.telNumberField];
    self.telNumberField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    UIView * telLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180 * scale, 144 * scale)];
    UILabel * telLeftLabel = [DDViewFactoryTool createLabelWithFrame:CGRectMake(0, 0, 160 * scale, 144 * scale) font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentRight];
    telLeftLabel.text = @"手机: ";
    [telLeftView addSubview:telLeftLabel];
    self.telNumberField.leftView = telLeftView;
    self.telNumberField.leftViewMode = UITextFieldViewModeAlways;
    [self.baseView addSubview:self.telNumberField];
    [self.telNumberField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(612 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(144 * scale);
    }];
    
    //验证码输入
    self.codeField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.codeField.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.codeField.keyboardType = UIKeyboardTypeNumberPad;
    self.codeField.placeholder = @"请输入验证码";
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.codeField];
    
    UIView * codeLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180 * scale, 144 * scale)];
    UILabel * codeLeftLabel = [DDViewFactoryTool createLabelWithFrame:CGRectMake(0, 0, 160 * scale, 144 * scale) font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentRight];
    codeLeftLabel.text = @"验证码: ";
    [codeLeftView addSubview:codeLeftLabel];
    self.codeField.leftView = codeLeftView;
    self.codeField.leftViewMode = UITextFieldViewModeAlways;
    
    self.codeButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(0, 0, 300 * scale, 120 * scale) font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"获取验证码"];
    [self.codeButton addTarget:self action:@selector(codeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    self.codeField.rightView = self.codeButton;
    self.codeField.rightViewMode = UITextFieldViewModeAlways;
    
    //密码输入
    self.passwordField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.passwordField.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.passwordField.borderStyle = UIKeyboardTypeNamePhonePad;
    self.passwordField.secureTextEntry = YES;
    self.passwordField.placeholder = @"请输入密码";
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.passwordField];
    self.passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    UIView * passwordLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180 * scale, 144 * scale)];
    UILabel * passwordLeftLabel = [DDViewFactoryTool createLabelWithFrame:CGRectMake(0, 0, 160 * scale, 144 * scale) font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentRight];
    passwordLeftLabel.text = @"密码: ";
    [passwordLeftView addSubview:passwordLeftLabel];
    self.passwordField.leftView = passwordLeftView;
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    
//    [self.baseView addSubview:self.passwordField];
//    [self.passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.codeField.mas_bottom).offset(40 * scale);
//        make.left.mas_equalTo(60 * scale);
//        make.right.mas_equalTo(-60 * scale);
//        make.height.mas_equalTo(144 * scale);
//    }];
    
    self.agreementButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.agreementButton setImage:[UIImage imageNamed:@"singleno"] forState:UIControlStateNormal];
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:@"阅读并同意《地到用户注册协议》" attributes:@{NSFontAttributeName:kPingFangRegular(42 * scale), NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [attributedString addAttributes:@{NSFontAttributeName:kPingFangRegular(42 * scale), NSForegroundColorAttributeName:[[UIColor whiteColor] colorWithAlphaComponent:.7f]} range:NSMakeRange(0, 5)];
    [self.agreementButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    [self.agreementButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20 * scale, 0, 0)];
    [self.agreementButton addTarget:self action:@selector(agreementButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * readButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.agreementButton addSubview:readButton];
    [readButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(0);
        make.width.mas_equalTo(470 * scale);
    }];
    [readButton addTarget:self action:@selector(readButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.loginButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xFFFFFF) backgroundColor:UIColorFromRGB(0x00BD00) title:@"确定并登录"];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.loginButton];
    [self.loginButton addTarget:self action:@selector(loginButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.baseView addSubview:self.loginButton];
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(120 * scale);
        make.right.mas_equalTo(-120 * scale);
        make.top.mas_equalTo(1188 * scale);
        make.height.mas_equalTo(144 * scale);
    }];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth - 240 * scale, 144 * scale);
    [self.loginButton.layer insertSublayer:gradientLayer atIndex:0];
    self.loginButton.alpha = .5f;
    self.loginButton.enabled = NO;
    
//    self.leftHandleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:[UIColor whiteColor] title:@"账号密码登录"];
//    [self.baseView addSubview:self.leftHandleButton];
//    [self.leftHandleButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(120 * scale);
//        make.height.mas_equalTo(60 * scale);
//        make.top.mas_equalTo(self.loginButton.mas_bottom).offset(250 * scale);
//    }];
    
    self.rightHandleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:[UIColor whiteColor] title:@"微信登录"];
    [self.baseView addSubview:self.rightHandleButton];
    [self.rightHandleButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-120 * scale);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(60 * scale);
        make.top.mas_equalTo(self.loginButton.mas_bottom).offset(250 * scale);
    }];
    if (![WXApi isWXAppInstalled]) {
        self.rightHandleButton.hidden = YES;
    }
    
    if (self.type == DDTelLoginPageType_BindMobile) {
        self.rightHandleButton.hidden = YES;
    }
    
    self.forgetButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"忘记密码?"];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.rowHeight = .1 * scale;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = self.baseView;
    [self.view addSubview:self.tableView];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userEndEdit)];
    [self.tableView addGestureRecognizer:tap];
    
    [self.forgetButton addTarget:self action:@selector(forgetButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.leftHandleButton addTarget:self action:@selector(leftHandleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.rightHandleButton addTarget:self action:@selector(rightHandleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self reloadLoginView];
    
    [self.telNumberField addTarget:self action:@selector(textFieldValueDidChange) forControlEvents:UIControlEventEditingChanged];
    [self.codeField addTarget:self action:@selector(textFieldValueDidChange) forControlEvents:UIControlEventEditingChanged];
    [self.passwordField addTarget:self action:@selector(textFieldValueDidChange) forControlEvents:UIControlEventEditingChanged];
    
    [self agreementButtonDidClicked];
    
    UIButton* sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.backgroundColor = [UIColor clearColor];
    sureBtn.frame = CGRectZero;
    sureBtn.layer.cornerRadius = 12.0;
    sureBtn.layer.borderColor = UIColorFromRGB(0xffffff).CGColor;
    sureBtn.layer.borderWidth = 1.0f;
    [sureBtn setTitle:@"跳过" forState:UIControlStateNormal];
    [sureBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [sureBtn.titleLabel setFont:kPingFangLight(13)];
    [sureBtn addTarget:self action:@selector(sureBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sureBtn];
    
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50,24));
        make.top.mas_equalTo(40);
        make.right.mas_equalTo(-30);
    }];
}

- (void)sureBtnClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.loginSucess) {
        self.loginSucess();
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DDUserDidLoginWithTelNumberNotification object:nil];
}

- (void)readButtonDidClicked
{
    AgreementViewController * agreement = [[AgreementViewController alloc] init];
    [self presentViewController:agreement animated:YES completion:nil];
}

- (void)textFieldValueDidChange
{
    if (self.type == DDTelLoginPageType_Login) {
        
        NSString * telNumber = self.telNumberField.text;
        NSString * password = self.passwordField.text;
        
        telNumber = [telNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        password = [password stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if (telNumber.length > 20) {
            telNumber = [telNumber substringToIndex:20];
        }
        if (password.length > 16) {
            password = [password substringToIndex:16];
        }
        self.telNumberField.text = telNumber;
        self.passwordField.text = password;
        if (self.telNumberField.text.length >= 11 && self.passwordField.text.length >= 6) {
            self.loginButton.alpha = 1;
            self.loginButton.enabled = YES;
        }else{
            self.loginButton.alpha = .5f;
            self.loginButton.enabled = NO;
        }
        
    }else if (self.type == DDTelLoginPageType_Register) {
        
        NSString * telNumber = self.telNumberField.text;
        NSString * code = self.codeField.text;
        
        telNumber = [telNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        code = [code stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if (telNumber.length > 20) {
            telNumber = [telNumber substringToIndex:20];
        }
        if (code.length > 8) {
            code = [code substringToIndex:8];
        }
        
        self.telNumberField.text = telNumber;
        self.codeField.text = code;
        
        if (self.telNumberField.text.length >= 11 && self.codeField.text.length >= 4) {
            self.loginButton.alpha = 1;
            self.loginButton.enabled = YES;
        }else{
            self.loginButton.alpha = .5f;
            self.loginButton.enabled = NO;
        }
        
    }else if (self.type == DDTelLoginPageType_BindMobile) {
        NSString * telNumber = self.telNumberField.text;
        NSString * code = self.codeField.text;
        
        telNumber = [telNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        code = [code stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if (telNumber.length > 20) {
            telNumber = [telNumber substringToIndex:20];
        }
        if (code.length > 8) {
            code = [code substringToIndex:8];
        }
        
        self.telNumberField.text = telNumber;
        self.codeField.text = code;
        
        if (self.telNumberField.text.length >= 11 && self.codeField.text.length >= 4) {
            self.loginButton.alpha = 1;
            self.loginButton.enabled = YES;
        }else{
            self.loginButton.alpha = .5f;
            self.loginButton.enabled = NO;
        }
    }
}

- (void)reloadLoginView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    if (self.type == DDTelLoginPageType_Login) {
        
        [self.leftHandleButton setTitle:@"短信验证码登录(密码)" forState:UIControlStateNormal];
        
        [self.tipLabel removeFromSuperview];
        [self.codeField removeFromSuperview];
        [self.agreementButton removeFromSuperview];
        
        [self.telNumberField mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(552 * scale);
        }];
        
        [self.baseView addSubview:self.passwordField];
        [self.passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.telNumberField.mas_bottom).offset(40 * scale);
            make.left.mas_equalTo(60 * scale);
            make.right.mas_equalTo(-60 * scale);
            make.height.mas_equalTo(144 * scale);
        }];
        
        [self.baseView addSubview:self.forgetButton];
        [self.forgetButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.passwordField.mas_bottom).offset(55 * scale);
            make.right.mas_equalTo(-120 * scale);
            make.height.mas_equalTo(50 * scale);
        }];
        
        [self.loginButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(1128 * scale);
        }];
    }else if (self.type == DDTelLoginPageType_Register) {
        
        [self.leftHandleButton setTitle:@"账号密码登录" forState:UIControlStateNormal];
        
        [self.passwordField removeFromSuperview];
        [self.forgetButton removeFromSuperview];
        
        [self.baseView addSubview:self.tipLabel];
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom);
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(50 * scale);
        }];
        
        [self.telNumberField mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(612 * scale);
        }];
        
        [self.baseView addSubview:self.codeField];
        [self.codeField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.telNumberField.mas_bottom).offset(40 * scale);
            make.left.mas_equalTo(60 * scale);
            make.right.mas_equalTo(-60 * scale);
            make.height.mas_equalTo(144 * scale);
        }];
        
        [self.baseView addSubview:self.agreementButton];
        [self.agreementButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(72 * scale);
            make.left.mas_equalTo(120 * scale);
            make.right.mas_equalTo(-120 * scale);
            make.top.mas_equalTo(self.codeField.mas_bottom).offset(50 * scale);
        }];
        
        [self.loginButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(1188 * scale);
        }];
    }else if (self.type == DDTelLoginPageType_BindMobile) {
        [self.leftHandleButton setTitle:@"短信验证码登录(密码)" forState:UIControlStateNormal];
        [self.loginButton setTitle:@"确定并绑定" forState:UIControlStateNormal];
        
        [self.passwordField removeFromSuperview];
        [self.forgetButton removeFromSuperview];
        
        [self.baseView addSubview:self.tipLabel];
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom);
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(50 * scale);
        }];
        
        [self.telNumberField mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(612 * scale);
        }];
        
        [self.baseView addSubview:self.codeField];
        [self.codeField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.telNumberField.mas_bottom).offset(40 * scale);
            make.left.mas_equalTo(60 * scale);
            make.right.mas_equalTo(-60 * scale);
            make.height.mas_equalTo(144 * scale);
        }];
        
        [self.baseView addSubview:self.agreementButton];
        [self.agreementButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(72 * scale);
            make.left.mas_equalTo(120 * scale);
            make.right.mas_equalTo(-120 * scale);
            make.top.mas_equalTo(self.codeField.mas_bottom).offset(50 * scale);
        }];
        
        [self.loginButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(1188 * scale);
        }];
    }
    [self textFieldValueDidChange];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)userEndEdit
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
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
