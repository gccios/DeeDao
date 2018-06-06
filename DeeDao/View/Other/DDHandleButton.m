//
//  DDHandleButton.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/18.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDHandleButton.h"
#import <Masonry.h>

@interface DDHandleButton ()

@end

@implementation DDHandleButton

- (void)configImage:(UIImage *)image
{
    [self.handleImageView setImage:image];
}

- (void)configTitle:(NSString *)title
{
    self.handleLabel.text = title;
}

- (UIImageView *)handleImageView
{
    if (!_handleImageView) {
        _handleImageView = [[UIImageView alloc] init];
        _handleImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_handleImageView];
        [_handleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(self.mas_width).multipliedBy(.6f);
            make.height.mas_equalTo(self.mas_width).multipliedBy(.6f);
        }];
    }
    return _handleImageView;
}

- (UILabel *)handleLabel
{
    if (!_handleLabel) {
        CGFloat scale = kMainBoundsWidth / 1080.f;
        _handleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _handleLabel.textColor = UIColorFromRGB(0x999999);
        _handleLabel.font = kPingFangRegular(36 * scale);
        _handleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_handleLabel];
        [_handleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(40 * scale);
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
    }
    return _handleLabel;
}

@end
