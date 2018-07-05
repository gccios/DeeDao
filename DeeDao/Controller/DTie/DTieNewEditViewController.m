//
//  DTieNewEditViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/31.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieNewEditViewController.h"
#import "DTieContentView.h"
#import "UserManager.h"
#import "MBProgressHUD+DDHUD.h"
#import "QNDDUploadManager.h"
#import "CreateDTieRequest.h"
#import "SecurityGroupModel.h"
#import "DTieDetailRequest.h"
#import "DTieNewDetailViewController.h"
#import "WeChatManager.h"

NSString * const DTieDidCreateNewNotification = @"DTieDidCreateNewNotification";
NSString * const DTieCollectionNeedUpdateNotification = @"DTieCollectionNeedUpdateNotification";

@interface DTieNewEditViewController ()

@property (nonatomic, strong) UIView * topView;


@property (nonatomic, strong) DTieContentView * contenView;

@property (nonatomic, strong) DTieModel * editModel;

@property (nonatomic, strong) UIButton * leftHandleButton;
@property (nonatomic, strong) UIButton * rightHandleButton;

@property (nonatomic, copy) NSString * firstImageURL;
//@property (nonatomic, assign) NSInteger sharePostId;

@property (nonatomic, assign) BOOL isPflg;

@end

@implementation DTieNewEditViewController

- (instancetype)initWithDtieModel:(DTieModel *)model
{
    if (self = [super init]) {
        self.editModel = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
}

- (void)postDetailListSuccess:(void (^)(NSMutableArray * details))success
{
    self.firstImageURL = @"";
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在上传帖子内容" inView:self.view];
    NSMutableArray * details = [[NSMutableArray alloc] init];
    
    __block NSInteger tempCount = 0;
    
    if (self.contenView.modleSources.count == 0) {
        [hud hideAnimated:YES];
        success(details);
        return;
    }
    
    for (NSInteger i = 0; i < self.contenView.modleSources.count; i++) {
        
        DTieEditModel * model = [self.contenView.modleSources objectAtIndex:i];
        
        if (model.pFlag == 1) {
            self.isPflg = YES;
        }
        
        if (model.type == DTieEditType_Image) {
            
            if (model.detailContent) {
                
                if (isEmptyString(self.firstImageURL)) {
                    self.firstImageURL = model.detailsContent;
                }
                
                NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                        @"datadictionaryType":@"CONTENT_IMG",
                                        @"detailsContent":model.detailsContent,
                                        @"textInformation":@"",
                                        @"pFlag":@(model.pFlag),
                                        @"wxCansee":@(model.shareEnable)};
                [details addObject:dict];
                tempCount++;
                if (tempCount == self.contenView.modleSources.count) {
                    [hud hideAnimated:YES];
                    success(details);
                }
            }else{
                if (model.image) {
                    QNDDUploadManager * manager = [[QNDDUploadManager alloc] init];
                    
                    [manager uploadImage:model.image progress:^(NSString *key, float percent) {
                        
                    } success:^(NSString *url) {
                        
                        model.detailsContent = url;
                        if (isEmptyString(self.firstImageURL)) {
                            self.firstImageURL = model.detailsContent;
                        }
                        NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                                @"datadictionaryType":@"CONTENT_IMG",
                                                @"detailsContent":model.detailsContent,
                                                @"textInformation":@"",
                                                @"pFlag":@(model.pFlag),
                                                @"wxCansee":@(model.shareEnable)};
                        [details addObject:dict];
                        tempCount++;
                        if (tempCount == self.contenView.modleSources.count) {
                            [hud hideAnimated:YES];
                            success(details);
                        }
                    } failed:^(NSError *error) {
                        
                        tempCount++;
                        if (tempCount == self.contenView.modleSources.count) {
                            [hud hideAnimated:YES];
                            success(details);
                        }
                    }];
                }else{
                    tempCount++;
                    if (tempCount == self.contenView.modleSources.count) {
                        [hud hideAnimated:YES];
                        success(details);
                    }
                }
            }
        }else if (model.type == DTieEditType_Text) {
            NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                    @"datadictionaryType":@"CONTENT_TEXT",
                                    @"detailsContent":model.detailsContent,
                                    @"textInformation":@"",
                                    @"pFlag":@(model.pFlag),
                                    @"wxCansee":@(model.shareEnable)};
            [details addObject:dict];
            tempCount++;
            if (tempCount == self.contenView.modleSources.count) {
                [hud hideAnimated:YES];
                success(details);
            }
        }else if (model.type == DTieEditType_Video) {
            if (model.detailContent && model.textInformation) {
                NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                        @"datadictionaryType":@"CONTENT_VIDEO",
                                        @"detailsContent":model.detailsContent,
                                        @"textInformation":model.textInformation,
                                        @"pFlag":@(model.pFlag),
                                        @"wxCansee":@(model.shareEnable)};
                tempCount++;
                [details addObject:dict];
                if (tempCount == self.contenView.modleSources.count) {
                    [hud hideAnimated:YES];
                    success(details);
                }
            }else{
                QNDDUploadManager * manager = [[QNDDUploadManager alloc] init];
                
                [manager uploadImage:model.image progress:^(NSString *key, float percent) {
                    
                } success:^(NSString *url) {
                    model.detailsContent = url;
                    
                    [manager uploadPHAsset:model.asset progress:^(NSString *key, float percent) {
                        
                    } success:^(NSString *url) {
                        
                        model.textInformation = url;
                        NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                                @"datadictionaryType":@"CONTENT_VIDEO",
                                                @"detailsContent":model.detailsContent,
                                                @"textInformation":model.textInformation,
                                                @"pFlag":@(model.pFlag),
                                                @"wxCansee":@(model.shareEnable)};
                        [details addObject:dict];
                        
                        [[NSFileManager defaultManager] removeItemAtURL:model.videoURL error:nil];
                        
                        tempCount++;
                        if (tempCount == self.contenView.modleSources.count) {
                            [hud hideAnimated:YES];
                            success(details);
                        }
                        
                    } failed:^(NSError *error) {
                        tempCount++;
                        if (tempCount == self.contenView.modleSources.count) {
                            [hud hideAnimated:YES];
                            success(details);
                        }
                        
                    }];
                    
//                    [manager uploadVideoWith:model.image filePath:model.videoURL progress:^(NSString *key, float percent) {
//                        
//                    } success:^(NSString *url) {
//                        
//                        model.textInformation = url;
//                        NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
//                                                @"datadictionaryType":@"CONTENT_VIDEO",
//                                                @"detailsContent":model.detailsContent,
//                                                @"textInformation":model.textInformation,
//                                                @"pFlag":@(model.pFlag),
//                                                @"wxCansee":@(model.shareEnable)};
//                        [details addObject:dict];
//                        
//                        [[NSFileManager defaultManager] removeItemAtURL:model.videoURL error:nil];
//                        
//                        tempCount++;
//                        if (tempCount == self.contenView.modleSources.count) {
//                            [hud hideAnimated:YES];
//                            success(details);
//                        }
//                        
//                    } failed:^(NSError *error) {
//                        
//                        tempCount++;
//                        if (tempCount == self.contenView.modleSources.count) {
//                            [hud hideAnimated:YES];
//                            success(details);
//                        }
//                        
//                    }];
                    
                } failed:^(NSError *error) {
                    
                    tempCount++;
                    if (tempCount == self.contenView.modleSources.count) {
                        [hud hideAnimated:YES];
                        success(details);
                    }
                    
                }];
            }
        }else{
            tempCount++;
            if (tempCount == self.contenView.modleSources.count) {
                [hud hideAnimated:YES];
                success(details);
            }
        }
        
    }
}

#pragma mark - 保存草稿
- (void)saveDtie
{
    [self postDetailListSuccess:^(NSMutableArray *details) {
        
        [self saveOrCreateWith:details status:0];
        
    }];
}

#pragma mark - 发布D帖
- (void)putDtie
{
    [self postDetailListSuccess:^(NSMutableArray *details) {
        
        [self saveOrCreateWith:details status:1];
        
    }];
}

- (void)saveOrCreateWith:(NSMutableArray *)details status:(NSInteger)status
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
    
    if (details.count == 0 && status == 1) {
        [MBProgressHUD showTextHUDWithText:@"不能发布空帖哟~" inView:self.view];
        return;
    }
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在创建帖子" inView:self.view];
    
    //获取参数配置
    NSString * address = @"";
    if (self.contenView.choosePOI) {
        address = self.contenView.choosePOI.address;
    }else{
        address = self.contenView.locationLabel.text;
    }
    
    NSString * building = self.contenView.choosePOI.name;
    if (isEmptyString(building)) {
        building = address;
    }
    
    double lon;
    double lat;
    if (self.contenView.choosePOI) {
        lon = self.contenView.choosePOI.pt.longitude;
        lat = self.contenView.choosePOI.pt.latitude;
    }else if (self.editModel){
        lon = self.editModel.sceneAddressLng;
        lat = self.editModel.sceneAddressLat;
    }else{
        lon = [DDLocationManager shareManager].userLocation.location.coordinate.longitude;
        lat = [DDLocationManager shareManager].userLocation.location.coordinate.latitude;
    }
    NSString * firstPic = self.firstImageURL;
    
    NSInteger postId = 0;
    if (self.editModel) {
        postId = self.editModel.postId;
        if (postId == 0) {
            postId = self.editModel.cid;
        }
    }
    
    NSInteger landAccountFlg = self.contenView.landAccountFlg;
    
    NSMutableArray * allowToSeeList = [[NSMutableArray alloc] init];
    if (landAccountFlg == 4) {
        
        for (SecurityGroupModel * groupModel in self.contenView.selectSource) {
            if (groupModel.cid == -1) {
                if (landAccountFlg == 5) {
                    landAccountFlg = 6;
                }else{
                    landAccountFlg = 3;
                }
            }else if (groupModel.cid == -2){
                if (landAccountFlg == 3) {
                    landAccountFlg = 6;
                }else{
                    landAccountFlg = 5;
                }
            }else{
                NSInteger remindFlg = 0;
                if (groupModel.isNotification) {
                    remindFlg = 1;
                }
                [allowToSeeList addObject:@{@"securityGroupId":@(groupModel.cid), @"remindFlg":@(remindFlg)}];
            }
        }
        
        if (allowToSeeList.count > 0) {
            if (landAccountFlg == 2) {
                landAccountFlg = 2;
            }else if (landAccountFlg == 3) {
                landAccountFlg = 3;
            }else if (landAccountFlg == 5) {
                landAccountFlg = 7;
            }else if (landAccountFlg == 6) {
                landAccountFlg = 6;
            }
        }
    }
    
    NSString * title = self.contenView.titleTextField.text;
    if (isEmptyString(title)) {
        title = building;
    }
    
    CreateDTieRequest * request = [[CreateDTieRequest alloc] initWithList:details title:title address:address building:building addressLng:lon addressLat:lat status:status remindFlg:1 firstPic:firstPic postID:postId landAccountFlg:landAccountFlg allowToSeeList:allowToSeeList sceneTime:self.contenView.createTime];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                [MBProgressHUD showTextHUDWithText:@"操作成功" inView:self.view];
                DTieModel * DTie = [DTieModel mj_objectWithKeyValues:data];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:DTieDidCreateNewNotification object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:DTieCollectionNeedUpdateNotification object:nil];
                
                if (self.needPopTwoVC) {
                    
                    NSArray * vcArray = self.navigationController.viewControllers;
                    UIViewController * vc = [vcArray objectAtIndex:vcArray.count - 3];
                    [self.navigationController popToViewController:vc animated:YES];
                }else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
                if (status == 1) {
                    BOOL shareEnable = YES;
                    if (![WXApi isWXAppInstalled] && [UserManager shareManager].user.bloggerFlg == 0) {
                        shareEnable = NO;
                    }
                    if (landAccountFlg == 2) {
                        shareEnable = NO;
                    }
                    
                    [self checkShareWithPostId:DTie.postId share:shareEnable];
                }
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

- (void)checkShareWithPostId:(NSInteger)postId share:(BOOL)sharenable;
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:[UIApplication sharedApplication].keyWindow];
    
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:postId type:4 start:0 length:10];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                if (dtieModel.ifCanSee == 0) {
                    [MBProgressHUD showTextHUDWithText:@"您没有浏览该帖的权限~" inView:self.view];
                    return;
                }
                
                if (dtieModel.deleteFlg == 1) {
                    [MBProgressHUD showTextHUDWithText:@"该帖已被作者删除~" inView:self.view];
                    return;
                }
                DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initWithDTie:dtieModel];
                UITabBarController * tab = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                UINavigationController * na = (UINavigationController *)tab.selectedViewController;
                
                [na pushViewController:detail animated:YES];
                
                if (sharenable) {
                    [detail showShareWithCreatePost];
                }
            }
        }
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
    }];
}

- (void)leftHandleButtonDidClicked
{
    [self saveDtie];
}

- (void)rightHandleButtonDidClicked
{
    if (nil == self.contenView.choosePOI) {
        [MBProgressHUD showTextHUDWithText:@"请先选择一个位置" inView:self.view];
        return;
    }
    
    BOOL hasImage = NO;
    for (DTieEditModel * model in self.contenView.modleSources) {
        if (model.type == DTieEditType_Image) {
            hasImage = YES;
            break;
        }
    }
    if (!hasImage) {
        [MBProgressHUD showTextHUDWithText:@"至少需要一张图片" inView:self.view];
        return;
    }
    
    [self putDtie];
}

#pragma mark - 第一步
- (void)showContenView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    [self.view insertSubview:self.contenView atIndex:0];
    [self.contenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
}

- (void)hiddenContenView
{
    [self.contenView removeFromSuperview];
}

//#pragma mark - 第二步
//- (void)showQuanxianView
//{
//    CGFloat scale = kMainBoundsWidth / 1080.f;
//    [self.view insertSubview:self.quanxianTableView atIndex:0];
//    [self.quanxianTableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo((364 + kStatusBarHeight) * scale);
//        make.left.bottom.right.mas_equalTo(0);
//    }];
//}

//- (void)hiddenQuanxianView
//{
//    [self.quanxianTableView removeFromSuperview];
//}
//
//#pragma mark - 第三步
//- (void)showReadView
//{
//    DTieModel * model = [[DTieModel alloc] init];
//    model.postSummary = self.contenView.titleTextField.text;
//    model.sceneTime = self.contenView.createTime;
//    model.details = [NSArray arrayWithArray:self.contenView.modleSources];
//    model.nickname = [UserManager shareManager].user.nickname;
//    model.authorId = [UserManager shareManager].user.cid;
//    model.portraituri = [UserManager shareManager].user.portraituri;
//    model.sceneAddress = self.contenView.locationLabel.text;
//    model.updateTime = [[NSDate date] timeIntervalSince1970];
//
//    NSString * scene = self.contenView.choosePOI.name;
//    if (isEmptyString(scene)) {
//        scene = model.sceneAddress;
//    }
//    model.sceneBuilding = scene;
//
//    double lon;
//    double lat;
//    if (self.contenView.choosePOI) {
//        lon = self.contenView.choosePOI.pt.longitude;
//        lat = self.contenView.choosePOI.pt.latitude;
//    }else if (self.editModel){
//        lon = self.editModel.sceneAddressLng;
//        lat = self.editModel.sceneAddressLat;
//    }else{
//        lon = [DDLocationManager shareManager].userLocation.location.coordinate.longitude;
//        lat = [DDLocationManager shareManager].userLocation.location.coordinate.latitude;
//    }
//    model.sceneAddressLat = lat;
//    model.sceneAddressLng = lon;
//
//    CGFloat scale = kMainBoundsWidth / 1080.f;
//
//    self.readView = [[DTieReadView alloc] initWithFrame:self.view.bounds model:model];
//    self.readView.parentDDViewController = self.navigationController;
//    self.readView.isPreRead = YES;
//    [self.view insertSubview:self.readView atIndex:0];
//    [self.readView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo((364 + kStatusBarHeight) * scale);
//        make.left.bottom.right.mas_equalTo(0);
//    }];
//}
//
//- (void)hiddenReadView
//{
//    [self.readView removeFromSuperview];
//}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    [self createTopView];
    
    UIView * bottomHandleView = [[UIView alloc] initWithFrame:CGRectZero];
    bottomHandleView.backgroundColor = [UIColorFromRGB(0xEEEEF4) colorWithAlphaComponent:.7f];
    [self.view addSubview:bottomHandleView];
    [bottomHandleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(324 * scale);
    }];
    
    self.leftHandleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:@"保存并退出"];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.leftHandleButton];
    self.leftHandleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.leftHandleButton.layer.borderWidth = 3 * scale;
    [bottomHandleView addSubview:self.leftHandleButton];
    [self.leftHandleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.width.mas_equalTo(444 * scale);
        make.height.mas_equalTo(144 * scale);
        make.centerY.mas_equalTo(0);
    }];
    
    self.rightHandleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:@"发布并浏览"];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.rightHandleButton];
    self.rightHandleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.rightHandleButton.layer.borderWidth = 3 * scale;
    [bottomHandleView addSubview:self.rightHandleButton];
    [self.rightHandleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.width.mas_equalTo(444 * scale);
        make.height.mas_equalTo(144 * scale);
        make.centerY.mas_equalTo(0);
    }];
    
    [self.leftHandleButton addTarget:self action:@selector(leftHandleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.rightHandleButton addTarget:self action:@selector(rightHandleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self showContenView];
    if (nil == self.editModel) {
        [self.contenView showChoosePhotoPicker];
    }
    
//    self.quanxianTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
//    self.quanxianTableView.backgroundColor = self.view.backgroundColor;
//    self.quanxianTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self.quanxianTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
//    self.quanxianTableView.rowHeight = .1 * scale;
//    self.quanxianTableView.delegate = self;
//    self.quanxianTableView.dataSource = self;
//    self.quanxianTableView.tableHeaderView = self.quanxianView;
}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return 1;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
//
//    return cell;
//}

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
    titleLabel.text = @"编辑D帖";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
    UIButton * yulanButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] title:@"预览D帖"];
    [DDViewFactoryTool cornerRadius:12 * scale withView:yulanButton];
    yulanButton.layer.borderWidth = .5f;
    yulanButton.layer.borderColor = UIColorFromRGB(0xFFFFFF).CGColor;
    [yulanButton addTarget:self action:@selector(yulanButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:yulanButton];
    [yulanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(192 * scale);
        make.height.mas_equalTo(72 * scale);
        make.centerY.mas_equalTo(titleLabel);
        make.right.mas_equalTo(-60 * scale);
    }];
//    
//    CGFloat buttonWidth = kMainBoundsWidth / 3.f;
//    self.yulanButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"3.预览发布"];
//    self.yulanButton.alpha = .5f;
//    [self.topView addSubview:self.yulanButton];
//    [self.yulanButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(0);
//        make.bottom.mas_equalTo(0);
//        make.width.mas_equalTo(buttonWidth);
//        make.height.mas_equalTo(144 * scale);
//    }];
//    
//    self.quxianButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"2.权限设置"];
//    self.quxianButton.alpha = .5f;
//    [self.topView addSubview:self.quxianButton];
//    [self.quxianButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(0);
//        make.bottom.mas_equalTo(0);
//        make.width.mas_equalTo(buttonWidth);
//        make.height.mas_equalTo(144 * scale);
//    }];
//    
//    self.contentButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"1.添加内容"];
//    [self.topView addSubview:self.contentButton];
//    [self.contentButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(0);
//        make.bottom.mas_equalTo(0);
//        make.width.mas_equalTo(buttonWidth);
//        make.height.mas_equalTo(144 * scale);
//    }];
}

- (void)yulanButtonDidClicked
{
    if (nil == self.contenView.choosePOI) {
        [MBProgressHUD showTextHUDWithText:@"请先选择一个位置" inView:self.view];
        return;
    }
    
    BOOL hasImage = NO;
    for (DTieEditModel * model in self.contenView.modleSources) {
        if (model.type == DTieEditType_Image) {
            hasImage = YES;
            break;
        }
    }
    if (!hasImage) {
        [MBProgressHUD showTextHUDWithText:@"至少需要一张图片" inView:self.view];
        return;
    }

    DTieModel * model = [[DTieModel alloc] init];
    model.postSummary = self.contenView.titleTextField.text;
    if (isEmptyString(self.contenView.titleTextField.text)) {
        model.postSummary = self.contenView.choosePOI.name;
    }
    model.sceneTime = self.contenView.createTime;
    model.details = [NSArray arrayWithArray:self.contenView.modleSources];
    model.nickname = [UserManager shareManager].user.nickname;
    model.authorId = [UserManager shareManager].user.cid;
    model.portraituri = [UserManager shareManager].user.portraituri;
    model.sceneAddress = self.contenView.locationLabel.text;
    model.sceneBuilding = self.contenView.choosePOI.name;
    model.updateTime = [[NSDate date] timeIntervalSince1970];
    
    DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initPreReadWithDTie:model];
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)backButtonDidClicked
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定要放弃当前编辑的内容？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.needPopTwoVC) {
            
            NSArray * vcArray = self.navigationController.viewControllers;
            UIViewController * vc = [vcArray objectAtIndex:vcArray.count - 3];
            [self.navigationController popToViewController:vc animated:YES];
            
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    [self presentViewController:alert animated:YES completion:nil];
}

- (DTieContentView *)contenView
{
    if (!_contenView) {
        if (self.editModel) {
            _contenView = [[DTieContentView alloc] initWithFrame:[UIScreen mainScreen].bounds editModel:self.editModel];
        }else{
            _contenView = [[DTieContentView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        }
        _contenView.parentDDViewController = self.navigationController;
    }
    return _contenView;
}

//- (DTieQuanxianView *)quanxianView
//{
//    if (!_quanxianView) {
//        _quanxianView = [[DTieQuanxianView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    }
//    return _quanxianView;
//}
//
//- (NSMutableArray *)shareImages
//{
//    if (!_shareImages) {
//        _shareImages = [[NSMutableArray alloc] init];
//    }
//    return _shareImages;
//}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if ([self.contenView.titleTextField isFirstResponder]) {
        [self.contenView.titleTextField resignFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //开启iOS7的滑动返回效果
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //关闭iOS7的滑动返回效果
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
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
