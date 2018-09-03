//
//  DTieSearchViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieSearchViewController.h"
#import "MBProgressHUD+DDHUD.h"
#import "DTieModel.h"
#import "DTieHeaderLogoCell.h"
#import "DDCollectionViewController.h"
#import "DTieDetailRequest.h"
#import "DTieNewEditViewController.h"
#import "DTieSearchRequest.h"
#import "DDTool.h"
#import "ChooseUserViewController.h"
#import "SelectPostAuthorRequest.h"
#import "UserModel.h"

@interface DTieSearchViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, ChooseUserDelegate>

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UITextField * textField;

@property (nonatomic, strong) UIButton * timeButton;
@property (nonatomic, strong) UIButton * sourceButton;
@property (nonatomic, strong) UIButton * selectButton;

@property (nonatomic, assign) NSInteger sortType;
@property (nonatomic, assign) NSInteger sourceType;

@property (nonatomic, strong) UICollectionView * collectionView;

@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger length;

@property (nonatomic, strong) ChooseUserViewController * chooseUser;
@property (nonatomic, strong) NSArray * selectAuthor;

@end

@implementation DTieSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sortType = 0;
    self.sourceType = 1;
    self.start = 0;
    self.length = 1000;
    self.dataSource = [[NSMutableArray alloc] init];
    
    [self createViews];
    [self searchRequest];
}

- (void)searchRequest
{
    NSString * keyWord = @"";
    if (!isEmptyString(self.textField.text)) {
        keyWord = self.textField.text;
    }
    
    NSInteger dataSourceType = self.sourceType;
    
    [DTieSearchRequest cancelRequest];
    DTieSearchRequest * request = [[DTieSearchRequest alloc] initWithKeyWord:keyWord lat1:0 lng1:0 lat2:0 lng2:0 startDate:0 endDate:(NSInteger)[DDTool getTimeCurrentWithDouble] sortType:1 dataSources:dataSourceType type:2 pageStart:self.start pageSize:self.length];
    
    if (dataSourceType == -1) {
        request = [[DTieSearchRequest alloc] initWithKeyWord:keyWord lat1:0 lng1:0 lat2:0 lng2:0 startDate:0 endDate:(NSInteger)[DDTool getTimeCurrentWithDouble] sortType:1 dataSources:1 type:2 status:0 pageStart:self.start pageSize:self.length];
    }else if (dataSourceType == 1){
        request = [[DTieSearchRequest alloc] initWithKeyWord:keyWord lat1:0 lng1:0 lat2:0 lng2:0 startDate:0 endDate:(NSInteger)[DDTool getTimeCurrentWithDouble] sortType:1 dataSources:1 type:2 status:1 pageStart:self.start pageSize:self.length];
    }
    [request configTimeSort:self.sortType];
    
    if (self.selectAuthor && self.selectAuthor.count > 0) {
        NSMutableArray * authorID = [[NSMutableArray alloc] init];
        for (UserModel * model in self.selectAuthor) {
            [authorID addObject:@(model.cid)];
        }
        [request configWithAuthorID:authorID];
    }
    
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.dataSource removeAllObjects];
                for (NSInteger i = 0; i < data.count; i++) {
                    NSDictionary * dict = [data objectAtIndex:i];
                    DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                    [self.dataSource addObject:model];
                }
                [self.collectionView reloadData];
            }
        }
        
        if (self.dataSource.count == 0) {
            [MBProgressHUD showTextHUDWithText:@"暂无搜索结果，请修改搜索条件后重试" inView:self.view];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kMainBoundsWidth / 2, 360 * scale);
    layout.minimumLineSpacing = 30 * scale;
    layout.minimumInteritemSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerClass:[DTieHeaderLogoCell class] forCellWithReuseIdentifier:@"DTieHeaderLogoCell"];
    self.collectionView.backgroundColor = self.view.backgroundColor;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((364 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    [self createTopView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DTieHeaderLogoCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DTieHeaderLogoCell" forIndexPath:indexPath];
    
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.item];
    
    cell.indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section];
    
    [cell configWithDTieModel:model];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self endEditing];
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.item];
    
    if (model.status == 0) {
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在获取草稿" inView:self.view];
        
        DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:model.postId type:4 start:0 length:10];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
            
            if (KIsDictionary(response)) {
                NSDictionary * data = [response objectForKey:@"data"];
                if (KIsDictionary(data)) {
                    DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
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
        DDCollectionViewController * collection = [[DDCollectionViewController alloc] initWithDataSource:self.dataSource index:indexPath.row];
        [self.navigationController pushViewController:collection animated:YES];
    }
}

- (void)timeButtonDidClicked
{
    [self endEditing];
    if (self.sortType == 0) {
        self.sortType = 1;
    }else{
        self.sortType = 0;
    }
    [self searchRequest];
}

- (void)sourceButtonDidClicked
{
    [self endEditing];
    if (self.sourceType == 1) {
        self.sourceType = 2;
    }else if (self.sourceType == 2) {
        self.sourceType = 9;
    }else if (self.sourceType == 9) {
        self.sourceType = -1;
    }else if (self.sourceType == -1) {
        self.sourceType = 1;
    }
    
    if (self.sourceType == 1) {
        [self.sourceButton setTitle:@"我的" forState:UIControlStateNormal];
    }else if (self.sourceType == 2){
        [self.sourceButton setTitle:@"收藏" forState:UIControlStateNormal];
    }else if (self.sourceType == 9){
        [self.sourceButton setTitle:@"要约" forState:UIControlStateNormal];
    }else if (self.sourceType == -1){
        [self.sourceButton setTitle:@"草稿" forState:UIControlStateNormal];
    }
    [self searchRequest];
}

- (void)searchButtonDidClicked
{
    [self searchRequest];
    [self endEditing];
}

- (void)selectButtonDidClicked
{
    if (!self.chooseUser) {
        [self requestChooseUserList];
    }else{
        [self.navigationController pushViewController:self.chooseUser animated:YES];
    }
}

- (void)requestChooseUserList
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:self.view];
    SelectPostAuthorRequest * request = [[SelectPostAuthorRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            
            if (KIsArray(data)) {
                NSMutableArray * dataSource = [[NSMutableArray alloc] init];
                for (NSDictionary * dict in data) {
                    UserModel * model = [UserModel mj_objectWithKeyValues:dict];
                    [dataSource addObject:model];
                }
                
                if (dataSource.count == 0) {
                    [MBProgressHUD showTextHUDWithText:@"暂无可筛选作者" inView:self.view];
                    return;
                }
                
                self.chooseUser = [[ChooseUserViewController alloc] initWithUsers:dataSource];
                self.chooseUser.delegate = self;
                [self.navigationController pushViewController:self.chooseUser animated:YES];
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [MBProgressHUD showTextHUDWithText:@"获取作者列表失败" inView:self.view];
        [hud hideAnimated:YES];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:self.view];
        [hud hideAnimated:YES];
        
    }];
}

- (void)userDidCompleteSelectWith:(NSArray *)selectArray
{
    self.selectAuthor = [[NSArray alloc] initWithArray:selectArray];
    [self searchRequest];
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
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.topView addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(96 * scale);
        make.left.mas_equalTo(24 * scale);
        make.right.mas_equalTo(-24 * scale);
        make.height.mas_equalTo((124 + kStatusBarHeight) * scale);
    }];
    self.textField.backgroundColor = UIColorFromRGB(0xFAFAFA);
    [DDViewFactoryTool cornerRadius:6 * scale withView:self.textField];
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
    
    UIButton * sendButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(0, 0, 130 * scale, 72 * scale) font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"搜索"];
    self.textField.rightView = sendButton;
    self.textField.rightViewMode = UITextFieldViewModeAlways;
    [sendButton addTarget:self action:@selector(searchButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.timeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"时间"];
    [self.timeButton addTarget:self action:@selector(timeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.timeButton setImage:[UIImage imageNamed:@"time_tab"] forState:UIControlStateNormal];
    [self.topView addSubview:self.timeButton];
    [self.timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textField.mas_bottom).offset(10 * scale);
        make.left.mas_equalTo(kMainBoundsWidth / 3);
        make.bottom.mas_equalTo(-10 * scale);
        make.width.mas_equalTo(kMainBoundsWidth / 3);
    }];
    
    UIView * lineView1 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView1.backgroundColor = [UIColorFromRGB(0xFFFFFF) colorWithAlphaComponent:.5f];
    [self.timeButton addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.width.mas_equalTo(3 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    
    self.sourceButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"我的"];
    [self.sourceButton addTarget:self action:@selector(sourceButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.sourceButton setImage:[UIImage imageNamed:@"source_tab"] forState:UIControlStateNormal];
    [self.topView addSubview:self.sourceButton];
    [self.sourceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textField.mas_bottom).offset(10 * scale);
        make.left.mas_equalTo(0 * scale);
        make.bottom.mas_equalTo(-10 * scale);
        make.width.mas_equalTo(kMainBoundsWidth / 3);
    }];
    
    UIView * lineView2 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView2.backgroundColor = [UIColorFromRGB(0xFFFFFF) colorWithAlphaComponent:.5f];
    [self.sourceButton addSubview:lineView2];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.width.mas_equalTo(3 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    
    self.selectButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"筛选"];
    [self.selectButton addTarget:self action:@selector(selectButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.selectButton setImage:[UIImage imageNamed:@"zuozhe_tab"] forState:UIControlStateNormal];
    [self.topView addSubview:self.selectButton];
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textField.mas_bottom).offset(10 * scale);
        make.right.mas_equalTo(0 * scale);
        make.bottom.mas_equalTo(-10 * scale);
        make.width.mas_equalTo(kMainBoundsWidth / 3);
    }];
}

- (void)backButtonDidClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)endEditing
{
    if ([self.textField canResignFirstResponder]) {
        [self.textField resignFirstResponder];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self endEditing];
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
