//
//  DTieSeeShareViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/12.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieSeeShareViewController.h"
#import "DTieSeeModel.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <WXApi.h>
#import "DTieSeeDetailViewController.h"

@interface DTieSeeShareViewController ()<BMKMapViewDelegate>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) BMKMapView * mapView;

@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, strong) NSMutableArray * pointArray;

@property (nonatomic, strong) DTieModel * model;

@end

@implementation DTieSeeShareViewController

- (instancetype)initWithSource:(NSArray *)dataSource model:(DTieModel *)model
{
    if (self = [super init]) {
        self.dataSource = [[NSMutableArray alloc] initWithArray:dataSource];
        self.pointArray = [[NSMutableArray alloc] init];
        self.model = model;

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
    self.mapView = [[BMKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.rotateEnabled = NO;
    self.mapView.overlookEnabled = NO;
    self.mapView.minZoomLevel = 4.f;
    self.mapView.zoomLevel = 6.f;
    self.mapView.maxZoomLevel = 10.f;
    
    [self.view addSubview:self.mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
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
    
    [self.mapView removeAnnotations:self.pointArray];
    [self.pointArray removeAllObjects];
    
    for (NSInteger i = 0; i < self.dataSource.count; i++) {
        DTieSeeModel * model = [self.dataSource objectAtIndex:i];
        BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake(model.createAddressLat, model.createAddressLng);
        [self.pointArray addObject:annotation];
    }
    
    [self.mapView addAnnotations:self.pointArray];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    BMKAnnotationView * view = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BMKAnnotationView"];
    view.annotation = annotation;
    view.image = [UIImage imageNamed:@"readNumberBG"];
    view.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:[UIView new]];
    
    NSInteger index = [self.pointArray indexOfObject:annotation];
    DTieSeeModel * model = [self.dataSource objectAtIndex:index];
    
    if ([view viewWithTag:888]) {
        UILabel * label = (UILabel *)[view viewWithTag:888];
        
        NSString * title = @"";
        if (model.countTime == 0) {
            title = @"0";
        }else if (model.countTime < 100) {
            title = [NSString stringWithFormat:@"%ld", model.countTime];
        }else{
            title = @"99+";
        }
        
        label.text = title;
        
    }else{
        
        CGFloat width = view.frame.size.width;
        CGFloat logoWidth = width * 47.5f / 52.f;
        CGFloat origin = (width - logoWidth) / 2;
        
        UILabel * label = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentCenter];
        label.frame = CGRectMake(origin, origin, logoWidth, logoWidth);
        label.tag = 888;
        [view addSubview:label];
        
        NSString * title = @"";
        if (model.countTime == 0) {
            title = @"0";
        }else if (model.countTime < 100) {
            title = [NSString stringWithFormat:@"%ld", model.countTime];
        }else{
            title = @"99+";
        }
        
        label.text = title;
        
    }
    
    return view;
}

- (void)shareButtonDidClicked
{
    DTieSeeDetailViewController * detail = [[DTieSeeDetailViewController alloc] initWithModel:self.model shareImage:[self.mapView takeSnapshot]];
    [self.navigationController pushViewController:detail animated:YES];
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
    titleLabel.text = DDLocalizedString(@"Readership Heat Map");
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
