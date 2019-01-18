//
//  DDGroupPostManagerController.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/10.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDGroupPostManagerController.h"
#import "DDGroupPostTableViewCell.h"
#import "DDGroupRequest.h"
#import <MJRefresh.h>
#import "MBProgressHUD+DDHUD.h"
#import "DTieNewDetailViewController.h"
#import "DTieDetailRequest.h"
#import "MBProgressHUD+DDHUD.h"

@interface DDGroupPostManagerController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) DDGroupModel * model;

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UIButton * peopleButton;
@property (nonatomic, strong) UIButton * applyButton;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, assign) NSInteger type; //1为已有群，2为其它公开群

@end

@implementation DDGroupPostManagerController

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
    
    self.type = 1;
    [self createViews];
    [self requestDataSource];
}

- (void)requestDataSource
{
    if (self.type == 1) {
        DDGroupRequest * request = [[DDGroupRequest alloc] initGroupPostListWithGroupID:self.model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.dataSource removeAllObjects];
                for (NSDictionary * dict in data) {
                    DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                    model.groupListID = [dict objectForKey:@"id"];
                    model.cid = model.postId;
                    [self.dataSource addObject:model];
                }
                
                [self.tableView reloadData];
            }
            [self.tableView.mj_header endRefreshing];
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [self.tableView.mj_header endRefreshing];
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            [self.tableView.mj_header endRefreshing];
        }];
        
    }else{
        DDGroupRequest * request = [[DDGroupRequest alloc] initApplyPostListWithGroupID:self.model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                
                [self.dataSource removeAllObjects];
                for (NSDictionary * dict in data) {
                    DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                    model.groupListID = [dict objectForKey:@"id"];
                    model.cid = model.postId;
                    [self.dataSource addObject:model];
                }
                
                [self.tableView reloadData];
            }
            [self.tableView.mj_header endRefreshing];
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [self.tableView.mj_header endRefreshing];
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            [self.tableView.mj_header endRefreshing];
        }];
    }
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 360.f;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 220 * scale;
    [self.tableView registerClass:[DDGroupPostTableViewCell class] forCellReuseIdentifier:@"DDGroupPostTableViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((364 + kStatusBarHeight) * kMainBoundsWidth / 1080.f);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestDataSource)];
    
    [self createTopView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDGroupPostTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DDGroupPostTableViewCell" forIndexPath:indexPath];
    
    DTieModel * dtie = [self.dataSource objectAtIndex:indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    
    if (self.type == 1) {
        [cell configPostWithModel:dtie];
        cell.toApplyButtonHandle = ^(DTieModel * _Nonnull model) {
            [weakSelf moveToApplyWithModel:model];
        };
    }else{
        [cell configApplyWithModel:dtie];
        cell.applyButtonHandle = ^(DTieModel * _Nonnull model) {
            [weakSelf applyWithModel:model state:YES];
        };
        cell.deleteButtonHandle = ^(DTieModel * _Nonnull model) {
            [weakSelf applyWithModel:model state:NO];
        };
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTieModel * dtie = [self.dataSource objectAtIndex:indexPath.row];
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:self.view];
    
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:dtie.cid type:4 start:0 length:10];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        
        if (KIsDictionary(response)) {
            
            NSInteger code = [[response objectForKey:@"status"] integerValue];
            if (code == 4002) {
                [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"PageHasDelete") inView:self.view];
                return;
            }
            
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                
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

- (void)moveToApplyWithModel:(DTieModel *)model
{
    DDGroupRequest * request = [[DDGroupRequest alloc] initMovePost:model.cid toApplyGroup:self.model.cid];
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:self.view];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"操作成功" inView:self.view];
        
        NSInteger index = [self.dataSource indexOfObject:model];
        [self.dataSource removeObject:model];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        NSString * msg = [response objectForKey:@"msg"];
        if (isEmptyString(msg)) {
            msg = @"操作失败";
        }
        [MBProgressHUD showTextHUDWithText:msg inView:self.view];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"操作失败" inView:self.view];
    }];
}

- (void)applyWithModel:(DTieModel *)model state:(BOOL)state
{
    DDGroupRequest * request = [[DDGroupRequest alloc] initApplyPostWithID:model.groupListID state:state];
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:self.view];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"操作成功" inView:self.view];
        
        NSInteger index = [self.dataSource indexOfObject:model];
        [self.dataSource removeObject:model];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        NSString * msg = [response objectForKey:@"msg"];
        if (isEmptyString(msg)) {
            msg = @"操作失败";
        }
        [MBProgressHUD showTextHUDWithText:msg inView:self.view];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"操作失败" inView:self.view];
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
        make.left.mas_equalTo(25 * scale);
        make.bottom.mas_equalTo(-160 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    titleLabel.text = @"群贴管理";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale - 144 * scale);
    }];
    
    self.peopleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"已加入的群帖"];
    [self.peopleButton addTarget:self action:@selector(peopleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.peopleButton];
    [self.peopleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(-10 * scale);
        make.width.mas_equalTo(kMainBoundsWidth / 2.f);
    }];
    
    UIView * lineView1 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView1.backgroundColor = [UIColorFromRGB(0xFFFFFF) colorWithAlphaComponent:.5f];
    [self.peopleButton addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.width.mas_equalTo(3 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    
    self.applyButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"待审批的群帖"];
    [self.applyButton addTarget:self action:@selector(applyButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.applyButton];
    [self.applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0 * scale);
        make.bottom.mas_equalTo(-10 * scale);
        make.width.mas_equalTo(kMainBoundsWidth / 2.f);
    }];
    self.applyButton.alpha = .5f;
}

- (void)peopleButtonDidClicked
{
    if (self.type == 2) {
        self.type = 1;
        self.applyButton.alpha = .5f;
        self.peopleButton.alpha = 1.f;
        
        [self.dataSource removeAllObjects];
        [self.tableView reloadData];
        [self requestDataSource];
    }
}

- (void)applyButtonDidClicked
{
    if (self.type == 1) {
        self.type = 2;
        self.applyButton.alpha = 1.f;
        self.peopleButton.alpha = .5f;
        
        [self.dataSource removeAllObjects];
        [self.tableView reloadData];
        [self requestDataSource];
    }
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
