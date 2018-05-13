//
//  AchievementViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/13.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "AchievementViewController.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import "AchievementCollectionCell.h"

@interface AchievementViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UICollectionViewFlowLayout * layout;
@property (nonatomic, strong) UICollectionView * collectionView;

@end

@implementation AchievementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
}

- (void)createViews
{
    [self createTopView];
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.layout = [[UICollectionViewFlowLayout alloc] init];
    self.layout.itemSize = CGSizeMake(500 * scale, 590 * scale);
    self.layout.minimumInteritemSpacing = (kMainBoundsWidth - self.layout.itemSize.width * 2) / 3 - 1;
    self.layout.minimumLineSpacing = self.layout.minimumInteritemSpacing;
    self.layout.headerReferenceSize = CGSizeMake(kMainBoundsWidth, 80 * scale);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    [self.collectionView registerClass:[AchievementCollectionCell class] forCellWithReuseIdentifier:@"AchievementCollectionCell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    self.collectionView.backgroundColor = self.view.backgroundColor;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.contentInset = UIEdgeInsetsMake(self.layout.minimumInteritemSpacing, self.layout.minimumInteritemSpacing, self.layout.minimumInteritemSpacing, self.layout.minimumInteritemSpacing);
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom).offset(0);
        make.left.bottom.right.mas_equalTo(0);
    }];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AchievementCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AchievementCollectionCell" forIndexPath:indexPath];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        
        UICollectionReusableView * header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        
        CGFloat scale = kMainBoundsWidth / 1080.f;
        UILabel * label;
        if ([header viewWithTag:666]) {
            label = (UILabel *)[header viewWithTag:666];
        }else{
            label = [DDViewFactoryTool createLabelWithFrame:CGRectMake(self.layout.minimumInteritemSpacing, 0, kMainBoundsWidth - self.layout.minimumInteritemSpacing, self.layout.headerReferenceSize.height) font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
            [header addSubview:label];
        }
        label.text = @"已获得";
        return header;
        
    }
    return [UICollectionReusableView new];
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
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentCenter];
    titleLabel.text = @"我的成就";
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
