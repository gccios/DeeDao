//
//  DTieGroupViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/14.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DTieGroupViewController.h"
#import "DTieAddGroupTableViewCell.h"
#import "DDGroupRequest.h"
#import "MBProgressHUD+DDHUD.h"
#import <MJRefresh.h>
#import "DDGroupSearchViewController.h"

@interface DTieGroupViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) DTieModel * model;

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@end

@implementation DTieGroupViewController

- (instancetype)initWithModel:(DTieModel *)model
{
    if (self = [super init]) {
        self.model = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    DDGroupModel * myModel = [[DDGroupModel alloc] initWithMy];
//    [self.dataSource addObject:myModel];
    
    DDGroupModel * otherModel = [[DDGroupModel alloc] initWithPublic];
    [self.dataSource addObject:otherModel];
    
    [self createViews];
    [self createTopView];
    
    [self setupData];
}

- (void)setupData
{
    DDGroupRequest * request = [[DDGroupRequest alloc] initAddGroupListWithPostID:self.model.cid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSArray * data = [response objectForKey:@"data"];
        if (KIsArray(data)) {
            [self.dataSource removeAllObjects];
            
//            DDGroupModel * myModel = [[DDGroupModel alloc] initWithMy];
//            [self.dataSource addObject:myModel];
            
            DDGroupModel * otherModel = [[DDGroupModel alloc] initWithPublic];
            [self.dataSource addObject:otherModel];
            
            [self.dataSource addObjectsFromArray:[DDGroupModel mj_objectArrayWithKeyValuesArray:data]];
        }
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self.tableView.mj_header endRefreshing];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 360.f;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 195 * scale;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[DTieAddGroupTableViewCell class] forCellReuseIdentifier:@"DTieAddGroupTableViewCell"];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(setupData)];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * kMainBoundsWidth / 1080.f);
        make.left.bottom.right.mas_equalTo(0);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTieAddGroupTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieAddGroupTableViewCell" forIndexPath:indexPath];
    
    DDGroupModel * model = [self.dataSource objectAtIndex:indexPath.row];
    [cell configWithModel:model DtieModel:self.model];
    
    __weak typeof(self) weakSelf = self;
    cell.addButtonHandle = ^(DDGroupModel * _Nonnull model) {
        [weakSelf addWithGroup:model];
    };
    cell.cancleButtonHandle = ^(DDGroupModel * _Nonnull model) {
        [weakSelf cancleWithGroup:model];
    };
    
    return cell;
}

- (void)addWithGroup:(DDGroupModel *)model
{
    if (model.cid == -2) {
        
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在投放" inView:self.view];
        DDGroupRequest * request = [[DDGroupRequest alloc] initEditPost:self.model.cid accountFlg:1];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"已投放至公开群" inView:self.view];
            self.model.landAccountFlg = 1;
            [self.tableView reloadData];
            if (self.delegate && [self.delegate respondsToSelector:@selector(DTieGroupNeedUpdate)]) {
                [self.delegate DTieGroupNeedUpdate];
            }
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [hud hideAnimated:YES];
            NSString * msg = [response objectForKey:@"msg"];
            if (isEmptyString(msg)) {
                msg = @"投放失败";
            }
            [MBProgressHUD showTextHUDWithText:msg inView:[UIApplication sharedApplication].keyWindow];
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"投放失败" inView:[UIApplication sharedApplication].keyWindow];
            
        }];
        
    }else{
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在申请投放" inView:self.view];
        DDGroupRequest * request = [[DDGroupRequest alloc] initAddPost:self.model.cid toGroup:model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"投放申请已发出" inView:self.view];
            
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                model.postFlag = [[data objectForKey:@"postFlag"] integerValue];
                [self.model.groupArray insertObject:model atIndex:0];
            }else{
                model.postFlag = 2;
                [self.model.groupArray insertObject:model atIndex:0];
            }
            
            [self.tableView reloadData];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(DTieGroupNeedUpdate)]) {
                [self.delegate DTieGroupNeedUpdate];
            }
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [hud hideAnimated:YES];
            NSString * msg = [response objectForKey:@"msg"];
            if (isEmptyString(msg)) {
                msg = @"投放失败";
            }
            [MBProgressHUD showTextHUDWithText:msg inView:[UIApplication sharedApplication].keyWindow];
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"投放失败" inView:[UIApplication sharedApplication].keyWindow];
            
        }];
    }
}

- (void)cancleWithGroup:(DDGroupModel *)model
{
    if (self.model.authorId != [UserManager shareManager].user.cid) {
        [MBProgressHUD showTextHUDWithText:@"只有作者才可取消投放" inView:self.view];
        return;
    }
    
    if (model.cid == -2) {
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在取消投放" inView:self.view];
        DDGroupRequest * request = [[DDGroupRequest alloc] initEditPost:self.model.cid accountFlg:0];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"已取消投放公开群" inView:self.view];
            self.model.landAccountFlg = 0;
            [self.tableView reloadData];
            if (self.delegate && [self.delegate respondsToSelector:@selector(DTieGroupNeedUpdate)]) {
                [self.delegate DTieGroupNeedUpdate];
            }
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [hud hideAnimated:YES];
            NSString * msg = [response objectForKey:@"msg"];
            if (isEmptyString(msg)) {
                msg = @"取消投放失败";
            }
            [MBProgressHUD showTextHUDWithText:msg inView:[UIApplication sharedApplication].keyWindow];
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"取消投放失败" inView:[UIApplication sharedApplication].keyWindow];
            
        }];
    }else{
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在取消投放" inView:self.view];
        DDGroupRequest * request = [[DDGroupRequest alloc] initRemovePost:self.model.cid fromGroup:model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"已取消投放" inView:self.view];
            model.postFlag = 0;
            
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"cid == %d", model.cid];
            NSArray * tempArray = [self.model.groupArray filteredArrayUsingPredicate:predicate];
            if (tempArray.count > 0) {
                [self.model.groupArray removeObjectsInArray:tempArray];
            }
            
            [self.tableView reloadData];
            if (self.delegate && [self.delegate respondsToSelector:@selector(DTieGroupNeedUpdate)]) {
                [self.delegate DTieGroupNeedUpdate];
            }
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [hud hideAnimated:YES];
            NSString * msg = [response objectForKey:@"msg"];
            if (isEmptyString(msg)) {
                msg = @"取消投放失败";
            }
            [MBProgressHUD showTextHUDWithText:msg inView:[UIApplication sharedApplication].keyWindow];
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"取消投放失败" inView:[UIApplication sharedApplication].keyWindow];
            
        }];
        
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
    titleLabel.text = @"选择群";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
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
    DDGroupSearchViewController * search = [[DDGroupSearchViewController alloc] initWithAddDtieModel:self.model];
    [self.navigationController pushViewController:search animated:YES];
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
