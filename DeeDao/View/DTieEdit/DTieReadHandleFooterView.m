//
//  DTieReadHandleFooterView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieReadHandleFooterView.h"
#import "DDViewFactoryTool.h"
#import "UserManager.h"
#import "DTieCancleWYYRequest.h"
#import "DTieCancleCollectRequest.h"
#import "DTieCollectionRequest.h"
#import <Masonry.h>
#import "DDTool.h"
#import "DDYaoYueViewController.h"
#import "SelectPostSeeRequest.h"
#import "DTieSeeModel.h"
#import "DTieSeeShareViewController.h"
#import "MBProgressHUD+DDHUD.h"
#import "DDLGSideViewController.h"
#import "UserYaoYueBlockModel.h"
#import "DTieYaoyueBlockView.h"
#import "ChangeWYYStatusRequest.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import "DDLocationManager.h"
#import "SecurityFriendController.h"
#import "SelectWYYBlockRequest.h"
#import "AddUserToWYYRequest.h"
#import "RDAlertView.h"

@interface DTieReadHandleFooterView ()<BMKMapViewDelegate, SecurityFriendDelegate>

@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, strong) NSMutableArray * yaoyueList;
@property (nonatomic, strong) UIView * yaoyueView;

@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UIButton * handleButton;
@property (nonatomic, strong) UIButton * shoucangButton;
@property (nonatomic, strong) UIButton * yaoyueButton;
@property (nonatomic, strong) UILabel * yaoyueNumberLabel;
@property (nonatomic, strong) UILabel * yaoyueNumberShowLabel;
@property (nonatomic, strong) UILabel * shoucangNumberLabel;

@property (nonatomic, strong) UILabel * readLabel;
@property (nonatomic, strong) UIButton * readButton;
@property (nonatomic, strong) UIButton * jubaoButton;

@property (nonatomic, strong) UIView * mapBaseView;
@property (nonatomic, strong) BMKMapView * mapView;

@property (nonatomic, strong) UISwitch * addUserSwitch;

@property (nonatomic, strong) UIButton * leftButton;
@property (nonatomic, strong) UIButton * rightButton;
@property (nonatomic, strong) UIButton * createButton;

@end

@implementation DTieReadHandleFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self createDTieReadHandleView];
    }
    return self;
}

- (void)configWithModel:(DTieModel *)model
{
    model.readTimes += 1;
    self.model = model;
    
    BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(self.model.sceneAddressLat, self.model.sceneAddressLng);
    [self.mapView addAnnotation:annotation];
    
    self.timeLabel.text = [NSString stringWithFormat:@"%@：%@", DDLocalizedString(@"Last updated"), [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.model.createTime]];
    
    if (model.authorId == [UserManager shareManager].user.cid) {
        self.handleButton.hidden = NO;
        self.jubaoButton.hidden = YES;
        self.readButton.hidden = NO;
    }else{
        self.handleButton.hidden = YES;
        self.jubaoButton.hidden = NO;
        self.readButton.hidden = YES;
    }
    
    NSString * readText = @"0";
    if (model.readTimes > 0) {
        readText = [NSString stringWithFormat:@"%ld", model.readTimes];
    }
    if (model.readTimes > 10000) {
        readText = @"10000+";
    }
    self.readLabel.text = [NSString stringWithFormat:@"%@：%@", DDLocalizedString(@"# of readers"), readText];

    
    [self reloadStatus];
}

- (void)configWithWacthPhotos:(NSArray *)models
{
    self.yaoyueList = [[NSMutableArray alloc] initWithArray:models];
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    if (self.leftButton.superview) {
        [self.leftButton removeFromSuperview];
    }
    if (self.rightButton.superview) {
        [self.rightButton removeFromSuperview];
    }
    if (self.createButton.superview) {
        [self.createButton removeFromSuperview];
    }
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"userId == %d", [UserManager shareManager].user.cid];
    NSArray * tempArray = [models filteredArrayUsingPredicate:predicate];
    
    self.leftButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [DDViewFactoryTool cornerRadius:60 * scale withView:self.leftButton];
    self.leftButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.leftButton.layer.borderWidth = 3 * scale;
    
    self.rightButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [DDViewFactoryTool cornerRadius:60 * scale withView:self.rightButton];
    self.rightButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.rightButton.layer.borderWidth = 3 * scale;
    
    self.createButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [DDViewFactoryTool cornerRadius:60 * scale withView:self.createButton];
    self.createButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.createButton.layer.borderWidth = 3 * scale;
    
    if ([UserManager shareManager].user.cid == self.model.authorId) {
        if (self.WYYSelectType == 1) {
            [self.leftButton setTitle:DDLocalizedString(@"Yes") forState:UIControlStateNormal];
        }else{
            [self.leftButton setTitle:DDLocalizedString(@"DeletePhotos") forState:UIControlStateNormal];
        }
        [self addSubview:self.leftButton];
        [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(50 * scale);
            make.height.mas_equalTo(120 * scale);
            make.width.mas_equalTo(444 * scale);
            make.centerX.mas_equalTo(-kMainBoundsWidth/4.f);
        }];
        [self.leftButton addTarget:self action:@selector(removeButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.WYYSelectType == 2) {
            [self.rightButton setTitle:DDLocalizedString(@"Yes") forState:UIControlStateNormal];
        }else{
            [self.rightButton setTitle:DDLocalizedString(@"MakeCover") forState:UIControlStateNormal];
        }
        [self addSubview:self.rightButton];
        [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(50 * scale);
            make.height.mas_equalTo(120 * scale);
            make.width.mas_equalTo(444 * scale);
            make.centerX.mas_equalTo(kMainBoundsWidth/4.f);
        }];
        [self.rightButton addTarget:self action:@selector(coverButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.WYYSelectType == 3) {
            [self.createButton setTitle:DDLocalizedString(@"Yes") forState:UIControlStateNormal];
        }else{
            [self.createButton setTitle:DDLocalizedString(@"PhotoCreatePostLong") forState:UIControlStateNormal];
        }
        [self addSubview:self.createButton];
        [self.createButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.leftButton.mas_bottom).offset(60 * scale);
            make.left.mas_equalTo(60 * scale);
            make.right.mas_equalTo(-60 * scale);
            make.height.mas_equalTo(120 * scale);
        }];
        [self.createButton addTarget:self action:@selector(createButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        
        [self.mapBaseView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(350 * scale);
            make.height.mas_equalTo(.1);
        }];
    }else{
        if (tempArray.count > 0) {
            if (self.WYYSelectType == 1) {
                [self.leftButton setTitle:DDLocalizedString(@"Yes") forState:UIControlStateNormal];
            }else{
                [self.leftButton setTitle:DDLocalizedString(@"DeletePhotos") forState:UIControlStateNormal];
            }
            [self addSubview:self.leftButton];
            [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(50 * scale);
                make.height.mas_equalTo(120 * scale);
                make.width.mas_equalTo(444 * scale);
                make.centerX.mas_equalTo(-kMainBoundsWidth/4.f);
            }];
            [self.leftButton addTarget:self action:@selector(removeButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
            
            if (self.WYYSelectType == 3) {
                [self.rightButton setTitle:DDLocalizedString(@"Yes") forState:UIControlStateNormal];
            }else{
                [self.rightButton setTitle:DDLocalizedString(@"PhotoCreatePostShort") forState:UIControlStateNormal];
            }
            [self addSubview:self.rightButton];
            [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(50 * scale);
                make.height.mas_equalTo(120 * scale);
                make.width.mas_equalTo(444 * scale);
                make.centerX.mas_equalTo(kMainBoundsWidth/4.f);
            }];
            [self.rightButton addTarget:self action:@selector(createButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
            [self.mapBaseView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(170 * scale);
                make.height.mas_equalTo(.1);
            }];
        }else{
            [self.mapBaseView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(50 * scale);
                make.height.mas_equalTo(.1);
            }];
        }
    }
}

- (void)configWithYaoyueModel:(NSArray *)models
{
    self.yaoyueList = [[NSMutableArray alloc] initWithArray:models];
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    [self.yaoyueView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (!self.yaoyueView.superview) {
        [self addSubview:self.yaoyueView];
    }
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xCCCCCC);
    [self.yaoyueView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.top.mas_equalTo(59 * scale);
        make.height.mas_equalTo(2 * scale);
    }];
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentCenter];
    titleLabel.backgroundColor = UIColorFromRGB(0xEFEFF4);
    titleLabel.text = DDLocalizedString(@"Invite Friends");
    [self.yaoyueView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(550 * scale);
        make.height.mas_equalTo(72 * scale);
        make.centerY.mas_equalTo(lineView);
    }];
    CGFloat height = 0;
    if (models.count > 0) {
        
        NSInteger postID = self.model.cid;
        if (postID == 0) {
            postID = self.model.postId;
        }
        
        BOOL isAuthor = NO;
        if ([UserManager shareManager].user.cid == self.model.authorId) {
            isAuthor = YES;
        }
        
        NSInteger agreeCount = 0;
        for (NSInteger i = 0; i < self.yaoyueList.count; i++) {
            UserYaoYueBlockModel * model = [self.yaoyueList objectAtIndex:i];
            model.postID = postID;
            DTieYaoyueBlockView * view = [[DTieYaoyueBlockView alloc] initWithBlockModel:model isAuthor:isAuthor];
            
            __weak typeof(self) weakSelf = self;
            view.removeDidClicked = ^(UserYaoYueBlockModel *blockModel) {
                [weakSelf removeYaoyueBlockModel:blockModel];
            };
            [self.yaoyueView addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo((i+1) * 144 * scale);
                make.left.right.mas_equalTo(0);
                make.height.mas_equalTo(144 * scale);
            }];
            
            if (model.subtype == 1) {
                agreeCount++;
            }
        }
        
        titleLabel.text = [NSString stringWithFormat:@"邀请好友（已有%ld人确定参加）", agreeCount];
        
        NSInteger count = models.count + 1;
        height = 144 * scale * count + 60 * scale;
        
        UIButton * handleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
        [self.yaoyueView addSubview:handleButton];
        height = height + 144 * scale;
        [handleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(60 * scale);
            make.right.mas_equalTo(-60 * scale);
            make.bottom.mas_equalTo(-50 * scale);
            make.height.mas_equalTo(120 * scale);
        }];
        [handleButton setBackgroundColor:UIColorFromRGB(0xDB6283)];
        [DDViewFactoryTool cornerRadius:60 * scale withView:handleButton];
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"userId == %d", [UserManager shareManager].user.cid];
        NSArray * tempArray = [models filteredArrayUsingPredicate:predicate];
        if ([UserManager shareManager].user.cid == self.model.authorId) {
            
            [handleButton setTitle:@"拉入DeeDao好友" forState:UIControlStateNormal];
            [handleButton addTarget:self action:@selector(addButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
            
        }else if (tempArray.count == 0) {
            
            if (self.model.wyyPermission == 0) {
                [handleButton setTitle:@"参与入口已关闭" forState:UIControlStateNormal];
                [handleButton setBackgroundColor:UIColorFromRGB(0xDDDDDD)];
            }else{
                [handleButton setTitle:@"我也要加入聚会" forState:UIControlStateNormal];
                [handleButton addTarget:self action:@selector(addButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
            }
            
        }else{
            
            [handleButton setTitle:@"退出参与" forState:UIControlStateNormal];
            [handleButton addTarget:self action:@selector(addButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
            
        }
        
        [self.yaoyueView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(60 * scale);
            make.right.mas_equalTo(-60 * scale);
            make.top.mas_equalTo(50 * scale);
            make.height.mas_equalTo(height);
        }];
        [self.mapBaseView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(height + 144 * scale);
        }];
    }else if (models){
        
        UIButton * handleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"我也要加入聚会"];
        [self.yaoyueView addSubview:handleButton];
        [handleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(60 * scale);
            make.right.mas_equalTo(-60 * scale);
            make.bottom.mas_equalTo(-50 * scale);
            make.height.mas_equalTo(120 * scale);
        }];
        [handleButton setBackgroundColor:UIColorFromRGB(0xDB6283)];
        [DDViewFactoryTool cornerRadius:60 * scale withView:handleButton];
        [handleButton addTarget:self action:@selector(addButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        
        NSInteger postID = self.model.cid;
        if (postID == 0) {
            postID = self.model.postId;
        }
        
        height = 144 * scale * 2 + 60 * scale;
        
        [self.yaoyueView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(60 * scale);
            make.right.mas_equalTo(-60 * scale);
            make.top.mas_equalTo(50 * scale);
            make.height.mas_equalTo(height);
        }];
        [self.mapBaseView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(height + 144 * scale);
        }];
    }
    
    if ([UserManager shareManager].user.cid == self.model.authorId) {
        UILabel * addTipLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
        addTipLabel.text = @"允许新参与者主动加入";
        [self addSubview:addTipLabel];
        [addTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(45 * scale);
            make.left.mas_equalTo(60 * scale);
            make.height.mas_equalTo(120 * scale);
        }];
        
        self.addUserSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        self.addUserSwitch.onTintColor = UIColorFromRGB(0xDB6283);
        [self.addUserSwitch addTarget:self action:@selector(switcDidChange:) forControlEvents:UIControlEventValueChanged];
        
        if (self.model.wyyPermission == 1) {
            self.addUserSwitch.on = YES;
        }else if(self.model.wyyPermission == 0) {
            self.addUserSwitch.on = NO;
        }
        
        [self addSubview:self.addUserSwitch];
        [self.addUserSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(addTipLabel);
            make.right.mas_equalTo(-60 * scale);
            make.width.mas_equalTo(51);
            make.height.mas_equalTo(31);
        }];
        
        UIView * addLineView = [[UIView alloc] initWithFrame:CGRectZero];
        addLineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
        [self addSubview:addLineView];
        [addLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(60 * scale);
            make.right.mas_equalTo(-60 * scale);
            make.height.mas_equalTo(3 * scale);
            make.top.mas_equalTo(addTipLabel.mas_bottom);
        }];
        
        [self.yaoyueView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(50 * scale + 144 * scale);
        }];
        
        [self.mapBaseView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(height + 144 * scale + 144 * scale);
        }];
    }
}

- (void)removeYaoyueBlockModel:(UserYaoYueBlockModel *)model
{
    RDAlertView * alertView = [[RDAlertView alloc] initWithTitle:DDLocalizedString(@"Information") message:[NSString stringWithFormat:@"%@  即将被您从参与者中移除，请确认。", model.nickname]];
    RDAlertAction * action1 = [[RDAlertAction alloc] initWithTitle:DDLocalizedString(@"Cancel") handler:^{
        
    } bold:NO];
    
    RDAlertAction * action2 = [[RDAlertAction alloc] initWithTitle:DDLocalizedString(@"Yes") handler:^{
        
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:self];
        ChangeWYYStatusRequest * request =  [[ChangeWYYStatusRequest alloc] initRemoveSelfWithPostID:model.postID userID:model.userId];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [hud hideAnimated:YES];
            if (self.addButtonDidClickedHandle) {
                self.addButtonDidClickedHandle();
            }
            
            [self.yaoyueList removeObject:model];
            [self configWithYaoyueModel:self.yaoyueList];
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [hud hideAnimated:YES];
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
            [hud hideAnimated:YES];
            
        }];
        
    } bold:NO];
    
    [alertView addActions:@[action1, action2]];
    [alertView show];
}

- (void)switcDidChange:(UISwitch *)sender
{
    [SelectWYYBlockRequest cancelRequest];
    SelectWYYBlockRequest * request =  [[SelectWYYBlockRequest alloc] initAddUserSwitchWithPostID:self.model.cid status:sender.isOn];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (sender.isOn) {
            self.model.postClassification = 1;
        }else{
            self.model.postClassification = 0;
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)createDTieReadHandleView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.mapBaseView = [[UIView alloc] initWithFrame:CGRectZero];
    self.mapBaseView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self addSubview:self.mapBaseView];
    [self.mapBaseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(50 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(450 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    self.mapBaseView.layer.cornerRadius = 24 * scale;
    self.mapBaseView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    self.mapBaseView.layer.shadowOpacity = .3f;
    self.mapBaseView.layer.shadowRadius = 24 * scale;
    self.mapBaseView.layer.shadowOffset = CGSizeMake(0, 12 * scale);
    
    UITapGestureRecognizer * mapTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationButtonClicked)];
    [self.mapBaseView addGestureRecognizer:mapTap];
    
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
    [self.mapView updateLocationViewWithParam:userlocationStyle];
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = BMKUserTrackingModeNone;
    self.mapView.gesturesEnabled = NO;
    self.mapView.buildingsEnabled = NO;
    self.mapView.showMapPoi = NO;
    [self.mapView updateLocationData:[DDLocationManager shareManager].userLocation];
    
    [self.mapBaseView addSubview:self.mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
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
    
    self.yaoyueView = [[UIView alloc] initWithFrame:CGRectZero];
    self.yaoyueView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self addSubview:self.yaoyueView];
    self.yaoyueView.layer.cornerRadius = 24 * scale;
    self.yaoyueView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    self.yaoyueView.layer.shadowOpacity = .3f;
    self.yaoyueView.layer.shadowRadius = 24 * scale;
    self.yaoyueView.layer.shadowOffset = CGSizeMake(0, 12 * scale);
    
    self.readLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.readLabel.text = DDLocalizedString(@"# of readers");
    [self addSubview:self.readLabel];
    [self.readLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mapBaseView.mas_bottom).offset(90 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    self.readButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0XDB6283) title:DDLocalizedString(@"See Read Map")];
    [self addSubview:self.readButton];
    [self.readButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.readLabel);
        make.width.mas_equalTo(260 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    [self.readButton addTarget:self action:@selector(readButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [DDViewFactoryTool cornerRadius:12 * scale withView:self.readButton];
    self.readButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.readButton.layer.borderWidth = 3 * scale;
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.readLabel.mas_bottom).offset(70 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    self.handleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0XDB6283) title:DDLocalizedString(@"Security Settings")];
    [self addSubview:self.handleButton];
    [self.handleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.timeLabel);
        make.width.mas_equalTo(260 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    [self.handleButton addTarget:self action:@selector(handleButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [DDViewFactoryTool cornerRadius:12 * scale withView:self.handleButton];
    self.handleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.handleButton.layer.borderWidth = 3 * scale;
    
    self.jubaoButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0XDB6283) title:[NSString stringWithFormat:@" %@", DDLocalizedString(@"Report")]];
    [self.jubaoButton setImage:[UIImage imageNamed:@"jubaoyes"] forState:UIControlStateNormal];
    [self addSubview:self.jubaoButton];
    [self.jubaoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.timeLabel);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    [self.jubaoButton addTarget:self action:@selector(handleButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    
    self.shoucangButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xDB6282) title:@""];
    [self.shoucangButton setImage:[UIImage imageNamed:@"shoucangno"] forState:UIControlStateNormal];
//    self.shoucangButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.shoucangButton];
    [self.shoucangButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(45 * scale);
        make.centerX.mas_equalTo(-kMainBoundsWidth / 4);
        make.height.mas_equalTo(120 * scale);
//        make.width.mas_equalTo(200 * scale);
    }];
    [self.shoucangButton addTarget:self action:@selector(shoucangButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.shoucangNumberLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [self addSubview:self.shoucangNumberLabel];
    [self.shoucangNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(40 * scale);
        make.left.mas_equalTo(self.shoucangButton.mas_right).offset(0 * scale);
        make.width.mas_equalTo(100 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    
    self.yaoyueButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xDB6282) title:@""];
    [self.yaoyueButton setImage:[UIImage imageNamed:@"yaoyueno"] forState:UIControlStateNormal];
    [self addSubview:self.yaoyueButton];
    [self.yaoyueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(45 * scale);
        make.centerX.mas_equalTo(kMainBoundsWidth / 4);
        make.height.mas_equalTo(120 * scale);
    }];
    [self.yaoyueButton addTarget:self action:@selector(yaoyueButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.yaoyueNumberLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [self addSubview:self.yaoyueNumberLabel];
    [self.yaoyueNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(40 * scale);
        make.left.mas_equalTo(self.yaoyueButton.mas_right).offset(0 * scale);
        make.width.mas_equalTo(120 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    
    self.yaoyueNumberShowLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentCenter];
    self.yaoyueNumberShowLabel.backgroundColor = UIColorFromRGB(0xDB6283);
    [self.yaoyueNumberLabel addSubview:self.yaoyueNumberShowLabel];
    [self.yaoyueNumberShowLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(30 * scale);
        make.width.mas_equalTo(42 * scale); 
        make.height.mas_equalTo(42 * scale);
    }];
    [DDViewFactoryTool cornerRadius:21 * scale withView:self.yaoyueNumberShowLabel];
    self.yaoyueNumberShowLabel.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.yaoyueNumberShowLabel.layer.borderWidth = 2 * scale;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDidClicked)];
    self.yaoyueNumberLabel.userInteractionEnabled = YES;
    [self.yaoyueNumberLabel addGestureRecognizer:tap];
    
    UIButton * backHomeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"BackList")];
    [DDViewFactoryTool cornerRadius:60 * scale withView:backHomeButton];
    backHomeButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    backHomeButton.layer.borderWidth = 3 * scale;
    [self addSubview:backHomeButton];
    [backHomeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(-kMainBoundsWidth/4.f);
        make.height.mas_equalTo(120 * scale);
        make.width.mas_equalTo(444 * scale);
        make.bottom.mas_equalTo(-40 * scale);
    }];
    [backHomeButton addTarget:self action:@selector(backHomeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * shareButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"SendWXFriend")];
    [DDViewFactoryTool cornerRadius:60 * scale withView:shareButton];
    shareButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    shareButton.layer.borderWidth = 3 * scale;
    [self addSubview:shareButton];
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(kMainBoundsWidth/4.f);
        make.height.mas_equalTo(120 * scale);
        make.width.mas_equalTo(444 * scale);
        make.bottom.mas_equalTo(-40 * scale);
    }];
    [shareButton addTarget:self action:@selector(shareButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    BMKAnnotationView * view = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BMKAnnotationView"];
    view.annotation = annotation;
    view.image = [UIImage imageNamed:@"location"];
    view.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:[UIView new]];
    
    return view;
}

- (void)mapViewDidFinishLoading:(BMKMapView *)mapView
{
    BMKCoordinateRegion viewRegion;
    
    if ([DDLocationManager shareManager].userLocation.location) {
        
        CLLocationDegrees lng = fabs([DDLocationManager shareManager].userLocation.location.coordinate.longitude - self.model.sceneAddressLng);
        CLLocationDegrees lat = fabs([DDLocationManager shareManager].userLocation.location.coordinate.latitude - self.model.sceneAddressLat);
        
        CLLocationDegrees centerLat;
        CLLocationDegrees centerLng;
        if ([DDLocationManager shareManager].userLocation.location.coordinate.longitude > self.model.sceneAddressLng) {
            centerLng = self.model.sceneAddressLng + lng / 2.f;
        }else{
            centerLng = [DDLocationManager shareManager].userLocation.location.coordinate.longitude + lng / 2.f;
        }
        
        if ([DDLocationManager shareManager].userLocation.location.coordinate.latitude > self.model.sceneAddressLat) {
            centerLat = self.model.sceneAddressLat + lat / 2.f;
        }else{
            centerLat = [DDLocationManager shareManager].userLocation.location.coordinate.latitude + lat / 2.f;
        }
        
        if (lng < 0.01) {
            lng = 0.01;
        }
        if (lat < 0.01) {
            lat = 0.01;
        }
        
        viewRegion = BMKCoordinateRegionMake(CLLocationCoordinate2DMake(centerLat, centerLng), BMKCoordinateSpanMake(lat * 1.5, lng * 1.5));
    }else{
        viewRegion = BMKCoordinateRegionMake(CLLocationCoordinate2DMake(self.model.sceneAddressLat, self.model.sceneAddressLng), BMKCoordinateSpanMake(.01, .01));
    }
    
    [self.mapView setRegion:viewRegion animated:YES];
}

- (void)locationButtonClicked
{
    if (self.locationButtonDidClicked) {
        self.locationButtonDidClicked();
    }
}

- (void)backHomeButtonDidClicked
{
    if (self.backButtonDidClicked) {
        self.backButtonDidClicked();
    }
}

- (void)readButtonDidTouchUpInside
{
    NSInteger postID = self.model.cid;
    if (postID == 0) {
        postID = self.model.postId;
    }
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:[UIApplication sharedApplication].keyWindow];
    
    SelectPostSeeRequest * request = [[SelectPostSeeRequest alloc] initWithPostID:postID];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                NSMutableArray * dataSource = [[NSMutableArray alloc] init];
                for (NSDictionary * info in data) {
                    DTieSeeModel * model = [DTieSeeModel mj_objectWithKeyValues:info];
                    [dataSource addObject:model];
                }
                DTieSeeShareViewController * share = [[DTieSeeShareViewController alloc] initWithSource:dataSource model:self.model];
                DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                UINavigationController * na = (UINavigationController *)lg.rootViewController;
                [na pushViewController:share animated:YES];
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"获取阅读信息失败" inView:[UIApplication sharedApplication].keyWindow];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:[UIApplication sharedApplication].keyWindow];
        
    }];
}

- (void)tapDidClicked
{
    DDYaoYueViewController * yaoyue = [[DDYaoYueViewController alloc] initWithDtieModel:self.model];
    
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    [na pushViewController:yaoyue animated:YES];
}

- (void)reloadStatus
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    if (self.model.wyyFlg) {
        [self.yaoyueButton setTitle:@"" forState:UIControlStateNormal];
        [self.yaoyueButton setImage:[UIImage imageNamed:@"yaoyueyes"] forState:UIControlStateNormal];
        self.yaoyueButton.alpha = .5f;
    }else{
        [self.yaoyueButton setTitle:@"" forState:UIControlStateNormal];
        [self.yaoyueButton setImage:[UIImage imageNamed:@"yaoyueno"] forState:UIControlStateNormal];
        self.yaoyueButton.alpha = 1.f;
    }
    
    if (self.model.wyyCount <= 0) {
        self.yaoyueNumberShowLabel.text = @"0";
        [self.yaoyueNumberShowLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(42 * scale);
        }];
    }else if(self.model.wyyCount < 100){
        self.yaoyueNumberShowLabel.text = [NSString stringWithFormat:@"%ld", self.model.wyyCount];
        
        if (self.model.wyyCount < 10) {
            [self.yaoyueNumberShowLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(42 * scale);
            }];
        }else {
            [self.yaoyueNumberShowLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(80 * scale);
            }];
        }
        
    }else{
        self.yaoyueNumberShowLabel.text = @"99+";
        [self.yaoyueNumberShowLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(80 * scale);
        }];
    }
    
    if (self.model.authorId == [UserManager shareManager].user.cid) {
        
        self.shoucangButton.alpha = 1.f;
        
        [self.shoucangButton setImage:[UIImage imageNamed:@"zuozheshoucang"] forState:UIControlStateNormal];
        
        if (self.model.collectCount <= 0) {
            self.shoucangNumberLabel.text = @" 0";
        }else if(self.model.collectCount < 100){
            self.shoucangNumberLabel.text = [NSString stringWithFormat:@" %ld", self.model.collectCount];
        }else{
            self.shoucangNumberLabel.text = @" 99+";
        }
        self.shoucangNumberLabel.hidden = NO;
        
    }else{
        
        self.shoucangNumberLabel.hidden = YES;
        
        if (self.model.collectFlg) {
            [self.shoucangButton setTitle:@"" forState:UIControlStateNormal];
            [self.shoucangButton setImage:[UIImage imageNamed:@"shoucangyes"] forState:UIControlStateNormal];
            self.shoucangButton.alpha = .5f;
        }else{
            [self.shoucangButton setTitle:@"" forState:UIControlStateNormal];
            [self.shoucangButton setImage:[UIImage imageNamed:@"shoucangno"] forState:UIControlStateNormal];
            self.shoucangButton.alpha = 1.f;
        }
    }
}

- (void)handleButtonDidTouchUpInside
{
    if (self.handleButtonDidClicked) {
        self.handleButtonDidClicked();
    }
}

- (void)shareButtonDidTouchUpInside
{
    if (self.shareButtonDidClicked) {
        self.shareButtonDidClicked();
    }
}

- (void)removeButtonDidTouchUpInside
{
    if (self.WYYSelectType == 1) {
        self.WYYSelectType = 0;
    }else{
        self.WYYSelectType = 1;
    }
    
    [self configWithWacthPhotos:self.yaoyueList];
    if (self.selectButtonDidClicked) {
        self.selectButtonDidClicked(self.WYYSelectType);
    }
}

- (void)coverButtonDidTouchUpInside
{
    if (self.WYYSelectType == 2) {
        self.WYYSelectType = 0;
    }else{
        self.WYYSelectType = 2;
    }
    
    [self configWithWacthPhotos:self.yaoyueList];
    if (self.selectButtonDidClicked) {
        self.selectButtonDidClicked(self.WYYSelectType);
    }
}

- (void)createButtonDidTouchUpInside
{
    if (self.WYYSelectType == 3) {
        self.WYYSelectType = 0;
    }else{
        self.WYYSelectType = 3;
    }
    
    [self configWithWacthPhotos:self.yaoyueList];
    if (self.selectButtonDidClicked) {
        self.selectButtonDidClicked(self.WYYSelectType);
    }
}

- (void)addButtonDidClicked
{
    NSInteger postID = self.model.cid;
    if (postID == 0) {
        postID = self.model.postId;
    }
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"userId == %d", [UserManager shareManager].user.cid];
    NSArray * tempArray = [self.yaoyueList filteredArrayUsingPredicate:predicate];
    
    if ([UserManager shareManager].user.cid == self.model.authorId) {
        
        SecurityFriendController * friend = [[SecurityFriendController alloc] initMulSelectWithDataDict:[NSDictionary new] nameKeys:[NSArray new] selectModels:[NSMutableArray new]];
        friend.delegate = self;
        
        DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        UINavigationController * na = (UINavigationController *)lg.rootViewController;
        
        [na pushViewController:friend animated:YES];
        
        
    }else if (tempArray.count == 0) {
        
        ChangeWYYStatusRequest * request =  [[ChangeWYYStatusRequest alloc] initWithPostID:postID subType:1];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            if (self.addButtonDidClickedHandle) {
                self.addButtonDidClickedHandle();
            }
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
        }];
        
    }else{
        
        RDAlertView * alertView = [[RDAlertView alloc] initWithTitle:DDLocalizedString(@"Information") message:[NSString stringWithFormat:@"您将退出参与该次活动，请确认。"]];
        RDAlertAction * action1 = [[RDAlertAction alloc] initWithTitle:DDLocalizedString(@"Cancel") handler:^{
            
        } bold:NO];
        
        RDAlertAction * action2 = [[RDAlertAction alloc] initWithTitle:DDLocalizedString(@"Yes") handler:^{
            
            ChangeWYYStatusRequest * request =  [[ChangeWYYStatusRequest alloc] initRemoveSelfWithPostID:postID userID:[UserManager shareManager].user.cid];
            [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                if (self.addButtonDidClickedHandle) {
                    self.addButtonDidClickedHandle();
                }
            } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
            } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
                
            }];
            
        } bold:NO];
        
        [alertView addActions:@[action1, action2]];
        [alertView show];
    }
}

- (void)friendDidMulSelectComplete:(NSArray *)selectArray
{
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    [na popViewControllerAnimated:YES];
    
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for (UserModel * model in selectArray) {
        [array addObject:@(model.cid)];
    }
    AddUserToWYYRequest * request = [[AddUserToWYYRequest alloc] initWithUserList:array postId:self.model.cid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (self.addButtonDidClickedHandle) {
            self.addButtonDidClickedHandle();
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)shoucangButtonDidClicked
{
    DTieModel * model = self.model;
    
    if (model.authorId == [UserManager shareManager].user.cid) {
        //        [MBProgressHUD showTextHUDWithText:@"无法对自己的帖子进行该操作" inView:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
    self.shoucangButton.enabled = NO;
    if (model.collectFlg) {
        
        DTieCancleCollectRequest * request = [[DTieCancleCollectRequest alloc] initWithPostID:model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            model.collectFlg = 0;
            model.collectCount--;
            [self reloadStatus];
            
            self.shoucangButton.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.shoucangButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.shoucangButton.enabled = YES;
        }];
        
    }else{
        DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:model.cid type:0 subType:0 remark:@""];
        
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            model.collectFlg = 1;
            model.collectCount++;
            [self reloadStatus];
            
            self.shoucangButton.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.shoucangButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.shoucangButton.enabled = YES;
        }];
    }
}

- (void)yaoyueButtonDidClicked
{
    DTieModel * model = self.model;
    
    self.yaoyueButton.enabled = NO;
    if (model.wyyFlg) {
        
        DTieCancleWYYRequest * request = [[DTieCancleWYYRequest alloc] initWithPostID:model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            model.wyyFlg = 0;
            model.wyyCount--;
            [self reloadStatus];
            
            self.yaoyueButton.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.yaoyueButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.yaoyueButton.enabled = YES;
        }];
        
    }else{
        DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:model.cid type:1 subType:0 remark:@""];
        
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            model.wyyFlg = 1;
            model.wyyCount++;
            [MBProgressHUD showTextHUDWithText:@"您刚标识了您想约这里。约点越多，被约越多。Deedao好友越多，被约越多。记得常去约饭约玩活地图 组饭局哦。" inView:[UIApplication sharedApplication].keyWindow];
            
            [self reloadStatus];
            
            self.yaoyueButton.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.yaoyueButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.yaoyueButton.enabled = YES;
        }];
    }
}

@end
