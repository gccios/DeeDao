//
//  DDMineViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/10.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDMineViewController.h"
#import "MineHeaderView.h"
#import "MainTableViewCell.h"
#import "MineInfoViewController.h"
#import "MYWalletViewController.h"
#import "AchievementViewController.h"

@interface DDMineViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) NSMutableArray * dataSource;

@end

@implementation DDMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createDataSource];
    [self createViews];
}

- (void)createDataSource
{
    self.dataSource = [NSMutableArray new];
    NSArray * typeArray = @[[[MineMenuModel alloc] initWithType:MineMenuType_Wallet],
                            [[MineMenuModel alloc] initWithType:MineMenuType_Achievement],
                            [[MineMenuModel alloc] initWithType:MineMenuType_Address],
                            [[MineMenuModel alloc] initWithType:MineMenuType_Private]];
    NSArray * sysArray = @[[[MineMenuModel alloc] initWithType:MineMenuType_System]];
    [self.dataSource addObject:typeArray];
    [self.dataSource addObject:sysArray];
}

- (void)createViews
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
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentCenter];
    titleLabel.text = @"个人中心";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60.5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.tableView registerClass:[MainTableViewCell class] forCellReuseIdentifier:@"MainTableViewCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    MineHeaderView * headerView = [[MineHeaderView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 288 * scale)];
    self.tableView.tableHeaderView = headerView;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom).offset(0);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.tableView.contentInset = UIEdgeInsetsMake(60 * scale, 0, 0, 0);
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mineInfoDidClcked)];
    tap.numberOfTapsRequired = 1;
    [headerView addGestureRecognizer:tap];
}

- (void)mineInfoDidClcked
{
    MineInfoViewController * info = [[MineInfoViewController alloc] init];
    [self.navigationController pushViewController:info animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSArray * data = [self.dataSource objectAtIndex:indexPath.section];
    MineMenuModel * model = [data objectAtIndex:indexPath.row];
    switch (model.type) {
        case MineMenuType_Wallet:
        {
            MYWalletViewController * wallet = [[MYWalletViewController alloc] init];
            [self.navigationController pushViewController:wallet animated:YES];
        }
            break;
            
        case MineMenuType_Achievement:
        {
            AchievementViewController * achievement = [[AchievementViewController alloc] init];
            [self.navigationController pushViewController:achievement animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * data = [self.dataSource objectAtIndex:section];
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MainTableViewCell" forIndexPath:indexPath];
    
    NSArray * data = [self.dataSource objectAtIndex:indexPath.section];
    MineMenuModel * model = [data objectAtIndex:indexPath.row];
    [cell configWithMenuModel:model];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    return 144 * scale;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    return 48 * scale;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return .1;
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
