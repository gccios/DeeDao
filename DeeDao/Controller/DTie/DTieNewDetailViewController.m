//
//  DTieNewDetailViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/1.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieNewDetailViewController.h"
#import "DTieReadView.h"
#import "WeChatManager.h"
#import "UserManager.h"
#import "DDTool.h"
#import "DTieShareViewController.h"
#import "DTieNewEditViewController.h"
#import "RDAlertView.h"
#import "MBProgressHUD+DDHUD.h"
#import "SecurityFriendController.h"
#import "CreateDTieRequest.h"
#import <UIImageView+WebCache.h>
#import "TransPostRequest.h"
#import "DTieShareView.h"
#import "DTieSingleImageShareView.h"
#import "DTiePostShareView.h"
#import "AddPostSeeRequest.h"
#import "ShareImageModel.h"
#import "DDBackWidow.h"
#import "DTieDeleteRequest.h"
#import "RDAlertView.h"
#import "ConverUtil.h"
#import "DDShareManager.h"

@interface DTieNewDetailViewController ()<SecurityFriendDelegate, DTieShareDelegate>

@property (nonatomic, strong) DTieReadView * readView;
@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UIView * paopaoView;

@property (nonatomic, assign) BOOL isPreRead;

@end

@implementation DTieNewDetailViewController

- (instancetype)initWithDTie:(DTieModel *)model
{
    if (self = [super init]) {
        self.model = model;
        self.isPreRead = NO;
        [self addPostSee];
    }
    return self;
}

- (void)addPostSee
{
    if ([DDLocationManager shareManager].result.location.latitude == 0.f) {
        return;
    }
    
    NSInteger postId = self.model.cid;
    if (postId == 0) {
        postId = self.model.postId;
    }
    
    AddPostSeeRequest * request = [[AddPostSeeRequest alloc] initWithPostID:postId];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (instancetype)initPreReadWithDTie:(DTieModel *)model
{
    if (self = [super init]) {
        self.model = model;
        self.isPreRead = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
    [self createPaopaoView];
}

- (void)createPaopaoView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.paopaoView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.paopaoView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
    
    UIImageView * paopaoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"paopao.png"]];
    paopaoImageView.userInteractionEnabled = YES;
    [self.paopaoView addSubview:paopaoImageView];
    [paopaoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-70 * scale);
        make.top.mas_equalTo((130 + kStatusBarHeight) * scale);
        make.width.height.mas_equalTo(280 * scale);
    }];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(paopaoViewDidClicked)];
    [self.paopaoView addGestureRecognizer:tap];
    
    UIButton * editButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xDB6283) title:DDLocalizedString(@"EditDPage")];
    [paopaoImageView addSubview:editButton];
    [editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(25 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    [editButton addTarget:self action:@selector(editButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * deleteButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xDB6283) title:DDLocalizedString(@"DeleteDPage")];
    [paopaoImageView addSubview:deleteButton];
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(editButton.mas_bottom);
        make.height.mas_equalTo(120 * scale);
    }];
    
    [deleteButton addTarget:self action:@selector(deleteButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)deleteButtonDidClicked
{
    [self paopaoViewDidClicked];
    
    RDAlertView * alertView = [[RDAlertView alloc] initWithTitle:@"删除D帖提示" message:@"您是否确定要删除当前D帖？点取消返回，点确定将立即删除。"];
    RDAlertAction * leftAction = [[RDAlertAction alloc] initWithTitle:DDLocalizedString(@"Cancel") handler:^{
        
    } bold:NO];
    
    RDAlertAction * rightAction = [[RDAlertAction alloc] initWithTitle:DDLocalizedString(@"Yes") handler:^{
        
        NSInteger postID = self.model.postId;
        if (postID == 0) {
            postID = self.model.cid;
        }
        
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在删除" inView:self.view];
        DTieDeleteRequest * request = [[DTieDeleteRequest alloc] initWithPostId:postID];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [hud hideAnimated:YES];
            
            self.model.deleteFlg = 1;
            [self.navigationController popViewControllerAnimated:YES];
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [hud hideAnimated:YES];
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
            [hud hideAnimated:YES];
            
        }];
        
    } bold:NO];
    [alertView addActions:@[leftAction, rightAction]];
    [alertView show];
}

- (void)paopaoViewDidClicked
{
    [self.paopaoView removeFromSuperview];
}

- (void)showPaopaoView
{
    [self.view addSubview:self.paopaoView];
    [self.paopaoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)shareButtonDidClicked
{
//    if (self.readView.yaoyueList) {
//        DTiePostShareView * share = [[DTiePostShareView alloc] initWithModel:self.model];
//        [self.view insertSubview:share atIndex:0];
//        [share startShare];
//        return;
//    }
    
    DTieShareView * share = [[DTieShareView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    share.delegate = self;
    [share show];
}

- (void)showShareWithCreatePost
{
    DTieShareView * share = [[DTieShareView alloc] initCreatePostWithFrame:[UIScreen mainScreen].bounds];
    share.delegate = self;
    [share show];
}

- (void)DTieShareDidSelectIndex:(NSInteger)index
{
    NSInteger postID = self.model.postId;
    if (postID == 0) {
        postID = self.model.cid;
    }
    
    if (index == 0) {
        
//        BOOL pflg = NO;
//        NSMutableArray * shareSource = [[NSMutableArray alloc] init];
//        NSMutableArray * urlSource = [[NSMutableArray alloc] init];
//        NSMutableArray * pflgSource = [[NSMutableArray alloc] init];
//        for (NSInteger i = 0; i < self.model.details.count; i++) {
//            DTieEditModel * model = [self.model.details objectAtIndex:i];
//            if (model.type == DTieEditType_Image) {
//                if (model.image) {
//
//                    ShareImageModel * shareModel = [[ShareImageModel alloc] init];
//                    shareModel.postId = postID;
//                    shareModel.image = model.image;
//                    shareModel.title = self.model.postSummary;
//                    shareModel.PFlag = model.pFlag;
//                    if (shareModel.PFlag == 1) {
//                        [shareModel changeToDeedao];
//                    }
//
//                    [shareSource addObject:shareModel];
//
//                }else if (!isEmptyString(model.detailContent)) {
//                    [urlSource addObject:model.detailContent];
//                    [pflgSource addObject:@(model.pFlag)];
//                }
//            }
//            if (model.pFlag == 1) {
//                pflg = YES;
//            }
//        }
//
//        if (urlSource.count > 0) {
//
//            MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在获取图片" inView:self.view];
//            __block NSUInteger count = 0;
//            for (NSInteger i = 0; i < urlSource.count; i++)  {
//
//                NSString * path = [urlSource objectAtIndex:i];
//                NSInteger tempPflg = [[pflgSource objectAtIndex:i] integerValue];
//
//                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:path] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
//
//                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
//
//                    if (nil == image) {
//                        count++;
//                        if (count == urlSource.count) {
//                            [hud hideAnimated:YES];
//
//                            NSInteger postId = self.model.cid;
//                            if (postId == 0) {
//                                postId = self.model.postId;
//                            }
//
//                            DTieShareViewController * share = [[DTieShareViewController sharedViewController] insertShareList:shareSource title:self.model.postSummary pflg:pflg postId:postID];
//                            [self presentViewController:share animated:YES completion:nil];
//                            [[DDBackWidow shareWindow] hidden];
//                        }
//                        return;
//                    }
//
//                    [[SDImageCache sharedImageCache] storeImage:image forKey:path toDisk:YES completion:nil];
//
//                    ShareImageModel * shareModel = [[ShareImageModel alloc] init];
//                    shareModel.postId = postID;
//                    shareModel.image = image;
//                    shareModel.title = self.model.postSummary;
//                    shareModel.PFlag = tempPflg;
//                    if (shareModel.PFlag == 1) {
//                        [shareModel changeToDeedao];
//                    }
//
//                    [shareSource addObject:shareModel];
//
//                    count++;
//                    if (count == urlSource.count) {
//                        [hud hideAnimated:YES];
//
//                        NSInteger postId = self.model.cid;
//                        if (postId == 0) {
//                            postId = self.model.postId;
//                        }
//
//                        DTieShareViewController * share = [[DTieShareViewController sharedViewController] insertShareList:shareSource title:self.model.postSummary pflg:pflg postId:postID];
//                        [self presentViewController:share animated:YES completion:nil];
//                        [[DDBackWidow shareWindow] hidden];
//                    }
//                }];
//            }
//        }else{
//            DTieShareViewController * share = [[DTieShareViewController sharedViewController] insertShareList:shareSource title:self.model.postSummary pflg:pflg postId:postID];
//            [self presentViewController:share animated:YES completion:nil];
//            [[DDBackWidow shareWindow] hidden];
//        }
        
        [[DDBackWidow shareWindow] show];
        
        DTiePostShareView * share = [[DTiePostShareView alloc] initWithModel:self.model];
        [self.view insertSubview:share atIndex:0];
        [share startShare];
        
    }else if (index == 1) {
        
//        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"分享到" message:DDLocalizedString(@"To Share") preferredStyle:UIAlertControllerStyleActionSheet];
//
//        UIAlertAction * friendAction = [UIAlertAction actionWithTitle:DDLocalizedString(@"Wechat Groups") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//            [[DDBackWidow shareWindow] show];
//
//            DTiePostShareView * share = [[DTiePostShareView alloc] initWithModel:self.model];
//            [self.view insertSubview:share atIndex:0];
//            [share startShare];
//
//        }];
        
//        UIAlertAction * quanAction = [UIAlertAction actionWithTitle:DDLocalizedString(@"Wechat Connections") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
//            [[DDBackWidow shareWindow] show];
//
//            NSString * urlPath = self.model.postFirstPicture;
//
//            for (NSInteger i = 0; i < self.model.details.count; i++) {
//                DTieEditModel * model = [self.model.details objectAtIndex:i];
//                if (model.type == DTieEditType_Image) {
//                    if (isEmptyString(urlPath)) {
//                        urlPath = model.detailContent;
//                    }
//                    break;
//                }
//            }
//
//            MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:self.view];
//            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:urlPath] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
//
//            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
//                [[SDImageCache sharedImageCache] storeImage:image forKey:urlPath toDisk:YES completion:nil];
//
//                if (image) {
//                    [[WeChatManager shareManager] shareMiniProgramWithPostID:postID image:image isShare:NO title:self.model.postSummary];
//                }else{
//                    [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"SharingFailed") inView:self.view];
//                }
//
//                [hud hideAnimated:YES];
//            }];
//        }];
        
        
        [[DDBackWidow shareWindow] show];
        
        NSString * urlPath = self.model.postFirstPicture;
        
        for (NSInteger i = 0; i < self.model.details.count; i++) {
            DTieEditModel * model = [self.model.details objectAtIndex:i];
            if (model.type == DTieEditType_Image) {
                if (isEmptyString(urlPath)) {
                    urlPath = model.detailContent;
                }
                break;
            }
        }
        
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:self.view];
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:urlPath] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            [[SDImageCache sharedImageCache] storeImage:image forKey:urlPath toDisk:YES completion:nil];
            
            if (image) {
                [[WeChatManager shareManager] shareMiniProgramWithPostID:postID image:image isShare:NO title:self.model.postSummary];
            }else{
                [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"SharingFailed") inView:self.view];
            }
            
            [hud hideAnimated:YES];
        }];
        
//        UIAlertAction * saveAction = [UIAlertAction actionWithTitle:DDLocalizedString(@"StampSave") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//            [[DDBackWidow shareWindow] show];
//
//            DTiePostShareView * share = [[DTiePostShareView alloc] initWithModel:self.model];
//            [self.view insertSubview:share atIndex:0];
//            [share saveToAlbum];
//
//        }];
//
//        UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:DDLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            [[DDBackWidow shareWindow] show];
//        }];
//
//        [alert addAction:friendAction];
//        [alert addAction:quanAction];
//        [alert addAction:saveAction];
//        [alert addAction:cancleAction];
//        [self presentViewController:alert animated:YES completion:nil];
//        [[DDBackWidow shareWindow] hidden];
        
    }else if (index == 2) {
        
        [[DDBackWidow shareWindow] show];
        
        DTiePostShareView * share = [[DTiePostShareView alloc] initWithModel:self.model];
        [self.view insertSubview:share atIndex:0];
        [share saveToAlbum];
        
//        SecurityFriendController * friend = [[SecurityFriendController alloc] initMulSelectWithDataDict:[NSDictionary new] nameKeys:[NSArray new] selectModels:[NSMutableArray new]];
//        friend.delegate = self;
//        [self.navigationController pushViewController:friend animated:YES];
    }else if (index == 3) {
        
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 1000;
        NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
        
        NSString * userID = [NSString stringWithFormat:@"%ld", self.model.cid];
        
        NSString * string = [NSString stringWithFormat:@"post:%@+%@", timeString, userID];
        NSString * result = [ConverUtil base64EncodeString:string];
        
        NSString * pasteString = [NSString stringWithFormat:@"【DeeDao地到】%@#复制此消息，打开DeeDao地到查看帖子详情", result];
        
        UIPasteboard * pasteBoard = [UIPasteboard generalPasteboard];
        pasteBoard.string = pasteString;
        [MBProgressHUD showTextHUDWithText:@"已拷贝口令。在微博或电邮粘贴口令并发出。对方拷贝，并打开Deedao, 便可打开帖子" inView:[UIApplication sharedApplication].keyWindow];
        
    }else if (index == 4) {
        
//        if ([UserManager shareManager].user.bloggerFlg != 1) {
//            [MBProgressHUD showTextHUDWithText:@"该功能只支持博主使用" inView:self.view];
//            return;
//        }
        
        NSString * urlLink = [NSString stringWithFormat:@"pages/detail/detail?postId=%lduserIs%ldisBlogger", postID, [UserManager shareManager].user.cid];
//        RDAlertView * alertView = [[RDAlertView alloc] initWithTitle:@"博主小程序链接" message:[NSString stringWithFormat:@"此帖的小程序链接是:\n%@\n请复制到微信公众平台文章编辑页", urlLink]];
//        RDAlertAction * rdaction1 = [[RDAlertAction alloc] initWithTitle:@"取消" handler:^{
//
//        } bold:NO];
//        RDAlertAction * rdaction2 = [[RDAlertAction alloc] initWithTitle:@"确定" handler:^{
//
//            NSString * preText = [UserManager shareManager].PasteboardText;
//            if (isEmptyString(preText)) {
//                preText = @"";
//            }else{
//                preText = [preText stringByAppendingString:@"\n"];
//            }
        
        NSString * scene = self.model.sceneBuilding;
        if (isEmptyString(scene)) {
            scene = self.model.sceneAddress;
        }
        NSString * text = [NSString stringWithFormat:@"%@\n%@\n%@\n请把以下文字和链接放置到您的微信公众号博文里：点击这里，一键把这个地点收藏到您的 Deedao 小程序（和APP） 里，在您恰好路过的时候提醒您不要错过😃\n %@\n\n",  [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.model.sceneTime], self.model.postSummary, scene, urlLink];
        
        NSError * error = nil;
        NSFileManager * manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:DDBloggerLinkPath]) {
            NSFileHandle * writeHandle = [NSFileHandle fileHandleForWritingAtPath:DDBloggerLinkPath];
            if (writeHandle) {
                [writeHandle seekToEndOfFile];
                NSData * linkData = [text dataUsingEncoding:NSUTF8StringEncoding];
                [writeHandle writeData:linkData];
                [writeHandle closeFile];
            }else{
                error = [NSError new];
            }
        }else{
            [text writeToFile:DDBloggerLinkPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        }
        
        if (error) {
            [MBProgressHUD showTextHUDWithText:@"获取失败" inView:self.view];
        }else{
            [MBProgressHUD showTextHUDWithText:@"获取成功,请到我的博主链接查看" inView:self.view];
        }
        
//            [UserManager shareManager].PasteboardText = text;
        
//            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//            pasteboard.string = text;
//            [MBProgressHUD showTextHUDWithText:@"复制成功" inView:self.view];
//        } bold:NO];
//        [alertView addActions:@[rdaction1, rdaction2]];
//        [alertView show];
    }
}

- (void)securityFriendDidSelectWith:(UserModel *)model
{
    TransPostRequest * request = [[TransPostRequest alloc] initWithPostID:self.model.cid userList:@[@(model.cid)]];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self.navigationController popViewControllerAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"转发成功" inView:self.view];
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self.navigationController popViewControllerAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"转发失败" inView:self.view];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self.navigationController popViewControllerAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:self.view];
    }];
}

- (void)friendDidMulSelectComplete:(NSArray *)selectArray
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for (UserModel * model in selectArray) {
        [array addObject:@(model.cid)];
    }
    TransPostRequest * request = [[TransPostRequest alloc] initWithPostID:self.model.cid userList:array];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self.navigationController popViewControllerAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"转发成功" inView:self.view];
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self.navigationController popViewControllerAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"转发失败" inView:self.view];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self.navigationController popViewControllerAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:self.view];
    }];
}

- (void)editButtonDidClicked
{
    [self paopaoViewDidClicked];
    
    NSInteger postID = self.model.cid;
    if (postID == 0) {
        postID = self.model.postId;
    }
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:self.view];
    
    NSMutableArray * details = [[NSMutableArray alloc] init];

    for (NSInteger i = 0; i < self.model.details.count; i++) {

        DTieEditModel * model = [self.model.details objectAtIndex:i];

        if (model.type == DTieEditType_Image) {

            NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                    @"datadictionaryType":@"CONTENT_IMG",
                                    @"detailsContent":model.detailsContent,
                                    @"textInformation":@"",
                                    @"pFlag":@(model.pFlag),
                                    @"wxCansee":@(model.shareEnable),
                                    @"authorID":@(model.authorID)};
            [details addObject:dict];

        }else if (model.type == DTieEditType_Text) {

            NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                    @"datadictionaryType":@"CONTENT_TEXT",
                                    @"detailsContent":model.detailsContent,
                                    @"textInformation":@"",
                                    @"pFlag":@(model.pFlag),
                                    @"wxCansee":@(model.shareEnable),
                                    @"authorID":@(model.authorID)};
            [details addObject:dict];

        }else if (model.type == DTieEditType_Video) {

            NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                    @"datadictionaryType":@"CONTENT_VIDEO",
                                    @"detailsContent":model.detailsContent,
                                    @"textInformation":model.textInformation,
                                    @"pFlag":@(model.pFlag),
                                    @"wxCansee":@(model.shareEnable),
                                    @"authorID":@(model.authorID)};
            [details addObject:dict];

        }else if (model.type == DTieEditType_Post) {

            NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                    @"datadictionaryType":@"CONTENT_POST",
                                    @"detailsContent":@"",
                                    @"textInformation":@"",
                                    @"pFlag":@(0),
                                    @"wxCansee":@(1),
                                    @"postToPostId":@(model.postId),
                                    @"authorID":@(model.authorID)
                                    };
            [details addObject:dict];

        }
    }
    
    CreateDTieRequest * request = [[CreateDTieRequest alloc] initWithList:details title:self.model.postSummary address:self.model.sceneAddress building:self.model.sceneBuilding addressLng:self.model.sceneAddressLng addressLat:self.model.sceneAddressLat status:0 remindFlg:1 firstPic:self.model.postFirstPicture postID:self.model.cid landAccountFlg:self.model.landAccountFlg allowToSeeList:self.model.allowToSeeList sceneTime:self.model.sceneTime];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        self.model.status = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:DTieDidCreateNewNotification object:nil];
        DTieNewEditViewController * edit = [[DTieNewEditViewController alloc] initWithDtieModel:self.model];
        edit.needPopTwoVC = YES;
        [self.navigationController pushViewController:edit animated:YES];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
    }];
}

- (void)createViews
{
    self.readView = [[DTieReadView alloc] initWithFrame:[UIScreen mainScreen].bounds model:self.model isRemark:self.isRemark];
    self.readView.isPreRead = self.isPreRead;
    self.readView.parentDDViewController = self.navigationController;
    [self.view addSubview:self.readView];
    [self.readView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(-kStatusBarHeight);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    [self createTopView];
}

- (void)createTopView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.topView = [[UIView alloc] init];
    self.topView.userInteractionEnabled = YES;
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo((170 + kStatusBarHeight) * scale);
    }];
    
    UIButton * backButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [backButton setImage:[UIImage imageNamed:@"contentClose"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.bottom.mas_equalTo(-15 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    if (!self.isPreRead) {
        UIButton * shareButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
        [shareButton setImage:[UIImage imageNamed:@"contentShare"] forState:UIControlStateNormal];
        [shareButton addTarget:self action:@selector(shareButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:shareButton];
        [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-40 * scale);
            make.bottom.mas_equalTo(-20 * scale);
            make.width.height.mas_equalTo(100 * scale);
        }];
        
        UIButton * shareMultButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
        [shareMultButton setImage:[UIImage imageNamed:@"shareMult"] forState:UIControlStateNormal];
        [shareMultButton addTarget:self action:@selector(shareMultButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:shareMultButton];
        [shareMultButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-150 * scale);
            make.centerY.mas_equalTo(shareButton).offset(-4 * scale);
            make.width.height.mas_equalTo(60 * scale);
        }];
        
//        if (self.model.authorId == [UserManager shareManager].user.cid) {
//            UIButton * editButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
//            [editButton setImage:[UIImage imageNamed:@"contentEdit"] forState:UIControlStateNormal];
//            [editButton addTarget:self action:@selector(bianjiButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//            [self.topView addSubview:editButton];
//            [editButton mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.right.mas_equalTo(shareButton.mas_left).offset(-20 * scale);
//                make.bottom.mas_equalTo(-20 * scale);
//                make.width.height.mas_equalTo(100 * scale);
//            }];
//        }
    }
}

- (void)shareMultButtonDidClicked
{
    [[DDShareManager shareManager] showShareList];
}

- (void)bianjiButtonDidClicked
{
    [self showPaopaoView];
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[DDBackWidow shareWindow] show];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.isRemark) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self.readView selector:@selector(secondNumberChange) object:nil];
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
