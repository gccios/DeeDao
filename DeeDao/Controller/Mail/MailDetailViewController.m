//
//  MailDetailViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/18.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "MailDetailViewController.h"
#import "MainInfoTableViewCell.h"
#import "DDTool.h"
#import "UserInfoViewController.h"
#import <UIImageView+WebCache.h>
#import "SaveFriendOrConcernRequest.h"
#import "DTieNewDetailViewController.h"
#import "DTieDetailRequest.h"
#import "MBProgressHUD+DDHUD.h"

@interface MailDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) MailModel * model;
@property (nonatomic, assign) BOOL isDtie;

@end

@implementation MailDetailViewController

- (instancetype)initMailModel:(MailModel *)model
{
    if (self = [super init]) {
        self.model = model;
        NSInteger cid = model.mailTypeId;
        self.isDtie = NO;
        if (cid == 1 || cid == 3 || cid == 4 || cid == 5 || cid == 7 || cid == 10 || cid == 11) {
            self.isDtie = YES;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
}

- (void)showDTieDetail
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:self.view];
    
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:self.model.postId type:4 start:0 length:10];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                if (dtieModel.ifCanSee == 0) {
                    [MBProgressHUD showTextHUDWithText:@"您没有浏览该帖的权限~" inView:self.view];
                    return;
                }
                
                if (dtieModel.deleteFlg == 1) {
                    [MBProgressHUD showTextHUDWithText:@"该帖已被作者删除~" inView:self.view];
                    return;
                }
                DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initWithDTie:dtieModel];
                [self.navigationController pushViewController:detail animated:YES];
            }
        }
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
    }];
}

- (void)userInfoShouldLook
{
    UserInfoViewController * info = [[UserInfoViewController alloc] initWithUserId:self.model.mailSendId];
    [self.navigationController pushViewController:info animated:YES];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[MainInfoTableViewCell class] forCellReuseIdentifier:@"MainInfoTableViewCell"];
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 210 * scale, 0);
    
    UIButton * backButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"返回列表"];
    backButton.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [DDViewFactoryTool cornerRadius:24 * scale withView:backButton];
    backButton.layer.borderColor = UIColorFromRGB(0xDB5282).CGColor;
    backButton.layer.borderWidth = 3 * scale;
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.bottom.mas_equalTo(-63 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(144 * scale);
    }];
    if (self.model.mailTypeId == 8) {
        [backButton setTitle:@"同意添加" forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(addFriendOK:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [backButton addTarget:self action:@selector(backButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self createTableHeaderFooter];
    [self createTopView];
}

- (void)addFriendOK:(UIButton *)button
{
    SaveFriendOrConcernRequest * request = [[SaveFriendOrConcernRequest alloc] initWithHandleFriendId:self.model.mailSendId andIsAdd:YES];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [button removeTarget:self action:@selector(addFriendOK:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"返回列表" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        [MBProgressHUD showTextHUDWithText:@"添加成功" inView:self.navigationController.view];
        
//        if (self.delegate && [self.delegate respondsToSelector:@selector(userDidAgreementFriend:)]) {
//            [self.delegate userDidAgreementFriend:self.model];
//        }
//        [self.navigationController popViewControllerAnimated:YES];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [MBProgressHUD showTextHUDWithText:@"添加失败" inView:self.view];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [MBProgressHUD showTextHUDWithText:@"添加失败" inView:self.view];
        
    }];
}

- (void)createTableHeaderFooter
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 340 * scale)];
    
    if (self.isDtie) {
        
        headerView.frame = CGRectMake(0, 0, kMainBoundsWidth, 695 * scale);
        
        UIImageView * bgImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
        [bgImageView sd_setImageWithURL:[NSURL URLWithString:self.model.postFirstPicture] placeholderImage:[UIImage imageNamed:@"list_bg"]];
        bgImageView.clipsToBounds = YES;
        bgImageView.clipsToBounds = YES;
        [headerView addSubview:bgImageView];
        [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(80 * scale);
            make.width.mas_equalTo(kMainBoundsWidth / 2);
            make.centerX.mas_equalTo(0);
            make.height.mas_equalTo(300 * scale);
        }];
        
        bgImageView.layer.cornerRadius = 24 * scale;
        bgImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        bgImageView.layer.shadowOpacity = .3f;
        bgImageView.layer.shadowRadius = 12 * scale;
        bgImageView.layer.shadowOffset = CGSizeMake(0, -6 * scale);
        
        bgImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDTieDetail)];
        [bgImageView addGestureRecognizer:tap];
        
        UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentCenter];
        titleLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6f];
        titleLabel.text = self.model.mailPostSummary;
        [bgImageView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.mas_equalTo(0);
            make.height.mas_equalTo(90 * scale);
        }];
        
        UIView * coverView = [[UIView alloc] initWithFrame:CGRectZero];
        coverView.backgroundColor = UIColorFromRGB(0xFFFFFF);
        [headerView addSubview:coverView];
        [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(356 * scale);
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(30 * scale);
        }];
        coverView.layer.shadowColor = UIColorFromRGB(0x333333).CGColor;
        coverView.layer.shadowOpacity = .2f;
        coverView.layer.shadowOffset = CGSizeMake(0, -12 * scale);
    }
    
    UIImageView * headerBGView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"headerBG"]];
    [headerView addSubview:headerBGView];
    [headerBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(99 * scale);
        make.bottom.mas_equalTo(-49 * scale);
        make.width.height.mas_equalTo(182 * scale);
    }];
    
    UIImageView * logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"test"]];
    [logoImageView sd_setImageWithURL:[NSURL URLWithString:self.model.portraitUri]];
    [headerView addSubview:logoImageView];
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(115 * scale);
        make.bottom.mas_equalTo(-65 * scale);
        make.width.height.mas_equalTo(150 * scale);
    }];
    [DDViewFactoryTool cornerRadius:150 * scale / 2 withView:logoImageView];
    UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userInfoShouldLook)];
    logoImageView.userInteractionEnabled = YES;
    [logoImageView addGestureRecognizer:tap1];
    
    UILabel * nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    nameLabel.text = self.model.nickName;
    [headerView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(logoImageView.mas_top).offset(15 * scale);
        make.left.mas_equalTo(logoImageView.mas_right).offset(45 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userInfoShouldLook)];
    nameLabel.userInteractionEnabled = YES;
    [nameLabel addGestureRecognizer:tap2];
    
    UILabel * infoLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(54 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    infoLabel.text = [MailModel getTitleWithMailTypeId:self.model.mailTypeId];
    [headerView addSubview:infoLabel];
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(nameLabel.mas_bottom).offset(15 * scale);
        make.left.mas_equalTo(logoImageView.mas_right).offset(45 * scale);
        make.height.mas_equalTo(60 * scale);
    }];
    
    self.tableView.tableHeaderView = headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainInfoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MainInfoTableViewCell" forIndexPath:indexPath];
    
    [cell configInfo:self.model.mailContent time:[DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.model.createTime]];
    
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
    titleLabel.text = @"消息详情";
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
