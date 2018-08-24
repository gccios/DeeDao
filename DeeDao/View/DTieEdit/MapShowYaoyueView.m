//
//  MapShowYaoyueView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "MapShowYaoyueView.h"
#import <Masonry.h>
#import "DDViewFactoryTool.h"
#import "MapYaoyueHeaderView.h"
#import "SelectMapYaoyueDetailRequest.h"
#import "LogoCollectionViewCell.h"
#import "DTieDetailRequest.h"
#import "DTieNewDetailViewController.h"
#import "MBProgressHUD+DDHUD.h"
#import "UserInfoViewController.h"
#import "DDYaoYueViewController.h"
#import "DTiePOIViewController.h"
#import "UserManager.h"
#import "DDLGSideViewController.h"
#import "YueFanViewController.h"

@interface MapShowYaoyueView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) DTieModel * dtieModel;
@property (nonatomic, strong) UICollectionViewFlowLayout * layout;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSMutableArray * userSource;
@property (nonatomic, strong) DTieMapYaoyueModel * model;

@end

@implementation MapShowYaoyueView

- (instancetype)initWithModel:(DTieMapYaoyueModel *)model
{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        
        self.model = model;
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
    [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    [contenView addSubview:cancleButton];
    [cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10 * scale);
        make.right.mas_equalTo(-30 * scale);
        make.width.mas_equalTo(150 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    [cancleButton addTarget:self action:@selector(cancleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
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
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 324 * scale, 0);
    [contenView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cancleButton.mas_bottom).offset(20 * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    UIButton * leftHandleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:@"发起约饭"];
    [DDViewFactoryTool cornerRadius:24 * scale withView:leftHandleButton];
    leftHandleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    leftHandleButton.layer.borderWidth = 3 * scale;
    [self addSubview:leftHandleButton];
    [leftHandleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(144 * scale);
        make.bottom.mas_equalTo(-40 * scale);
    }];
    
    [leftHandleButton addTarget:self action:@selector(leftHandleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
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
                NSDictionary * postBean = [data objectForKey:@"postBean"];
                if (KIsDictionary(postBean)) {
                    self.dtieModel = [DTieModel mj_objectWithKeyValues:postBean];
                    [self.dtieModel mj_setKeyValues:data];
                }
                
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
        
        if (self.dtieModel.wyyFlg == 1) {
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
        
        if (self.dtieModel) {
            [view configWithDTieModel:self.dtieModel];
            
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
            
//            view.yaoyueHandle = ^{
//                [weakSelf showYaoYue];
//            };
        }
        
        return view;
    }
    return nil;
}

- (void)reloadWYYStatus
{
    if (self.dtieModel.wyyFlg == 1) {
        
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
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:self];
    
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:self.dtieModel.cid type:4 start:0 length:10];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        
        if (KIsDictionary(response)) {
            
            NSInteger code = [[response objectForKey:@"status"] integerValue];
            if (code == 4002) {
                [MBProgressHUD showTextHUDWithText:@"该帖已被作者删除~" inView:self];
                return;
            }
            
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                
                if (dtieModel.deleteFlg == 1) {
                    [MBProgressHUD showTextHUDWithText:@"该帖已被作者删除~" inView:self];
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
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
    }];
}

- (void)showUserInfo
{
    [self cancleButtonDidClicked];
    UserInfoViewController * info = [[UserInfoViewController alloc] initWithUserId:self.dtieModel.authorId];
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    [na pushViewController:info animated:YES];
}

- (void)showYaoYue
{
    [self cancleButtonDidClicked];
    
    if (self.dtieModel == nil) {
        [MBProgressHUD showTextHUDWithText:@"该点暂时没有帖子哟~" inView:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
    DDYaoYueViewController * yaoyue = [[DDYaoYueViewController alloc] initWithDtieModel:self.dtieModel];
    
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    [na pushViewController:yaoyue animated:YES];
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
    
    if (self.dtieModel == nil) {
        [MBProgressHUD showTextHUDWithText:@"该点暂时没有帖子哟~" inView:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
    DTiePOIViewController * poi = [[DTiePOIViewController alloc] initWithDtieModel:self.dtieModel];
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    [na pushViewController:poi animated:YES];
}

- (void)leftHandleButtonDidClicked
{
//    [self showYaoYue];
    [self cancleButtonDidClicked];
    
    if (self.dtieModel == nil) {
        [MBProgressHUD showTextHUDWithText:@"该点暂时没有帖子哟~" inView:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
    BMKPoiInfo * poi = [[BMKPoiInfo alloc] init];
    poi.pt = CLLocationCoordinate2DMake(self.dtieModel.sceneAddressLat, self.dtieModel.sceneAddressLng);
    poi.address = self.dtieModel.sceneAddress;
    poi.name = self.dtieModel.sceneBuilding;
    
    NSMutableArray * yaoyueSource = [[NSMutableArray alloc] initWithArray:self.userSource];
    if ([yaoyueSource.firstObject isKindOfClass:[UserModel class]]) {
        [yaoyueSource removeObjectAtIndex:0];
    }
    YueFanViewController * yuefan = [[YueFanViewController alloc] initWithBMKPoiInfo:poi friendArray:yaoyueSource];
    
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    [na pushViewController:yuefan animated:YES];
}

- (void)cancleButtonDidClicked
{
    [self removeFromSuperview];
}

@end
