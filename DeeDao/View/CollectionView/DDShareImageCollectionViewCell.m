//
//  DDShareImageCollectionViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/28.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDShareImageCollectionViewCell.h"
#import <Masonry.h>

@interface DDShareImageCollectionViewCell ()

@property (nonatomic, strong) UIImageView * shareImageView;
//@property (nonatomic, strong) UIButton * cancleButton;

@property (nonatomic, strong) UILabel * numberLabel;

@end

@implementation DDShareImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createShareImageCell];
    }
    return self;
}

- (void)createShareImageCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * baseView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:baseView];
    [baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(20 * scale);
        make.bottom.right.mas_equalTo(-20 * scale);
    }];
    
    baseView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    baseView.layer.shadowOpacity = .3f;
    baseView.layer.shadowRadius = 24 * scale;
    baseView.layer.shadowOffset = CGSizeMake(0, 6 * scale);
    
    self.shareImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.shareImageView.contentMode = UIViewContentModeScaleAspectFill;
    [baseView addSubview:self.shareImageView];
    [self.shareImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.shareImageView.layer.cornerRadius = 24 * scale;
    self.shareImageView.clipsToBounds = YES;
    
//    self.cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.contentView addSubview:self.cancleButton];
//    [self.cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(0);
//        make.right.mas_equalTo(0);
//        make.width.height.mas_equalTo(82 * scale);
//    }];
//    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancleButtonDidClicked)];
//    [self.cancleButton addGestureRecognizer:self.tap];
//
//    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//    imageView.contentMode = UIViewContentModeScaleAspectFill;
//    [imageView setImage:[UIImage imageNamed:@"jianqu"]];
//    [self.cancleButton addSubview:imageView];
//    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.right.mas_equalTo(0);
//        make.width.height.mas_equalTo(72 * scale);
//    }];
    
    self.numberLabel = [[UILabel alloc] init];
    self.numberLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
    self.numberLabel.textColor = UIColorFromRGB(0xFFFFFF);
    self.numberLabel.font = kPingFangMedium(120 * scale);
    self.numberLabel.textAlignment = NSTextAlignmentCenter;
    [self.shareImageView addSubview:self.numberLabel];
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.numberLabel.hidden = YES;
}

- (void)configIndex:(NSInteger)index hidden:(BOOL)hidden
{
    if (hidden) {
        self.numberLabel.hidden = YES;
    }else{
        self.numberLabel.text = [NSString stringWithFormat:@"%ld", index];
        self.numberLabel.hidden = NO;
    }
}

- (void)cancleButtonDidClicked
{
    if (self.cancleButtonClicked) {
        self.cancleButtonClicked();
    }
}

- (void)configImageWith:(UIImage *)image isEdit:(BOOL)isEdit
{
    [self.shareImageView setImage:image];
//    self.cancleButton.hidden = !isEdit;
}

- (void)configWithImage:(UIImage *)image
{
    [self.shareImageView setImage:image];
}

- (void)configEdit:(NSNumber *)isEdit
{
//    self.cancleButton.hidden = ![isEdit boolValue];
}

@end
