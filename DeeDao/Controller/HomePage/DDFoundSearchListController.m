//
//  DDFoundSearchListController.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/16.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDFoundSearchListController.h"
#import "DTieSearchRequest.h"
#import "MBProgressHUD+DDHUD.h"
#import "DDTool.h"
#import "DTieNewTableViewCell.h"
#import <MJRefresh.h>
#import "DTieNewDetailViewController.h"

@interface DDFoundSearchListController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) DDGroupModel * model;

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UITextField * textField;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, assign) NSInteger dataSourceType;
@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger length;

@end

@implementation DDFoundSearchListController

- (instancetype)initWithModel:(DDGroupModel *)model
{
    if (self = [super init]) {
        self.model = model;
        
        if (model.cid == -1) {
            self.dataSourceType = 1;
        }else if (model.cid == -2) {
            self.dataSourceType = 6;
        }else{
            self.dataSourceType = 12;
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createViews];
    [self createTopView];
}

- (void)searchButtonDidClicked
{
    NSString * keyWord = self.textField.text;
    if (isEmptyString(keyWord)) {
        return;
    }
    
    self.start = 0;
    self.length = 1000;
    
    if (self.textField.isFirstResponder) {
        [self.textField resignFirstResponder];
    }
    
    [DTieSearchRequest cancelRequest];
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    
    DTieSearchRequest * request = [[DTieSearchRequest alloc] initWithKeyWord:keyWord lat1:0 lng1:0 lat2:0 lng2:0 startDate:0 endDate:(NSInteger)[DDTool getTimeCurrentWithDouble] sortType:1 dataSources:self.dataSourceType type:2 pageStart:self.start pageSize:self.length];
    if (self.dataSourceType == 12) {
        [request configGroupID:self.model.cid];
    }
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSArray * data = [response objectForKey:@"data"];
        if (KIsArray(data)) {
            [self.dataSource addObjectsFromArray:[DTieModel mj_objectArrayWithKeyValuesArray:data]];
            
            if (data.count > 0) {
                self.tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDataSource)];
                self.start += self.length;
            }else{
                [MBProgressHUD showTextHUDWithText:@"暂无搜索结果" inView:self.view];
            }
            
        }
        [self.tableView reloadData];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)loadMoreDataSource
{
    NSString * keyWord = self.textField.text;
    if (isEmptyString(keyWord)) {
        return;
    }
    
    if (self.textField.isFirstResponder) {
        [self.textField resignFirstResponder];
    }
    
    [DTieSearchRequest cancelRequest];
    
    DTieSearchRequest * request = [[DTieSearchRequest alloc] initWithKeyWord:keyWord lat1:0 lng1:0 lat2:0 lng2:0 startDate:0 endDate:(NSInteger)[DDTool getTimeCurrentWithDouble] sortType:1 dataSources:self.dataSourceType type:2 pageStart:self.start pageSize:self.length];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSArray * data = [response objectForKey:@"data"];
        if (KIsArray(data)) {
            [self.dataSource addObjectsFromArray:[DTieModel mj_objectArrayWithKeyValuesArray:data]];
            
            if (data.count == 0) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [self.tableView.mj_footer endRefreshing];
                self.start += self.length;
            }
            
        }
        [self.tableView reloadData];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self.tableView.mj_footer endRefreshing];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (void)createViews
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[DTieNewTableViewCell class] forCellReuseIdentifier:@"DTieNewTableViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * kMainBoundsWidth / 1080.f);
        make.left.bottom.right.mas_equalTo(0);
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
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.textField.returnKeyType = UIReturnKeySearch;
    self.textField.delegate = self;
    [self.topView addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((60 + kStatusBarHeight) * scale);
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
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTieNewTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieNewTableViewCell" forIndexPath:indexPath];
    
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.row];
    [cell configWithModel:model];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.row];
    DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initWithDTie:model];
    [self.navigationController pushViewController:detail animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    return 620 * scale;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self searchButtonDidClicked];
    
    return YES;
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

@end
