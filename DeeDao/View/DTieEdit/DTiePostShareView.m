//
//  DTiePostShareView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/12.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTiePostShareView.h"
#import <UIImageView+WebCache.h>
#import <Masonry.h>
#import "MBProgressHUD+DDHUD.h"
#import "WeChatManager.h"
#import "GCCScreenImage.h"
#import "GetWXAccessTokenRequest.h"
#import "DDTool.h"

#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>

@interface DTiePostShareView ()<BMKMapViewDelegate>

@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, strong) UIImageView * logoImageView;

@property (nonatomic, strong) UIImageView * mapImageView;
@property (nonatomic, strong) BMKMapView * mapView;

@property (nonatomic, assign) BOOL isFinishMap;
@property (nonatomic, assign) BOOL isFinishCode;

@property (nonatomic, assign) NSInteger shareType;

@end

@implementation DTiePostShareView

- (instancetype)initWithModel:(DTieModel *)model
{
    if (self = [super init]) {
        self.model = model;
        [self configShareView];
    }
    return self;
}

- (void)startShare
{
    self.shareType = 1;
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:[UIApplication sharedApplication].keyWindow];
    
    GetWXAccessTokenRequest * request = [[GetWXAccessTokenRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSDictionary *dict = [response objectForKey:@"data"];
            if (KIsDictionary(dict)) {
                [WeChatManager shareManager].miniProgramToken = [dict objectForKey:@"access_token"];
            }
        }
        
        NSInteger postID = self.model.cid;
        if (postID == 0) {
            postID = self.model.postId;
        }
        
        [[WeChatManager shareManager] getMiniProgromCodeWithPostID:postID handle:^(UIImage *image) {
            
            if (image) {
                [self.logoImageView setImage:image];
            }else{
                [self.logoImageView setImage:[UIImage imageNamed:@"gongzhongCode"]];
            }
            
            if (self.isFinishMap) {
                [self share];
                [hud hideAnimated:YES];
            }
            self.isFinishCode = YES;
        }];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (self.isFinishMap) {
            [hud hideAnimated:YES];
        }
        self.isFinishCode = YES;
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        if (self.isFinishMap) {
            [hud hideAnimated:YES];
        }
        self.isFinishCode = YES;
        
    }];
}

- (void)share
{
    UIImage * shareImage = [GCCScreenImage screenView:self];
    if (self.shareType == 1) {
        [[WeChatManager shareManager] shareImage:shareImage];
    }else if (self.shareType == 2) {
        [DDTool saveImageInSystemPhoto:shareImage];
    }
    [self removeFromSuperview];
}

- (void)saveToAlbum
{
    self.shareType = 2;
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:[UIApplication sharedApplication].keyWindow];
    
    GetWXAccessTokenRequest * request = [[GetWXAccessTokenRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSDictionary *dict = [response objectForKey:@"data"];
            if (KIsDictionary(dict)) {
                [WeChatManager shareManager].miniProgramToken = [dict objectForKey:@"access_token"];
            }
        }
        
        NSInteger postID = self.model.cid;
        if (postID == 0) {
            postID = self.model.postId;
        }
        
        [[WeChatManager shareManager] getMiniProgromCodeWithPostID:postID handle:^(UIImage *image) {
            
            if (image) {
                [self.logoImageView setImage:image];
            }else{
                [self.logoImageView setImage:[UIImage imageNamed:@"gongzhongCode"]];
            }
            
            if (self.isFinishMap) {
                [self share];
                [hud hideAnimated:YES];
            }
            self.isFinishCode = YES;
        }];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (self.isFinishMap) {
            [hud hideAnimated:YES];
        }
        self.isFinishCode = YES;
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        if (self.isFinishMap) {
            [hud hideAnimated:YES];
        }
        self.isFinishCode = YES;
        
    }];
}

- (void)configShareView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    self.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.frame = CGRectMake(0, 0, kMainBoundsWidth, 1920 * scale);
    
    UIView * userLogoBGView = [[UIView alloc] initWithFrame:CGRectZero];
    userLogoBGView.backgroundColor = [UIColor whiteColor];
    [self addSubview:userLogoBGView];
    [userLogoBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(80 * scale);
        make.left.mas_equalTo(60 * scale);
        make.width.height.mas_equalTo(96 * scale);
    }];
    userLogoBGView.layer.cornerRadius = 48 * scale;
    userLogoBGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    userLogoBGView.layer.shadowOpacity = .5f;
    userLogoBGView.layer.shadowRadius = 6 * scale;
    userLogoBGView.layer.shadowOffset = CGSizeMake(0, 3 * scale);
    
    UIImageView * userLogoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [userLogoImageView sd_setImageWithURL:[NSURL URLWithString:self.model.portraituri]];
    userLogoImageView.contentMode = UIViewContentModeScaleAspectFill;
    [userLogoBGView addSubview:userLogoImageView];
    [userLogoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(96 * scale);
    }];
    userLogoImageView.layer.cornerRadius = 48 * scale;
    userLogoImageView.clipsToBounds = YES;
    
    UILabel * userNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    userNameLabel.font = kPingFangRegular(36 * scale);
    userNameLabel.textColor = UIColorFromRGB(0x333333);
    userNameLabel.textAlignment = NSTextAlignmentLeft;
    userNameLabel.text = self.model.nickname;
    [self addSubview:userNameLabel];
    [userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.mas_equalTo(userLogoBGView);
        make.left.mas_equalTo(userLogoBGView.mas_right).offset(60 * scale);
    }];
    
    UIView * BGView = [[UIView alloc] initWithFrame:CGRectZero];
    BGView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self addSubview:BGView];
    [BGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(204 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(1224 * scale);
    }];
    BGView.layer.cornerRadius = 24 * scale;
    BGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    BGView.layer.shadowOpacity = .3f;
    BGView.layer.shadowRadius = 12 * scale;
    BGView.layer.shadowOffset = CGSizeMake(0, 6 * scale);
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.model.postFirstPicture]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [BGView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0 * scale);
        make.left.mas_equalTo(0 * scale);
        make.right.mas_equalTo(0 * scale);
        make.height.mas_equalTo(636 * scale);
    }];
    imageView.layer.cornerRadius = 24 * scale;
    imageView.clipsToBounds = YES;
    
    UIView * postTitleView = [[UIView alloc] initWithFrame:CGRectZero];
    postTitleView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    [imageView addSubview:postTitleView];
    [postTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(120 * scale);
    }];
    
    UILabel * postTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    postTitleLabel.font = kPingFangRegular(42 * scale);
    postTitleLabel.textColor = UIColorFromRGB(0xFFFFFF);
    postTitleLabel.textAlignment = NSTextAlignmentLeft;
    postTitleLabel.text = self.model.postSummary;
    [postTitleView addSubview:postTitleLabel];
    [postTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(120 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    
    UIView * locationView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:locationView];
    [locationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(108 * scale);
    }];
    
    UILabel * locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    locationLabel.font = kPingFangRegular(36 * scale);
    locationLabel.textColor = UIColorFromRGB(0x333333);
    locationLabel.textAlignment = NSTextAlignmentCenter;
    locationLabel.text = [NSString stringWithFormat:@"地址：%@", self.model.sceneAddress];
    [locationView addSubview:locationLabel];
    [locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(108 * scale);
    }];
    
    self.mapImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.mapImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.mapImageView.clipsToBounds = YES;
    [BGView addSubview:self.mapImageView];
    [self.mapImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.top.mas_equalTo(locationView.mas_bottom);
    }];
    
    self.mapView = [[BMKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = NO;
    self.mapView.userTrackingMode = BMKUserTrackingModeNone;
    self.mapView.gesturesEnabled = NO;
    self.mapView.buildingsEnabled = NO;
    
    [BGView insertSubview:self.mapView atIndex:0];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.top.mas_equalTo(locationView.mas_bottom);
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
    
    BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(self.model.sceneAddressLat, self.model.sceneAddressLng);
    [self.mapView addAnnotation:annotation];
    [self.mapView setRegion:BMKCoordinateRegionMake(CLLocationCoordinate2DMake(self.model.sceneAddressLat, self.model.sceneAddressLng), BMKCoordinateSpanMake(2, 2))];
    
    UIView * logoBGView = [[UIView alloc] initWithFrame:CGRectZero];
    logoBGView.backgroundColor = [UIColor whiteColor];
    [self addSubview:logoBGView];
    [logoBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(BGView.mas_bottom).offset(-132 * scale);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(264 * scale);
    }];
    logoBGView.layer.cornerRadius = 132 * scale;
    logoBGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    logoBGView.layer.shadowOpacity = .5f;
    logoBGView.layer.shadowRadius = 24 * scale;
    logoBGView.layer.shadowOffset = CGSizeMake(0, 12 * scale);
    
    self.logoImageView = [[UIImageView alloc] init];
    [logoBGView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(220 * scale);
    }];
    self.logoImageView.layer.cornerRadius = 80 * scale;
    self.logoImageView.clipsToBounds = YES;
    
//    UIImageView * letterImageview = [[UIImageView alloc] init];
//    [letterImageview setImage:[UIImage imageNamed:@"letterLogo"]];
//    [imageView addSubview:letterImageview];
//    [letterImageview mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(60 * scale);
//        make.right.mas_equalTo(-60 * scale);
//        make.width.mas_equalTo(168 * scale);
//        make.height.mas_equalTo(120 * scale);
//    }];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = kPingFangRegular(36 * scale);
    label.textColor = UIColorFromRGB(0x999999);
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
    label.text = @"识别二维码  收藏美食卡";
    [self addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.logoImageView.mas_bottom).offset(80 * scale);
    }];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(120 * scale);
        make.bottom.mas_equalTo(-131 * scale);
        make.right.mas_equalTo(-120 * scale);
        make.height.mas_equalTo(3 * scale);
    }];
    
    UILabel * tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    tipLabel.backgroundColor = [UIColor whiteColor];
    tipLabel.font = kPingFangRegular(36 * scale);
    tipLabel.textColor = UIColorFromRGB(0x333333);
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.text = @"发布于Deedao地到APP";
    [self addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(lineView);
        make.width.mas_equalTo(450 * scale);
        make.height.mas_equalTo(60 * scale);
    }];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    BMKAnnotationView * view = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BMKAnnotationView"];
    view.annotation = annotation;
    view.image = [UIImage imageNamed:@"locationBig"];
    view.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:[UIView new]];
    
    return view;
}

- (void)mapViewDidFinishRendering:(BMKMapView *)mapView
{
    [self.mapImageView setImage:[mapView takeSnapshot]];
    [mapView removeFromSuperview];
    if (self.isFinishCode) {
        [self share];
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
    }
    self.isFinishMap = YES;
}

- (void)dealloc
{
    self.mapView.delegate = nil;
}

@end
