//
//  ForgetPasswordViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/4.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "ForgetPasswordViewController.h"

@interface ForgetPasswordViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UITextField * telField;
@property (nonatomic, strong) UITextField * codeField;
@property (nonatomic, strong) UITextField * passwordField;
@property (nonatomic, strong) UITextField * secondPasseordField;

@property (nonatomic, strong) UIButton * codeButton;
@property (nonatomic, assign) NSInteger codeTime;

@property (nonatomic, strong) UIButton * leftHandleButton;
@property (nonatomic, strong) UIButton * rightHandleButton;

@property (nonatomic, strong) UITableView * tableView;

@end

@implementation ForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
}

- (void)codeButtonDidClicked
{
    self.codeButton.enabled = NO;
    self.codeTime = 59;
    [self codeTimeDidCount];
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

- (void)leftHandleButtonDidClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightHandleButtonDidClicked
{
    
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 744 * scale)];
    UIView * contenView = [[UIView alloc] initWithFrame:CGRectZero];
    contenView.backgroundColor = [UIColor whiteColor];
    [baseView addSubview:contenView];
    [contenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(576 * scale);
    }];
    
    self.telField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.telField.text = @"假装这里有号码";
    self.telField.keyboardType = UIKeyboardTypeNumberPad;
    self.telField.enabled = NO;
    self.telField.placeholder = @"请输入手机号码";
    
    UIView * codeLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250 * scale, 144 * scale)];
    UILabel * codeLeftLabel = [DDViewFactoryTool createLabelWithFrame:CGRectMake(0, 0, 230 * scale, 144 * scale) font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentRight];
    codeLeftLabel.text = @"手机号码:";
    [codeLeftView addSubview:codeLeftLabel];
    self.telField.leftView = codeLeftView;
    self.telField.leftViewMode = UITextFieldViewModeAlways;
    
    [contenView addSubview:self.telField];
    [self.telField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    
    UIView * lineView1 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView1.backgroundColor = UIColorFromRGB(0xCCCCCC);
    [self.telField addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(3 * scale);
    }];
    
    //验证码输入
    self.codeField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.codeField.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.codeField.keyboardType = UIKeyboardTypeNumberPad;
    self.codeField.placeholder = @"请输入验证码";
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.codeField];
    
    UIView * codeLeftView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250 * scale, 144 * scale)];
    UILabel * codeLeftLabel2 = [DDViewFactoryTool createLabelWithFrame:CGRectMake(0, 0, 230 * scale, 144 * scale) font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentRight];
    codeLeftLabel2.text = @"验证码: ";
    [codeLeftView2 addSubview:codeLeftLabel2];
    self.codeField.leftView = codeLeftView2;
    self.codeField.leftViewMode = UITextFieldViewModeAlways;
    
    self.codeButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(0, 0, 300 * scale, 120 * scale) font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"获取验证码"];
    [self.codeButton addTarget:self action:@selector(codeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    self.codeField.rightView = self.codeButton;
    self.codeField.rightViewMode = UITextFieldViewModeAlways;
    
    [contenView addSubview:self.codeField];
    [self.codeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.telField.mas_bottom);
        make.left.mas_equalTo(0 * scale);
        make.right.mas_equalTo(0 * scale);
        make.height.mas_equalTo(144 * scale);
    }];
    
    UIView * lineView4 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView4.backgroundColor = UIColorFromRGB(0xCCCCCC);
    [self.codeField addSubview:lineView4];
    [lineView4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(3 * scale);
    }];
    
    self.passwordField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.passwordField.keyboardType = UIKeyboardTypeNamePhonePad;
    self.passwordField.placeholder = @"请输入新密码";
    
    UIView * passwordLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250 * scale, 144 * scale)];
    UILabel * passwordLabel = [DDViewFactoryTool createLabelWithFrame:CGRectMake(0, 0, 230 * scale, 144 * scale) font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentRight];
    passwordLabel.text = @"新密码:";
    [passwordLeftView addSubview:passwordLabel];
    self.passwordField.leftView = passwordLeftView;
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    
    [contenView addSubview:self.passwordField];
    [self.passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.codeField.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    
    UIView * lineView2 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView2.backgroundColor = UIColorFromRGB(0xCCCCCC);
    [self.passwordField addSubview:lineView2];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(3 * scale);
    }];
    
    self.secondPasseordField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.secondPasseordField.keyboardType = UIKeyboardTypeNamePhonePad;
    self.secondPasseordField.placeholder = @"请再次输入新密码";
    
    UIView * secondLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250 * scale, 144 * scale)];
    UILabel * secondLeftLabel = [DDViewFactoryTool createLabelWithFrame:CGRectMake(0, 0, 230 * scale, 144 * scale) font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentRight];
    secondLeftLabel.text = @"新密码:";
    [secondLeftView addSubview:secondLeftLabel];
    self.secondPasseordField.leftView = secondLeftView;
    self.secondPasseordField.leftViewMode = UITextFieldViewModeAlways;
    
    [contenView addSubview:self.secondPasseordField];
    [self.secondPasseordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.passwordField.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.rowHeight = .1 * scale;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 350 * scale, 0);
    self.tableView.tableHeaderView = baseView;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shouldRegisterEditing)];
    [self.tableView addGestureRecognizer:tap];
    
    UIView * bottomHandleView = [[UIView alloc] initWithFrame:CGRectZero];
    bottomHandleView.backgroundColor = [UIColorFromRGB(0xEEEEF4) colorWithAlphaComponent:.7f];
    [self.view addSubview:bottomHandleView];
    [bottomHandleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(324 * scale);
    }];
    
    self.leftHandleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:@"取消并退出"];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.leftHandleButton];
    self.leftHandleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.leftHandleButton.layer.borderWidth = 3 * scale;
    [bottomHandleView addSubview:self.leftHandleButton];
    [self.leftHandleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.width.mas_equalTo(444 * scale);
        make.height.mas_equalTo(144 * scale);
        make.centerY.mas_equalTo(0);
    }];
    
    self.rightHandleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:@"保存并更新"];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.rightHandleButton];
    self.rightHandleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.rightHandleButton.layer.borderWidth = 3 * scale;
    [bottomHandleView addSubview:self.rightHandleButton];
    [self.rightHandleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.width.mas_equalTo(444 * scale);
        make.height.mas_equalTo(144 * scale);
        make.centerY.mas_equalTo(0);
    }];
    
    [self.leftHandleButton addTarget:self action:@selector(leftHandleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.rightHandleButton addTarget:self action:@selector(rightHandleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.passwordField addTarget:self action:@selector(textFieldValueDidChange) forControlEvents:UIControlEventEditingChanged];
    [self.secondPasseordField addTarget:self action:@selector(textFieldValueDidChange) forControlEvents:UIControlEventEditingChanged];
    
    [self createTopViews];
}

- (void)shouldRegisterEditing
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

- (void)textFieldValueDidChange
{
    NSString * first = self.passwordField.text;
    NSString * second = self.secondPasseordField.text;
    
    first = [first stringByReplacingOccurrencesOfString:@" " withString:@""];
    second = [second stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (first.length > 16) {
        first = [first substringToIndex:16];
    }
    if (second.length > 16) {
        second = [second substringToIndex:16];
    }
    self.passwordField.text = first;
    self.secondPasseordField.text = second;
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

- (void)createTopViews
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
    [backButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.bottom.mas_equalTo(-15 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    titleLabel.text = @"密码设置";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
}

- (void)backButtonDidClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
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