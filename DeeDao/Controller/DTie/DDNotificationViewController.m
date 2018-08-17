//
//  DDNotificationViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/13.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDNotificationViewController.h"
#import "TYCyclePagerView.h"
#import "NotificationCollectionViewCell.h"
#import "DDCollectionSlider.h"
#import "SelectNotificationRequest.h"
#import "NotificationHistoryModel.h"
#import "MBProgressHUD+DDHUD.h"

@interface DDNotificationViewController () <TYCyclePagerViewDataSource, TYCyclePagerViewDelegate>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, assign) NSInteger notificationID;

@property (nonatomic, strong) TYCyclePagerView *pagerView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) DDCollectionSlider * slider;
@property (nonatomic, assign) BOOL isSliding;

@end

@implementation DDNotificationViewController

- (instancetype)initWithNotificationID:(NSInteger)notificationID
{
    if (self = [super init]) {
        self.notificationID = notificationID;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createViews];
    [self createTopView];
    
    [self getNotificationList];
}

- (void)getNotificationList
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:self.view];
    
    SelectNotificationRequest * request = [[SelectNotificationRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                self.dataSource = [NotificationHistoryModel mj_objectArrayWithKeyValuesArray:data];
            }
        }
        if (self.dataSource.count == 0) {
            
            [MBProgressHUD showTextHUDWithText:@"暂无提醒记录" inView:self.view];
            self.slider.hidden = YES;
            
        }else{
            [self.pagerView reloadData];
            
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"cid == %d", self.notificationID];
            NSArray * tempArray = [self.dataSource filteredArrayUsingPredicate:predicate];
            if (tempArray) {
                NotificationHistoryModel * model = [tempArray firstObject];
                NSInteger index = [self.dataSource indexOfObject:model];
                [self.pagerView scrollToItemAtIndex:index animate:YES];
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [MBProgressHUD showTextHUDWithText:@"获取失败" inView:self.view];
        [hud hideAnimated:YES];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [MBProgressHUD showTextHUDWithText:@"获取失败" inView:self.view];
        [hud hideAnimated:YES];
        
    }];
}

- (NSInteger)numberOfItemsInPagerView:(TYCyclePagerView *)pageView {
    return self.dataSource.count;
}

- (UICollectionViewCell *)pagerView:(TYCyclePagerView *)pagerView cellForItemAtIndex:(NSInteger)index {
    NotificationCollectionViewCell *cell = [pagerView dequeueReusableCellWithReuseIdentifier:@"NotificationCollectionViewCell" forIndex:index];
    
    NotificationHistoryModel * model = [self.dataSource objectAtIndex:index];
    [cell configWithModel:model];
    
    return cell;
}

- (TYCyclePagerViewLayout *)layoutForPagerView:(TYCyclePagerView *)pageView {
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    TYCyclePagerViewLayout *layout = [[TYCyclePagerViewLayout alloc]init];
    layout.itemSize = CGSizeMake(kMainBoundsWidth - 300 * scale, CGRectGetHeight(pageView.frame));
    layout.layoutType = TYCyclePagerTransformLayoutLinear;
    layout.itemHorizontalCenter = YES;
    layout.itemSpacing = 50 * scale;
    layout.minimumAlpha = .3f;
    
    return layout;
}

- (void)pagerView:(TYCyclePagerView *)pageView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    [self reloadPageWithIndex:toIndex];
}

- (void)reloadPageWithIndex:(NSInteger)index
{
    if (!self.isSliding) {
        CGFloat value = (CGFloat)self.pagerView.curIndex / (CGFloat)(self.dataSource.count - 1);
        [self.slider setValue:value animated:YES];
    }
}

- (void)createViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.pagerView = [[TYCyclePagerView alloc]init];
    self.pagerView.dataSource = self;
    self.pagerView.delegate = self;
    self.pagerView.isInfiniteLoop = NO;
    [self.pagerView registerClass:[NotificationCollectionViewCell class] forCellWithReuseIdentifier:@"NotificationCollectionViewCell"];
    
    [self.view addSubview:self.pagerView];
    [self.pagerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-220 * scale);
    }];
    
    self.slider = [[DDCollectionSlider alloc] initWithFrame:CGRectZero];
    self.slider.maximumTrackTintColor = UIColorFromRGB(0xEFEFF4);
    self.slider.minimumTrackTintColor = UIColorFromRGB(0xEFEFF4);
    [self.slider setThumbImage:[UIImage imageNamed:@"singleyes"] forState:UIControlStateNormal];
    [self.view addSubview:self.slider];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(170 * scale);
        make.bottom.mas_equalTo(-150 * scale);
        make.right.mas_equalTo(-170 * scale);
        make.height.mas_equalTo(35 * scale);
    }];
    self.slider.value = 0 / (CGFloat)(self.dataSource.count - 1);
    [self.slider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(sliderValueDidSliderEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
}

- (void)sliderValueDidChange:(UISlider *)slider
{
    self.isSliding = YES;
    CGFloat value = slider.value;
    [self.pagerView.collectionView setContentOffset:CGPointMake((self.pagerView.collectionView.contentSize.width - kMainBoundsWidth) * value, 0) animated:NO];
}

- (void)sliderValueDidSliderEnd:(UISlider *)slider
{
    self.isSliding = NO;
    CGFloat value = slider.value;
    CGFloat tempIndex = (self.dataSource.count - 1) * value;
    NSInteger index = round(tempIndex);
    [self.pagerView scrollToItemAtIndex:index animate:YES];
    
    value = (CGFloat)index / (CGFloat)(self.dataSource.count - 1);
    [self.slider setValue:value animated:YES];
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
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(54 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    titleLabel.text = @"Hi~你感兴趣的点就在你周围！";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
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
