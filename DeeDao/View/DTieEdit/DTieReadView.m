
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
#import <TZPhotoPickerController.h>
#import "QNDDUploadManager.h"
#import "CreateDTieRequest.h"
#import "WeChatManager.h"
#import "DTieWatchPhotoTableViewCell.h"
#import "DTieDetailRequest.h"
#import "DTieNewDetailViewController.h"
#import "RDAlertView.h"
#import "DTieDeleteRequest.h"
#import "RDAlertView.h"
#import "DTieCancleWYYRequest.h"
#import "YueFanViewController.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import "DTieEditTextViewController.h"
#import <PGDatePickManager.h>
#import "DDBackWidow.h"
#import "DTieChooseLocationController.h"
#import "DTieChooseDTieController.h"
#import "DTieEditRequest.h"
#import <YYText.h>
#import "DDGroupRequest.h"

@interface DTieReadView () <UITableViewDelegate, UITableViewDataSource, LiuyanDidComplete, TZImagePickerControllerDelegate, DTEditTextViewControllerDelegate, BMKMapViewDelegate, PGDatePickerDelegate, ChooseLocationDelegate, DTieChooseDTieControllerDelegate>

@property (nonatomic, strong) UIView * headerView;
@property (nonatomic, strong) UIImageView * firstImageView;
@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UIButton * locationButton;
@property (nonatomic, strong) UILabel * locationLabel;
@property (nonatomic, strong) UILabel * senceTimelabel;
@property (nonatomic, strong) UILabel * titleLabel;

@property (nonatomic, strong) UIButton * mygxqButton;
@property (nonatomic, strong) UIButton * mydzhButton;
@property (nonatomic, strong) UIButton * leftButton;
@property (nonatomic, strong) UIButton * centerButton;
@property (nonatomic, strong) UIButton * rightButton;

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
@property (nonatomic, strong) UILabel * addPhotonTipLabel;

@property (nonatomic, strong) UIView * mapBaseView;
@property (nonatomic, strong) BMKMapView * mapView;

//添加新的内容
@property (nonatomic, strong) UIView * addChooseView;
@property (nonatomic, strong) UIButton * addButton;
@property (nonatomic, strong) UIButton * tempAddButton;
@property (nonatomic, strong) UIButton * imageButton;
@property (nonatomic, strong) UIButton * videoButton;
@property (nonatomic, strong) UIButton * textButton;
@property (nonatomic, strong) UIButton * dtieButton;
@property (nonatomic, strong) UIButton * chooseButton;
@property (nonatomic, assign) NSInteger insertIndex;
@property (nonatomic, strong) DTieEditModel * currentModel;
@property (nonatomic, assign) BOOL isEditTitle;
@property (nonatomic, assign) BOOL isContentImagePicker;

@property (nonatomic, strong) NSMutableArray * groupSource;

@end

@implementation DTieReadView

- (instancetype)initWithFrame:(CGRect)frame model:(DTieModel *)model isRemark:(BOOL)remark
{
    if (self = [super initWithFrame:frame]) {
        
        self.isPreRead = NO;
        self.isRemark = remark;
        model.readTimes += 1;
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
        [self createChooseView];
        
        [self checkWYYBlock];
        [self getGroupList];
    }
    return self;
}

- (void)getGroupList
{
    DDGroupRequest * request = [[DDGroupRequest alloc] initGetPostGroupListWithPostID:self.model.cid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.model.groupArray removeAllObjects];
        NSArray * data = [response objectForKey:@"data"];
        if (KIsArray(data)) {
            [self.model.groupArray addObjectsFromArray:[DDGroupModel mj_objectArrayWithKeyValuesArray:data]];
        }
        [self.tableView reloadData];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)createChooseView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenChooseView)];
    self.addChooseView = [[UIView alloc] initWithFrame:self.bounds];
    self.addChooseView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
    [self.addChooseView addGestureRecognizer:tap];
    
    self.imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.imageButton setImage:[UIImage imageNamed:@"imageChoose"] forState:UIControlStateNormal];
    [self.addChooseView addSubview:self.imageButton];
    self.imageButton.frame = CGRectMake(0, 0, 120 * scale, 120 * scale);
    self.imageButton.center = self.addChooseView.center;
    [self.imageButton addTarget:self action:@selector(imageButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.videoButton setImage:[UIImage imageNamed:@"videoChoose"] forState:UIControlStateNormal];
    [self.addChooseView addSubview:self.videoButton];
    self.videoButton.frame = CGRectMake(0, 0, 120 * scale, 120 * scale);
    self.videoButton.center = self.addChooseView.center;
    [self.videoButton addTarget:self action:@selector(videoButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.textButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.textButton setImage:[UIImage imageNamed:@"textChoose"] forState:UIControlStateNormal];
    [self.addChooseView addSubview:self.textButton];
    self.textButton.frame = CGRectMake(0, 0, 120 * scale, 120 * scale);
    self.textButton.center = self.addChooseView.center;
    [self.textButton addTarget:self action:@selector(textButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.tempAddButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.tempAddButton setImage:[UIImage imageNamed:@"addEdit"] forState:UIControlStateNormal];
    [self.addChooseView addSubview:self.tempAddButton];
    self.tempAddButton.frame = CGRectMake(0, 0, 72 * scale, 72 * scale);
    self.tempAddButton.center = self.addChooseView.center;
    [self.tempAddButton addTarget:self action:@selector(hiddenChooseView) forControlEvents:UIControlEventTouchUpInside];
    
    self.dtieButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.dtieButton setImage:[UIImage imageNamed:@"dtieChoose"] forState:UIControlStateNormal];
    [self.addChooseView addSubview:self.dtieButton];
    self.dtieButton.frame = CGRectMake(0, 0, 120 * scale, 120 * scale);
    self.dtieButton.center = self.addChooseView.center;
    [self.dtieButton addTarget:self action:@selector(dtieButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)imageButtonDidClicked
{
    [self showChoosePhotoPicker];
    [self hiddenChooseView];
}

- (void)showChoosePhotoPicker
{
    self.isContentImagePicker = YES;
    
    TZImagePickerController * picker = [[TZImagePickerController alloc] initWithMaxImagesCount:100 delegate:self];
    picker.allowPickingOriginalPhoto = NO;
    picker.allowPickingVideo = NO;
    picker.allowTakeVideo = NO;
    picker.showSelectedIndex = YES;
    picker.allowCrop = NO;
    
    [self.parentDDViewController presentViewController:picker animated:YES completion:nil];
}

- (void)videoButtonDidClicked
{
    [self takeVideo];
    [self hiddenChooseView];
}

#pragma mark - 录制小视频
- (void)takeVideo
{
    self.isContentImagePicker = YES;
    
    TZImagePickerController * picker = [[TZImagePickerController alloc] initWithMaxImagesCount:100 delegate:self];
    picker.allowPickingOriginalPhoto = NO;
    picker.videoMaximumDuration = 30.f;
    picker.allowPickingMultipleVideo = YES;
    picker.allowPickingVideo = YES;
    picker.allowPickingImage = NO;
    picker.allowTakeVideo = YES;
    picker.showSelectedIndex = YES;
    picker.allowPreview = YES;
    
    [self.parentDDViewController presentViewController:picker animated:YES completion:nil];
}

- (void)textButtonDidClicked
{
    [self showTextEditController];
    [self hiddenChooseView];
}

#pragma mark - 编辑文字
- (void)showTextEditController
{
    DTieEditTextViewController * edit = [[DTieEditTextViewController alloc] initWithText:@"" placeholder:@"请输入文字"];
    edit.delegate = self;
    [self.parentDDViewController presentViewController:edit animated:YES completion:nil];
}

- (void)DTEditTextDidFinished:(NSString *)text
{
    if (self.currentModel) {
        
        NSInteger index = [self.modelSources indexOfObject:self.currentModel];
        
        if (isEmptyString(text)) {
            
            [self.dataSource removeObject:self.currentModel];
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            
        }else{
            self.currentModel.detailContent = text;
            
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        
    }else{
        
        if (self.isEditTitle) {
            self.model.postSummary = text;
            [self configHeaderView];
            
            DTieEditRequest * request = [[DTieEditRequest alloc] initWithTitle:text postID:self.model.cid];
            [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
            } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
            } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
                
            }];
            
        }else{
            DTieEditModel * model = [[DTieEditModel alloc] init];
            model.type = DTieEditType_Text;
            model.datadictionaryType = @"CONTENT_TEXT";
            model.detailContent = text;
            model.pFlag = 0;
            model.wxCanSee = 1;
            model.textInformation = @"";
            model.authorID = [UserManager shareManager].user.cid;

            [self.modelSources insertObject:model atIndex:self.insertIndex];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.insertIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
    }
    
    [self sortCurrentDetails];
    
    self.currentModel = nil;
    self.isEditTitle = NO;
}

- (void)DTEditTextDidCancle
{
    self.isEditTitle = NO;
    self.currentModel = nil;
}

- (void)dtieButtonDidClicked
{
    if (self.parentDDViewController) {
        DTieChooseDTieController * dtie = [[DTieChooseDTieController alloc] init];
        dtie.delegate = self;
        [self.parentDDViewController pushViewController:dtie animated:YES];
    }
    [self hiddenChooseView];
}

#pragma mark - DTieChooseDTieControllerDelegate选择D帖
- (void)didChooseDtie:(NSArray *)array
{
    for (NSInteger i = 0; i < array.count; i++) {

        DTieModel * dtieModel = [array objectAtIndex:i];

        DTieEditModel * model = [[DTieEditModel alloc] init];
        model.type = DTieEditType_Post;
        model.shareEnable = 0;
        model.datadictionaryType = @"CONTENT_POST";
        model.postFirstPicture = dtieModel.postFirstPicture;
        model.portraituri = dtieModel.portraituri;
        model.postSummary = dtieModel.postSummary;
        model.nickname = dtieModel.nickname;
        model.sceneBuilding = dtieModel.sceneBuilding;
        model.sceneAddress = dtieModel.sceneAddress;
        model.updateTime = dtieModel.updateTime;
        model.postId = dtieModel.postId;
        model.authorID = dtieModel.authorId;
        model.bloggerFlg = dtieModel.bloggerFlg;
        model.textInformation = @"";
        
        [self.modelSources insertObject:model atIndex:self.insertIndex];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.insertIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    
    [self sortCurrentDetails];
}

- (void)didSingleChooseDtie:(NSArray *)array
{
    NSInteger index = [self.modelSources indexOfObject:self.currentModel];
    
    DTieModel * model = array.firstObject;
    self.currentModel.postFirstPicture = model.postFirstPicture;
    self.currentModel.portraituri = model.portraituri;
    self.currentModel.postSummary = model.postSummary;
    self.currentModel.nickname = model.nickname;
    self.currentModel.sceneBuilding = model.sceneBuilding;
    self.currentModel.sceneAddress = model.sceneAddress;
    self.currentModel.updateTime = model.updateTime;
    [self.currentModel configPostID:model.postId];
    self.currentModel.authorID = model.authorId;
    self.currentModel.bloggerFlg = model.bloggerFlg;
    self.currentModel.textInformation = @"";
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
    [self sortCurrentDetails];
}

#pragma mark - 对现有的details的detailNumber进行排序
- (void)sortCurrentDetails
{
    NSMutableArray * details = [[NSMutableArray alloc] init];
    NSMutableArray * models = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < self.modelSources.count; i++) {
        DTieEditModel * model = [self.modelSources objectAtIndex:i];
        
        NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                @"datadictionaryType":model.datadictionaryType,
                                @"detailsContent":model.detailsContent,
                                @"textInformation":model.textInformation,
                                @"pFlag":@(model.pFlag),
                                @"wxCansee":@(model.wxCanSee),
                                @"authorID":@(model.authorID)};
        model.detailNumber = i+1;
        [models addObject:model];
        [details addObject:dict];
    }
    self.model.details = [NSArray arrayWithArray:models];
    self.modelSources = [NSMutableArray arrayWithArray:self.model.details];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"type == 2"];
    NSArray * tempArray = [self.modelSources filteredArrayUsingPredicate:predicate];
    [self.photoSource removeAllObjects];
    [self.photoSource addObjectsFromArray:tempArray];
    
    [CreateDTieRequest cancelRequest];
    
    CreateDTieRequest * request = [[CreateDTieRequest alloc] initRepelaceWithPostID:self.model.cid details:details];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

#pragma mark - 对details进行排序
- (NSMutableArray *)sortDetails:(NSMutableArray *)details
{
    [details sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
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
    return details;
}

#pragma mark - 添加新的元素
//添加按钮被点击
- (void)addButtonDidClicked:(UIButton *)button
{
    [self showChooseViewWithButton:button insertIndex:0];
}

//展示进行选择添加项
- (void)showChooseViewWithButton:(UIButton *)button insertIndex:(NSInteger)insertIndex;
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.chooseButton = button;
    self.insertIndex = insertIndex;
    self.chooseButton.hidden = YES;
    
    CGRect frame = [button convertRect:button.bounds toView:self];
    CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    
    [self addSubview:self.addChooseView];
    [self.addChooseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.imageButton.center = center;
    self.videoButton.center = center;
    self.textButton.center = center;
    self.dtieButton.center = center;
    self.tempAddButton.center = center;
    
    CGPoint leftCenter = CGPointMake(center.x - 150 * scale, center.y - 20 * scale);
    CGPoint leftCenter2 = CGPointMake(center.x - 70 * scale, center.y - 130 * scale);
    CGPoint rightCenter = CGPointMake(center.x + 70 * scale, center.y - 130 * scale);
    CGPoint rightCenter2 = CGPointMake(center.x + 150 * scale, center.y - 20 * scale);
    
    [UIView animateWithDuration:.5f delay:0.f usingSpringWithDamping:.5f initialSpringVelocity:15.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.imageButton.center = leftCenter;
        self.videoButton.center = leftCenter2;
        self.textButton.center = rightCenter;
        self.dtieButton.center = rightCenter2;
        self.addChooseView.alpha = 1;
        self.tempAddButton.transform = CGAffineTransformMakeRotation(M_PI/4.f);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hiddenChooseView
{
    [self.addChooseView removeFromSuperview];
    self.chooseButton.hidden = NO;
    self.tempAddButton.transform = CGAffineTransformMakeRotation(0);
    self.chooseButton = nil;
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
    
    if (isEmptyString(imageURL)) {
        if (self.photoSource.count > 0) {
            DTieEditModel * model = self.photoSource.firstObject;
            self.model.postFirstPicture = model.detailsContent;
            imageURL = model.detailsContent;
        }
    }
    
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

- (void)editTitleButtonDidClicked
{
    if (self.isRemark) {
        self.secondNumberLabel.hidden = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(secondNumberChange) object:nil];
    }
    self.isEditTitle = YES;
    DTieEditTextViewController * edit = [[DTieEditTextViewController alloc] initWithText:self.model.postSummary placeholder:@"请输入D帖标题"];
    edit.delegate = self;
    [self.parentDDViewController presentViewController:edit animated:YES completion:nil];
}

- (void)editTimeButtonDidClicked
{
    if (self.isRemark) {
        self.secondNumberLabel.hidden = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(secondNumberChange) object:nil];
    }
    PGDatePickManager *datePickManager = [[PGDatePickManager alloc]init];
    datePickManager.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    datePickManager.confirmButtonTextColor = UIColorFromRGB(0xDB6283);
    
    PGDatePicker *datePicker = datePickManager.datePicker;
    
    datePicker.delegate = self;
    datePicker.datePickerMode = PGDatePickerModeDateHourMinute;
    datePicker.textColorOfSelectedRow = UIColorFromRGB(0xDB6283);
    datePicker.lineBackgroundColor = UIColorFromRGB(0xDB6283);
    datePicker.middleTextColor = UIColorFromRGB(0xDB6283);
    
    NSInteger dateSecond = self.model.sceneTime / 1000;
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:dateSecond];
    [datePicker setDate:date];
    
    [self.parentDDViewController presentViewController:datePickManager animated:false completion:nil];
    [[DDBackWidow shareWindow] hidden];
}

- (void)datePicker:(PGDatePicker *)datePicker didSelectDate:(NSDateComponents *)dateComponents {
    
    NSDate * date = [NSDate setYear:dateComponents.year month:dateComponents.month day:dateComponents.day hour:dateComponents.hour minute:dateComponents.minute];
    self.model.sceneTime = [date timeIntervalSince1970] * 1000;
    NSString * str = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.model.sceneTime];
    self.senceTimelabel.text = str;
    
    DTieEditRequest * request = [[DTieEditRequest alloc] initWithTime:self.model.sceneTime postID:self.model.cid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)editLocationButtonDidClicked
{
    if (self.isRemark) {
        self.secondNumberLabel.hidden = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(secondNumberChange) object:nil];
    }
    DTieChooseLocationController * chosse = [[DTieChooseLocationController alloc] init];
    
    BMKPoiInfo * poi = [[BMKPoiInfo alloc] init];
    poi.pt = CLLocationCoordinate2DMake(self.model.sceneAddressLat, self.model.sceneAddressLng);
    poi.address = self.model.sceneAddress;
    poi.name = self.model.sceneBuilding;
    chosse.startPoi = poi;
    
    chosse.delegate = self;
    [self.parentDDViewController pushViewController:chosse animated:YES];
}

- (void)chooseLocationDidChoose:(BMKPoiInfo *)poi
{
    self.model.sceneAddressLat = poi.pt.latitude;
    self.model.sceneAddressLng = poi.pt.longitude;
    self.model.sceneAddress = poi.address;
    self.model.sceneBuilding = poi.name;
    
    self.locationLabel.text = [NSString stringWithFormat:@"%@", self.model.sceneBuilding];
    
    DTieEditRequest * request = [[DTieEditRequest alloc] initWithAddress:self.model.sceneAddress building:self.model.sceneBuilding lat:self.model.sceneAddressLat lng:self.model.sceneAddressLng postID:self.model.cid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
    
    [self configMapRegion];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    BMKAnnotationView * view = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BMKAnnotationView"];
    view.annotation = annotation;
    view.image = [UIImage imageNamed:@"location"];
    view.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:[UIView new]];
    
    return view;
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
        [DTieCollectionRequest cancelRequest];
        DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:self.model.cid type:2 subType:1 remark:text];
        
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            self.model.dzfFlg = 1;
            self.model.dzfCount++;
            
            [MBProgressHUD showTextHUDWithText:@"对方已收到您的信息" inView:[UIApplication sharedApplication].keyWindow];
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
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
            
            __weak typeof(self) weakSelf = self;
            __weak typeof(cell) weakCell = cell;
            cell.addButtonHandle = ^{
                
                NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
                [weakSelf showChooseViewWithButton:weakCell.addButton insertIndex:indexPath.row+1];
            };
            
            cell.upButtonHandle = ^{
                NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
                [weakSelf upButtonDidClickedWith:indexPath];
            };
            
            cell.downButtonHandle = ^{
                NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
                [weakSelf downButtonDidClickedWith:indexPath];
            };
            
            cell.deleteButtonHandle = ^{
                NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
                [weakSelf deleteButtonDidClickedWith:indexPath];
            };
            
            cell.editButtonHandle = ^{
                NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
                [weakSelf editButtonDidClickedWith:indexPath];
            };
            
            cell.shouldUpdateHandle = ^{
                [weakSelf sortCurrentDetails];
            };
            
            return cell;
        }else if (model.type == DTieEditType_Video) {
            DTieDetailVideoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieDetailVideoTableViewCell" forIndexPath:indexPath];
            
            [cell configWithModel:model Dtie:self.model];
            
            __weak typeof(self) weakSelf = self;
            __weak typeof(cell) weakCell = cell;
            cell.addButtonHandle = ^{
                
                NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
                [weakSelf showChooseViewWithButton:weakCell.addButton insertIndex:indexPath.row+1];
            };
            
            cell.upButtonHandle = ^{
                NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
                [weakSelf upButtonDidClickedWith:indexPath];
            };
            
            cell.downButtonHandle = ^{
                NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
                [weakSelf downButtonDidClickedWith:indexPath];
            };
            
            cell.deleteButtonHandle = ^{
                NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
                [weakSelf deleteButtonDidClickedWith:indexPath];
            };
            
            cell.editButtonHandle = ^{
                NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
                [weakSelf editButtonDidClickedWith:indexPath];
            };
            
            cell.shouldUpdateHandle = ^{
                [weakSelf sortCurrentDetails];
            };
            
            return cell;
        }else if (model.type == DTieEditType_Post) {
            
            DTieDetailPostTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieDetailPostTableViewCell" forIndexPath:indexPath];
            
            [cell configWithModel:model Dtie:self.model];
            
            __weak typeof(self) weakSelf = self;
            __weak typeof(cell) weakCell = cell;
            cell.addButtonHandle = ^{
                
                NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
                [weakSelf showChooseViewWithButton:weakCell.addButton insertIndex:indexPath.row+1];
            };
            
            cell.upButtonHandle = ^{
                NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
                [weakSelf upButtonDidClickedWith:indexPath];
            };
            
            cell.downButtonHandle = ^{
                NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
                [weakSelf downButtonDidClickedWith:indexPath];
            };
            
            cell.deleteButtonHandle = ^{
                NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
                [weakSelf deleteButtonDidClickedWith:indexPath];
            };
            
            cell.editButtonHandle = ^{
                NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
                [weakSelf editButtonDidClickedWith:indexPath];
            };
            
            return cell;
        }
        
        DTieDetailTextTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieDetailTextTableViewCell" forIndexPath:indexPath];
        
        [cell configWithModel:model Dtie:self.model];
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(cell) weakCell = cell;
        cell.addButtonHandle = ^{
            
            NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
            [weakSelf showChooseViewWithButton:weakCell.addButton insertIndex:indexPath.row+1];
        };
        
        cell.upButtonHandle = ^{
            NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
            [weakSelf upButtonDidClickedWith:indexPath];
        };
        
        cell.downButtonHandle = ^{
            NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
            [weakSelf downButtonDidClickedWith:indexPath];
        };
        
        cell.deleteButtonHandle = ^{
            NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
            [weakSelf deleteButtonDidClickedWith:indexPath];
        };
        
        cell.editButtonHandle = ^{
            NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
            [weakSelf editButtonDidClickedWith:indexPath];
        };
        
        cell.shouldUpdateHandle = ^{
            [weakSelf sortCurrentDetails];
        };
        
        return cell;
    }
    
    CommentModel * model = [self.contentSources objectAtIndex:indexPath.row];
    LiuYanTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"LiuYanTableViewCell" forIndexPath:indexPath];
    
    [cell configWithModel:model];
    
    return cell;
}

- (void)editButtonDidClickedWith:(NSIndexPath *)indexPath
{
    DTieEditModel * model = [self.modelSources objectAtIndex:indexPath.row];
    self.currentModel = model;
    self.insertIndex = indexPath.row;
    
    if (model.type == DTieEditType_Text) {
        
        DTieEditTextViewController * edit = [[DTieEditTextViewController alloc] initWithText:model.detailContent placeholder:@"请输入文字"];
        edit.delegate = self;
        [self.parentDDViewController presentViewController:edit animated:YES completion:nil];
        
    }else if (model.type == DTieEditType_Image) {
        
        RDAlertView * alertView = [[RDAlertView alloc] initWithTitle:@"设置封面" message:@"确定使用当前图片作为封面 吗？"];
        RDAlertAction * action1 = [[RDAlertAction alloc] initWithTitle:@"取消" handler:^{
            
        } bold:NO];
        RDAlertAction * action2 = [[RDAlertAction alloc] initWithTitle:@"确定" handler:^{
            
            CreateDTieRequest * request = [[CreateDTieRequest alloc] initChangeFirstPicWithPostID:model.postId image:model.detailsContent];
            [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
                [MBProgressHUD showTextHUDWithText:@"设为封面成功" inView:self];
                self.model.postFirstPicture = model.detailsContent;
                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:self.model.postFirstPicture] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    
                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                    if (image) {
                        [[SDImageCache sharedImageCache] storeImage:image forKey:self.model.postFirstPicture toDisk:YES completion:nil];
                        self.firstImage = image;
                        [self configHeaderView];
                    }
                }];
                
            } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
                [MBProgressHUD showTextHUDWithText:@"设为封面失败" inView:self];
                
            } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
                
                [MBProgressHUD showTextHUDWithText:@"设为封面失败" inView:self];
                
            }];
            
        } bold:YES];
        [alertView addActions:@[action1, action2]];
        [alertView show];
        
        
//        TZImagePickerController * picker = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
//        picker.allowPickingOriginalPhoto = NO;
//        picker.allowPickingVideo = NO;
//        picker.allowTakeVideo = NO;
//        picker.showSelectedIndex = NO;
//        picker.allowCrop = NO;
//
//        self.isContentImagePicker = YES;
//
//        [self.parentDDViewController presentViewController:picker animated:YES completion:nil];
        
    }else if (model.type == DTieEditType_Video) {
        TZImagePickerController * picker = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
        picker.allowPickingOriginalPhoto = NO;
        picker.videoMaximumDuration = 30.f;
        picker.allowPickingMultipleVideo = NO;
        picker.allowPickingVideo = YES;
        picker.allowPickingImage = NO;
        picker.allowTakeVideo = YES;
        picker.showSelectedIndex = NO;
        picker.allowPreview = YES;
        
        self.isContentImagePicker = YES;
        
        [self.parentDDViewController presentViewController:picker animated:YES completion:nil];
    }else if (model.type == DTieEditType_Post) {
        DTieChooseDTieController * dtie = [[DTieChooseDTieController alloc] init];
        dtie.isSingle = YES;
        dtie.delegate = self;
        [self.parentDDViewController pushViewController:dtie animated:YES];
    }
}

- (void)deleteButtonDidClickedWith:(NSIndexPath *)indexPath
{
    RDAlertView * alertView = [[RDAlertView alloc] initWithTitle:@"删除提示" message:@"确定删除当前模块吗？"];
    RDAlertAction * action1 = [[RDAlertAction alloc] initWithTitle:@"取消" handler:^{
        
    } bold:NO];
    RDAlertAction * action2 = [[RDAlertAction alloc] initWithTitle:@"确定" handler:^{
        
        [self.modelSources removeObjectAtIndex:indexPath.row];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        [self sortCurrentDetails];
        
    } bold:YES];
    [alertView addActions:@[action1, action2]];
    [alertView show];
}

- (void)upButtonDidClickedWith:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [MBProgressHUD showTextHUDWithText:@"已经到达最顶了哦~" inView:self.parentDDViewController.view];
    }else{
        
        [self.modelSources exchangeObjectAtIndex:indexPath.row withObjectAtIndex:indexPath.row-1];
        [self.tableView beginUpdates];
        NSIndexPath * exchangeIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:0];
        [self.tableView moveRowAtIndexPath:indexPath toIndexPath:exchangeIndexPath];
        [self.tableView endUpdates];
        
        [self sortCurrentDetails];
        
    }
}

- (void)downButtonDidClickedWith:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.modelSources.count-1) {
        [MBProgressHUD showTextHUDWithText:@"已经到达最底了哦~" inView:self.parentDDViewController.view];
    }else{
        
        [self.modelSources exchangeObjectAtIndex:indexPath.row withObjectAtIndex:indexPath.row+1];
        [self.tableView beginUpdates];
        NSIndexPath * exchangeIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
        [self.tableView moveRowAtIndexPath:indexPath toIndexPath:exchangeIndexPath];
        [self.tableView endUpdates];
        
        [self sortCurrentDetails];
        
    }
}

- (void)watchPhotoDidClicked:(DTieEditModel *)model
{
    if (self.WYYSelectType == 0) {
        LookImageViewController * look = [[LookImageViewController alloc] initWithImageURL:model.detailContent];
        [self.parentDDViewController presentViewController:look animated:YES completion:nil];
    }else if (self.WYYSelectType == 2) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:DDLocalizedString(@"Information") message:@"确定使用该图片作为封面吗？" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * action1 = [UIAlertAction actionWithTitle:DDLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.tableView reloadData];
        }];
        
        UIAlertAction * action2 = [UIAlertAction actionWithTitle:DDLocalizedString(@"Yes") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            CreateDTieRequest * request = [[CreateDTieRequest alloc] initChangeFirstPicWithPostID:self.model.cid image:model.detailContent];
            
            [self.tableView reloadData];
            
            MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:self];
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
        
        if (self.isRemark) {
            [header hiddenWithRemark];
        }
        
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
        
        if (self.isRemark) {
            [footer hiddenWithRemark];
        }
        
        __weak typeof(self) weakSelf = self;
        
        footer.locationButtonDidClicked = ^{
            [weakSelf locationButtonDidClicked];
        };
        
        footer.handleButtonDidClicked = ^{
            weakSelf.secondNumberLabel.hidden = YES;
            [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(secondNumberChange) object:nil];
        };
        
//        if (self.model.authorId == [UserManager shareManager].user.cid) {
//            footer.handleButtonDidClicked = ^{
//                [weakSelf seeButtonDidClicked];
//            };
//        }else{
//            footer.handleButtonDidClicked = ^{
//                [weakSelf jubaoButtonDidClicked];
//            };
//        }
        
        footer.jubaoButtonBlock = ^{
            [weakSelf jubaoButtonDidClicked];
        };
        
        if (!self.isPreRead) {
            footer.leftHandleButtonBlock = ^{
                [weakSelf leftButtonDidClicked];
            };
            
            footer.backHandleButtonBlock = ^{
                [weakSelf backHomeDidClicked];
            };
        }
        
        footer.rightHandleButtonBlock = ^{
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
        
        DTieCollectionRequest * collectRequest = [[DTieCollectionRequest alloc] initWithPostID:postId type:1 subType:0 remark:@""];
        
        [collectRequest sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
        }];
        
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:self];
        DTieDetailRequest * detailRequest = [[DTieDetailRequest alloc] initWithID:postId type:4 start:0 length:10];
        [detailRequest sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
            
            if (KIsDictionary(response)) {
                NSDictionary * data = [response objectForKey:@"data"];
                if (KIsDictionary(data)) {
                    DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                    dtieModel.wyyFlg = 1;
                    dtieModel.wyyCount = 1;
                    
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
                    height = height + 144 * scale + 150 * scale;
                }
                
                return 450 * scale + height;
            }else if (self.WYYTab == 2){
                
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"userId == %d", [UserManager shareManager].user.cid];
                NSArray * tempArray = [self.yaoyueList filteredArrayUsingPredicate:predicate];
                
                if (tempArray.count > 0) {
                    if ([UserManager shareManager].user.cid == self.model.authorId) {
                        return 900 * scale + 150 * scale;
                    }else{
                        return 740 * scale;
                    }
                }else{
                    if ([UserManager shareManager].user.cid == self.model.authorId) {
                        return 900 * scale + 150 * scale;
                    }else{
                        return 600 * scale;
                    }
                }
            }
        }else if (self.yaoyueList) {
            
            if (self.WYYTab == 1) {
                if ([UserManager shareManager].user.cid == self.model.authorId) {
                    return 450 * scale + 3 * 144 * scale + 60 * scale + 144 * scale + 150 * scale;
                }
                return 450 * scale + 3 * 144 * scale + 60 * scale;
            }else if (self.WYYTab == 2){
                if ([UserManager shareManager].user.cid == self.model.authorId) {
                    return 900 * scale + 150 * scale;
                }else{
                    return 600 * scale;
                }
            }
            
        }else{
            
            NSMutableAttributedString * groupStr = [[NSMutableAttributedString alloc] initWithString:@"群归属：" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
            
            if ([UserManager shareManager].user.cid == self.model.authorId) {
                NSMutableAttributedString * spaceStr = [[NSMutableAttributedString alloc] initWithString:@"我的" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x999999)}];
                [groupStr appendAttributedString:spaceStr];
                if (self.model.landAccountFlg == 1) {
                    NSMutableAttributedString * spaceStr1 = [[NSMutableAttributedString alloc] initWithString:@" 、" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
                    [groupStr appendAttributedString:spaceStr1];
                    NSMutableAttributedString * spaceStr2 = [[NSMutableAttributedString alloc] initWithString:@"公开" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x999999)}];
                    [groupStr appendAttributedString:spaceStr2];
                    if (self.model.groupArray.count > 0) {
                        NSMutableAttributedString * spaceStr3 = [[NSMutableAttributedString alloc] initWithString:@" 、" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
                        [groupStr appendAttributedString:spaceStr3];
                    }else{
                        NSMutableAttributedString * spaceStr = [[NSMutableAttributedString alloc] initWithString:@"  " attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
                        [groupStr appendAttributedString:spaceStr];
                    }
                }else{
                    if (self.model.groupArray.count > 0) {
                        NSMutableAttributedString * spaceStr = [[NSMutableAttributedString alloc] initWithString:@" 、" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
                        [groupStr appendAttributedString:spaceStr];
                    }else{
                        NSMutableAttributedString * spaceStr = [[NSMutableAttributedString alloc] initWithString:@"  " attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
                        [groupStr appendAttributedString:spaceStr];
                    }
                }
            }else  if (self.model.landAccountFlg == 1) {
                NSMutableAttributedString * spaceStr = [[NSMutableAttributedString alloc] initWithString:@"公开" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x999999)}];
                [groupStr appendAttributedString:spaceStr];
                if (self.model.groupArray.count > 0) {
                    NSMutableAttributedString * spaceStr = [[NSMutableAttributedString alloc] initWithString:@" 、" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
                    [groupStr appendAttributedString:spaceStr];
                }else{
                    NSMutableAttributedString * spaceStr = [[NSMutableAttributedString alloc] initWithString:@"  " attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
                    [groupStr appendAttributedString:spaceStr];
                }
            }
            
            for (NSInteger i = 0; i < self.model.groupArray.count ; i++) {
                DDGroupModel * group = [self.model.groupArray objectAtIndex:i];
                if (group.postFlag == 2) {
                    NSMutableAttributedString * tempStr = [[NSMutableAttributedString alloc] initWithString:group.groupName attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0xB721FF)}];
                    [groupStr appendAttributedString:tempStr];
                }else{
                    NSMutableAttributedString * tempStr = [[NSMutableAttributedString alloc] initWithString:group.groupName attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0xDB6283)}];
                    [groupStr appendAttributedString:tempStr];
                }
                
                if (i == self.model.groupArray.count-1) {
                    NSMutableAttributedString * spaceStr = [[NSMutableAttributedString alloc] initWithString:@"  " attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
                    [groupStr appendAttributedString:spaceStr];
                }else{
                    NSMutableAttributedString * spaceStr = [[NSMutableAttributedString alloc] initWithString:@" 、" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
                    [groupStr appendAttributedString:spaceStr];
                }
            }
            
            UIImage * image = [UIImage imageNamed:@"addGroup"];
            NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:image.size alignToFont:kPingFangRegular(36 * scale) alignment:YYTextVerticalAlignmentCenter];
            [groupStr appendAttributedString:attachText];
            
            //计算文本尺寸
            YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(kMainBoundsWidth - 120 * scale, 10000) text:groupStr];
            YYLabel * groupLabel = [[YYLabel alloc] init];
            groupLabel.numberOfLines = 0;
            groupLabel.attributedText = groupStr;
            groupLabel.preferredMaxLayoutWidth = kMainBoundsWidth - 120 * scale;
            groupLabel.textLayout = layout;
            CGFloat introHeight = layout.textBoundingSize.height;
            
            if ([UserManager shareManager].user.cid == self.model.authorId) {
                return 350 * scale + 150 * scale + introHeight;
            }
            return 350 * scale + introHeight;
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
            
            if (height == 0.1f) {
                height = 100 * scale;
            }
            
            if (self.isSelfFlg) {
                height += 300 * scale;
                height += 120 * scale;
            }
            
        }else if (model.type == DTieEditType_Video){
            
            height = (kMainBoundsWidth - 120 * scale) / 4.f * 3.f + 90 * scale;
            
            if (self.isSelfFlg) {
                height += 300 * scale;
                height += 120 * scale;
            }
            
            
        }else if (model.type == DTieEditType_Text) {
            
            height = [DDTool getHeightByWidth:kMainBoundsWidth - 120 * scale - 120 * scale title:model.detailsContent font:kPingFangRegular(42 * scale)] + 100 * scale + 120 * scale;
            
            if (self.isSelfFlg) {
                height += 300 * scale;
                height += 120 * scale;
            }
            
        }else if (model.type == DTieEditType_Post) {
             height = 800 * scale + 90 * scale;
            if (self.isSelfFlg) {
                height += 144 * scale;
                height += 120 * scale;
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
    if (self.isRemark) {
        
    }else{
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
}

- (void)seeButtonDidClicked
{
    
//    if (self.isPreRead) {
//        [MBProgressHUD showTextHUDWithText:@"预览状态无法进行查看~" inView:self];
//        return;
//    }
//
//    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:[UIApplication sharedApplication].keyWindow];
//    GetDtieSecurityRequest * request = [[GetDtieSecurityRequest alloc] initWithModel:self.model];
//    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
//
//        [hud hideAnimated:YES];
//
//        NSMutableArray * modelList =  [[NSMutableArray alloc] init];
//        NSInteger accountFlg = self.model.landAccountFlg;
//
//        SecurityGroupModel * model1 = [[SecurityGroupModel alloc] init];
//        model1.cid = -1;
//        model1.securitygroupName = @"所有朋友";
//        model1.securitygroupPropName = @"所有朋友可见";
//        model1.isChoose = YES;
//        model1.isNotification = YES;
//
//        SecurityGroupModel * model2 = [[SecurityGroupModel alloc] init];
//        model2.cid = -2;
//        model2.securitygroupName = DDLocalizedString(@"My Fans");
//        model2.securitygroupPropName = @"关注我的人可见";
//        model2.isChoose = YES;
//        model2.isNotification = YES;
//        if (accountFlg == 3) {
//            [modelList addObject:model1];
//        }else if (accountFlg == 5) {
//            [modelList addObject:model2];
//        }else if (accountFlg == 6) {
//            [modelList addObject:model1];
//            [modelList addObject:model2];
//        }else if (accountFlg == 7) {
//            [modelList addObject:model2];
//        }
//
//        if (KIsDictionary(response)) {
//            NSArray * data = [response objectForKey:@"data"];
//            for (NSDictionary * dict in data) {
//                SecurityGroupModel * model = [SecurityGroupModel mj_objectWithKeyValues:dict];
//                [modelList addObject:model];
//            }
//        }
//
//        if (modelList.count > 0) {
//            if (self.isRemark) {
//                self.secondNumberLabel.hidden = YES;
//                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(secondNumberChange) object:nil];
//            }
//
//            DTieSecurityViewController * vc = [[DTieSecurityViewController alloc] initWithSecurityList:modelList];
//            [self.parentDDViewController pushViewController:vc animated:YES];
//        }else{
//            if (accountFlg == 1) {
//                [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"CurrentOpen") inView:self.parentDDViewController.view];
//            }else if (accountFlg == 2) {
//                [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"CurrentPrivate") inView:self.parentDDViewController.view];
//            }else{
//                [MBProgressHUD showTextHUDWithText:@"没有权限设置" inView:self.parentDDViewController.view];
//            }
//        }
//
//    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
//
//        [hud hideAnimated:YES];
//
//    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
//
//        [hud hideAnimated:YES];
//
//    }];
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        TZPhotoPickerController * preview = (TZPhotoPickerController *)picker.topViewController;
        if ([preview isKindOfClass:[TZPhotoPickerController class]]) {
            [preview performSelector:@selector(takePhoto)];
        }
    });
}

#pragma mark - 选取照片
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos
{
    if (self.isContentImagePicker) {
        
        NSInteger editIndex = [self.modelSources indexOfObject:self.currentModel];
        
        if (picker.allowPickingImage) {
            
            if (self.currentModel) {
                
                MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在上传图片" inView:self.parentDDViewController.view];
                QNDDUploadManager * manager = [[QNDDUploadManager alloc] init];
                [manager uploadImage:photos.firstObject progress:^(NSString *key, float percent) {
                    
                } success:^(NSString *url) {
                    
                    DTieEditModel * editModel = [self.modelSources objectAtIndex:editIndex];
                    
                    editModel.detailContent = url;
                    editModel.image = photos.firstObject;
                    editModel.postId = self.model.cid;
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:editIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                    
                    [self sortCurrentDetails];
                    
                    [hud hideAnimated:YES];
                    
                } failed:^(NSError *error) {
                    
                    [hud hideAnimated:YES];
                    [MBProgressHUD showTextHUDWithText:@"上传图片失败" inView:self.parentDDViewController.view];
                    
                }];
                
            }else{
                MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在上传图片" inView:self.parentDDViewController.view];
                
                NSMutableArray * tempDetails = [[NSMutableArray alloc] init];
                QNDDUploadManager * manager = [[QNDDUploadManager alloc] init];
                
                if (photos.count > 0 && isEmptyString(self.model.postFirstPicture)) {
                    self.firstImage = photos.firstObject;
                }
                
                __block NSInteger count = 0;
                
                for (NSInteger i = 0; i < photos.count; i++) {
                    UIImage * image = [photos objectAtIndex:i];
                    
                    [manager uploadImage:image progress:^(NSString *key, float percent) {
                        
                    } success:^(NSString *url) {
                        
                        DTieEditModel * model = [[DTieEditModel alloc] init];
                        model.type = DTieEditType_Image;
                        model.datadictionaryType = @"CONTENT_IMG";
                        model.detailContent = url;
                        model.pFlag = 0;
                        model.wxCanSee = 1;
                        model.textInformation = @"";
                        model.authorID = [UserManager shareManager].user.cid;
                        model.detailNumber = i+1;
                        model.postId = self.model.cid;
                        [tempDetails addObject:model];
                        count++;
                        
                        if (count == photos.count) {
                            
                            [self sortDetails:tempDetails];
                            [self.modelSources insertObjects:tempDetails atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.insertIndex, tempDetails.count)]];
                            [self.tableView reloadData];
                            [self sortCurrentDetails];
                            
                            [hud hideAnimated:YES];
                        }
                        
                    } failed:^(NSError *error) {
                        count++;
                        if (count == photos.count) {
                            
                            [self sortDetails:tempDetails];
                            [self.modelSources insertObjects:tempDetails atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.insertIndex, tempDetails.count)]];
                            [self.tableView reloadData];
                            [self sortCurrentDetails];
                            
                            [hud hideAnimated:YES];
                        }
                        
                    }];
                }
            }
            
        }else{
            
            if (self.currentModel) {
                
                
            }else{
                
                MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在上传视频" inView:self.parentDDViewController.view];
                
                NSMutableArray * tempDetails = [[NSMutableArray alloc] init];
                QNDDUploadManager * manager = [[QNDDUploadManager alloc] init];
                
                if (photos.count > 0 && isEmptyString(self.model.postFirstPicture)) {
                    self.firstImage = photos.firstObject;
                }
                
                __block NSInteger count = 0;
                
                for (NSInteger i = 0; i < photos.count; i++) {
                    
                    UIImage * image = [photos objectAtIndex:i];
                    PHAsset * asset = [assets objectAtIndex:i];
                    
                    [manager uploadImage:image progress:^(NSString *key, float percent) {
                        
                    } success:^(NSString *url) {
                        
                        DTieEditModel * model = [[DTieEditModel alloc] init];
                        model.detailContent = url;
                        model.type = DTieEditType_Video;
                        model.datadictionaryType = @"CONTENT_VIDEO";
                        model.wxCanSee = 1;
                        model.authorID = [UserManager shareManager].user.cid;
                        model.detailNumber = i+1;
                        model.pFlag = 0;
                        model.postId = self.model.cid;
                        
                        [manager uploadPHAsset:asset progress:^(NSString *key, float percent) {
                            
                        } success:^(NSString *url) {
                            
                            model.textInformation = url;
                            [tempDetails addObject:model];
                            count++;
                            
                            if (count == photos.count) {
                                
                                [self sortDetails:tempDetails];
                                [self.modelSources insertObjects:tempDetails atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.insertIndex, tempDetails.count)]];
                                [self.tableView reloadData];
                                [self sortCurrentDetails];
                                
                                [hud hideAnimated:YES];
                            }
                            
                        } failed:^(NSError *error) {
                            count++;
                            if (count == photos.count) {
                                
                                [self sortDetails:tempDetails];
                                [self.modelSources insertObjects:tempDetails atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.insertIndex, tempDetails.count)]];
                                [self.tableView reloadData];
                                [self sortCurrentDetails];
                                
                                [hud hideAnimated:YES];
                            }
                            
                        }];
                        
                    } failed:^(NSError *error) {
                        [hud hideAnimated:YES];
                    }];
                }
                
            }
            
        }
        
    }else{
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
    
    self.currentModel = nil;
    self.isContentImagePicker = NO;
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset
{
    NSInteger editIndex = [self.modelSources indexOfObject:self.currentModel];
    
    if (self.currentModel) {
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在上传视频" inView:self.parentDDViewController.view];
        QNDDUploadManager * manager = [[QNDDUploadManager alloc] init];
        [manager uploadImage:coverImage progress:^(NSString *key, float percent) {
            
        } success:^(NSString *url) {
            
            DTieEditModel * editModel = [self.modelSources objectAtIndex:editIndex];
            editModel.detailContent = url;
            editModel.image = coverImage;
            
            [manager uploadPHAsset:asset progress:^(NSString *key, float percent) {
                
            } success:^(NSString *url) {
                
                editModel.textInformation = url;
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:editIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                
                [self sortCurrentDetails];
                
                [hud hideAnimated:YES];
                
            } failed:^(NSError *error) {
                [hud hideAnimated:YES];
            }];
            
        } failed:^(NSError *error) {
            
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"上传视频失败" inView:self.parentDDViewController.view];
            
        }];
    }
    self.currentModel = nil;
    self.isContentImagePicker = NO;
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker
{
    self.currentModel = nil;
    self.isContentImagePicker = NO;
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
                NSMutableArray * data = [[NSMutableArray alloc] init];
                
                for (NSInteger i = 0; i < details.count; i++) {
                    NSDictionary * dict = [details objectAtIndex:i];
                    DTieEditModel * editModel = [DTieEditModel mj_objectWithKeyValues:dict];
                    editModel.postId = self.model.cid;
                    [data addObject:editModel];
                }
                self.model.details = [NSArray arrayWithArray:data];
            }else{
                NSMutableArray * data = [[NSMutableArray alloc] initWithArray:self.model.details];
                for (NSInteger i = 0; i < details.count; i++) {
                    NSDictionary * dict = [details objectAtIndex:i];
                    DTieEditModel * editModel = [DTieEditModel mj_objectWithKeyValues:dict];
                    editModel.postId = self.model.cid;
                    [data addObject:editModel];
                }
                self.model.details = [NSArray arrayWithArray:data];
            }
            
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"上传成功" inView:self];
            [self sortWithDetails:self.model.details];
            
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
            
            [hud hideAnimated:YES];
            if (self.model.details.count == 0) {
                NSMutableArray * data = [[NSMutableArray alloc] init];
                
                for (NSInteger i = 0; i < details.count; i++) {
                    NSDictionary * dict = [details objectAtIndex:i];
                    DTieEditModel * editModel = [DTieEditModel mj_objectWithKeyValues:dict];
                    editModel.postId = self.model.cid;
                    [data addObject:editModel];
                }
                self.model.details = [NSArray arrayWithArray:data];
                
                [MBProgressHUD showTextHUDWithText:@"上传成功，首张图片默认为封面图" inView:self];
            }else{
                NSMutableArray * data = [[NSMutableArray alloc] initWithArray:self.model.details];
                
                for (NSInteger i = 0; i < details.count; i++) {
                    NSDictionary * dict = [details objectAtIndex:i];
                    DTieEditModel * editModel = [DTieEditModel mj_objectWithKeyValues:dict];
                    editModel.postId = self.model.cid;
                    [data addObject:editModel];
                }
                
                self.model.details = [NSArray arrayWithArray:data];
                [MBProgressHUD showTextHUDWithText:@"上传成功" inView:self];
            }
            
            [self sortWithDetails:self.model.details];
            
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
    
    self.titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangMedium(72 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    self.titleLabel.numberOfLines = 0;
    [self.headerView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.firstImageView.mas_bottom).offset(20 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(165 * scale);
    }];
    
    if (self.isSelfFlg) {
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-90 * scale);
        }];
        
        UIButton * editTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [editTitleButton setImage:[UIImage imageNamed:@"editTitle"] forState:UIControlStateNormal];
        [self.headerView addSubview:editTitleButton];
        [editTitleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.titleLabel);
            make.right.mas_equalTo(-30 * scale);
            make.width.height.mas_equalTo(60 * scale);
        }];
        [editTitleButton addTarget:self action:@selector(editTitleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIView * userView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 144 * scale)];
    [self.headerView addSubview:userView];
    [userView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(20 * scale);
        make.height.mas_equalTo(144 * scale);
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
    
    self.mydzhButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(38 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@""];
    [self.mydzhButton setBackgroundColor:[UIColor whiteColor]];
    [self.mydzhButton addTarget:self action:@selector(dazhaohuButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [userView addSubview:self.mydzhButton];
    [self.mydzhButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-30 * scale);
        make.height.mas_equalTo(100 * scale);
        make.width.mas_equalTo(250 * scale);
        make.centerY.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:50 * scale withView:self.mydzhButton];
    self.mydzhButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.mydzhButton.layer.borderWidth = 4 * scale;
    
    self.mygxqButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(38 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@""];
    [self.mygxqButton setBackgroundColor:[UIColor whiteColor]];
    [self.mygxqButton addTarget:self action:@selector(handleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [userView addSubview:self.mygxqButton];
    [self.mygxqButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mydzhButton.mas_left).offset(-30 * scale);
        make.height.mas_equalTo(100 * scale);
        make.width.mas_equalTo(200 * scale);
        make.centerY.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:50 * scale withView:self.mygxqButton];
    self.mygxqButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.mygxqButton.layer.borderWidth = 4 * scale;
    
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
    
    self.locationLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [self.locationButton addSubview:self.locationLabel];
    [self.locationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0 * scale);
        make.right.mas_equalTo(-160 * scale);
        make.height.mas_equalTo(45 * scale);
        make.centerY.mas_equalTo(0);
    }];
    
    self.mapBaseView = [[UIView alloc] initWithFrame:CGRectZero];
    self.mapBaseView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.headerView addSubview:self.mapBaseView];
    [self.mapBaseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.locationButton.mas_bottom).offset(30 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(450 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    self.mapBaseView.layer.cornerRadius = 24 * scale;
    self.mapBaseView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    self.mapBaseView.layer.shadowOpacity = .3f;
    self.mapBaseView.layer.shadowRadius = 24 * scale;
    self.mapBaseView.layer.shadowOffset = CGSizeMake(0, 12 * scale);
    
    UIView * mapBGView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.mapBaseView addSubview:mapBGView];
    [mapBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0 * scale);
    }];
    
    UITapGestureRecognizer * mapTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationButtonDidClicked)];
    [mapBGView addGestureRecognizer:mapTap];
    
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
    
    [mapBGView addSubview:self.mapView];
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
    
    if (self.isSelfFlg) {
        [self.mapBaseView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(570 * scale);
        }];
        
        [mapBGView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-120 * scale);
        }];
        
        UIButton * editTimeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"修改时间"];
        [self.mapBaseView addSubview:editTimeButton];
        [editTimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.mas_equalTo(0);
            make.width.mas_equalTo((kMainBoundsWidth - 120 * scale)/2.f);
            make.height.mas_equalTo(120 * scale);
        }];
        [editTimeButton addTarget:self action:@selector(editTimeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        
        UIView * mapLineView = [[UIView alloc] initWithFrame:CGRectZero];
        mapLineView.backgroundColor = UIColorFromRGB(0xDB6283);
        [self.mapBaseView addSubview:mapLineView];
        [mapLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(editTimeButton);
            make.height.mas_equalTo(60 * scale);
            make.width.mas_equalTo(3 * scale);
            make.centerX.mas_equalTo(0);
        }];
        
        UIButton * editLocationButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"修改地点"];
        [self.mapBaseView addSubview:editLocationButton];
        [editLocationButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.mas_equalTo(0);
            make.width.mas_equalTo((kMainBoundsWidth - 120 * scale)/2.f);
            make.height.mas_equalTo(120 * scale);
        }];
        [editLocationButton addTarget:self action:@selector(editLocationButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        
        self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.addButton setImage:[UIImage imageNamed:@"addEdit"] forState:UIControlStateNormal];
        [self.headerView addSubview:self.addButton];
        [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-20 * scale);
            make.centerX.mas_equalTo(0);
            make.width.height.mas_equalTo(72 * scale);
        }];
        [self.addButton addTarget:self action:@selector(addButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self configHeaderView];
    [self configUserInteractionEnabled];
    [self configMapRegion];
}

- (void)configHeaderView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    CGFloat height = (1050 - 165) * scale;
    
    if (self.isSelfFlg) {
        height = (1270 -165) * scale;
    }
    
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
    
    if (isEmptyString(title)) {
        title = DDLocalizedString(@"NoTitle");
    }
    
    if (!isEmptyString(title)) {
        
        CGFloat tempWidth = kMainBoundsWidth - 120 * scale;
        if (self.isSelfFlg) {
            tempWidth = kMainBoundsWidth - 150 * scale;
        }
        
        CGFloat tempHeight = [DDTool getHeightByWidth:tempWidth title:title font:kPingFangRegular(72 * scale)];
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
    
//    if (self.isRemark) {
//
//    }else{
//
//    }
    
    if (self.yaoyueList) {
        
        if (self.leftButton.superview) {
            [self.leftButton removeFromSuperview];
        }
        
        if (self.centerButton.superview) {
            [self.centerButton removeFromSuperview];
        }
        
        if (self.rightButton.superview) {
            [self.rightButton removeFromSuperview];
        }
        
        //约饭帖
        height += 300 * scale;
        
        UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
        lineView.backgroundColor = UIColorFromRGB(0xefeff4);
        [self.headerView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(60 * scale);
            make.right.mas_equalTo(-60 * scale);
            make.height.mas_equalTo(3 * scale);
            make.top.mas_equalTo(self.mapBaseView.mas_bottom).offset(80 * scale);
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
            
            UIView * tempView = [self.headerView viewWithTag:999];
            if (tempView) {
                [tempView removeFromSuperview];
            }
            
            UIView * addPhotoView = [[UIView alloc] initWithFrame:CGRectZero];
            addPhotoView.tag = 999;
            [self.headerView addSubview:addPhotoView];
            [addPhotoView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(lineView.mas_bottom);
                make.left.mas_equalTo(60 * scale);
                make.height.mas_equalTo(163 * scale);
                make.right.mas_equalTo(-60 * scale);
            }];
            
            self.addPhotonTipLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
            self.addPhotonTipLabel.text = @"允许参与者上传照片";
            [addPhotoView addSubview:self.addPhotonTipLabel];
            [self.addPhotonTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
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
            [addPhotoView addSubview:self.WYYAddPhotoSwitch];
            [self.WYYAddPhotoSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.addPhotonTipLabel);
                make.right.mas_equalTo(-10 * scale);
                make.width.mas_equalTo(51);
                make.height.mas_equalTo(31);
            }];
            
            UIView * bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
            bottomLineView.backgroundColor = UIColorFromRGB(0xefeff4);
            [addPhotoView addSubview:bottomLineView];
            [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(60 * scale);
                make.right.mas_equalTo(-60 * scale);
                make.height.mas_equalTo(3 * scale);
                make.bottom.mas_equalTo(0);
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
        
        if (self.isSelfFlg) {
            [self.leftWYYButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(0);
                make.width.mas_equalTo(kMainBoundsWidth - 120 * scale);
            }];
            self.rightWYYButton.hidden = YES;
        }
        
    }else{
        height += 180 * scale;
        
        if (self.leftButton.superview) {
            [self.leftButton removeFromSuperview];
        }
        
        if (self.centerButton.superview) {
            [self.centerButton removeFromSuperview];
        }
        
        if (self.rightButton.superview) {
            [self.rightButton removeFromSuperview];
        }
        CGFloat distance = (kMainBoundsWidth - 3 * 300 * scale) / 4.f;
        self.leftButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@""];
        [self.leftButton setBackgroundColor:[UIColor whiteColor]];
        [self.leftButton addTarget:self action:@selector(leftButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:self.leftButton];
        [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(distance);
            make.height.mas_equalTo(120 * scale);
            make.width.mas_equalTo(300 * scale);
            make.top.mas_equalTo(self.mapBaseView.mas_bottom).offset(80 * scale);
        }];
        [DDViewFactoryTool cornerRadius:60 * scale withView:self.leftButton];
        self.leftButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
        self.leftButton.layer.borderWidth = 4 * scale;
        
        self.centerButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@""];
        [self.centerButton addTarget:self action:@selector(centerButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.centerButton setBackgroundColor:[UIColor whiteColor]];
        [self.headerView addSubview:self.centerButton];
        [self.centerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.leftButton.mas_right).offset(distance);
            make.height.mas_equalTo(120 * scale);
            make.width.mas_equalTo(300 * scale);
            make.top.mas_equalTo(self.mapBaseView.mas_bottom).offset(80 * scale);
        }];
        [DDViewFactoryTool cornerRadius:60 * scale withView:self.centerButton];
        self.centerButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
        self.centerButton.layer.borderWidth = 4 * scale;
        
        self.rightButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@""];
        [self.rightButton addTarget:self action:@selector(rightButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.rightButton setBackgroundColor:[UIColor whiteColor]];
        [self.headerView addSubview:self.rightButton];
        [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.centerButton.mas_right).offset(distance);
            make.height.mas_equalTo(120 * scale);
            make.width.mas_equalTo(300 * scale);
            make.top.mas_equalTo(self.mapBaseView.mas_bottom).offset(80 * scale);
        }];
        [DDViewFactoryTool cornerRadius:60 * scale withView:self.rightButton];
        self.rightButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
        self.rightButton.layer.borderWidth = 4 * scale;
    }
    
    self.headerView.frame = CGRectMake(0, 0, kMainBoundsWidth, height);
    
    self.tableView.tableHeaderView = self.headerView;
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:self.model.portraituri]];
    self.nameLabel.text = self.model.nickname;
    self.locationLabel.text = self.model.sceneBuilding;
    self.senceTimelabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.model.sceneTime];
    
    [self reloadStatus];
    [self configMapRegion];
}

- (void)configMapRegion
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(self.model.sceneAddressLat, self.model.sceneAddressLng);
    [self.mapView addAnnotation:annotation];
    
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

//浏览照片和帖子切换
- (void)leftWYYButtonDidClicked
{
    if (self.WYYTab == 1) {
        self.WYYTab = 2;
        self.addButton.hidden = YES;
        [self.leftWYYButton setTitle:DDLocalizedString(@"BrowsePost") forState:UIControlStateNormal];
    }else if (self.WYYTab == 2) {
        self.WYYTab = 1;
        self.addButton.hidden = NO;
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
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
    
    if (sender.isOn) {
        self.model.postClassification = 1;
        self.addPhotonTipLabel.text = @"允许参与者上传照片";
    }else{
        self.model.postClassification = 0;
        self.addPhotonTipLabel.text = @"不允许参与者上传照片";
    }
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

- (void)reloadStatus
{
    NSString * number = @"";
    if (self.model.wyyCount > 0) {
        number = [NSString stringWithFormat:@"%ld", self.model.wyyCount];
        if (self.model.wyyCount > 99) {
            number = @"99+";
        }
    }
    
    if (self.isSelfFlg) {
        
        if (self.isRemark) {
            self.mygxqButton.hidden = YES;
            self.mydzhButton.hidden = YES;
        }else{
            if (self.yaoyueList) {
                self.mygxqButton.hidden = YES;
                self.mydzhButton.hidden = YES;
            }else{
                self.mygxqButton.hidden = NO;
                self.mydzhButton.hidden = NO;
            }
        }
        
        NSString * dzhNumber = @"";
        if (self.model.dzfCount > 0) {
            dzhNumber = [NSString stringWithFormat:@"%ld", self.model.dzfCount];
            if (self.model.wyyCount > 99) {
                dzhNumber = @"99+";
            }
        }
        
        [self.mydzhButton setTitle:[NSString stringWithFormat:@"%@ %@", DDLocalizedString(@"SayHi"), dzhNumber] forState:UIControlStateNormal];
        
        [self.leftButton setTitle:DDLocalizedString(@"Delete") forState:UIControlStateNormal];
        [self.centerButton setTitle:DDLocalizedString(@"AddPhotos") forState:UIControlStateNormal];
        [self.rightButton setTitle:DDLocalizedString(@"OrganizeHere") forState:UIControlStateNormal];
        
        if (self.model.wyyFlg == 1) {
            [self.mygxqButton setTitle:[NSString stringWithFormat:@"%@ %@", DDLocalizedString(@"HasInterestedHome"), number] forState:UIControlStateNormal];
            self.mygxqButton.alpha = .5f;
        }else{
            [self.mygxqButton setTitle:DDLocalizedString(@"InterestedHome") forState:UIControlStateNormal];
            self.mygxqButton.alpha = 1.f;
        }
        
    }else{
        
        self.mygxqButton.hidden = YES;
        self.mydzhButton.hidden = YES;
        
        if (self.model.wyyFlg == 1) {
            [self.leftButton setTitle:[NSString stringWithFormat:@"%@ %@", DDLocalizedString(@"HasInterestedHome"), number] forState:UIControlStateNormal];
            self.leftButton.alpha = .5f;
        }else{
            [self.leftButton setTitle:DDLocalizedString(@"InterestedHome") forState:UIControlStateNormal];
            self.leftButton.alpha = 1.f;
        }
        [self.centerButton setTitle:DDLocalizedString(@"SayHi") forState:UIControlStateNormal];
        [self.rightButton setTitle:DDLocalizedString(@"OrganizeHere") forState:UIControlStateNormal];
        
        if ([[DDLocationManager shareManager] postIsCanDazhaohuWith:self.model]) {
            self.centerButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
            [self.centerButton setTitleColor:UIColorFromRGB(0xDB6283) forState:UIControlStateNormal];
        }else{
            self.centerButton.layer.borderColor = UIColorFromRGB(0xefeff4).CGColor;
            [self.centerButton setTitleColor:UIColorFromRGB(0xefeff4) forState:UIControlStateNormal];
        }
    }
}

- (void)leftButtonDidClicked
{
    if (self.isRemark) {
        self.secondNumberLabel.hidden = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(secondNumberChange) object:nil];
    }
    if (self.isSelfFlg) {
        RDAlertView * alert = [[RDAlertView alloc] initWithTitle:@"删除提示" message:@"是否确定删除该帖子？"];
        RDAlertAction * action1 = [[RDAlertAction alloc] initWithTitle:@"取消" handler:^{
            
        } bold:NO];
        RDAlertAction * action2 = [[RDAlertAction alloc] initWithTitle:@"确定" handler:^{
            
            MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在删除" inView:self.parentDDViewController.view];
            
            DTieDeleteRequest * request = [[DTieDeleteRequest alloc] initWithPostId:self.model.cid];
            [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
                [hud hideAnimated:YES];
                [MBProgressHUD showTextHUDWithText:@"删除成功" inView:self.parentDDViewController.view];
                [self.parentDDViewController popViewControllerAnimated:YES];
                
            } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
                [hud hideAnimated:YES];
                [MBProgressHUD showTextHUDWithText:@"删除失败" inView:self.parentDDViewController.view];
                
            } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
                
                [hud hideAnimated:YES];
                [MBProgressHUD showTextHUDWithText:@"删除失败" inView:self.parentDDViewController.view];
                
            }];
            
        } bold:NO];
        [alert addActions:@[action1, action2]];
        [alert show];
    }else{
        if (self.model.wyyFlg) {
            [DTieCancleWYYRequest cancelRequest];
            DTieCancleWYYRequest * request = [[DTieCancleWYYRequest alloc] initWithPostID:self.model.cid];
            [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
                self.model.wyyFlg = 0;
                self.model.wyyCount--;
                [self reloadStatus];
                
            } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
            } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
                
            }];
            
        }else{
            [DTieCollectionRequest cancelRequest];
            DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:self.model.cid type:1 subType:0 remark:@""];
            
            [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
                self.model.wyyFlg = 1;
                self.model.wyyCount++;
                [MBProgressHUD showTextHUDWithText:@"您刚标识了您想约这里。约点越多，被约越多。Deedao好友越多，被约越多。记得常去约饭约玩活地图 组饭局哦。" inView:[UIApplication sharedApplication].keyWindow];
                
                [self reloadStatus];
            } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
            } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
                
            }];
        }
    }
}

- (void)centerButtonDidClicked
{
    if (self.isRemark) {
        self.secondNumberLabel.hidden = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(secondNumberChange) object:nil];
    }
    if (self.model.authorId == [UserManager shareManager].user.cid) {
        [self uploadButtonDidClicked];
    }else{
        if ([[DDLocationManager shareManager] postIsCanDazhaohuWith:self.model]) {
            DDDazhaohuView * view = [[DDDazhaohuView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            view.block = ^(NSString *text) {
                
                [DTieCollectionRequest cancelRequest];
                DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:self.model.cid type:2 subType:1 remark:text];
                
                [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                    
                    self.model.dzfFlg = 1;
                    self.model.dzfCount++;
                    [self reloadStatus];
                    
                    [MBProgressHUD showTextHUDWithText:@"对方已收到您的信息" inView:[UIApplication sharedApplication].keyWindow];
                } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                    
                } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
                    
                }];
            };
            [view show];
        }
    }
}

- (void)rightButtonDidClicked
{
    if (self.isRemark) {
        self.secondNumberLabel.hidden = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(secondNumberChange) object:nil];
    }
    BMKPoiInfo * poi = [[BMKPoiInfo alloc] init];
    poi.pt = CLLocationCoordinate2DMake(self.model.sceneAddressLat, self.model.sceneAddressLng);
    poi.address = self.model.sceneAddress;
    poi.name = self.model.sceneBuilding;
    
    YueFanViewController * yuefan = [[YueFanViewController alloc] initWithBMKPoiInfo:poi friendArray:[NSMutableArray new]];
    
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    
    [na pushViewController:yuefan animated:YES];
}

- (void)handleButtonDidClicked
{
    if (self.isRemark) {
        self.secondNumberLabel.hidden = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(secondNumberChange) object:nil];
    }
    if (self.model.wyyFlg == 1) {
        [DTieCancleWYYRequest cancelRequest];
        DTieCancleWYYRequest * request = [[DTieCancleWYYRequest alloc] initWithPostID:self.model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            self.model.wyyFlg = 0;
            self.model.wyyCount--;
            [self reloadStatus];
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
        }];
        
    }else{
        [DTieCollectionRequest cancelRequest];
        DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:self.model.cid type:1 subType:0 remark:@""];
        
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            self.model.wyyFlg = 1;
            self.model.wyyCount++;
            [MBProgressHUD showTextHUDWithText:@"您刚标识了您想约这里。约点越多，被约越多。Deedao好友越多，被约越多。记得常去约饭约玩活地图 组饭局哦。" inView:[UIApplication sharedApplication].keyWindow];
            
            [self reloadStatus];
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
        }];
    }
}

@end
