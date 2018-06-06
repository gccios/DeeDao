
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

#import "DTieCollectionRequest.h"
#import "DTieCancleCollectRequest.h"
#import "DTieCancleWYYRequest.h"
#import "LiuYanViewController.h"
#import "UserInfoViewController.h"
#import "DDLocationManager.h"
#import "DDShareManager.h"
#import "LookImageViewController.h"
#import "DDDazhaohuView.h"
#import "MBProgressHUD+DDHUD.h"

#import <UIImageView+WebCache.h>
#import <Masonry.h>

@interface DTieReadView () <UITableViewDelegate, UITableViewDataSource, LiuyanDidComplete>

@property (nonatomic, strong) UIView * headerView;
@property (nonatomic, strong) UIImageView * firstImageView;
@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UIButton * dazhaohuButton;
@property (nonatomic, strong) UIButton * locationButton;
@property (nonatomic, strong) UILabel * locationLabel;
@property (nonatomic, strong) UILabel * senceTimelabel;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * modelSources;

@property (nonatomic, strong) UIImage * firstImage;

@property (nonatomic, assign) BOOL isSelfFlg;

@property (nonatomic, strong) UIButton * jubaoButton;
@property (nonatomic, strong) UIButton * shoucangButton;
@property (nonatomic, strong) UIButton * woyaoyueButton;
@property (nonatomic, strong) UIButton * liuyanButton;
@property (nonatomic, strong) UILabel * liuyanLabel;

@end

@implementation DTieReadView

- (instancetype)initWithFrame:(CGRect)frame model:(DTieModel *)model
{
    if (self = [super initWithFrame:frame]) {
        
        self.model = model;
        if (model.details) {
            [self sortWithDetails:model.details];
        }else{
            self.modelSources = [NSMutableArray new];
        }
        
        if ([UserManager shareManager].user.cid == model.authorId) {
            self.isSelfFlg = YES;
        }
        
        [self createDTieReadView];
        
        [self configUserInteractionEnabled];
    }
    return self;
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
    
    [self.liuyanButton addTarget:self action:@selector(liuyanButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDidHandle:)];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidTap:)];
    self.firstImageView.userInteractionEnabled = YES;
    [self.firstImageView addGestureRecognizer:longPress];
    [self.firstImageView addGestureRecognizer:tap];
    
    [self.dazhaohuButton addTarget:self action:@selector(dazhaohuButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.jubaoButton addTarget:self action:@selector(jubaoButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.shoucangButton addTarget:self action:@selector(shoucangButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.woyaoyueButton addTarget:self action:@selector(woyaoyueButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.locationButton addTarget:self action:@selector(locationButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)imageDidTap:(UITapGestureRecognizer *)tap
{
    if (self.parentDDViewController) {
        if (self.firstImage) {
            LookImageViewController * look = [[LookImageViewController alloc] initWithImage:self.firstImage];
            [self.parentDDViewController presentViewController:look animated:NO completion:nil];
        }
    }
}

- (void)longPressDidHandle:(UILongPressGestureRecognizer *)longPress
{
    if (self.parentDDViewController) {
        [[DDShareManager shareManager] showHandleViewWithImage:self.firstImageView.image];
    }
}

- (void)locationButtonDidClicked
{
    [[DDLocationManager shareManager] mapNavigationToLongitude:self.model.sceneAddressLng latitude:self.model.sceneAddressLat poiName:self.model.sceneAddress withViewController:self.parentDDViewController];
}

- (void)dazhaohuButtonDidClicked
{
    if (self.isSelfFlg) {
        [MBProgressHUD showTextHUDWithText:@"无法对自己的帖子进行该操作" inView:self];
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
        
        DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:self.model.postId type:0 subType:1 remark:text];
        
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
    
}

- (void)shoucangButtonDidClicked
{
    if (self.isSelfFlg) {
        [MBProgressHUD showTextHUDWithText:@"无法对自己的帖子进行该操作" inView:self];
        return;
    }
    
    self.shoucangButton.enabled = NO;
    if (self.model.collectFlg) {
        
        DTieCancleCollectRequest * request = [[DTieCancleCollectRequest alloc] initWithPostID:self.model.postId];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            self.model.collectFlg = 0;
            self.model.collectCount--;
            [self.shoucangButton setTitle:[NSString stringWithFormat:@"收藏+%ld", self.model.collectCount] forState:UIControlStateNormal];
            [self.shoucangButton setImage:[UIImage imageNamed:@"shoucangno"] forState:UIControlStateNormal];
            self.shoucangButton.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.shoucangButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.shoucangButton.enabled = YES;
        }];
        
    }else{
        DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:self.model.postId type:0 subType:0 remark:@""];
        
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            self.model.collectFlg = 1;
            self.model.collectCount++;
            [self.shoucangButton setTitle:[NSString stringWithFormat:@"收藏+%ld", self.model.collectCount] forState:UIControlStateNormal];
            [self.shoucangButton setImage:[UIImage imageNamed:@"shoucangyes"] forState:UIControlStateNormal];
            self.shoucangButton.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.shoucangButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.shoucangButton.enabled = YES;
        }];
    }
}

- (void)woyaoyueButtonDidClicked
{
    if (self.isSelfFlg) {
        [MBProgressHUD showTextHUDWithText:@"无法对自己的帖子进行该操作" inView:self];
        return;
    }
    self.woyaoyueButton.enabled = NO;
    if (self.model.wyyFlg) {
        
        DTieCancleWYYRequest * request = [[DTieCancleWYYRequest alloc] initWithPostID:self.model.postId];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            self.model.wyyFlg = 0;
            self.model.wyyCount--;
            [self.woyaoyueButton setTitle:[NSString stringWithFormat:@"我要约+%ld", self.model.wyyCount] forState:UIControlStateNormal];
            [self.woyaoyueButton setImage:[UIImage imageNamed:@"yaoyueno"] forState:UIControlStateNormal];
            self.woyaoyueButton.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.woyaoyueButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.woyaoyueButton.enabled = YES;
        }];
        
    }else{
        DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:self.model.postId type:1 subType:0 remark:@""];
        
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            self.model.wyyFlg = 1;
            self.model.wyyCount++;
            [self.woyaoyueButton setTitle:[NSString stringWithFormat:@"我要约+%ld", self.model.wyyCount] forState:UIControlStateNormal];
            [self.woyaoyueButton setImage:[UIImage imageNamed:@"yaoyueyes"] forState:UIControlStateNormal];
            self.woyaoyueButton.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.woyaoyueButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.woyaoyueButton.enabled = YES;
        }];
    }
}

- (void)liuyanButtonDidClicked
{
    if (self.parentDDViewController) {
        LiuYanViewController * liuyan = [[LiuYanViewController alloc] initWithPostID:self.model.cid commentId:self.model.authorId];
        liuyan.delegate = self;
        [self.parentDDViewController pushViewController:liuyan animated:YES];
    }
}

- (void)liuyanDidComplete
{
    self.model.messageCount += 1;
    self.liuyanLabel.text = [NSString stringWithFormat:@"共%ld条留言，查看或评论...", self.model.messageCount];
}

- (void)userinfoDidClicked
{
    if (self.parentDDViewController) {
        UserInfoViewController * info = [[UserInfoViewController alloc] initWithUserId:self.model.authorId];
        [self.parentDDViewController pushViewController:info animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.modelSources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    DTieEditModel * model = [self.modelSources objectAtIndex:indexPath.row];
    if (model.type == DTieEditType_Image) {
        DTieDetailImageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieDetailImageTableViewCell" forIndexPath:indexPath];
        
        [cell configWithModel:model Dtie:self.model];
        
        return cell;
    }else if (model.type == DTieEditType_Video) {
        DTieDetailVideoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieDetailVideoTableViewCell" forIndexPath:indexPath];
        
        [cell configWithModel:model Dtie:self.model];
        
        return cell;
    }
    
    DTieDetailTextTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieDetailTextTableViewCell" forIndexPath:indexPath];
    
    [cell configWithModel:model Dtie:self.model];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    DTieEditModel * model = [self.modelSources objectAtIndex:indexPath.row];
    if (model.type == DTieEditType_Image || model.type == DTieEditType_Video) {
        
        if (model.image) {
            return [DDTool getHeightWithImage:model.image] + 48 * scale;
        }else{
            UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:model.detailContent];
            
            if (!image) {
                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:model.detailContent] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    
                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                    [[SDImageCache sharedImageCache] storeImage:image forKey:model.detailContent toDisk:YES completion:nil];
                    model.image = image;
                    [self.tableView beginUpdates];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [self.tableView endUpdates];
                }];
            }else{
                return [DDTool getHeightWithImage:image] + 48 * scale;
            }
        }
        
    }else if (model.type == DTieEditType_Text) {
        
        CGFloat height = [DDTool getHeightByWidth:kMainBoundsWidth - 120 * scale title:model.detailsContent font:kPingFangRegular(42 * scale)] + 60 * scale;
        
        return height;
        
    }
    
    return .1f;
}

- (void)createDTieReadView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[DTieDetailTextTableViewCell class] forCellReuseIdentifier:@"DTieDetailTextTableViewCell"];
    [self.tableView registerClass:[DTieDetailImageTableViewCell class] forCellReuseIdentifier:@"DTieDetailImageTableViewCell"];
    [self.tableView registerClass:[DTieDetailVideoTableViewCell class] forCellReuseIdentifier:@"DTieDetailVideoTableViewCell"];
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
    
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 315 * scale)];
    
    self.jubaoButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0x333333) title:@"举报"];
    [self.jubaoButton setImage:[UIImage imageNamed:@"jubaono"] forState:UIControlStateNormal];
    [footerView addSubview:self.jubaoButton];
    [self.jubaoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(90 * scale);
        make.top.mas_equalTo(60 * scale);
        make.height.mas_equalTo(75 * scale);
    }];
    
    self.shoucangButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0x333333) title:@"收藏+0"];
    [self.shoucangButton setTitle:[NSString stringWithFormat:@"收藏+%ld", self.model.collectCount] forState:UIControlStateNormal];
    if (self.model.collectFlg) {
        [self.shoucangButton setImage:[UIImage imageNamed:@"shoucangyes"] forState:UIControlStateNormal];
    }else{
        [self.shoucangButton setImage:[UIImage imageNamed:@"shoucangno"] forState:UIControlStateNormal];
    }
    [footerView addSubview:self.shoucangButton];
    [self.shoucangButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(60 * scale);
        make.height.mas_equalTo(75 * scale);
    }];
    
    self.woyaoyueButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0x333333) title:@"我要约+0"];
    [self.woyaoyueButton setTitle:[NSString stringWithFormat:@"我要约+%ld", self.model.wyyCount] forState:UIControlStateNormal];
    if (self.model.wyyFlg) {
        [self.woyaoyueButton setImage:[UIImage imageNamed:@"yaoyueyes"] forState:UIControlStateNormal];
    }else{
        [self.woyaoyueButton setImage:[UIImage imageNamed:@"yaoyueno"] forState:UIControlStateNormal];
    }
    [footerView addSubview:self.woyaoyueButton];
    [self.woyaoyueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-90 * scale);
        make.top.mas_equalTo(60 * scale);
        make.height.mas_equalTo(75 * scale);
    }];
    
    self.liuyanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.liuyanButton setBackgroundColor:[UIColorFromRGB(0x999999) colorWithAlphaComponent:.3f]];
    [footerView addSubview:self.liuyanButton];
    [self.liuyanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(120 * scale);
        make.bottom.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.liuyanButton];
    
    self.liuyanLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    [self.liuyanButton addSubview:self.liuyanLabel];
    self.liuyanLabel.text = [NSString stringWithFormat:@"共%ld条留言，查看或评论...", self.model.messageCount];
    [self.liuyanLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(36 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(50 * scale);
    }];
    
    self.tableView.tableFooterView = footerView;
}

#pragma mark - 创建tableView头视图
- (void)createHeaderView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 408 * scale)];
    self.headerView.backgroundColor = [UIColor whiteColor];
    
    self.firstImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [self.headerView addSubview:self.firstImageView];
    [self.firstImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(.1f);
    }];
    
    UIView * timeView = [[UIView alloc] initWithFrame:CGRectZero];
    timeView.backgroundColor = UIColorFromRGB(0xE18CA4);
    [self.headerView addSubview:timeView];
    [timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-24 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    
    self.locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.locationButton.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.headerView addSubview:self.locationButton];
    [self.locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(120 * scale);
        make.bottom.mas_equalTo(timeView.mas_top);
    }];
    
    UIView * userView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 144 * scale)];
    userView.backgroundColor = [UIColorFromRGB(0x111111) colorWithAlphaComponent:.5f];
    [self.headerView addSubview:userView];
    [userView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.locationButton.mas_top);
        make.height.mas_equalTo(144 * scale);
    }];
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [userView addSubview:self.logoImageView];
    [self.logoImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.centerY.mas_equalTo(0);
        make.width.height.mas_equalTo(96 * scale);
    }];
    [DDViewFactoryTool cornerRadius:48 * scale withView:self.logoImageView];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangMedium(42 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentLeft];
    [userView addSubview:self.nameLabel];
    [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(20 * scale);
        make.right.mas_equalTo(-300 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(50 * scale);
    }];
    
    self.dazhaohuButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"打招呼+0"];
    if (self.isSelfFlg) {
        [self.dazhaohuButton setTitle:[NSString stringWithFormat:@"打招呼+%ld", self.model.dzfCount] forState:UIControlStateNormal];
        [self.dazhaohuButton setImage:[UIImage imageNamed:@"dazhaohuzuozhe"] forState:UIControlStateNormal];
        self.dazhaohuButton.userInteractionEnabled = NO;
    }else{
        [self.dazhaohuButton setTitle:@"" forState:UIControlStateNormal];
        [self.dazhaohuButton setImage:[UIImage imageNamed:@"sayhi"] forState:UIControlStateNormal];
    }
    [userView addSubview:self.dazhaohuButton];
    [self.dazhaohuButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20 * scale);
        make.width.mas_equalTo(250 * scale);
        make.top.bottom.mas_equalTo(0);
    }];
    
    self.locationLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [self.locationButton addSubview:self.locationLabel];
    [self.locationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-160 * scale);
        make.height.mas_equalTo(45 * scale);
        make.centerY.mas_equalTo(0);
    }];
    
    UIImageView * locationImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"locationEdit"]];
    [self.locationButton addSubview:locationImageView];
    [locationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
        make.width.height.mas_equalTo(72 * scale);
    }];
    
    self.senceTimelabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(54 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentLeft];
    [timeView addSubview:self.senceTimelabel];
    [self.senceTimelabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(60 * scale);
    }];
    
    self.tableView.tableHeaderView = self.headerView;
    
    [self configHeaderView];
}

- (void)configHeaderView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    if (self.firstImage) {
        CGFloat imageHeight = [DDTool getHeightWithImage:self.firstImage];
        [self.firstImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(imageHeight);
        }];
        [self.firstImageView setImage:self.firstImage];
        self.headerView.frame = CGRectMake(0, 0, kMainBoundsWidth, 264 * scale + imageHeight);
        self.tableView.tableHeaderView = self.headerView;
    }
    
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:self.model.portraituri]];
    self.nameLabel.text = self.model.nickname;
    self.locationLabel.text = self.model.sceneAddress;
    self.senceTimelabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.model.sceneTime];
}

@end
