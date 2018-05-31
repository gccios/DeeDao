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
@property (nonatomic, strong) UIImageView * playImageView;;

@property (nonatomic, strong) UIImageView * fugaiImageView;

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
    self.detailImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.detailImageView];
    [self.detailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    self.playImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.playImageView setImage:[UIImage imageNamed:@"player"]];
    [self.contentView addSubview:self.playImageView];
    [self.playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(150 * scale);
    }];
    
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
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:model.detailContent];
    
    if (image) {
        [self.detailImageView setImage:image];
    }else{
        [self.detailImageView setImage:[UIImage imageNamed:@"hengBG"]];
    }
}

- (void)yulanWithModel:(DTieEditModel *)model
{
    if (model.image) {
        [self.detailImageView setImage:model.image];
    }else{
        [self.detailImageView setImage:[UIImage imageNamed:@"hengBG"]];
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
