//
//  DDCollectionViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/16.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDCollectionViewController.h"
#import "TYCyclePagerView.h"
#import "DDCollectionListViewCell.h"
#import "DTieDetailViewController.h"
#import "DDHandleButton.h"
#import <UIImageView+WebCache.h>

@interface DDCollectionViewController ()<TYCyclePagerViewDataSource, TYCyclePagerViewDelegate>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * locationLabel;
@property (nonatomic, strong) DDHandleButton * yaoyueButton;
@property (nonatomic, strong) DDHandleButton * shoucangButton;
@property (nonatomic, strong) DDHandleButton * dazhaohuButton;

@property (nonatomic, strong) TYCyclePagerView *pagerView;

@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, assign) NSInteger index;

@end

@implementation DDCollectionViewController

- (instancetype)initWithDataSource:(NSArray *)dataSource index:(NSInteger)index
{
    if (self = [super init]) {
        self.dataSource = [[NSMutableArray alloc] initWithArray:dataSource];
        self.index = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
    [self createTopView];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.pagerView = [[TYCyclePagerView alloc]init];
    self.pagerView.isInfiniteLoop = YES;
    self.pagerView.dataSource = self;
    self.pagerView.delegate = self;
    self.pagerView.isInfiniteLoop = NO;
    [self.pagerView registerClass:[DDCollectionListViewCell class] forCellWithReuseIdentifier:@"DDCollectionListViewCell"];
    [self.view addSubview:self.pagerView];
    
    [self.pagerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + 144 + kStatusBarHeight) * scale);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-210 * scale);
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.pagerView scrollToItemAtIndex:self.index animate:NO];
    });
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"test"]];
    [self.view addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((244 + kStatusBarHeight) * scale);
        make.left.mas_equalTo(120 * scale);
        make.width.height.mas_equalTo(96 *scale);
    }];
    [DDViewFactoryTool cornerRadius:60 * scale withView:self.logoImageView];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentLeft];
    [self.view addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.logoImageView);
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(15 * scale);
        make.height.mas_equalTo(60 * scale);
    }];
    
    UIImageView * locationImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"location"]];
    [self.view addSubview:locationImageView];
    [locationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pagerView.mas_bottom).offset(40 * scale);
        make.left.mas_equalTo(self.logoImageView);
        make.width.height.mas_equalTo(50 * scale);
    }];
    
    self.locationLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.locationLabel.numberOfLines = 0;
    [self.view addSubview:self.locationLabel];
    [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pagerView.mas_bottom).offset(25 * scale);
        make.left.mas_equalTo(locationImageView.mas_right).offset(25 * scale);
        make.width.mas_equalTo(450 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    
    self.yaoyueButton = [DDHandleButton buttonWithType:UIButtonTypeCustom];
    [self.yaoyueButton configImage:[UIImage imageNamed:@"yaoyue"]];
    [self.yaoyueButton configTitle:@"0"];
    [self.view addSubview:self.yaoyueButton];
    [self.yaoyueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pagerView.mas_bottom).offset(25 * scale);
        make.left.mas_equalTo(self.locationLabel.mas_right).offset(30 * scale);
        make.width.mas_equalTo(96 * scale);
        make.height.mas_equalTo(96 * scale);
    }];
    
    self.shoucangButton = [DDHandleButton buttonWithType:UIButtonTypeCustom];
    [self.shoucangButton configImage:[UIImage imageNamed:@"yaoyue"]];
    [self.shoucangButton configTitle:@"0"];
    [self.view addSubview:self.shoucangButton];
    [self.shoucangButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pagerView.mas_bottom).offset(25 * scale);
        make.left.mas_equalTo(self.yaoyueButton.mas_right).offset(10 * scale);
        make.width.mas_equalTo(96 * scale);
        make.height.mas_equalTo(96 * scale);
    }];
    
    self.dazhaohuButton = [DDHandleButton buttonWithType:UIButtonTypeCustom];
    [self.dazhaohuButton configImage:[UIImage imageNamed:@"dazhaohu"]];
    [self.dazhaohuButton configTitle:@"0"];
    [self.view addSubview:self.dazhaohuButton];
    [self.dazhaohuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pagerView.mas_bottom).offset(25 * scale);
        make.left.mas_equalTo(self.shoucangButton.mas_right).offset(10 * scale);
        make.width.mas_equalTo(96 * scale);
        make.height.mas_equalTo(96 * scale);
    }];
}

- (void)pagerView:(TYCyclePagerView *)pageView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    DTieModel * model = [self.dataSource objectAtIndex:toIndex];
    if (model) {
        [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
        self.nameLabel.text = model.nickname;
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString * createTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)model.updateTime / 1000]];
        self.locationLabel.text = [NSString stringWithFormat:@"%@\n%@", createTime, model.sceneAddress];
        
        [self.yaoyueButton configTitle:[NSString stringWithFormat:@"%ld", model.wyyCount]];
        [self.shoucangButton configTitle:[NSString stringWithFormat:@"%ld", model.collectCount]];
        [self.dazhaohuButton configTitle:[NSString stringWithFormat:@"%ld", model.dzfCount]];
    }
}

- (NSInteger)numberOfItemsInPagerView:(TYCyclePagerView *)pageView {
    return self.dataSource.count;
}

- (UICollectionViewCell *)pagerView:(TYCyclePagerView *)pagerView cellForItemAtIndex:(NSInteger)index {
    DDCollectionListViewCell *cell = [pagerView dequeueReusableCellWithReuseIdentifier:@"DDCollectionListViewCell" forIndex:index];
    
    DTieModel * model = [self.dataSource objectAtIndex:index];
    [cell configWithModel:model tag:index];
    
    return cell;
}

- (TYCyclePagerViewLayout *)layoutForPagerView:(TYCyclePagerView *)pageView {
    
    TYCyclePagerViewLayout *layout = [[TYCyclePagerViewLayout alloc]init];
    layout.itemSize = CGSizeMake(CGRectGetWidth(pageView.frame)*0.8, CGRectGetHeight(pageView.frame));
    layout.layoutType = TYCyclePagerTransformLayoutLinear;
    layout.itemHorizontalCenter = YES;
    layout.itemSpacing = 15;
    
    return layout;
}

- (void)pagerView:(TYCyclePagerView *)pageView didSelectedItemCell:(__kindof UICollectionViewCell *)cell atIndex:(NSInteger)index
{
    DTieModel * model = [self.dataSource objectAtIndex:index];
    DTieDetailViewController * detail = [[DTieDetailViewController alloc] initWithDTie:model];
    [self.navigationController pushViewController:detail animated:NO];
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
    
    self.titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentCenter];
    self.titleLabel.text = @"浏览D贴";
    [self.topView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
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
