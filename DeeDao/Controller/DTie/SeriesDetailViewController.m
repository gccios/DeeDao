//
//  SeriesDetailViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SeriesDetailViewController.h"
#import "SeriesDetailTableViewCell.h"
#import "MBProgressHUD+DDHUD.h"
#import "DTieDetailRequest.h"
#import "DTieNewDetailViewController.h"
#import "DDTool.h"

@interface SeriesDetailViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, copy) NSString * seriesTitle;

@property (nonatomic, strong) SeriesDetailModel * model;

@property (nonatomic, assign) NSInteger seriesTime;

@end

@implementation SeriesDetailViewController

- (instancetype)initWithTitle:(NSString *)title source:(NSArray *)source
{
    if (self = [super init]) {
        self.seriesTitle = title;
        self.dataSource = [[NSMutableArray alloc] initWithArray:source];
        self.seriesTime = [[NSDate date] timeIntervalSince1970] * 1000;
    }
    return self;
}

- (instancetype)initWithSeriesModel:(SeriesDetailModel *)model
{
    if (self = [super init]) {
        self.model = model;
        self.seriesTitle = model.seriesTitle;
        self.dataSource = [[NSMutableArray alloc] initWithArray:model.postShowDetailRes];
        self.seriesTime = model.seriesCreatTime;
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
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 540 * scale;
    [self.tableView registerClass:[SeriesDetailTableViewCell class] forCellReuseIdentifier:@"SeriesDetailTableViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    [self createTableHeaderFooter];
    
    [self createTopView];
}

- (void)createTableHeaderFooter
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 210 * scale)];
    headerView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectMake(60 * scale, 60 * scale, kMainBoundsWidth - 120 * scale, 60 * scale) font:kPingFangRegular(54 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentLeft];
    titleLabel.text = self.seriesTitle;
    [headerView addSubview:titleLabel];
    
    UILabel * timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectMake(60 * scale, 126 * scale, kMainBoundsWidth - 120 * scale, 54 * scale) font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    timeLabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.seriesTime];
    [headerView addSubview:timeLabel];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(60 * scale, 202 * scale, kMainBoundsWidth - 120 * scale, 3 * scale)];
    lineView.backgroundColor = [UIColorFromRGB(0x000000) colorWithAlphaComponent:.12f];
    [headerView addSubview:lineView];
    
    self.tableView.tableHeaderView = headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SeriesDetailTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"SeriesDetailTableViewCell" forIndexPath:indexPath];
    
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.row];
    [cell configWithModel:model];
    
    __weak typeof(self) weakSelf = self;
    cell.seriesShowDTieHandle = ^{
        [weakSelf showDtieWithModel:model];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 890 * kMainBoundsWidth / 1080.f;
}

- (void)showDtieWithModel:(DTieModel *)model
{
    if (model.details) {
        DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initWithDTie:model];
        [self.navigationController pushViewController:detail animated:YES];
        return;
    }
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在获取详情" inView:self.view];
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:model.cid type:4 start:0 length:10];
    
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                DTieModel * tempModel = [DTieModel mj_objectWithKeyValues:data];
                DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initWithDTie:tempModel];
                [self.navigationController pushViewController:detail animated:YES];
            }
        }
        
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
    titleLabel.text = self.seriesTitle;
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
