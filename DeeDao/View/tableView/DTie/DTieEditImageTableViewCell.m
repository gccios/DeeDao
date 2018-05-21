//
//  DTieEditImageTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/11.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieEditImageTableViewCell.h"
#import <Masonry.h>
#import "DDViewFactoryTool.h"

@interface DTieEditImageTableViewCell ()

@property (nonatomic, strong) UIImageView * tieImageView;

@property (nonatomic, strong) UIButton * seeButton;

@property (nonatomic, strong) DTieEditModel * model;

@end

@implementation DTieEditImageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createEditCell];
    }
    return self;
}

- (void)createEditCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.tieImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFit image:[UIImage new]];
    [self.tieImageView setImage:[UIImage imageNamed:@"AddBG"]];
    [self.contentView addSubview:self.tieImageView];
    self.tieImageView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.tieImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(0);
        make.width.mas_equalTo(kMainBoundsWidth);
        make.bottom.mas_equalTo(-170 * scale);
    }];
    
    self.seeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"设置到地可见"];
    [self.seeButton addTarget:self action:@selector(seeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.seeButton setImage:[UIImage imageNamed:@"qxno"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.seeButton];
    [self.seeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tieImageView.mas_bottom).offset(10 * scale);
        make.bottom.mas_equalTo(-30 * scale);
        make.right.mas_equalTo(-30 * scale);
        make.width.mas_equalTo(350 * scale);
    }];
}

- (void)configWithEditModel:(DTieEditModel *)model
{
    self.model = model;
    if (model.image) {
        [self.tieImageView setImage:model.image];
    }
    if (self.model.pFlag) {
        [self.seeButton setImage:[UIImage imageNamed:@"qx"] forState:UIControlStateNormal];
    }else{
        [self.seeButton setImage:[UIImage imageNamed:@"qxno"] forState:UIControlStateNormal];
    }
}

- (void)seeButtonDidClicked
{
    self.model.pFlag = !self.model.pFlag;
    if (self.model.pFlag) {
        [self.seeButton setImage:[UIImage imageNamed:@"qx"] forState:UIControlStateNormal];
    }else{
        [self.seeButton setImage:[UIImage imageNamed:@"qxno"] forState:UIControlStateNormal];
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
