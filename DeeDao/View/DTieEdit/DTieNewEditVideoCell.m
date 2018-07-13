//
//  DTieNewEditVideoCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/31.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieNewEditVideoCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import <WXApi.h>

@interface DTieNewEditVideoCell()

@property (nonatomic, strong) UIImageView * logoImageView;

@property (nonatomic, assign) BOOL shareEnbale;
@property (nonatomic, strong) UIButton * shareButton;
@property (nonatomic, strong) UILabel * shareLabel;
@property (nonatomic, strong) UIImageView * shareImageView;

@property (nonatomic, assign) BOOL deedaoEnbale;
@property (nonatomic, strong) UIButton * deedaoButton;
@property (nonatomic, strong) UILabel * deedaoLabel;
@property (nonatomic, strong) UIImageView * deedaoImageView;

@end

@implementation DTieNewEditVideoCell

- (void)configWithModel:(DTieEditModel *)model
{
    self.model = model;
    if (model.image) {
        [self.logoImageView setImage:model.image];
    }else if (!isEmptyString(model.detailContent)){
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:model.detailContent];
        
        // 没有找到已下载的图片就使用默认的占位图，当然高度也是默认的高度了，除了高度不固定的文字部分。
        if (!image) {
            image = [UIImage new];
        }
        
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:model.detailContent] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            [[SDImageCache sharedImageCache] storeImage:image forKey:model.detailContent toDisk:YES completion:nil];
            model.image = image;
            [self.logoImageView setImage:image];
        }];
        
        [self.logoImageView setImage:image];
    }
    
    if (self.model.pFlag == 1) {
        self.deedaoEnbale = YES;
        [self.deedaoImageView setImage:[UIImage imageNamed:@"chooseyes"]];
    }else{
        self.deedaoEnbale = NO;
        [self.deedaoImageView setImage:[UIImage imageNamed:@"chooseno"]];
    }
    
    if (self.model.shareEnable) {
        self.shareEnbale = YES;
        [self.shareImageView setImage:[UIImage imageNamed:@"chooseyes"]];
    }else{
        self.deedaoEnbale = NO;
        [self.shareImageView setImage:[UIImage imageNamed:@"chooseno"]];
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createNewEditImageCell];
    }
    return self;
}

- (void)createNewEditImageCell
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
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [baseView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(360 * scale);
        make.height.mas_equalTo(216 * scale);
    }];
    self.logoImageView.clipsToBounds = YES;
    self.logoImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(preViewDidHandle)];
    [self.logoImageView addGestureRecognizer:tap];
    
    UIImageView * playImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [playImageView setImage:[UIImage imageNamed:@"player"]];
    [self.logoImageView addSubview:playImageView];
    [playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    self.deedaoButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0x333333) title:@""];
    [baseView addSubview:self.deedaoButton];
    [self.deedaoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(240 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    
    self.deedaoLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    self.deedaoLabel.text = @"到地体验";
    [self.deedaoButton addSubview:self.deedaoLabel];
    [self.deedaoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.height.mas_equalTo(60 * scale);
    }];
    
    self.deedaoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"chooseno"]];
    [self.deedaoButton addSubview:self.deedaoImageView];
    [self.deedaoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(self.deedaoLabel.mas_right).offset(5 * scale);
        make.width.height.mas_equalTo(60 * scale);
    }];
    
    self.shareButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0x333333) title:@""];
    [baseView addSubview:self.shareButton];
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.deedaoButton.mas_left).offset(-54 * scale);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(240 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    
    if (![WXApi isWXAppInstalled]) {
        self.shareButton.hidden = YES;
    }
    
    self.shareLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    self.shareLabel.text = @"微信可见";
    [self.shareButton addSubview:self.shareLabel];
    [self.shareLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.height.mas_equalTo(60 * scale);
    }];
    
    self.shareImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"chooseno"]];
    [self.shareButton addSubview:self.shareImageView];
    [self.shareImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(self.shareLabel.mas_right).offset(5 * scale);
        make.width.height.mas_equalTo(60 * scale);
    }];
    
//    UIButton * alertButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [alertButton setImage:[UIImage imageNamed:@"alertEdit"] forState:UIControlStateNormal];
//    [baseView addSubview:alertButton];
//    [alertButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(14 * scale);
//        make.right.mas_equalTo(-30 * scale);
//        make.width.height.mas_equalTo(72 * scale);
//    }];
    
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addButton setImage:[UIImage imageNamed:@"addEdit"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.addButton];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(baseView.mas_bottom).offset(24 * scale);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(72 * scale);
    }];
    [self.addButton addTarget:self action:@selector(addButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.deedaoButton addTarget:self action:@selector(deedaoButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton addTarget:self action:@selector(shareButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)deedaoButtonDidClicked
{
    if (self.model.pFlag == 0) {
        self.model.pFlag = 1;
        [self.deedaoImageView setImage:[UIImage imageNamed:@"chooseyes"]];
    }else{
        self.model.pFlag = 0;
        [self.deedaoImageView setImage:[UIImage imageNamed:@"chooseno"]];
    }
}

- (void)shareButtonDidClicked
{
    if (self.model.shareEnable == 0) {
        self.model.shareEnable = 1;
    }else{
        self.model.shareEnable = 0;
    }
    
    if (self.model.shareEnable == 1) {
        [self.shareImageView setImage:[UIImage imageNamed:@"chooseyes"]];
    }else{
        [self.shareImageView setImage:[UIImage imageNamed:@"chooseno"]];
    }
}
- (void)addButtonDidClicked
{
    if (self.addButtonHandle) {
        self.addButtonHandle();
    }
}

- (void)preViewDidHandle
{
    if (self.preViewHandle) {
        self.preViewHandle();
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
