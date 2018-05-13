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
    
    self.tieImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleToFill image:[UIImage new]];
    [self.tieImageView setImage:[UIImage imageNamed:@"AddBG"]];
    [self.contentView addSubview:self.tieImageView];
    self.tieImageView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.tieImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(self.tieImageView.mas_width).multipliedBy(9.f/16.f);
    }];
    
    self.seeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"设置到地可见"];
    [self.seeButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.contentView addSubview:self.seeButton];
    [self.seeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tieImageView.mas_bottom).offset(20 * scale);
        make.bottom.mas_equalTo(-40 * scale);
        make.right.mas_equalTo(-30 * scale);
        make.width.mas_equalTo(350 * scale);
    }];
}

- (void)configWithEditModel:(DTieEditModel *)model
{
    if (model.image) {
        [self.tieImageView setImage:model.image];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint tempPoint = [self convertPoint:point toView:self.tieImageView];
    
    if (tempPoint.x < 0 || tempPoint.y < 0) {
        return NO;
    }
    
    return YES;
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
