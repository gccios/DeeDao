//
//  DDGroupGiveViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/10.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDGroupGiveViewController.h"
#import "DDGroupPeopleManagerController.h"
#import "DDGroupPeopleTableViewCell.h"
#import "UserManager.h"
#import "DDGroupRequest.h"
#import "MBProgressHUD+DDHUD.h"
#import "RDAlertView.h"

@interface DDGroupGiveViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) DDGroupModel * model;

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@end

@implementation DDGroupGiveViewController

- (instancetype)initWithModel:(DDGroupModel *)model
{
    if (self = [super init]) {
        self.model = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 360.f;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 65 * scale;
    [self.tableView registerClass:[DDGroupPeopleTableViewCell class] forCellReuseIdentifier:@"DDGroupPeopleTableViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * kMainBoundsWidth / 1080.f);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    [self createTopView];
    
    [self setupData];
}

- (void)setupData
{
    DDGroupRequest * request = [[DDGroupRequest alloc] initGroupPeopleListWithGroupID:self.model.cid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSArray * data = [response objectForKey:@"data"];
        if (KIsArray(data)) {
            
            [self.dataSource removeAllObjects];
            for (NSDictionary * dict in data) {
                UserModel * model = [[UserModel alloc] init];
                model.groupID = [[dict objectForKey:@"groupId"] integerValue];
                model.groupListID = [dict objectForKey:@"id"];
                model.nickname = [dict objectForKey:@"nickname"];
                model.portraituri = [dict objectForKey:@"portraitUri"];
                model.cid = [[dict objectForKey:@"userId"] integerValue];
                [self.dataSource addObject:model];
            }
            [self.tableView reloadData];
        }
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDGroupPeopleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DDGroupPeopleTableViewCell" forIndexPath:indexPath];
    
    UserModel * model = [self.dataSource objectAtIndex:indexPath.row];
    [cell configGiveWithModel:model];
    
    __weak typeof(self) weakSelf = self;
    cell.giveButtonHandle = ^(UserModel * _Nonnull model) {
        [weakSelf giveWithModel:model];
    };
    
    return cell;
}

- (void)giveWithModel:(UserModel *)model
{
    RDAlertView * alertView = [[RDAlertView alloc] initWithTitle:@"移交" message:[NSString stringWithFormat:@"确定把群“%@”移交给“%@”吗？", self.model.groupName, model.nickname]];
    RDAlertAction * action1 = [[RDAlertAction alloc] initWithTitle:@"取消" handler:^{
        
    } bold:NO];
    RDAlertAction * action2 = [[RDAlertAction alloc] initWithTitle:@"确定" handler:^{
        
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在移交" inView:self.view];
        DDGroupRequest * request = [[DDGroupRequest alloc] initGiveGroup:self.model.cid toUser:model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [MBProgressHUD showTextHUDWithText:@"移交成功" inView:[UIApplication sharedApplication].keyWindow];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
            NSString * msg = [response objectForKey:@"msg"];
            if (isEmptyString(msg)) {
                msg = @"移交失败";
            }
            [MBProgressHUD showTextHUDWithText:msg inView:self.view];
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"移交失败" inView:self.view];
        }];
        
    } bold:NO];
    [alertView addActions:@[action1, action2]];
    [alertView show];
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
    titleLabel.text = @"用户管理";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
        make.right.mas_equalTo(-135 * scale);
    }];
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
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
