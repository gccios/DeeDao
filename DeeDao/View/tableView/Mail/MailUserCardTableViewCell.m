
//
//  MailUserCardTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/10.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "MailUserCardTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import "DDTool.h"
#import "SaveFriendOrConcernRequest.h"
#import "AddFriendRequest.h"
#import "MBProgressHUD+DDHUD.h"
#import <UIImageView+WebCache.h>
#import "DDLGSideViewController.h"

@interface MailUserCardTableViewCell ()

@property (nonatomic, strong) UserMailModel * model;

@property (nonatomic, strong) UIImageView * coverImageView;
@property (nonatomic, strong) UIImageView * bloggerImageView;

@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UIView * baseView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * timeLabel;

@property (nonatomic, strong) UIButton * leftButton;
@property (nonatomic, strong) UIButton * rightButton;

@end

@implementation MailUserCardTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createSmallCell];
    }
    return self;
}

- (void)createSmallCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.backgroundColor = UIColorFromRGB(0xEFEFF4);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.baseView];
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(54 * scale);
        make.left.mas_equalTo(54 * scale);
        make.right.mas_equalTo(-54 * scale);
        make.bottom.mas_equalTo(0);
    }];
    
    UIImage * bgImage = [UIImage imageNamed:@"smallkuang"];
    self.coverImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleToFill image:[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(bgImage.size.height*0.9, bgImage.size.width*0.9, bgImage.size.height*0.9, bgImage.size.width*0.9) resizingMode:UIImageResizingModeStretch]];
    self.coverImageView.layer.masksToBounds = YES;
    [self.baseView addSubview:self.coverImageView];
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
    }];
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"yt-dazhaohu"]];
    [self.baseView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(70 * scale);
        make.centerY.mas_equalTo(-40 * scale);
        make.width.height.mas_equalTo(90 * scale);
    }];
    [DDViewFactoryTool cornerRadius:45 * scale withView:self.logoImageView];
    
    self.bloggerImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.bloggerImageView setImage:[UIImage imageNamed:@"bozhuTag"]];
    [self.baseView addSubview:self.bloggerImageView];
    [self.bloggerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.logoImageView.mas_bottom).offset(-15 * scale);
        make.width.mas_equalTo(120 * scale);
        make.height.mas_equalTo(36 * scale);
        make.centerX.mas_equalTo(self.logoImageView);
    }];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentRight];
    [self.baseView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(45 * scale);
        make.right.mas_equalTo(-45 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    //    self.nameLabel.text = @"Just丶DeeDao";
    [self.baseView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(45 * scale);
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(35 * scale);
        make.right.mas_equalTo(self.timeLabel.mas_left).offset(-20 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
    
    self.rightButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:DDLocalizedString(@"AddFollow")];
    [self.baseView addSubview:self.rightButton];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(35 * scale);
        make.right.mas_equalTo(-45 * scale);
        make.height.mas_equalTo(72 * scale);
        make.width.mas_equalTo(216 * scale);
    }];
    [DDViewFactoryTool cornerRadius:12 * scale withView:self.rightButton];
    self.rightButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.rightButton.layer.borderWidth = 3 * scale;
    
    self.leftButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"申请好友"];
    [self.baseView addSubview:self.leftButton];
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(35 * scale);
        make.right.mas_equalTo(self.rightButton.mas_left).offset(-48 * scale);
        make.height.mas_equalTo(72 * scale);
        make.width.mas_equalTo(216 * scale);
    }];
    [DDViewFactoryTool cornerRadius:12 * scale withView:self.leftButton];
    self.leftButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.leftButton.layer.borderWidth = 3 * scale;
    
    UIView * coverView = [[UIView alloc] initWithFrame:CGRectZero];
    coverView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.contentView addSubview:coverView];
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(24 * scale);
    }];
    coverView.layer.shadowColor = UIColorFromRGB(0x333333).CGColor;
    coverView.layer.shadowOpacity = .2f;
    coverView.layer.shadowOffset = CGSizeMake(0, -12 * scale);
    
    [self.leftButton addTarget:self action:@selector(leftButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addTarget:self action:@selector(rightButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)leftButtonDidClicked
{
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    
    if (self.model.ifFriendFlg == 1) {
        
//        [SaveFriendOrConcernRequest cancelRequest];
//        SaveFriendOrConcernRequest * request = [[SaveFriendOrConcernRequest alloc] initWithHandleFriendId:self.model.cid andIsAdd:NO];
//        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
//
//            [MBProgressHUD showTextHUDWithText:@"删除好友成功" inView:na.view];
//            self.model.friendFlg = 0;
//            [self reloadWithModelStatus];
//
//        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
//
//            [MBProgressHUD showTextHUDWithText:@"删除好友失败" inView:na.view];
//
//        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
//
//            [MBProgressHUD showTextHUDWithText:@"删除好友失败" inView:na.view];
//
//        }];
        
    }else{
        
        [AddFriendRequest cancelRequest];
        AddFriendRequest * request = [[AddFriendRequest alloc] initWithUserId:self.model.userId];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [MBProgressHUD showTextHUDWithText:@"好友请求已发送" inView:na.view];
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [MBProgressHUD showTextHUDWithText:@"好友请求发送失败" inView:na.view];
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
            [MBProgressHUD showTextHUDWithText:@"好友请求发送失败" inView:na.view];
            
        }];
        
    }
}

- (void)rightButtonDidClicked
{
    if (self.model.ifFollowedFlg == 1) {
        return;
    }
    
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    
    BOOL isAdd = YES;
    if (self.model.ifFollowedFlg == 1) {
        isAdd = NO;
    }
    
    [SaveFriendOrConcernRequest cancelRequest];
    SaveFriendOrConcernRequest * request = [[SaveFriendOrConcernRequest alloc] initWithHandleConcernId:self.model.userId andIsAdd:isAdd];
    
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        self.model.ifFollowedFlg = !self.model.ifFollowedFlg;
        
        [self reloadWithModelStatus];
        
        if (isAdd) {
            [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"AddFollow") inView:na.view];
        }else{
            [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"De-Follow") inView:na.view];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (isAdd) {
            [MBProgressHUD showTextHUDWithText:@"关注失败" inView:na.view];
        }else{
            [MBProgressHUD showTextHUDWithText:@"取消关注失败" inView:na.view];
        }
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        if (isAdd) {
            [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:na.view];
        }else{
            [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:na.view];
        }
        
    }];
}

- (void)configWithModel:(UserMailModel *)model
{
    self.model = model;
    self.nameLabel.text = model.nickname;
    self.timeLabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:model.createdat];
    
    UIImage * bgImage = [UIImage imageNamed:@"smallkuang"];
    [self.coverImageView setImage:[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(bgImage.size.height*0.9, bgImage.size.width*0.9, bgImage.size.height*0.9, bgImage.size.width*0.9) resizingMode:UIImageResizingModeStretch]];
    [self.logoImageView setImage:[UIImage imageNamed:@"yt-dazhaohu"]];
    
    if (!isEmptyString(model.portraituri)) {
        [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    }
    [self reloadWithModelStatus];
}

- (void)reloadWithModelStatus
{
    if (self.model.bloggerFlg == 1) {
        self.bloggerImageView.hidden = NO;
    }else{
        self.bloggerImageView.hidden = YES;
    }
    
    if (self.model.ifFriendFlg == 1) {
        [self.leftButton setTitle:DDLocalizedString(@"Already connected") forState:UIControlStateNormal];
        self.leftButton.alpha = .5f;
    }else{
        [self.leftButton setTitle:@"申请好友" forState:UIControlStateNormal];
        self.leftButton.alpha = 1.f;
    }
    
    if (self.model.ifFollowedFlg == 1) {
        [self.rightButton setTitle:DDLocalizedString(@"Already follow") forState:UIControlStateNormal];
        self.rightButton.alpha = .5f;
    }else{
        [self.rightButton setTitle:DDLocalizedString(@"AddFollow") forState:UIControlStateNormal];
        self.rightButton.alpha = 1.f;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
