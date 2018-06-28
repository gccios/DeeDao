//
//  DTiePOIViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/7.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTiePOIViewController.h"
#import "DDLocationManager.h"
#import "DTiePOIRequest.h"
#import "DTieCollectionViewCell.h"
#import "CollectionLineTitleView.h"
#import "DTieNewDetailViewController.h"
#import "MBProgressHUD+DDHUD.h"
#import "DTieDetailRequest.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>

@interface DTiePOIViewController () <UICollectionViewDelegate, UICollectionViewDataSource, BMKMapViewDelegate>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, strong) BMKMapView * mapView;

@property (nonatomic, strong) UICollectionView * collectionView;

@property (nonatomic, strong) NSArray * titleSource;
@property (nonatomic, strong) NSMutableArray * dataSource;

@end

@implementation DTiePOIViewController

- (instancetype)initWithDtieModel:(DTieModel *)model
{
    if (self = [super init]) {
        self.dataSource = [[NSMutableArray alloc] init];
        self.model = model;
        [self.dataSource addObject:[NSArray arrayWithObject:model]];
        self.titleSource = @[@"", @"我和好友", @"博主", @"我所关注人", @"部分公开"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
    [self createTopView];
    [self requestPOI];
}

- (void)requestPOI
{
    DTiePOIRequest * request = [[DTiePOIRequest alloc] initWithLat:self.model.sceneAddressLat lng:self.model.sceneAddressLng];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                
                NSMutableArray * myAndFriend = [[NSMutableArray alloc] init];
                NSMutableArray * blogger = [[NSMutableArray alloc] init];
                NSMutableArray * myConcern = [[NSMutableArray alloc] init];
                NSMutableArray * stranger = [[NSMutableArray alloc] init];
                
                
                NSArray * tempArray = [data objectForKey:@"myAndFriendPostList"];
                for (NSInteger i = 0; i < tempArray.count; i++) {
                    NSDictionary * info = [tempArray objectAtIndex:i];
                    DTieModel * model = [DTieModel mj_objectWithKeyValues:info];
                    [myAndFriend addObject:model];
                }
                
                tempArray = [data objectForKey:@"bloggerPostList"];
                for (NSInteger i = 0; i < tempArray.count; i++) {
                    NSDictionary * info = [tempArray objectAtIndex:i];
                    DTieModel * model = [DTieModel mj_objectWithKeyValues:info];
                    [blogger addObject:model];
                }
                
                tempArray = [data objectForKey:@"myConcernPostList"];
                for (NSInteger i = 0; i < tempArray.count; i++) {
                    NSDictionary * info = [tempArray objectAtIndex:i];
                    DTieModel * model = [DTieModel mj_objectWithKeyValues:info];
                    [myConcern addObject:model];
                }
                
                tempArray = [data objectForKey:@"strangerPostList"];
                for (NSInteger i = 0; i < tempArray.count; i++) {
                    NSDictionary * info = [tempArray objectAtIndex:i];
                    DTieModel * model = [DTieModel mj_objectWithKeyValues:info];
                    [stranger addObject:model];
                }
                
                [self.dataSource addObject:myAndFriend];
                [self.dataSource addObject:blogger];
                [self.dataSource addObject:myConcern];
                [self.dataSource addObject:stranger];
                [self.collectionView reloadData];
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * locationView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:locationView];
    [locationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo((kMainBoundsHeight - ((220 + kStatusBarHeight) * scale)) / 5 * 2);
    }];
    
    self.mapView = [[BMKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.mapView.showsUserLocation = NO;
    self.mapView.userTrackingMode = BMKUserTrackingModeNone;
    self.mapView.delegate = self;
    
    [locationView addSubview:self.mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-120 * scale);
    }];
    
    for (UIView * view in self.mapView.subviews) {
        if ([NSStringFromClass([view class]) isEqualToString:@"BMKInternalMapView"]) {
            for (UIView * tempView in view.subviews) {
                if ([tempView isKindOfClass:[UIImageView class]] && tempView.frame.size.width == 66) {
                    tempView.alpha = 0;
                    break;
                }
            }
        }
    }
    
    BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(CLLocationCoordinate2DMake(self.model.sceneAddressLat, self.model.sceneAddressLng), BMKCoordinateSpanMake(.01, .01));
    BMKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
    
    BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(self.model.sceneAddressLat, self.model.sceneAddressLng);
    [self.mapView addAnnotation:annotation];
    
    UIView * navView = [[UIView alloc] initWithFrame:CGRectZero];
    navView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [locationView addSubview:navView];
    [navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(120 * scale);
    }];
    
    UILabel * navLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    navLabel.text = self.model.sceneAddress;
    [navView addSubview:navLabel];
    [navLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-300 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    UIButton * navButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:[UIColor clearColor] title:@"导航过去"];
    [navButton addTarget:self action:@selector(navButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [DDViewFactoryTool cornerRadius:12 * scale withView:navButton];
    navButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    navButton.layer.borderWidth = 3 * scale;
    [navView addSubview:navButton];
    [navButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(72 * scale);
        make.width.mas_equalTo(216 * scale);
    }];
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kMainBoundsWidth / 2, 360 * scale);
    layout.headerReferenceSize = CGSizeMake(kMainBoundsWidth, 70 * scale);
    layout.minimumLineSpacing = 30 * scale;
    layout.minimumInteritemSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerClass:[DTieCollectionViewCell class] forCellWithReuseIdentifier:@"DTieCollectionViewCell"];
    [self.collectionView registerClass:[CollectionLineTitleView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionLineTitleView"];
    self.collectionView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(locationView.mas_bottom);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    UIButton * backLocationButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [backLocationButton setImage:[UIImage imageNamed:@"backLocation"] forState:UIControlStateNormal];
    [backLocationButton addTarget:self action:@selector(backLocationButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:backLocationButton];
    [backLocationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40 * scale);
        make.bottom.mas_equalTo(-30 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
}

- (void)backLocationButtonDidClicked
{
    BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(CLLocationCoordinate2DMake(self.model.sceneAddressLat, self.model.sceneAddressLng), self.mapView.region.span);
    BMKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    BMKAnnotationView * view = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BMKAnnotationView"];
    view.annotation = annotation;
    view.image = [UIImage imageNamed:@"location"];
    view.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:[UIView new]];
    
    return view;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray * data = [self.dataSource objectAtIndex:section];
    return data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * data = [self.dataSource objectAtIndex:indexPath.section];
    DTieModel * model = [data objectAtIndex:indexPath.row];
    
    DTieCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DTieCollectionViewCell" forIndexPath:indexPath];
    cell.coverView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    cell.indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section];
    
    [cell configWithDTieModel:model];
    [cell confiEditEnable:NO];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        CollectionLineTitleView * view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionLineTitleView" forIndexPath:indexPath];
        
        [view confiTitle:[self.titleSource objectAtIndex:indexPath.section]];
        
        return view;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * data = [self.dataSource objectAtIndex:indexPath.section];
    DTieModel * model = [data objectAtIndex:indexPath.row];
    
    if (model.details && model.details.count > 0) {
        DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initWithDTie:model];
        [self.navigationController pushViewController:detail animated:YES];
        return;
    }
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:self.view];
    
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:model.cid type:4 start:0 length:10];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                [model mj_setKeyValues:data];
                
                if (model.ifCanSee == 0) {
                    [MBProgressHUD showTextHUDWithText:@"您没有浏览该帖的权限~" inView:self.view];
                    return;
                }
                
                if (model.deleteFlg == 1) {
                    [MBProgressHUD showTextHUDWithText:@"该帖已被作者删除" inView:self.view];
                    return;
                }
                
                DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initWithDTie:model];
                [self.navigationController pushViewController:detail animated:YES];
            }
        }
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
    }];
}

- (void)navButtonDidClicked
{
    [[DDLocationManager shareManager] mapNavigationToLongitude:self.model.sceneAddressLng latitude:self.model.sceneAddressLat poiName:self.model.sceneAddress withViewController:self.navigationController];
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
    titleLabel.text = self.model.sceneBuilding;
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

- (void)dealloc
{
    self.mapView.delegate = nil;
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
