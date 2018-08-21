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
#import "DDMailViewController.h"
#import "DTieNewEditViewController.h"
#import "DTieNewViewController.h"
#import "DTieSearchViewController.h"
#import "ChooseTypeViewController.h"
#import "ChooseTimeView.h"
#import "ChooseCategoryView.h"
#import "DDShareManager.h"
#import "DDNotificationViewController.h"
#import "DDShouCangViewController.h"
#import "MapShowPostView.h"

@interface DDFoundViewController () <BMKMapViewDelegate, SCSafariPageControllerDelegate, SCSafariPageControllerDataSource, OnlyMapViewControllerDelegate, DTieFoundEditViewDelegate, DTieMapSelecteFriendDelegate, ChooseTypeViewControllerDelegate>

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UIView * searchTopView;
@property (nonatomic, strong) UITextField * textField;
@property (nonatomic, strong) UIButton * topTimeButton;
@property (nonatomic, strong) UIButton * topSourceButton;
@property (nonatomic, strong) UIButton * topSelectButton;

@property (nonatomic, strong) UIButton * locationButton;

@property (nonatomic, strong) UIButton * searchButton;
@property (nonatomic, assign) BOOL isSearch;

@property (nonatomic, strong) UIView * topAlertView;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UILabel * topAlertLabel;

@property (nonatomic, strong) UIButton * sourceButton;
//@property (nonatomic, strong) UIButton * timeButton;
@property (nonatomic, strong) UIButton * mailButton;
@property (nonatomic, strong) UIButton * selectButton;
@property (nonatomic, strong) UIButton * addButton;

@property (nonatomic, strong) UIButton * picButton;
@property (nonatomic, assign) BOOL picIsUser;

@property (nonatomic, strong) UIButton * tieButton;
@property (nonatomic, assign) BOOL tieIsOpen;
@property (nonatomic, strong) UIButton * myButton;
@property (nonatomic, strong) UIButton * shoucangButton;
@property (nonatomic, strong) UIButton * yuezheButton;

@property (nonatomic, strong) UIButton * typeButton;

@property (nonatomic, strong) BMKMapView * mapView;
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

@end

@implementation DDFoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.logoBGName = @"touxiangkuang";
    self.logoBGColor = UIColorFromRGB(0xDB6283);
    
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
    self.year = comp.year;
    
    self.isFirst = YES;
    // Do any additional setup after loading the view.
    
    self.sourceType = 8;
    
    [self getMyFriendList];
    [self creatViews];
    [self creatTopView];
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
    self.topSelectButton.alpha = 1.f;
    
    if (self.isSearch) {
        if (self.sourceType == 666) {
            
            [self.yaoyueFriendSource removeAllObjects];
            [self.yaoyueFriendSource addObjectsFromArray:selectFriend];
            [self.mapView removeAnnotations:self.mapView.annotations];
            [self requestMapViewLocations];
            
        }else if (selectView == self.yaoyueSelectView) {
            
            [self.yaoyueFriendSource removeAllObjects];
            [self.yaoyueFriendSource addObjectsFromArray:selectFriend];
            [self.mapView removeAnnotations:self.mapView.annotations];
            [self searchMapViewLocations];
            
        }
    }else{
        if (selectView == self.yaoyueSelectView) {
            
            [self.yaoyueFriendSource removeAllObjects];
            [self.yaoyueFriendSource addObjectsFromArray:selectFriend];
            [self.mapView removeAnnotations:self.mapView.annotations];
            [self requestMapViewLocations];
            
        }
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
    self.mapView.showMapPoi = NO;
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
    
    [self updateUserLocation];
    [self requestMapViewLocations];
    
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
    
    CGFloat buttonWidth = 100 * scale;
    
    self.backLocationButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self.backLocationButton setImage:[UIImage imageNamed:@"backLocation"] forState:UIControlStateNormal];
    [self.backLocationButton addTarget:self action:@selector(backLocationButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backLocationButton];
    [self.backLocationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.bottom.mas_equalTo(-520 * scale);
        make.width.height.mas_equalTo(120 * scale);
    }];
    
//    self.timeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"时光"];
//    self.timeButton.backgroundColor = UIColorFromRGB(0xdb6283);
//    [self.timeButton addTarget:self action:@selector(timeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.timeButton];
//    [self.timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(30 * scale);
//        make.bottom.mas_equalTo(self.backLocationButton.mas_top).offset(-30 * scale);
//        make.width.height.mas_equalTo(buttonWidth);
//    }];
//    self.timeButton.layer.cornerRadius = buttonWidth / 2.f;
//    self.timeButton.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.timeButton.layer.shadowOpacity = .5f;
//    self.timeButton.layer.shadowOffset = CGSizeMake(0, 10 * scale);
//    self.timeButton.layer.shadowRadius = 10 * scale;
    
//    self.sourceButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"博主"];
//    self.sourceButton.backgroundColor = UIColorFromRGB(0xdb6283);
//    [self.sourceButton addTarget:self action:@selector(sourceButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.sourceButton];
//    [self.sourceButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(30 * scale);
//        make.bottom.mas_equalTo(self.backLocationButton.mas_top).offset(-30 * scale);
//        make.width.height.mas_equalTo(buttonWidth);
//    }];
//    self.sourceButton.layer.cornerRadius = buttonWidth / 2.f;
//    self.sourceButton.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.sourceButton.layer.shadowOpacity = .5f;
//    self.sourceButton.layer.shadowOffset = CGSizeMake(0, 10 * scale);
//    self.sourceButton.layer.shadowRadius = 10 * scale;
    
//    self.selectButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"筛选"];
//    self.selectButton.backgroundColor = UIColorFromRGB(0xdb6283);
//    [self.selectButton addTarget:self action:@selector(selectButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.selectButton];
//    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(30 * scale);
//        make.bottom.mas_equalTo(self.sourceButton.mas_top).offset(-25 * scale);
//        make.width.height.mas_equalTo(buttonWidth);
//    }];
//    self.selectButton.layer.cornerRadius = buttonWidth / 2.f;
//    self.selectButton.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.selectButton.layer.shadowOpacity = .5f;
//    self.selectButton.layer.shadowOffset = CGSizeMake(0, 10 * scale);
//    self.selectButton.layer.shadowRadius = 10 * scale;
//    self.selectButton.alpha = .5f;
//    self.selectButton.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestMapViewLocations) name:DTieDidCreateNewNotification object:nil];
    
    self.topAlertView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.topAlertView];
//    self.topAlertView.backgroundColor = [UIColorFromRGB(0x111111) colorWithAlphaComponent:.1f];
    [self.topAlertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + 60 + kStatusBarHeight) * scale);
        make.left.mas_equalTo(250 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.topAlertView];
    
    self.mailButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self.mailButton setImage:[UIImage imageNamed:@"homeMail"] forState:UIControlStateNormal];
    [self.view addSubview:self.mailButton];
    [self.mailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topAlertView);
        make.left.mas_equalTo(60 * scale);
        make.width.height.mas_equalTo(120 * scale);
    }];
    [DDViewFactoryTool cornerRadius:60 * scale withView:self.mailButton];
    [self.mailButton addTarget:self action:@selector(mailButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * timeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self.topAlertView addSubview:timeButton];
    [timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(24 * scale);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(300 * scale);
        make.height.mas_equalTo(98 * scale);
    }];
    [timeButton setBackgroundImage:[UIImage imageNamed:@"homeTimeBG"] forState:UIControlStateNormal];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentCenter];
    [timeButton addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20 * scale);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(200 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    self.timeLabel.text = [NSString stringWithFormat:@"%ld", self.year];
    
    [timeButton addTarget:self action:@selector(timeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.topAlertLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    [self.topAlertView addSubview:self.topAlertLabel];
    self.topAlertLabel.text = @"地到博主D帖";
    [self.topAlertView addSubview:self.topAlertLabel];
    [self.topAlertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(timeButton.mas_right).offset(48 * scale);
        make.height.mas_equalTo(55 * scale);
        make.right.mas_equalTo(0);
    }];
    
    self.addButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self.addButton setBackgroundImage:[UIImage imageNamed:@"homeAdd"] forState:UIControlStateNormal];
    [self.view addSubview:self.addButton];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(-60 * scale);
        make.width.height.mas_equalTo(180 * scale);
    }];
    [self.addButton addTarget:self action:@selector(addButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.typeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self.typeButton setImage:[UIImage imageNamed:@"homeSource"] forState:UIControlStateNormal];
    [self.view addSubview:self.typeButton];
    [self.typeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.centerY.mas_equalTo(self.addButton);
        make.width.height.mas_equalTo(144 * scale);
    }];
    [self.typeButton addTarget:self action:@selector(typeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.picIsUser = YES;
    self.picButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self.picButton setImage:[UIImage imageNamed:@"homePicUser"] forState:UIControlStateNormal];
    [self.view addSubview:self.picButton];
    [self.picButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.centerY.mas_equalTo(self.addButton).offset(-180 * scale);
        make.width.height.mas_equalTo(144 * scale);
    }];
    [self.picButton addTarget:self action:@selector(picButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.yuezheButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self.yuezheButton setImage:[UIImage imageNamed:@"homeYuezhe"] forState:UIControlStateNormal];
    [self.view addSubview:self.yuezheButton];
    [self.yuezheButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.centerY.mas_equalTo(self.addButton).offset(0 * scale);
        make.width.height.mas_equalTo(144 * scale);
    }];
    [self.yuezheButton addTarget:self action:@selector(yuezheButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.shoucangButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self.shoucangButton setImage:[UIImage imageNamed:@"homeShoucang"] forState:UIControlStateNormal];
    [self.view addSubview:self.shoucangButton];
    [self.shoucangButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.centerY.mas_equalTo(self.addButton).offset(0 * scale);
        make.width.height.mas_equalTo(144 * scale);
    }];
    [self.shoucangButton addTarget:self action:@selector(shoucangButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.myButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self.myButton setImage:[UIImage imageNamed:@"homeMyPost"] forState:UIControlStateNormal];
    [self.view addSubview:self.myButton];
    [self.myButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.centerY.mas_equalTo(self.addButton).offset(0 * scale);
        make.width.height.mas_equalTo(144 * scale);
    }];
    [self.myButton addTarget:self action:@selector(myButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.tieIsOpen = NO;
    self.tieButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self.tieButton setImage:[UIImage imageNamed:@"homeMy"] forState:UIControlStateNormal];
    [self.view addSubview:self.tieButton];
    [self.tieButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.centerY.mas_equalTo(self.addButton).offset(0 * scale);
        make.width.height.mas_equalTo(144 * scale);
    }];
    [self.tieButton addTarget:self action:@selector(tieButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self showTipWithText:@"摇一摇以刷新附近D帖"];
//    });
}

- (void)typeDidChooseComplete:(NSInteger)chooseTag
{
    if (self.isSearch) {
        [self topCloseButtonDidClicked];
    }
    
    self.topSourceButton.hidden = NO;
    self.topTimeButton.hidden = NO;
    
    [self resetSearch];
    
    if (chooseTag == 11) {
        self.sourceType = 7;
        self.logoBGName = @"touxiangkuang";
        self.logoBGColor = UIColorFromRGB(0xDB6283);
        self.selectButton.alpha = .5f;
        self.selectButton.enabled = NO;
        self.topAlertLabel.text = @"我和朋友的及收藏和要约";
    }else if (chooseTag == 12) {
        self.sourceType = 8;
        self.logoBGName = @"touxiangkuangbozhu";
        self.logoBGColor = UIColorFromRGB(0xB721FF);
        self.selectButton.alpha = .5f;
        self.selectButton.enabled = NO;
        self.topAlertLabel.text = @"地到博主D帖";
    }else if (chooseTag == 13) {
        self.sourceType = 6;
        self.logoBGName = @"touxiangkuanghui";
        self.logoBGColor = UIColorFromRGB(0x999999);
        self.selectButton.alpha = .5f;
        self.selectButton.enabled = NO;
        if (self.year == -1) {
            OnlyMapViewController * map = [_mapVCSource objectAtIndex:1];
            self.year = map.year;
            self.timeLabel.text = [NSString stringWithFormat:@"%ld年", self.year];
        }
        self.topAlertLabel.text = @"陌生人的公开D帖";
    }else if (chooseTag == 14) {
        self.sourceType = 10;
        self.logoBGName = @"touxiangkuang";
        self.logoBGColor = UIColorFromRGB(0xDB6283);
        self.selectButton.alpha = .5f;
        self.selectButton.enabled = NO;
        self.topAlertLabel.text = @"提醒过的点";
    }
    
    self.addButton.hidden = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self requestMapViewLocations];
    [self updateUserLocation];
}

- (void)yuezheButtonDidClicked
{
    if (self.isSearch) {
        [self topCloseButtonDidClicked];
    }
    
    self.topSourceButton.hidden = YES;
    self.topTimeButton.hidden = YES;
    
    [self resetSearch];
    if (self.sourceType == 666) {
        return;
    }
    
    self.sourceType = 666;
//    self.selectButton.alpha = 1.f;
//    self.selectButton.enabled = YES;
    
    [self.yaoyueFriendSource removeAllObjects];
    self.topAlertLabel.text = @"所有发起约这的好友";
    
    if (self.year == -1) {
        OnlyMapViewController * map = [_mapVCSource objectAtIndex:1];
        self.year = map.year;
        self.timeLabel.text = [NSString stringWithFormat:@"%ld年", self.year];
    }
    
    self.addButton.hidden = YES;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self requestMapViewLocations];
    [self updateUserLocation];
}

- (void)typeButtonDidClicked
{
    ChooseTypeViewController * type = [[ChooseTypeViewController alloc] initWithSourceType:self.sourceType];
    type.delegate = self;
    [self.navigationController presentViewController:type animated:YES completion:nil];
}

- (void)shoucangButtonDidClicked
{
    DDShouCangViewController * search = [[DDShouCangViewController alloc] init];
    [self.navigationController pushViewController:search animated:YES];
}

- (void)myButtonDidClicked
{
    DTieNewViewController * dtie = [[DTieNewViewController alloc] init];
    [self.navigationController pushViewController:dtie animated:YES];
}

- (void)tieButtonDidClicked
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    self.tieIsOpen = !self.tieIsOpen;
    if (self.tieIsOpen) {
        [self.yuezheButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.addButton).offset(-420 * scale);
        }];
        [self.shoucangButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.addButton).offset(-280 * scale);
        }];
        [self.myButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.addButton).offset(-140 * scale);
        }];
        [self.tieButton setImage:[UIImage imageNamed:@"homeClose"] forState:UIControlStateNormal];
    }else{
        [self.yuezheButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.addButton).offset(0 * scale);
        }];
        [self.shoucangButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.addButton).offset(0 * scale);
        }];
        [self.myButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.addButton).offset(0 * scale);
        }];
        [self.tieButton setImage:[UIImage imageNamed:@"homeMy"] forState:UIControlStateNormal];
    }
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

- (void)addButtonDidClicked
{
    DTieNewEditViewController * edit = [[DTieNewEditViewController alloc] init];
    [self.navigationController pushViewController:edit animated:YES];
}

- (void)mailButtonDidClicked
{
    DDMailViewController * mail = [[DDMailViewController alloc] init];
    [self.navigationController pushViewController:mail animated:YES];
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
    BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake([DDLocationManager shareManager].userLocation.location.coordinate, BMKCoordinateSpanMake(.017, .017));
    BMKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
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
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake([DDLocationManager shareManager].userLocation.location.coordinate, BMKCoordinateSpanMake(.017, .017));
        BMKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
        [_mapView setRegion:adjustedRegion animated:YES];
        self.isFirst = NO;
    }
    
    if ([DDLocationManager shareManager].result) {
        NSString * city = [DDLocationManager shareManager].result.addressDetail.city;
        [self.locationButton setTitle:city forState:UIControlStateNormal];
    }
}

- (void)requestMapViewLocations
{
    [DTieSearchRequest cancelRequest];
    
    self.isNotification = NO;
    if (self.sourceType == 666) {
        
        NSMutableArray * friendList = [[NSMutableArray alloc] init];
        for (UserModel * model in self.yaoyueFriendSource) {
            [friendList addObject:@(model.cid)];
        }
        
        SelectMapYaoyueRequest * request = [[SelectMapYaoyueRequest alloc] initWithFriendList:friendList];
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
        
        DTieSearchRequest * request = [[DTieSearchRequest alloc] initWithKeyWord:@"" lat1:leftUpLati lng1:leftUpLong lat2:rightDownLati lng2:rightDownLong startDate:startDate endDate:endDate sortType:2 dataSources:self.sourceType type:1 pageStart:0 pageSize:1000];
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
//    [self requestMapViewLocations];
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
    }else{
        
        CGFloat width = view.frame.size.width;
        CGFloat logoWidth = width * 47.5f / 52.f;
        CGFloat origin = (width - logoWidth) / 2;
        
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
            
            MapShowYaoyueView * yaoyue = [[MapShowYaoyueView alloc] initWithModel:model];
            [yaoyue show];
        }
    }else if (self.isNotification) {
        
        if ([self.mapView.annotations containsObject:view.annotation]) {
            NSInteger index = [self.mapView.annotations indexOfObject:view.annotation];
            
            DTieModel * model = [self.mapSource objectAtIndex:index];
            NSInteger notificationID = [model.remark integerValue];
            
            DDNotificationViewController * vc = [[DDNotificationViewController alloc] initWithNotificationID:notificationID];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }else{
        if ([self.mapView.annotations containsObject:view.annotation]) {
            NSInteger index = [self.mapView.annotations indexOfObject:view.annotation];
            
            DTieModel * model = [self.mapSource objectAtIndex:index];
            NSArray * tempArray = [[self.mapSource reverseObjectEnumerator] allObjects];
            index = [tempArray indexOfObject:model];
            
//            MapShowPostView * view = [[MapShowPostView alloc] initWithModel:model source:tempArray index:index];
//            [view show];
            
            DDCollectionViewController * vc = [[DDCollectionViewController alloc] initWithDataSource:tempArray index:index];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
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
    
    if ([DDLocationManager shareManager].result) {
        NSString * city = [DDLocationManager shareManager].result.addressDetail.city;
        [self.locationButton setTitle:city forState:UIControlStateNormal];
    }
    
    [self.locationButton setImage:[UIImage imageNamed:@"homeLocation"] forState:UIControlStateNormal];
    [self.topView addSubview:self.locationButton];
    [self.locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0 * scale);
        make.height.mas_equalTo(72 * scale);
        make.centerY.mas_equalTo(logoButton);
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

- (void)searchButtonDidClicked
{
    self.searchTopView.hidden = NO;
    self.isSearch = YES;
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
    
    UIButton * sendButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(0, 0, 130 * scale, 72 * scale) font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"搜索"];
    self.textField.rightView = sendButton;
    self.textField.rightViewMode = UITextFieldViewModeAlways;
    [sendButton addTarget:self action:@selector(topSearchButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.topTimeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"指定时间段"];
    [self.topTimeButton addTarget:self action:@selector(topTimeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.searchTopView addSubview:self.topTimeButton];
    [self.topTimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textField.mas_bottom).offset(10 * scale);
        make.right.mas_equalTo(0 * scale);
        make.bottom.mas_equalTo(-10 * scale);
        make.width.mas_equalTo(kMainBoundsWidth / 3);
    }];
    
    self.topSourceButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"指定类别"];
    [self.topSourceButton addTarget:self action:@selector(topSourceButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.searchTopView addSubview:self.topSourceButton];
    [self.topSourceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textField.mas_bottom).offset(10 * scale);
        make.left.mas_equalTo(0 * scale);
        make.bottom.mas_equalTo(-10 * scale);
        make.width.mas_equalTo(kMainBoundsWidth / 3);
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
    
    self.topSelectButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"指定作者"];
    [self.topSelectButton addTarget:self action:@selector(selectButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.searchTopView addSubview:self.topSelectButton];
    [self.topSelectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textField.mas_bottom).offset(10 * scale);
        make.left.mas_equalTo(kMainBoundsWidth / 3);
        make.bottom.mas_equalTo(-10 * scale);
        make.width.mas_equalTo(kMainBoundsWidth / 3);
    }];
    
    UIView * lineView1 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView1.backgroundColor = [UIColorFromRGB(0xFFFFFF) colorWithAlphaComponent:.5f];
    [self.topTimeButton addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(3 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    
    self.searchTopView.hidden = YES;
    
    self.topSelectButton.alpha = .5f;
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
    self.topSelectButton.alpha = .5f;
    self.topSourceButton.alpha = .5f;
    self.topTimeButton.alpha = .5f;
    self.textField.text = @"";
    [self.yaoyueSelectView clear];
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

- (void)sourceButtonDidClicked
{
    if (self.sourceType == 7) {
        self.sourceType = 6;
        [self.sourceButton setTitle:@"公开" forState:UIControlStateNormal];
        self.logoBGName = @"touxiangkuanghui";
        self.logoBGColor = UIColorFromRGB(0x999999);
        self.selectButton.alpha = .5f;
        self.selectButton.enabled = NO;
        if (self.year == -1) {
            OnlyMapViewController * map = [_mapVCSource objectAtIndex:1];
            self.year = map.year;
            self.timeLabel.text = [NSString stringWithFormat:@"%ld年", self.year];
        }
        
        self.topAlertLabel.text = @"陌生人的公开D帖";
    }else if (self.sourceType == 8) {
        self.sourceType = 666;
        [self.sourceButton setTitle:@"约" forState:UIControlStateNormal];
        self.selectButton.alpha = 1.f;
        self.selectButton.enabled = YES;
        
        self.topAlertLabel.text = @"所有发起约这的好友";
        
        if (self.year == -1) {
            OnlyMapViewController * map = [_mapVCSource objectAtIndex:1];
            self.year = map.year;
            self.timeLabel.text = [NSString stringWithFormat:@"%ld年", self.year];
        }
    }else if (self.sourceType == 6) {
        self.sourceType = 8;
        [self.sourceButton setTitle:@"博主" forState:UIControlStateNormal];
        self.logoBGName = @"touxiangkuangbozhu";
        self.logoBGColor = UIColorFromRGB(0xB721FF);
        self.selectButton.alpha = .5f;
        self.selectButton.enabled = NO;
        
        self.topAlertLabel.text = @"地到博主D帖";
    }else{
        self.sourceType = 7;
        [self.sourceButton setTitle:@"我的" forState:UIControlStateNormal];
        self.logoBGName = @"touxiangkuang";
        self.logoBGColor = UIColorFromRGB(0xDB6283);
        self.selectButton.alpha = .5f;
        self.selectButton.enabled = NO;
        
        self.topAlertLabel.text = @"我和朋友的及收藏和要约";
    }
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self requestMapViewLocations];
    [self updateUserLocation];
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
        if (self.sourceType == 6 || self.sourceType == 666) {
            [MBProgressHUD showTextHUDWithText:@"该频道暂不支持查看全部时间" inView:self.view];
            return;
        }
    }
    
    if (self.year != viewController.year) {
        self.year = viewController.year;
        self.timeLabel.text = [NSString stringWithFormat:@"%ld年", self.year];
        if (self.year == -1) {
            self.timeLabel.text = @"全部时间";
        }
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self requestMapViewLocations];
    }
}

- (void)motionHandle
{
    self.isMotion = YES;
    [self requestMapViewLocations];
}

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DDUserLocationDidUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DTieDidCreateNewNotification object:nil];
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
