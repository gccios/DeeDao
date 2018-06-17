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

@interface DTieNewDetailViewController ()<SecurityFriendDelegate, DTieShareDelegate>

@property (nonatomic, strong) DTieReadView * readView;
@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, strong) UIView * topView;

@end

@implementation DTieNewDetailViewController

- (instancetype)initWithDTie:(DTieModel *)model
{
    if (self = [super init]) {
        self.model = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
}

- (void)shareButtonDidClicked
{
    DTieShareView * share = [[DTieShareView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    share.delegate = self;
    [share show];
}

- (void)DTieShareDidSelectIndex:(NSInteger)index
{
    if (index == 0) {
        BOOL pflg = NO;
        NSMutableArray * shareSource = [[NSMutableArray alloc] init];
        NSMutableArray * urlSource = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < self.model.details.count; i++) {
            DTieEditModel * model = [self.model.details objectAtIndex:i];
            if (model.type == DTieEditType_Image) {
                if (model.image) {
                    [shareSource addObject:model.image];
                }else if (!isEmptyString(model.detailContent)) {
                    [urlSource addObject:model.detailContent];
                }
            }
            if (model.pFlag == 1) {
                pflg = YES;
            }
        }
        
        if (urlSource.count > 0) {
            
            MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在获取图片" inView:self.view];
            __block NSUInteger count = 0;
            for (NSString * path in urlSource) {
                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:path] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    
                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                    [[SDImageCache sharedImageCache] storeImage:image forKey:path toDisk:YES completion:nil];
                    [shareSource addObject:image];
                    count++;
                    if (count == urlSource.count) {
                        [hud hideAnimated:YES];
                        
                        NSInteger postId = self.model.cid;
                        if (postId == 0) {
                            postId = self.model.postId;
                        }
                        
                        DTieShareViewController * share = [[DTieShareViewController alloc] initWithShareList:shareSource title:self.model.postSummary pflg:pflg postId:postId];
                        [self presentViewController:share animated:YES completion:nil];
                    }
                }];
            }
        }else{
            NSInteger postId = self.model.cid;
            if (postId == 0) {
                postId = self.model.postId;
            }
            
            DTieShareViewController * share = [[DTieShareViewController alloc] initWithShareList:shareSource title:self.model.postSummary pflg:pflg postId:postId];
            [self presentViewController:share animated:YES completion:nil];
        }
    }else if (index == 1) {
        for (NSInteger i = 0; i < self.model.details.count; i++) {
            DTieEditModel * model = [self.model.details objectAtIndex:i];
            if (model.type == DTieEditType_Image) {
                NSInteger postId = self.model.postId;
                if (postId == 0) {
                    postId = self.model.cid;
                }
                if (model.image) {
                    [[WeChatManager shareManager] shareMiniProgramWithPostID:postId image:model.image isShare:NO];
                }else{
                    NSString * urlPath = self.model.postFirstPicture;
                    if (isEmptyString(urlPath)) {
                        urlPath = model.detailContent;
                    }
                    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:self.view];
                    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:urlPath] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                        
                    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                        [[SDImageCache sharedImageCache] storeImage:image forKey:urlPath toDisk:YES completion:nil];
                        
                        if (image) {
                            [[WeChatManager shareManager] shareMiniProgramWithPostID:postId image:image isShare:NO];
                        }else{
                            [MBProgressHUD showTextHUDWithText:@"分享失败" inView:self.view];
                        }
                        
                        [hud hideAnimated:YES];
                    }];
                }
                break;
            }
        }
    }else if (index == 2) {
        SecurityFriendController * friend = [[SecurityFriendController alloc] init];
        friend.delegate = self;
        [self.navigationController pushViewController:friend animated:YES];
    }else if (index == 3) {
        
//        if ([UserManager shareManager].user.bloggerFlg != 1) {
//            [MBProgressHUD showTextHUDWithText:@"该功能只支持博主使用" inView:self.view];
//            return;
//        }
        
        NSString * urlLink = [NSString stringWithFormat:@"pages/index/index?postId=%ld", self.model.postId];
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
        
        NSString * text = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n\n", self.model.postSummary, [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.model.sceneTime], self.model.sceneAddress, urlLink];
        
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
        [MBProgressHUD showTextHUDWithText:@"转发失败" inView:self.view];
    }];
}

- (void)editButtonDidClicked
{
    NSInteger postID = self.model.cid;
    if (postID == 0) {
        postID = self.model.postId;
    }
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:self.view];
    CreateDTieRequest * request = [[CreateDTieRequest alloc] initWithList:[NSArray new] title:self.model.postSummary address:self.model.sceneAddress addressLng:self.model.sceneAddressLng addressLat:self.model.sceneAddressLat status:0 remindFlg:1 firstPic:self.model.postFirstPicture postID:self.model.cid landAccountFlg:self.model.landAccountFlg allowToSeeList:self.model.allowToSeeList sceneTime:self.model.sceneTime];
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
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.readView = [[DTieReadView alloc] initWithFrame:[UIScreen mainScreen].bounds model:self.model];
    self.readView.parentDDViewController = self.navigationController;
    [self.view addSubview:self.readView];
    [self.readView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
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
    titleLabel.text = self.model.postSummary;
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
        make.right.mas_equalTo(-270 * scale);
    }];
    
    UIButton * shareButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:shareButton];
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-40 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    if (self.model.authorId == [UserManager shareManager].user.cid) {
        UIButton * editButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
        [editButton setImage:[UIImage imageNamed:@"detailEdit"] forState:UIControlStateNormal];
        [editButton addTarget:self action:@selector(editButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:editButton];
        [editButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(shareButton.mas_left).offset(-20 * scale);
            make.bottom.mas_equalTo(-20 * scale);
            make.width.height.mas_equalTo(100 * scale);
        }];
    }
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
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
