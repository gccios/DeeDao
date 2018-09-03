//
//  ShowSeriesViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/13.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "ShowSeriesViewController.h"
#import "DTieCollectionViewCell.h"
#import "DTieNewDetailViewController.h"
#import "MBProgressHUD+DDHUD.h"
#import "DTieDetailRequest.h"
#import "DDLocationManager.h"
#import "SecurityFriendController.h"
#import "ForwardSeriesRequest.h"
#import "WeChatManager.h"
#import "NewAddSeriesController.h"
#import <UIImageView+WebCache.h>
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <WXApi.h>

@interface ShowSeriesViewController () <UICollectionViewDelegate, UICollectionViewDataSource, BMKMapViewDelegate, SecurityFriendDelegate>

@property (nonatomic, strong) SeriesModel * seriesModel;

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) BMKMapView * mapView;

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) UIView * shareView;

@end

@implementation ShowSeriesViewController

- (instancetype)initWithData:(NSMutableArray *)dataSource series:(SeriesModel *)seriesModel
{
    if (self = [super init]) {
        self.dataSource = [NSMutableArray arrayWithArray:dataSource];
        self.seriesModel = seriesModel;
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
    
    UIView * locationView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:locationView];
    [locationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo((kMainBoundsHeight - ((220 + kStatusBarHeight) * scale)) / 5 * 2);
    }];
    
    self.mapView = [[BMKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    //设置定位图层自定义样式
    BMKLocationViewDisplayParam *userlocationStyle = [[BMKLocationViewDisplayParam alloc] init];
    //跟随态旋转角度是否生效
    userlocationStyle.isRotateAngleValid = NO;
    //精度圈是否显示
    userlocationStyle.isAccuracyCircleShow = NO;
    userlocationStyle.locationViewOffsetX = 0;//定位偏移量（经度）
    userlocationStyle.locationViewOffsetY = 0;//定位偏移量（纬度）
    [self.mapView updateLocationViewWithParam:userlocationStyle];
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = BMKUserTrackingModeNone;
    self.mapView.rotateEnabled = NO;
    self.mapView.buildingsEnabled = NO;
    self.mapView.showMapPoi = NO;
    [self.mapView updateLocationData:[DDLocationManager shareManager].userLocation];
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
    
    [self meterDistance];
    
    UIView * navView = [[UIView alloc] initWithFrame:CGRectZero];
    navView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [locationView addSubview:navView];
    [navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(120 * scale);
    }];
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kMainBoundsWidth / 2, 360 * scale);
    layout.minimumLineSpacing = 30 * scale;
    layout.minimumInteritemSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerClass:[DTieCollectionViewCell class] forCellWithReuseIdentifier:@"DTieCollectionViewCell"];
    self.collectionView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mapView.mas_bottom);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.collectionView.contentInset = UIEdgeInsetsMake(0 * scale, 0, 324 * scale, 0);
    
    UIButton * backLocationButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [backLocationButton setImage:[UIImage imageNamed:@"backLocation"] forState:UIControlStateNormal];
    [backLocationButton addTarget:self action:@selector(backLocationButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:backLocationButton];
    [backLocationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40 * scale);
        make.bottom.mas_equalTo(-30 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    UIButton * editSeriesButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"编辑系列"];
    editSeriesButton.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [DDViewFactoryTool cornerRadius:24 * scale withView:editSeriesButton];
    editSeriesButton.layer.borderColor = UIColorFromRGB(0xDB5282).CGColor;
    editSeriesButton.layer.borderWidth = 3 * scale;
    [self.view addSubview:editSeriesButton];
    [editSeriesButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.bottom.mas_equalTo(-63 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(144 * scale);
    }];
    [editSeriesButton addTarget:self action:@selector(editSeries) forControlEvents:UIControlEventTouchUpInside];
}

- (void)editSeries
{
    NewAddSeriesController * add = [[NewAddSeriesController alloc] initWithDataSource:self.dataSource series:self.seriesModel];
    [self.navigationController pushViewController:add animated:YES];
}

- (void)meterDistance
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        DTieModel * resultModel;
        CLLocationDistance mostMeters = 0;
        BMKMapPoint userPoint = BMKMapPointForCoordinate([DDLocationManager shareManager].userLocation.location.coordinate);
        
        NSMutableArray * tempPointArray = [[NSMutableArray alloc] init];
        
        for (DTieModel * model in self.dataSource) {
            BMKMapPoint point = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(model.sceneAddressLat, model.sceneAddressLng));
            
            CLLocationDistance distance = BMKMetersBetweenMapPoints(userPoint, point);
            if (distance > mostMeters) {
                mostMeters = distance;
                resultModel = model;
            }
            
            BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc] init];
            annotation.coordinate = CLLocationCoordinate2DMake(model.sceneAddressLat, model.sceneAddressLng);
            [tempPointArray addObject:annotation];
        }
        
        CLLocationDegrees lng = fabs([DDLocationManager shareManager].userLocation.location.coordinate.longitude - resultModel.sceneAddressLng);
        CLLocationDegrees lat = fabs([DDLocationManager shareManager].userLocation.location.coordinate.latitude - resultModel.sceneAddressLat);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake([DDLocationManager shareManager].userLocation.location.coordinate, BMKCoordinateSpanMake(lat * 2.3, lng * 2.3));
//            BMKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
            [self.mapView setRegion:viewRegion animated:YES];
            [self.mapView addAnnotations:tempPointArray];
        });
        
    });
}

- (void)backLocationButtonDidClicked
{
    BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake([DDLocationManager shareManager].userLocation.location.coordinate, self.mapView.region.span);
    BMKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    NSInteger index = [self.mapView.annotations indexOfObject:annotation];
    BMKAnnotationView * view = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BMKAnnotationView"];
    if (index >= self.dataSource.count) {
        return view;
    }
    DTieModel * model = [self.dataSource objectAtIndex:index];
    
    if (model.bloggerFlg == 1) {
        
        view.annotation = annotation;
        if (model.source == 1) {
            view.image = [UIImage imageNamed:@"bozhuGongzhong"];
        }else if (model.concernFlg == 1) {
            view.image = [UIImage imageNamed:@"bozhuGuanzhu"];
        }else{
            view.image = [UIImage imageNamed:@"touxiangkuang"];
        }
        view.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:[UIView new]];
        
        if ([view viewWithTag:888]) {
            UIImageView * imageView = (UIImageView *)[view viewWithTag:888];
            [imageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
        }else{
            
            CGFloat width = view.frame.size.width;
            CGFloat logoWidth;
            CGFloat originX;
            CGFloat originY;
            
            if (model.source == 1) {
                
                logoWidth = width * .6f;
                originX = width * .2f;
                originY = width * .19f;
                
            }else if (model.concernFlg == 1) {
                
                logoWidth = width * .6f;
                originX = width * .19f;
                originY = width * .23f;
                
            }else{
                
                logoWidth = width * 47.5f / 52.f;
                originX = (width - logoWidth) / 2;
                originY = (width - logoWidth) / 2;
                
            }
            
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(originX, originY, logoWidth, logoWidth)];
            
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.tag = 888;
            [view addSubview:imageView];
            [DDViewFactoryTool cornerRadius:logoWidth / 2 withView:imageView];
            [imageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
        }
        
        return view;
        
    }else{
        view.annotation = annotation;
        view.image = [UIImage imageNamed:@"touxiangkuang"];
        view.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:[UIView new]];
        
        if ([view viewWithTag:888]) {
            UIImageView * imageView = (UIImageView *)[view viewWithTag:888];
            [imageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
        }else{
            
            CGFloat width = view.frame.size.width;
            CGFloat logoWidth = width * 47.5f / 52.f;
            CGFloat origin = (width - logoWidth) / 2;
            
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(origin, origin, logoWidth, logoWidth)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.tag = 888;
            [view addSubview:imageView];
            [DDViewFactoryTool cornerRadius:logoWidth / 2 withView:imageView];
            [imageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
        }
        
        return view;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.row];
    
    DTieCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DTieCollectionViewCell" forIndexPath:indexPath];
    cell.coverView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    cell.indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section];
    
    [cell configWithDTieModel:model];
    [cell confiEditEnable:NO];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.row];
    
    if (model.details && model.details.count > 0) {
        if (model.landAccountFlg == 2 && model.authorId != [UserManager shareManager].user.cid) {
            [MBProgressHUD showTextHUDWithText:@"该帖已被作者设为私密状态" inView:self.view];
            return;
        }
        DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initWithDTie:model];
        [self.navigationController pushViewController:detail animated:YES];
        return;
    }
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:self.view];
    
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:model.postId type:4 start:0 length:10];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        
        if (KIsDictionary(response)) {
            NSInteger code = [[response objectForKey:@"status"] integerValue];
            if (code == 4002) {
                [MBProgressHUD showTextHUDWithText:@"该帖已被作者删除~" inView:self.view];
                return;
            }
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                [model mj_setKeyValues:data];
                
                if (model.deleteFlg == 1) {
                    [MBProgressHUD showTextHUDWithText:@"该帖已被作者删除" inView:self.view];
                    return;
                }
                
                if (model.landAccountFlg == 2 && model.authorId != [UserManager shareManager].user.cid) {
                    [MBProgressHUD showTextHUDWithText:@"该帖已被作者设为私密状态" inView:self.view];
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
    titleLabel.text = self.seriesModel.seriesTitle;
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
        make.right.mas_equalTo(-60 * scale);
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
}

- (void)shareButtonDidClicked
{
    [[UIApplication sharedApplication].keyWindow addSubview:self.shareView];
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
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
        BOOL isBozhu = NO;;
        if ([UserManager shareManager].user.bloggerFlg == 1) {
            isBozhu = YES;
        }
        
        if (isBozhu && isInstallWX) {
            imageNames = @[@"shareweixin", @"shareFriend", @"sharebozhu"];
            titles = @[@"微信好友或群", @"地到好友", @"地到博主"];
            startTag = 10;
        }else if (isBozhu && !isInstallWX) {
            imageNames = @[@"shareFriend", @"sharebozhu"];
            titles = @[@"地到好友", @"地到博主"];
            startTag = 11;
        }else if (!isBozhu && isInstallWX) {
            imageNames = @[@"shareweixin", @"shareFriend"];
            titles = @[@"微信好友或群", @"地到好友"];
            startTag = 10;
        }
        
        CGFloat width = kMainBoundsWidth / imageNames.count;
        CGFloat height = kMainBoundsWidth / 4.f;
        if (KIsiPhoneX) {
            height += 38.f;
        }
        CGFloat scale = kMainBoundsWidth / 1080.f;
        for (NSInteger i = 0; i < imageNames.count; i++) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor whiteColor];
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
    if (button.tag == 10) {
        
        [[WeChatManager shareManager] shareMiniProgramWithSeries:self.seriesModel image:[self.mapView takeSnapshot]];
        
    }else if (button.tag == 11) {
        
        SecurityFriendController * friend = [[SecurityFriendController alloc] initMulSelectWithDataDict:[NSDictionary new] nameKeys:[NSArray new] selectModels:[NSMutableArray new]];
        friend.delegate = self;
        [self.navigationController pushViewController:friend animated:YES];
        
    }else if (button.tag == 12) {
        
        NSString * urlLink = [NSString stringWithFormat:@"pages/album/album?albumId=%ldisBlogger", self.seriesModel.cid];
        
        NSString * text = [NSString stringWithFormat:@"系列 -- %@\n请把以下文字和链接放置到您的微信公众号博文里：点击这里，一键收藏本文所有的推荐到您的 Deedao 小程序（和 APP）里，在您恰好路过的时候提醒您不要错过😃\n%@\n\n", self.seriesModel.seriesTitle, urlLink];
        
        NSError * error = nil;
        NSFileManager * manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:DDBloggerLinkPath]) {
            NSFileHandle * writeHandle = [NSFileHandle fileHandleForWritingAtPath:DDBloggerLinkPath];
            if (writeHandle) {
                [writeHandle seekToEndOfFile];
                NSData * linkData = [text dataUsingEncoding:NSUTF8StringEncoding];
                [writeHandle writeData:linkData];
                [writeHandle closeFile];
            }else{
                error = [NSError new];
            }
        }else{
            [text writeToFile:DDBloggerLinkPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        }
        
        if (error) {
            [MBProgressHUD showTextHUDWithText:@"获取失败" inView:self.view];
        }else{
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = urlLink;
            [MBProgressHUD showTextHUDWithText:@"已复制到粘贴板和博主链接" inView:self.view];
        }
        
    }
}

- (void)friendDidMulSelectComplete:(NSArray *)selectArray
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for (UserModel * model in selectArray) {
        [array addObject:@(model.cid)];
    }
    ForwardSeriesRequest * request = [[ForwardSeriesRequest alloc] initWithSeriesID:self.seriesModel.cid userList:array];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self.navigationController popViewControllerAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"转发成功" inView:self.view];
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self.navigationController popViewControllerAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"转发失败" inView:self.view];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self.navigationController popViewControllerAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:self.view];
    }];
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
