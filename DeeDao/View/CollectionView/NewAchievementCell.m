//
//  NewAchievementCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "NewAchievementCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "GetMedalDetailRequest.h"
#import "DTieImageCollectionViewCell.h"
#import "DTieTextCollectionViewCell.h"
#import "DTieVideoCollectionViewCell.h"
#import "DTiePostCollectionViewCell.h"
#import "DDLocationManager.h"
#import "TYCyclePagerView.h"
#import "UserManager.h"
#import "MBProgressHUD+DDHUD.h"
#import "UserInfoViewController.h"
#import "DDTool.h"
#import "DDLGSideViewController.h"
#import "LookImageViewController.h"
#import "DDBackWidow.h"
#import <AVKit/AVKit.h>
#import "OnlyTextViewController.h"
#import "DTieDetailRequest.h"
#import "DTieNewDetailViewController.h"

@interface NewAchievementCell () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UIButton * showButton;

@property (nonatomic, strong) AchievementModel * model;
@property (nonatomic, assign) BOOL isFirstRead;
@property (nonatomic, assign) NSIndexPath * firestIndex;
@property (nonatomic, strong) UIView * baseView;
//@property (nonatomic, strong) UIImageView * collectImageView;

@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, strong) GetMedalDetailRequest * request;

@end

@implementation NewAchievementCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createListViewCell];
    }
    return self;
}

- (void)showButtonDidClicked
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:self];
    
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:self.model.medalObjectId type:4 start:0 length:10];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        
        if (KIsDictionary(response)) {
            
            NSInteger code = [[response objectForKey:@"status"] integerValue];
            if (code == 4002) {
                [MBProgressHUD showTextHUDWithText:@"该帖已被删除~" inView:self];
                return;
            }
            
            if (code == 4003) {
                [MBProgressHUD showTextHUDWithText:@"该帖已经下线~" inView:self];
                return;
            }
            
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                
                if (dtieModel.deleteFlg == 1) {
                    [MBProgressHUD showTextHUDWithText:@"该帖已被删除~" inView:self];
                    return;
                }
                
                for (DTieEditModel * blockModel in dtieModel.details) {
                    blockModel.pFlag = 0;
                }
                
                DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                UINavigationController * na = (UINavigationController *)lg.rootViewController;
                DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initWithDTie:dtieModel];
                [na pushViewController:detail animated:YES];
            }
        }
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
    }];
}

- (void)createListViewCell
{
    self.dataSource = [[NSMutableArray alloc] init];
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.baseView = [[UIView alloc] init];
    self.baseView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.contentView addSubview:self.baseView];
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.bottom.right.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.baseView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.baseView.backgroundColor;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = kMainBoundsHeight - (kStatusBarHeight + 980) * scale;
    self.tableView.pagingEnabled = YES;
    [self.tableView registerClass:[DTieVideoCollectionViewCell class] forCellReuseIdentifier:@"DTieVideoCollectionViewCell"];
    [self.tableView registerClass:[DTieImageCollectionViewCell class] forCellReuseIdentifier:@"DTieImageCollectionViewCell"];
    [self.tableView registerClass:[DTieTextCollectionViewCell class] forCellReuseIdentifier:@"DTieTextCollectionViewCell"];
    [self.tableView registerClass:[DTiePostCollectionViewCell class] forCellReuseIdentifier:@"DTiePostCollectionViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.baseView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(30 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(kMainBoundsHeight - (kStatusBarHeight + 980) * scale);
    }];
    
    UIView * logoBGView = [[UIView alloc] initWithFrame:CGRectZero];
    logoBGView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:logoBGView];
    [logoBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.bottom.mas_equalTo(-90 * scale);
        make.height.width.mas_equalTo(96 * scale);
    }];
    logoBGView.layer.cornerRadius = 48 * scale;
    logoBGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    logoBGView.layer.shadowOpacity = .3f;
    logoBGView.layer.shadowRadius = 4 * scale;
    logoBGView.layer.shadowOffset = CGSizeMake(0, 2 * scale);
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [logoBGView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:48 * scale withView:self.logoImageView];
    UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookUserInfo)];
    self.logoImageView.userInteractionEnabled = YES;
    [self.logoImageView addGestureRecognizer:tap1];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    self.nameLabel.numberOfLines = 2;
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(20 * scale);
        make.right.mas_equalTo(-300 * scale);
        make.centerY.mas_equalTo(self.logoImageView);
    }];
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookUserInfo)];
    self.nameLabel.userInteractionEnabled = YES;
    [self.nameLabel addGestureRecognizer:tap2];
    
    self.showButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@""];
    [self.showButton setImage:[UIImage imageNamed:@"qukantiezi"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.showButton];
    [self.showButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-30 * scale);
        make.width.mas_equalTo(268 * scale);
        make.centerY.mas_lessThanOrEqualTo(self.logoImageView);
        make.height.mas_equalTo(148 * scale);
    }];
    [self.showButton addTarget:self action:@selector(showButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)lookUserInfo
{
//    AchievementModel * model = self.model;
//    if (model) {
//        DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
//        UINavigationController * na = (UINavigationController *)lg.rootViewController;
//        UserInfoViewController * info = [[UserInfoViewController alloc] initWithUserId:model.authorId];
//        [na pushViewController:info animated:YES];
//    }
}

- (void)configWithModel:(AchievementModel *)model tag:(NSInteger)tag
{
    self.request = nil;
    self.model = model;
    
    self.tableView.tag = tag;
    self.isFirstRead = YES;
    
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.medalObjectImg]];
    self.nameLabel.text = [NSString stringWithFormat:@"您在%@\n到过Ta的D帖", [DDTool getTimeWithFormat:@"yyyy年MM月" time:model.createTime]];
    
    if (model.details) {
        
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:model.details];
        
        [self.tableView setContentOffset:CGPointZero animated:NO];
        [self.tableView reloadData];
        return;
    }
    
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    
    //    [DTieDetailRequest cancelRequest];
    
    NSInteger medalID = model.cid;
    
    self.request = [[GetMedalDetailRequest alloc] initWithID:medalID];
    [self.request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                [model mj_setKeyValues:data];
                
                if (request == self.request) {
                    [self.dataSource removeAllObjects];
                    [self.dataSource addObjectsFromArray:model.details];
                    
                    [self.tableView setContentOffset:CGPointZero animated:NO];
                    [self.tableView reloadData];
                }
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTieEditModel * model = [self.dataSource objectAtIndex:indexPath.row];
    
    if (model.type == DTieEditType_Image) {
        DTieImageCollectionViewCell * imageCell = [tableView dequeueReusableCellWithIdentifier:@"DTieImageCollectionViewCell" forIndexPath:indexPath];
        [imageCell configWithModel:model Dtie:nil];
        return imageCell;
    }else if (model.type == DTieEditType_Text){
        DTieTextCollectionViewCell * textCell = [tableView dequeueReusableCellWithIdentifier:@"DTieTextCollectionViewCell" forIndexPath:indexPath];
        [textCell configWithModel:model Dtie:nil];
        return textCell;
    }else if (model.type == DTieEditType_Video) {
        DTieVideoCollectionViewCell * videoCell = [tableView dequeueReusableCellWithIdentifier:@"DTieVideoCollectionViewCell" forIndexPath:indexPath];
        [videoCell configWithModel:model Dtie:nil];
        return videoCell;
    }else if (model.type == DTieEditType_Post) {
        DTiePostCollectionViewCell * postCell = [tableView dequeueReusableCellWithIdentifier:@"DTiePostCollectionViewCell" forIndexPath:indexPath];
        [postCell configWithModel:model Dtie:nil];
        return postCell;
    }
    
    DTieImageCollectionViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieImageCollectionViewCell" forIndexPath:indexPath];
    
    [cell configWithModel:model Dtie:nil];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    
    DTieEditModel * model = [self.dataSource objectAtIndex:indexPath.row];
    if (model.type == DTieEditType_Image) {
         LookImageViewController * lookImage = [[LookImageViewController alloc] initWithImageURL:model.detailsContent];
        [na presentViewController:lookImage animated:YES completion:nil];
        [[DDBackWidow shareWindow] hidden];
    }else if (model.type == DTieEditType_Video) {
        NSURL * url;
        if (model.videoURL) {
            url = model.videoURL;
        }else{
            url = [NSURL URLWithString:model.textInformation];
        }
        
        AVPlayerViewController * player = [[AVPlayerViewController alloc] init];
        player.player = [[AVPlayer alloc] initWithURL:url];
        player.videoGravity = AVLayerVideoGravityResizeAspect;
        [na presentViewController:player animated:YES completion:nil];
        [[DDBackWidow shareWindow] hidden];
    }else if (model.type == DTieEditType_Text) {
        NSString * text = model.detailContent;
        if (isEmptyString(text)) {
            text = model.detailsContent;
        }
        OnlyTextViewController * only = [[OnlyTextViewController alloc] initWithText:text];
        [na presentViewController:only animated:YES completion:nil];
        [[DDBackWidow shareWindow] hidden];
    }
}

@end
