//
//  NotificationCollectionViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/13.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "NotificationCollectionViewCell.h"
#import <Masonry.h>
#import "DDViewFactoryTool.h"
#import "DDTool.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import "DDLocationManager.h"
#import <UIImageView+WebCache.h>
#import "NotificationTableViewCell.h"
#import "SelectNotificationDeatilRequest.h"
#import "MBProgressHUD+DDHUD.h"
#import "DTieDetailRequest.h"
#import "DTieNewDetailViewController.h"
#import "DDLGSideViewController.h"

@interface NotificationCollectionViewCell () <UITableViewDelegate, UITableViewDataSource, BMKMapViewDelegate>

@property (nonatomic, strong) NotificationHistoryModel * model;

@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UILabel * titleLabel;

@property (nonatomic, strong) BMKMapView * mapView;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSArray * dataSource;

@end

@implementation NotificationCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createNotificationCell];
    }
    return self;
}

- (void)configWithModel:(NotificationHistoryModel *)model
{
    [self.tableView setContentOffset:CGPointZero];
    self.model = model;
    self.dataSource = model.postList;
    if (!model.postList) {
        [self requestPostListWith:model];
    }
    [self.mapView setRegion:BMKCoordinateRegionMake(CLLocationCoordinate2DMake(model.remindLat, model.remindLng), BMKCoordinateSpanMake(.015, .015)) animated:YES];
    self.timeLabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:model.remindTime];
    [self.tableView reloadData];
    [self refreshAnnotion];
}

- (void)requestPostListWith:(NotificationHistoryModel *)model
{
    SelectNotificationDeatilRequest * request = [[SelectNotificationDeatilRequest alloc] initWithNotificationID:model.cid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                model.postList = [NSArray arrayWithArray:[DTieModel mj_objectArrayWithKeyValuesArray:data]];
            }
        }
        if (self.model == model) {
            self.dataSource = self.model.postList;
            [self.tableView reloadData];
            [self refreshAnnotion];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)refreshAnnotion
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    NSMutableArray * tempPointArray = [[NSMutableArray alloc] init];
    for (DTieModel * model in self.dataSource) {
        BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake(model.sceneAddressLat, model.sceneAddressLng);
        [tempPointArray addObject:annotation];
    }
    [self.mapView addAnnotations:tempPointArray];
}

- (void)createNotificationCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * BGView = [[UIView alloc] initWithFrame:CGRectZero];
    BGView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:BGView];
    BGView.layer.cornerRadius = 24 * scale;
    BGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    BGView.layer.shadowOpacity = .3f;
    BGView.layer.shadowRadius = 8 * scale;
    BGView.layer.shadowOffset = CGSizeMake(0, 8 * scale);
    
    [BGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(90 * scale);
        make.left.mas_equalTo(20 * scale);
        make.right.mas_equalTo(-20 * scale);
        make.bottom.mas_equalTo(-20 * scale);
    }];
    
    UIView * baseView = [[UIView alloc] initWithFrame:CGRectZero];
    [BGView addSubview:baseView];
    [baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:baseView];
    
    UIView * titleView = [[UIView alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [baseView addSubview:titleView];
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangMedium(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.timeLabel.text = [DDTool getCurrentTimeWithFormat:@"yyyy年MM月dd日 HH:mm"];
    [titleView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(25 * scale);
        make.left.mas_equalTo(45 * scale);
        make.right.mas_equalTo(-45 * scale);
    }];
    
    self.titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.titleLabel.text = @"D帖的POI";
    [titleView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom);
        make.left.right.mas_equalTo(self.timeLabel);
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 500 * scale;
    [self.tableView registerClass:[NotificationTableViewCell class] forCellReuseIdentifier:@"NotificationTableViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [baseView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleView.mas_bottom);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    self.mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth - 300 * scale, 360 * scale)];
    
    self.mapView.showsUserLocation = NO;
    self.mapView.gesturesEnabled = NO;
    self.mapView.buildingsEnabled = NO;
    self.mapView.showMapPoi = NO;
    self.mapView.delegate = self;
    
    UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"location"]];
    [self.mapView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(90 * scale);
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
    
//    UIButton * backLocationButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
//    [backLocationButton setImage:[UIImage imageNamed:@"backLocation"] forState:UIControlStateNormal];
//    [backLocationButton addTarget:self action:@selector(backLocationButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.mapView addSubview:backLocationButton];
//    [backLocationButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(40 * scale);
//        make.bottom.mas_equalTo(-30 * scale);
//        make.width.height.mas_equalTo(100 * scale);
//    }];
    
    self.tableView.tableHeaderView = self.mapView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationTableViewCell" forIndexPath:indexPath];
    
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.row];
    [cell configWithModel:model];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:self];
    
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.row];
    
    NSInteger postID = model.postId;
    if (postID == 0) {
        postID = self.model.cid;
    }
    
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:postID type:4 start:0 length:10];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        
        if (KIsDictionary(response)) {
            
            NSInteger code = [[response objectForKey:@"status"] integerValue];
            if (code == 4002) {
                [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"PageHasDelete") inView:self];
                return;
            }
            
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                
                if (dtieModel.deleteFlg == 1) {
                    [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"PageHasDelete") inView:self];
                    return;
                }
                
                DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initWithDTie:dtieModel];
                DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                UINavigationController * na = (UINavigationController *)lg.rootViewController;
                [na pushViewController:detail animated:YES];
            }
        }
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
    }];
}

- (void)backLocationButtonDidClicked
{
    BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake([DDLocationManager shareManager].userLocation.location.coordinate, self.mapView.region.span);
    BMKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
}

- (void)mapViewDidFinishLoading:(BMKMapView *)mapView
{
    if (self.mapView.region.span.latitudeDelta > 10 && self.model) {
        [self.mapView setRegion:BMKCoordinateRegionMake(CLLocationCoordinate2DMake(self.model.remindLat, self.model.remindLng), BMKCoordinateSpanMake(.015, .015)) animated:YES];
    }
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

- (void)dealloc
{
    self.mapView.delegate = nil;
}

@end
