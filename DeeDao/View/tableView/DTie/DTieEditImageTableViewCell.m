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
#import <UIImageView+WebCache.h>

@interface DTieEditImageTableViewCell ()

@property (nonatomic, strong) UIImageView * tieImageView;

@property (nonatomic, strong) UIButton * seeButton;

@property (nonatomic, strong) DTieEditModel * model;

@property (nonatomic, strong) UIButton * addButton;
@property (nonatomic, strong) UILabel * addLabel;

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
    
    self.tieImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFit image:[DDViewFactoryTool imageWithColor:UIColorFromRGB(0xEFEFF4) size:CGSizeMake(1080 * scale, 720 * scale)]];
    [self.contentView addSubview:self.tieImageView];
    self.tieImageView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.tieImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(0);
        make.width.mas_equalTo(kMainBoundsWidth);
        make.bottom.mas_equalTo(-170 * scale);
    }];
    
    self.addButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(60 * scale, 60 * scale, 960 * scale, 600 * scale) font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@""];
    self.addButton.userInteractionEnabled = NO;
    [self.tieImageView addSubview:self.addButton];
    [DDViewFactoryTool addBorderToLayer:self.addButton];
    
    UIImageView * addImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"DTieAdd"]];
    [self.addButton addSubview:addImageView];
    [addImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(180 * scale);
        make.width.height.mas_equalTo(72 * scale);
    }];
    
    self.addLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentCenter];
    [self.addButton addSubview:self.addLabel];
    [self.addLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(310 * scale);
        make.height.mas_equalTo(45 * scale);
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
        self.addButton.hidden = YES;
        [self.tieImageView setImage:model.image];
    }else if (!isEmptyString(model.detailContent)){
        self.addButton.hidden = YES;
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:model.detailContent];
        
        // 没有找到已下载的图片就使用默认的占位图，当然高度也是默认的高度了，除了高度不固定的文字部分。
        if (!image) {
            image = [UIImage imageNamed:@"test"];
        }
        [self.tieImageView setImage:image];
    }else{
        self.addButton.hidden = NO;
    }
    
    if (self.model.pFlag) {
        [self.seeButton setImage:[UIImage imageNamed:@"qx"] forState:UIControlStateNormal];
    }else{
        [self.seeButton setImage:[UIImage imageNamed:@"qxno"] forState:UIControlStateNormal];
    }
    
    if (self.model.type == DTieEditType_Image) {
        self.addLabel.text = @"添加图片";
    }else if (self.model.type == DTieEditType_Video){
        self.addLabel.text = @"添加视频";
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
