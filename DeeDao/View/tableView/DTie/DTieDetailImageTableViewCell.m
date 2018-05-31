//
//  DTieDetailImageTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/17.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieDetailImageTableViewCell.h"
#import "DDTool.h"
#import <UIImageView+WebCache.h>
#import <Masonry.h>
#import "DDShareManager.h"

@interface DTieDetailImageTableViewCell ()

@property (nonatomic, strong) UIImageView * detailImageView;

@property (nonatomic, strong) UIImageView * fugaiImageView;

@end

@implementation DTieDetailImageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createDetailImageCell];
    }
    return self;
}

- (void)createDetailImageCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.detailImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.detailImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.detailImageView];
    [self.detailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDidHandle:)];
    self.detailImageView.userInteractionEnabled = YES;
    [self.detailImageView addGestureRecognizer:longPress];
    
//    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    self.effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
//    self.effectView.alpha = .98f;
//    [self.contentView addSubview:self.effectView];
//    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(0);
//    }];
    
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

- (void)longPressDidHandle:(UILongPressGestureRecognizer *)longPress
{
    [[DDShareManager shareManager] showHandleViewWithImage:self.detailImageView.image];
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
