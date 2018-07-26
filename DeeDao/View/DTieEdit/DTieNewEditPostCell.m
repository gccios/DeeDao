//
//  DTieNewEditPostCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieNewEditPostCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "DDTool.h"

@interface DTieNewEditPostCell ()

@property (nonatomic, strong) DTieEditModel * model;

@property (nonatomic, strong) UIImageView * postImageView;
@property (nonatomic, strong) UILabel * postNameLabel;
@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UILabel * addressLabel;

@end

@implementation DTieNewEditPostCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createNewEditPostCell];
    }
    return self;
}

- (void)configWithModel:(DTieEditModel *)model
{
    self.model = model;
    [self.postImageView sd_setImageWithURL:[NSURL URLWithString:model.postFirstPicture]];
    self.postNameLabel.text = model.postSummary;
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    self.nameLabel.text = model.nickname;
    self.timeLabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:model.updateTime];
    self.addressLabel.text = model.sceneAddress;
}

- (void)createNewEditPostCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.backgroundColor = UIColorFromRGB(0xEFEFF4);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView * baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 288 * scale)];
    baseView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:baseView];
    [baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(288 * scale);
    }];
    
    self.postImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [baseView addSubview:self.postImageView];
    [self.postImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(360 * scale);
        make.height.mas_equalTo(216 * scale);
    }];
    self.postImageView.clipsToBounds = YES;
    
    UIView * postBlackView = [[UIView alloc] init];
    postBlackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    [self.postImageView addSubview:postBlackView];
    [postBlackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(72 * scale);
    }];
    
    self.postNameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentLeft];
    [postBlackView addSubview:self.postNameLabel];
    [self.postNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10 * scale);
        make.right.mas_equalTo(10 * scale);
        make.top.bottom.mas_equalTo(0);
    }];
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [baseView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.postImageView.mas_right).offset(60 * scale);
        make.top.mas_equalTo(self.postImageView);
        make.width.mas_equalTo(96 * scale);
        make.height.mas_equalTo(96 * scale);
    }];
    [DDViewFactoryTool cornerRadius:48 * scale withView:self.logoImageView];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [baseView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.logoImageView);
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(40 * scale);
        make.right.mas_equalTo(-40 * scale);
    }];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [baseView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(30 * scale);
        make.left.mas_equalTo(self.logoImageView);
        make.right.mas_equalTo(-40 * scale);
    }];
    
    self.addressLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [baseView addSubview:self.addressLabel];
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(10 * scale);
        make.left.mas_equalTo(self.logoImageView);
        make.right.mas_equalTo(-40 * scale);
    }];
    
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addButton setImage:[UIImage imageNamed:@"addEdit"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.addButton];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(baseView.mas_bottom).offset(24 * scale);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(72 * scale);
    }];
    [self.addButton addTarget:self action:@selector(addButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addButtonDidClicked
{
    if (self.addButtonHandle) {
        self.addButtonHandle();
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
