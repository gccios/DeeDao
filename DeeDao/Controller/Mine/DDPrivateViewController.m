//
//  DDPrivateViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/14.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDPrivateViewController.h"
#import "DDPrivateTableViewCell.h"
#import "SecurityRequest.h"
#import "MBProgressHUD+DDHUD.h"
#import "EditSecurityController.h"
#import "SelectSecurityRequest.h"
#import "UserModel.h"
#import "DTieModel.h"
#import "UserManager.h"

@interface DDPrivateViewController () <UITableViewDelegate, UITableViewDataSource, EditSecurityDelegate>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@end

@implementation DDPrivateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
    
    [self requestSecuritySource];
}

- (void)requestSecuritySource
{
    SecurityRequest * request = [[SecurityRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.dataSource removeAllObjects];
                
                if (self.delegate) {
                    [self createChooseBaseModel];
                }
                
                for (NSInteger i = 0; i < data.count; i++) {
                    NSDictionary * dict = [data objectAtIndex:i];
                    NSDictionary * result = [dict objectForKey:@"securityGroup"];
                    SecurityGroupModel * model = [SecurityGroupModel mj_objectWithKeyValues:result];
                    [self.dataSource addObject:model];
                }
                [self.tableView reloadData];
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)createChooseBaseModel
{
    SecurityGroupModel * model1 = [[SecurityGroupModel alloc] init];
    model1.landAccountFlg = 1;
    model1.securitygroupName = @"公开";
    model1.securitygroupPropName = @"所有用户都可见，包括陌生人";
    model1.createPerson = [UserManager shareManager].user.cid;
    model1.createTime = [[NSDate date] timeIntervalSince1970] * 1000;
    
    SecurityGroupModel * model2 = [[SecurityGroupModel alloc] init];
    model2.landAccountFlg = 0;
    model2.securitygroupName = @"设为隐私";
    model2.securitygroupPropName = @"只有自己可见";
    model2.createPerson = [UserManager shareManager].user.cid;
    model2.createTime = [[NSDate date] timeIntervalSince1970] * 1000;
    
    [self.dataSource addObject:model1];
    [self.dataSource addObject:model2];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 540 * scale;
    [self.tableView registerClass:[DDPrivateTableViewCell class] forCellReuseIdentifier:@"DDPrivateTableViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    self.tableView.contentInset = UIEdgeInsetsMake(40 * scale, 0, 30 * scale, 0);
    
    [self createTopView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SecurityGroupModel * model = [self.dataSource objectAtIndex:indexPath.row];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(securityDidSelectWith:)]) {
        [self.delegate securityDidSelectWith:model];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    __block NSInteger count = 0;
    __block NSMutableArray * friends = [[NSMutableArray alloc] init];
    __block NSMutableArray * Dties = [[NSMutableArray alloc] init];
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载好友圈" inView:self.view];
    
    SelectSecurityRequest * friendRequest = [[SelectSecurityRequest alloc] initWithSelectUserWith:model.cid];
    [friendRequest sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            for (NSDictionary * dict in data) {
                UserModel * model = [UserModel mj_objectWithKeyValues:dict];
                [friends addObject:model];
            }
        }
        
        count++;
        if (count == 2) {
            [hud hideAnimated:YES];
            [self editWithFriends:friends posts:Dties model:model];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        count++;
        if (count == 2) {
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"用户列表获取失败" inView:self.view];
        }
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        count++;
        if (count == 2) {
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"用户列表获取失败" inView:self.view];
        }
        
    }];
    
    SelectSecurityRequest * postRequest = [[SelectSecurityRequest alloc] initWithSelectPostWith:model.cid];
    [postRequest sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            for (NSDictionary * dict in data) {
                DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                [Dties addObject:model];
            }
        }
        count++;
        if (count == 2) {
            [hud hideAnimated:YES];
            [self editWithFriends:friends posts:Dties model:model];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        count++;
        if (count == 2) {
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"D帖列表获取失败" inView:self.view];
        }
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        count++;
        if (count == 2) {
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"D帖列表获取失败" inView:self.view];
        }
        
    }];
    
}

- (void)editWithFriends:(NSArray *)friends posts:(NSArray *)posts model:(SecurityGroupModel *)model
{
    EditSecurityController * edit = [[EditSecurityController alloc] initWithModel:model friends:friends posts:posts];
    edit.delegate = self;
    [self.navigationController pushViewController:edit animated:YES];
}

- (void)securityGroupDidEdit
{
    [self requestSecuritySource];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDPrivateTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DDPrivateTableViewCell" forIndexPath:indexPath];
    
    SecurityGroupModel * model = [self.dataSource objectAtIndex:indexPath.row];
    [cell configWithModel:model];
    
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
    titleLabel.text = @"我的圈子";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
    UIButton * createButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] title:@"新建"];
    [DDViewFactoryTool cornerRadius:12 * scale withView:createButton];
    createButton.layer.borderWidth = .5f;
    createButton.layer.borderColor = UIColorFromRGB(0xFFFFFF).CGColor;
    [createButton addTarget:self action:@selector(createButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:createButton];
    [createButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(144 * scale);
        make.height.mas_equalTo(72 * scale);
        make.centerY.mas_equalTo(titleLabel);
        make.right.mas_equalTo(-60 * scale);
    }];
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createButtonDidClicked
{
    EditSecurityController * edit = [[EditSecurityController alloc] init];
    edit.delegate = self;
    [self.navigationController pushViewController:edit animated:YES];
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
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
