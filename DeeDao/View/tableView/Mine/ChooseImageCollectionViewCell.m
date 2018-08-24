//
//  ChooseImageCollectionViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "ChooseImageCollectionViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>

@interface ChooseImageCollectionViewCell ()

@property (nonatomic, strong) UIImageView * imageView;

@end

@implementation ChooseImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self createImageCell];
        
    }
    return self;
}

- (void)configWithImageName:(NSString *)name
{
    [self.imageView setImage:[UIImage imageNamed:name]];
}

- (void)createImageCell
{
    self.imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [self.contentView addSubview:self.imageView];
    self.imageView.clipsToBounds = YES;
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

@end
