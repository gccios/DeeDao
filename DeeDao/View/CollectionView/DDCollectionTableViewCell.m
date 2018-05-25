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

@interface DDCollectionTableViewCell ()

@property (nonatomic, strong) UIImageView * baseImageView;

@property (nonatomic, strong) UIView * firstReadView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UILabel * locationLabel;
@property (nonatomic, strong) UILabel * firstReadLabel;

@property (nonatomic, strong) UIView * baseReadView;
@property (nonatomic, strong) UILabel * readLabel;

@property (nonatomic, strong) UILabel * lastLabel;

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
    
    self.baseImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFit image:[UIImage imageNamed:@"test"]];
    [self.contentView addSubview:self.baseImageView];
    [self.baseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
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
}

- (void)configWithModel:(DTieEditModel *)model
{
    if (model.type == DTieEditType_Image || model.type == DTieEditType_Video) {
        self.firstReadView.hidden = YES;
        self.baseReadView.hidden = YES;
        self.baseImageView.hidden = NO;
        
        if (isEmptyString(model.detailContent)) {
            [self.baseImageView setImage:[UIImage imageNamed:@"test"]];
        }else{
            [self.baseImageView sd_setImageWithURL:[NSURL URLWithString:[DDTool getImageURLWithHtml:model.detailContent]]];
        }
    }else if (model.type == DTieEditType_Text){
        self.firstReadView.hidden = YES;
        self.baseReadView.hidden = NO;
        self.baseImageView.hidden = YES;
        self.readLabel.text = [DDTool getTextWithHtml:model.detailContent];
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
