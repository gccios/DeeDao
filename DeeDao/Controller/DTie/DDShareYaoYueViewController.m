//
//  DDShareYaoYueViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/12.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDShareYaoYueViewController.h"
#import "UserManager.h"
#import "MBProgressHUD+DDHUD.h"
#import "GetWXAccessTokenRequest.h"
#import "WeChatManager.h"
#import <UIImageView+WebCache.h>
#import "GCCScreenImage.h"
#import "UserYaoYueModel.h"
#import "DDTool.h"

#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>

@interface DDShareYaoYueViewController ()<UITableViewDelegate, UITableViewDataSource, BMKMapViewDelegate>

@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UIView * resultView;
@property (nonatomic, strong) UITextField * titleField;
@property (nonatomic, strong) UITextField * timeField;

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) UIView * shareView;

@property (nonatomic, strong) NSArray * selectUsers;

@property (nonatomic, strong) UIImageView * mapImageView;
@property (nonatomic, strong) BMKMapView * mapView;

@property (nonatomic, assign) BOOL isFinishMap;
@property (nonatomic, assign) BOOL isFinishCode;

@end

@implementation DDShareYaoYueViewController

- (instancetype)initWithDtieModel:(DTieModel *)model selectUser:(NSArray *)selectUsers
{
    if (self = [super init]) {
        self.model = model;
        self.selectUsers = [[NSArray alloc] initWithArray:selectUsers];
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
    
    NSInteger userCount = self.selectUsers.count;
    NSInteger lineCount = userCount / 3;
    if (userCount % 3 > 0) {
        lineCount++;
    }
    
    CGFloat height = 230 * scale;
    
    CGFloat userHeight = lineCount * height;
    
    self.resultView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 2400 * scale + userHeight)];
    self.resultView.backgroundColor = [UIColor whiteColor];
    
    UIView * userLogoBGView = [[UIView alloc] initWithFrame:CGRectZero];
    userLogoBGView.backgroundColor = [UIColor whiteColor];
    [self.resultView addSubview:userLogoBGView];
    [userLogoBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(80 * scale);
        make.left.mas_equalTo(65 * scale);
        make.width.height.mas_equalTo(96 * scale);
    }];
    userLogoBGView.layer.cornerRadius = 48 * scale;
    userLogoBGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    userLogoBGView.layer.shadowOpacity = .5f;
    userLogoBGView.layer.shadowRadius = 6 * scale;
    userLogoBGView.layer.shadowOffset = CGSizeMake(0, 3 * scale);
    
    UIImageView * logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFit image:[UIImage new]];
    
    [userLogoBGView addSubview:logoImageView];
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(96 * scale);
    }];
    [logoImageView sd_setImageWithURL:[NSURL URLWithString:[UserManager shareManager].user.portraituri]];
    [DDViewFactoryTool cornerRadius:48 * scale withView:logoImageView];
    
    UILabel * nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    nameLabel.text = [UserManager shareManager].user.nickname;
    [self.resultView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(userLogoBGView.mas_right).offset(15 * scale);
        make.centerY.mas_equalTo(userLogoBGView);
        make.right.mas_equalTo(-490 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
    
//    UILabel * tipLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentRight];
//    tipLabel.text = @"通过以下D帖发起要约";
//    [self.resultView addSubview:tipLabel];
//    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(userLogoBGView);
//        make.right.mas_equalTo(-60 * scale);
//        make.height.mas_equalTo(55 * scale);
//    }];
    
    UIImageView * yaoyueImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    yaoyueImageView.contentMode = UIViewContentModeScaleAspectFill;
    [yaoyueImageView setImage:[UIImage imageNamed:@"yaoyueno"]];
    [self.resultView addSubview:yaoyueImageView];
    [yaoyueImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(userLogoBGView);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    
    UIView * BGView = [[UIView alloc] initWithFrame:CGRectZero];
    BGView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.resultView addSubview:BGView];
    [BGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(204 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(1500 * scale);
    }];
    BGView.layer.cornerRadius = 24 * scale;
    BGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    BGView.layer.shadowOpacity = .3f;
    BGView.layer.shadowRadius = 12 * scale;
    BGView.layer.shadowOffset = CGSizeMake(0, 6 * scale);
    
    UIView * contenView = [[UIView alloc] initWithFrame:CGRectZero];
    contenView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [DDViewFactoryTool cornerRadius:24 * scale withView:contenView];
    [BGView addSubview:contenView];
    [contenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    UIView * yaoyueView = [[UIView alloc] initWithFrame:CGRectZero];
    [contenView addSubview:yaoyueView];
    [yaoyueView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(156 * scale);
    }];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth - 120 * scale, 156 * scale);
    [yaoyueView.layer addSublayer:gradientLayer];
    
    UILabel * yaoyueLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentCenter];
    yaoyueLabel.text = @"发现你们都想约这里，那么我们一起去吧";
    [yaoyueView addSubview:yaoyueLabel];
    [yaoyueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    UIImageView * coverImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [coverImageView sd_setImageWithURL:[NSURL URLWithString:self.model.postFirstPicture]];
    coverImageView.clipsToBounds = YES;
    [contenView addSubview:coverImageView];
    [coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(yaoyueView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(480 * scale);
    }];
    
//    UIImageView * letterImageview = [[UIImageView alloc] init];
//    [letterImageview setImage:[UIImage imageNamed:@"letterLogo"]];
//    [coverImageView addSubview:letterImageview];
//    [letterImageview mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(60 * scale);
//        make.right.mas_equalTo(-60 * scale);
//        make.width.mas_equalTo(168 * scale);
//        make.height.mas_equalTo(120 * scale);
//    }];
    
//    UIView * coverBlackView = [[UIView alloc] initWithFrame:CGRectZero];
//    coverBlackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
//    [coverImageView addSubview:coverBlackView];
//    [coverBlackView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.bottom.right.mas_equalTo(0);
//        make.height.mas_equalTo(120 * scale);
//    }];
//
//    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentLeft];
//    titleLabel.text = self.model.postSummary;
//    [coverBlackView addSubview:titleLabel];
//    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(60 * scale);
//        make.centerY.mas_equalTo(0);
//        make.height.mas_equalTo(55 * scale);
//        make.right.mas_equalTo(-60 * scale);
//    }];
    
    UILabel * titleInputLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentCenter];
    titleInputLabel.text = @"整啥：";
    [contenView addSubview:titleInputLabel];
    [titleInputLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(coverImageView.mas_bottom).offset(48 * scale);
        make.left.mas_equalTo(57 * scale);
        make.height.mas_equalTo(72 * scale);
        make.width.mas_equalTo(140 * scale);
    }];
    
    UIView * titleLineView = [[UIView alloc] initWithFrame:CGRectZero];
    titleLineView.backgroundColor = UIColorFromRGB(0xCCCCCC);
    [contenView addSubview:titleLineView];
    [titleLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleInputLabel.mas_right);
        make.top.mas_equalTo(titleInputLabel.mas_bottom).offset(5 * scale);
        make.height.mas_equalTo(2 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    
    self.titleField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.titleField.placeholder = @"请输入聚会主题";
    self.titleField.font = kPingFangRegular(42 * scale);
    self.titleField.textColor = UIColorFromRGB(0x333333);
    [contenView addSubview:self.titleField];
    [self.titleField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleInputLabel.mas_right);
        make.centerY.mas_equalTo(titleInputLabel);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    
    UILabel * timeInputLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentCenter];
    timeInputLabel.text = [NSString stringWithFormat:@"%@：", DDLocalizedString(@"Time")];
    [contenView addSubview:timeInputLabel];
    [timeInputLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleInputLabel.mas_bottom).offset(60 * scale);
        make.left.mas_equalTo(57 * scale);
        make.height.mas_equalTo(72 * scale);
        make.width.mas_equalTo(140 * scale);
    }];
    
    UIView * timeLineView = [[UIView alloc] initWithFrame:CGRectZero];
    timeLineView.backgroundColor = UIColorFromRGB(0xCCCCCC);
    [contenView addSubview:timeLineView];
    [timeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(timeInputLabel.mas_right);
        make.top.mas_equalTo(timeInputLabel.mas_bottom).offset(5 * scale);
        make.height.mas_equalTo(2 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    
    self.timeField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.timeField.placeholder = @"请输入聚会时间";
    self.timeField.font = kPingFangRegular(42 * scale);
    self.timeField.textColor = UIColorFromRGB(0x333333);
    [contenView addSubview:self.timeField];
    [self.timeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(timeInputLabel.mas_right);
        make.centerY.mas_equalTo(timeInputLabel);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    
    UILabel * locationLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    locationLabel.text = [NSString stringWithFormat:@"地址：%@", self.model.sceneAddress];
    [contenView addSubview:locationLabel];
    [locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleInputLabel);
        make.top.mas_equalTo(timeLineView.mas_bottom).offset(48 * scale);
        make.height.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-55 * scale);
    }];
    
    self.mapImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.mapImageView.clipsToBounds = YES;
    self.mapImageView.contentMode = UIViewContentModeScaleAspectFill;
    [contenView addSubview:self.mapImageView];
    [self.mapImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.top.mas_equalTo(locationLabel.mas_bottom).offset(40 * scale);
    }];
    
    self.mapView = [[BMKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = NO;
    self.mapView.userTrackingMode = BMKUserTrackingModeNone;
    self.mapView.gesturesEnabled = NO;
    self.mapView.buildingsEnabled = NO;
    
    [contenView insertSubview:self.mapView atIndex:0];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.top.mas_equalTo(locationLabel.mas_bottom).offset(40 * scale);
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
    
//
//    UILabel * numberLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentCenter];
//    numberLabel.text = @"以上好友，一起happy";
//    [contenView addSubview:numberLabel];
//    [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(contenLineView.mas_bottom).offset(290 * scale);
//        make.height.mas_equalTo(55 * scale);
//        make.left.right.mas_equalTo(0);
//    }];
    
    UIView * logoBGView = [[UIView alloc] initWithFrame:CGRectZero];
    logoBGView.backgroundColor = [UIColor whiteColor];
    [self.resultView addSubview:logoBGView];
    [logoBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(contenView.mas_bottom).offset(-132 * scale);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(264 * scale);
    }];
    logoBGView.layer.cornerRadius = 132 * scale;
    logoBGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    logoBGView.layer.shadowOpacity = .5f;
    logoBGView.layer.shadowRadius = 24 * scale;
    logoBGView.layer.shadowOffset = CGSizeMake(0, 12 * scale);
    
    UIImageView * codeImageView = [[UIImageView alloc] init];
    [logoBGView addSubview:codeImageView];
    [codeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(220 * scale);
    }];
    codeImageView.layer.cornerRadius = 80 * scale;
    codeImageView.clipsToBounds = YES;
    
    UILabel * bottomTipLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentCenter];
    bottomTipLabel.text = @"识别二维码，导航过去加入聚会";
    [self.resultView addSubview:bottomTipLabel];
    [bottomTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(60 * scale);
        make.top.mas_equalTo(logoBGView.mas_bottom).offset(70 * scale);
    }];
    
    UIView * contenLineView = [[UIView alloc] initWithFrame:CGRectZero];
    contenLineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.resultView addSubview:contenLineView];
    [contenLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bottomTipLabel.mas_bottom).offset(90 * scale);
        make.left.mas_equalTo(120 * scale);
        make.right.mas_equalTo(-120 * scale);
        make.height.mas_equalTo(2 * scale);
    }];
    
    UILabel * contentTipLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentCenter];
    contentTipLabel.backgroundColor = UIColorFromRGB(0xFFFFFF);
    contentTipLabel.text = @"要约列表";
    [self.resultView addSubview:contentTipLabel];
    [contentTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(contenLineView);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(300 * scale);
        make.height.mas_equalTo(55 * scale);
    }];
    
    CGFloat width = kMainBoundsWidth / 3.f;
    for (NSInteger i = 0; i < lineCount; i++) {
        
        for (NSInteger j = 0; j < 3; j++) {
            
            NSInteger index = i * 3 + j;
            
            if (index > self.selectUsers.count-1) {
                break;
            }
            
            UserYaoYueModel * model = [self.selectUsers objectAtIndex:index];
            
            UIView * userView = [[UIView alloc] initWithFrame:CGRectZero];
            [self.resultView addSubview:userView];
            [userView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(contentTipLabel.mas_bottom).offset(i * height + 20 * scale);
                make.left.mas_equalTo(j * width);
                make.width.mas_equalTo(width);
                make.height.mas_equalTo(height);
            }];
            
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [imageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
            [userView addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(40 * scale);
                make.centerX.mas_equalTo(0);
                make.width.height.mas_equalTo(96 * scale);
            }];
            [DDViewFactoryTool cornerRadius:48 * scale withView:imageView];
            
            UILabel * label = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentCenter];
            label.text = model.nickname;
            [userView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(imageView.mas_bottom).offset(15 * scale);
                make.left.mas_equalTo(30 * scale);
                make.right.mas_equalTo(-30 * scale);
                make.height.mas_equalTo(50 * scale);
            }];
        }
        
    }
    
    UIView * bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
    bottomLineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.resultView addSubview:bottomLineView];
    [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-120 * scale);
        make.left.mas_equalTo(120 * scale);
        make.right.mas_equalTo(-120 * scale);
        make.height.mas_equalTo(2 * scale);
    }];
    
    UILabel * bottomDeeDaoLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentCenter];
    bottomDeeDaoLabel.backgroundColor = UIColorFromRGB(0xFFFFFF);
    bottomDeeDaoLabel.text = @"发布于DeeDao地到APP";
    [self.resultView addSubview:bottomDeeDaoLabel];
    [bottomDeeDaoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(bottomLineView);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(450 * scale);
        make.height.mas_equalTo(55 * scale);
    }];
    
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
                [codeImageView setImage:image];
            }else{
                //                [self.logoImageView setImage:[UIImage imageNamed:@"gongzhongCode"]];
            }
        }];
        
        if (self.isFinishMap) {
            [hud hideAnimated:YES];
        }
        self.isFinishCode = YES;
        
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
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.rowHeight = .1 * scale;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = self.resultView;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDidClicked)];
    [self.tableView addGestureRecognizer:tap];
    
    [self.view addSubview:self.shareView];
    [self.shareView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(kMainBoundsWidth / 4.f);
    }];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kMainBoundsWidth / 4.f, 0);
}

- (void)tapDidClicked
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
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
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
    }
    self.isFinishMap = YES;
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
    titleLabel.text = @"分享要约邀请";
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

- (UIView *)shareView
{
    if (!_shareView) {
        _shareView = [[UIView alloc] initWithFrame:CGRectZero];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:_shareView action:@selector(removeFromSuperview)];
        [_shareView addGestureRecognizer:tap];
        
        NSArray * imageNames;
        NSArray * titles;
        NSInteger startTag = 10;
        
        BOOL isInstallWX = [WXApi isWXAppInstalled];
        
        if (isInstallWX) {
            imageNames = @[@"sharepengyouquan", @"shareweixin", @"saveToPhone"];
            titles = @[DDLocalizedString(@"Wechat Groups"), @"微信好友或群", @"保存到手机"];
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
//    if (isEmptyString(self.titleField.text)) {
//        [MBProgressHUD showTextHUDWithText:@"请输入主题" inView:self.view];
//        return;
//    }
//
//    if (isEmptyString(self.timeField.text)) {
//        [MBProgressHUD showTextHUDWithText:@"请输入时间" inView:self.view];
//        return;
//    }
    
    UIImage * shareImage = [GCCScreenImage screenView:self.resultView];
    if (button.tag == 10) {
        
        [[WeChatManager shareManager] shareImage:shareImage];
        
    }else if (button.tag == 11){
        
        [[WeChatManager shareManager] shareFriendImage:shareImage];
        
    }else{
        
        [DDTool userLibraryAuthorizationStatusWithSuccess:^{
            
            [DDTool saveImageInSystemPhoto:shareImage];
        } failure:^{
            [MBProgressHUD showTextHUDWithText:@"没有相册访问权限" inView:[UIApplication sharedApplication].keyWindow];
        }];
        
    }
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
