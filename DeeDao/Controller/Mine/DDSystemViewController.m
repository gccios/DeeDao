//
//  DDSystemViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/14.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDSystemViewController.h"
#import "DDSystemTableViewCell.h"
#import "DDSystemAlertController.h"
#import "UserManager.h"
#import "UserLogoutRequest.h"
#import "PassWordSetViewController.h"
#import "HelpAndAdviceController.h"
//#import "SystemAlertTableViewCell.h"
#import "MBProgressHUD+DDHUD.h"

@interface DDSystemViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@end

@implementation DDSystemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = [[NSMutableArray alloc] initWithArray:@[@"帮助与反馈", @"切换账号/退出登录"]];
    [self createViews];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 150 * scale;
    [self.tableView registerClass:[DDSystemTableViewCell class] forCellReuseIdentifier:@"DDSystemTableViewCell"];
//    [self.tableView registerClass:[SystemAlertTableViewCell class] forCellReuseIdentifier:@"SystemAlertTableViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    UIView * tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 708 * scale)];
    tableHeaderView.backgroundColor = self.tableView.backgroundColor;
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 684 * scale)];
    headerView.backgroundColor = [UIColor whiteColor];
    [tableHeaderView addSubview:headerView];
    
    UIImageView * logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"DeeDao-logo"]];
    [headerView addSubview:logoImageView];
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40 * scale);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(228 * scale);
    }];
    
    UILabel * aboutLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentCenter];
    aboutLabel.text = @"关于  DeeDao地到";
    [headerView addSubview:aboutLabel];
    [aboutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(logoImageView.mas_bottom).offset(14 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(50 * scale);
    }];
    
    UILabel * detailLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    detailLabel.numberOfLines = 0;
    detailLabel.text = @"Deedao 跟朋友一样靠谱，通过Deedao，您可以分享您的美食奇景体验，收集朋友的分享， 计划你下一次的聚餐和出游，而且，您还可以通过踩到共同的地点，而跟好友互动和拉近关系。地到，比朋友更资源丰富。";
    [headerView addSubview:detailLabel];
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(aboutLabel.mas_bottom).offset(5 * scale);
        make.left.mas_equalTo(60 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    
    self.tableView.tableHeaderView = tableHeaderView;
    
    UIView * tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 200 * scale)];
    UILabel * CopyLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentCenter];
    CopyLabel.numberOfLines = 0;
    CopyLabel.text = @"Copyright © 2018\n图籍数据科技(上海)有限公司";
    [tableFooterView addSubview:CopyLabel];
    [CopyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(90 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(120 * scale);
    }];
    self.tableView.tableFooterView = tableFooterView;
    
    [self createTopView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == 1) {
//        SystemAlertTableViewCell * tipCell = [tableView dequeueReusableCellWithIdentifier:@"SystemAlertTableViewCell"];
//
//        [tipCell configWithModel:[[SettingModel alloc] initWithType:SettingType_AlertTip]];
//
//        return tipCell;
//    }
    
    DDSystemTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DDSystemTableViewCell" forIndexPath:indexPath];
    
    cell.nameLabel.text = [self.dataSource objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 0) {
        
        HelpAndAdviceController * help = [[HelpAndAdviceController alloc] init];
        [self.navigationController pushViewController:help animated:YES];
        
    }else if (indexPath.row == 1){
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定退出当前登录账号" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action1];
        
        UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self logoutUser];
        }];
        [alert addAction:action2];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)logoutUser
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在退出登录" inView:self.view];
    
    UserLogoutRequest * logout = [[UserLogoutRequest alloc] init];
    [logout sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:DDUserDidLoginOutNotification object:nil];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        
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
    titleLabel.text = @"系统设置";
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
