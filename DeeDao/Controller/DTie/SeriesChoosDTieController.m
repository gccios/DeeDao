//
//  SeriesChoosDTieController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SeriesChoosDTieController.h"
#import "DTieListRequest.h"
#import "MBProgressHUD+DDHUD.h"
#import "DTieModel.h"
#import "DTieCollectionViewCell.h"

@interface SeriesChoosDTieController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UICollectionView * collectionView;

@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger length;

@end

@implementation SeriesChoosDTieController

- (instancetype)initWithSource:(NSMutableArray *)source
{
    if (self = [super init]) {
        self.dataSource = source;
        
        self.start = self.dataSource.count;
        self.length = 30;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
    
    if (self.dataSource.count == 0) {
        [self getMoreList];
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
    [self.collectionView registerClass:[DTieCollectionViewCell class] forCellWithReuseIdentifier:@"DTieCollectionViewCell"];
    self.collectionView.backgroundColor = self.view.backgroundColor;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
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
    DTieCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DTieCollectionViewCell" forIndexPath:indexPath];
    
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.item];
    
    cell.indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section];
    
    [cell configWithDTieModel:model];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.item];
    if (self.delegate && [self.delegate respondsToSelector:@selector(seriesWillInsertWith:)]) {
        [self.delegate seriesWillInsertWith:model];
    }
}

- (void)getMoreList
{
    DTieListRequest * request = [[DTieListRequest alloc] initWithStart:self.start length:self.length];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                
                for (NSDictionary * dict in data) {
                    DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                    [self.dataSource addObject:model];
                }
                [self.collectionView reloadData];
                
                return;
                
            }
        }
        [MBProgressHUD showTextHUDWithText:@"获取D帖失败" inView:self.view];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [MBProgressHUD showTextHUDWithText:@"获取D帖失败" inView:self.view];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:self.view];
        
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
    titleLabel.text = @"添加D帖系列";
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
