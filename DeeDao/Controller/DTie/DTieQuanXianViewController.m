//
//  DTieQuanXianViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieQuanXianViewController.h"
#import "SecurityRequest.h"
#import <Masonry.h>
#import "DTieNewSecurityCell.h"
#import "MBProgressHUD+DDHUD.h"

@interface DTieQuanXianViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UIView * quanxianView;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) UIButton * gongkaiButton;
@property (nonatomic, strong) UIButton * yinsiButton;
@property (nonatomic, strong) UIButton * miquanButton;

@property (nonatomic, strong) UIButton * currentQuanxianButton;

@property (nonatomic, strong) NSMutableArray * selectSource;
@property (nonatomic, assign) NSInteger landAccountFlg;

@property (nonatomic, strong) UILabel * alertLabel;

@end

@implementation DTieQuanXianViewController

- (instancetype)init
{
    if (self = [super init]) {
        [self createViews];
        [self createTopView];
        
        [self requestSecuritySource];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)requestSecuritySource
{
    SecurityRequest * request = [[SecurityRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.dataSource removeAllObjects];
                [self.selectSource removeAllObjects];
                
                SecurityGroupModel * model1 = [[SecurityGroupModel alloc] init];
                model1.cid = -1;
                model1.securitygroupName = @"所有朋友";
                model1.isChoose = YES;
                model1.isNotification = YES;
                [self.dataSource addObject:model1];
                
                SecurityGroupModel * model2 = [[SecurityGroupModel alloc] init];
                model2.cid = -2;
                model2.securitygroupName = @"关注我的人";
                model2.isChoose = YES;
                model2.isNotification = YES;
                [self.dataSource addObject:model2];
                
                for (NSInteger i = 0; i < data.count; i++) {
                    NSDictionary * dict = [data objectAtIndex:i];
                    NSDictionary * result = [dict objectForKey:@"securityGroup"];
                    SecurityGroupModel * model = [SecurityGroupModel mj_objectWithKeyValues:result];
                    model.isNotification = YES;
                    [self.dataSource addObject:model];
                }
                
                [self.selectSource addObject:model1];
                [self.selectSource addObject:model2];
                
                [self.tableView reloadData];
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

#pragma mark - 选择不同的选项
- (void)gongkaiButtonDidClicked:(UIButton *)button
{
    if (self.currentQuanxianButton != button) {
        [self.currentQuanxianButton setImage:[UIImage imageNamed:@"singleno"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"singleyes"] forState:UIControlStateNormal];
        self.landAccountFlg = 1;
        self.currentQuanxianButton = button;
        
        self.tableView.tableFooterView.frame = CGRectMake(0, 0, kMainBoundsWidth, 220 * kMainBoundsWidth / 1080.f);
        self.alertLabel.text = @"选择公开，意味着您的所有好友以及关注您的人（包括陌生人）均可看见您当前发布的D帖，并会收到相应提示。精华公开帖有机会被地到官方选中推广。";
        
        [self.tableView reloadData];
    }
}

- (void)yinsiButtonDidClicked:(UIButton *)button
{
    if (self.currentQuanxianButton != button) {
        [self.currentQuanxianButton setImage:[UIImage imageNamed:@"singleno"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"singleyes"] forState:UIControlStateNormal];
        self.landAccountFlg = 2;
        self.currentQuanxianButton = button;
        
        self.tableView.tableFooterView.frame = CGRectMake(0, 0, kMainBoundsWidth, 170 * kMainBoundsWidth / 1080.f);
        self.alertLabel.text = @"选择私密，意味着除您自己外，其他人均不可看见您当前发布的D帖。";
        
        [self.tableView reloadData];
    }
}

- (void)miquanButtonDidClicked:(UIButton *)button
{
    if (self.currentQuanxianButton != button) {
        [self.currentQuanxianButton setImage:[UIImage imageNamed:@"singleno"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"singleyes"] forState:UIControlStateNormal];
        self.landAccountFlg = 4;
        self.currentQuanxianButton = button;
        
        self.alertLabel.text = @"选择好友圈，意味着只有您指定的好友可看见您当前发布的D帖，并会收到相应提示。";
        
        [self.tableView reloadData];
    }
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.quanxianView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 400 * scale)];
    
    CGFloat buttonHeight = (400 - 48) * scale / 3.f;
    
    UIView * gongkaiView = [[UIView alloc] init];
    gongkaiView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.quanxianView addSubview:gongkaiView];
    [gongkaiView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(buttonHeight);
    }];
    
    self.gongkaiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.gongkaiButton.titleLabel.font = kPingFangRegular(42 * scale);
    [self.gongkaiButton setImage:[UIImage imageNamed:@"singleno"] forState:UIControlStateNormal];
    [self.gongkaiButton setTitle:@"公开" forState:UIControlStateNormal];
    [self.gongkaiButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    [gongkaiView addSubview:self.gongkaiButton];
    [self.gongkaiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(buttonHeight);
    }];
    self.landAccountFlg = 1;
    [self.gongkaiButton addTarget:self action:@selector(gongkaiButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIView * yinsiView = [[UIView alloc] init];
    yinsiView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.quanxianView addSubview:yinsiView];
    [yinsiView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(gongkaiView.mas_bottom).offset(24 * scale);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(buttonHeight);
    }];
    
    self.yinsiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.yinsiButton.titleLabel.font = kPingFangRegular(42 * scale);
    [self.yinsiButton setImage:[UIImage imageNamed:@"singleno"] forState:UIControlStateNormal];
    [self.yinsiButton setTitle:@"私密" forState:UIControlStateNormal];
    [self.yinsiButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    [yinsiView addSubview:self.yinsiButton];
    [self.yinsiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(buttonHeight);
    }];
    [self.yinsiButton addTarget:self action:@selector(yinsiButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView * miquanView = [[UIView alloc] init];
    miquanView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.quanxianView addSubview:miquanView];
    [miquanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(yinsiView.mas_bottom).offset(24 * scale);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(buttonHeight);
    }];
    
    self.miquanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.miquanButton.titleLabel.font = kPingFangRegular(42 * scale);
    [self.miquanButton setTitle:@"好友圈" forState:UIControlStateNormal];
    [self.miquanButton setImage:[UIImage imageNamed:@"singleno"] forState:UIControlStateNormal];
    [self.miquanButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    [miquanView addSubview:self.miquanButton];
    [self.miquanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(buttonHeight);
    }];
    [self.miquanButton addTarget:self action:@selector(miquanButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView * tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 220 * kMainBoundsWidth / 1080.f)];
    UIImageView * alertImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"alertEdit"]];
    [tableFooterView addSubview:alertImageView];
    [alertImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(48 * scale);
        make.left.mas_equalTo(60 * scale);
        make.width.height.mas_equalTo(72 * scale);
    }];
    
    self.alertLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    self.alertLabel.numberOfLines = 0;
    self.alertLabel.text = @"选择公开，意味着您的所有好友以及关注您的人（包括陌生人）均可看见您当前发布的D帖，并会收到相应提示。精华公开帖有机会被地到官方选中推广。";
    [tableFooterView addSubview:self.alertLabel];
    [self.alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(48 * scale);
        make.left.mas_equalTo(alertImageView.mas_right).offset(20 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.bottom.mas_equalTo(-10 * scale);
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[DTieNewSecurityCell class] forCellReuseIdentifier:@"DTieNewSecurityCell"];
    self.tableView.rowHeight = 90 * scale;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.tableView.contentInset = UIEdgeInsetsMake(60 * scale, 0, 324 * scale, 0);
    self.tableView.tableHeaderView = self.quanxianView;
    self.tableView.tableFooterView = tableFooterView;
    
    SecurityGroupModel * model1 = [[SecurityGroupModel alloc] init];
    model1.cid = -1;
    model1.securitygroupName = @"所有朋友";
    model1.isChoose = YES;
    model1.isNotification = YES;
    [self.dataSource addObject:model1];

    SecurityGroupModel * model2 = [[SecurityGroupModel alloc] init];
    model2.cid = -2;
    model2.securitygroupName = @"关注我的人";
    model2.isChoose = YES;
    model2.isNotification = YES;
    [self.dataSource addObject:model2];
//    [self.selectSource addObject:model1];
//    [self.selectSource addObject:model2];
    [self.gongkaiButton setImage:[UIImage imageNamed:@"singleyes"] forState:UIControlStateNormal];
    self.landAccountFlg = 1;
    self.currentQuanxianButton = self.gongkaiButton;
    
    [self.tableView reloadData];
    
    UIView * bottomHandleView = [[UIView alloc] initWithFrame:CGRectZero];
    bottomHandleView.backgroundColor = [UIColorFromRGB(0xEEEEF4) colorWithAlphaComponent:.7f];
    [self.view addSubview:bottomHandleView];
    [bottomHandleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(324 * scale);
    }];
    
    UIButton * handleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:@"确定并返回"];
    [DDViewFactoryTool cornerRadius:24 * scale withView:handleButton];
    handleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    handleButton.layer.borderWidth = 3 * scale;
    [bottomHandleView addSubview:handleButton];
    [handleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(144 * scale);
        make.centerY.mas_equalTo(0);
    }];
    [handleButton addTarget:self action:@selector(handleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)handleButtonDidClicked
{
    [self.selectSource removeAllObjects];
    if (self.landAccountFlg == 4) {
        for (SecurityGroupModel * model in self.dataSource) {
            if (model.isChoose) {
                [self.selectSource addObject:model];
            }
        }
        if (self.selectSource.count == 0) {
            [MBProgressHUD showTextHUDWithText:@"请至少选择一个" inView:[UIApplication sharedApplication].keyWindow];
            return;
        }
    }
    [self delegateShouldBlock];
}

- (void)delegateShouldBlock
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(DTieQuanxianDidCompleteWith:landAccountFlg:)]) {
        [self.delegate DTieQuanxianDidCompleteWith:self.selectSource landAccountFlg:self.landAccountFlg];
        [self backButtonDidClicked];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.currentQuanxianButton != self.miquanButton) {
        return 0;
    }
    
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTieNewSecurityCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieNewSecurityCell" forIndexPath:indexPath];
    
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
    [backButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.bottom.mas_equalTo(-15 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    titleLabel.text = @"浏览权限";
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

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (NSMutableArray *)selectSource
{
    if (!_selectSource) {
        _selectSource = [[NSMutableArray alloc] init];
    }
    return _selectSource;
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
