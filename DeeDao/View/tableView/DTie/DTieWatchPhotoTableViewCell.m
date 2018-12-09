//
//  DTieWatchPhotoTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/10/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieWatchPhotoTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "UserManager.h"

@interface DTieWatchPhotoTableViewCell ()

@property (nonatomic, strong) UIView * firstBaseView;
@property (nonatomic, strong) UIView * secondBaseView;
@property (nonatomic, strong) UIView * thirdBaseView;

@property (nonatomic, strong) UIImageView * firstImageView;
@property (nonatomic, strong) UIImageView * secondImageView;
@property (nonatomic, strong) UIImageView * thirdImageView;

@property (nonatomic, strong) UIView * firstSelectView;
@property (nonatomic, strong) UIView * secondSelectView;
@property (nonatomic, strong) UIView * thirdSelectView;

@property (nonatomic, strong) DTieEditModel * firstModel;
@property (nonatomic, strong) DTieEditModel * secondModel;
@property (nonatomic, strong) DTieEditModel * thirdModel;

@end

@implementation DTieWatchPhotoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createWatchPhotoCell];
    }
    return self;
}

- (void)resetStatus
{
    self.firstBaseView.hidden = YES;
    self.secondBaseView.hidden = YES;
    self.thirdBaseView.hidden = YES;
}

- (void)configWithModel:(DTieEditModel *)model index:(NSInteger)index
{
    if (isEmptyString(model.detailContent)) {
        model.detailContent = model.detailsContent;
    }
    
    if (index == 0) {
        self.firstModel = model;
        self.firstBaseView.hidden = NO;
        [self.firstImageView sd_setImageWithURL:[NSURL URLWithString:model.detailsContent]];
        self.firstSelectView.hidden = !model.isChoose;
    }else if (index == 1) {
        self.secondModel = model;
        self.secondBaseView.hidden = NO;
        [self.secondImageView sd_setImageWithURL:[NSURL URLWithString:model.detailsContent]];
        self.secondSelectView.hidden = !model.isChoose;
    }else if (index == 2) {
        self.thirdModel = model;
        self.thirdBaseView.hidden = NO;
        [self.thirdImageView sd_setImageWithURL:[NSURL URLWithString:model.detailsContent]];
        self.thirdSelectView.hidden = !model.isChoose;
    }
}

- (void)imageDidTap:(UITapGestureRecognizer *)tap
{
    if (tap.view == self.firstBaseView) {
        
        if (self.WYYSelectType == 1) {
            if (!self.isAuthor) {
                if (self.firstModel.authorID != [UserManager shareManager].user.cid) {
                    return;
                }
            }
        }
        
        if (self.WYYSelectType == 2) {
            self.firstSelectView.hidden = NO;
        }else if (self.WYYSelectType > 0) {
            self.firstModel.isChoose = !self.firstModel.isChoose;
            self.firstSelectView.hidden = !self.firstModel.isChoose;
        }
        if (self.imageDidClicked) {
            self.imageDidClicked(self.firstModel);
        }
    }else if (tap.view == self.secondBaseView) {
        
        if (self.WYYSelectType == 1) {
            if (!self.isAuthor) {
                if (self.secondModel.authorID != [UserManager shareManager].user.cid) {
                    return;
                }
            }
        }
        
        if (self.WYYSelectType == 2) {
            self.secondSelectView.hidden = NO;
        }else if (self.WYYSelectType > 0) {
            self.secondModel.isChoose = !self.secondModel.isChoose;
            self.secondSelectView.hidden = !self.secondModel.isChoose;
        }
        if (self.imageDidClicked) {
            self.imageDidClicked(self.secondModel);
        }
    }else if (tap.view == self.thirdBaseView) {
        
        if (self.WYYSelectType == 1) {
            if (!self.isAuthor) {
                if (self.thirdModel.authorID != [UserManager shareManager].user.cid) {
                    return;
                }
            }
        }
        
        if (self.WYYSelectType == 2) {
            self.thirdSelectView.hidden = NO;
        }else if (self.WYYSelectType > 0) {
            self.thirdModel.isChoose = !self.thirdModel.isChoose;
            self.thirdSelectView.hidden = !self.thirdModel.isChoose;
        }
        if (self.imageDidClicked) {
            self.imageDidClicked(self.thirdModel);
        }
    }
}

- (void)createWatchPhotoCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = UIColorFromRGB(0xffffff);
    
    CGFloat width = (kMainBoundsWidth - 60 * scale * 4) / 3.f;
    
    self.firstBaseView = [[UIView alloc] initWithFrame:CGRectZero];
    self.firstBaseView.layer.cornerRadius = 24 * scale;
    self.firstBaseView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    self.firstBaseView.layer.shadowOpacity = .3f;
    self.firstBaseView.layer.shadowRadius = 8 * scale;
    self.firstBaseView.layer.shadowOffset = CGSizeMake(0, 4 * scale);
    [self.contentView addSubview:self.firstBaseView];
    [self.firstBaseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(60 * scale);
        make.width.height.mas_equalTo(width);
    }];
    UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidTap:)];
    [self.firstBaseView addGestureRecognizer:tap1];
    
    self.firstImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [self.firstBaseView addSubview:self.firstImageView];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.firstImageView];
    [self.firstImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.firstSelectView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.firstBaseView addSubview:self.firstSelectView];
    [self.firstSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.firstSelectView.backgroundColor = [UIColorFromRGB(0xDB6283) colorWithAlphaComponent:.3f];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.firstSelectView];
    self.firstSelectView.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.firstSelectView.layer.borderWidth = 6 * scale;
    self.firstSelectView.hidden = YES;
    
    self.secondBaseView = [[UIView alloc] initWithFrame:CGRectZero];
    self.secondBaseView.layer.cornerRadius = 24 * scale;
    self.secondBaseView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    self.secondBaseView.layer.shadowOpacity = .3f;
    self.secondBaseView.layer.shadowRadius = 8 * scale;
    self.secondBaseView.layer.shadowOffset = CGSizeMake(0, 4 * scale);
    [self.contentView addSubview:self.secondBaseView];
    [self.secondBaseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(self.firstBaseView.mas_right).offset(60 * scale);
        make.width.height.mas_equalTo(width);
    }];
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidTap:)];
    [self.secondBaseView addGestureRecognizer:tap2];
    
    self.secondImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [self.secondBaseView addSubview:self.secondImageView];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.secondImageView];
    [self.secondImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.secondSelectView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.secondBaseView addSubview:self.secondSelectView];
    [self.secondSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.secondSelectView.backgroundColor = [UIColorFromRGB(0xDB6283) colorWithAlphaComponent:.3f];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.secondSelectView];
    self.secondSelectView.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.secondSelectView.layer.borderWidth = 6 * scale;
    self.secondSelectView.hidden = YES;
    
    self.thirdBaseView = [[UIView alloc] initWithFrame:CGRectZero];
    self.thirdBaseView.layer.cornerRadius = 24 * scale;
    self.thirdBaseView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    self.thirdBaseView.layer.shadowOpacity = .3f;
    self.thirdBaseView.layer.shadowRadius = 8 * scale;
    self.thirdBaseView.layer.shadowOffset = CGSizeMake(0, 4 * scale);
    [self.contentView addSubview:self.thirdBaseView];
    [self.thirdBaseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(self.secondBaseView.mas_right).offset(60 * scale);
        make.width.height.mas_equalTo(width);
    }];
    UITapGestureRecognizer * tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageDidTap:)];
    [self.thirdBaseView addGestureRecognizer:tap3];
    
    self.thirdImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [self.thirdBaseView addSubview:self.thirdImageView];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.thirdImageView];
    [self.thirdImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.thirdSelectView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.thirdBaseView addSubview:self.thirdSelectView];
    [self.thirdSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.thirdSelectView.backgroundColor = [UIColorFromRGB(0xDB6283) colorWithAlphaComponent:.3f];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.thirdSelectView];
    self.thirdSelectView.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.thirdSelectView.layer.borderWidth = 6 * scale;
    self.thirdSelectView.hidden = YES;
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
