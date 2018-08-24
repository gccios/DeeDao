//
//  AlertSingleTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "AlertSingleTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>

@interface AlertSingleTableViewCell ()

@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UIImageView * choosImageView;

@end

@implementation AlertSingleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createAlertCell];
    }
    return self;
}

- (void)configTitle:(NSString *)title
{
    self.nameLabel.text = title;
}

- (void)configChooseStatus:(BOOL)chooseStaus
{
    if (chooseStaus) {
        [self.choosImageView setImage:[UIImage imageNamed:@"singleyes"]];
    }else{
        [self.choosImageView setImage:[UIImage imageNamed:@"singleno"]];
    }
}

- (void)createAlertCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.top.bottom.mas_equalTo(0);
    }];
    
    self.choosImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"singleno"]];
    [self.contentView addSubview:self.choosImageView];
    [self.choosImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
        make.width.height.mas_equalTo(72 * scale);
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
