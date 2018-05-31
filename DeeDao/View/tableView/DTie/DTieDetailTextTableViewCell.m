//
//  DTieDetailTextTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/17.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieDetailTextTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>

@interface DTieDetailTextTableViewCell ()

@property (nonatomic, strong) UILabel * detailLabel;

@property (nonatomic, strong) UIImageView * fugaiImageView;

@end

@implementation DTieDetailTextTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createDetailTextCell];
    }
    return self;
}

- (void)createDetailTextCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.detailLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.detailLabel.numberOfLines = 0;
    [self.contentView addSubview:self.detailLabel];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.bottom.mas_equalTo(-20 * scale);
    }];
    
//    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    self.effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
//    self.effectView.alpha = .98f;
//    [self.contentView addSubview:self.effectView];
//    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(0);
//    }];
    
    self.fugaiImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.fugaiImageView setImage:[UIImage imageNamed:@"hengBG"]];
    [self.contentView addSubview:self.fugaiImageView];
    [self.fugaiImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.fugaiImageView.hidden = YES;
}

- (void)configWithCanSee:(BOOL)cansee
{
    if (cansee) {
        self.fugaiImageView.hidden = NO;
    }else{
        self.fugaiImageView.hidden = YES;
    }
}

- (void)configWithModel:(DTieEditModel *)model
{
    self.detailLabel.text = model.detailContent;
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
