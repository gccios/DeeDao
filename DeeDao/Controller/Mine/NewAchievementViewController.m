//
//  NewAchievementViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "NewAchievementViewController.h"
#import "TYCyclePagerView.h"
#import "DDCollectionSlider.h"
#import "NotificationHistoryModel.h"
#import "NewAchievementCell.h"
#import "MBProgressHUD+DDHUD.h"
#import "GetMyMedalRequest.h"
#import <WXApi.h>
#import <UIImageView+WebCache.h>
#import "UserManager.h"
#import "DDBackWidow.h"
#import "WeChatManager.h"
#import "DDTool.h"
#import "GCCScreenImage.h"
#import "AchievementShareView.h"

@interface NewAchievementViewController () <TYCyclePagerViewDataSource, TYCyclePagerViewDelegate>

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) TYCyclePagerView *pagerView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) DDCollectionSlider * slider;
@property (nonatomic, assign) BOOL isSliding;

@property (nonatomic, strong) UIView * shareView;

@end

@implementation NewAchievementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createViews];
    [self createTopView];
    
    [self getAchievementList];
}

- (void)getAchievementList
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:self.view];
    
    GetMyMedalRequest * request = [[GetMyMedalRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                self.dataSource = [AchievementModel mj_objectArrayWithKeyValuesArray:data];
            }
        }
        if (self.dataSource.count == 0) {
            
            [MBProgressHUD showTextHUDWithText:@"暂未获得成就" inView:self.view];
            self.slider.hidden = YES;
            
        }
        
        [self.pagerView reloadData];
        
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
    NewAchievementCell *cell = [pagerView dequeueReusableCellWithReuseIdentifier:@"NewAchievementCell" forIndex:index];
    
    AchievementModel * model = [self.dataSource objectAtIndex:index];
    [cell configWithModel:model tag:index];
    
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
    [self.pagerView registerClass:[NewAchievementCell class] forCellWithReuseIdentifier:@"NewAchievementCell"];
    
    [self.view addSubview:self.pagerView];
    [self.pagerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((500 + kStatusBarHeight) * scale);
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
        make.height.mas_equalTo((480 + kStatusBarHeight) * scale);
    }];
    
    UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"chengjiuBG"]];
    [self.topView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    UIButton * backButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.top.mas_equalTo(120 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(54 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    titleLabel.text = @"我的成就";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.centerY.mas_equalTo(backButton);
        make.right.mas_equalTo(-60 * scale);
    }];
    
    UIImageView * logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [logoImageView sd_setImageWithURL:[NSURL URLWithString:[UserManager shareManager].user.portraituri]];
    [self.topView addSubview:logoImageView];
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(-40 * scale);
        make.width.height.mas_equalTo(220 * scale);
    }];
    [DDViewFactoryTool cornerRadius:110 * scale withView:logoImageView];
    
    UIButton * shareButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:shareButton];
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-40 * scale);
        make.centerY.mas_equalTo(backButton);
        make.width.height.mas_equalTo(100 * scale);
    }];
}

- (void)shareButtonDidClicked
{
    [[UIApplication sharedApplication].keyWindow addSubview:self.shareView];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[DDBackWidow shareWindow] show];
}

- (UIView *)shareView
{
    if (!_shareView) {
        _shareView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _shareView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:_shareView action:@selector(removeFromSuperview)];
        [_shareView addGestureRecognizer:tap];
        
        NSArray * imageNames;
        NSArray * titles;
        NSInteger startTag = 10;
        
        BOOL isInstallWX = [WXApi isWXAppInstalled];
        
        if (isInstallWX) {
            imageNames = @[@"sharepengyouquan", @"shareweixin", @"saveToPhone"];
            titles = @[@"微信朋友圈", @"微信好友或群", @"保存到手机"];
            startTag = 10;
        }else {
            imageNames = @[@"saveToPhone"];
            titles = @[@"保存到手机"];
            startTag = 12;
        }
        
        CGFloat width = kMainBoundsWidth / imageNames.count;
        CGFloat height = kMainBoundsWidth / 4.f;
        if (KIsiPhoneX) {
            height += 38.f;
        }
        CGFloat scale = kMainBoundsWidth / 1080.f;
        for (NSInteger i = 0; i < imageNames.count; i++) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.8f];
            button.tag = startTag + i;
            [button addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_shareView addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(i * width);
                make.height.mas_equalTo(height);
                make.bottom.mas_equalTo(0);
                make.width.mas_equalTo(width);
            }];
            
            UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
            [button addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(0);
                make.top.mas_equalTo(50 * scale);
                make.width.height.mas_equalTo(96 * scale);
            }];
            
            UILabel * label = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentCenter];
            label.text = [titles objectAtIndex:i];
            [button addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.mas_equalTo(0);
                make.height.mas_equalTo(45 * scale);
                make.top.mas_equalTo(imageView.mas_bottom).offset(20 * scale);
            }];
        }
    }
    return _shareView;
}

- (void)buttonDidClicked:(UIButton *)button
{
    [self.shareView removeFromSuperview];
    
    NewAchievementCell * cell = self.pagerView.curIndexCell;
    
    UIImage * shareImage = [GCCScreenImage screenView:cell];
    
    AchievementModel * model = [self.dataSource objectAtIndex:self.pagerView.curIndex];
    AchievementShareView * view;
    
    if (button.tag == 10) {
        
        view = [[AchievementShareView alloc] initWithAchievementModel:model currentImage:shareImage type:1];
        
    }else if (button.tag == 11){
        
        view = [[AchievementShareView alloc] initWithAchievementModel:model currentImage:shareImage type:2];
        
    }else{
        
        view = [[AchievementShareView alloc] initWithAchievementModel:model currentImage:shareImage type:3];
        
    }
    [view startShare];
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
