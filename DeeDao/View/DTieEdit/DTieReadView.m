
//
//  DTieReadView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/1.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieReadView.h"
#import "UserManager.h"
#import "DDViewFactoryTool.h"
#import "DDTool.h"
#import "DTieDetailTextTableViewCell.h"
#import "DTieDetailImageTableViewCell.h"
#import "DTieDetailVideoTableViewCell.h"
#import "DTieDetailPostTableViewCell.h"
#import "LiuYanTableViewCell.h"

#import "DTieCollectionRequest.h"
#import "LiuYanViewController.h"
#import "UserInfoViewController.h"
#import "DDLocationManager.h"
#import "DDShareManager.h"
#import "LookImageViewController.h"
#import "DDDazhaohuView.h"
#import "MBProgressHUD+DDHUD.h"
#import "DTiePOIViewController.h"
#import "JubaoRequest.h"
#import "CommentRequest.h"
#import "GetDtieSecurityRequest.h"
#import "DTieSecurityViewController.h"
#import "DDTool.h"

#import "DTieReadHandleFooterView.h"
#import "DTieReadCommentHeaderView.h"

#import <UIImageView+WebCache.h>
#import <Masonry.h>
#import <WXApi.h>

#import "DDDaZhaoHuViewController.h"

#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>

#import "SelectWYYBlockRequest.h"
#import "UserYaoYueBlockModel.h"
#import <AFHTTPSessionManager.h>
#import "DDBackWidow.h"
#import "DaoDiAlertView.h"
#import "NewAchievementViewController.h"

@interface DTieReadView () <UITableViewDelegate, UITableViewDataSource, LiuyanDidComplete, BMKMapViewDelegate>

@property (nonatomic, strong) UIView * headerView;
@property (nonatomic, strong) UIImageView * firstImageView;
@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UIButton * dazhaohuButton;
@property (nonatomic, strong) UIButton * locationButton;
@property (nonatomic, strong) UILabel * locationLabel;
@property (nonatomic, strong) UILabel * senceTimelabel;
@property (nonatomic, strong) UILabel * titleLabel;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * modelSources;
@property (nonatomic, strong) NSMutableArray * contentSources;
@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) NSMutableArray * yaoyueList;

@property (nonatomic, strong) UIImage * firstImage;

@property (nonatomic, assign) BOOL isSelfFlg;

@property (nonatomic, strong) UIButton * jubaoButton;

@property (nonatomic, assign) BOOL isInsatllWX;

@property (nonatomic, strong) BMKMapView * mapView;

@property (nonatomic, assign) BOOL hasDaoDi;

@end

@implementation DTieReadView

- (instancetype)initWithFrame:(CGRect)frame model:(DTieModel *)model
{
    if (self = [super initWithFrame:frame]) {
        
        self.isPreRead = NO;
        self.model = model;
        self.isInsatllWX = [WXApi isWXAppInstalled];
        if (model.details) {
            [self sortWithDetails:model.details];
        }else{
            self.modelSources = [NSMutableArray new];
        }
        
        self.dataSource = [[NSMutableArray alloc] init];
        self.contentSources = [[NSMutableArray alloc] init];
        [self.dataSource addObject:self.modelSources];
        [self.dataSource addObject:self.contentSources];
        
        if ([UserManager shareManager].user.cid == model.authorId) {
            self.isSelfFlg = YES;
        }
        
        [self getLiuyanList];
        [self createDTieReadView];
        
        [self configUserInteractionEnabled];
        
        [self checkWYYBlock];
    }
    return self;
}

- (void)checkWYYBlock
{
    NSInteger postID = self.model.postId;
    if (postID == 0) {
        postID = self.model.cid;
    }
    SelectWYYBlockRequest * request = [[SelectWYYBlockRequest alloc] initWithPostID:postID];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                self.yaoyueList = [UserYaoYueBlockModel mj_objectArrayWithKeyValuesArray:data];
                [self.tableView reloadData];
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)getLiuyanList
{
    if (self.isPreRead) {
        return;
    }
    
    NSInteger postID = self.model.cid;
    if (postID == 0) {
        postID = self.model.postId;
    }
    
    CommentRequest * request = [[CommentRequest alloc] initWithPostID:self.model.postId];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.contentSources removeAllObjects];
                for (NSInteger i = 0; i < data.count; i++) {
                    NSDictionary * dict = [data objectAtIndex:i];
                    CommentModel * model = [CommentModel mj_objectWithKeyValues:dict];
                    [self.contentSources addObject:model];
                }
                
                if (self.contentSources.count > 10) {
                    [self.contentSources removeObjectsInRange:NSMakeRange(10, self.contentSources.count - 10)];
                }
                [self.tableView reloadData];
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
       
    }];
}

- (void)sortWithDetails:(NSArray *)details
{
    self.modelSources = [NSMutableArray arrayWithArray:details];
    for (NSInteger i = 0; i < details.count; i++) {
        DTieEditModel * model = [details objectAtIndex:i];
        if (model.type == DTieEditType_Image) {
            if (model.image) {
                self.firstImage = model.image;
            }else{
                
                NSString * imageURL = self.model.postFirstPicture;
                if (isEmptyString(imageURL)) {
                    imageURL = model.detailContent;
                }
                
                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imageURL] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    
                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                    [[SDImageCache sharedImageCache] storeImage:image forKey:imageURL toDisk:YES completion:nil];
                    self.firstImage = image;
                    [self configHeaderView];
                }];
            }
            [self.modelSources removeObject:model];
            break;
        }
    }
}

- (void)configUserInteractionEnabled
{
    UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userinfoDidClicked)];
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userinfoDidClicked)];
    self.logoImageView.userInteractionEnabled = YES;
    self.nameLabel.userInteractionEnabled = YES;
    [self.logoImageView addGestureRecognizer:tap1];
    [self.nameLabel addGestureRecognizer:tap2];
    
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDidHandle:)];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidTap:)];
    self.firstImageView.userInteractionEnabled = YES;
    [self.firstImageView addGestureRecognizer:longPress];
    [self.firstImageView addGestureRecognizer:tap];
    
    [self.dazhaohuButton addTarget:self action:@selector(dazhaohuButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.jubaoButton addTarget:self action:@selector(jubaoButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)imageDidTap:(UITapGestureRecognizer *)tap
{
    if (self.parentDDViewController) {
        if (self.firstImage) {
            LookImageViewController * look = [[LookImageViewController alloc] initWithImage:self.firstImage];
            [self.parentDDViewController presentViewController:look animated:NO completion:nil];
            [[DDBackWidow shareWindow] hidden];
        }
    }
}

- (void)longPressDidHandle:(UILongPressGestureRecognizer *)longPress
{
    if (self.parentDDViewController) {
        ShareImageModel * model = [[ShareImageModel alloc] init];
        NSInteger postId = self.model.cid;
        if (postId == 0) {
            postId = self.model.postId;
        }
        model.postId = postId;
        model.PFlag = 0;
        model.image = self.firstImageView.image;
        model.title = self.model.postSummary;
        [[DDShareManager shareManager] showHandleViewWithImage:model];
    }
}

- (void)locationButtonDidClicked
{
    if (self.isPreRead) {
        return;
    }
    DTiePOIViewController * poi = [[DTiePOIViewController alloc] initWithDtieModel:self.model];
    [self.parentDDViewController pushViewController:poi animated:YES];
}

- (void)dazhaohuButtonDidClicked
{
    if (self.isSelfFlg) {
        
        if (self.parentDDViewController) {
            DDDaZhaoHuViewController * dazhaohu = [[DDDaZhaoHuViewController alloc] initWithDTieModel:self.model];
            [self.parentDDViewController pushViewController:dazhaohu animated:YES];
        }
        
        return;
    }
    
    if (self.model.dzfFlg == 1) {
        [MBProgressHUD showTextHUDWithText:@"您已经打过招呼了" inView:self.parentDDViewController.view];
        return;
    }
    
    BOOL canHandle = [[DDLocationManager shareManager] postIsCanDazhaohuWith:self.model];
    if (!canHandle) {
        [MBProgressHUD showTextHUDWithText:[NSString stringWithFormat:@"只能和%ld米之内的的帖子打招呼", [DDLocationManager shareManager].distance] inView:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
    DDDazhaohuView * view = [[DDDazhaohuView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.block = ^(NSString *text) {
        self.dazhaohuButton.enabled = NO;
        
        DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:self.model.cid type:2 subType:1 remark:text];
        
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            self.model.dzfFlg = 1;
            self.model.dzfCount++;
            
            self.dazhaohuButton.enabled = YES;
            [MBProgressHUD showTextHUDWithText:@"对方已收到您的信息" inView:[UIApplication sharedApplication].keyWindow];
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.dazhaohuButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.dazhaohuButton.enabled = YES;
        }];
    };
    [view show];
}

- (void)jubaoButtonDidClicked
{
    if (self.isSelfFlg) {
        return;
    }
    
    [JubaoRequest cancelRequest];
    JubaoRequest * jubao = [[JubaoRequest alloc] initWithPostViewId:self.model.cid postComplaintContent:@"" complaintOwner:[UserManager shareManager].user.cid];
    [jubao sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [MBProgressHUD showTextHUDWithText:@"举报成功，稍后我们会对内容进行核实" inView:self.parentDDViewController.view];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [MBProgressHUD showTextHUDWithText:@"举报失败" inView:self.parentDDViewController.view];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:self.parentDDViewController.view];
        
    }];
}

- (void)liuyanButtonDidClicked
{
    if (self.isPreRead) {
        [MBProgressHUD showTextHUDWithText:@"预览状态无法进行查看~" inView:self.self];
        return;
    }
    if (self.parentDDViewController) {
        LiuYanViewController * liuyan = [[LiuYanViewController alloc] initWithPostID:self.model.cid commentId:self.model.authorId];
        liuyan.delegate = self;
        [self.parentDDViewController pushViewController:liuyan animated:YES];
    }
}

- (void)liuyanDidComplete:(NSMutableArray *)commentSource
{
    self.model.messageCount += 1;
    [self.contentSources removeAllObjects];
    [self.contentSources addObjectsFromArray:commentSource];
    [self.tableView reloadData];
}

- (void)userinfoDidClicked
{
    if (self.isPreRead) {
        return;
    }
    if (self.parentDDViewController) {
        UserInfoViewController * info = [[UserInfoViewController alloc] initWithUserId:self.model.authorId];
        [self.parentDDViewController pushViewController:info animated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.modelSources.count;
    }
    return self.contentSources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        DTieEditModel * model = [self.modelSources objectAtIndex:indexPath.row];
        
        if (model.pFlag == 1) {
            [self hasGetDaoDiAchievement];
        }
        
        if (model.type == DTieEditType_Image) {
            DTieDetailImageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieDetailImageTableViewCell" forIndexPath:indexPath];
            
            [cell configWithModel:model Dtie:self.model];
            
            return cell;
        }else if (model.type == DTieEditType_Video) {
            DTieDetailVideoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieDetailVideoTableViewCell" forIndexPath:indexPath];
            
            [cell configWithModel:model Dtie:self.model];
            
            return cell;
        }else if (model.type == DTieEditType_Post) {
            
            DTieDetailPostTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieDetailPostTableViewCell" forIndexPath:indexPath];
            
            [cell configWithModel:model Dtie:self.model];
            
            return cell;
        }
        
        DTieDetailTextTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieDetailTextTableViewCell" forIndexPath:indexPath];
        
        [cell configWithModel:model Dtie:self.model];
        
        return cell;
    }
    
    CommentModel * model = [self.contentSources objectAtIndex:indexPath.row];
    LiuYanTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"LiuYanTableViewCell" forIndexPath:indexPath];
    
    [cell configWithModel:model];
    
    return cell;
    
}

- (void)hasGetDaoDiAchievement
{
    if (self.hasDaoDi || [UserManager shareManager].user.cid == self.model.authorId) {
        return;
    }
    self.hasDaoDi = YES;
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSInteger postID = self.model.postId;
    if (postID == 0) {
        postID = self.model.cid;
    }
    
    NSString * url = [NSString stringWithFormat:@"%@/medal/arriveCanSeeMedal", HOSTURL];
    [manager POST:url parameters:@{@"postId":@(postID)} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary * respones = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        NSInteger status = [[respones objectForKey:@"status"] integerValue];
        if (status == 1100) {
            DaoDiAlertView * view = [[DaoDiAlertView alloc] init];
            view.handleButtonClicked = ^{
                NewAchievementViewController * vc = [[NewAchievementViewController alloc] init];
                [self.parentDDViewController pushViewController:vc animated:YES];
            };
            [view show];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        DTieReadCommentHeaderView * header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DTieReadCommentHeaderView"];
        
        return header;
    }
    
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"UITableViewHeaderFooterView"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    if (section == 1) {
        return 144 * scale;
    }
    return .1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        DTieReadHandleFooterView * footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DTieReadHandleFooterView"];
        
        [footer configWithModel:self.model];
        
        __weak typeof(self) weakSelf = self;
        if (self.model.authorId == [UserManager shareManager].user.cid) {
            footer.handleButtonDidClicked = ^{
                [weakSelf seeButtonDidClicked];
            };
        }else{
            footer.handleButtonDidClicked = ^{
                [weakSelf jubaoButtonDidClicked];
            };
        }
        
        if (!self.isPreRead) {
            footer.backButtonDidClicked = ^{
                [weakSelf backHomeDidClicked];
            };
        }
        
        if (self.yaoyueList) {
            [footer configWithYaoyueModel:self.yaoyueList];
            footer.addButtonDidClickedHandle = ^{
                [weakSelf checkWYYBlock];
            };
        }
        
        return footer;
    }
    
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"UITableViewHeaderFooterView"];
}

- (void)backHomeDidClicked
{
    if (self.parentDDViewController) {
        [self.parentDDViewController popToRootViewControllerAnimated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    if (section == 0) {
        
        if (self.yaoyueList.count > 0) {
            NSInteger count = self.yaoyueList.count + 2;
            
            CGFloat height = 144 * scale * count + 60 * scale;
            
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"userId == %d", [UserManager shareManager].user.cid];
            NSArray * tempArray = [self.yaoyueList filteredArrayUsingPredicate:predicate];
            if (tempArray.count == 0) {
                height = height + 144 * scale;
            }
            
            return 620 * scale + height;
        }else if (self.yaoyueList) {
            
            return 620 * scale + 3 * 144 * scale + 60 * scale;
        }else{
            return 620 * scale;
        }
    }
    return .1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        CGFloat scale = kMainBoundsWidth / 1080.f;
        DTieEditModel * model = [self.modelSources objectAtIndex:indexPath.row];
        
        CGFloat height = 0.1f;
        
        if (model.type == DTieEditType_Image) {
            
            if (model.image) {
                height = [DDTool getHeightWithImage:model.image] + 90 * scale;
            }else{
                UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:model.detailContent];
                
                if (!image) {
                    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:model.detailContent] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                        
                    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                        [[SDImageCache sharedImageCache] storeImage:image forKey:model.detailContent toDisk:YES completion:nil];
                        model.image = image;
                        
                        if ([tableView.indexPathsForVisibleRows containsObject:indexPath]) {
                            [self.tableView beginUpdates];
                            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                            [self.tableView endUpdates];
                        }
                    }];
                }else{
                    height = [DDTool getHeightWithImage:image] + 90 * scale;
                }
            }
            
        }else if (model.type == DTieEditType_Video){
            
            height = (kMainBoundsWidth - 120 * scale) / 4.f * 3.f + 90 * scale;
            
            
        }else if (model.type == DTieEditType_Text) {
            
            height = [DDTool getHeightByWidth:kMainBoundsWidth - 120 * scale - 120 * scale title:model.detailsContent font:kPingFangRegular(42 * scale)] + 100 * scale + 120 * scale;
        }else if (model.type == DTieEditType_Post) {
             height = 800 * scale + 90 * scale;
        }
        
        if (self.isSelfFlg && self.isInsatllWX) {
            if (model.wxCanSee == 1 || model.pFlag == 1 || model.shareEnable == 1) {
                height += 72 * scale;
            }
        }
        
        return height;
    }else{
        
        CGFloat scale = kMainBoundsWidth / 1080.f;
        
        CommentModel * model = [self.contentSources objectAtIndex:indexPath.row];
        CGSize size = [model.commentContent boundingRectWithSize:CGSizeMake(kMainBoundsWidth - 290 * scale, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:kPingFangRegular(42 * scale)} context:nil].size;
        
        
        return size.height + 170 * scale;
    }
}

- (void)createDTieReadView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[DTieDetailTextTableViewCell class] forCellReuseIdentifier:@"DTieDetailTextTableViewCell"];
    [self.tableView registerClass:[DTieDetailImageTableViewCell class] forCellReuseIdentifier:@"DTieDetailImageTableViewCell"];
    [self.tableView registerClass:[DTieDetailVideoTableViewCell class] forCellReuseIdentifier:@"DTieDetailVideoTableViewCell"];
    [self.tableView registerClass:[DTieDetailPostTableViewCell class] forCellReuseIdentifier:@"DTieDetailPostTableViewCell"];
    [self.tableView registerClass:[LiuYanTableViewCell class] forCellReuseIdentifier:@"LiuYanTableViewCell"];
    [self.tableView registerClass:[DTieReadHandleFooterView class] forHeaderFooterViewReuseIdentifier:@"DTieReadHandleFooterView"];
    [self.tableView registerClass:[DTieReadCommentHeaderView class] forHeaderFooterViewReuseIdentifier:@"DTieReadCommentHeaderView"];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"UITableViewHeaderFooterView"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 324 * scale, 0);
    
    [self createHeaderView];
    [self createfooterView];
}

#pragma mark - 创建tableView脚视图
- (void)createfooterView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 144 * scale)];
    footerView.backgroundColor = [UIColor whiteColor];
    
    UIButton * commentButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"查看更多留言或回评"];
    [footerView addSubview:commentButton];
    [commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    [commentButton addTarget:self action:@selector(liuyanButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.tableFooterView = footerView;
}

- (void)seeButtonDidClicked
{
    if (self.isPreRead) {
        [MBProgressHUD showTextHUDWithText:@"预览状态无法进行查看~" inView:self];
        return;
    }
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:[UIApplication sharedApplication].keyWindow];
    GetDtieSecurityRequest * request = [[GetDtieSecurityRequest alloc] initWithModel:self.model];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        
        NSMutableArray * modelList =  [[NSMutableArray alloc] init];
        NSInteger accountFlg = self.model.landAccountFlg;
        
        SecurityGroupModel * model1 = [[SecurityGroupModel alloc] init];
        model1.cid = -1;
        model1.securitygroupName = @"所有朋友";
        model1.securitygroupPropName = @"所有朋友可见";
        model1.isChoose = YES;
        model1.isNotification = YES;
        
        SecurityGroupModel * model2 = [[SecurityGroupModel alloc] init];
        model2.cid = -2;
        model2.securitygroupName = @"关注我的人";
        model2.securitygroupPropName = @"关注我的人可见";
        model2.isChoose = YES;
        model2.isNotification = YES;
        if (accountFlg == 3) {
            [modelList addObject:model1];
        }else if (accountFlg == 5) {
            [modelList addObject:model2];
        }else if (accountFlg == 6) {
            [modelList addObject:model1];
            [modelList addObject:model2];
        }else if (accountFlg == 7) {
            [modelList addObject:model2];
        }
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            for (NSDictionary * dict in data) {
                SecurityGroupModel * model = [SecurityGroupModel mj_objectWithKeyValues:dict];
                [modelList addObject:model];
            }
        }
        
        if (modelList.count > 0) {
            DTieSecurityViewController * vc = [[DTieSecurityViewController alloc] initWithSecurityList:modelList];
            [self.parentDDViewController pushViewController:vc animated:YES];
        }else{
            if (accountFlg == 1) {
                [MBProgressHUD showTextHUDWithText:@"当前权限设置为公开" inView:self.parentDDViewController.view];
            }else if (accountFlg == 2) {
                [MBProgressHUD showTextHUDWithText:@"当前权限设置为隐私" inView:self.parentDDViewController.view];
            }else{
                [MBProgressHUD showTextHUDWithText:@"没有权限设置" inView:self.parentDDViewController.view];
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        
    }];
}

#pragma mark - 创建tableView头视图
- (void)createHeaderView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 1050 * scale)];
    self.headerView.backgroundColor = [UIColor whiteColor];
    
    self.firstImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [self.headerView addSubview:self.firstImageView];
    [self.firstImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(.1f);
    }];
    
//    UIView * timeView = [[UIView alloc] initWithFrame:CGRectZero];
//    [self.headerView addSubview:timeView];
//    [timeView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.mas_equalTo(0);
//        make.top.mas_equalTo(self.firstImageView.mas_bottom).offset(60 * scale);
//        make.height.mas_equalTo(40 * scale);
//    }];
    
    self.titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangMedium(72 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    self.titleLabel.numberOfLines = 0;
    [self.headerView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.firstImageView.mas_bottom).offset(20 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(165 * scale);
    }];
    
    UIView * userView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 144 * scale)];
    [self.headerView addSubview:userView];
    [userView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(20 * scale);
        make.height.mas_equalTo(144 * scale);
    }];
    
    UIImageView * locationButton = [[UIImageView alloc] init];
    locationButton.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationButtonDidClicked)];
    [locationButton addGestureRecognizer:tap];
    
//    UIImage * locationBG = [UIImage imageNamed:@"buttonBG"];
//    locationBG = [locationBG resizableImageWithCapInsets:UIEdgeInsetsMake(locationBG.size.height / 3, locationBG.size.width / 3, locationBG.size.height / 3, locationBG.size.width / 3) resizingMode:UIImageResizingModeStretch];
//    [locationButton setImage:locationBG];
    [self.headerView addSubview:locationButton];
    [locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20 * scale);
        make.right.mas_equalTo(-20 * scale);
        make.top.mas_equalTo(userView.mas_bottom).offset(20 * scale);
        make.height.mas_equalTo(160 * scale);
    }];
    
    self.senceTimelabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    [locationButton addSubview:self.senceTimelabel];
    [self.senceTimelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(35 * scale);
        make.left.mas_equalTo(40 * scale);
        make.right.mas_equalTo(-80 * scale);
        make.height.mas_equalTo(44 * scale);
    }];
    
    self.locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [locationButton addSubview:self.locationButton];
    [self.locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40 * scale);
        make.height.mas_equalTo(50 * scale);
        make.top.mas_equalTo(self.senceTimelabel.mas_bottom).offset(0 * scale);
    }];
    
    UIImageView * locationImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"POI_icon"]];
    [locationButton addSubview:locationImageView];
    [locationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-40 * scale);
        make.width.height.mas_equalTo(72 * scale);
    }];
    
//    UIImageView * userBGView = [[UIImageView alloc] initWithFrame:CGRectZero];
//    userBGView.contentMode = UIViewContentModeScaleAspectFill;
//    [userView addSubview:userBGView];
//    UIImage * userBG = [UIImage imageNamed:@"buttonBG"];
//    userBG = [locationBG resizableImageWithCapInsets:UIEdgeInsetsMake(locationBG.size.height / 3, locationBG.size.width / 3, locationBG.size.height / 3, locationBG.size.width / 3) resizingMode:UIImageResizingModeStretch];
//    [userBGView setImage:userBG];
    
    UIView * logoBGView = [[UIView alloc] initWithFrame:CGRectZero];
    logoBGView.backgroundColor = [UIColor whiteColor];
    [userView addSubview:logoBGView];
    [logoBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.centerY.mas_equalTo(0);
        make.width.height.mas_equalTo(96 * scale);
    }];
    logoBGView.layer.cornerRadius = 48 * scale;
    logoBGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    logoBGView.layer.shadowOpacity = .5f;
    logoBGView.layer.shadowRadius = 8 * scale;
    logoBGView.layer.shadowOffset = CGSizeMake(0, 4 * scale);
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [userView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.centerY.mas_equalTo(0);
        make.width.height.mas_equalTo(96 * scale);
    }];
    [DDViewFactoryTool cornerRadius:48 * scale withView:self.logoImageView];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [userView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(20 * scale);
        make.right.mas_lessThanOrEqualTo(-350 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(50 * scale);
    }];
    
//    CGSize size = [self.model.nickname boundingRectWithSize:CGSizeMake(kMainBoundsWidth - 500 * scale, 50 * scale) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:kPingFangRegular(42 * scale)} context:nil].size;
//    [userBGView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(80 * scale);
//        make.centerY.mas_equalTo(0);
//        make.width.mas_equalTo(size.width + 140 * scale);
//        make.height.mas_equalTo(120 * scale);
//    }];
    
    self.dazhaohuButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"打招呼 0"];
    if (self.isSelfFlg) {
        [self.dazhaohuButton setTitle:[NSString stringWithFormat:@"打招呼 %ld", self.model.dzfCount] forState:UIControlStateNormal];
        if (self.model.dzfCount > 100) {
            [self.dazhaohuButton setTitle:@" 打招呼 99+" forState:UIControlStateNormal];
        }
        [self.dazhaohuButton setImage:[UIImage imageNamed:@"dazhaohuzuozhe"] forState:UIControlStateNormal];
    }else{
        [self.dazhaohuButton setTitle:@"" forState:UIControlStateNormal];
        [self.dazhaohuButton setImage:[UIImage imageNamed:@"dazhaohuzhankai"] forState:UIControlStateNormal];
        
        BOOL canHandle = [[DDLocationManager shareManager] postIsCanDazhaohuWith:self.model];
        if (!canHandle) {
            self.dazhaohuButton.alpha = 0.7f;
        }
    }
    [userView addSubview:self.dazhaohuButton];
    [self.dazhaohuButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.width.mas_equalTo(300 * scale);
        make.height.mas_equalTo(128 * scale);
        make.centerY.mas_equalTo(0);
    }];
    
    self.locationLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [self.locationButton addSubview:self.locationLabel];
    [self.locationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0 * scale);
        make.right.mas_equalTo(-160 * scale);
        make.height.mas_equalTo(45 * scale);
        make.centerY.mas_equalTo(0);
    }];
    
    UIView * baseView = [[UIView alloc] initWithFrame:CGRectZero];
    baseView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.headerView addSubview:baseView];
    [baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(locationButton.mas_bottom).offset(20 * scale);
        make.left.mas_equalTo(60 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    baseView.layer.cornerRadius = 24 * scale;
    baseView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    baseView.layer.shadowOpacity = .3f;
    baseView.layer.shadowRadius = 24 * scale;
    baseView.layer.shadowOffset = CGSizeMake(0, 12 * scale);
    
    UITapGestureRecognizer * mapTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationButtonDidClicked)];
    [baseView addGestureRecognizer:mapTap];
    
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
    
    [baseView addSubview:self.mapView];
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
    
    BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(self.model.sceneAddressLat, self.model.sceneAddressLng);
    [self.mapView addAnnotation:annotation];
    
    [self configHeaderView];
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

- (void)configHeaderView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    CGFloat height = (1050 - 165) * scale;
    
    if (self.firstImage) {
        CGFloat imageHeight = [DDTool getHeightWithImage:self.firstImage];
        [self.firstImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(imageHeight);
        }];
        [self.firstImageView setImage:self.firstImage];
        height += imageHeight;
    }
    
    NSString * title = self.model.postSummary;
    if (!isEmptyString(title)) {
        CGFloat tempHeight = [DDTool getHeightByWidth:kMainBoundsWidth - 120 * scale title:title font:kPingFangRegular(72 * scale)];
        if (tempHeight < 120 * scale) {
            height += 100 * scale;
            [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(100 * scale);
            }];
        }else{
            height += 200 * scale;
            [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(230 * scale);
            }];
        }
        self.titleLabel.text = title;
    }else{
        height += 100 * scale;
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(100 * scale);
        }];
    }
    CGRect frame = self.headerView.frame;
    frame.size.height = height;
    self.headerView.frame = frame;
    
    self.tableView.tableHeaderView = self.headerView;
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:self.model.portraituri]];
    self.nameLabel.text = self.model.nickname;
    self.locationLabel.text = self.model.sceneBuilding;
    self.senceTimelabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.model.sceneTime];
}

@end
