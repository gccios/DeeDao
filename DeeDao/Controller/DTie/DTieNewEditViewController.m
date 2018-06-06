//
//  DTieNewEditViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/31.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieNewEditViewController.h"
#import "DTieContentView.h"
#import "DTieQuanxianView.h"
#import "DTieReadView.h"
#import "UserManager.h"
#import "MBProgressHUD+DDHUD.h"
#import "QNDDUploadManager.h"
#import "CreateDTieRequest.h"
#import "DTieShareViewController.h"
#import "WeChatManager.h"

NSString * const DTieDidCreateNewNotification = @"DTieDidCreateNewNotification";

@interface DTieNewEditViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UIButton * contentButton;
@property (nonatomic, strong) UIButton * quxianButton;
@property (nonatomic, strong) UIButton * yulanButton;

@property (nonatomic, strong) DTieContentView * contenView;
@property (nonatomic, strong) UITableView * quanxianTableView;
@property (nonatomic, strong) DTieQuanxianView * quanxianView;
@property (nonatomic, strong) DTieReadView * readView;
@property (nonatomic, strong) NSMutableArray * shareImages;

@property (nonatomic, strong) DTieModel * editModel;

@property (nonatomic, assign) NSInteger step;
@property (nonatomic, strong) UIButton * leftHandleButton;
@property (nonatomic, strong) UIButton * rightHandleButton;

@property (nonatomic, copy) NSString * firstImageURL;
@property (nonatomic, assign) NSInteger sharePostId;

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
    self.step = 1;
    [self createViews];
}

- (void)postDetailListSuccess:(void (^)(NSMutableArray * details))success
{
    self.firstImageURL = @"";
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在上传帖子内容" inView:self.view];
    NSMutableArray * details = [[NSMutableArray alloc] init];
    
    [self.shareImages removeAllObjects];
    __block NSInteger tempCount = 0;
    
    for (NSInteger i = 0; i < self.contenView.modleSources.count; i++) {
        
        DTieEditModel * model = [self.contenView.modleSources objectAtIndex:i];
        if (model.type == DTieEditType_Image) {
            
            if (model.image && model.shareEnable) {
                if (self.shareImages.count < 9) {
                    [self.shareImages addObject:model.image];
                }
            }
            
            if (model.detailContent) {
                
                if (isEmptyString(self.firstImageURL)) {
                    self.firstImageURL = model.detailsContent;
                }
                
                NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                        @"datadictionaryType":@"CONTENT_IMG",
                                        @"detailsContent":model.detailsContent,
                                        @"textInformation":@"",
                                        @"pFlg":@(model.pFlag)};
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
                                                @"pFlg":@(model.pFlag)};
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
                                    @"pFlg":@(model.pFlag)};
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
                                        @"pFlg":@(model.pFlag)};
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
                    [manager uploadVideoWith:model.image filePath:model.videoURL progress:^(NSString *key, float percent) {
                        
                    } success:^(NSString *url) {
                        
                        model.textInformation = url;
                        NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                                @"datadictionaryType":@"CONTENT_VIDEO",
                                                @"detailsContent":model.detailsContent,
                                                @"textInformation":model.textInformation,
                                                @"pFlg":@(model.pFlag)};
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
    
    if (details.count == 0) {
        [MBProgressHUD showTextHUDWithText:@"不能发布空贴哟~" inView:self.view];
        return;
    }
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在创建帖子" inView:self.view];
    
    //获取参数配置
    NSString * address = self.contenView.locationLabel.text;
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
    }
    
    NSMutableArray * allowToSeeList = [[NSMutableArray alloc] init];
    for (SecurityGroupModel * groupModel in self.quanxianView.allowToSeeList) {
        [allowToSeeList addObject:@(groupModel.cid)];
    }
    
    CreateDTieRequest * request = [[CreateDTieRequest alloc] initWithList:details title:self.contenView.titleTextField.text address:address addressLng:lon addressLat:lat status:status remindFlg:1 firstPic:firstPic postID:postId landAccountFlg:self.quanxianView.landAccountFlg allowToSeeList:allowToSeeList sceneTime:self.contenView.createTime];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                [MBProgressHUD showTextHUDWithText:@"操作成功" inView:self.view];
                DTieModel * DTie = [DTieModel mj_objectWithKeyValues:data];
                self.sharePostId = DTie.postId;
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:DTieDidCreateNewNotification object:nil];
        [self.navigationController popViewControllerAnimated:YES];
        
        if (status == 1) {
            [self checkShare];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"操作失败" inView:self.view];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"操作失败" inView:self.view];
    }];
}

- (void)checkShare
{
    if (self.shareImages.count == 0) {
        return;
    }
    
    if (self.quanxianView.shareType == 1) {
        if (self.shareImages && self.shareImages.count > 0) {
            DTieShareViewController * share = [[DTieShareViewController alloc] initWithShareList:self.shareImages];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:share animated:YES completion:nil];
        }
    }else{
        
        if (self.sharePostId == 0) {
            return;
        }
        
        [WeChatManager shareManager].isShare = YES;
        UIImage * image = [UIImage imageNamed:@"DeeDao-logo"];
        if (self.shareImages && self.shareImages.count > 0) {
            image = [self.shareImages firstObject];
        }
        [[WeChatManager shareManager] shareMiniProgramWithPostID:self.editModel.cid image:image];
    }
}

- (void)leftHandleButtonDidClicked
{
    if (self.step == 1) {
        [self saveDtie];
    }else if (self.step == 2) {
        [self hiddenQuanxianView];
        [self showContenView];
        self.step = 1;
        [self.leftHandleButton setTitle:@"保存并退出" forState:UIControlStateNormal];
        self.quxianButton.alpha = .5f;
        self.contentButton.alpha = 1;
    }else if (self.step == 3) {
        self.step = 2;
        self.quxianButton.alpha = 1;
        self.yulanButton.alpha = .5f;
        [self.rightHandleButton setTitle:@"下一步" forState:UIControlStateNormal];
        
        [self hiddenReadView];
        [self showQuanxianView];
    }
}

- (void)rightHandleButtonDidClicked
{
    if (self.step == 1) {
        
        if (isEmptyString(self.contenView.titleTextField.text)) {
            [MBProgressHUD showTextHUDWithText:@"请先输入标题" inView:self.view];
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
        
        self.step = 2;
        self.contentButton.alpha = .5f;
        self.quxianButton.alpha = 1;
        [self.leftHandleButton setTitle:@"上一步" forState:UIControlStateNormal];
        
        [self hiddenContenView];
        [self showQuanxianView];
        
    }else if (self.step == 2) {
        
        self.step = 3;
        self.quxianButton.alpha = .5f;
        self.yulanButton.alpha = 1;
        [self.rightHandleButton setTitle:@"发布并分享" forState:UIControlStateNormal];
        
        [self hiddenQuanxianView];
        [self showReadView];
    }else if (self.step == 3) {
        [self putDtie];
    }
}

#pragma mark - 第一步
- (void)showContenView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    [self.view insertSubview:self.contenView atIndex:0];
    [self.contenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((364 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
}

- (void)hiddenContenView
{
    [self.contenView removeFromSuperview];
}

#pragma mark - 第二步
- (void)showQuanxianView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    [self.view insertSubview:self.quanxianTableView atIndex:0];
    [self.quanxianTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((364 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
}

- (void)hiddenQuanxianView
{
    [self.quanxianTableView removeFromSuperview];
}

#pragma mark - 第三步
- (void)showReadView
{
    DTieModel * model = [[DTieModel alloc] init];
    model.postSummary = self.contenView.titleTextField.text;
    model.sceneTime = self.contenView.createTime;
    model.details = [NSArray arrayWithArray:self.contenView.modleSources];
    model.nickname = [UserManager shareManager].user.nickname;
    model.authorId = [UserManager shareManager].user.cid;
    model.portraituri = [UserManager shareManager].user.portraituri;
    model.sceneAddress = self.contenView.locationLabel.text;
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.readView = [[DTieReadView alloc] initWithFrame:self.view.bounds model:model];
    [self.view insertSubview:self.readView atIndex:0];
    [self.readView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((364 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
}

- (void)hiddenReadView
{
    [self.readView removeFromSuperview];
}

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
    
    self.rightHandleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:@"下一步"];
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
    
    self.quanxianTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.quanxianTableView.backgroundColor = self.view.backgroundColor;
    self.quanxianTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.quanxianTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.quanxianTableView.rowHeight = .1 * scale;
    self.quanxianTableView.delegate = self;
    self.quanxianTableView.dataSource = self;
    self.quanxianTableView.tableHeaderView = self.quanxianView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    return cell;
}

- (void)createTopView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.topView = [[UIView alloc] init];
    self.topView.userInteractionEnabled = YES;
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo((364 + kStatusBarHeight) * scale);
    }];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, (364 + kStatusBarHeight) * scale);
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
        make.bottom.mas_equalTo(-159 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentCenter];
    titleLabel.text = @"编辑D贴";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-181 * scale);
    }];
    
    CGFloat buttonWidth = kMainBoundsWidth / 3.f;
    self.yulanButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"3.预览发布"];
    self.yulanButton.alpha = .5f;
    [self.topView addSubview:self.yulanButton];
    [self.yulanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(144 * scale);
    }];
    
    self.quxianButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"2.权限设置"];
    self.quxianButton.alpha = .5f;
    [self.topView addSubview:self.quxianButton];
    [self.quxianButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(144 * scale);
    }];
    
    self.contentButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"1.添加内容"];
    [self.topView addSubview:self.contentButton];
    [self.contentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(144 * scale);
    }];
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (DTieQuanxianView *)quanxianView
{
    if (!_quanxianView) {
        _quanxianView = [[DTieQuanxianView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _quanxianView;
}

- (NSMutableArray *)shareImages
{
    if (!_shareImages) {
        _shareImages = [[NSMutableArray alloc] init];
    }
    return _shareImages;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if ([self.contenView.titleTextField isFirstResponder]) {
        [self.contenView.titleTextField resignFirstResponder];
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
