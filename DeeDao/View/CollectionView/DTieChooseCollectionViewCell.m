//
//  DTieChooseCollectionViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieChooseCollectionViewCell.h"
#import <Masonry.h>

@interface DTieChooseCollectionViewCell ()

@property (nonatomic, strong) UIImageView * chooseIcon;

@end

@implementation DTieChooseCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createChooseCollectionCell];
    }
    return self;
}

- (void)configSelectStatus:(BOOL)selectStaus
{
    self.isSelect = selectStaus;
    if (selectStaus) {
        [self.chooseIcon setImage:[UIImage imageNamed:@"selectyes"]];
    }else{
        [self.chooseIcon setImage:[UIImage imageNamed:@"selectno"]];
    }
}

- (void)createChooseCollectionCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.chooseIcon = [[UIImageView alloc] init];
    [self.contentView addSubview:self.chooseIcon];
    [self.chooseIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contenImageView.mas_top).offset(-30 * scale);
        make.left.mas_equalTo(self.contenImageView.mas_right).offset(-15 * scale);
        make.width.height.mas_equalTo(60 * scale);
    }];
}

- (void)configSingle
{
    self.chooseIcon.hidden = YES;
}

@end
