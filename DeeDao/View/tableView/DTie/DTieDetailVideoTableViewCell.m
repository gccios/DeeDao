//
//  DTieDetailVideoTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/17.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieDetailVideoTableViewCell.h"
#import "DDTool.h"
#import <UIImageView+WebCache.h>
#import <Masonry.h>

@interface DTieDetailVideoTableViewCell ()

@property (nonatomic, strong) UIImageView * detailImageView;

@end

@implementation DTieDetailVideoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createDetailVideoCell];
    }
    return self;
}

- (void)createDetailVideoCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.detailImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)configWithModel:(DTieEditModel *)model
{
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:model.detailContent];
    
    if (image) {
        [self.detailImageView setImage:image];
    }else{
        [self.detailImageView setImage:[UIImage imageNamed:@"test"]];
    }
}

- (void)yulanWithModel:(DTieEditModel *)model
{
    if (model.image) {
        [self.detailImageView setImage:model.image];
    }else{
        [self.detailImageView setImage:[UIImage imageNamed:@"test"]];
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
