
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

#import "SelectWYYBlockRequest.h"
#import "UserYaoYueBlockModel.h"
#import <AFHTTPSessionManager.h>
#import "DDBackWidow.h"
#import "DaoDiAlertView.h"
#import "NewAchievementViewController.h"
#import "DDLGSideViewController.h"
#import <TZImagePickerController.h>
#import "QNDDUploadManager.h"
#import "CreateDTieRequest.h"
#import "WeChatManager.h"
#import "DTieWatchPhotoTableViewCell.h"
#import "DTieDetailRequest.h"
#import "DTieNewDetailViewController.h"
#import "RDAlertView.h"

@interface DTieReadView () <UITableViewDelegate, UITableViewDataSource, LiuyanDidComplete, TZImagePickerControllerDelegate>

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
@property (nonatomic, strong) NSMutableArray * photoSource;
@property (nonatomic, strong) NSMutableArray * contentSources;
@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) UIImage * firstImage;

@property (nonatomic, assign) BOOL isSelfFlg;

@property (nonatomic, strong) UIButton * jubaoButton;

@property (nonatomic, assign) BOOL isInsatllWX;

@property (nonatomic, assign) BOOL hasDaoDi;

@property (nonatomic, assign) BOOL isRemark;
@property (nonatomic, strong) UILabel * secondNumberLabel;
@property (nonatomic, assign) NSInteger second;

@property (nonatomic, strong) UIButton * uploadButton;

//约饭贴的内容
@property (nonatomic, assign) NSInteger WYYTab;
@property (nonatomic, assign) NSInteger WYYSelectType;
@property (nonatomic, strong) UILabel * WYYNumberLabel;
@property (nonatomic, strong) UIButton * leftWYYButton;
@property (nonatomic, strong) UIButton * rightWYYButton;
@property (nonatomic, strong) UISwitch * WYYAddPhotoSwitch;

@end

@implementation DTieReadView

- (instancetype)initWithFrame:(CGRect)frame model:(DTieModel *)model isRemark:(BOOL)remark
{
    if (self = [super initWithFrame:frame]) {
        
        self.isPreRead = NO;
        self.isRemark = remark;
        self.model = model;
        self.WYYTab = 1;
        self.isInsatllWX = [WXApi isWXAppInstalled];
        
        if (self.isRemark) {
            self.firstImage = [UIImage imageNamed:@"defaultRemarkFirst.jpg"];
        }else{
            self.firstImage = [UIImage imageNamed:@"defaultRemark.jpg"];
        }
        
        self.photoSource = [[NSMutableArray alloc] init];
        if (model.details) {
            [self sortWithDetails:model.details];
        }else{
            self.modelSources = [NSMutableArray new];
            
            if (!isEmptyString(self.model.postFirstPicture)) {
                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:self.model.postFirstPicture] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    
                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                    if (image) {
                        [[SDImageCache sharedImageCache] storeImage:image forKey:self.model.postFirstPicture toDisk:YES completion:nil];
                        self.firstImage = image;
                        [self configHeaderView];
                    }
                }];
            }
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
        [self createHeaderView];
        [self createfooterView];
        
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
                [self createHeaderView];
                
                [self sortWithDetails:self.model.details];
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
    
    CommentRequest * request = [[CommentRequest alloc] initWithPostID:postID];
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
    if (self.yaoyueList) {
        [self.modelSources sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            DTieEditModel * model1 = (DTieEditModel *)obj1;
            DTieEditModel * model2 = (DTieEditModel *)obj2;
            NSInteger detailNumber1 = model1.detailNumber;
            NSInteger detailNumber2 = model2.detailNumber;
            if (detailNumber1 > detailNumber2) {
                return NSOrderedAscending;
            }else if (detailNumber1 < detailNumber2) {
                return NSOrderedDescending;
            }else{
                return NSOrderedSame;
            }
        }];
    }
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"type == 2"];
    NSArray * tempArray = [self.modelSources filteredArrayUsingPredicate:predicate];
    [self.photoSource removeAllObjects];
    [self.photoSource addObjectsFromArray:tempArray];
    
    NSString * imageURL = self.model.postFirstPicture;
    if (!isEmptyString(imageURL)) {
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imageURL] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            if (image) {
                [[SDImageCache sharedImageCache] storeImage:image forKey:imageURL toDisk:YES completion:nil];
                self.firstImage = image;
                [self configHeaderView];
            }
        }];
    }
    
//    for (NSInteger i = 0; i < details.count; i++) {
//        DTieEditModel * model = [details objectAtIndex:i];
//        if (model.type == DTieEditType_Image) {
//            if (model.image) {
//                self.firstImage = model.image;
//            }else{
//                if (isEmptyString(imageURL)) {
//                    imageURL = model.detailContent;
//                }
//            }
//            [self.modelSources removeObject:model];
//            break;
//        }
//    }
//
//    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imageURL] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
//
//    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
//        [[SDImageCache sharedImageCache] storeImage:image forKey:imageURL toDisk:YES completion:nil];
//        self.firstImage = image;
//        [self configHeaderView];
//    }];
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
    if (!self.isRemark) {
        [self.firstImageView addGestureRecognizer:longPress];
        [self.firstImageView addGestureRecognizer:tap];
    }
    
    if (!self.isSelfFlg) {
        [self.dazhaohuButton addTarget:self action:@selector(dazhaohuButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    }
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
    
    if (self.isRemark) {
        self.secondNumberLabel.hidden = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(secondNumberChange) object:nil];
    }
    
    DTiePOIViewController * poi = [[DTiePOIViewController alloc] initWithDtieModel:self.model];
    [self.parentDDViewController pushViewController:poi animated:YES];
}

- (void)dazhaohuButtonDidClicked
{
    if (self.isSelfFlg) {
        
        if (self.parentDDViewController) {
            if (self.isRemark) {
                self.secondNumberLabel.hidden = YES;
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(secondNumberChange) object:nil];
            }
            
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
        if (self.isRemark) {
            self.secondNumberLabel.hidden = YES;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(secondNumberChange) object:nil];
        }
        
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
        if (self.isRemark) {
            self.secondNumberLabel.hidden = YES;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(secondNumberChange) object:nil];
        }
        
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
        if (self.WYYTab == 1) {
            return self.modelSources.count;
        }else if (self.WYYTab == 2) {
            
            NSInteger count = self.photoSource.count % 3;
            if (count > 0) {
                return self.photoSource.count / 3 + 1;
            }
            
            return self.photoSource.count / 3;
        }
    }
    return self.contentSources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        
        if (self.WYYTab == 2) {
            DTieWatchPhotoTableViewCell * watch = [tableView dequeueReusableCellWithIdentifier:@"DTieWatchPhotoTableViewCell" forIndexPath:indexPath];
            
            if (self.model.authorId == [UserManager shareManager].user.cid) {
                watch.isAuthor = YES;
            }else{
                watch.isAuthor = NO;
            }
            
            [watch resetStatus];
            NSInteger count = 0;
            for (NSInteger i = indexPath.row * 3; i < self.photoSource.count; i++) {
                DTieEditModel * model = [self.photoSource objectAtIndex:i];
                [watch configWithModel:model index:count];
                count++;
                if (count == 3) {
                    break;
                }
            }
            
            __weak typeof(self) weakSelf = self;
            watch.imageDidClicked = ^(DTieEditModel *editModel) {
                [weakSelf watchPhotoDidClicked:editModel];
            };
            
            watch.WYYSelectType = self.WYYSelectType;
            
            return watch;
        }
        DTieEditModel * model = [self.modelSources objectAtIndex:indexPath.row];
        
        if (model.pFlag == 1 && [[DDLocationManager shareManager] contentIsCanSeeWith:self.model detailModle:model]) {
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

- (void)watchPhotoDidClicked:(DTieEditModel *)model
{
    if (self.WYYSelectType == 0) {
        LookImageViewController * look = [[LookImageViewController alloc] initWithImageURL:model.detailContent];
        [self.parentDDViewController presentViewController:look animated:YES completion:nil];
    }else if (self.WYYSelectType == 2) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:DDLocalizedString(@"Information") message:@"确定使用该图片作为封面吗？" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * action1 = [UIAlertAction actionWithTitle:DDLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        UIAlertAction * action2 = [UIAlertAction actionWithTitle:DDLocalizedString(@"Yes") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            CreateDTieRequest * request = [[CreateDTieRequest alloc] initChangeFirstPicWithPostID:self.model.cid image:model.detailContent];
            
            MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:self];
            [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
                [hud hideAnimated:YES];
                UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:model.detailContent];
                
                if (!image) {
                    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:model.detailContent] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                        
                    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                        if (image) {
                            [[SDImageCache sharedImageCache] storeImage:image forKey:model.detailContent toDisk:YES completion:nil];
                            self.firstImage = image;
                            [self configHeaderView];
                        }
                    }];
                }else{
                    self.firstImage = image;
                    [self configHeaderView];
                }
                
                [MBProgressHUD showTextHUDWithText:@"设置封面成功" inView:self];
                
            } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
                [hud hideAnimated:YES];
                [MBProgressHUD showTextHUDWithText:@"设置封面失败" inView:self];
                
            } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
                
                [hud hideAnimated:YES];
                [MBProgressHUD showTextHUDWithText:@"设置封面失败" inView:self];
                
            }];
        }];
        
        [alert addAction:action1];
        [alert addAction:action2];
        [self.parentDDViewController presentViewController:alert animated:YES completion:nil];
    }
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
        DTieReadHandleFooterView * footer = [[DTieReadHandleFooterView alloc] initWithReuseIdentifier:@"DTieReadHandleFooterView"];
        
        footer.WYYSelectType = self.WYYSelectType;
        [footer configWithModel:self.model];
        
        __weak typeof(self) weakSelf = self;
        
        footer.locationButtonDidClicked = ^{
            [weakSelf locationButtonDidClicked];
        };
        
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
        
        footer.shareButtonDidClicked = ^{
            [weakSelf shareButtonDidClicked];
        };
        
        footer.addButtonDidClickedHandle = ^{
            [weakSelf checkWYYBlock];
        };
        
        footer.selectButtonDidClicked = ^(NSInteger type) {
            [weakSelf selectButtonDidClicked:type];
        };
        
        if (self.yaoyueList) {
            
            if (self.WYYTab == 1) {
                [footer configWithYaoyueModel:self.yaoyueList];
            }else if (self.WYYTab == 2) {
                [footer configWithWacthPhotos:self.yaoyueList];
            }
        }
        
        return footer;
    }
    
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"UITableViewHeaderFooterView"];
}

- (void)selectButtonDidClicked:(NSInteger)type
{
    NSInteger lastType = self.WYYSelectType;
    self.WYYSelectType = type;
    
    if (self.WYYSelectType == 0) {
        if (lastType == 1) {
            
            NSMutableArray * data = [[NSMutableArray alloc] init];
            for (DTieEditModel * model in self.photoSource) {
                if (model.isChoose) {
                    [data addObject:model];
                }
            }
            
            if (data.count > 0) {
                
                RDAlertView * alertView = [[RDAlertView alloc] initWithTitle:DDLocalizedString(@"Information") message:[NSString stringWithFormat:@"选中的%ld张图片即将被移除，请确认是否继续。", data.count]];
                RDAlertAction * action1 = [[RDAlertAction alloc] initWithTitle:DDLocalizedString(@"Cancel") handler:^{
                    
                } bold:NO];
                
                RDAlertAction * action2 = [[RDAlertAction alloc] initWithTitle:DDLocalizedString(@"Yes") handler:^{
                    
                    [self removeWithArray:data];
                    
                } bold:NO];
                
                [alertView addActions:@[action1, action2]];
                [alertView show];
            }
        }else if (lastType == 3) {
            NSMutableArray * data = [[NSMutableArray alloc] init];
            for (DTieEditModel * model in self.photoSource) {
                if (model.isChoose) {
                    [data addObject:model];
                }
            }
            
            if (data.count > 0) {
                [self createWithArray:data];
            }
        }
        
        [self.photoSource makeObjectsPerformSelector:@selector(changeNoSelect)];
        [self.tableView reloadData];
    }else{
        
        [self.photoSource makeObjectsPerformSelector:@selector(changeNoSelect)];
        [self.tableView reloadData];
    }
}

- (void)createWithArray:(NSArray *)data
{
    NSMutableArray * details = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < data.count; i++) {
        DTieEditModel * model = [data objectAtIndex:i];
        
        NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                @"datadictionaryType":model.datadictionaryType,
                                @"detailsContent":model.detailsContent,
                                @"textInformation":model.textInformation,
                                @"pFlag":@(model.pFlag),
                                @"wxCansee":@(model.wxCanSee),
                                @"authorID":@([UserManager shareManager].user.cid)};
        [details addObject:dict];
    }
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在生成" inView:self];
    
    CreateDTieRequest * request = [[CreateDTieRequest alloc] initWithList:details title:self.model.postSummary address:self.model.sceneAddress building:self.model.sceneBuilding addressLng:self.model.sceneAddressLng addressLat:self.model.sceneAddressLat status:1 remindFlg:1 firstPic:self.model.postFirstPicture postID:0 landAccountFlg:self.model.landAccountFlg allowToSeeList:self.model.allowToSeeList sceneTime:self.model.sceneTime];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSDictionary * data = [response objectForKey:@"data"];
        [hud hideAnimated:YES];
        
        if (!KIsDictionary(data)) {
            return;
        }
        NSInteger postId = [[data objectForKey:@"postId"] integerValue];
        
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:self];
        DTieDetailRequest * detailRequest = [[DTieDetailRequest alloc] initWithID:postId type:4 start:0 length:10];
        [detailRequest sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
            
            if (KIsDictionary(response)) {
                NSDictionary * data = [response objectForKey:@"data"];
                if (KIsDictionary(data)) {
                    DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                    
                    DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initWithDTie:dtieModel];
                    
                    [self.parentDDViewController pushViewController:detail animated:YES];
                }
            }
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            [hud hideAnimated:YES];
        }];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"生成失败" inView:self];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"生成失败" inView:self];
        
    }];
}

- (void)removeWithArray:(NSArray *)data
{
    NSMutableArray * dataSource = [[NSMutableArray alloc] initWithArray:self.model.details];
    [dataSource removeObjectsInArray:data];
    
    NSMutableArray * details = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < dataSource.count; i++) {
        DTieEditModel * model = [dataSource objectAtIndex:i];
        
        NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                @"datadictionaryType":model.datadictionaryType,
                                @"detailsContent":model.detailsContent,
                                @"textInformation":model.textInformation,
                                @"pFlag":@(model.pFlag),
                                @"wxCansee":@(model.wxCanSee),
                                @"authorID":@(model.authorID)};
        [details addObject:dict];
    }
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在删除照片" inView:self];
    CreateDTieRequest * request = [[CreateDTieRequest alloc] initRepelaceWithPostID:self.model.cid details:details];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"删除成功" inView:self];
        self.model.details = [NSArray arrayWithArray:dataSource];
        [self sortWithDetails:self.model.details];
        [self.tableView reloadData];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"删除失败" inView:self];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"删除失败" inView:self];
        
    }];
}

- (void)shareButtonDidClicked
{
    [[WeChatManager shareManager] shareMiniProgramWithPostID:self.model.cid image:self.firstImage isShare:NO title:self.model.postSummary];
}

- (void)backHomeDidClicked
{
    if (self.parentDDViewController) {
        [self.parentDDViewController popViewControllerAnimated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    if (section == 0) {
        
        if (self.yaoyueList.count > 0) {
            if (self.WYYTab == 1) {
                NSInteger count = self.yaoyueList.count + 2;
                
                CGFloat height = 144 * scale * count + 60 * scale;
                
                height = height + 144 * scale;
                
                if ([UserManager shareManager].user.cid == self.model.authorId) {
                    height = height + 144 * scale;
                }
                
                return 1100 * scale + height;
            }else if (self.WYYTab == 2){
                
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"userId == %d", [UserManager shareManager].user.cid];
                NSArray * tempArray = [self.yaoyueList filteredArrayUsingPredicate:predicate];
                
                if (tempArray.count > 0) {
                    if ([UserManager shareManager].user.cid == self.model.authorId) {
                        return 1000 * scale;
                    }else{
                        return 840 * scale;
                    }
                }else{
                    return 700 * scale;
                }
            }
        }else if (self.yaoyueList) {
            
            if (self.WYYTab == 1) {
                if ([UserManager shareManager].user.cid == self.model.authorId) {
                    return 1100 * scale + 3 * 144 * scale + 60 * scale + 144 * scale;
                }
                return 1100 * scale + 3 * 144 * scale + 60 * scale;
            }else if (self.WYYTab == 2){
                if ([UserManager shareManager].user.cid == self.model.authorId) {
                    return 1000 * scale;
                }else{
                    return 700 * scale;
                }
            }
            
        }else{
            return 1100 * scale;
        }
    }
    return .1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        CGFloat scale = kMainBoundsWidth / 1080.f;
        
        if (self.WYYTab == 2) {
            return (kMainBoundsWidth - 60 * scale * 4) / 3.f + 60 * scale;
        }
        
        DTieEditModel * model = [self.modelSources objectAtIndex:indexPath.row];
        
        CGFloat height = 0.1f;
        
        if (model.type == DTieEditType_Image) {
            
            if (model.image) {
                height = [DDTool getHeightWithImage:model.image] + 90 * scale;
            }else{
                if (isEmptyString(model.detailContent)) {
                    model.detailContent = model.detailsContent;
                }
                
                UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:model.detailContent];
                
                if (!image) {
                    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:model.detailContent] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                        
                    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                        if (image) {
                            [[SDImageCache sharedImageCache] storeImage:image forKey:model.detailContent toDisk:YES completion:nil];
                            model.image = image;
                            
                            if ([tableView.indexPathsForVisibleRows containsObject:indexPath]) {
                                [self.tableView beginUpdates];
                                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                [self.tableView endUpdates];
                            }
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
    [self.tableView registerClass:[DTieWatchPhotoTableViewCell class] forCellReuseIdentifier:@"DTieWatchPhotoTableViewCell"];
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
}

#pragma mark - 创建tableView脚视图
- (void)createfooterView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 144 * scale)];
    footerView.backgroundColor = [UIColor whiteColor];
    
    UIButton * commentButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xDB6283) title:DDLocalizedString(@"More")];
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
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:[UIApplication sharedApplication].keyWindow];
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
        model2.securitygroupName = DDLocalizedString(@"My Fans");
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
            if (self.isRemark) {
                self.secondNumberLabel.hidden = YES;
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(secondNumberChange) object:nil];
            }
            
            DTieSecurityViewController * vc = [[DTieSecurityViewController alloc] initWithSecurityList:modelList];
            [self.parentDDViewController pushViewController:vc animated:YES];
        }else{
            if (accountFlg == 1) {
                [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"CurrentOpen") inView:self.parentDDViewController.view];
            }else if (accountFlg == 2) {
                [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"CurrentPrivate") inView:self.parentDDViewController.view];
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

- (void)secondNumberChange
{
    self.second--;
    if (self.second == 0) {
        DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        UINavigationController * na = (UINavigationController *)lg.rootViewController;
        [na popViewControllerAnimated:YES];
    }
    self.secondNumberLabel.text = [NSString stringWithFormat:@"此 帖 在 %ld 秒 后 自 动 关 闭", self.second];
    [self performSelector:@selector(secondNumberChange) withObject:nil afterDelay:1.f];
}

- (void)firstImageDidClicked
{
    self.secondNumberLabel.hidden = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(secondNumberChange) object:nil];
    
    TZImagePickerController * picker = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    picker.allowPickingOriginalPhoto = NO;
    picker.allowPickingVideo = NO;
    picker.allowTakeVideo = NO;
    picker.showSelectedIndex = NO;
    picker.allowCrop = NO;
    
    [self.parentDDViewController presentViewController:picker animated:YES completion:nil];
}

#pragma mark - 选取照片
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos
{
    if (picker.showSelectedIndex) {
        
        NSMutableArray * details = [[NSMutableArray alloc] init];
        
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在上传" inView:self];
        QNDDUploadManager * manager = [[QNDDUploadManager alloc] init];
        
        if (photos.count > 0 && isEmptyString(self.model.postFirstPicture)) {
            self.firstImage = photos.firstObject;
        }
        
        __block NSInteger count = 0;
        NSInteger totalCount = photos.count+self.model.details.count;
        for (NSInteger i = self.model.details.count; i < totalCount; i++) {
            
            UIImage * image = [photos objectAtIndex:i-self.model.details.count];
            
            [manager uploadImage:image progress:^(NSString *key, float percent) {
                
            } success:^(NSString *url) {
                
                NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                        @"datadictionaryType":@"CONTENT_IMG",
                                        @"detailsContent":url,
                                        @"textInformation":@"",
                                        @"pFlag":@(0),
                                        @"wxCansee":@(1),
                                        @"authorID":@([UserManager shareManager].user.cid)
                                        };
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
        
        
    }else{
        UIImage * image = [photos firstObject];
        
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在上传" inView:self];
        QNDDUploadManager * manager = [[QNDDUploadManager alloc] init];
        [manager uploadImage:image progress:^(NSString *key, float percent) {
            
        } success:^(NSString *url) {
            
            CreateDTieRequest * request = [[CreateDTieRequest alloc] initChangeFirstPicWithPostID:self.model.cid image:url];
            [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
                [hud hideAnimated:YES];
                [MBProgressHUD showTextHUDWithText:@"上传成功" inView:self];
                self.model.postFirstPicture = url;
                self.firstImage = image;
                
                NSDictionary * data = [response objectForKey:@"data"];
                if (KIsArray(data)) {
                    self.model.details = [NSArray arrayWithArray:[DTieEditModel mj_objectArrayWithKeyValuesArray:data]];
                }
                
                [self configHeaderView];
                [self.tableView reloadData];
                
            } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
                [hud hideAnimated:YES];
                [MBProgressHUD showTextHUDWithText:@"上传失败" inView:self];
                
            } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
                
                [hud hideAnimated:YES];
                [MBProgressHUD showTextHUDWithText:@"上传失败" inView:self];
                
            }];
            
        } failed:^(NSError *error) {
            
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"上传失败" inView:self];
            
        }];
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
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在添加照片" inView:self];
    if (self.yaoyueList) {
        CreateDTieRequest * request = [[CreateDTieRequest alloc] initAddWYYWithPostID:self.model.cid blocks:details];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            if (self.model.details.count == 0) {
                self.model.details = [NSArray arrayWithArray:[DTieEditModel mj_objectArrayWithKeyValuesArray:details]];
            }else{
                NSMutableArray * data = [[NSMutableArray alloc] initWithArray:self.model.details];
                [data addObjectsFromArray:[DTieEditModel mj_objectArrayWithKeyValuesArray:details]];
                self.model.details = [NSArray arrayWithArray:data];
            }
            
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"上传成功" inView:self];
            [self sortWithDetails:self.model.details];
            
            if (self.photoSource.count > 0) {
                DTieEditModel * firstModel = self.photoSource.firstObject;
                self.model.postFirstPicture = firstModel.detailsContent;
                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:self.model.postFirstPicture] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    
                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                    if (image) {
                        [[SDImageCache sharedImageCache] storeImage:image forKey:self.model.postFirstPicture toDisk:YES completion:nil];
                        self.firstImage = image;
                        [self.firstImageView setImage:image];
                    }
                }];
            }
            
            [self configHeaderView];
            [self.tableView reloadData];
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"上传失败" inView:self];
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"上传失败" inView:self];
        }];
    }else{
        CreateDTieRequest * request = [[CreateDTieRequest alloc] initAddWithPostID:self.model.cid blocks:details];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            if (self.model.details.count == 0) {
                self.model.details = [NSArray arrayWithArray:[DTieEditModel mj_objectArrayWithKeyValuesArray:details]];
            }else{
                NSMutableArray * data = [[NSMutableArray alloc] initWithArray:self.model.details];
                [data addObjectsFromArray:[DTieEditModel mj_objectArrayWithKeyValuesArray:details]];
                self.model.details = [NSArray arrayWithArray:data];
            }
            
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"上传成功" inView:self];
            [self sortWithDetails:self.model.details];
            
            if (self.photoSource.count > 0) {
                DTieEditModel * model = self.photoSource.firstObject;
                self.model.postFirstPicture = model.detailsContent;
            }
            
            [self configHeaderView];
            [self.tableView reloadData];
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"上传失败" inView:self];
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"上传失败" inView:self];
        }];
    }
}

#pragma mark - 创建tableView头视图
- (void)createHeaderView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    if (self.headerView) {
        [self.headerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 550 * scale)];
    self.headerView.backgroundColor = [UIColor whiteColor];
    
    self.firstImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    self.firstImageView.clipsToBounds = YES;
    [self.headerView addSubview:self.firstImageView];
    [self.firstImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(.1f);
    }];
    
    if (self.isRemark) {
        self.second = 7;
        
        self.secondNumberLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentCenter];
        self.secondNumberLabel.text = @"此 帖 在 7 秒 后 自 动 关 闭";
        self.secondNumberLabel.backgroundColor = UIColorFromRGB(0xefeff4);
        [self.firstImageView addSubview:self.secondNumberLabel];
        [self.secondNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.mas_equalTo(0);
            make.height.mas_equalTo(120 * scale);
        }];
        
        self.firstImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(firstImageDidClicked)];
        [self.firstImageView addGestureRecognizer:tap];
        
        [self performSelector:@selector(secondNumberChange) withObject:nil afterDelay:1.f];
    }
    
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
    self.locationButton.enabled = NO;
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
    
    self.dazhaohuButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"打招呼"];
    [userView addSubview:self.dazhaohuButton];
    [self.dazhaohuButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-100 * scale);
        make.width.mas_equalTo(250 * scale);
        make.height.mas_equalTo(128 * scale);
        make.centerY.mas_equalTo(0);
    }];
    if (self.isSelfFlg) {
        
        UIButton * numberButton = [UIButton buttonWithType:UIButtonTypeCustom];
        numberButton.titleLabel.font = kPingFangRegular(32 * scale);
        [numberButton addTarget:self action:@selector(dazhaohuButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        numberButton.backgroundColor = UIColorFromRGB(0xDB6283);
        [userView addSubview:numberButton];
        [numberButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.dazhaohuButton);
            make.left.mas_equalTo(self.dazhaohuButton.mas_right).offset(5 * scale);
            make.width.mas_equalTo(42 * scale);
            make.height.mas_equalTo(42 * scale);
        }];
        [DDViewFactoryTool cornerRadius:21 * scale withView:numberButton];
        
        if (self.model.dzfCount == 0) {
            [numberButton setTitle:@"0" forState:UIControlStateNormal];
        }else if (self.model.dzfCount < 10) {
            [numberButton setTitle:[NSString stringWithFormat:@"%ld", self.model.dzfCount] forState:UIControlStateNormal];
        }else if (self.model.dzfCount < 100) {
            [numberButton setTitle:[NSString stringWithFormat:@"%ld", self.model.dzfCount] forState:UIControlStateNormal];
            [numberButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(80 * scale);
            }];
        }else if (self.model.dzfCount > 100) {
            [numberButton setTitle:@"99+" forState:UIControlStateNormal];
            [numberButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(80 * scale);
            }];
        }
        [self.dazhaohuButton setImage:[UIImage imageNamed:@"dazhaohuzuozhe"] forState:UIControlStateNormal];
        self.dazhaohuButton.alpha = .7f;
    }else{
        [self.dazhaohuButton setTitle:@" 打招呼" forState:UIControlStateNormal];
        [self.dazhaohuButton setImage:[UIImage imageNamed:@"dazhaohuzuozhe"] forState:UIControlStateNormal];
        
        BOOL canHandle = [[DDLocationManager shareManager] postIsCanDazhaohuWith:self.model];
        if (!canHandle) {
            self.dazhaohuButton.alpha = 0.7f;
        }
    }
    
    if (self.isRemark) {
        self.dazhaohuButton.hidden = YES;
    }
    
    self.locationLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [self.locationButton addSubview:self.locationLabel];
    [self.locationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0 * scale);
        make.right.mas_equalTo(-160 * scale);
        make.height.mas_equalTo(45 * scale);
        make.centerY.mas_equalTo(0);
    }];
    
    [self configHeaderView];
    [self configUserInteractionEnabled];
}

- (void)configHeaderView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    CGFloat height = (550 - 165) * scale;
    
    if (self.firstImage) {
//        CGFloat imageHeight = [DDTool getHeightWithImage:self.firstImage];
        CGFloat imageHeight = 720 * scale;
        height += imageHeight;
        [self.firstImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(imageHeight);
        }];
        [self.firstImageView setImage:self.firstImage];
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
        height += 10 * scale;
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(10 * scale);
        }];
    }
    
    if (self.yaoyueList) {
        
        //约饭帖
        height += 300 * scale;
        
        UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
        lineView.backgroundColor = UIColorFromRGB(0xefeff4);
        [self.headerView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(60 * scale);
            make.right.mas_equalTo(-60 * scale);
            make.height.mas_equalTo(3 * scale);
            make.top.mas_equalTo(self.locationButton.mas_bottom).offset(10 * scale);
        }];
        
        if (self.WYYNumberLabel.superview) {
            [self.WYYNumberLabel removeFromSuperview];
        }
        self.WYYNumberLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
        [self.headerView addSubview:self.WYYNumberLabel];
        [self.WYYNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(lineView.mas_bottom).offset(45 * scale);
            make.left.mas_equalTo(60 * scale);
            make.height.mas_equalTo(50 * scale);
        }];
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"type == 2"];
        NSArray * tempArray = [self.modelSources filteredArrayUsingPredicate:predicate];
        self.WYYNumberLabel.text = [NSString stringWithFormat:@"已上传%ld张", tempArray.count];
        
        if (self.model.authorId == [UserManager shareManager].user.cid) {
            height += 165 * scale;
            
            UILabel * addPhotonTipLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
            addPhotonTipLabel.text = @"允许参与者上传照片";
            [self.headerView addSubview:addPhotonTipLabel];
            [addPhotonTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(lineView.mas_bottom);
                make.left.mas_equalTo(60 * scale);
                make.height.mas_equalTo(160 * scale);
            }];
            
            if (self.WYYAddPhotoSwitch.superview) {
                [self.WYYAddPhotoSwitch removeFromSuperview];
            }
            self.WYYAddPhotoSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            self.WYYAddPhotoSwitch.onTintColor = UIColorFromRGB(0xDB6283);
            if (self.model.postClassification == 1) {
                self.WYYAddPhotoSwitch.on = YES;
            }
            [self.WYYAddPhotoSwitch addTarget:self action:@selector(switcDidChange:) forControlEvents:UIControlEventValueChanged];
            [self.headerView addSubview:self.WYYAddPhotoSwitch];
            [self.WYYAddPhotoSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(addPhotonTipLabel);
                make.right.mas_equalTo(-60 * scale);
                make.width.mas_equalTo(51);
                make.height.mas_equalTo(31);
            }];
            
            UIView * bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
            bottomLineView.backgroundColor = UIColorFromRGB(0xefeff4);
            [self.headerView addSubview:bottomLineView];
            [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(60 * scale);
                make.right.mas_equalTo(-60 * scale);
                make.height.mas_equalTo(3 * scale);
                make.top.mas_equalTo(addPhotonTipLabel.mas_bottom);
            }];
            
            [self.WYYNumberLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(lineView.mas_bottom).offset(210 * scale);
            }];
        }
        
        if (self.leftWYYButton.superview) {
            [self.leftWYYButton removeFromSuperview];
        }
        self.leftWYYButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"BrowsePhotos")];
        if (self.WYYTab == 2) {
            [self.leftWYYButton setTitle:DDLocalizedString(@"BrowsePost") forState:UIControlStateNormal];
        }
        [DDViewFactoryTool cornerRadius:60 * scale withView:self.leftWYYButton];
        self.leftWYYButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
        self.leftWYYButton.layer.borderWidth = 3 * scale;
        [self.headerView addSubview:self.leftWYYButton];
        [self.leftWYYButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.WYYNumberLabel.mas_bottom).offset(45 * scale);
            make.centerX.mas_equalTo(-kMainBoundsWidth/4.f);
            make.height.mas_equalTo(120 * scale);
            make.width.mas_equalTo(444 * scale);
        }];
        [self.leftWYYButton addTarget:self action:@selector(leftWYYButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.rightWYYButton.superview) {
            [self.rightWYYButton removeFromSuperview];
        }
        self.rightWYYButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"UploadPhotos")];
        [DDViewFactoryTool cornerRadius:60 * scale withView:self.rightWYYButton];
        self.rightWYYButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
        self.rightWYYButton.layer.borderWidth = 3 * scale;
        [self.headerView addSubview:self.rightWYYButton];
        [self.rightWYYButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.WYYNumberLabel.mas_bottom).offset(45 * scale);
            make.centerX.mas_equalTo(kMainBoundsWidth/4.f);
            make.height.mas_equalTo(120 * scale);
            make.width.mas_equalTo(444 * scale);
        }];
        [self.rightWYYButton addTarget:self action:@selector(rightWYYButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        
        NSPredicate* predicateUser = [NSPredicate predicateWithFormat:@"userId == %d", [UserManager shareManager].user.cid];
        NSArray * userArray = [self.yaoyueList filteredArrayUsingPredicate:predicateUser];
        
        if (userArray.count == 0) {
            self.rightWYYButton.hidden = YES;
        }else if (self.model.postClassification == 0) {
            if ([UserManager shareManager].user.cid != self.model.authorId) {
                self.rightWYYButton.hidden = YES;
            }
        }
        
    }else if (self.model.authorId == [UserManager shareManager].user.cid) {
        
        if (!self.isRemark) {
            height += 180 * scale;
            
            if (self.uploadButton.superview) {
                [self.uploadButton removeFromSuperview];
            }
            self.uploadButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"UploadPhotos")];
            [DDViewFactoryTool cornerRadius:60 * scale withView:self.uploadButton];
            self.uploadButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
            self.uploadButton.layer.borderWidth = 3 * scale;
            [self.headerView addSubview:self.uploadButton];
            [self.uploadButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.locationLabel.mas_bottom).offset(60 * scale);
                make.height.mas_equalTo(120 * scale);
                make.right.mas_equalTo(-60 * scale);
                make.left.mas_equalTo(60 * scale);
            }];
            [self.uploadButton addTarget:self action:@selector(uploadButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    self.headerView.frame = CGRectMake(0, 0, kMainBoundsWidth, height);
    
    self.tableView.tableHeaderView = self.headerView;
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:self.model.portraituri]];
    self.nameLabel.text = self.model.nickname;
    self.locationLabel.text = self.model.sceneBuilding;
    self.senceTimelabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.model.sceneTime];
}

//浏览照片和帖子切换
- (void)leftWYYButtonDidClicked
{
    if (self.WYYTab == 1) {
        self.WYYTab = 2;
        [self.leftWYYButton setTitle:DDLocalizedString(@"BrowsePost") forState:UIControlStateNormal];
    }else if (self.WYYTab == 2) {
        self.WYYTab = 1;
        [self.leftWYYButton setTitle:DDLocalizedString(@"BrowsePhotos") forState:UIControlStateNormal];
    }
    [self.tableView reloadData];
}

//上传照片
- (void)rightWYYButtonDidClicked
{
    TZImagePickerController * picker = [[TZImagePickerController alloc] initWithMaxImagesCount:100 delegate:self];
    picker.allowPickingOriginalPhoto = NO;
    picker.allowPickingVideo = NO;
    picker.showSelectedIndex = YES;
    picker.allowCrop = NO;
    [self.parentDDViewController presentViewController:picker animated:YES completion:nil];
}

- (void)switcDidChange:(UISwitch *)sender
{
    [SelectWYYBlockRequest cancelRequest];
    SelectWYYBlockRequest * request =  [[SelectWYYBlockRequest alloc] initSwitchWithPostID:self.model.cid status:sender.isOn];
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

- (void)uploadButtonDidClicked
{
    if (self.isRemark) {
        self.secondNumberLabel.hidden = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(secondNumberChange) object:nil];
    }
    
    TZImagePickerController * picker = [[TZImagePickerController alloc] initWithMaxImagesCount:100 delegate:self];
    picker.allowPickingOriginalPhoto = NO;
    picker.allowPickingVideo = NO;
    picker.showSelectedIndex = YES;
    picker.allowCrop = NO;
    [self.parentDDViewController presentViewController:picker animated:YES completion:nil];
}

@end
