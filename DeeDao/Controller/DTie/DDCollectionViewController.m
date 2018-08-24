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
#import "MBProgressHUD+DDHUD.h"
#import "DTieDetailRequest.h"
#import "DTieNewDetailViewController.h"
#import "DTieNewEditViewController.h"
#import "DDShareManager.h"
#import "DDDTieViewController.h"
#import "DDCollectionSlider.h"
#import "UserManager.h"

@interface DDCollectionViewController ()<TYCyclePagerViewDataSource, TYCyclePagerViewDelegate>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UILabel * titleLabel;

@property (nonatomic, strong) TYCyclePagerView *pagerView;

@property (nonatomic, strong) DDCollectionSlider * slider;
@property (nonatomic, assign) BOOL isSliding;

@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) BOOL isCanDelete;

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
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self createViews];
    [self createViewsFirstNew];
    [self createTopView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCurrentPage) name:DTieCollectionNeedUpdateNotification object:nil];
}

- (void)createViewsFirstNew
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
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
    self.slider.value = (CGFloat)self.index / (CGFloat)(self.dataSource.count - 1);
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

- (void)reloadCurrentPage
{
    DTieModel * model = [self.dataSource objectAtIndex:self.pagerView.curIndex];
    model.details = nil;
    
    [self.pagerView.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.pagerView.curIndex inSection:0]]];
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
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-200 * scale);
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.pagerView scrollToItemAtIndex:self.index animate:NO];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isCanDelete = YES;
    });
}

- (void)pagerView:(TYCyclePagerView *)pageView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    [self reloadPageWithIndex:toIndex];
}

- (void)reloadPageWithIndex:(NSInteger)index
{
    if (!self.isCanDelete) {
        return;
    }
    
    if (self.dataSource.count == 0) {
        return;
    }
    
    if (!self.isSliding) {
        CGFloat value = (CGFloat)self.pagerView.curIndex / (CGFloat)(self.dataSource.count - 1);
        [self.slider setValue:value animated:YES];
    }
    
    DTieModel * model = [self.dataSource objectAtIndex:index];
    
    if (model) {
        
        if (model.deleteFlg == 1) {
            
            [MBProgressHUD showTextHUDWithText:@"帖子已被作者删除" inView:self.view];
            
            [self.dataSource removeObjectAtIndex:index];
            [self.pagerView.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
            
            NSArray * vcs = self.navigationController.viewControllers;
            UIViewController * vc = [vcs objectAtIndex:vcs.count - 2];
            if ([vc isKindOfClass:[DDDTieViewController class]]) {
                DDDTieViewController * tie = (DDDTieViewController *)vc;
                [tie deleteDtieWithIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
            }
            if (self.dataSource.count == 0) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            
            return;
        }else if (model.landAccountFlg == 2) {
            
            if (model.authorId != [UserManager shareManager].user.cid) {
                [MBProgressHUD showTextHUDWithText:@"帖子已被作者设置为私密" inView:self.view];
                
                [self.dataSource removeObjectAtIndex:index];
                [self.pagerView.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
                
                NSArray * vcs = self.navigationController.viewControllers;
                UIViewController * vc = [vcs objectAtIndex:vcs.count - 2];
                if ([vc isKindOfClass:[DDDTieViewController class]]) {
                    DDDTieViewController * tie = (DDDTieViewController *)vc;
                    [tie deleteDtieWithIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
                }
                if (self.dataSource.count == 0) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
                return;
            }
            
        }
        
        self.titleLabel.text = model.postSummary;
    }
}

- (NSInteger)numberOfItemsInPagerView:(TYCyclePagerView *)pageView {
    return self.dataSource.count;
}

- (UICollectionViewCell *)pagerView:(TYCyclePagerView *)pagerView cellForItemAtIndex:(NSInteger)index {
    DDCollectionListViewCell *cell = [pagerView dequeueReusableCellWithReuseIdentifier:@"DDCollectionListViewCell" forIndex:index];
    
    DTieModel * model = [self.dataSource objectAtIndex:index];
    [cell configWithModel:model tag:index];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(cell) weakCell = cell;
    cell.tableViewClickHandle = ^(NSIndexPath *cellIndex) {
        [weakSelf.pagerView.delegate pagerView:weakSelf.pagerView didSelectedItemCell:weakCell atIndex:cellIndex.item];
    };
    
    return cell;
}

- (TYCyclePagerViewLayout *)layoutForPagerView:(TYCyclePagerView *)pageView {
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    TYCyclePagerViewLayout *layout = [[TYCyclePagerViewLayout alloc]init];
    layout.itemSize = CGSizeMake(kMainBoundsWidth - 300 * scale, CGRectGetHeight(pageView.frame));
    layout.layoutType = TYCyclePagerTransformLayoutLinear;
    layout.itemHorizontalCenter = YES;
    layout.itemSpacing = 50 * scale;
    layout.minimumAlpha = .2f;
    
    return layout;
}

- (void)pagerView:(TYCyclePagerView *)pageView didSelectedItemCell:(__kindof UICollectionViewCell *)cell atIndex:(NSInteger)index
{
    DTieModel * model = [self.dataSource objectAtIndex:index];
    NSInteger postID = model.postId;
    if (postID == 0) {
        postID = model.cid;
    }
    
    if (model.status == 0) {
        
        if (model.authorId != [UserManager shareManager].user.cid) {
            
            [MBProgressHUD showTextHUDWithText:@"该帖已被作者变为草稿状态" inView:self.view];
            
            return;
        }
        
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在获取草稿" inView:self.view];
        
        DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:postID type:4 start:0 length:10];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
            
            if (KIsDictionary(response)) {
                NSDictionary * data = [response objectForKey:@"data"];
                if (KIsDictionary(data)) {
                    DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                    dtieModel.postId = model.postId;
                    DTieNewEditViewController * edit = [[DTieNewEditViewController alloc] initWithDtieModel:dtieModel];
                    [self.navigationController pushViewController:edit animated:YES];
                }
            }
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            [hud hideAnimated:YES];
        }];
        return;
    }
    
//    if (model.details) {
        DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initWithDTie:model];
        [self.navigationController pushViewController:detail animated:NO];
//    }else{
//        [MBProgressHUD showTextHUDWithText:@"正在获取帖子内容" inView:self.view];
//    }
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
    
    self.titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    self.titleLabel.text = @"浏览D帖";
    [self.topView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
        make.right.mas_equalTo(-210 * scale);
    }];
    
    UIButton * shareButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:shareButton];
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-40 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    [[DDShareManager shareManager] updateNumber];
}

- (void)shareButtonDidClicked
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * shareView = [[UIView alloc] initWithFrame:CGRectZero];
    shareView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    [self.view addSubview:shareView];
    [shareView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    CGFloat height = kMainBoundsWidth / 4.f;
    if (KIsiPhoneX) {
        height += 38.f;
    }
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor whiteColor];
    [button addTarget:self action:@selector(bottomButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [shareView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(height);
        make.bottom.mas_equalTo(0);
    }];
    
    UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"homeTP"]];
    [button addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(50 * scale);
        make.width.height.mas_equalTo(96 * scale);
    }];
    
    UILabel * label = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentCenter];
    label.text = @"图片分享列表";
    [button addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(45 * scale);
        make.top.mas_equalTo(imageView.mas_bottom).offset(20 * scale);
    }];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:shareView action:@selector(removeFromSuperview)];
    [shareView addGestureRecognizer:tap];
}

- (void)bottomButtonDidClicked:(UIButton *)button
{
    [button.superview removeFromSuperview];
    [[DDShareManager shareManager] showShareList];
}
- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.pagerView.collectionView) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:self.pagerView.curIndex inSection:0];
        DDCollectionListViewCell * cell = (DDCollectionListViewCell *)[self.pagerView.collectionView cellForItemAtIndexPath:indexPath];
        if (cell) {
            [cell configWithModel:[self.dataSource objectAtIndex:indexPath.item] tag:indexPath.item];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DTieCollectionNeedUpdateNotification object:nil];
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
