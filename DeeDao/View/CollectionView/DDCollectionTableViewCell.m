//
//  DDCollectionTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/16.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDCollectionTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "DDTool.h"
#import "DDShareManager.h"
#import "DDLocationManager.h"

@interface DDCollectionTableViewCell ()

@property (nonatomic, strong) UIImageView * baseImageView;
@property (nonatomic, strong) UIImageView * playImageView;;

@property (nonatomic, strong) UIView * firstReadView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UILabel * locationLabel;
@property (nonatomic, strong) UILabel * firstReadLabel;

@property (nonatomic, strong) UIView * baseReadView;
@property (nonatomic, strong) UILabel * readLabel;

@property (nonatomic, strong) UILabel * lastLabel;

@property (nonatomic, strong) UIVisualEffectView * effectView;
@property (nonatomic, strong) UIView * coverView;

@property (nonatomic, strong) DTieModel * dtieModel;
@property (nonatomic, strong) DTieEditModel * model;

@end

@implementation DDCollectionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createCollectionTableCell];
    }
    return self;
}

- (void)createCollectionTableCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.baseImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFit image:[UIImage imageNamed:@"imageKong"]];
    [self.contentView addSubview:self.baseImageView];
    [self.baseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.baseImageView.clipsToBounds = YES;
    
    self.firstReadView = [[UIView alloc] init];
    [self.contentView addSubview:self.firstReadView];
    [self.firstReadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(54 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentLeft];
    [self.firstReadView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(57 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-120 * scale);
        make.height.mas_equalTo(60 * scale);
    }];
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    [self.firstReadView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(20 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(45 * scale);
        make.right.mas_equalTo(-120 * scale);
    }];
    self.locationLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    self.locationLabel.numberOfLines = 0;
    [self.firstReadView addSubview:self.locationLabel];
    [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(10 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-120 * scale);
    }];
    
    self.firstReadLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.firstReadLabel.numberOfLines = 0;
    [self.firstReadView addSubview:self.firstReadLabel];
    [self.firstReadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.locationLabel.mas_bottom).offset(25 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-120 * scale);
    }];
    
//    self.lastLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
//    self.lastLabel.numberOfLines = 0;
//    [self.firstReadView addSubview:self.lastLabel];
//    [self.lastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.firstReadLabel.mas_bottom).offset(25 * scale);
//        make.left.mas_equalTo(60 * scale);
//        make.right.mas_equalTo(-120 * scale);
//    }];
    
    self.baseReadView = [[UIView alloc] init];
    [self.contentView addSubview:self.baseReadView];
    [self.baseReadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.readLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.readLabel.numberOfLines = 0;
    [self.baseReadView addSubview:self.readLabel];
    [self.readLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-120 * scale);
        make.bottom.mas_equalTo(-60 * scale);
    }];
    
    self.playImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.playImageView setImage:[UIImage imageNamed:@"player"]];
    [self.contentView addSubview:self.playImageView];
    [self.playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(150 * scale);
    }];
    
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDidHandle:)];
    self.baseImageView.userInteractionEnabled = YES;
    [self.baseImageView addGestureRecognizer:longPress];
    
    self.coverView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.coverView];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(24 * scale);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-24 * scale);
    }];
    self.coverView.hidden = YES;
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    self.effectView.alpha = .98f;
    [self.coverView addSubview:self.effectView];
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    UIImageView * deedaoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    deedaoImageView.contentMode = UIViewContentModeScaleAspectFill;
    [deedaoImageView setImage:[UIImage imageNamed:@"Dtie"]];
    [self.coverView addSubview:deedaoImageView];
    [deedaoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(-30 * scale);
        make.width.height.mas_equalTo(150 * scale);
    }];
    
    UILabel * deedaoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    deedaoLabel.textAlignment = NSTextAlignmentCenter;
    deedaoLabel.font = kPingFangMedium(42 * scale);
    deedaoLabel.text = @"到 地 体 验";
    deedaoLabel.textColor = UIColorFromRGB(0xFFFFFF);
    [self.coverView addSubview:deedaoLabel];
    [deedaoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(70 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(60 * scale);
    }];
}

- (void)longPressDidHandle:(UILongPressGestureRecognizer *)longPress
{
    if (self.playImageView.isHidden) {
        ShareImageModel * model = [[ShareImageModel alloc] init];
        NSInteger postId = self.dtieModel.cid;
        if (postId == 0) {
            postId = self.dtieModel.postId;
        }
        model.postId = postId;
        model.image = self.baseImageView.image;
        model.title = self.dtieModel.postSummary;
        model.PFlag = self.model.pFlag;
        [[DDShareManager shareManager] showHandleViewWithImage:model];
    }
}

- (void)configWithModel:(DTieEditModel *)model
{
    self.model = model;
    self.playImageView.hidden = YES;
    if (model.type == DTieEditType_Image || model.type == DTieEditType_Video) {
        [self.baseImageView setImage:[UIImage new]];
        self.firstReadView.hidden = YES;
        self.baseReadView.hidden = YES;
        self.baseImageView.hidden = NO;
        
        if (isEmptyString(model.detailContent)) {
            [self.baseImageView setImage:[UIImage imageNamed:@"imageKong"]];
        }else{
            [self.baseImageView sd_setImageWithURL:[NSURL URLWithString:[DDTool getImageURLWithHtml:model.detailContent]]];
        }
        
        if (model.type == DTieEditType_Video) {
            self.playImageView.hidden = NO;
        }
        
    }else if (model.type == DTieEditType_Text){
        self.firstReadView.hidden = YES;
        self.baseReadView.hidden = NO;
        self.baseImageView.hidden = YES;
        self.readLabel.text = [DDTool getTextWithHtml:model.detailContent];
    }
}

- (void)configWithModel:(DTieEditModel *)model Dtie:(DTieModel *)dtieModel
{
    self.model = model;
    self.dtieModel = dtieModel;
    self.playImageView.hidden = YES;
    if (model.type == DTieEditType_Image || model.type == DTieEditType_Video) {
        [self.baseImageView setImage:[UIImage new]];
        self.firstReadView.hidden = YES;
        self.baseReadView.hidden = YES;
        self.baseImageView.hidden = NO;
        
        if (!isEmptyString(model.detailContent)) {
            [self.baseImageView sd_setImageWithURL:[NSURL URLWithString:[DDTool getImageURLWithHtml:model.detailContent]]];
            
        }
        
        if (model.type == DTieEditType_Image) {
            self.baseImageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.baseImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(0);
            }];
        }else{
            self.baseImageView.contentMode = UIViewContentModeScaleAspectFill;
            self.playImageView.hidden = NO;
            [self.baseImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.mas_equalTo(0);
                make.center.mas_equalTo(0);
                make.height.mas_equalTo(self.baseImageView.mas_width).multipliedBy(9.f / 16.f);
            }];
        }
        
        
    }else if (model.type == DTieEditType_Text){
        self.firstReadView.hidden = YES;
        self.baseReadView.hidden = NO;
        self.baseImageView.hidden = YES;
        self.readLabel.text = [DDTool getTextWithHtml:model.detailContent];
    }
    
    if ([[DDLocationManager shareManager] contentIsCanSeeWith:dtieModel detailModle:model]) {
        self.baseImageView.userInteractionEnabled = YES;
        self.coverView.hidden = YES;
    }else{
        self.baseImageView.userInteractionEnabled = NO;
        self.coverView.hidden = NO;
    }
}

- (void)configCanSee:(BOOL)isCansee
{
    if (isCansee) {
        self.firstReadView.hidden = YES;
        self.baseReadView.hidden = YES;
        self.baseImageView.hidden = NO;
        self.baseImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.baseImageView setImage:[UIImage imageNamed:@"shuBG"]];
    }else{
        self.baseImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

- (void)configFirstWithModel:(DTieEditModel *)model firstTime:(NSString *)firstTime location:(NSString *)location updateTime:(NSString *)updateTime
{
    self.firstReadView.hidden = NO;
    self.baseReadView.hidden = YES;
    self.baseImageView.hidden = YES;
    self.firstReadLabel.text = [DDTool getTextWithHtml:model.detailContent];
    self.timeLabel.text = firstTime;
    self.locationLabel.text = location;
    self.lastLabel.text = [NSString stringWithFormat:@"最后更新时间：%@", updateTime];
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
