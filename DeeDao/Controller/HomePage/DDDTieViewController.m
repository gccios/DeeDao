//
//  DDDTieViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDDTieViewController.h"
#import "DTieCollectionViewCell.h"

@interface DDDTieViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView * DTieManagerView;

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UIButton * searchButton;
@property (nonatomic, strong) UIButton * mapButton;
@property (nonatomic, strong) UIButton * seriesButton;

@property (nonatomic, strong) UICollectionView * collectionView;

@property (nonatomic, strong) NSMutableArray * dataSource;

@end

@implementation DDDTieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createViews];
}

- (void)createViews
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
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, (220 + kStatusBarHeight) * scale);
    [self.topView.layer addSublayer:gradientLayer];
    
    self.topView.layer.shadowColor = UIColorFromRGB(0xB721FF).CGColor;
    self.topView.layer.shadowOpacity = .24;
    self.topView.layer.shadowOffset = CGSizeMake(0, 4);
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentCenter];
    titleLabel.text = @"D贴";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60.5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
    self.searchButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [self.searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [self.searchButton addTarget:self action:@selector(searchButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.searchButton];
    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-40 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    self.mapButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [self.mapButton setImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal];
    [self.mapButton addTarget:self action:@selector(mapButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.mapButton];
    [self.mapButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.searchButton.mas_left).offset(-20 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    self.seriesButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [self.seriesButton setImage:[UIImage imageNamed:@"series"] forState:UIControlStateNormal];
    [self.seriesButton addTarget:self action:@selector(seriesButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.seriesButton];
    [self.seriesButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mapButton.mas_left).offset(-20 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
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
        make.top.mas_equalTo(self.topView.mas_bottom).offset(0);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    /*
     D贴顶部下拉资源管理
     */
    CGFloat managerViewHeight = 288 * scale;
    self.DTieManagerView = [[UIView alloc] initWithFrame:CGRectMake(0, -managerViewHeight, kMainBoundsWidth, managerViewHeight)];
    self.DTieManagerView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(managerViewDidClicked)];
    tap.numberOfTapsRequired = 1;
    [self.collectionView.panGestureRecognizer requireGestureRecognizerToFail:tap];
    [self.DTieManagerView addGestureRecognizer:tap];
    
    [self.collectionView addSubview:self.DTieManagerView];
    
    UIImageView * managerImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"sourceManager"]];
    [self.DTieManagerView addSubview:managerImageView];
    [managerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(144 * scale);
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(263 * scale);
    }];
    
    UILabel * managerTitleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    managerTitleLabel.text = @"D贴素材管理";
    [self.DTieManagerView addSubview:managerTitleLabel];
    [managerTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(-50 * scale / 2);
        make.left.mas_equalTo(managerImageView.mas_right).offset(24 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    UILabel * managerSubtitleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    managerSubtitleLabel.text = @"展开所有D贴照片和视频";
    [self.DTieManagerView addSubview:managerSubtitleLabel];
    [managerSubtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(managerTitleLabel.mas_bottom).offset(10 * scale);
        make.left.mas_equalTo(managerImageView.mas_right).offset(24 * scale);
        make.height.mas_equalTo(36 * scale);
    }];
    
    [self.view bringSubviewToFront:self.topView];
}

- (void)managerViewDidClicked
{
    NSLog(@"下拉资源管理");
}

- (void)seriesButtonDidClicked
{
    NSLog(@"系列");
}

- (void)mapButtonDidClicked
{
    NSLog(@"地图");
}

- (void)searchButtonDidClicked
{
    NSLog(@"搜索");
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击了");
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

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        CGFloat contentY = scrollView.contentOffset.y;
        CGFloat height = self.DTieManagerView.frame.size.height;
        if (contentY <= -height) {
            [scrollView setContentOffset:CGPointMake(0, -height) animated:YES];
        }
    }
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
        
        for (NSInteger i = 0; i < 50; i++) {
            DTieModel * model = [[DTieModel alloc] init];
            model.type = i % 4 + 1;
            model.title = @"如果我不曾见过太阳";
            [_dataSource addObject:model];
        }
        
        DTieModel * model = [[DTieModel alloc] init];
        model.type = DTieType_Add;
        [_dataSource insertObject:model atIndex:0];
        
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
