//
//  MapShowPostView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/20.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "MapShowPostView.h"
#import <Masonry.h>
#import "DDViewFactoryTool.h"
#import "MapYaoyueHeaderView.h"
#import "MapYaoyueFooterView.h"
#import "SelectMapYaoyueDetailRequest.h"
#import "LogoCollectionViewCell.h"
#import "DTieDetailRequest.h"
#import "DTieNewDetailViewController.h"
#import "MBProgressHUD+DDHUD.h"
#import "UserInfoViewController.h"
#import "DDYaoYueViewController.h"
#import "UserManager.h"
#import "DTiePOIViewController.h"
#import "DDLGSideViewController.h"
#import "YueFanViewController.h"
#import "DTieDeleteRequest.h"
#import "WYYListViewController.h"

@interface MapShowPostView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, strong) UICollectionViewFlowLayout * layout;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, strong) NSMutableArray * userSource;
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) UIButton * deleteButton;

@end

@implementation MapShowPostView

- (instancetype)initWithModel:(DTieModel *)model source:(NSArray *)source index:(NSInteger)index
{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        
        self.model = model;
        self.dataSource = [[NSMutableArray alloc] initWithArray:source];
        self.index = index;
        [self createMapSelectFriendView];
        
    }
    return self;
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.userSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LogoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LogoCollectionViewCell" forIndexPath:indexPath];
    
    UserYaoYueModel * model = [self.userSource objectAtIndex:indexPath.row];
    [cell confiWithModel:model];
    
    return cell;
}

- (void)createMapSelectFriendView
{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * contenView = [[UIView alloc] initWithFrame:CGRectZero];
    contenView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self addSubview:contenView];
    [contenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(940 * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    UIButton * cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleButton setTitleColor:UIColorFromRGB(0xDB6283) forState:UIControlStateNormal];
    [cancleButton setImage:[UIImage imageNamed:@"cancleDown"] forState:UIControlStateNormal];
    [contenView addSubview:cancleButton];
    [cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15 * scale);
        make.right.mas_equalTo(-20 * scale);
        make.width.mas_equalTo(150 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    [cancleButton addTarget:self action:@selector(cancleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.model.authorId == [UserManager shareManager].user.cid) {
        self.deleteButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"   删除这个帖子   "];
        [contenView addSubview:self.deleteButton];
        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(45 * scale);
            make.top.mas_equalTo(40 * scale);
            make.height.mas_equalTo(80 * scale);
        }];
        self.deleteButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
        self.deleteButton.layer.borderWidth = 3 * scale;
        [DDViewFactoryTool cornerRadius:40 * scale withView:self.deleteButton];
        [self.deleteButton addTarget:self action:@selector(deletePost) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.layout = [[UICollectionViewFlowLayout alloc] init];
    self.layout.itemSize = CGSizeMake(150 * scale, 150 * scale);
    self.layout.minimumLineSpacing = 10 * scale;
    self.layout.minimumInteritemSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    [self.collectionView registerClass:[LogoCollectionViewCell class] forCellWithReuseIdentifier:@"LogoCollectionViewCell"];
    [self.collectionView registerClass:[MapYaoyueHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MapYaoyueHeaderView"];
    self.collectionView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(20 * scale, 0, 200 * scale, 0);
    [contenView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cancleButton.mas_bottom).offset(60 * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    MapYaoyueFooterView * view = [[MapYaoyueFooterView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 200 * scale)];
    view.backgroundColor = UIColorFromRGB(0xffffff);
    
    if (self.model) {
        [view configWithDTieModel:self.model];
        
        __weak typeof(self) weakSelf = self;
        
        view.yaoyueHandle = ^() {
            [weakSelf leftHandleButtonDidClicked];
        };
        
        view.deleteHandle = ^{
            [weakSelf deletePost];
        };
        
        view.uploadHandle = ^{
            [weakSelf uploadPhoto];
        };
        
        view.hiddenHandle = ^{
            [weakSelf cancleButtonDidClicked];
        };
    }
    
    [self addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(200 * scale);
    }];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancleButtonDidClicked)];
    UIView * backView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(contenView.mas_top);
    }];
    [backView addGestureRecognizer:tap];
    
    SelectMapYaoyueDetailRequest * request = [[SelectMapYaoyueDetailRequest alloc] initWithAddress:self.model.sceneAddress];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                NSArray * friendsList = [data objectForKey:@"friendsList"];
                if (KIsArray(friendsList)) {
                    [self.userSource removeAllObjects];
                    for (NSDictionary * dict in friendsList) {
                        UserYaoYueModel * model = [UserYaoYueModel mj_objectWithKeyValues:dict];
                        [self.userSource addObject:model];
                    }
                }
            }
            
        }
        
        if (self.model.wyyFlg == 1) {
            [self.userSource insertObject:[UserManager shareManager].user atIndex:0];
        }
        
        self.layout.headerReferenceSize = CGSizeMake(kMainBoundsWidth, 430 * scale);
        [self.collectionView reloadData];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        MapYaoyueHeaderView * view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MapYaoyueHeaderView" forIndexPath:indexPath];
        
        if (self.model) {
            [view configWithDTieModel:self.model];
            
            __weak typeof(self) weakSelf = self;
            view.postHandle = ^{
                [weakSelf showPostDetail];
            };
            
            view.userHandle = ^{
                [weakSelf showUserInfo];
            };
            
            view.yaoyueHandle = ^() {
                [weakSelf reloadWYYStatus];
            };
        }
        
        return view;
    }
    
    return nil;
}

- (void)uploadPhoto
{
    if (self.uploadHandle) {
        self.uploadHandle(self.model);
    }
    
    [self cancleButtonDidClicked];
}

- (void)deletePost
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:[UIApplication sharedApplication].keyWindow];
    
    DTieDeleteRequest * request = [[DTieDeleteRequest alloc] initWithPostId:self.model.cid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [self cancleButtonDidClicked];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [MBProgressHUD showTextHUDWithText:@"删除失败" inView:[UIApplication sharedApplication].keyWindow];
        [hud hideAnimated:YES];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:[UIApplication sharedApplication].keyWindow];
        [hud hideAnimated:YES];
        
    }];
}

- (void)reloadWYYStatus
{
    if (self.model.wyyFlg == 1) {
        
        if (self.userSource.count == 0) {
            [self.userSource insertObject:[UserManager shareManager].user atIndex:0];
            [self.collectionView reloadData];
        }else{
            UserModel * model = [self.userSource firstObject];
            if (model != [UserManager shareManager].user) {
                [self.userSource insertObject:[UserManager shareManager].user atIndex:0];
                [self.collectionView reloadData];
            }
        }
        
    }else{
        
        if (self.userSource.count == 0) {
            
        }else{
            UserModel * model = [self.userSource firstObject];
            if (model == [UserManager shareManager].user) {
                [self.userSource removeObject:model];
                [self.collectionView reloadData];
            }
        }
        
    }
    
    [self.collectionView reloadData];
}

- (void)showPostDetail
{
    [self cancleButtonDidClicked];
//    DDCollectionViewController * collect = [[DDCollectionViewController alloc] initWithDataSource:self.dataSource index:self.index];
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:[UIApplication sharedApplication].keyWindow];
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:self.model.cid type:4 start:0 length:10];
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
                DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                
                if (dtieModel.deleteFlg == 1) {
                    [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"PageHasDelete") inView:[UIApplication sharedApplication].keyWindow];
                    return;
                }
                
                [self cancleButtonDidClicked];
                DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initWithDTie:dtieModel];
                DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                UINavigationController * na = (UINavigationController *)lg.rootViewController;
                [na pushViewController:detail animated:YES];
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"获取详情失败" inView:[UIApplication sharedApplication].keyWindow];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:[UIApplication sharedApplication].keyWindow];
        
    }];
}

- (void)showUserInfo
{
    [self cancleButtonDidClicked];
    UserInfoViewController * info = [[UserInfoViewController alloc] initWithUserId:self.model.authorId];
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    [na pushViewController:info animated:YES];
}

- (void)showYaoYue
{
    [self cancleButtonDidClicked];
    
    if (self.model == nil) {
        [MBProgressHUD showTextHUDWithText:@"该点暂时没有帖子哟~" inView:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
    BMKPoiInfo * poi = [[BMKPoiInfo alloc] init];
    poi.pt = CLLocationCoordinate2DMake(self.model.sceneAddressLat, self.model.sceneAddressLng);
    poi.address = self.model.sceneAddress;
    poi.name = self.model.sceneBuilding;
    
    NSMutableArray * yaoyueSource = [[NSMutableArray alloc] initWithArray:self.userSource];
    if ([yaoyueSource.firstObject isKindOfClass:[UserModel class]]) {
        [yaoyueSource removeObjectAtIndex:0];
    }
    YueFanViewController * yuefan = [[YueFanViewController alloc] initWithBMKPoiInfo:poi friendArray:yaoyueSource];
    
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    [na pushViewController:yuefan animated:YES];
}

- (NSMutableArray *)userSource
{
    if (!_userSource) {
        _userSource = [[NSMutableArray alloc] init];
    }
    return _userSource;
}

- (void)rightHandleButtonDidClicked
{
    [self removeFromSuperview];
    
    if (self.model == nil) {
        [MBProgressHUD showTextHUDWithText:@"该点暂时没有帖子哟~" inView:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
    DTiePOIViewController * poi = [[DTiePOIViewController alloc] initWithDtieModel:self.model];
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    [na pushViewController:poi animated:YES];
}

- (void)leftHandleButtonDidClicked
{
    [self showYaoYue];
}

- (void)cancleButtonDidClicked
{
    [self removeFromSuperview];
}

@end
