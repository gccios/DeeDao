//
//  SecurityDTieViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SecurityDTieViewController.h"
#import "DTieListRequest.h"
#import "MBProgressHUD+DDHUD.h"
#import "DTieModel.h"
#import "DTieChooseCollectionViewCell.h"
#import <MJRefresh.h>
#import "UserManager.h"

@interface SecurityDTieViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UICollectionView * collectionView;

@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger length;

@property (nonatomic, strong) NSMutableArray * chooseSource;

@end

@implementation SecurityDTieViewController

- (instancetype)initWithChooseSource:(NSMutableArray *)chooseSource DTieSource:(NSMutableArray *)DTieSource
{
    if (self = [super init]) {
        self.dataSource = DTieSource;
        self.chooseSource = chooseSource;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.start = 0;
    self.length = 20;
    
    [self createViews];
    
    if (self.dataSource.count == 0) {
        [self refreshData];
    }else{
        self.start = self.dataSource.count;
    }
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kMainBoundsWidth / 2, 360 * scale);
    layout.minimumLineSpacing = 30 * scale;
    layout.minimumInteritemSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerClass:[DTieChooseCollectionViewCell class] forCellWithReuseIdentifier:@"DTieChooseCollectionViewCell"];
    self.collectionView.backgroundColor = self.view.backgroundColor;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.collectionView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMoreList)];
    
    [self createTopView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DTieChooseCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DTieChooseCollectionViewCell" forIndexPath:indexPath];
    
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.item];
    
    cell.indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section];
    
    [cell configWithDTieModel:model];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"cid == %d", model.postId];
    NSArray * tempArray = [self.chooseSource filteredArrayUsingPredicate:predicate];
    
    if (tempArray && tempArray.count > 0) {
        [cell configSelectStatus:YES];
    }else{
        [cell configSelectStatus:NO];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.item];
    
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"cid == %d", model.postId];
    NSArray * tempArray = [self.chooseSource filteredArrayUsingPredicate:predicate];
    
    if (tempArray && tempArray.count > 0) {
        [self.chooseSource removeObjectsInArray:tempArray];
    }else{
        [self.chooseSource addObject:model];
    }
    
    [collectionView reloadData];
}

- (void)refreshData
{
    DTieListRequest * request = [[DTieListRequest alloc] initWithStart:0 length:self.length];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data) && data.count > 0) {
                [self.dataSource removeAllObjects];
                for (NSDictionary * dict in data) {
                    DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                    model.cid = model.postId;
                    if (model.authorId == [UserManager shareManager].user.cid) {
                        [self.dataSource addObject:model];
                    }
                }
                [self.collectionView reloadData];
                self.start = 21;
                
                return;
                
            }
        }
        
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
//        [MBProgressHUD showTextHUDWithText:@"获取D帖失败" inView:self.view];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
//        [MBProgressHUD showTextHUDWithText:@"获取D帖失败" inView:self.view];
        
    }];
}

- (void)getMoreList
{
    DTieListRequest * request = [[DTieListRequest alloc] initWithStart:self.start length:self.length];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data) && data.count > 0) {
                
                for (NSDictionary * dict in data) {
                    DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                    if (model.type == [UserManager shareManager].user.cid) {
                        [self.dataSource addObject:model];
                    }
                }
                [self.collectionView reloadData];
                self.start += self.length;
                return;
                
            }
        }
        [self.collectionView.mj_footer endRefreshing];
//        [MBProgressHUD showTextHUDWithText:@"获取D帖失败" inView:self.view];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self.collectionView.mj_footer endRefreshing];
//        [MBProgressHUD showTextHUDWithText:@"获取D帖失败" inView:self.view];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self.collectionView.mj_footer endRefreshing];
//        [MBProgressHUD showTextHUDWithText:@"获取D帖失败" inView:self.view];
        
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
    titleLabel.text = @"添加D帖";
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
