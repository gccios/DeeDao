//
//  AchievementDetailViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/14.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "AchievementDetailViewController.h"

@interface AchievementDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UITableView * tableView;

@end

@implementation AchievementDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
    [self createTopView];
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
    self.tableView.rowHeight = 0.1f;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(0);
    }];
    
    NSString * bgImagePath = [[NSBundle mainBundle] pathForResource:@"chengjiuBG" ofType:@"png"];
    UIImage * image;
    if (bgImagePath) {
        image = [UIImage imageWithContentsOfFile:bgImagePath];
    }else{
        image = [UIImage imageNamed:@"chengjiuBG.png"];
    }
    UIImageView * tableHeaderView = [DDViewFactoryTool createImageViewWithFrame:CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsWidth * 360 / 324) contentModel:UIViewContentModeScaleAspectFill image:image];
    self.tableView.tableHeaderView = tableHeaderView;
    
    UIView * tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 380 * scale)];
    tableHeaderView.backgroundColor = self.tableView.backgroundColor;
    UIView * footerImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"QRCode"]];
    [tableFooterView addSubview:footerImageView];
    [footerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20 * scale);
        make.left.mas_equalTo(90 * scale);
        make.width.height.mas_equalTo(180 * scale);
    }];
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    titleLabel.text = @"DeeDao身份证明";
    [tableFooterView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(39 * scale);
        make.left.mas_equalTo(footerImageView.mas_right).offset(24 * scale);
        make.width.mas_equalTo(695 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
    
    UILabel * detailLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentLeft];
    detailLabel.numberOfLines = 0;
    [tableFooterView addSubview:detailLabel];
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(20 * scale);
        make.left.mas_equalTo(footerImageView.mas_right).offset(24 * scale);
        make.width.mas_equalTo(695 * scale);
    }];
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@"恭喜您于" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x000000)}];
    
    NSAttributedString * dateString = [[NSAttributedString alloc] initWithString:@"2018-05-13  23:56" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0xDB6283)}];
    [string appendAttributedString:dateString];
    
    NSAttributedString * preString = [[NSMutableAttributedString alloc] initWithString:@"成功登录DeeDao星球成为" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x000000)}];
    [string appendAttributedString:preString];
    
    NSAttributedString * numberString = [[NSAttributedString alloc] initWithString:@"1" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0xDB6283)}];
    [string appendAttributedString:numberString];
    
    NSAttributedString * fixString = [[NSMutableAttributedString alloc] initWithString:@"位原住民" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x000000)}];
    [string appendAttributedString:fixString];
    detailLabel.attributedText = string;
    
    UIButton * bottomShareButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"点击分享即可获得D星球外交官成就"];
    [bottomShareButton addTarget:self action:@selector(shareButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [tableFooterView addSubview:bottomShareButton];
    [bottomShareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(50 * scale);
        make.height.mas_equalTo(150 * scale);
        make.width.mas_equalTo(kMainBoundsWidth - 120 * scale);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:bottomShareButton];
    bottomShareButton.layer.borderColor = UIColorFromRGB(0XDB6283).CGColor;
    bottomShareButton.layer.borderWidth = 3 * scale;
    
    self.tableView.tableFooterView = tableFooterView;
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
    titleLabel.text = @"我的成就";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
    UIButton * shareButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] title:@""];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [DDViewFactoryTool cornerRadius:12 * scale withView:shareButton];
    [shareButton addTarget:self action:@selector(shareButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:shareButton];
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(90 * scale);
        make.height.mas_equalTo(90 * scale);
        make.centerY.mas_equalTo(titleLabel);
        make.right.mas_equalTo(-60 * scale);
    }];
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareButtonDidClicked
{
    NSLog(@"分享");
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
