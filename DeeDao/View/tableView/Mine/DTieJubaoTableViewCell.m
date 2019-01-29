//
//  DTieJubaoTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/24.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DTieJubaoTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "DDTool.h"
#import "SuperManagerRequest.h"
#import "MBProgressHUD+DDHUD.h"

@interface DTieJubaoTableViewCell ()

@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, strong) UIImageView * postImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * poiLabel;
@property (nonatomic, strong) UILabel * statusLabel;
@property (nonatomic, strong) UILabel * postTitleLabel;

@property (nonatomic, strong) UILabel * infoLabel;

@property (nonatomic, strong) UILabel * jubaoLabel;

@property (nonatomic, strong) UIButton * onLineButton;
@property (nonatomic, strong) UIButton * downLineButton;

@end

@implementation DTieJubaoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createJubaoCell];
    }
    return self;
}

- (void)configWithModel:(DTieModel *)model
{
    self.model = model;
    [self.postImageView sd_setImageWithURL:[NSURL URLWithString:model.postFirstPicture]];
    if (isEmptyString(model.postSummary)) {
        self.postTitleLabel.text = @"暂无标题";
    }else{
        self.postTitleLabel.text = model.postSummary;
    }
    
    NSString * build = model.sceneBuilding;
    if (isEmptyString(build)) {
        build = @"";
    }
    
    self.infoLabel.text = [NSString stringWithFormat:@"%@", [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:model.sceneTime]];
    self.nameLabel.text = model.nickname;
    self.poiLabel.text = model.sceneBuilding;
    
    if (self.model.subType == 1) {
        self.statusLabel.text = DDLocalizedString(@"Attend");
    }else{
        if (self.model.subType == 0) {
            self.statusLabel.text = DDLocalizedString(@"TBD");
        }else if (self.model.subType == 2) {
            self.statusLabel.text = DDLocalizedString(@"OutFollow");
        }
    }
    
    if (model.onlineFlag == 1) {
        self.downLineButton.hidden = NO;
        self.onLineButton.hidden = YES;
    }else{
        self.downLineButton.hidden = YES;
        self.onLineButton.hidden = NO;
    }
    
    self.jubaoLabel.text = [NSString stringWithFormat:@"举报时间：%@\n举报人：%@", [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:model.createTime], model.reporterName];
}

- (void)createJubaoCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    self.infoLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(38 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.infoLabel];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(50 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    
    UIView * BGView = [[UIView alloc] initWithFrame:CGRectZero];
    BGView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:BGView];
    BGView.layer.cornerRadius = 24 * scale;
    BGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    BGView.layer.shadowOpacity = .3f;
    BGView.layer.shadowRadius = 8 * scale;
    BGView.layer.shadowOffset = CGSizeMake(0, 8 * scale);
    [BGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(140 * scale);
        make.left.mas_equalTo(60 * scale);
        make.width.height.mas_equalTo(240 * scale);
    }];
    
    self.postImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [BGView addSubview:self.postImageView];
    [self.postImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.postImageView];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangMedium(48 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(BGView.mas_right).offset(25 * scale);
        make.top.mas_equalTo(BGView);
        make.right.mas_equalTo(-30 * scale);
    }];
    
    self.poiLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.poiLabel];
    [self.poiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(0 * scale);
        make.left.mas_equalTo(self.nameLabel);
        make.right.mas_equalTo(self.nameLabel);
    }];
    
    self.postTitleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.postTitleLabel];
    [self.postTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.poiLabel.mas_bottom).offset(-5 * scale);
        make.left.mas_equalTo(self.poiLabel);
        make.right.mas_equalTo(self.poiLabel);
    }];
    
    self.statusLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.statusLabel];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.postTitleLabel.mas_bottom).offset(0 * scale);
        make.left.mas_equalTo(self.postTitleLabel);
        make.right.mas_equalTo(self.postTitleLabel);
    }];
    self.statusLabel.hidden = YES;
    
    self.jubaoLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    self.jubaoLabel.numberOfLines = 2;
    [self.contentView addSubview:self.jubaoLabel];
    [self.jubaoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.postImageView.mas_bottom).offset(60 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-400 * scale);
    }];
    
    self.downLineButton = [DDViewFactoryTool createButtonWithFrame: CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"下线帖子"];
    [self.downLineButton setBackgroundColor:UIColorFromRGB(0xDB6283)];
    [self.contentView addSubview:self.downLineButton];
    [self.downLineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.width.mas_equalTo(240 * scale);
        make.height.mas_equalTo(120 * scale);
        make.top.mas_equalTo(self.postImageView.mas_bottom).offset(60 * scale);
    }];
    [DDViewFactoryTool cornerRadius:60 * scale withView:self.downLineButton];
    self.downLineButton.layer.borderWidth = 3 * scale;
    self.downLineButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    [self.downLineButton addTarget:self action:@selector(downLineButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.onLineButton = [DDViewFactoryTool createButtonWithFrame: CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"上线帖子"];
    [self.contentView addSubview:self.onLineButton];
    [self.onLineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.width.mas_equalTo(240 * scale);
        make.height.mas_equalTo(120 * scale);
        make.top.mas_equalTo(self.postImageView.mas_bottom).offset(60 * scale);
    }];
    [DDViewFactoryTool cornerRadius:60 * scale withView:self.onLineButton];
    self.onLineButton.layer.borderWidth = 3 * scale;
    self.onLineButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    [self.onLineButton addTarget:self action:@selector(onLineButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    self.onLineButton.hidden = YES;
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(20 * scale);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)onLineButtonDidClicked
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在上线" inView:[UIApplication sharedApplication].keyWindow];
    SuperManagerRequest * request = [[SuperManagerRequest alloc] initOnlinePost:self.model.cid onlineFlag:1];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        self.onLineButton.hidden = YES;
        self.downLineButton.hidden = NO;
        self.model.onlineFlag = 1;
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"上线失败" inView:[UIApplication sharedApplication].keyWindow];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"上线失败" inView:[UIApplication sharedApplication].keyWindow];
    }];
}

- (void)downLineButtonDidClicked
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在下线" inView:[UIApplication sharedApplication].keyWindow];
    SuperManagerRequest * request = [[SuperManagerRequest alloc] initOnlinePost:self.model.cid onlineFlag:0];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        self.onLineButton.hidden = NO;
        self.downLineButton.hidden = YES;
        self.model.onlineFlag = 0;
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"下线失败" inView:[UIApplication sharedApplication].keyWindow];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"下线失败" inView:[UIApplication sharedApplication].keyWindow];
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
