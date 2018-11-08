//
//  NotificationTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/13.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "NotificationTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "UpdateNotificationStatusRequest.h"

@interface NotificationTableViewCell ()

@property (nonatomic, strong) DTieModel * model;

@property (nonatomic, strong) UIImageView * postImageView;
@property (nonatomic, strong) UILabel * postTitleLabel;
@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UIButton * handleButton;

@end

@implementation NotificationTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createNotificationTableCell];
    }
    return self;
}

- (void)configWithModel:(DTieModel *)model
{
    self.model = model;
    [self.postImageView sd_setImageWithURL:[NSURL URLWithString:model.postFirstPicture]];
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    self.postTitleLabel.text = model.postSummary;
    
    [self reloadModelAlertStatus];
}

- (void)reloadModelAlertStatus
{
    if (self.model.remindStatus == 0) {
        [self.handleButton setTitle:DDLocalizedString(@"Not yet reminded") forState:UIControlStateNormal];
    }else if (self.model.remindStatus == 1) {
        [self.handleButton setTitle:DDLocalizedString(@"No more for today") forState:UIControlStateNormal];
    }else if (self.model.remindStatus == 2) {
        [self.handleButton setTitle:DDLocalizedString(@"Not in 3 months") forState:UIControlStateNormal];
    }else if (self.model.remindStatus == 3) {
        [self.handleButton setTitle:DDLocalizedString(@"Not in 1 year") forState:UIControlStateNormal];
    }else if (self.model.remindStatus == 4) {
        [self.handleButton setTitle:DDLocalizedString(@"Never this again") forState:UIControlStateNormal];
    }
}

- (void)createNotificationTableCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView * BGView = [[UIView alloc] initWithFrame:CGRectZero];
    BGView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:BGView];
    BGView.layer.cornerRadius = 24 * scale;
    BGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    BGView.layer.shadowOpacity = .3f;
    BGView.layer.shadowRadius = 8 * scale;
    BGView.layer.shadowOffset = CGSizeMake(0, 8 * scale);
    [BGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(80 * scale);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(450 * scale);
        make.height.mas_equalTo(280 * scale);
    }];
    
    UIView * coverView = [[UIView alloc] initWithFrame:CGRectZero];
    coverView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.contentView addSubview:coverView];
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(BGView.mas_bottom).offset(-24 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    self.postImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [BGView addSubview:self.postImageView];
    [self.postImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.postImageView];
    
    UIView * blackView = [[UIView alloc] initWithFrame:CGRectZero];
    blackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    [self.postImageView addSubview:blackView];
    [blackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-24 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    
    self.postTitleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentLeft];
    [blackView addSubview:self.postTitleLabel];
    [self.postTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(20 * scale);
        make.right.mas_equalTo(-20 * scale);
    }];
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [self.contentView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(BGView.mas_left).offset(-20 * scale);
        make.top.mas_equalTo(BGView).offset(-30 * scale);
        make.width.height.mas_equalTo(108 * scale);
    }];
    [DDViewFactoryTool cornerRadius:54 * scale withView:self.logoImageView];
    
    self.handleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:DDLocalizedString(@"No more for today")];
    [self.contentView addSubview:self.handleButton];
    [self.handleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(coverView.mas_bottom);
        make.height.mas_equalTo(72 * scale);
    }];
    [DDViewFactoryTool cornerRadius:36 * scale withView:self.handleButton];
    self.handleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.handleButton.layer.borderWidth = 3 * scale;
    [self.handleButton addTarget:self action:@selector(handleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)handleButtonDidClicked
{
    [UpdateNotificationStatusRequest cancelRequest];
    NSInteger resultStatus = 0;
    if (self.model.remindStatus == 0) {
        resultStatus = 1;
    }else if (self.model.remindStatus == 1) {
        resultStatus = 2;
    }else if (self.model.remindStatus == 2) {
        resultStatus = 3;
    }else if (self.model.remindStatus == 3) {
        resultStatus = 4;
    }else if (self.model.remindStatus == 4) {
        resultStatus = 0;
    }
    
    NSInteger postID = self.model.postId;
    if (postID == 0) {
        postID = self.model.cid;
    }
    UpdateNotificationStatusRequest * request = [[UpdateNotificationStatusRequest alloc] initWithPostID:postID status:resultStatus];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (self.model.postId == postID) {
            self.model.remindStatus = resultStatus;
            [self reloadModelAlertStatus];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
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
