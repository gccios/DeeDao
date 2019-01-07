
//
//  DDGroupViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/3.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDGroupViewController.h"
#import "DDGroupCollectionViewCell.h"
#import "DDGroupTitleReusableView.h"
#import "DDBackWidow.h"
#import "DDGroupSearchViewController.h"

@interface DDGroupViewController () <UICollectionViewDelegate, UICollectionViewDataSource, CAAnimationDelegate>

@property (nonatomic, strong) UICollectionView * collectionView;

@end

@implementation DDGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createViews];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 360.f;
    
    UIView * BGView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:BGView];
    [BGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight);
    gradientLayer.opacity = .8f;
    [BGView.layer addSublayer:gradientLayer];
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((kMainBoundsWidth - 50 * scale) / 2.f, 150 * scale);
    layout.headerReferenceSize = CGSizeMake(kMainBoundsWidth, 40 * scale);
    layout.minimumLineSpacing = 10 * scale;
    layout.minimumInteritemSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerClass:[DDGroupCollectionViewCell class] forCellWithReuseIdentifier:@"DDGroupCollectionViewCell"];
    [self.collectionView registerClass:[DDGroupTitleReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"DDGroupTitleReusableView"];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(20 * scale);
        make.right.mas_equalTo(-20 * scale);
        make.bottom.mas_equalTo(0);
    }];
    
    UIButton * backButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [backButton setImage:[UIImage imageNamed:@"contentClose"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15 * scale);
        make.top.mas_equalTo(40 * scale);
        make.width.height.mas_equalTo(30 * scale);
    }];
    
    UIButton * searchButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [self.view addSubview:searchButton];
    [searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15 * scale);
        make.top.mas_equalTo(40 * scale);
        make.width.height.mas_equalTo(35 * scale);
    }];
    [searchButton addTarget:self action:@selector(searchButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)searchButtonDidClicked
{
    DDGroupSearchViewController * search = [[DDGroupSearchViewController alloc] init];
    
    CATransition *transition = [CATransition animation];
    
    transition.duration = 0.35;
    
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    
    transition.type = kCATransitionPush;
    
    transition.subtype = kCATransitionFromTop;
    
    transition.delegate = self;
    
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    [self.navigationController pushViewController:search animated:NO];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 9;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DDGroupCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DDGroupCollectionViewCell" forIndexPath:indexPath];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        DDGroupTitleReusableView * view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"DDGroupTitleReusableView" forIndexPath:indexPath];
        
        if (indexPath.section == 0) {
            [view configWithTitle:@"-  已 有 群  -"];
        }else{
            [view configWithTitle:@"-  其 他 公 开 群  -"];
        }
        
        return view;
    }
    
    return nil;
}

- (void)backButtonDidClicked
{
    CATransition *transition = [CATransition animation];
    
    transition.duration = 0.35;
    
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    
    transition.type = kCATransitionPush;
    
    transition.subtype = kCATransitionFromBottom;
    
    transition.delegate = self;
    
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[DDBackWidow shareWindow] hidden];
    });
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

@end
