

//
//  AddSeriesViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "AddSeriesViewController.h"
#import "SeriesDetailTableViewCell.h"
#import "SeriesChoosDTieController.h"
#import "DTieDetailRequest.h"
#import "DTieNewEditViewController.h"
#import "MBProgressHUD+DDHUD.h"
#import "UserManager.h"
#import "CreateOrUpdateSeriesRequest.h"
#import "DraftSeriesRequest.h"
#import "SeriesDetailViewController.h"

@interface AddSeriesViewController ()<UITableViewDelegate, UITableViewDataSource, SeriesChoosDTieDelegate>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UITextField * titleField;

@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, strong) DTieModel * currentHandleModel;

@property (nonatomic, strong) SeriesDetailModel * model;
@property (nonatomic, assign) NSInteger seriesID;

@property (nonatomic, strong) NSMutableArray * seriesSource;

@end

@implementation AddSeriesViewController

- (instancetype)initWithSeriesModel:(SeriesDetailModel *)model seriesID:(NSInteger)seriesID
{
    if (self = [super init]) {
        self.model = model;
        self.seriesID = seriesID;
        self.dataSource = [[NSMutableArray alloc] initWithArray:model.postShowDetailRes];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.seriesSource = [[NSMutableArray alloc] init];
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
        DTieNewEditViewController * detail = [[DTieNewEditViewController alloc] initWithDtieModel:model];
        [self.navigationController pushViewController:detail animated:YES];
        return;
    }
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在获取详情" inView:self.view];
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:model.postId type:4 start:0 length:10];
    
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                DTieModel * tempModel = [DTieModel mj_objectWithKeyValues:data];
                DTieNewEditViewController * detail = [[DTieNewEditViewController alloc] initWithDtieModel:tempModel];
                [self.navigationController pushViewController:detail animated:YES];
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
    }];
}

- (void)createTableHeaderFooter
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 210 * scale)];
    headerView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    self.titleField = [[UITextField alloc] initWithFrame:CGRectMake(60 * scale, 20 * scale, kMainBoundsWidth - 120 * scale, 140 * scale)];
    self.titleField.placeholder = @"请输入系列标题";
    self.titleField.font = kPingFangRegular(54 * scale);
    [headerView addSubview:self.titleField];
    if (self.model) {
        self.titleField.text = self.model.seriesTitle;
    }
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(60 * scale, 160 * scale, kMainBoundsWidth - 120 * scale, 3 * scale)];
    lineView.backgroundColor = [UIColorFromRGB(0x000000) colorWithAlphaComponent:.12f];
    [headerView addSubview:lineView];
    
    self.tableView.tableHeaderView = headerView;
    
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 1670 * scale)];
    footerView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    UIView * coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 720 * scale)];
    coverView.backgroundColor = self.view.backgroundColor;
    [footerView addSubview:coverView];
    
    UIButton * addButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(60 * scale, 60 * scale, kMainBoundsWidth - 120 * scale, 600 * scale) font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@""];
    [footerView addSubview:addButton];
    [DDViewFactoryTool addBorderToLayer:addButton];
    [addButton addTarget:self action:@selector(addButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView * addImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"DTieAdd"]];
    [addButton addSubview:addImageView];
    [addImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(180 * scale);
        make.width.height.mas_equalTo(72 * scale);
    }];
    
    UILabel * addLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentCenter];
    addLabel.text = @"选择D帖加入系列";
    [addButton addSubview:addLabel];
    [addLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(310 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
    
    UIButton * seeButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(kMainBoundsWidth - 470 * scale, 780 * scale, 400 * scale, 75 * scale) font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"当前系列权限设置"];
    [seeButton setImage:[UIImage imageNamed:@"qx"] forState:UIControlStateNormal];
    [seeButton addTarget:self action:@selector(seeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:seeButton];
    
    UIButton * fabuButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(60 * scale, 940 * scale, kMainBoundsWidth - 120 * scale, 144 * scale) font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"发布"];
    [footerView addSubview:fabuButton];
    [fabuButton addTarget:self action:@selector(fabuButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [DDViewFactoryTool cornerRadius:24 * scale withView:fabuButton];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth - 120 * scale, 144 * scale);
    [fabuButton.layer insertSublayer:gradientLayer atIndex:0];
    
    UIButton * yulanButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(60 * scale, 1145 * scale, 450 * scale, 144 * scale) font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"预览"];
    [yulanButton addTarget:self action:@selector(yulanButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:yulanButton];
    
    [DDViewFactoryTool cornerRadius:24 * scale withView:yulanButton];
    yulanButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    yulanButton.layer.borderWidth = 3 * scale;
    
    UIButton * saveButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(kMainBoundsWidth - 510 * scale, 1145 * scale, 450 * scale, 144 * scale) font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"保存草稿"];
    [saveButton addTarget:self action:@selector(saveButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:saveButton];
    [DDViewFactoryTool cornerRadius:24 * scale withView:saveButton];
    saveButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    saveButton.layer.borderWidth = 3 * scale;
    
    UIView * tipLine = [[UIView alloc] initWithFrame:CGRectMake(60 * scale, 1395 * scale, kMainBoundsWidth - 120 * scale, 3 * scale)];
    tipLine.backgroundColor = UIColorFromRGB(0xCCCCCC);
    [footerView addSubview:tipLine];
    
    UILabel * tipLabel = [DDViewFactoryTool createLabelWithFrame:CGRectMake((kMainBoundsWidth - 226 * scale) / 2, 1375 * scale, 226 * scale, 40 * scale) font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xCCCCCC) alignment:NSTextAlignmentCenter];
    tipLabel.text = @"小提示";
    tipLabel.backgroundColor = footerView.backgroundColor;
    [footerView addSubview:tipLabel];
    
    UILabel * bottomLabel = [DDViewFactoryTool createLabelWithFrame:CGRectMake(60 * scale, tipLabel.frame.origin.y + tipLabel.frame.size.height + 35 * scale, kMainBoundsWidth - 120 * scale, 120 * scale) font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xCCCCCC) alignment:NSTextAlignmentLeft];
    bottomLabel.text = @"您可以预览确认后再发布，也可以点击发布标签直接发布，或先保存草稿，稍晚编辑后再发布";
    bottomLabel.numberOfLines = 0;
    [footerView addSubview:bottomLabel];
    
    self.tableView.tableFooterView = footerView;
}

- (void)seriesWillInsertWith:(DTieModel *)model
{
    int tempID = (int)model.cid;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"cid == %d", tempID];
    NSArray * tempArray = [self.dataSource filteredArrayUsingPredicate:predicate];
    if (tempArray && tempArray.count > 0) {
        [MBProgressHUD showTextHUDWithText:@"系列中已经存在该Dtie" inView:self.navigationController.view];
    }else{
        [self.dataSource addObject:model];
        [self.tableView reloadData];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 用户交互事件
- (void)addButtonDidClicked
{
    SeriesChoosDTieController * add = [[SeriesChoosDTieController alloc] initWithSource:self.seriesSource];
    add.delegate = self;
    [self.navigationController pushViewController:add animated:YES];
}

- (void)seeButtonDidClicked
{
    
}

- (void)fabuButtonDidClicked
{
    NSString * title = self.titleField.text;
    if (isEmptyString(title)) {
        [MBProgressHUD showTextHUDWithText:@"请输入一个标题" inView:self.view];
        return;
    }
    
    if (self.dataSource.count == 0) {
        [MBProgressHUD showTextHUDWithText:@"请至少选择一个Dtie" inView:self.view];
        return;
    }
    
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for (DTieModel * model in self.dataSource) {
        [array addObject:@(model.postId)];
    }
    
    [self requestDTieWithStatus:0 seriesId:0 seriesTitle:title seriesType:0 stickyFlag:0 seriesOwnerId:[UserManager shareManager].user.cid createPerson:[UserManager shareManager].user.cid seriesDesc:@"" deleteFlg:0 seriesCollectionId:0 postIdList:array];
}

- (void)yulanButtonDidClicked
{
    if (isEmptyString(self.titleField.text)) {
        [MBProgressHUD showTextHUDWithText:@"请输入标题" inView:self.view];
        return;
    }
    
    if (self.dataSource.count == 0) {
        [MBProgressHUD showTextHUDWithText:@"至少需要一个D帖" inView:self.view];
        return;
    }
    
    SeriesDetailViewController * detail = [[SeriesDetailViewController alloc] initWithTitle:self.titleField.text source:self.dataSource];
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)saveButtonDidClicked
{
    NSString * title = self.titleField.text;
    if (isEmptyString(title)) {
        [MBProgressHUD showTextHUDWithText:@"请输入一个标题" inView:self.view];
        return;
    }
    
    if (self.dataSource.count == 0) {
        [MBProgressHUD showTextHUDWithText:@"请至少选择一个Dtie" inView:self.view];
        return;
    }
    
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for (DTieModel * model in self.dataSource) {
        [array addObject:@(model.postId)];
    }
    
    NSInteger seriesID = 0;
    if (self.model) {
        seriesID = self.seriesID;
    }
    [self requestDTieWithStatus:1 seriesId:seriesID seriesTitle:title seriesType:0 stickyFlag:0 seriesOwnerId:[UserManager shareManager].user.cid createPerson:[UserManager shareManager].user.cid seriesDesc:@"" deleteFlg:0 seriesCollectionId:0 postIdList:array];
}

//创建或者更新系列
- (void)requestDTieWithStatus:(NSInteger)status seriesId:(NSInteger)seriesId seriesTitle:(NSString *)seriesTitle seriesType:(NSInteger)seriesType stickyFlag:(NSInteger)stickyFlag seriesOwnerId:(NSInteger)seriesOwnerId createPerson:(NSInteger)createPerson seriesDesc:(NSString *)seriesDesc deleteFlg:(NSInteger)deleteFlg seriesCollectionId:(NSInteger)seriesCollectionId postIdList:(NSArray *)postIdList
{
    if (status) {
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在创建" inView:self.view];
        DraftSeriesRequest * request = [[DraftSeriesRequest alloc] initWithStatus:status seriesId:seriesId seriesTitle:seriesTitle seriesType:seriesType stickyFlag:stickyFlag seriesOwnerId:seriesOwnerId createPerson:createPerson seriesDesc:seriesDesc deleteFlg:deleteFlg seriesCollectionId:seriesCollectionId postIdList:postIdList];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(seriesNeedUpdate)]) {
                [self.delegate seriesNeedUpdate];
            }
            [self.navigationController popViewControllerAnimated:YES];
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            [hud hideAnimated:YES];
        }];
    }else{
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在创建" inView:self.view];
        CreateOrUpdateSeriesRequest * request = [[CreateOrUpdateSeriesRequest alloc] initWithStatus:status seriesId:seriesId seriesTitle:seriesTitle seriesType:seriesType stickyFlag:stickyFlag seriesOwnerId:seriesOwnerId createPerson:createPerson seriesDesc:seriesDesc deleteFlg:deleteFlg seriesCollectionId:seriesCollectionId postIdList:postIdList];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(seriesNeedUpdate)]) {
                [self.delegate seriesNeedUpdate];
            }
            [self.navigationController popViewControllerAnimated:YES];
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            [hud hideAnimated:YES];
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
    titleLabel.text = @"新增系列";
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if ([self.titleField canResignFirstResponder]) {
        [self.titleField resignFirstResponder];
    }
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
