//
//  DDFoundViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDFoundViewController.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <BaiduMapAPI_Map/BMKCircleView.h>
#import <BaiduMapAPI_Map/BMKGroundOverlay.h>
#import "DDLocationManager.h"
#import "SCSafariPageController.h"
#import "OnlyMapViewController.h"
#import "DDCollectionViewController.h"
#import "DTieSearchRequest.h"
#import "DDTool.h"
#import "DTieModel.h"
#import <UIImageView+WebCache.h>
#import "DTieFoundEditView.h"
#import "DTieNewEditViewController.h"
#import "MBProgressHUD+DDHUD.h"
#import "SelectFriendRequest.h"
#import "DTieMapSelectFriendView.h"
#import "MapShowYaoyueView.h"
#import "SelectMapYaoyueRequest.h"
#import "DTieMapYaoyueModel.h"
#import "UIViewController+LGSideMenuController.h"
#import "DTieNewEditViewController.h"
#import "DTieNewViewController.h"
#import "DTieSearchViewController.h"
#import "ChooseTypeViewController.h"
#import "ChooseTimeView.h"
#import "ChooseCategoryView.h"
#import "DDShareManager.h"
//#import "DDNotificationViewController.h"
#import "MapShowNotificationView.h"
#import "MapShowPostView.h"
#import "WYYListViewController.h"
#import "YueFanViewController.h"
#import "MarkViewController.h"
#import "DDBackWidow.h"
#import "CreateDTieRequest.h"
#import "DTieDetailRequest.h"
#import "DTieNewDetailViewController.h"
#import <TZImagePickerController.h>
#import "QNDDUploadManager.h"
#import "GCCScreenImage.h"
#import "DDGroupViewController.h"
#import "DDGroupPostListViewController.h"
#import "DDFoundSearchListController.h"
#import "DDAuthorGroupDetailController.h"
#import "DDGroupDetailViewController.h"
#import "DDGroupRequest.h"
#import "DDShakeRequest.h"

@interface DDFoundViewController () <BMKMapViewDelegate, SCSafariPageControllerDelegate, SCSafariPageControllerDataSource, OnlyMapViewControllerDelegate, DTieFoundEditViewDelegate, DTieMapSelecteFriendDelegate, ChooseTypeViewControllerDelegate, BMKGeoCodeSearchDelegate, TZImagePickerControllerDelegate, CAAnimationDelegate>

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UIView * searchTopView;
@property (nonatomic, strong) UITextField * textField;
@property (nonatomic, strong) UIButton * topTimeButton;
@property (nonatomic, strong) UIButton * topSourceButton;

@property (nonatomic, strong) UIButton * locationButton;
@property (nonatomic, strong) UIButton * pindaoButton;
@property (nonatomic, strong) UILabel * pindaoLabel;

@property (nonatomic, strong) UIButton * searchButton;
@property (nonatomic, assign) BOOL isSearch;

@property (nonatomic, strong) UIView * topAlertView;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UILabel * topAlertLabel;

@property (nonatomic, strong) UIButton * picButton;
@property (nonatomic, assign) BOOL picIsUser;

@property (nonatomic, strong) BMKMapView * mapView;
@property (nonatomic, strong) BMKGeoCodeSearch *geocodesearch;
@property (nonatomic, assign) BOOL isFirst;

@property (nonatomic, strong) SCSafariPageController * safariPageController;
@property (nonatomic, strong) NSMutableArray * mapVCSource;

@property (nonatomic, assign) NSInteger sourceType;

@property (nonatomic, strong) NSMutableArray * mapSource;

@property (nonatomic, assign) NSInteger year;

@property (nonatomic, strong) UIButton * backLocationButton;

@property (nonatomic, strong) UIView * tipView;
@property (nonatomic, strong) UILabel * tipLabel;

@property (nonatomic, assign) CLLocationCoordinate2D markCoordinate;
@property (nonatomic, strong) BMKCircle * circle;

@property (nonatomic, assign) BOOL isMotion;

@property (nonatomic, copy) NSString * logoBGName;
@property (nonatomic, strong) UIColor * logoBGColor;

@property (nonatomic, strong) NSMutableArray * friendSource;
@property (nonatomic, strong) NSMutableArray * yaoyueFriendSource;
@property (nonatomic, strong) DTieMapSelectFriendView * yaoyueSelectView;

@property (nonatomic, strong) NSMutableArray * yaoyueMapSource;

@property (nonatomic, assign) NSInteger minTime;
@property (nonatomic, assign) NSInteger maxTime;
@property (nonatomic, assign) NSInteger searchType;

@property (nonatomic, assign) BOOL isNotification;
@property (nonatomic, assign) NSInteger addType; //1是mark点 2是赴约帖 3是发帖子
@property (nonatomic, assign) BOOL isPushing;

@property (nonatomic, strong) UIView * bottomView;
@property (nonatomic, strong) UIImageView * upImageView;
@property (nonatomic, strong) UIView * downView;
@property (nonatomic, assign) BOOL bottomIsOpen;

@property (nonatomic, strong) DTieModel * uploadModel;

@property (nonatomic, strong) UILabel * groupNameLabel;

@property (nonatomic, strong) DDGroupModel * groupModel;

@property (nonatomic, strong) UIView * tagView;

@property (nonatomic, strong) UIButton * showNumerButton;
@property (nonatomic, assign) BOOL isShowNumber;

@property (nonatomic, assign) NSInteger shakeCount;

@end

@implementation DDFoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.year = -1;
    
    self.isFirst = YES;
    // Do any additional setup after loading the view.
    
    self.sourceType = 11;
    self.logoBGName = @"touxiangkuanghui";
    self.logoBGColor = UIColorFromRGB(0x999999);
    
    self.groupModel = [[DDGroupModel alloc] initWithMyHome];
    
    self.geocodesearch = [[BMKGeoCodeSearch alloc] init];
    self.geocodesearch.delegate = self;
    
    [self getMyFriendList];
    [self creatViews];
    [self creatTopView];
    self.timeLabel.text = @"全部时间";
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BMKReverseGeoCodeSearchOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeSearchOption alloc] init];
        reverseGeocodeSearchOption.location = self.mapView.centerCoordinate;
        [self.geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
        
        [self requestMapViewLocations];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postGroupDidChange:) name:@"DDGroupDidChange" object:nil];
}

- (void)postGroupDidChange:(NSNotification *)notification
{
    DDGroupModel * model = (DDGroupModel *)notification.object;
    self.groupNameLabel.text = model.groupName;
    self.groupModel = model;
    [self requestMapViewLocations];
    
    if (model.cid == -1 || model.cid == -4 || model.cid == -5) {
        self.showNumerButton.hidden = YES;
    }else{
        self.showNumerButton.hidden = NO;
    }
}

- (void)getMyFriendList
{
    SelectFriendRequest * request = [[SelectFriendRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.friendSource removeAllObjects];
                for (NSInteger i = 0; i < data.count; i++) {
                    NSDictionary * dict = [data objectAtIndex:i];
                    UserModel * model = [UserModel mj_objectWithKeyValues:dict];
                    [self.friendSource addObject:model];
                }
                self.yaoyueSelectView = [[DTieMapSelectFriendView alloc] initWithFrendSource:self.friendSource];
                self.yaoyueSelectView.delegate = self;
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)mapSelectFriendView:(DTieMapSelectFriendView *)selectView didSelectFriend:(NSArray *)selectFriend
{
//    self.topSelectButton.alpha = 1.f;
    
    [self.yaoyueFriendSource removeAllObjects];
    [self.yaoyueFriendSource addObjectsFromArray:selectFriend];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self requestMapViewLocations];
}

- (void)groupImageViewDidTap
{
    if (self.groupModel.isSystem) {
        return;
    }
    
    if (self.groupModel.groupCreateUser == [UserManager shareManager].user.cid) {
        DDAuthorGroupDetailController * detail = [[DDAuthorGroupDetailController alloc] initWithModel:self.groupModel];
        [self.navigationController pushViewController:detail animated:YES];
    }else{
        DDGroupDetailViewController * detail = [[DDGroupDetailViewController alloc] initWithModel:self.groupModel];
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (void)creatViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.mapView = [[BMKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.mapView.delegate = self;
    //设置定位图层自定义样式
    BMKLocationViewDisplayParam *userlocationStyle = [[BMKLocationViewDisplayParam alloc] init];
    //跟随态旋转角度是否生效
    userlocationStyle.isRotateAngleValid = NO;
    //精度圈是否显示
    userlocationStyle.isAccuracyCircleShow = NO;
    userlocationStyle.locationViewOffsetX = 0;//定位偏移量（经度）
    userlocationStyle.locationViewOffsetY = 0;//定位偏移量（纬度）
    userlocationStyle.locationViewImgName = @"currentLocation";
    [self.mapView updateLocationViewWithParam:userlocationStyle];
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = BMKUserTrackingModeNone;
    self.mapView.buildingsEnabled = NO;
    self.mapView.showMapPoi = YES;
    self.mapView.rotateEnabled = NO;
    
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
    
    UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"location"]];
    [self.mapView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(90 * scale);
    }];
    
    [self updateUserLocation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserLocation) name:DDUserLocationDidUpdateNotification object:nil];
    
    self.safariPageController = [[SCSafariPageController alloc] init];
    self.safariPageController.canRemoveOnSwipe = NO;
    [self.safariPageController setDataSource:self];
    [self.safariPageController setDelegate:self];
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"mapChooseBG" ofType:@"jpeg"];
    if (isEmptyString(path)) {
        self.safariPageController.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
    }else{
        UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:[UIScreen mainScreen].bounds contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageWithContentsOfFile:path]];
        [self.safariPageController.view insertSubview:imageView atIndex:0];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    
    self.backLocationButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(kMainBoundsWidth - 180 * scale, kMainBoundsHeight - 480 * scale, 120 * scale, 120 * scale) font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self.backLocationButton setImage:[UIImage imageNamed:@"backLocation"] forState:UIControlStateNormal];
    [self.backLocationButton addTarget:self action:@selector(backLocationButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backLocationButton];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kMainBoundsHeight - 246 * scale, kMainBoundsWidth, 384 * scale)];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 60 * scale, kMainBoundsWidth, 450 * scale);
    [self.bottomView.layer addSublayer:gradientLayer];
    [self.view addSubview:self.bottomView];
    
    UISwipeGestureRecognizer * swipe1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(bottomDidSwipe:)];
    swipe1.direction = UISwipeGestureRecognizerDirectionUp;
    [self.bottomView addGestureRecognizer:swipe1];
    
    UISwipeGestureRecognizer * swipe2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(bottomDidSwipe:)];
    swipe2.direction = UISwipeGestureRecognizerDirectionDown;
    [self.bottomView addGestureRecognizer:swipe2];
    
//    UIImageView * bottomBGView = [DDViewFactoryTool createImageViewWithFrame:CGRectMake(0, 100 * scale, kMainBoundsWidth, 450 * scale) contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"homeColor"]];
//    [self.bottomView addSubview:bottomBGView];
    
    self.downView = [[UIView alloc] initWithFrame:CGRectMake(0, 240 * scale, kMainBoundsWidth, 144 * scale)];
    self.downView.backgroundColor = [UIColorFromRGB(0xFFFFFF) colorWithAlphaComponent:.2f];
    [self.bottomView addSubview:self.downView];
    
    self.pindaoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.pindaoButton setImage:[UIImage imageNamed:@"homeGroup"] forState:UIControlStateNormal];
    [self.pindaoButton addTarget:self action:@selector(typeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.pindaoButton];
    [self.pindaoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0 * scale);
        make.width.height.mas_equalTo(120 * scale);
        make.top.mas_equalTo(90 * scale);
    }];
    
    self.pindaoLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentLeft];
    self.pindaoLabel.text = DDLocalizedString(@"Group");
    [self.bottomView addSubview:self.pindaoLabel];
    [self.pindaoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.pindaoButton);
        make.left.mas_equalTo(self.pindaoButton.mas_right).offset(20 * scale);
        make.height.mas_equalTo(60 * scale);
    }];
    self.pindaoLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer * pindaoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(typeButtonDidClicked)];
    [self.pindaoLabel addGestureRecognizer:pindaoTap];
    
    self.tagView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tagView.backgroundColor = UIColorFromRGB(0xFC6E60);
    [DDViewFactoryTool cornerRadius:7.5 withView:self.tagView];
    self.tagView.layer.borderColor = UIColorFromRGB(0xFFFFFF).CGColor;
    self.tagView.layer.borderWidth = .5f;
    [self.pindaoButton addSubview:self.tagView];
    [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.pindaoButton).offset(-5 * scale);
        make.top.mas_equalTo(self.pindaoButton).offset(5 * scale);
        make.width.height.mas_equalTo(15);
    }];
    self.tagView.hidden = YES;
    
    UIButton * zujuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [zujuButton setImage:[UIImage imageNamed:@"zujuHome"] forState:UIControlStateNormal];
    [zujuButton addTarget:self action:@selector(zujuButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:zujuButton];
    [zujuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-140 * scale);
        make.width.height.mas_equalTo(120 * scale);
        make.top.mas_equalTo(90 * scale);
    }];
    
    UILabel * zujuLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentCenter];
    zujuLabel.text = DDLocalizedString(@"HomeZuju");
    [self.bottomView addSubview:zujuLabel];
    [zujuLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(zujuButton);
        make.left.mas_equalTo(zujuButton.mas_right).offset(12 * scale);
        make.height.mas_equalTo(60 * scale);
    }];
    zujuLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer * zujuTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zujuButtonDidClicked)];
    [zujuLabel addGestureRecognizer:zujuTap];
    
    UIImageView * snapImageview = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"snap"]];
    snapImageview.userInteractionEnabled = YES;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(snapButtonDidClicked)];
    UILongPressGestureRecognizer * longGress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(snapLongButtonDidClicked)];
    [tap requireGestureRecognizerToFail:longGress];
    [snapImageview addGestureRecognizer:tap];
    [snapImageview addGestureRecognizer:longGress];
    
    [self.bottomView addSubview:snapImageview];
    [snapImageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(75 * scale);
        make.width.height.mas_equalTo(120 * scale);
        make.top.mas_equalTo(90 * scale);
    }];
    
    UILabel * snapLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentCenter];
    snapLabel.text = DDLocalizedString(@"Snap");
    [self.bottomView addSubview:snapLabel];
    [snapLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(snapImageview);
        make.left.mas_equalTo(snapImageview.mas_right).offset(12 * scale);
        make.height.mas_equalTo(60 * scale);
    }];
    snapLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer * snapTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(snapButtonDidClicked)];
    [snapLabel addGestureRecognizer:snapTap];
    
    self.upImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectMake((kMainBoundsWidth - 180 * scale) / 2.f, 0 * scale, 180 * scale, 60 * scale) contentModel:UIViewContentModeScaleAspectFit image:[UIImage imageNamed:@"upHome"]];
    [self.bottomView addSubview:self.upImageView];
    self.upImageView.userInteractionEnabled = YES;
//    UITapGestureRecognizer * uptap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(upImageViewDidClicked)];
//    [self.upImageView addGestureRecognizer:uptap];
//
//    [swipe1 requireGestureRecognizerToFail:uptap];
//    [swipe2 requireGestureRecognizerToFail:uptap];
    
    UIButton * upButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.upImageView addSubview:upButton];
    [upButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [upButton addTarget:self action:@selector(upImageViewDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * wodeListButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"DListTie")];
    [wodeListButton addTarget:self action:@selector(myButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.downView addSubview:wodeListButton];
    [wodeListButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0 * scale);
        make.width.mas_equalTo(kMainBoundsWidth / 3.f);
        make.bottom.mas_equalTo(0 * scale);
    }];
    UIView * wodeLinew = [[UIView alloc] initWithFrame:CGRectZero];
    wodeLinew.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [wodeListButton addSubview:wodeLinew];
    [wodeLinew mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(3 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    
    UIButton * guanzhuButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"InterestedListTie")];
    [guanzhuButton addTarget:self action:@selector(shoucangButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.downView addSubview:guanzhuButton];
    [guanzhuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wodeListButton.mas_right);
        make.top.mas_equalTo(0 * scale);
        make.width.mas_equalTo(kMainBoundsWidth / 3.f);
        make.bottom.mas_equalTo(0 * scale);
    }];
    UIView * guanzhuLinew = [[UIView alloc] initWithFrame:CGRectZero];
    guanzhuLinew.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [guanzhuButton addSubview:guanzhuLinew];
    [guanzhuLinew mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(3 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    
    UIButton * zujuListButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"AppointmentsListTie")];
    [zujuListButton addTarget:self action:@selector(wyyButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.downView addSubview:zujuListButton];
    [zujuListButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(guanzhuButton.mas_right);
        make.top.mas_equalTo(0 * scale);
        make.width.mas_equalTo(kMainBoundsWidth / 3.f);
        make.bottom.mas_equalTo(0 * scale);
    }];
    
    self.topAlertView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.topAlertView];
//    self.topAlertView.backgroundColor = [UIColorFromRGB(0x111111) colorWithAlphaComponent:.1f];
    [self.topAlertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + 60 + kStatusBarHeight) * scale);
        make.left.mas_equalTo(50 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.topAlertView];
    
    UIButton * timeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self.topAlertView addSubview:timeButton];
    [timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(24 * scale);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(300 * scale);
        make.height.mas_equalTo(98 * scale);
    }];
    [timeButton setBackgroundImage:[UIImage imageNamed:@"homeTimeBG"] forState:UIControlStateNormal];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentCenter];
    [timeButton addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20 * scale);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(200 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    self.timeLabel.text = [NSString stringWithFormat:@"%ld", self.year];
    
    [timeButton addTarget:self action:@selector(timeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.topAlertLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    [self.topAlertView addSubview:self.topAlertLabel];
    self.topAlertLabel.text = DDLocalizedString(@"All");
    [self.topAlertView addSubview:self.topAlertLabel];
    [self.topAlertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(timeButton.mas_right).offset(48 * scale);
        make.height.mas_equalTo(55 * scale);
        make.right.mas_equalTo(0);
    }];
    
    self.picIsUser = YES;
    self.picButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(60 * scale, kMainBoundsHeight - 480 * scale, 120 * scale, 120 * scale) font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self.picButton setImage:[UIImage imageNamed:@"homePicUser"] forState:UIControlStateNormal];
    [self.view addSubview:self.picButton];
    [self.picButton addTarget:self action:@selector(picButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.isShowNumber = NO;
    self.showNumerButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(60 * scale, kMainBoundsHeight - 650 * scale, 120 * scale, 120 * scale) font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self.showNumerButton setImage:[UIImage imageNamed:@"showNumberNO"] forState:UIControlStateNormal];
    [self.view addSubview:self.showNumerButton];
    [self.showNumerButton addTarget:self action:@selector(showNumerButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIView * groupView = [[UIView alloc] initWithFrame:CGRectZero];
    groupView.backgroundColor = UIColorFromRGB(0xDB6283);
    [DDViewFactoryTool cornerRadius:48 * scale withView:groupView];
    [self.view addSubview:groupView];
    [groupView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(timeButton);
        make.right.mas_equalTo(-50 * scale);
        make.left.mas_equalTo(timeButton.mas_right).offset(45 * scale);
        make.height.mas_equalTo(96 * scale);
    }];
    
    UIImageView * groupImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFit image:[UIImage imageNamed:@"groupName"]];
    [groupView addSubview:groupImageView];
    [groupImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.width.height.mas_equalTo(80 * scale);
        make.left.mas_equalTo(40 * scale);
    }];
    groupImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(groupImageViewDidTap)];
    [groupImageView addGestureRecognizer:tap1];
    
    UIView * lineView1 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView1.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [groupView addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(380 * scale);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(4 * scale);
        make.height.mas_equalTo(40 * scale);
    }];
    
    self.groupNameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentLeft];
    self.groupNameLabel.text = @"首页";
    [groupView addSubview:self.groupNameLabel];
    [self.groupNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(groupImageView.mas_right).offset(20 * scale);
        make.height.mas_equalTo(50 * scale);
        make.right.mas_equalTo(lineView1.mas_left).offset(-20 * scale);
    }];
    self.groupNameLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(groupImageViewDidTap)];
    [self.groupNameLabel addGestureRecognizer:tap2];
    
    UIButton * listButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"列表浏览"];
    [groupView addSubview:listButton];
    [listButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(lineView1.mas_right).offset(5 * scale);
        make.height.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-15 * scale);
    }];
    [listButton addTarget:self action:@selector(listButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)listButtonDidClicked
{
    DDGroupPostListViewController * list = [[DDGroupPostListViewController alloc] initWithModel:self.groupModel];
    [self.navigationController pushViewController:list animated:YES];
}

- (void)bottomDidSwipe:(UISwipeGestureRecognizer *)swipe
{
    switch (swipe.direction) {
        case UISwipeGestureRecognizerDirectionUp:
        {
            if (self.bottomIsOpen) {
                return;
            }
            
            CGFloat scale = kMainBoundsWidth / 1080.f;
//            self.downView.hidden = NO;
//            self.upImageView.frame = CGRectMake(0, 450 * scale, kMainBoundsWidth, 70 * scale);
            [self.upImageView setImage:[UIImage imageNamed:@"downHome"]];
            [UIView animateWithDuration:.2f animations:^{
                self.bottomView.frame = CGRectMake(0, kMainBoundsHeight - 384 * scale, kMainBoundsWidth, 384 * scale);
                self.backLocationButton.frame = CGRectMake(kMainBoundsWidth - 180 * scale, kMainBoundsHeight - 504 * scale, 120 * scale, 120 * scale);
                self.picButton.frame = CGRectMake(60 * scale, kMainBoundsHeight - 504 * scale, 120 * scale, 120 * scale);
                self.showNumerButton.frame = CGRectMake(60 * scale, kMainBoundsHeight - 674 * scale, 120 * scale, 120 * scale);
            }];
            self.bottomIsOpen = YES;
        }
            break;
            
        case UISwipeGestureRecognizerDirectionDown:
        {
            if (!self.bottomIsOpen) {
                return;
            }
            
            CGFloat scale = kMainBoundsWidth / 1080.f;
//            self.downView.hidden = YES;
//            self.upImageView.frame = CGRectMake(0, 250 * scale, kMainBoundsWidth, 70 * scale);
            [self.upImageView setImage:[UIImage imageNamed:@"upHome"]];
            [UIView animateWithDuration:.2f animations:^{
                self.bottomView.frame = CGRectMake(0, kMainBoundsHeight - 240 * scale, kMainBoundsWidth, 384 * scale);
                self.backLocationButton.frame = CGRectMake(kMainBoundsWidth - 180 * scale, kMainBoundsHeight - 360 * scale, 120 * scale, 120 * scale);
                self.picButton.frame = CGRectMake(60 * scale, kMainBoundsHeight - 360 * scale, 120 * scale, 120 * scale);
                self.showNumerButton.frame = CGRectMake(60 * scale, kMainBoundsHeight - 530 * scale, 120 * scale, 120 * scale);
            }];
            self.bottomIsOpen = NO;
        }
            break;
            
        default:
            break;
    }
}

- (void)upImageViewDidClicked
{
    if (self.bottomIsOpen) {
        CGFloat scale = kMainBoundsWidth / 1080.f;
//        self.downView.hidden = YES;
//        self.upImageView.frame = CGRectMake(0, 250 * scale, kMainBoundsWidth, 70 * scale);
        [self.upImageView setImage:[UIImage imageNamed:@"upHome"]];
        [UIView animateWithDuration:.2f animations:^{
            self.bottomView.frame = CGRectMake(0, kMainBoundsHeight - 240 * scale, kMainBoundsWidth, 384 * scale);
            self.backLocationButton.frame = CGRectMake(kMainBoundsWidth - 180 * scale, kMainBoundsHeight - 360 * scale, 120 * scale, 120 * scale);
            self.picButton.frame = CGRectMake(60 * scale, kMainBoundsHeight - 360 * scale, 120 * scale, 120 * scale);
            self.showNumerButton.frame = CGRectMake(60 * scale, kMainBoundsHeight - 530 * scale, 120 * scale, 120 * scale);
        }];
        self.bottomIsOpen = NO;
    }else{
        CGFloat scale = kMainBoundsWidth / 1080.f;
//        self.downView.hidden = NO;
//        self.upImageView.frame = CGRectMake(0, 450 * scale, kMainBoundsWidth, 70 * scale);
        [self.upImageView setImage:[UIImage imageNamed:@"downHome"]];
        [UIView animateWithDuration:.2f animations:^{
            self.bottomView.frame = CGRectMake(0, kMainBoundsHeight - 384 * scale, kMainBoundsWidth, 384 * scale);
            self.backLocationButton.frame = CGRectMake(kMainBoundsWidth - 180 * scale, kMainBoundsHeight - 504 * scale, 120 * scale, 120 * scale);
            self.picButton.frame = CGRectMake(60 * scale, kMainBoundsHeight - 504 * scale, 120 * scale, 120 * scale);
            self.showNumerButton.frame = CGRectMake(60 * scale, kMainBoundsHeight - 674 * scale, 120 * scale, 120 * scale);
        }];
        self.bottomIsOpen = YES;
    }
}

- (void)zujuButtonDidClicked
{
    self.addType = 2;
    [self addButtonDidClicked];
}

- (void)snapButtonDidClicked
{
    self.addType = 1;
    [self addButtonDidClicked];
}

- (void)snapLongButtonDidClicked
{
    self.addType = 3;
    [self addButtonDidClicked];
}

- (void)typeDidChooseComplete:(NSInteger)chooseTag
{
    if (self.isSearch) {
        [self topCloseButtonDidClicked];
    }
    
    [self resetSearch];
    
    if (chooseTag == 11) {
        self.sourceType = 7;
        self.logoBGName = @"touxiangkuang";
        self.logoBGColor = UIColorFromRGB(0xDB6283);
        self.topAlertLabel.text = DDLocalizedString(@"Friend");
        self.pindaoLabel.text = DDLocalizedString(@"Friend");
        [self.pindaoButton setImage:[UIImage imageNamed:@"HomePDHaoyou"] forState:UIControlStateNormal];
    }else if (chooseTag == 12) {
        self.sourceType = 8;
        self.logoBGName = @"touxiangkuangbozhu";
        self.logoBGColor = UIColorFromRGB(0xB721FF);
        self.topAlertLabel.text = DDLocalizedString(@"Blogger");
        self.pindaoLabel.text = DDLocalizedString(@"Blogger");
        [self.pindaoButton setImage:[UIImage imageNamed:@"HomePDBozhu"] forState:UIControlStateNormal];
    }else if (chooseTag == 13) {
        self.sourceType = 6;
        self.logoBGName = @"touxiangkuanghui";
        self.logoBGColor = UIColorFromRGB(0x999999);
        if (self.year == -1) {
            OnlyMapViewController * map = [_mapVCSource objectAtIndex:1];
            self.year = map.year;
            self.timeLabel.text = [NSString stringWithFormat:@"%ld年", self.year];
        }
        self.topAlertLabel.text = DDLocalizedString(@"Other");
        self.pindaoLabel.text = DDLocalizedString(@"Other");
        [self.pindaoButton setImage:[UIImage imageNamed:@"HomePDQita"] forState:UIControlStateNormal];
    }else if (chooseTag == 14) {
        self.sourceType = 10;
        self.logoBGName = @"touxiangkuang";
        self.logoBGColor = UIColorFromRGB(0xDB6283);
        self.topAlertLabel.text = DDLocalizedString(@"Reminder");
        self.pindaoLabel.text = DDLocalizedString(@"Reminder");
        [self.pindaoButton setImage:[UIImage imageNamed:@"HomePDTixing"] forState:UIControlStateNormal];
    }else if (chooseTag == 15) {
        self.sourceType = 1;
        self.logoBGName = @"touxiangkuang";
        self.logoBGColor = UIColorFromRGB(0xDB6283);
        self.topAlertLabel.text = DDLocalizedString(@"My");
        self.pindaoLabel.text = DDLocalizedString(@"My");
        [self.pindaoButton setImage:[UIImage imageNamed:@"HomePDWode"] forState:UIControlStateNormal];
    }else if (chooseTag == 16) {
        [self yuezheButtonDidClicked];
        self.pindaoLabel.text = DDLocalizedString(@"D");
        [self.pindaoButton setImage:[UIImage imageNamed:@"HomePDZuju"] forState:UIControlStateNormal];
        return;
    }else if (chooseTag == 17) {
        self.sourceType = 11;
        self.logoBGName = @"touxiangkuanghui";
        self.logoBGColor = UIColorFromRGB(0x999999);
        self.topAlertLabel.text = DDLocalizedString(@"All");
        self.pindaoLabel.text = DDLocalizedString(@"All");
        [self.pindaoButton setImage:[UIImage imageNamed:@"HomePDQuanbu"] forState:UIControlStateNormal];
    }
    
    self.searchButton.hidden = NO;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self requestMapViewLocations];
    [self updateUserLocation];
}

- (void)yuezheButtonDidClicked
{
    self.searchButton.hidden = YES;
    
    if (self.isSearch) {
        [self topCloseButtonDidClicked];
    }
    
    [self resetSearch];
    
    if (self.sourceType == 666) {
        return;
    }
    
    self.sourceType = 666;
//    self.selectButton.alpha = 1.f;
//    self.selectButton.enabled = YES;
    
    [self.yaoyueFriendSource removeAllObjects];
    self.topAlertLabel.text = DDLocalizedString(@"D");
    
    if (self.year == -1) {
        OnlyMapViewController * map = [_mapVCSource objectAtIndex:1];
        self.year = map.year;
        self.timeLabel.text = [NSString stringWithFormat:@"%ld年", self.year];
    }
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self requestMapViewLocations];
    [self updateUserLocation];
}

- (void)wyyButtonDidClicked
{
    DDGroupModel * model = [[DDGroupModel alloc] initWithMyWYY];
    DDGroupPostListViewController * list = [[DDGroupPostListViewController alloc] initWithModel:model];
    
    [self.navigationController pushViewController:list animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DDGroupDidChange" object:model];
}

- (void)typeButtonDidClicked
{
    DDGroupViewController * group = [[DDGroupViewController alloc] init];
    group.currentModel = self.groupModel;
    
    CATransition *transition = [CATransition animation];
    
    transition.duration = 0.35;
    
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    
    transition.type = kCATransitionPush;
    
    transition.subtype = kCATransitionFromTop;
    
    transition.delegate = self;
    
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    [self.navigationController pushViewController:group animated:NO];
}

- (void)shoucangButtonDidClicked
{
    DDGroupModel * model = [[DDGroupModel alloc] initWithMyCollect];
    DDGroupPostListViewController * list = [[DDGroupPostListViewController alloc] initWithModel:model];
    
    [self.navigationController pushViewController:list animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DDGroupDidChange" object:model];
}

- (void)myButtonDidClicked
{
    DDGroupModel * model = [[DDGroupModel alloc] initWithMy];
    DDGroupPostListViewController * list = [[DDGroupPostListViewController alloc] initWithModel:model];
    
    [self.navigationController pushViewController:list animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DDGroupDidChange" object:model];
}

- (void)picButtonDidClicked
{
    self.picIsUser = !self.picIsUser;
    
    NSArray * dataSource = self.mapView.annotations;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:dataSource];
    
    if (self.picIsUser) {
        [self.picButton setImage:[UIImage imageNamed:@"homePicUser"] forState:UIControlStateNormal];
    }else{
        [self.picButton setImage:[UIImage imageNamed:@"homePicPost"] forState:UIControlStateNormal];
    }
}

- (void)showNumerButtonDidClicked
{
    self.isShowNumber = !self.isShowNumber;
    
    NSArray * dataSource = self.mapView.annotations;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:dataSource];
    
    if (self.isShowNumber) {
        [self.showNumerButton setImage:[UIImage imageNamed:@"showNumberYES"] forState:UIControlStateNormal];
    }else{
        [self.showNumerButton setImage:[UIImage imageNamed:@"showNumberNO"] forState:UIControlStateNormal];
    }
}

- (void)addButtonDidClicked
{
    if (self.navigationController.topViewController != self || self.isPushing) {
        return;
    }
    
    self.isPushing = YES;
    
    if (self.addType == 1) {
        BMKReverseGeoCodeSearchOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeSearchOption alloc] init];
        reverseGeocodeSearchOption.location = self.mapView.centerCoordinate;
        [self.geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    }else{
        BMKReverseGeoCodeSearchOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeSearchOption alloc] init];
        reverseGeocodeSearchOption.location = [DDLocationManager shareManager].userLocation.location.coordinate;
        [self.geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    }
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (!self.isPushing) {
        
        if (error == BMK_SEARCH_NO_ERROR) {
            if (!isEmptyString(result.addressDetail.city)) {
                [self.locationButton setTitle:result.addressDetail.city forState:UIControlStateNormal];
            }
        }
        return;
        
    }
    
    if (self.addType == 1) {
        
        BMKPoiInfo * poi = [[BMKPoiInfo alloc] init];
        poi.pt = result.location;
        poi.address = result.sematicDescription;
        poi.name = result.address;
        
        [self createPostWithPOI:poi];
        
    }else if (self.addType == 2) {
        
        BMKPoiInfo * poi = [[BMKPoiInfo alloc] init];
        if (result) {
            if (result.poiList.count > 0) {
                poi = result.poiList.firstObject;
            }else{
                NSString * address = result.address;
                if (isEmptyString(address)) {
                    address = result.sematicDescription;
                }
                
                poi.pt = result.location;
                poi.address = result.sematicDescription;
                poi.name = address;
            }
        }
        
        YueFanViewController * yuefan = [[YueFanViewController alloc] initWithBMKPoiInfo:nil friendArray:[NSArray new]];
        [self.navigationController pushViewController:yuefan animated:YES];
    }else{
        
        BMKPoiInfo * poi = [[BMKPoiInfo alloc] init];
        if (result) {
            if (result.poiList.count > 0) {
                poi = result.poiList.firstObject;
            }else{
                NSString * address = result.address;
                if (isEmptyString(address)) {
                    address = result.sematicDescription;
                }
                
                poi.pt = result.location;
                poi.address = result.sematicDescription;
                poi.name = address;
            }
        }
        
        DTieNewEditViewController * edit = [[DTieNewEditViewController alloc] init];
        [edit configWith:poi];
        [self.navigationController pushViewController:edit animated:YES];
    }
    self.isPushing = NO;
}

- (void)createPostWithPOI:(BMKPoiInfo *)poi
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:self.view];
    
    //获取参数配置
    NSString * address = poi.address;
    
    NSString * building = poi.name;
    if (isEmptyString(building)) {
        building = address;
    }
    
    double lon = poi.pt.longitude;
    double lat = poi.pt.latitude;
    
    NSInteger landAccountFlg = 0;
    
    NSMutableArray * allowToSeeList = [[NSMutableArray alloc] init];
    
    NSString * title = @"";
    
    NSInteger createTime = [[NSDate date] timeIntervalSince1970] * 1000;
    
    CreateDTieRequest * request = [[CreateDTieRequest alloc] initWithList:[NSArray new] title:title address:address building:building addressLng:lon addressLat:lat status:1 remindFlg:1 firstPic:@"" postID:0 landAccountFlg:landAccountFlg allowToSeeList:allowToSeeList sceneTime:createTime];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                //                    [MBProgressHUD showTextHUDWithText:@"操作成功" inView:self.view];
                DTieModel * DTie = [DTieModel mj_objectWithKeyValues:data];
                
                NSInteger newPostID = DTie.cid;
                if (newPostID == 0) {
                    newPostID = DTie.postId;
                }
                [self showPostDetailWithPostId:newPostID];
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"操作失败" inView:self.view];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"操作失败" inView:self.view];
    }];
}

- (void)showPostDetailWithPostId:(NSInteger)postId;
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:[UIApplication sharedApplication].keyWindow];
    
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:postId type:4 start:0 length:10];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                
                DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initWithDTie:dtieModel];
                detail.isRemark = YES;
                
                [self.navigationController pushViewController:detail animated:YES];
            }
        }
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
    }];
}

- (void)selectButtonDidClicked
{
    [self endTextFieldEdit];
    if (self.friendSource.count == 0) {
        [MBProgressHUD showTextHUDWithText:@"暂时没有找到您的朋友哦~" inView:self.view];
        return;
    }
    
    [self.yaoyueSelectView show];
}

- (void)showTipWithText:(NSString *)text
{
    self.tipView.alpha = 0;
    
    self.tipLabel.text = text;
    [UIView animateWithDuration:.3f animations:^{
        self.tipView.alpha = 1;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.tipView.alpha = 0;
        });
    }];
}

- (void)backLocationButtonDidClicked
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake([DDLocationManager shareManager].userLocation.location.coordinate, BMKCoordinateSpanMake(.017, .017));
        BMKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
        [self.mapView setRegion:adjustedRegion animated:YES];
    }else{
        [MBProgressHUD showTextHUDWithText:@"未打开定位，请前往“手机设置”允许应用定位" inView:self.view];
    }
    
    self.isFirst = NO;
}

- (void)updateUserLocation
{
    [self.mapView updateLocationData:[DDLocationManager shareManager].userLocation];
    
    CLLocationCoordinate2D coors = [DDLocationManager shareManager].userLocation.location.coordinate;
    if (self.circle) {
        [self.mapView removeOverlay:self.circle];
    }
    self.circle = [BMKCircle circleWithCenterCoordinate:coors radius:[DDLocationManager shareManager].distance];
    
    [self.mapView addOverlay:self.circle];
    
    if (self.isFirst) {
        BMKCoordinateRegion viewRegion;
        
        NSInteger count = [DDUserDefaultsGet(@"AppMapLoadCount") integerValue];
        if (count <= 3) {
            viewRegion = BMKCoordinateRegionMake([DDLocationManager shareManager].userLocation.location.coordinate, BMKCoordinateSpanMake(0, 60));
            count++;
            DDUserDefaultsSet(@"AppMapLoadCount", @(count));
        }else{
            viewRegion = BMKCoordinateRegionMake([DDLocationManager shareManager].userLocation.location.coordinate, BMKCoordinateSpanMake(.017, .017));
        }
        
        [self.mapView setRegion:viewRegion animated:YES];
        if (viewRegion.center.latitude == 0 && viewRegion.center.longitude == 0) {
            self.isFirst = YES;
        }else{
            self.isFirst = NO;
        }
    }
}

//正常请求
- (void)requestMapViewLocations
{
    [DTieSearchRequest cancelRequest];
    [SelectMapYaoyueRequest cancelRequest];
    
    CGFloat centerLongitude = self.mapView.region.center.longitude;
    CGFloat centerLatitude = self.mapView.region.center.latitude;
    
    //当前屏幕显示范围的经纬度
    CLLocationDegrees pointssLongitudeDelta = self.mapView.region.span.longitudeDelta;
    CLLocationDegrees pointssLatitudeDelta = self.mapView.region.span.latitudeDelta;
    //左上角
    CGFloat leftUpLong = centerLongitude - pointssLongitudeDelta/2.0;
    CGFloat leftUpLati = centerLatitude - pointssLatitudeDelta/2.0;
    //右下角
    CGFloat rightDownLong = centerLongitude + pointssLongitudeDelta/2.0;
    CGFloat rightDownLati = centerLatitude + pointssLatitudeDelta/2.0;
    
    self.isNotification = NO;
    if (self.sourceType == 666) {
        
        NSMutableArray * friendList = [[NSMutableArray alloc] init];
        for (UserModel * model in self.yaoyueFriendSource) {
            [friendList addObject:@(model.cid)];
        }
        
        SelectMapYaoyueRequest * request = [[SelectMapYaoyueRequest alloc] initWithFriendList:friendList lat1:leftUpLati lng1:leftUpLong lat2:rightDownLati lng2:rightDownLong];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            if (KIsDictionary(response)) {
                NSArray * data = [response objectForKey:@"data"];
                if (KIsArray(data)) {
                    [self.mapView removeAnnotations:self.mapView.annotations];
                    [self.yaoyueMapSource removeAllObjects];
                    NSMutableArray * tempPointArray = [[NSMutableArray alloc] init];
                    for (NSDictionary * dict in data) {
                        DTieMapYaoyueModel * model = [DTieMapYaoyueModel mj_objectWithKeyValues:dict];
                        [self.yaoyueMapSource addObject:model];
                        
                        BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc] init];
                        annotation.coordinate = CLLocationCoordinate2DMake(model.sceneAddressLat, model.sceneAddressLng);
                        [tempPointArray addObject:annotation];
                    }
                    [self.mapView addAnnotations:tempPointArray];
                }
            }
            
            if (self.isMotion) {
                [MBProgressHUD showTextHUDWithText:@"刷新成功" inView:self.view];
                self.isMotion = NO;
            }
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            self.isMotion = NO;
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
            self.isMotion = NO;
            
        }];
        
    }else{
        
        double startDate;
        double endDate;
        if (self.year == -1) {
            startDate = 0.f;
            endDate = [DDTool getTimeCurrentWithDouble];
        }else{
            startDate = [DDTool DDGetDoubleWithYear:self.year mouth:0 day:0];
            endDate = [DDTool DDGetDoubleWithYear:self.year+1 mouth:0 day:0];
        }
        
        if (self.sourceType == 10) {
            self.isNotification = YES;
        }
        
        NSInteger dataSourceType = 12;
        if (self.groupModel.cid == -1) {
            dataSourceType = 1;
        }else if (self.groupModel.cid == -2) {
            dataSourceType = 6;
        }else if (self.groupModel.cid == -4) {
            dataSourceType = 9;
        }else if (self.groupModel.cid == -5) {
            dataSourceType = 14;
        }else if (self.groupModel.cid == -6) {
            dataSourceType = 15;
        }
        
        DTieSearchRequest * request = [[DTieSearchRequest alloc] initWithKeyWord:@"" lat1:leftUpLati lng1:leftUpLong lat2:rightDownLati lng2:rightDownLong startDate:startDate endDate:endDate sortType:2 dataSources:dataSourceType type:1 pageStart:0 pageSize:5000];
        if (dataSourceType == 12) {
            [request configGroupID:self.groupModel.cid];
        }
        
        if (self.yaoyueFriendSource && self.yaoyueFriendSource.count > 0) {
            NSMutableArray * authorID = [[NSMutableArray alloc] init];
            for (UserModel * model in self.yaoyueFriendSource) {
                [authorID addObject:@(model.cid)];
            }
            [request configWithAuthorID:authorID];
        }
        
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            if (KIsDictionary(response)) {
                NSArray * data = [response objectForKey:@"data"];
                if (KIsArray(data)) {
                    [self.mapView removeAnnotations:self.mapView.annotations];
                    [self.mapSource removeAllObjects];
                    
                    NSMutableArray * tempPointArray = [[NSMutableArray alloc] init];
                    NSMutableArray * tempMapArray = [[NSMutableArray alloc] init];
                    
                    for (NSDictionary * dict in data) {
                        DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                        [tempMapArray addObject:model];
                        
                        BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc] init];
                        annotation.coordinate = CLLocationCoordinate2DMake(model.sceneAddressLat, model.sceneAddressLng);
                        [tempPointArray addObject:annotation];
                    }
                    [self.mapSource addObjectsFromArray:[[tempMapArray reverseObjectEnumerator] allObjects]];
                    [self.mapView addAnnotations:[[tempPointArray reverseObjectEnumerator] allObjects]];
                }
            }
            
            if (self.isMotion) {
                [MBProgressHUD showTextHUDWithText:@"刷新成功" inView:self.view];
                self.isMotion = NO;
            }
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            self.isMotion = NO;
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
            self.isMotion = NO;
            
        }];
    }
}

//点击搜索请求
- (void)searchMapViewLocations
{
    [DTieSearchRequest cancelRequest];
    
    self.isNotification = NO;
    
    CGFloat centerLongitude = self.mapView.region.center.longitude;
    CGFloat centerLatitude = self.mapView.region.center.latitude;
    
    //当前屏幕显示范围的经纬度
    CLLocationDegrees pointssLongitudeDelta = self.mapView.region.span.longitudeDelta;
    CLLocationDegrees pointssLatitudeDelta = self.mapView.region.span.latitudeDelta;
    //左上角
    CGFloat leftUpLong = centerLongitude - pointssLongitudeDelta/2.0;
    CGFloat leftUpLati = centerLatitude - pointssLatitudeDelta/2.0;
    //右下角
    CGFloat rightDownLong = centerLongitude + pointssLongitudeDelta/2.0;
    CGFloat rightDownLati = centerLatitude + pointssLatitudeDelta/2.0;
    [self.mapView convertPoint:CGPointZero toCoordinateFromView:self.mapView];
    
    double startDate = self.minTime;
    double endDate = self.maxTime;
    if (self.maxTime == 0) {
        if (self.year == -1) {
            startDate = 0.f;
            endDate = [DDTool getTimeCurrentWithDouble];
        }else{
            startDate = [DDTool DDGetDoubleWithYear:self.year mouth:0 day:0];
            endDate = [DDTool DDGetDoubleWithYear:self.year+1 mouth:0 day:0];
        }
    }
    
    NSInteger type = self.searchType;
    if (type == 0) {
        type = self.sourceType;
    }
    
    if (type == 10) {
        self.isNotification = YES;
    }
    
    NSString * keyWord = @"";
    if (!isEmptyString(self.textField.text)) {
        keyWord = self.textField.text;
    }
    
    DTieSearchRequest * request = [[DTieSearchRequest alloc] initWithKeyWord:keyWord lat1:leftUpLati lng1:leftUpLong lat2:rightDownLati lng2:rightDownLong startDate:startDate endDate:endDate sortType:2 dataSources:type type:1 pageStart:0 pageSize:1000];
    
//    if (self.yaoyueFriendSource && self.yaoyueFriendSource.count > 0) {
//        NSMutableArray * authorID = [[NSMutableArray alloc] init];
//        for (UserModel * model in self.yaoyueFriendSource) {
//            [authorID addObject:@(model.cid)];
//        }
//        [request configWithAuthorID:authorID];
//    }
    
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.mapView removeAnnotations:self.mapView.annotations];
                [self.mapSource removeAllObjects];
                
                NSMutableArray * tempPointArray = [[NSMutableArray alloc] init];
                NSMutableArray * tempMapArray = [[NSMutableArray alloc] init];
                
                for (NSDictionary * dict in data) {
                    DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                    [tempMapArray addObject:model];
                    
                    BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc] init];
                    annotation.coordinate = CLLocationCoordinate2DMake(model.sceneAddressLat, model.sceneAddressLng);
                    [tempPointArray addObject:annotation];
                }
                [self.mapSource addObjectsFromArray:[[tempMapArray reverseObjectEnumerator] allObjects]];
                [self.mapView addAnnotations:[[tempPointArray reverseObjectEnumerator] allObjects]];
            }
        }
        
        if (self.isMotion) {
            [MBProgressHUD showTextHUDWithText:@"刷新成功" inView:self.view];
            self.isMotion = NO;
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        self.isMotion = NO;
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        self.isMotion = NO;
        
    }];
}

- (void)meterDistance
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        BMKPointAnnotation * resultPoint;
        CLLocationDistance mostMeters = 0;
        BMKMapPoint userPoint = BMKMapPointForCoordinate([DDLocationManager shareManager].userLocation.location.coordinate);
        
        for (BMKPointAnnotation * annotation in self.mapView.annotations) {
            BMKMapPoint point = BMKMapPointForCoordinate(annotation.coordinate);
            
            CLLocationDistance distance = BMKMetersBetweenMapPoints(userPoint, point);
            if (distance > mostMeters) {
                mostMeters = distance;
                resultPoint = annotation;
            }
        }
        
        CLLocationDegrees lng = fabs([DDLocationManager shareManager].userLocation.location.coordinate.longitude - resultPoint.coordinate.longitude);
        CLLocationDegrees lat = fabs([DDLocationManager shareManager].userLocation.location.coordinate.latitude - resultPoint.coordinate.latitude);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake([DDLocationManager shareManager].userLocation.location.coordinate, BMKCoordinateSpanMake(lat * 2.3, lng * 2.3));
            BMKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
            [self.mapView setRegion:adjustedRegion animated:YES];
        });
        
    });
}

- (void)DTieFoundEditViewBeginEidt:(DTieFoundEditView *)view
{
    
    NSString * location = @"";
    if (!isEmptyString(view.locationLabel.text)) {
        location = [view.locationLabel.text componentsSeparatedByString:@"\n"].lastObject;
    }
    
    DTieModel * model = [[DTieModel alloc] init];
    model.postSummary = view.titleTextField.text;
    model.sceneAddress = location;
    model.sceneAddressLat = self.markCoordinate.latitude;
    model.sceneAddressLng = self.markCoordinate.longitude;
    
    DTieNewEditViewController * edit = [[DTieNewEditViewController alloc] initWithDtieModel:model];
    [view removeFromSuperview];
    [self.navigationController pushViewController:edit animated:YES];
}

#pragma mark - BMKMapViewDelegate
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.isSearch) {
        [self searchMapViewLocations];
    }else{
        [self requestMapViewLocations];
    }
    
    BMKReverseGeoCodeSearchOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeSearchOption alloc] init];
    reverseGeocodeSearchOption.location = self.mapView.centerCoordinate;
    [self.geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
}

//- (void)mapview:(BMKMapView *)mapView onLongClick:(CLLocationCoordinate2D)coordinate
//{
//    self.markCoordinate = coordinate;
//    DTieFoundEditView * edit = [[DTieFoundEditView alloc] initWithFrame:CGRectZero coordinate:coordinate];
//    [self.view addSubview:edit];
//    [edit mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(0);
//    }];
//    edit.delegate = self;
//}

- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKCircle class]])
    {
        BMKCircleView* circleView = [[BMKCircleView alloc] initWithOverlay:overlay];
        circleView.fillColor = [self.logoBGColor colorWithAlphaComponent:0.15];
        circleView.strokeColor = [self.logoBGColor colorWithAlphaComponent:0.4];
        circleView.lineWidth = .5f;
        return circleView;
    }
    return nil;
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    if (self.sourceType == 666) {
        
        BMKAnnotationView * yaoyueView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BMKAnnotationViewYue"];
        yaoyueView.annotation = annotation;
        
        yaoyueView.image = [UIImage imageNamed:@"mapyueguo"];
        yaoyueView.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:[UIView new]];
        
        NSInteger index = [self.mapView.annotations indexOfObject:annotation];
        DTieMapYaoyueModel * yaoyueModel = [self.yaoyueMapSource objectAtIndex:index];
        
        if ([yaoyueView viewWithTag:888]) {
            UILabel * label = (UILabel *)[yaoyueView viewWithTag:888];
            
            NSString * title = @"";
            if (yaoyueModel.count == 0) {
                title = @"0";
            }else if (yaoyueModel.count < 100) {
                title = [NSString stringWithFormat:@"%ld", yaoyueModel.count];
            }else{
                title = @"99+";
            }
            
            label.text = title;
        }else{
            CGFloat scale = kMainBoundsWidth / 1080.f;
            
            CGFloat width = yaoyueView.frame.size.width;
            CGFloat height = yaoyueView.frame.size.height;
            CGFloat logoWidth = width * 47.5f / 52.f;
            CGFloat originX = (width - logoWidth) / 2;
            CGFloat originY = height * .63f;
            
            UILabel * label = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentCenter];
            label.frame = CGRectMake(originX, originY, logoWidth, 50 * scale);
            [yaoyueView addSubview:label];
            
            NSString * title = @"";
            if (yaoyueModel.count == 0) {
                title = @"0";
            }else if (yaoyueModel.count < 100) {
                title = [NSString stringWithFormat:@"%ld", yaoyueModel.count];
            }else{
                title = @"99+";
            }
            
            label.text = title;
            
        }
        
        if ([yaoyueView viewWithTag:999]) {
            UIImageView * imageView = (UIImageView *)[yaoyueView viewWithTag:888];
            if (self.picIsUser) {
                [imageView sd_setImageWithURL:[NSURL URLWithString:yaoyueModel.userPortrait]];
            }else{
                [imageView sd_setImageWithURL:[NSURL URLWithString:yaoyueModel.firstPicture]];
            }
        }else{
            
            CGFloat width = yaoyueView.frame.size.width;
            CGFloat height = yaoyueView.frame.size.height;
            CGFloat logoWidth = width * 4.f / 5.f;
            CGFloat originX = (width - logoWidth) / 2;
            CGFloat originY = height * .09f;
            
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(originX, originY, logoWidth, logoWidth)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.tag = 999;
            [yaoyueView addSubview:imageView];
            [DDViewFactoryTool cornerRadius:logoWidth / 2 withView:imageView];
            if (self.picIsUser) {
                [imageView sd_setImageWithURL:[NSURL URLWithString:yaoyueModel.userPortrait]];
            }else{
                [imageView sd_setImageWithURL:[NSURL URLWithString:yaoyueModel.firstPicture]];
            }
        }
        
        return yaoyueView;
        
    }else if (self.sourceType == 8) {
        
        NSInteger index = [self.mapView.annotations indexOfObject:annotation];
        DTieModel * model = [self.mapSource objectAtIndex:index];
        
        BMKAnnotationView * view = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BMKAnnotationView"];
        view.annotation = annotation;
        if (model.source == 1) {
            view.image = [UIImage imageNamed:@"bozhuGongzhong"];
        }else if (model.concernFlg == 1) {
            view.image = [UIImage imageNamed:@"bozhuGuanzhu"];
        }else{
            view.image = [UIImage imageNamed:@"bozhuDefault"];
        }
        view.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:[UIView new]];
        
        if ([view viewWithTag:888]) {
            UIImageView * imageView = (UIImageView *)[view viewWithTag:888];
            if (self.picIsUser) {
                [imageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
            }else{
                [imageView sd_setImageWithURL:[NSURL URLWithString:model.postFirstPicture]];
            }
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
                
                logoWidth = width * .73f;
                originX = width * .13f;
                originY = width * .11f;
                
            }
            
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(originX, originY, logoWidth, logoWidth)];
            
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.tag = 888;
            [view addSubview:imageView];
            [DDViewFactoryTool cornerRadius:logoWidth / 2 withView:imageView];
            if (self.picIsUser) {
                [imageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
            }else{
                [imageView sd_setImageWithURL:[NSURL URLWithString:model.postFirstPicture]];
            }
        }
        
        return view;
        
    }
    
    BMKAnnotationView * view = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BMKAnnotationView"];
    view.annotation = annotation;
    view.image = [UIImage imageNamed:self.logoBGName];
    view.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:[UIView new]];
    
    NSInteger index = [self.mapView.annotations indexOfObject:annotation];
    
    if (self.mapSource.count == 0) {
        return view;
    }
    
    DTieModel * model = [self.mapSource objectAtIndex:index];
    
    if ([view viewWithTag:888]) {
        UIImageView * imageView = (UIImageView *)[view viewWithTag:888];
        if (self.picIsUser) {
            [imageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
        }else{
            [imageView sd_setImageWithURL:[NSURL URLWithString:model.postFirstPicture]];
        }
        
        
        UILabel * numberLabel = (UILabel *)[view viewWithTag:999];
        if (self.isShowNumber && model.commonCollectionCount > 0) {
            if (model.commonCollectionCount > 99) {
                
                numberLabel.hidden = NO;
                numberLabel.text = @"99";
                
            }else if (model.commonCollectionCount > 1) {
                numberLabel.hidden = NO;
                numberLabel.text = [NSString stringWithFormat:@"%ld", model.commonCollectionCount];
            }else{
                numberLabel.hidden = YES;
            }
        }else{
            numberLabel.hidden = YES;
        }
        
    }else{
        
        CGFloat width = view.frame.size.width;
        CGFloat logoWidth = width * 47.5f / 52.f;
        CGFloat origin = (width - logoWidth) / 2;
        CGFloat labelWidth = logoWidth / 2.5f;
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(origin, origin, logoWidth, logoWidth)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.tag = 888;
        [view addSubview:imageView];
        [DDViewFactoryTool cornerRadius:logoWidth / 2 withView:imageView];
        if (self.picIsUser) {
            [imageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
        }else{
            [imageView sd_setImageWithURL:[NSURL URLWithString:model.postFirstPicture]];
        }
        
        UILabel * numberLabel = [DDViewFactoryTool createLabelWithFrame:CGRectMake(origin+logoWidth-labelWidth/2.f, origin, labelWidth, labelWidth) font:kPingFangRegular(labelWidth/2.f) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentCenter];
        numberLabel.tag = 999;
        numberLabel.backgroundColor = UIColorFromRGB(0xDB6283);
        [DDViewFactoryTool cornerRadius:labelWidth/2.f withView:numberLabel];
        [view addSubview:numberLabel];
        if (self.isShowNumber && model.commonCollectionCount > 0) {
            if (model.commonCollectionCount > 99) {
                
                numberLabel.hidden = NO;
                numberLabel.text = @"99";
                
            }else if (model.commonCollectionCount > 1) {
                numberLabel.hidden = NO;
                numberLabel.text = [NSString stringWithFormat:@"%ld", model.commonCollectionCount];
            }else{
                numberLabel.hidden = YES;
            }
        }else{
            numberLabel.hidden = YES;
        }
    }
    
    return view;
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    [mapView deselectAnnotation:view.annotation animated:YES];
    
    if (self.sourceType == 666) {
        if ([self.mapView.annotations containsObject:view.annotation]) {
            NSInteger index = [self.mapView.annotations indexOfObject:view.annotation];
            
            DTieMapYaoyueModel * model = [self.yaoyueMapSource objectAtIndex:index];
            
            DTieModel * tieModel = [[DTieModel alloc] init];
            tieModel.cid = model.postId;
            tieModel.postId = model.postId;
            tieModel.authorId = model.authorId;
            tieModel.type = model.type;
            tieModel.subType = model.subType;
            tieModel.sceneBuilding = model.sceneBuilding;
            tieModel.sceneAddress = model.sceneAddress;
            tieModel.sceneAddressLat = model.sceneAddressLat;
            tieModel.sceneAddressLng = model.sceneAddressLng;
            tieModel.postFirstPicture = model.firstPicture;
            tieModel.portraituri = model.userPortrait;
            tieModel.createTime = model.createTime;
            tieModel.sceneTime = model.createTime;
            
            NSArray * tempArray = [[self.mapSource reverseObjectEnumerator] allObjects];
            index = [tempArray indexOfObject:tieModel];
            
            MapShowPostView * view = [[MapShowPostView alloc] initWithModel:tieModel source:tempArray index:index groupModel:self.groupModel];
            
            __weak typeof(self) weakSelf = self;
            view.uploadHandle = ^(DTieModel *dtieModel) {
                [weakSelf uploadPhoto:dtieModel];
            };
            
            [view show];
            
//            MapShowYaoyueView * yaoyue = [[MapShowYaoyueView alloc] initWithModel:model];
//            [yaoyue show];
        }
    }else if (self.isNotification) {
        
        if ([self.mapView.annotations containsObject:view.annotation]) {
            NSInteger index = [self.mapView.annotations indexOfObject:view.annotation];
            
            DTieModel * model = [self.mapSource objectAtIndex:index];
            MapShowNotificationView * view = [[MapShowNotificationView alloc] initWithModel:model];
            [view show];
//            NSInteger notificationID = [model.remark integerValue];
            
//            DDNotificationViewController * vc = [[DDNotificationViewController alloc] initWithNotificationID:notificationID];
//            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }else{
        if ([self.mapView.annotations containsObject:view.annotation]) {
            NSInteger index = [self.mapView.annotations indexOfObject:view.annotation];
            
            DTieModel * model = [self.mapSource objectAtIndex:index];
            NSArray * tempArray = [[self.mapSource reverseObjectEnumerator] allObjects];
            index = [tempArray indexOfObject:model];
            
            MapShowPostView * view = [[MapShowPostView alloc] initWithModel:model source:tempArray index:index groupModel:self.groupModel];
            
            __weak typeof(self) weakSelf = self;
            view.uploadHandle = ^(DTieModel *dtieModel) {
                [weakSelf uploadPhoto:dtieModel];
            };
            
            [view show];
//            
//            DDCollectionViewController * vc = [[DDCollectionViewController alloc] initWithDataSource:tempArray index:index];
//            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)uploadPhoto:(DTieModel *)model
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:[UIApplication sharedApplication].keyWindow];
    
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:model.cid type:4 start:0 length:10];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        
        if (KIsDictionary(response)) {
            
            NSInteger code = [[response objectForKey:@"status"] integerValue];
            if (code == 4002) {
                [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"PageHasDelete") inView:[UIApplication sharedApplication].keyWindow];
                
                return;
            }
            
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                
                self.uploadModel = [DTieModel mj_objectWithKeyValues:data];
                
                TZImagePickerController * picker = [[TZImagePickerController alloc] initWithMaxImagesCount:100 delegate:self];
                picker.allowPickingOriginalPhoto = NO;
                picker.allowPickingVideo = NO;
                picker.showSelectedIndex = YES;
                picker.allowCrop = NO;
                
                [self presentViewController:picker animated:YES completion:nil];
                
            }else{
                NSString * msg = [response objectForKey:@"msg"];
                if (!isEmptyString(msg)) {
                    [MBProgressHUD showTextHUDWithText:msg inView:[UIApplication sharedApplication].keyWindow];
                }
            }
        }
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
    }];
}

#pragma mark - 选取照片
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos
{
    NSMutableArray * details = [[NSMutableArray alloc] init];
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在上传" inView:[UIApplication sharedApplication].keyWindow];
    QNDDUploadManager * manager = [[QNDDUploadManager alloc] init];
    
    __block NSInteger count = 0;
    NSInteger totalCount = photos.count+self.uploadModel.details.count;
    for (NSInteger i = self.uploadModel.details.count; i < totalCount; i++) {
        
        UIImage * image = [photos objectAtIndex:i-self.uploadModel.details.count];
        
        [manager uploadImage:image progress:^(NSString *key, float percent) {
            
        } success:^(NSString *url) {
            
            NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                    @"datadictionaryType":@"CONTENT_IMG",
                                    @"detailsContent":url,
                                    @"textInformation":@"",
                                    @"pFlag":@(0),
                                    @"wxCansee":@(1),
                                    @"authorID":@([UserManager shareManager].user.cid)
                                    };
            [details addObject:dict];
            count++;
            if (count == photos.count) {
                [hud hideAnimated:YES];
                [self uploadWithPhotos:details];
            }
            
        } failed:^(NSError *error) {
            if (count == photos.count) {
                [hud hideAnimated:YES];
                [self uploadWithPhotos:details];
            }
        }];
    }
}

- (void)uploadWithPhotos:(NSMutableArray *)details
{
    [details sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSInteger detailNumber1 = [[obj1 objectForKey:@"detailNumber"] integerValue];
        NSInteger detailNumber2 = [[obj2 objectForKey:@"detailNumber"] integerValue];
        if (detailNumber1 > detailNumber2) {
            return NSOrderedDescending;
        }else if (detailNumber1 < detailNumber2) {
            return NSOrderedAscending;
        }else{
            return NSOrderedSame;
        }
    }];
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在添加照片" inView:[UIApplication sharedApplication].keyWindow];
    
    CreateDTieRequest * request = [[CreateDTieRequest alloc] initAddWithPostID:self.uploadModel.cid blocks:details];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"上传成功" inView:[UIApplication sharedApplication].keyWindow];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"上传失败" inView:[UIApplication sharedApplication].keyWindow];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"上传失败" inView:[UIApplication sharedApplication].keyWindow];
    }];
}

- (void)creatTopView
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
    
    UIButton * logoButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(60 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [logoButton setImage:[UIImage imageNamed:@"gerenzhongxin"] forState:UIControlStateNormal];
    [self.topView addSubview:logoButton];
    [logoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(50 * scale);
        make.height.mas_equalTo(110 * scale);
        make.width.mas_equalTo(110 * scale);
        make.bottom.mas_equalTo(-20 * scale);
    }];
    [logoButton addTarget:self action:@selector(mineButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.locationButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"正在获取位置"];
    
    [self.locationButton setImage:[UIImage imageNamed:@"homeLocation"] forState:UIControlStateNormal];
    [self.topView addSubview:self.locationButton];
    [self.locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0 * scale);
        make.height.mas_equalTo(72 * scale);
        make.centerY.mas_equalTo(logoButton);
    }];
    
    UIButton * shareButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [shareButton setImage:[UIImage imageNamed:@"shareMult"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:shareButton];
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-40 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    self.searchButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [self.searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [self.searchButton addTarget:self action:@selector(searchButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.searchButton];
    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(shareButton.mas_left).offset(-20 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
//    self.sourceButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
//    [self.sourceButton setImage:[UIImage imageNamed:@"source"] forState:UIControlStateNormal];
//    [self.sourceButton addTarget:self action:@selector(sourceButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.topView addSubview:self.sourceButton];
//    [self.sourceButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-40 * scale);
//        make.bottom.mas_equalTo(-20 * scale);
//        make.width.height.mas_equalTo(100 * scale);
//    }];
//
//    self.timeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
//    [self.timeButton setImage:[UIImage imageNamed:@"time"] forState:UIControlStateNormal];
//    [self.timeButton addTarget:self action:@selector(timeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.topView addSubview:self.timeButton];
//    [self.timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(self.sourceButton.mas_left).offset(-30 * scale);
//        make.bottom.mas_equalTo(-20 * scale);
//        make.width.height.mas_equalTo(100 * scale);
//    }];
    
    [self createSearchTopView];
}

- (void)shareButtonDidClicked
{
    [[DDShareManager shareManager] showShareList];
//    CGFloat scale = kMainBoundsWidth / 1080.f;
//
//    UIView * shareView = [[UIView alloc] initWithFrame:CGRectZero];
//    shareView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
//    [self.view addSubview:shareView];
//    [shareView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(0);
//    }];
//
//    CGFloat height = kMainBoundsWidth / 4.f;
//    if (KIsiPhoneX) {
//        height += 38.f;
//    }
//    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.backgroundColor = [UIColor whiteColor];
//    [button addTarget:self action:@selector(bottomButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [shareView addSubview:button];
//    [button mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.mas_equalTo(0);
//        make.height.mas_equalTo(height);
//        make.bottom.mas_equalTo(0);
//    }];
//
//    UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"homeTP"]];
//    [button addSubview:imageView];
//    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(0);
//        make.top.mas_equalTo(50 * scale);
//        make.width.height.mas_equalTo(96 * scale);
//    }];
//
//    UILabel * label = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentCenter];
//    label.text = DDLocalizedString(@"Share Basket");
//    [button addSubview:label];
//    [label mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.mas_equalTo(0);
//        make.height.mas_equalTo(45 * scale);
//        make.top.mas_equalTo(imageView.mas_bottom).offset(20 * scale);
//    }];
//
//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:shareView action:@selector(removeFromSuperview)];
//    [shareView addGestureRecognizer:tap];
}

- (void)bottomButtonDidClicked:(UIButton *)button
{
    [button.superview removeFromSuperview];
    [[DDShareManager shareManager] showShareList];
}

- (void)searchButtonDidClicked
{
//    self.searchTopView.hidden = NO;
//    self.isSearch = YES;
    DDFoundSearchListController * search = [[DDFoundSearchListController alloc] initWithModel:self.groupModel];
    [self.navigationController pushViewController:search animated:YES];
}

- (void)createSearchTopView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.searchTopView = [[UIView alloc] init];
    self.searchTopView.userInteractionEnabled = YES;
    [self.view addSubview:self.searchTopView];
    [self.searchTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo((364 + kStatusBarHeight) * scale);
    }];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, (364 + kStatusBarHeight) * scale);
    [self.searchTopView.layer addSublayer:gradientLayer];
    
    self.searchTopView.layer.shadowColor = UIColorFromRGB(0xB721FF).CGColor;
    self.searchTopView.layer.shadowOpacity = .24;
    self.searchTopView.layer.shadowOffset = CGSizeMake(0, 4);
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.searchTopView addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(96 * scale);
        make.left.mas_equalTo(24 * scale);
        make.right.mas_equalTo(-24 * scale);
        make.height.mas_equalTo((124 + kStatusBarHeight) * scale);
    }];
    self.textField.backgroundColor = UIColorFromRGB(0xFAFAFA);
    [DDViewFactoryTool cornerRadius:6 * scale withView:self.textField];
    self.textField.layer.shadowColor = UIColorFromRGB(0x000000).CGColor;
    self.textField.layer.shadowOpacity = .24f;
    self.textField.layer.shadowRadius = 6 * scale;
    self.textField.layer.shadowOffset = CGSizeMake(0, 6 * scale);
    
    UIButton * backButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(0, 0, 110 * scale, 72 * scale) font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@""];
    self.textField.leftView = backButton;
    UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectMake(40 * scale, 14 * scale, 48 * scale, 48 * scale) contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"close_color"]];
    [backButton addSubview:imageView];
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    [backButton addTarget:self action:@selector(topCloseButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * sendButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(0, 0, 140 * scale, 72 * scale) font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:DDLocalizedString(@"Search")];
    self.textField.rightView = sendButton;
    self.textField.rightViewMode = UITextFieldViewModeAlways;
    [sendButton addTarget:self action:@selector(topSearchButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.topTimeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"SetTime")];
    [self.topTimeButton addTarget:self action:@selector(topTimeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.searchTopView addSubview:self.topTimeButton];
    [self.topTimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textField.mas_bottom).offset(10 * scale);
        make.right.mas_equalTo(0 * scale);
        make.bottom.mas_equalTo(-10 * scale);
        make.width.mas_equalTo(kMainBoundsWidth / 2);
    }];
    
    self.topSourceButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"SetType")];
    [self.topSourceButton addTarget:self action:@selector(topSourceButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.searchTopView addSubview:self.topSourceButton];
    [self.topSourceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textField.mas_bottom).offset(10 * scale);
        make.left.mas_equalTo(0 * scale);
        make.bottom.mas_equalTo(-10 * scale);
        make.width.mas_equalTo(kMainBoundsWidth / 2);
    }];
    
    UIView * lineView2 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView2.backgroundColor = [UIColorFromRGB(0xFFFFFF) colorWithAlphaComponent:.5f];
    [self.topSourceButton addSubview:lineView2];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.width.mas_equalTo(3 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    
//    self.topSelectButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"指定作者"];
//    [self.topSelectButton addTarget:self action:@selector(selectButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.searchTopView addSubview:self.topSelectButton];
//    [self.topSelectButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.textField.mas_bottom).offset(10 * scale);
//        make.left.mas_equalTo(kMainBoundsWidth / 3);
//        make.bottom.mas_equalTo(-10 * scale);
//        make.width.mas_equalTo(kMainBoundsWidth / 3);
//    }];
    
//    UIView * lineView1 = [[UIView alloc] initWithFrame:CGRectZero];
//    lineView1.backgroundColor = [UIColorFromRGB(0xFFFFFF) colorWithAlphaComponent:.5f];
//    [self.topTimeButton addSubview:lineView1];
//    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(0);
//        make.left.mas_equalTo(0);
//        make.width.mas_equalTo(3 * scale);
//        make.height.mas_equalTo(72 * scale);
//    }];
    
    self.searchTopView.hidden = YES;
    
//    self.topSelectButton.alpha = .5f;
    self.topSourceButton.alpha = .5f;
    self.topTimeButton.alpha = .5f;
}

- (void)topCloseButtonDidClicked
{
    [self endTextFieldEdit];
    self.searchTopView.hidden = YES;
    self.isSearch = NO;
}

- (void)topTimeButtonDidClicked
{
    [self endTextFieldEdit];
    ChooseTimeView * choose = [[ChooseTimeView alloc] init];
    choose.handleButtonClicked = ^(NSInteger minTime, NSInteger maxTime) {
        self.minTime = minTime;
        self.maxTime = maxTime;
        self.topTimeButton.alpha = 1.f;
        if (self.sourceType == 666) {
            
        }else{
            [self searchMapViewLocations];
        }
    };
    [choose show];
}

- (void)topSourceButtonDidClicked
{
    [self endTextFieldEdit];
    ChooseCategoryView * choose = [[ChooseCategoryView alloc] init];
    choose.handleButtonClicked = ^(NSInteger tag) {
        self.searchType = tag;
        self.topSourceButton.alpha = 1.f;
        if (self.sourceType == 666) {
            
        }else{
            [self searchMapViewLocations];
        }
    };
    [choose show];
}

- (void)topSearchButtonDidClicked
{
    if (self.sourceType == 666) {
        
    }else{
        [self endTextFieldEdit];
        [self searchMapViewLocations];
    }
}

- (void)resetSearch
{
//    self.topSelectButton.alpha = .5f;
    self.topSourceButton.alpha = .5f;
    self.topTimeButton.alpha = .5f;
    self.textField.text = @"";
    [self.yaoyueSelectView clear];
    [self.yaoyueFriendSource removeAllObjects];
    self.minTime = 0;
    self.maxTime = 0;
    self.searchType = 0;
}

- (void)mineButtonDidClicked
{
    [self showLeftViewAnimated:nil];
}

- (void)timeButtonDidClicked
{
    UIView * tempView = [self.view snapshotViewAfterScreenUpdates:NO];
    [self.mapVCSource makeObjectsPerformSelector:@selector(addOnlyMapWith:) withObject:tempView];
    
    [self.view addSubview:self.safariPageController.view];
    [self.safariPageController.view setFrame:self.view.bounds];
    [self.safariPageController didMoveToParentViewController:self];
    [self.safariPageController zoomOutAnimated:YES completion:nil];
}

- (NSUInteger)numberOfPagesInPageController:(SCSafariPageController *)pageController
{
    return self.mapVCSource.count;
}

- (UIViewController *)pageController:(SCSafariPageController *)pageController viewControllerForPageAtIndex:(NSUInteger)index
{
    return [self.mapVCSource objectAtIndex:index];
}

- (void)viewControllerDidReceiveTap:(OnlyMapViewController *)viewController
{
    if(![self.safariPageController isZoomedOut]) {
        return;
    }
    
    NSUInteger pageIndex = [self.mapVCSource indexOfObject:viewController];
    
    [self.safariPageController zoomIntoPageAtIndex:pageIndex animated:YES completion:^{
        [self.safariPageController removeFromParentViewController];
        [self.safariPageController.view removeFromSuperview];
    }];
    
    if (pageIndex == 0) {
        if (self.sourceType == 666) {
            [MBProgressHUD showTextHUDWithText:@"该群暂不支持查看全部时间" inView:self.view];
            return;
        }
    }
    
    if (self.year != viewController.year) {
        self.year = viewController.year;
        self.timeLabel.text = [NSString stringWithFormat:@"%ld年", self.year];
        if (self.year == -1) {
            self.timeLabel.text = DDLocalizedString(@"Across time");
        }
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self requestMapViewLocations];
    }
}

- (void)motionHandle
{
    self.isMotion = YES;
//    [self requestMapViewLocations];
    
    self.shakeCount++;
    if (self.shakeCount == 4) {
        self.shakeCount = 1;
    }
    
    [DTieSearchRequest cancelRequest];
    NSInteger dataSourceType = 12;
    if (self.groupModel.cid == -1) {
        dataSourceType = 1;
    }else if (self.groupModel.cid == -2) {
        dataSourceType = 6;
    }else if (self.groupModel.cid == -4) {
        dataSourceType = 9;
    }else if (self.groupModel.cid == -5) {
        dataSourceType = 14;
    }else if (self.groupModel.cid == -6) {
        dataSourceType = 15;
    }
    DDShakeRequest * request = [[DDShakeRequest alloc] initWithGroupID:self.groupModel.cid dataSource:dataSourceType times:self.shakeCount];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSDictionary * data = [response objectForKey:@"data"];
        if (KIsDictionary(data)) {
            
            [self.mapView removeAnnotations:self.mapView.annotations];
            [self.mapSource removeAllObjects];
            
            DTieModel * model = [DTieModel mj_objectWithKeyValues:data];
            
            NSMutableArray * tempPointArray = [[NSMutableArray alloc] init];
            NSMutableArray * tempMapArray = [[NSMutableArray alloc] init];
            
            [tempMapArray addObject:model];
            
            BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc] init];
            annotation.coordinate = CLLocationCoordinate2DMake(model.sceneAddressLat, model.sceneAddressLng);
            [tempPointArray addObject:annotation];
            
            [self.mapSource addObjectsFromArray:[[tempMapArray reverseObjectEnumerator] allObjects]];
            [self.mapView addAnnotations:[[tempPointArray reverseObjectEnumerator] allObjects]];
            
            BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(CLLocationCoordinate2DMake(model.sceneAddressLat, model.sceneAddressLng), BMKCoordinateSpanMake(0, .3));
            [self.mapView setRegion:viewRegion animated:YES];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}
//福建省厦门市思明区湖滨北路61号
#pragma mark - getter
- (NSMutableArray *)mapVCSource
{
    if (!_mapVCSource) {
        _mapVCSource = [[NSMutableArray alloc] init];
        
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        // 获取当前日期
        NSDate* dt = [NSDate date];
        // 定义一个时间字段的旗标，指定将会获取指定年、月、日、时、分、秒的信息
        unsigned unitFlags = NSCalendarUnitYear |
        NSCalendarUnitMonth |  NSCalendarUnitDay;
        // 获取不同时间字段的信息
        NSDateComponents* comp = [gregorian components: unitFlags
                                              fromDate:dt];
        NSInteger year = comp.year;
        
        OnlyMapViewController * allMap = [[OnlyMapViewController alloc] init];
        allMap.year = -1;
        allMap.delegate = self;
        [_mapVCSource addObject:allMap];
        
        for (NSInteger i = 0; i < 50; i++) {
            OnlyMapViewController * map = [[OnlyMapViewController alloc] init];
            map.year = year - i;
            map.delegate = self;
            [_mapVCSource addObject:map];
        }
    }
    return _mapVCSource;
}

- (NSMutableArray *)mapSource
{
    if (!_mapSource) {
        _mapSource = [NSMutableArray new];
    }
    return _mapSource;
}

- (UIView *)tipView
{
    if (!_tipView) {
        CGFloat scale = kMainBoundsWidth / 1080.f;
        
        _tipView = [[UIView alloc] initWithFrame:CGRectZero];
        _tipView.backgroundColor = [UIColorFromRGB(0x394249) colorWithAlphaComponent:.8f];
        [self.view addSubview:_tipView];
        [_tipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(25 * scale + (220 + kStatusBarHeight) * scale);
            make.left.mas_equalTo(24 * scale);
            make.right.mas_equalTo(-24 * scale);
            make.height.mas_equalTo(132 * scale);
        }];
        [DDViewFactoryTool cornerRadius:6 * scale withView:_tipView];
        
        UIImageView * tipImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"shake"]];
        [_tipView addSubview:tipImageView];
        [tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(40 * scale);
            make.centerY.mas_equalTo(0);
            make.width.height.mas_equalTo(45 * scale);
        }];
        
        self.tipLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xF8F8F8) alignment:NSTextAlignmentCenter];
        [_tipView addSubview:self.tipLabel];
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.left.mas_equalTo(120 * scale);
            make.right.mas_equalTo(-120 * scale);
        }];
        
        UIImageView * tipAlert = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"alert"]];
        [_tipView addSubview:tipAlert];
        [tipAlert mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-40 * scale);
            make.centerY.mas_equalTo(0);
            make.width.height.mas_equalTo(60*scale);
        }];
        
        _tipView.alpha = 0;
    }
    return _tipView;
}

- (NSMutableArray *)yaoyueFriendSource
{
    if (!_yaoyueFriendSource) {
        _yaoyueFriendSource = [[NSMutableArray alloc] init];
    }
    return _yaoyueFriendSource;
}

- (NSMutableArray *)yaoyueMapSource
{
    if (!_yaoyueMapSource) {
        _yaoyueMapSource = [[NSMutableArray alloc] init];
    }
    return _yaoyueMapSource;
}

- (NSMutableArray *)friendSource
{
    if (!_friendSource) {
        _friendSource = [[NSMutableArray alloc] init];
    }
    return _friendSource;
}

- (void)endTextFieldEdit
{
    if (self.textField.isFirstResponder) {
        [self.textField resignFirstResponder];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[DDBackWidow shareWindow] hidden];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[DDBackWidow shareWindow] show];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    DDGroupRequest * request = [[DDGroupRequest alloc] initCheckGroupNew];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSDictionary * data = [response objectForKey:@"data"];
        if (KIsDictionary(data)) {
            NSInteger newFlag = [[data objectForKey:@"newFlag"] integerValue];
            if (newFlag == 1) {
                self.tagView.hidden = NO;
            }else{
                self.tagView.hidden = YES;
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DDUserLocationDidUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DDGroupDidChange" object:nil];
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
