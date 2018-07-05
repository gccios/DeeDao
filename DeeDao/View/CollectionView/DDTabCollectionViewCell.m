

//
//  DDTabCollectionViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/11.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDTabCollectionViewCell.h"
#import <Masonry.h>

@interface DDTabCollectionViewCell ()

@property (nonatomic, strong) UILabel * tagLabel;

@end

@implementation DDTabCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createTabCell];
    }
    return self;
}

- (void)createTabCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.tagLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.tagLabel.textAlignment = NSTextAlignmentCenter;
    self.tagLabel.font = kPingFangRegular(42 * scale);
    [self.contentView addSubview:self.tagLabel];
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)configWithTagTitle:(NSString *)title
{
    self.tagLabel.text = title;
}

- (void)configWithSelectStatus:(BOOL)select
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    if (select) {
        self.tagLabel.font = kPingFangRegular(46 * scale);
        self.tagLabel.textColor = UIColorFromRGB(0xDB6283);
    }else{
        self.tagLabel.font = kPingFangRegular(42 * scale);
        self.tagLabel.textColor = [UIColor blackColor];
    }
}

@end
