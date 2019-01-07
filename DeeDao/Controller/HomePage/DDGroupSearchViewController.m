//
//  DDGroupSearchViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/7.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDGroupSearchViewController.h"
#import "DDGroupTableViewCell.h"

@interface DDGroupSearchViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, CAAnimationDelegate>

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UITextField * textField;

@property (nonatomic, strong) UIButton * myButton;
@property (nonatomic, strong) UIButton * otherButton;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, assign) NSInteger type; //1为已有群，2为其它公开群

@end

@implementation DDGroupSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.type = 1;
    [self createViews];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 360.f;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 230 * scale;
    [self.tableView registerClass:[DDGroupTableViewCell class] forCellReuseIdentifier:@"DDGroupTableViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((364 + kStatusBarHeight) * kMainBoundsWidth / 1080.f);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    [self createTopView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDGroupTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DDGroupTableViewCell" forIndexPath:indexPath];
    
    return cell;
}

- (void)createTopView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.topView = [[UIView alloc] init];
    self.topView.userInteractionEnabled = YES;
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo((364 + kStatusBarHeight) * scale);
    }];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, (364 + kStatusBarHeight) * scale);
    [self.topView.layer addSublayer:gradientLayer];
    
    self.topView.layer.shadowColor = UIColorFromRGB(0xB721FF).CGColor;
    self.topView.layer.shadowOpacity = .24;
    self.topView.layer.shadowOffset = CGSizeMake(0, 4);
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.textField.returnKeyType = UIReturnKeySearch;
    self.textField.delegate = self;
    [self.topView addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((96 + kStatusBarHeight) * scale);
        make.left.mas_equalTo(24 * scale);
        make.right.mas_equalTo(-24 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    self.textField.backgroundColor = UIColorFromRGB(0xFAFAFA);
    [DDViewFactoryTool cornerRadius:30 * scale withView:self.textField];
    self.textField.layer.shadowColor = UIColorFromRGB(0x000000).CGColor;
    self.textField.layer.shadowOpacity = .24f;
    self.textField.layer.shadowRadius = 6 * scale;
    self.textField.layer.shadowOffset = CGSizeMake(0, 6 * scale);
    
    UIButton * backButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(0, 0, 110 * scale, 72 * scale) font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@""];
    self.textField.leftView = backButton;
    UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectMake(40 * scale, 14 * scale, 48 * scale, 48 * scale) contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"close_color"]];
    [backButton addSubview:imageView];
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    [backButton addTarget:self action:@selector(backButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * sendButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(0, 0, 140 * scale, 80 * scale) font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:DDLocalizedString(@"Search")];
    self.textField.rightView = sendButton;
    self.textField.rightViewMode = UITextFieldViewModeAlways;
    [sendButton addTarget:self action:@selector(searchButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.myButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"已有群"];
    [self.myButton addTarget:self action:@selector(myButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.myButton];
    [self.myButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textField.mas_bottom).offset(10 * scale);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(-10 * scale);
        make.width.mas_equalTo(kMainBoundsWidth / 2.f);
    }];
    
    UIView * lineView1 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView1.backgroundColor = [UIColorFromRGB(0xFFFFFF) colorWithAlphaComponent:.5f];
    [self.myButton addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.width.mas_equalTo(3 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    
    self.otherButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"其他公开群"];
    [self.otherButton addTarget:self action:@selector(otherButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.otherButton];
    [self.otherButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textField.mas_bottom).offset(10 * scale);
        make.right.mas_equalTo(0 * scale);
        make.bottom.mas_equalTo(-10 * scale);
        make.width.mas_equalTo(kMainBoundsWidth / 2.f);
    }];
    self.otherButton.alpha = .5f;
}

- (void)myButtonDidClicked
{
    if (self.type == 2) {
        self.type = 1;
        self.otherButton.alpha = .5f;
        self.myButton.alpha = 1.f;
        [self.tableView reloadData];
    }
}

- (void)otherButtonDidClicked
{
    if (self.type == 1) {
        self.type = 2;
        self.otherButton.alpha = 1.f;
        self.myButton.alpha = .5f;
        [self.tableView reloadData];
    }
}

- (void)searchButtonDidClicked
{
    if (self.textField.isFirstResponder) {
        [self.textField resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self searchButtonDidClicked];
    
    return YES;
}

- (void)backButtonDidClicked
{
    CATransition *transition = [CATransition animation];
    
    transition.duration = 0.35;
    
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    
    transition.type = kCATransitionPush;
    
    transition.subtype = kCATransitionFromBottom;
    
    transition.delegate = self;
    
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    [self.navigationController popViewControllerAnimated:NO];
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
