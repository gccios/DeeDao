//
//  WYYListViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "WYYListViewController.h"
#import "WXHistoryTableViewCell.h"
#import "FanjuTableViewCell.h"
#import <MJRefresh.h>
#import "DTieSearchRequest.h"
#import "DDTool.h"
#import "MBProgressHUD+DDHUD.h"
#import "DTieDetailRequest.h"
#import "DTieNewDetailViewController.h"
#import "SelectFanjuRequest.h"
#import <AFHTTPSessionManager.h>
#import "DDNavigationViewController.h"
#import "DTieSearchViewController.h"
#import "DDBackWidow.h"
#import "DDLocationManager.h"
#import <TZImagePickerController.h>
#import "QNDDUploadManager.h"
#import "CreateDTieRequest.h"
#import "DTieNewTableViewCell.h"
#import "DDCollectionViewController.h"

@interface WYYListViewController () <UITableViewDelegate, UITableViewDataSource, TZImagePickerControllerDelegate, CAAnimationDelegate>

@property (nonatomic, strong) DTieModel * uploadModel;

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UIButton * zujuButton;
@property (nonatomic, strong) UIButton * ganxingquButton;
@property (nonatomic, strong) UIButton * dakaButton;

@property (nonatomic, strong) NSMutableArray * zujuSource;
@property (nonatomic, strong) UITableView * zujuTableView;
@property (nonatomic, strong) NSMutableArray * ganxingquSource;
@property (nonatomic, strong) UITableView * ganxingquTableView;
@property (nonatomic, strong) NSMutableArray * dakaSource;
@property (nonatomic, strong) UITableView * dakaTableView;

@property (nonatomic, assign) NSInteger pageIndex;

@property (nonatomic, assign) NSInteger zujuStart;
@property (nonatomic, assign) NSInteger zujuSize;
@property (nonatomic, assign) NSInteger ganxingquStart;
@property (nonatomic, assign) NSInteger ganxingquSize;
@property (nonatomic, assign) NSInteger dakaStart;
@property (nonatomic, assign) NSInteger dakaSize;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation WYYListViewController

- (instancetype)initWithPageIndex:(NSInteger)index
{
    if (self = [super init]) {
        self.pageIndex = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.zujuSource = [[NSMutableArray alloc] init];
    self.dakaSource = [[NSMutableArray alloc] init];
    self.ganxingquSource = [[NSMutableArray alloc] init];
    
    [self createViews];
    [self creatTopView];
    
    [self requestZujuMessage];
    [self requestGanxingquMessage];
    [self requestDakaMessage];
    
    if (self.pageIndex == 1) {
        [self tabButtonDidClicked:self.dakaButton];
    }else if (self.pageIndex == 2) {
        [self tabButtonDidClicked:self.ganxingquButton];
    }else if (self.pageIndex == 3) {
        [self tabButtonDidClicked:self.zujuButton];
    }
        
}

- (void)requestDakaMessage
{
    self.dakaStart = 0;
    self.dakaSize = 20;
    DTieSearchRequest * request = [[DTieSearchRequest alloc] initWithSortType:1 dataSources:1 type:2 pageStart:self.dakaStart pageSize:self.dakaSize];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.dakaSource removeAllObjects];
                
                for (NSDictionary * dict in data) {
                    DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                    NSDictionary * postBean = [dict objectForKey:@"postBean"];
                    [model mj_setKeyValues:postBean];
                    [self.dakaSource addObject:model];
                }
                
                self.dakaStart += self.dakaSize;
                
                if (self.dakaTableView) {
                    [self.dakaTableView reloadData];
                    [self.dakaTableView.mj_footer resetNoMoreData];
                }
            }
        }
        
        if (self.dakaTableView) {
            [self.dakaTableView.mj_header endRefreshing];
        }
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (self.dakaTableView) {
            [self.dakaTableView.mj_header endRefreshing];
        }
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        if (self.dakaTableView) {
            [self.dakaTableView.mj_header endRefreshing];
        }
        
    }];
}

- (void)loadMoreDakaMessage
{
    DTieSearchRequest * request = [[DTieSearchRequest alloc] initWithSortType:1 dataSources:1 type:2 pageStart:self.dakaStart pageSize:self.dakaSize];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                if (data.count > 0) {
                    
                    for (NSDictionary * dict in data) {
                        DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                        NSDictionary * postBean = [dict objectForKey:@"postBean"];
                        [model mj_setKeyValues:postBean];
                        [self.dakaSource addObject:model];
                    }
                    
                    self.dakaStart += self.dakaSize;
                    
                    [self.dakaTableView reloadData];
                    [self.dakaTableView.mj_footer endRefreshing];
                    
                }else{
                    [self.dakaTableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.dakaTableView.mj_footer endRefreshing];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [self.dakaTableView.mj_footer endRefreshing];
        
    }];
}

- (void)requestZujuMessage
{
    [SelectFanjuRequest cancelRequest];
    self.zujuStart = 0;
    self.zujuSize = 20;
    SelectFanjuRequest * request = [[SelectFanjuRequest alloc] initWithStart:self.zujuStart size:self.zujuSize];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.zujuSource removeAllObjects];
                
                for (NSDictionary * dict in data) {
                    DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                    NSDictionary * postBean = [dict objectForKey:@"postBean"];
                    [model mj_setKeyValues:postBean];
                    [self.zujuSource addObject:model];
                }
                
                self.zujuStart += self.zujuSize;
                
                if (self.zujuTableView) {
                    [self.zujuTableView reloadData];
                    [self.zujuTableView.mj_footer resetNoMoreData];
                }
            }
        }
        
        if (self.zujuTableView) {
            [self.zujuTableView.mj_header endRefreshing];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (self.zujuTableView) {
            [self.zujuTableView.mj_header endRefreshing];
        }
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        if (self.zujuTableView) {
            [self.zujuTableView.mj_header endRefreshing];
        }
        
    }];
}

- (void)loadMoreZujuMessage
{
    SelectFanjuRequest * request = [[SelectFanjuRequest alloc] initWithStart:self.zujuStart size:self.zujuSize];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                if (data.count > 0) {
                    
                    for (NSDictionary * dict in data) {
                        DTieModel * model = [DTieModel mj_objectWithKeyValues:dict];
                        NSDictionary * postBean = [dict objectForKey:@"postBean"];
                        [model mj_setKeyValues:postBean];
                        [self.zujuSource addObject:model];
                    }
                    
                    self.zujuStart += self.zujuSize;
                    
                    [self.zujuTableView reloadData];
                    [self.zujuTableView.mj_footer endRefreshing];
                    
                }else{
                    [self.zujuTableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.zujuTableView.mj_footer endRefreshing];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [self.zujuTableView.mj_footer endRefreshing];
        
    }];
}

- (void)requestGanxingquMessage
{
    [DTieSearchRequest cancelRequest];
    self.ganxingquStart = 0;
    self.ganxingquSize = 20;
    DTieSearchRequest * request = [[DTieSearchRequest alloc] initWithKeyWord:@"" startDate:0 endDate:(NSInteger)[DDTool getTimeCurrentWithDouble] sortType:1 dataSources:9 type:2 pageStart:self.ganxingquStart pageSize:self.ganxingquSize];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.ganxingquSource removeAllObjects];
                
                [self.ganxingquSource addObjectsFromArray:[DTieModel mj_objectArrayWithKeyValuesArray:data]];
                
                self.ganxingquStart += self.ganxingquSize;
                
                if (self.ganxingquTableView) {
                    [self.ganxingquTableView reloadData];
                    [self.ganxingquTableView.mj_footer resetNoMoreData];
                }
            }
        }
        
        if (self.ganxingquTableView) {
            [self.ganxingquTableView.mj_header endRefreshing];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (self.ganxingquTableView) {
            [self.ganxingquTableView.mj_header endRefreshing];
        }
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        if (self.ganxingquTableView) {
            [self.ganxingquTableView.mj_header endRefreshing];
        }
        
    }];
}

- (void)loadMoreGanxingquMessage
{
    DTieSearchRequest * request = [[DTieSearchRequest alloc] initWithKeyWord:@"" lat1:0 lng1:0 lat2:0 lng2:0 startDate:0 endDate:(NSInteger)[DDTool getTimeCurrentWithDouble] sortType:1 dataSources:9 type:2 pageStart:self.ganxingquStart pageSize:self.ganxingquSize];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                if (data.count > 0) {
                    [self.ganxingquSource addObjectsFromArray:[DTieModel mj_objectArrayWithKeyValuesArray:data]];
                    
                    self.ganxingquStart += self.ganxingquSize;
                    
                    [self.ganxingquTableView reloadData];
                    [self.ganxingquTableView.mj_footer endRefreshing];
                    
                }else{
                    [self.ganxingquTableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.ganxingquTableView.mj_footer endRefreshing];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [self.ganxingquTableView.mj_footer endRefreshing];
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.zujuTableView) {
        return self.zujuSource.count;
    }else if (tableView == self.ganxingquTableView) {
        return self.ganxingquSource.count;
    }else if (tableView == self.dakaTableView) {
        return self.dakaSource.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.zujuTableView) {
        DTieModel * model = [self.zujuSource objectAtIndex:indexPath.row];
        
        FanjuTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FanjuTableViewCell" forIndexPath:indexPath];
        
        __weak typeof(self) weakSelf = self;
        cell.leftButtonHandle = ^{
            [weakSelf navPOIWithModel:model];
        };
        cell.rightButtonHandle = ^{
            [weakSelf uploadPhotoWithModel:model];
        };
        
        [cell configWithModel:model];
        
        return cell;
    }else if (tableView == self.ganxingquTableView) {
        DTieModel * model = [self.ganxingquSource objectAtIndex:indexPath.row];
        
        DTieNewTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieNewTableViewCell" forIndexPath:indexPath];
        
        [cell configWithModel:model];
        
        return cell;
    }else if (tableView == self.dakaTableView) {
        
        DTieNewTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieNewTableViewCell" forIndexPath:indexPath];
        
        DTieModel * model = [self.dakaSource objectAtIndex:indexPath.row];
        [cell configWithModel:model];
        return cell;
        
    }
    
    DTieNewTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieNewTableViewCell" forIndexPath:indexPath];
    
    return cell;
}

- (void)navPOIWithModel:(DTieModel *)model
{
    [[DDLocationManager shareManager] mapNavigationToLongitude:model.sceneAddressLng latitude:model.sceneAddressLat poiName:model.sceneBuilding withViewController:self];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = model.sceneBuilding;
    [MBProgressHUD showTextHUDWithText:@"地址已复制到粘贴板" inView:self.navigationController.view];
}

- (void)uploadPhotoWithModel:(DTieModel *)model
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:self.view];
    
    NSInteger postID = model.postId;
    if (postID == 0) {
        postID = model.cid;
    }
    
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:postID type:4 start:0 length:10];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        
        if (KIsDictionary(response)) {
            
            NSInteger code = [[response objectForKey:@"status"] integerValue];
            if (code == 4002) {
                [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"PageHasDelete") inView:self.view];
                
                [self.zujuSource removeObject:model];
                [self.zujuTableView reloadData];
                [self deletePostWithModel:postID];
                
                return;
            }
            
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                
                if (dtieModel.deleteFlg == 1) {
                    [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"PageHasDelete") inView:self.view];
                    
                    [self.zujuSource removeObject:model];
                    [self.zujuTableView reloadData];
                    [self deletePostWithModel:postID];
                    
                    return;
                }
                
                if (dtieModel.landAccountFlg == 2 && dtieModel.authorId != [UserManager shareManager].user.cid) {
                    [MBProgressHUD showTextHUDWithText:@"该帖已被作者设为私密状态" inView:[UIApplication sharedApplication].keyWindow];
                    return;
                }
                
                if (dtieModel.wyyPermission == 0) {
                    [MBProgressHUD showTextHUDWithText:@"发起人还没有开放照片添加" inView:[UIApplication sharedApplication].keyWindow];
                    return;
                }
                
                self.uploadModel = dtieModel;
                
                TZImagePickerController * picker = [[TZImagePickerController alloc] initWithMaxImagesCount:100 delegate:self];
                picker.allowPickingOriginalPhoto = NO;
                picker.allowPickingVideo = NO;
                picker.showSelectedIndex = YES;
                picker.allowCrop = NO;
                [self.navigationController presentViewController:picker animated:YES completion:nil];
                
            }else{
                NSString * msg = [response objectForKey:@"msg"];
                if (!isEmptyString(msg)) {
                    [MBProgressHUD showTextHUDWithText:msg inView:self.view];
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
    if (picker.showSelectedIndex) {
        
        NSMutableArray * details = [[NSMutableArray alloc] init];
        
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在上传" inView:self.view];
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
                                        @"authorID":@([UserManager shareManager].user.cid)};
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
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在添加照片" inView:self.view];
    CreateDTieRequest * request = [[CreateDTieRequest alloc] initAddWYYWithPostID:self.uploadModel.cid blocks:details];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        
        NSInteger status = [[response objectForKey:@"status"] integerValue];
        if (status == 1200) {
            [MBProgressHUD showTextHUDWithText:@"发起人还没有开放照片添加" inView:self.view];
        }else{
            [MBProgressHUD showTextHUDWithText:@"上传成功" inView:self.view];
            [self.zujuTableView reloadData];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"上传失败" inView:self.view];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"上传失败" inView:self.view];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    return 620 * scale;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.ganxingquTableView) {
        DDCollectionViewController * collectionVC = [[DDCollectionViewController alloc] initWithDataSource:self.ganxingquSource index:indexPath.row];
        [self.navigationController pushViewController:collectionVC animated:YES];
        return;
    }else if (tableView == self.dakaTableView) {
        DDCollectionViewController * collection = [[DDCollectionViewController alloc] initWithDataSource:self.dakaSource index:indexPath.row];
        [self.navigationController pushViewController:collection animated:YES];
        return;
    }
    
    DTieModel * model = [self.zujuSource objectAtIndex:indexPath.row];
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:self.view];
    
    NSInteger postID = model.postId;
    if (postID == 0) {
        postID = model.cid;
    }
    
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:postID type:4 start:0 length:10];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        
        if (KIsDictionary(response)) {
            
            NSInteger code = [[response objectForKey:@"status"] integerValue];
            if (code == 4002) {
                [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"PageHasDelete") inView:self.view];
                
                if (tableView == self.zujuTableView) {
                    [self.zujuSource removeObject:model];
                }else if (tableView == self.ganxingquTableView) {
                    [self.ganxingquSource removeObject:model];
                }
                [tableView reloadData];
                [self deletePostWithModel:postID];
                
                return;
            }
            
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                
                if (dtieModel.deleteFlg == 1) {
                    [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"PageHasDelete") inView:self.view];
                    
                    if (tableView == self.zujuTableView) {
                        [self.zujuSource removeObject:model];
                    }else if (tableView == self.ganxingquTableView) {
                        [self.ganxingquSource removeObject:model];
                    }
                    [tableView reloadData];
                    [self deletePostWithModel:postID];
                    
                    return;
                }
                
                if (dtieModel.landAccountFlg == 2 && dtieModel.authorId != [UserManager shareManager].user.cid) {
                    [MBProgressHUD showTextHUDWithText:@"该帖已被作者设为私密状态" inView:[UIApplication sharedApplication].keyWindow];
                    return;
                }
                
                DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initWithDTie:dtieModel];
                [self.navigationController pushViewController:detail animated:YES];
            }else{
                NSString * msg = [response objectForKey:@"msg"];
                if (!isEmptyString(msg)) {
                    [MBProgressHUD showTextHUDWithText:msg inView:self.view];
                }
            }
        }
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
    }];
}

- (void)deletePostWithModel:(NSInteger)postID
{
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString * url = [NSString stringWithFormat:@"%@/post/collection/deleteAllPostCollection", HOSTURL];
    [manager POST:url parameters:@{@"postId":@(postID)} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.zujuTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.zujuTableView.backgroundColor = self.view.backgroundColor;
    self.zujuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.zujuTableView registerClass:[FanjuTableViewCell class] forCellReuseIdentifier:@"FanjuTableViewCell"];
    self.zujuTableView.delegate = self;
    self.zujuTableView.dataSource = self;
    [self.view addSubview:self.zujuTableView];
    [self.zujuTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((364 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.zujuTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestZujuMessage)];
    self.zujuTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreZujuMessage)];
    self.zujuTableView.hidden = YES;
    
    self.ganxingquTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.ganxingquTableView.backgroundColor = self.view.backgroundColor;
    self.ganxingquTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.ganxingquTableView registerClass:[DTieNewTableViewCell class] forCellReuseIdentifier:@"DTieNewTableViewCell"];
    self.ganxingquTableView.delegate = self;
    self.ganxingquTableView.dataSource = self;
    [self.view addSubview:self.ganxingquTableView];
    [self.ganxingquTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((364 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.ganxingquTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestGanxingquMessage)];
    self.ganxingquTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreGanxingquMessage)];
    self.ganxingquTableView.hidden = YES;
    
    self.dakaTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.dakaTableView.backgroundColor = self.view.backgroundColor;
    self.dakaTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.dakaTableView registerClass:[DTieNewTableViewCell class] forCellReuseIdentifier:@"DTieNewTableViewCell"];
    self.dakaTableView.delegate = self;
    self.dakaTableView.dataSource = self;
    [self.view addSubview:self.dakaTableView];
    [self.dakaTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((364 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.dakaTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestDakaMessage)];
    self.dakaTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDakaMessage)];
    self.dakaTableView.hidden = YES;
}

- (void)creatTopView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.topView = [[UIView alloc] init];
    self.topView.userInteractionEnabled = YES;
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo((364 + kStatusBarHeight) * scale);
    }];
    
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    self.gradientLayer.startPoint = CGPointMake(0, 1);
    self.gradientLayer.endPoint = CGPointMake(1, 0);
    self.gradientLayer.locations = @[@0, @1.0];
    self.gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, (364 + kStatusBarHeight) * scale);
    [self.topView.layer addSublayer:self.gradientLayer];
    
    self.topView.layer.shadowColor = UIColorFromRGB(0xB721FF).CGColor;
    self.topView.layer.shadowOpacity = .24;
    self.topView.layer.shadowOffset = CGSizeMake(0, 4);
    
    UIButton * backButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [backButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(25 * scale);
        make.bottom.mas_equalTo(-160 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    titleLabel.text = DDLocalizedString(@"YueZheList");
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale - 144 * scale);
    }];
    
    CGFloat buttonWidth = kMainBoundsWidth / 3.f;
    self.zujuButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"Appointments")];
    self.zujuButton.alpha = .5f;
    [self.topView addSubview:self.zujuButton];
    [self.zujuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(144 * scale);
    }];
    
    self.ganxingquButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"Interested")];
    [self.topView addSubview:self.ganxingquButton];
    [self.ganxingquButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.zujuButton.mas_left);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(144 * scale);
    }];
    
    self.dakaButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"My D Page")];
    [self.topView addSubview:self.dakaButton];
    [self.dakaButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(144 * scale);
    }];
    
    UIView * lineView1 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView1.alpha = .5f;
    lineView1.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.topView addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.dakaButton);
        make.centerY.mas_equalTo(self.dakaButton);
        make.width.mas_equalTo(3 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    
    UIView * lineView2 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView2.alpha = .5f;
    lineView2.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.topView addSubview:lineView2];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.ganxingquButton);
        make.centerY.mas_equalTo(self.ganxingquButton);
        make.width.mas_equalTo(3 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    
    [self.zujuButton addTarget:self action:@selector(tabButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.dakaButton addTarget:self action:@selector(tabButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.ganxingquButton addTarget:self action:@selector(tabButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * searchButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:searchButton];
    [searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-40 * scale);
        make.centerY.mas_equalTo(titleLabel);
        make.width.height.mas_equalTo(100 * scale);
    }];
}

- (void)searchButtonDidClicked
{
    DTieSearchViewController * search = [[DTieSearchViewController alloc] init];
    DDNavigationViewController * na = [[DDNavigationViewController alloc] initWithRootViewController:search];
    [self presentViewController:na animated:YES completion:nil];
    [[DDBackWidow shareWindow] hidden];
}

- (void)backButtonDidClicked
{
    CATransition *transition = [CATransition animation];
    
    transition.duration = 0.35;
    
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    
    transition.type = kCATransitionPush;
    
    transition.subtype = kCATransitionFromBottom;
    
    transition.delegate = self;
    
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)tabButtonDidClicked:(UIButton *)button
{
    if (button == self.dakaButton) {
        self.pageIndex = 1;
    }else if (button == self.ganxingquButton) {
        self.pageIndex = 2;
    }else if (button == self.zujuButton) {
        self.pageIndex = 3;
    }
    [self reloadPageStatus];
}

- (void)reloadPageStatus
{
    if (self.pageIndex == 1) {
        
        self.dakaButton.alpha = 1.f;
        self.ganxingquButton.alpha = .5f;
        self.zujuButton.alpha = .5f;
        
        self.dakaTableView.hidden = NO;
        self.ganxingquTableView.hidden = YES;
        self.zujuTableView.hidden = YES;
        
        if (self.dakaSource.count == 0) {
            [self requestDakaMessage];
        }
        
        self.gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0x3023AE).CGColor, (__bridge id)UIColorFromRGB(0x539FFD).CGColor];
        self.topView.layer.shadowColor = UIColorFromRGB(0x4A90E2).CGColor;
        self.topView.layer.shadowOpacity = .24;
        self.topView.layer.shadowOffset = CGSizeMake(0, 4);
        
    }else if (self.pageIndex == 2) {
        
        self.dakaButton.alpha = .5f;
        self.ganxingquButton.alpha = 1.f;
        self.zujuButton.alpha = .5f;
        
        self.dakaTableView.hidden = YES;
        self.ganxingquTableView.hidden = NO;
        self.zujuTableView.hidden = YES;
        
        if (self.ganxingquSource.count == 0) {
            [self requestGanxingquMessage];
        }
        
        self.gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0x539FFD).CGColor, (__bridge id)UIColorFromRGB(0xB721FF).CGColor];
        self.topView.layer.shadowColor = UIColorFromRGB(0x4A4A4A).CGColor;
        self.topView.layer.shadowOpacity = .24;
        self.topView.layer.shadowOffset = CGSizeMake(0, 4);
    }else if (self.pageIndex == 3) {
        self.dakaButton.alpha = .5f;
        self.ganxingquButton.alpha = .5f;
        self.zujuButton.alpha = 1.f;
        
        self.dakaTableView.hidden = YES;
        self.ganxingquTableView.hidden = YES;
        self.zujuTableView.hidden = NO;
        
        if (self.zujuSource.count == 0) {
            [self requestZujuMessage];
        }
        
        self.gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xB721FF).CGColor, (__bridge id)UIColorFromRGB(0xDB6283).CGColor];
        self.topView.layer.shadowColor = UIColorFromRGB(0xB721FF).CGColor;
        self.topView.layer.shadowOpacity = .24;
        self.topView.layer.shadowOffset = CGSizeMake(0, 4);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[DDBackWidow shareWindow] show];
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
