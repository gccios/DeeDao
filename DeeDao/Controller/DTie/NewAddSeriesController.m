//
//  NewAddSeriesController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/7.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "NewAddSeriesController.h"
#import "DTieChooseDTieController.h"
#import "MBProgressHUD+DDHUD.h"
#import "NewSeriesTableViewCell.h"
#import "CreateOrUpdateSeriesRequest.h"
#import "UserManager.h"
#import "DTieDetailRequest.h"
#import "DTieNewDetailViewController.h"
#import "DTieNewEditViewController.h"
#import "DeletePostFromSeriesRequest.h"
#import "RTDragCellTableView.h"

@interface NewAddSeriesController ()<RTDragCellTableViewDelegate, RTDragCellTableViewDataSource, DTieChooseDTieControllerDelegate>

@property (nonatomic, strong) SeriesModel * seriesModel;
@property (nonatomic, strong) SeriesDetailModel * model;

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) RTDragCellTableView * tableView;
@property (nonatomic, strong) UITextField * titleField;

@property (nonatomic, strong) NSMutableArray * dataSource;

@end

@implementation NewAddSeriesController

- (instancetype)initWithDataSource:(NSArray *)dataSource series:(SeriesModel *)seriesModel
{
    if (self = [super init]) {
        self.seriesModel = seriesModel;
        self.dataSource = [[NSMutableArray alloc] initWithArray:dataSource];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createViews];
}

- (NSArray *)originalArrayDataForTableView:(RTDragCellTableView *)tableView
{
    return self.dataSource;
}

- (void)tableView:(RTDragCellTableView *)tableView newArrayDataForDataSource:(NSArray *)newArray
{
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:newArray];
//    [tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewSeriesTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"NewSeriesTableViewCell" forIndexPath:indexPath];
    
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.row];
    [cell configWithModel:model];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.titleField.isFirstResponder) {
        [self.titleField resignFirstResponder];
    }
    
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.row];
    
    NSInteger postID = model.postId;
    if (postID == 0) {
        postID = model.cid;
    }
    if (model.status == 0) {
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在获取草稿" inView:self.view];
        
        DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:postID type:4 start:0 length:10];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
            
            if (KIsDictionary(response)) {
                NSDictionary * data = [response objectForKey:@"data"];
                if (KIsDictionary(data)) {
                    DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                    dtieModel.postId = model.postId;
                    DTieNewEditViewController * edit = [[DTieNewEditViewController alloc] initWithDtieModel:dtieModel];
                    [self.navigationController pushViewController:edit animated:YES];
                }
            }
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            [hud hideAnimated:YES];
        }];
    }else{
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:self.view];
        
        DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:postID type:4 start:0 length:10];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
            
            if (KIsDictionary(response)) {
                
                NSInteger code = [[response objectForKey:@"status"] integerValue];
                if (code == 4002) {
                    [MBProgressHUD showTextHUDWithText:@"该帖已被删除~" inView:self.view];
                    return;
                }
                
                NSDictionary * data = [response objectForKey:@"data"];
                if (KIsDictionary(data)) {
                    DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                    
                    if (dtieModel.deleteFlg == 1) {
                        [MBProgressHUD showTextHUDWithText:@"该帖已被删除~" inView:self.view];
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
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.tableView = [[RTDragCellTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 312 * scale;
    [self.tableView registerClass:[NewSeriesTableViewCell class] forCellReuseIdentifier:@"NewSeriesTableViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.tableView.contentInset = UIEdgeInsetsMake(60 * scale, 0, 324 * scale, 0);
    
    [self createTableHeaderFooter];
    
    UIButton * leftHandleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"Import D Page")];
    [DDViewFactoryTool cornerRadius:24 * scale withView:leftHandleButton];
    leftHandleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    leftHandleButton.layer.borderWidth = 3 * scale;
    [self.view addSubview:leftHandleButton];
    [leftHandleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.width.mas_equalTo(444 * scale);
        make.height.mas_equalTo(144 * scale);
        make.bottom.mas_equalTo(-90 * scale);
    }];
    
    UIButton * rightHandleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"Yes")];
    [DDViewFactoryTool cornerRadius:24 * scale withView:rightHandleButton];
    rightHandleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    rightHandleButton.layer.borderWidth = 3 * scale;
    [self.view addSubview:rightHandleButton];
    [rightHandleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.width.mas_equalTo(444 * scale);
        make.height.mas_equalTo(144 * scale);
        make.bottom.mas_equalTo(-90 * scale);
    }];
    
    [leftHandleButton addTarget:self action:@selector(leftButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [rightHandleButton addTarget:self action:@selector(rightButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self createTopView];
}

- (void)endEdit
{
    if (self.titleField.isFirstResponder) {
        [self.titleField resignFirstResponder];
    }
}

- (void)tableViewDidSwipe:(UISwipeGestureRecognizer *)swipe
{
    CGPoint point = [swipe locationInView:self.tableView];
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if (indexPath && indexPath.row < self.dataSource.count) {
        
        DTieModel * model = [self.dataSource objectAtIndex:indexPath.row];
        NSInteger postID = model.postId;
        if (postID == 0) {
            postID = model.cid;
        }
//        [self deleteSeriesWithID:postID];
        
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    }
}

- (void)deleteSeriesWithID:(NSInteger)postID
{
    DeletePostFromSeriesRequest * request = [[DeletePostFromSeriesRequest alloc] initWithPostID:postID];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {

    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {

    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {

    }];
}


- (void)leftButtonDidClicked
{
    DTieChooseDTieController * choose = [[DTieChooseDTieController alloc] init];
    choose.delegate = self;
    [self.navigationController pushViewController:choose animated:YES];
}

- (void)didChooseDtie:(NSArray *)array
{
    [self.dataSource addObjectsFromArray:array];
    [self.tableView reloadData];
}

- (void)rightButtonDidClicked
{
    if (self.dataSource.count == 0) {
        [MBProgressHUD showTextHUDWithText:@"请先导入帖子" inView:self.view];
        return;
    }
    
    NSString * title = self.titleField.text;
    if (isEmptyString(title)) {
        [MBProgressHUD showTextHUDWithText:@"请输入标题" inView:self.view];
        return;
    }
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在创建" inView:self.view];
    
    NSMutableArray * postIdList = [[NSMutableArray alloc] init];
    for (DTieModel * model in self.dataSource) {
        NSInteger postID = model.postId;
        if (postID == 0) {
            postID = model.cid;
        }
        [postIdList addObject:@(postID)];
    }
    
    CreateOrUpdateSeriesRequest * request;
    if (self.seriesModel) {
        request = [[CreateOrUpdateSeriesRequest alloc] initWithStatus:1 seriesId:self.seriesModel.cid seriesTitle:title seriesType:self.seriesModel.seriesType stickyFlag:self.seriesModel.stickyFlag seriesOwnerId:self.seriesModel.seriesOwnerId createPerson:[UserManager shareManager].user.cid seriesDesc:self.seriesModel.seriesDesc deleteFlg:self.seriesModel.deleteFlg seriesCollectionId:self.seriesModel.seriesCollectionId postIdList:postIdList];
    }else{
        request = [[CreateOrUpdateSeriesRequest alloc] initWithStatus:1 seriesId:0 seriesTitle:title seriesType:0 stickyFlag:0 seriesOwnerId:[UserManager shareManager].user.cid createPerson:[UserManager shareManager].user.cid seriesDesc:@"" deleteFlg:0 seriesCollectionId:0 postIdList:postIdList];
    }
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        
//        if (self.delegate && [self.delegate respondsToSelector:@selector(seriesNeedUpdate)]) {
//            [self.delegate seriesNeedUpdate];
//        }
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-3] animated:YES];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
    }];
}

- (void)createTableHeaderFooter
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 144 * scale)];
    headerView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    titleLabel.text = [NSString stringWithFormat:@"%@：", DDLocalizedString(@"Theme")];
    [headerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.top.bottom.mas_equalTo(0);
    }];
    
    self.titleField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.titleField.placeholder = @"请输入系列标题";
    self.titleField.font = kPingFangRegular(42 * scale);
    [headerView addSubview:self.titleField];
    [self.titleField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabel.mas_right).offset(20 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.top.bottom.mas_equalTo(0);
    }];
    if (self.seriesModel) {
        self.titleField.text = self.seriesModel.seriesTitle;
    }
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(60 * scale, 160 * scale, kMainBoundsWidth - 120 * scale, 3 * scale)];
    lineView.backgroundColor = [UIColorFromRGB(0x000000) colorWithAlphaComponent:.12f];
    [headerView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleLabel.mas_right).offset(0 * scale);
        make.height.mas_equalTo(3 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.bottom.mas_equalTo(-20 * scale);
    }];
    
    self.tableView.tableHeaderView = headerView;
    
    UISwipeGestureRecognizer * swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewDidSwipe:)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.tableView addGestureRecognizer:swipe];
    
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 120 * scale)];
    footerView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    
    UIView * tipLine = [[UIView alloc] initWithFrame:CGRectZero];
    tipLine.backgroundColor = UIColorFromRGB(0xCCCCCC);
    [footerView addSubview:tipLine];
    [tipLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(3 * scale);
    }];
    
    UILabel * tipLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentCenter];
    tipLabel.text = @"系列只能加入自己的D帖，列表已到最末";
    tipLabel.backgroundColor = footerView.backgroundColor;
    [footerView addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.mas_equalTo(700 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    
    self.tableView.tableFooterView = footerView;
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
    titleLabel.text = DDLocalizedString(@"EditSeries");
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self endEdit];
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
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
