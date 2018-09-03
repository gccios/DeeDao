//
//  WYYListViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "WYYListViewController.h"
#import "WXHistoryTableViewCell.h"
#import "FanjuTableViewCell.h"
#import <MJRefresh.h>
#import "DTieSearchRequest.h"
#import "DDTool.h"
#import "MBProgressHUD+DDHUD.h"
#import "DTieDetailRequest.h"
#import "DTieNewDetailViewController.h"
#import "SelectFanjuRequest.h"
#import <AFHTTPSessionManager.h>
#import "DDNavigationViewController.h"
#import "DTieSearchViewController.h"
#import "DDBackWidow.h"

@interface WYYListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UIButton * zujuButton;
@property (nonatomic, strong) UIButton * ganxingquButton;

@property (nonatomic, strong) NSMutableArray * zujuSource;
@property (nonatomic, strong) UITableView * zujuTableView;
@property (nonatomic, strong) NSMutableArray * ganxingquSource;
@property (nonatomic, strong) UITableView * ganxingquTableView;

@property (nonatomic, assign) NSInteger pageIndex;

@property (nonatomic, assign) NSInteger zujuStart;
@property (nonatomic, assign) NSInteger zujuSize;
@property (nonatomic, assign) NSInteger ganxingquStart;
@property (nonatomic, assign) NSInteger ganxingquSize;

@end

@implementation WYYListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.pageIndex = 1;
    
    self.zujuSource = [[NSMutableArray alloc] init];
    self.ganxingquSource = [[NSMutableArray alloc] init];
    
    [self createViews];
    [self creatTopView];
    
    [self requestZujuMessage];
    [self requestGanxingquMessage];
}

- (void)requestZujuMessage
{
    [SelectFanjuRequest cancelRequest];
    self.zujuStart = 0;
    self.zujuSize = 20;
    SelectFanjuRequest * request = [[SelectFanjuRequest alloc] initWithStart:self.zujuStart size:self.zujuSize];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.zujuSource removeAllObjects];
                
                for (NSDictionary * dict in data) {
                    DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                    NSDictionary * postBean = [dict objectForKey:@"postBean"];
                    [model mj_setKeyValues:postBean];
                    [self.zujuSource addObject:model];
                }
                
                self.zujuStart += self.zujuSize;
                
                if (self.zujuTableView) {
                    [self.zujuTableView reloadData];
                    [self.zujuTableView.mj_footer resetNoMoreData];
                }
            }
        }
        
        if (self.zujuTableView) {
            [self.zujuTableView.mj_header endRefreshing];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (self.zujuTableView) {
            [self.zujuTableView.mj_header endRefreshing];
        }
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        if (self.zujuTableView) {
            [self.zujuTableView.mj_header endRefreshing];
        }
        
    }];
}

- (void)loadMoreZujuMessage
{
    SelectFanjuRequest * request = [[SelectFanjuRequest alloc] initWithStart:self.zujuStart size:self.zujuSize];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                if (data.count > 0) {
                    
                    for (NSDictionary * dict in data) {
                        DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                        NSDictionary * postBean = [dict objectForKey:@"postBean"];
                        [model mj_setKeyValues:postBean];
                        [self.zujuSource addObject:model];
                    }
                    
                    self.zujuStart += self.zujuSize;
                    
                    [self.zujuTableView reloadData];
                    [self.zujuTableView.mj_footer endRefreshing];
                    
                }else{
                    [self.zujuTableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.zujuTableView.mj_footer endRefreshing];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [self.zujuTableView.mj_footer endRefreshing];
        
    }];
}

- (void)requestGanxingquMessage
{
    [DTieSearchRequest cancelRequest];
    self.ganxingquStart = 0;
    self.ganxingquSize = 20;
    DTieSearchRequest * request = [[DTieSearchRequest alloc] initWithKeyWord:@"" lat1:0 lng1:0 lat2:0 lng2:0 startDate:0 endDate:(NSInteger)[DDTool getTimeCurrentWithDouble] sortType:1 dataSources:9 type:2 pageStart:self.ganxingquStart pageSize:self.ganxingquSize];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.ganxingquSource removeAllObjects];
                
                [self.ganxingquSource addObjectsFromArray:[DTieModel mj_objectArrayWithKeyValuesArray:data]];
                
                self.ganxingquStart += self.ganxingquSize;
                
                if (self.ganxingquTableView) {
                    [self.ganxingquTableView reloadData];
                    [self.ganxingquTableView.mj_footer resetNoMoreData];
                }
            }
        }
        
        if (self.ganxingquTableView) {
            [self.ganxingquTableView.mj_header endRefreshing];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (self.ganxingquTableView) {
            [self.ganxingquTableView.mj_header endRefreshing];
        }
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        if (self.ganxingquTableView) {
            [self.ganxingquTableView.mj_header endRefreshing];
        }
        
    }];
}

- (void)loadMoreGanxingquMessage
{
    DTieSearchRequest * request = [[DTieSearchRequest alloc] initWithKeyWord:@"" lat1:0 lng1:0 lat2:0 lng2:0 startDate:0 endDate:(NSInteger)[DDTool getTimeCurrentWithDouble] sortType:1 dataSources:9 type:2 pageStart:self.ganxingquStart pageSize:self.ganxingquSize];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                if (data.count > 0) {
                    [self.ganxingquSource addObjectsFromArray:[DTieModel mj_objectArrayWithKeyValuesArray:data]];
                    
                    self.ganxingquStart += self.ganxingquSize;
                    
                    [self.ganxingquTableView reloadData];
                    [self.ganxingquTableView.mj_footer endRefreshing];
                    
                }else{
                    [self.ganxingquTableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.ganxingquTableView.mj_footer endRefreshing];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [self.ganxingquTableView.mj_footer endRefreshing];
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.zujuTableView) {
        return self.zujuSource.count;
    }else if (tableView == self.ganxingquTableView) {
        return self.ganxingquSource.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.zujuTableView) {
        DTieModel * model = [self.zujuSource objectAtIndex:indexPath.row];
        
        FanjuTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FanjuTableViewCell" forIndexPath:indexPath];
        
        [cell configWithModel:model];
        
        return cell;
    }else if (tableView == self.ganxingquTableView) {
        DTieModel * model = [self.ganxingquSource objectAtIndex:indexPath.row];
        
        WXHistoryTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"WXHistoryTableViewCell" forIndexPath:indexPath];
        
        [cell configWithModel:model];
        
        return cell;
    }
    
    WXHistoryTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"WXHistoryTableViewCell" forIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    if (tableView == self.zujuTableView) {
        return 800 * scale;
    }
    
    return 700 * scale;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTieModel * model;
    if (tableView == self.zujuTableView) {
        model = [self.zujuSource objectAtIndex:indexPath.row];
    }else if (tableView == self.ganxingquTableView) {
        model = [self.ganxingquSource objectAtIndex:indexPath.row];
    }
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:self.view];
    
    NSInteger postID = model.postId;
    if (postID == 0) {
        postID = model.cid;
    }
    
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:postID type:4 start:0 length:10];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        
        if (KIsDictionary(response)) {
            
            NSInteger code = [[response objectForKey:@"status"] integerValue];
            if (code == 4002) {
                [MBProgressHUD showTextHUDWithText:@"该帖已被作者删除~" inView:self.view];
                
                if (tableView == self.zujuTableView) {
                    [self.zujuSource removeObject:model];
                }else if (tableView == self.ganxingquTableView) {
                    [self.ganxingquSource removeObject:model];
                }
                [tableView reloadData];
                [self deletePostWithModel:postID];
                
                return;
            }
            
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                
                if (dtieModel.deleteFlg == 1) {
                    [MBProgressHUD showTextHUDWithText:@"该帖已被作者删除~" inView:self.view];
                    
                    if (tableView == self.zujuTableView) {
                        [self.zujuSource removeObject:model];
                    }else if (tableView == self.ganxingquTableView) {
                        [self.ganxingquSource removeObject:model];
                    }
                    [tableView reloadData];
                    [self deletePostWithModel:postID];
                    
                    return;
                }
                
                if (dtieModel.landAccountFlg == 2 && dtieModel.authorId != [UserManager shareManager].user.cid) {
                    [MBProgressHUD showTextHUDWithText:@"该帖已被作者设为私密状态" inView:[UIApplication sharedApplication].keyWindow];
                    return;
                }
                
                DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initWithDTie:dtieModel];
                [self.navigationController pushViewController:detail animated:YES];
            }else{
                NSString * msg = [response objectForKey:@"msg"];
                if (!isEmptyString(msg)) {
                    [MBProgressHUD showTextHUDWithText:msg inView:self.view];
                }
            }
        }
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
    }];
}

- (void)deletePostWithModel:(NSInteger)postID
{
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString * url = [NSString stringWithFormat:@"%@/post/collection/deleteAllPostCollection", HOSTURL];
    [manager POST:url parameters:@{@"postId":@(postID)} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.zujuTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.zujuTableView.backgroundColor = self.view.backgroundColor;
    self.zujuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.zujuTableView registerClass:[FanjuTableViewCell class] forCellReuseIdentifier:@"FanjuTableViewCell"];
    self.zujuTableView.delegate = self;
    self.zujuTableView.dataSource = self;
    [self.view addSubview:self.zujuTableView];
    [self.zujuTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((364 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.zujuTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestZujuMessage)];
    self.zujuTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreZujuMessage)];
    
    self.ganxingquTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.ganxingquTableView.backgroundColor = self.view.backgroundColor;
    self.ganxingquTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.ganxingquTableView registerClass:[WXHistoryTableViewCell class] forCellReuseIdentifier:@"WXHistoryTableViewCell"];
    self.ganxingquTableView.delegate = self;
    self.ganxingquTableView.dataSource = self;
    [self.view addSubview:self.ganxingquTableView];
    [self.ganxingquTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((364 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.ganxingquTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestGanxingquMessage)];
    self.ganxingquTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreGanxingquMessage)];
    self.ganxingquTableView.hidden = YES;
}

- (void)creatTopView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.topView = [[UIView alloc] init];
    self.topView.userInteractionEnabled = YES;
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo((364 + kStatusBarHeight) * scale);
    }];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, (364 + kStatusBarHeight) * scale);
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
        make.bottom.mas_equalTo(-159 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    titleLabel.text = @"约这列表记录";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale - 144 * scale);
    }];
    
    CGFloat buttonWidth = kMainBoundsWidth / 2.f;
    self.zujuButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"组局中的"];
    [self.topView addSubview:self.zujuButton];
    [self.zujuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(144 * scale);
    }];
    
    self.ganxingquButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"感兴趣的"];
    self.ganxingquButton.alpha = .5f;
    [self.topView addSubview:self.ganxingquButton];
    [self.ganxingquButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(144 * scale);
    }];
    
    UIView * lineView1 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView1.alpha = .5f;
    lineView1.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.zujuButton addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(3 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    
    [self.zujuButton addTarget:self action:@selector(tabButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.ganxingquButton addTarget:self action:@selector(tabButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * searchButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:searchButton];
    [searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-40 * scale);
        make.centerY.mas_equalTo(titleLabel);
        make.width.height.mas_equalTo(100 * scale);
    }];
}

- (void)searchButtonDidClicked
{
    DTieSearchViewController * search = [[DTieSearchViewController alloc] init];
    DDNavigationViewController * na = [[DDNavigationViewController alloc] initWithRootViewController:search];
    [self presentViewController:na animated:YES completion:nil];
    [[DDBackWidow shareWindow] hidden];
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tabButtonDidClicked:(UIButton *)button
{
    if (button == self.zujuButton) {
        self.pageIndex = 1;
    }else if (button == self.ganxingquButton) {
        self.pageIndex = 2;
    }
    [self reloadPageStatus];
}

- (void)reloadPageStatus
{
    if (self.pageIndex == 1) {
        
        self.zujuButton.alpha = 1.f;
        self.ganxingquButton.alpha = .5f;
        
        self.zujuTableView.hidden = NO;
        self.ganxingquTableView.hidden = YES;
        
        if (self.zujuSource.count == 0) {
            [self requestZujuMessage];
        }
        
    }else if (self.pageIndex == 2) {
        
        self.zujuButton.alpha = .5f;
        self.ganxingquButton.alpha = 1.f;
        
        self.zujuTableView.hidden = YES;
        self.ganxingquTableView.hidden = NO;
        
        if (self.ganxingquSource.count == 0) {
            [self requestGanxingquMessage];
        }
        
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[DDBackWidow shareWindow] show];
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
