//
//  HelpAndAdviceController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/7.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "HelpAndAdviceController.h"
#import "UIView+LayerCurve.h"
#import "MBProgressHUD+DDHUD.h"
#import "JubaoRequest.h"
#import "UserManager.h"
#import <WebKit/WebKit.h>

@interface HelpAndAdviceController ()

@property (nonatomic, strong) UITextField * textField;

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) WKWebView * webView;

@end

@implementation HelpAndAdviceController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    self.webView = [[WKWebView alloc] init];
    [self.view addSubview:self.webView];
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 150 * scale, 0);
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((kStatusBarHeight + 220) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://test.deedao.com/help.html"]];
    [self.webView loadRequest:request];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.textField.placeholder = @"请输入您的留言内容...";
    [self.view addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    self.textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60 * scale, 100 * scale)];
    self.textField.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    [self.textField layerSolidLinePoints:@[[NSValue valueWithCGPoint:CGPointMake(0, 0)], [NSValue valueWithCGPoint:CGPointMake(kMainBoundsWidth, 0)]] Color:[UIColorFromRGB(0x000000) colorWithAlphaComponent:.12f] Width:3 * scale];
    
    UIButton * sendButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(0, 0, 150 * scale, 70 * scale) font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"确认"];
    self.textField.rightView = sendButton;
    self.textField.rightViewMode = UITextFieldViewModeAlways;
    [sendButton addTarget:self action:@selector(sendButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self createTopView];
}

- (void)sendButtonDidClicked
{
    NSString * complaint = self.textField.text;
    if (isEmptyString(complaint)) {
        [MBProgressHUD showTextHUDWithText:@"请输入您的反馈信息" inView:self.view];
        return;
    }
    JubaoRequest * request = [[JubaoRequest alloc] initWithPostViewId:-1 postComplaintContent:complaint complaintOwner:[UserManager shareManager].user.cid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self endEdit];
        self.textField.text = @"";
        [MBProgressHUD showTextHUDWithText:@"反馈成功" inView:self.view];
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [MBProgressHUD showTextHUDWithText:@"反馈失败" inView:self.view];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [MBProgressHUD showTextHUDWithText:@"反馈失败" inView:self.view];
    }];
}

- (void)createTopView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.topView = [[UIView alloc] init];
    self.topView.userInteractionEnabled = YES;
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo((220 + kStatusBarHeight) * scale);
    }];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, (220 + kStatusBarHeight) * scale);
    [self.topView.layer addSublayer:gradientLayer];
    
    self.topView.layer.shadowColor = UIColorFromRGB(0xB721FF).CGColor;
    self.topView.layer.shadowOpacity = .24;
    self.topView.layer.shadowOffset = CGSizeMake(0, 4);
    
    UIButton * backButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.bottom.mas_equalTo(-15 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    titleLabel.text = @"帮助与反馈";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];

    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEdit)];
    [self.webView addGestureRecognizer:tap];
}

- (void)endEdit
{
    if (self.textField.isFirstResponder) {
        [self.textField resignFirstResponder];
    }
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
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
