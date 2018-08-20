//
//  DDYaoYueViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/12.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDYaoYueViewController.h"
#import "DDLocationManager.h"
#import "DTiePOIRequest.h"
#import "DTieHeaderLogoCell.h"
#import "CollectionLineTitleView.h"
#import "DTieNewDetailViewController.h"
#import "MBProgressHUD+DDHUD.h"
#import "DTieDetailRequest.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import "DDShareYaoYueViewController.h"
#import "DTieReadCommentHeaderView.h"
#import "YaoYueUserTableViewCell.h"
#import <AFHTTPSessionManager.h>
#import "UserYaoYueModel.h"
#import "WeChatManager.h"
#import <UIImageView+WebCache.h>

#import "UserManager.h"
#import "QNDDUploadManager.h"
#import "CreateDTieRequest.h"
#import "DDTool.h"
#import "AddUserToWYYRequest.h"

@interface DDYaoYueViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, BMKMapViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, strong) BMKMapView * mapView;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * friendDataSource;
@property (nonatomic, strong) NSMutableArray * selectSource;

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSArray * titleSource;
@property (nonatomic, strong) NSMutableArray * DTieDataSource;

@property (nonatomic, strong) UIButton * yaoyueButton;
@property (nonatomic, strong) UIButton * aboutButton;
@property (nonatomic, assign) NSInteger selectIndex;

@end

@implementation DDYaoYueViewController

- (instancetype)initWithDtieModel:(DTieModel *)model
{
    if (self = [super init]) {
        self.friendDataSource = [[NSMutableArray alloc] init];
        self.DTieDataSource = [[NSMutableArray alloc] init];
        self.selectSource = [[NSMutableArray alloc] init];
        [self.selectSource addObject:[UserManager shareManager].user];
        self.titleSource = @[@"", @"我和好友", @"博主", @"我所关注人", @"部分公开"];
        self.model = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
    [self createTopView];
    
    [self setUpDatas];
}

- (void)setUpDatas
{
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSInteger postID = self.model.postId;
    if (postID == 0) {
        postID = self.model.cid;
    }
    
    NSString * url = [NSString stringWithFormat:@"%@/post/collection/selectWYYFriendsCount", HOSTURL];
    [manager POST:url parameters:@{@"postId":@(postID)} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * respones = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        
        if (KIsDictionary(respones)) {
            [self.friendDataSource removeAllObjects];
            [self.selectSource removeAllObjects];
            [self.selectSource addObject:[UserManager shareManager].user];
            NSArray * data = [respones objectForKey:@"data"];
            if (KIsArray(data)) {
                for (NSDictionary * dict in data) {
                    UserYaoYueModel * model = [UserYaoYueModel mj_objectWithKeyValues:dict];
                    [self.friendDataSource addObject:model];
                }
                [self.tableView reloadData];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
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
                
                [self.DTieDataSource addObject:myAndFriend];
                [self.DTieDataSource addObject:blogger];
                [self.DTieDataSource addObject:myConcern];
                [self.DTieDataSource addObject:stranger];
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
    
    UIButton * backLocationButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [backLocationButton setImage:[UIImage imageNamed:@"backLocation"] forState:UIControlStateNormal];
    [backLocationButton addTarget:self action:@selector(backLocationButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:backLocationButton];
    [backLocationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40 * scale);
        make.bottom.mas_equalTo(-30 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    UIView * tabView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:tabView];
    tabView.backgroundColor = [UIColor whiteColor];
    [tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(locationView.mas_bottom);
        make.height.mas_equalTo(120 * scale);
    }];
    
    UIView * tabLineView = [[UIView alloc] initWithFrame:CGRectZero];
    tabLineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [tabView addSubview:tabLineView];
    [tabLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.height.mas_equalTo(72 * scale);
        make.width.mas_equalTo(3 * scale);
    }];
    self.yaoyueButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"要约列表"];
    [tabView addSubview:self.yaoyueButton];
    [self.yaoyueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(0);
        make.right.mas_equalTo(tabLineView.mas_left);
    }];
    
    self.aboutButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"相关D贴"];
    [tabView addSubview:self.aboutButton];
    [self.aboutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(0);
        make.left.mas_equalTo(tabLineView.mas_right);
    }];
    self.aboutButton.alpha = .5f;
    [self.yaoyueButton addTarget:self action:@selector(tabButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.aboutButton addTarget:self action:@selector(tabButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 324 * scale, 0);
    self.tableView.rowHeight = 190 * scale;
    [self.tableView registerClass:[YaoYueUserTableViewCell class] forCellReuseIdentifier:@"YaoYueUserTableViewCell"];
    [self.tableView registerClass:[DTieReadCommentHeaderView class] forHeaderFooterViewReuseIdentifier:@"DTieReadCommentHeaderView"];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"UITableViewHeaderFooterView"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tabView.mas_bottom);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    UIView * bottomHandleView = [[UIView alloc] initWithFrame:CGRectZero];
    bottomHandleView.backgroundColor = [UIColorFromRGB(0xFFFFFF) colorWithAlphaComponent:.7f];
    [self.view addSubview:bottomHandleView];
    [bottomHandleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(324 * scale);
    }];
    
    UIButton * handleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:@"分享到好友或群"];
    [DDViewFactoryTool cornerRadius:24 * scale withView:handleButton];
    handleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    handleButton.layer.borderWidth = 3 * scale;
    [bottomHandleView addSubview:handleButton];
    [handleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(144 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.centerY.mas_equalTo(0);
    }];
    [handleButton addTarget:self action:@selector(handleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kMainBoundsWidth / 2, 360 * scale);
    layout.headerReferenceSize = CGSizeMake(kMainBoundsWidth, 70 * scale);
    layout.minimumLineSpacing = 30 * scale;
    layout.minimumInteritemSpacing = 0;

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerClass:[DTieHeaderLogoCell class] forCellWithReuseIdentifier:@"DTieHeaderLogoCell"];
    [self.collectionView registerClass:[CollectionLineTitleView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionLineTitleView"];
    self.collectionView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tabView.mas_bottom);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.collectionView.hidden = YES;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friendDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YaoYueUserTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"YaoYueUserTableViewCell" forIndexPath:indexPath];
    
    UserYaoYueModel * model = [self.friendDataSource objectAtIndex:indexPath.row];
    
    [cell configWithModel:model];
    
    [cell configSelectStatus:[self.selectSource containsObject:model]];
    
    __weak typeof(self) weakSelf = self;
    cell.yiyueButtonHandle = ^(UserYaoYueModel *model) {
        if ([weakSelf.selectSource containsObject:model]) {
            [weakSelf.selectSource removeObject:model];
        }
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    };
    cell.yaoyueButtonHandle = ^(UserYaoYueModel *model) {
        if (![weakSelf.selectSource containsObject:model]) {
            [weakSelf.selectSource addObject:model];
        }
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    };
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UITableViewHeaderFooterView * view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"UITableViewHeaderFooterView"];
        
        return view;
    }
    
    DTieReadCommentHeaderView * view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DTieReadCommentHeaderView"];
    
    [view configWithTitle:@"目标附近要约的好友"];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    if (section == 0) {
        return .1f;
    }
    return 130 * scale;
}

#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.DTieDataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray * data = [self.DTieDataSource objectAtIndex:section];
    return data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * data = [self.DTieDataSource objectAtIndex:indexPath.section];
    DTieModel * model = [data objectAtIndex:indexPath.row];
    
    DTieHeaderLogoCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DTieHeaderLogoCell" forIndexPath:indexPath];
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
    NSArray * data = [self.DTieDataSource objectAtIndex:indexPath.section];
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

- (void)handleButtonDidClicked
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:self.view];
    
    //获取参数配置
    NSString * address = self.model.sceneAddress;
    
    NSString * building = self.model.sceneBuilding;
    if (isEmptyString(building)) {
        building = address;
    }
    
    double lon = self.model.sceneAddressLng;
    double lat = self.model.sceneAddressLat;
    
    NSInteger postId = 0;
    if (self.model) {
        postId = self.model.postId;
        if (postId == 0) {
            postId = self.model.cid;
        }
    }
    
    NSInteger landAccountFlg = 1;
    
    NSMutableArray * userList = [[NSMutableArray alloc] init];
    for (UserYaoYueModel * model in self.selectSource) {
        [userList addObject:@(model.cid)];
    }
    
    NSMutableArray * allowToSeeList = [[NSMutableArray alloc] init];
    
    NSString * title = self.model.postSummary;
    if (isEmptyString(title)) {
        title = building;
    }
    
    UIImage * firstImage = [self.mapView takeSnapshot];
    QNDDUploadManager * manager = [[QNDDUploadManager alloc] init];
    [manager uploadImage:firstImage progress:^(NSString *key, float percent) {
        
    } success:^(NSString *url) {
        
        NSString * firstPic = url;
        
        CreateDTieRequest * request = [[CreateDTieRequest alloc] initWithList:[NSArray new] title:building address:address building:building addressLng:lon addressLat:lat status:1 remindFlg:1 firstPic:firstPic postID:0 landAccountFlg:landAccountFlg allowToSeeList:allowToSeeList sceneTime:[DDTool getTimeCurrentWithDouble]];
        [request configRemark:@"WYY"];
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
                    
                    AddUserToWYYRequest * request = [[AddUserToWYYRequest alloc] initWithUserList:userList postId:newPostID];
                    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                        
                    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                        
                    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
                        
                    }];
                    
                    [[WeChatManager shareManager] shareMiniProgramWithPostID:newPostID image:firstImage isShare:NO title:building];
                    
                }
            }
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"操作失败" inView:self.view];
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"操作失败" inView:self.view];
        }];
        
    } failed:^(NSError *error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"操作失败" inView:self.view];
    }];
    
//    DDShareYaoYueViewController * share = [[DDShareYaoYueViewController alloc] initWithDtieModel:self.model selectUser:self.selectSource];
//    [self.navigationController pushViewController:share animated:YES];
}

- (void)tabButtonDidClicked:(UIButton *)button
{
    if (button == self.yaoyueButton) {
        self.selectIndex = 1;
        
        self.yaoyueButton.alpha = 1.f;
        self.aboutButton.alpha = .5;
        self.tableView.hidden = NO;
        self.collectionView.hidden = YES;
        
        if (self.friendDataSource.count == 0) {
            [self setUpDatas];
        }
        
    }else{
        self.selectIndex = 2;
        
        self.yaoyueButton.alpha = .5f;
        self.aboutButton.alpha = 1.;
        self.tableView.hidden = YES;
        self.collectionView.hidden = NO;
    }
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
    titleLabel.text = @"要约";
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
