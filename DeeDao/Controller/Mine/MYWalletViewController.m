//
//  MYWalletViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/13.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "MYWalletViewController.h"

@interface MYWalletViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILabel * walletLabel;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UIView * topView;

@end

@implementation MYWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createViews];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    UIView * tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 300 * scale)];
    tableHeaderView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    UILabel * payLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(44 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    payLabel.text = @"账户余额:";
    [tableHeaderView addSubview:payLabel];
    [payLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(75 * scale);
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(50 * scale);
    }];
    
    self.walletLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(58 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.walletLabel.text = @"￥500";
    [tableHeaderView addSubview:self.walletLabel];
    [self.walletLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(payLabel.mas_right).offset(10 * scale);
        make.top.mas_equalTo(65 * scale);
        make.height.mas_equalTo(60 * scale);
    }];
    
    UIButton * cashButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(44 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"申请提现"];
    [tableHeaderView addSubview:cashButton];
    [cashButton addTarget:self action:@selector(cashButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [tableHeaderView addSubview:cashButton];
    [cashButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-20 * scale);
        make.width.mas_equalTo(200 * scale);
        make.height.mas_equalTo(80 * scale);
    }];
    
    UILabel * detailLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(44 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    detailLabel.text = @"获赠礼物清单";
    [tableHeaderView addSubview:detailLabel];
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.bottom.mas_equalTo(-50 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [tableHeaderView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.bottom.mas_equalTo(-5 * scale);
        make.width.mas_equalTo(kMainBoundsWidth - 15);
        make.height.mas_equalTo(.5f);
    }];
    
    self.tableView.tableHeaderView = tableHeaderView;
    
    UIView * tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 500 * scale)];
    
    UIButton * payButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(58 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"账户充值"];
    [DDViewFactoryTool cornerRadius:24 * scale withView:payButton];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth - 30, 144 * scale);
    [payButton.layer insertSublayer:gradientLayer atIndex:0];
    
    [tableFooterView addSubview:payButton];
    [payButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100 * scale);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(kMainBoundsWidth - 30);
        make.height.mas_equalTo(144 * scale);
    }];
    
    UIButton * detailButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(58 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"交易明细"];
    [DDViewFactoryTool cornerRadius:24 * scale withView:detailButton];
    detailButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    detailButton.layer.borderWidth = 1.f;
    [tableFooterView addSubview:detailButton];
    [detailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(payButton.mas_bottom).offset(60 * scale);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(kMainBoundsWidth - 30);
        make.height.mas_equalTo(144 * scale);
    }];
    [payButton addTarget:self action:@selector(payButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [detailButton addTarget:self action:@selector(detailButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.tableFooterView = tableFooterView;
    
    self.tableView.contentInset = UIEdgeInsetsMake(60 * scale, 0, 0, 0);
    
    [self createTopView];
}

- (void)payButtonDidClicked
{
    NSLog(@"账户充值");
}

- (void)detailButtonDidClicked
{
    NSLog(@"交易明细");
}

- (void)cashButtonDidClicked
{
    NSLog(@"申请提现");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    cell.textLabel.font = kPingFangRegular(42 * scale);
    cell.textLabel.textColor = UIColorFromRGB(0x666666);
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"收到赞:    累计数量100";
            break;
            
        case 1:
            cell.textLabel.text = @"收到小花: 累计数量100";
            break;
            
        case 2:
            cell.textLabel.text = @"收到咖啡: 累计数量20";
            break;
            
        case 3:
            cell.textLabel.text = @"收到魔棒: 累计数量5";
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 144 * kMainBoundsWidth / 1080.f;
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
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentCenter];
    titleLabel.text = @"我的钱包";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
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
