//
//  SeriesViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SeriesViewController.h"
#import "SeriesTableViewCell.h"
#import "SeriesTableHeaderView.h"
#import "GetSeriesRequest.h"
#import "MBProgressHUD+DDHUD.h"
#import "AddSeriesViewController.h"
#import "SeriesDetailRequest.h"
#import "SeriesDetailModel.h"
#import "SeriesDetailViewController.h"
#import <AFHTTPSessionManager.h>

@interface SeriesViewController ()<UITableViewDelegate, UITableViewDataSource, AddSeriesDelegate>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) NSMutableArray * topArray;
@property (nonatomic, strong) NSMutableArray * seriesArray;

@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation SeriesViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
    [self requestData];
}

- (void)seriesNeedUpdate
{
    [self requestData];
}

#pragma mark - 请求数据
- (void)requestData
{
    GetSeriesRequest * request = [[GetSeriesRequest alloc] init];
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在获取系列" inView:self.view];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self analysisData:data];
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
    }];
}

- (void)analysisData:(NSArray *)data
{
    [self.dataSource removeAllObjects];
    self.topArray = [[NSMutableArray alloc] init];
    self.seriesArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < data.count; i++) {
        NSDictionary * info = [data objectAtIndex:i];
        NSDictionary * dict = [info objectForKey:@"series"];
        SeriesModel * model = [SeriesModel mj_objectWithKeyValues:dict];
        model.seriesFirstPicture = [info objectForKey:@"seriesFirstPicture"];
        if (model.stickyFlag) {
            [self.topArray addObject:model];
        }else{
            [self.seriesArray addObject:model];
        }
    }
    
    if (self.topArray.count > 0) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"stickyTime" ascending:NO];
        [self.topArray sortUsingDescriptors:@[sort]];
        [self.dataSource addObject:self.topArray];
    }
    [self.dataSource addObject:self.seriesArray];
    [self.tableView reloadData];
}

- (void)addSeriesDidClicked
{
    AddSeriesViewController * addSeries = [[AddSeriesViewController alloc] init];
    addSeries.delegate = self;
    [self.navigationController pushViewController:addSeries animated:YES];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 540 * scale;
    [self.tableView registerClass:[SeriesTableViewCell class] forCellReuseIdentifier:@"SeriesTableViewCell"];
    [self.tableView registerClass:[SeriesTableHeaderView class] forHeaderFooterViewReuseIdentifier:@"SeriesTableHeaderView"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.tableView addGestureRecognizer:longPress];
    
    [self createTopView];
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress
{
    CGPoint point = [longPress locationInView:self.tableView];
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if (indexPath) {
        NSArray * data = [self.dataSource objectAtIndex:indexPath.section];
        SeriesModel * model = [data objectAtIndex:indexPath.row];
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"选择" message:@"请选择需要进行的操作" preferredStyle:UIAlertControllerStyleActionSheet];
        
        //进行了置顶操作
        UIAlertAction * action1;
        
        if (model.stickyFlag) {
            action1 = [UIAlertAction actionWithTitle:@"取消置顶" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                
                NSString * url = [NSString stringWithFormat:@"%@/series/cancelStickySeries", HOSTURL];
                [manager POST:url parameters:@{@"seriesId":@(model.cid)} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                    
                } progress:^(NSProgress * _Nonnull uploadProgress) {
                    
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [self requestData];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    
                }];
                
            }];
        }else{
            action1 = [UIAlertAction actionWithTitle:@"置顶系列" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                
                NSString * url = [NSString stringWithFormat:@"%@/series/stickySeries", HOSTURL];
                [manager POST:url parameters:@{@"seriesId":@(model.cid)} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                    
                } progress:^(NSProgress * _Nonnull uploadProgress) {
                    
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [self requestData];
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    
                }];
                
            }];
        }
        
        
        UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"删除系列" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            
            NSString * url = [NSString stringWithFormat:@"%@/series/deleteSeries", HOSTURL];
            [manager POST:url parameters:@{@"id":@(model.cid)} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self requestData];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
            }];
            
        }];
        
        [alert addAction:action1];
        [alert addAction:action2];
        
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:DDLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * result = [self.dataSource objectAtIndex:indexPath.section];
    SeriesModel * model = [result objectAtIndex:indexPath.row];
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"获取系列" inView:self.view];
    SeriesDetailRequest * request = [[SeriesDetailRequest alloc] initWithSeriesID:model.cid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                SeriesDetailModel * tempModel = [SeriesDetailModel mj_objectWithKeyValues:data];
                if (model.seriesStatus) {
                    AddSeriesViewController * detail = [[AddSeriesViewController alloc] initWithSeriesModel:tempModel seriesID:model.cid];
                    [self.navigationController pushViewController:detail animated:YES];
                }else{
                    SeriesDetailViewController * detail = [[SeriesDetailViewController alloc] initWithSeriesModel:tempModel];
                    [self.navigationController pushViewController:detail animated:YES];
                }
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * data = [self.dataSource objectAtIndex:section];
    
//    if (data == self.seriesArray && self.seriesArray.count == 0) {
//        return 1;
//    }
    
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SeriesTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"SeriesTableViewCell" forIndexPath:indexPath];
    
    NSArray * data = [self.dataSource objectAtIndex:indexPath.section];
    
//    if (data == self.seriesArray && self.seriesArray.count == 0) {
//        return cell;
//    }
    
    SeriesModel * model = [data objectAtIndex:indexPath.row];
    [cell configWithModel:model];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSArray * data = [self.dataSource objectAtIndex:indexPath.section];
//
//    if (data == self.seriesArray && self.seriesArray.count == 0) {
//        return .1f;
//    }
    
    return 330 * kMainBoundsWidth / 1080.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    SeriesTableHeaderView * view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SeriesTableHeaderView"];
    
    if (self.dataSource.count == 2) {
        if (section == 0) {
            [view configWithSetTop:YES];
        }else{
            [view configWithSetTop:NO];
            __weak typeof(self) weakSelf = self;
            view.addSeriesHandle = ^{
                [weakSelf addSeriesDidClicked];
            };
        }
    }else{
        [view configWithSetTop:NO];
        __weak typeof(self) weakSelf = self;
        view.addSeriesHandle = ^{
            [weakSelf addSeriesDidClicked];
        };
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.dataSource.count == 1) {
        return 340 * kMainBoundsWidth / 1080.f;
    }else{
        if (section == 0) {
            return 120 * kMainBoundsWidth / 1080.f;
        }else{
            return 340 * kMainBoundsWidth / 1080.f;
        }
    }
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
    titleLabel.text = @"D帖系列";
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
