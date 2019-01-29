//
//  DDGroupPeopleTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/10.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDGroupPeopleTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import "UIView+LayerCurve.h"
#import <UIImageView+WebCache.h>
#import "DDGroupRequest.h"
#import "UserManager.h"
#import "MBProgressHUD+DDHUD.h"

@interface DDGroupPeopleTableViewCell ()

@property (nonatomic, strong) UserModel * model;

@property (nonatomic, strong) UIImageView * vipImageView;
@property (nonatomic, strong) UIImageView * logoImageview;
@property (nonatomic, strong) UILabel * nameLabel;

@property (nonatomic, strong) UIButton * applyButton;
@property (nonatomic, strong) UIButton * removeButton;
@property (nonatomic, strong) UIButton * toApplyButton;
@property (nonatomic, strong) UIButton * giveButton;

@end

@implementation DDGroupPeopleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createGroupPeopleCell];
    }
    return self;
}

- (void)configApplyWithModel:(UserModel *)model
{
    self.model = model;
    
    self.toApplyButton.hidden = YES;
    self.applyButton.hidden = NO;
    self.removeButton.hidden = NO;
    self.giveButton.hidden = YES;
    
    [self.logoImageview sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    self.nameLabel.text = model.nickname;
    
    self.vipImageView.hidden = YES;
    [self.vipImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(-25 * kMainBoundsWidth / 375.f);
    }];
}

- (void)configPeopleWithModel:(UserModel *)model
{
    self.model = model;
    self.toApplyButton.hidden = NO;
    self.applyButton.hidden = YES;
    self.removeButton.hidden = YES;
    self.giveButton.hidden = YES;
    
    [self.logoImageview sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    self.nameLabel.text = model.nickname;
    
    self.vipImageView.hidden = NO;
    [self.vipImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20 * kMainBoundsWidth / 375.f);
    }];
    if (model.authority == 0) {
        [self.vipImageView setImage:[UIImage imageNamed:@"VIPYes"]];
    }else{
        [self.vipImageView setImage:[UIImage imageNamed:@"VIPDefault"]];
    }
}

- (void)configGiveWithModel:(UserModel *)model
{
    self.model = model;
    self.toApplyButton.hidden = YES;
    self.applyButton.hidden = YES;
    self.removeButton.hidden = YES;
    self.giveButton.hidden = NO;
    
    [self.logoImageview sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    self.nameLabel.text = model.nickname;
    
    self.vipImageView.hidden = YES;
    [self.vipImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(-25 * kMainBoundsWidth / 375.f);
    }];
}

- (void)VIPImageViewDidTap
{
    NSInteger authority = 0;
    if (self.model.authority == 0) {
        authority = 1;
    }
    
    NSInteger state = 0;
    if ([UserManager shareManager].user.cid == self.model.cid) {
        state = 1;
    }
    
    [DDGroupRequest cancelRequest];
    DDGroupRequest * request = [[DDGroupRequest alloc] initEditVIPWithID:[self.model.groupListID integerValue] groupId:self.model.groupID userId:self.model.cid authority:authority state:state];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        self.model.authority = authority;
        if (self.model.authority == 0) {
            [self.vipImageView setImage:[UIImage imageNamed:@"VIPYes"]];
            [MBProgressHUD showTextHUDWithText:@"超级群成员帖子无需审批" inView:[UIApplication sharedApplication].keyWindow];
        }else{
            [self.vipImageView setImage:[UIImage imageNamed:@"VIPDefault"]];
            [MBProgressHUD showTextHUDWithText:@"普通群成员帖子需要审批" inView:[UIApplication sharedApplication].keyWindow];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)createGroupPeopleCell
{
    CGFloat scale = kMainBoundsWidth / 360.f;
    
    self.contentView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.vipImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFit image:[UIImage imageNamed:@"VIPDefault"]];
    [self.contentView addSubview:self.vipImageView];
    [self.vipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(20 * scale);
        make.width.height.mas_equalTo(32 * scale);
    }];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(VIPImageViewDidTap)];
    self.vipImageView.userInteractionEnabled = YES;
    [self.vipImageView addGestureRecognizer:tap];
    
    UIView * logoView = [[UIView alloc] initWithFrame:CGRectZero];
    logoView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    logoView.layer.shadowColor = [UIColor colorWithRed:245/255.0 green:166/255.0 blue:35/255.0 alpha:1.0].CGColor;
    logoView.layer.shadowOffset = CGSizeMake(0,2);
    logoView.layer.shadowOpacity = 1;
    logoView.layer.shadowRadius = 4;
    logoView.layer.cornerRadius = 18 * scale;
    [self.contentView addSubview:logoView];
    [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(self.vipImageView.mas_right).offset(8 * scale);
        make.width.height.mas_equalTo(36 * scale);
    }];
    
    self.logoImageview = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [logoView addSubview:self.logoImageview];
    [self.logoImageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:18 * scale withView:self.logoImageview];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(16 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(self.logoImageview.mas_right).offset(15 * scale);
        make.height.mas_equalTo(25 * scale);
        make.right.mas_equalTo(-100 * scale);
    }];
    
    self.removeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(12 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"移除"];
    [self.contentView addSubview:self.removeButton];
    [self.removeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-20 * scale);
        make.height.mas_equalTo(16 * scale);
    }];
    [self.removeButton addTarget:self action:@selector(handleButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.applyButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(12 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"批准"];
    [self.contentView addSubview:self.applyButton];
    [self.applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(16 * scale);
    }];
    [self.applyButton addTarget:self action:@selector(handleButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.toApplyButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(12 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"移到待审批"];
    [self.contentView addSubview:self.toApplyButton];
    [self.toApplyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-20 * scale);
        make.height.mas_equalTo(16 * scale);
    }];
    [self.toApplyButton addTarget:self action:@selector(handleButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.giveButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(12 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"移交群"];
    [self.contentView addSubview:self.giveButton];
    [self.giveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-20 * scale);
        make.height.mas_equalTo(16 * scale);
    }];
    [self.giveButton addTarget:self action:@selector(handleButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 840 * scale, 2 * scale)];
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(320 * scale);
        make.height.mas_equalTo(1 * scale);
        make.centerX.mas_equalTo(0 * scale);
        make.bottom.mas_equalTo(0 * scale);
    }];
    [lineView layerDotteLinePoints:@[[NSValue valueWithCGPoint:CGPointMake(0, 0)], [NSValue valueWithCGPoint:CGPointMake(320 * scale, 0)]] Color:UIColorFromRGB(0x999999) Width:1 * scale SolidLength:2 * scale DotteLength:2 * scale];
}

- (void)handleButtonDidClicked:(UIButton *)button
{
    if (button == self.toApplyButton) {
        if (self.toApplyButtonHandle) {
            self.toApplyButtonHandle(self.model);
        }
    }else if (button == self.applyButton) {
        if (self.applyButtonHandle) {
            self.applyButtonHandle(self.model);
        }
    }else if (button == self.removeButton) {
        if (self.deleteButtonHandle) {
            self.deleteButtonHandle(self.model);
        }
    }else if (button == self.giveButton) {
        if (self.giveButtonHandle) {
            self.giveButtonHandle(self.model);
        }
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
