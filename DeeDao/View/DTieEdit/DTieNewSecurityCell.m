//
//  DTieNewSecurityCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/1.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieNewSecurityCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>

@interface DTieNewSecurityCell ()

@property (nonatomic, strong) SecurityGroupModel * model;
@property (nonatomic, strong) UIButton * nameButton;
@property (nonatomic, strong) UIButton * notificationButton;

@end

@implementation DTieNewSecurityCell

- (void)configWithModel:(SecurityGroupModel *)model
{
    self.model = model;
    
    [self.nameButton setTitle:model.securitygroupName forState:UIControlStateNormal];
    if (model.isChoose) {
        [self.nameButton setImage:[UIImage imageNamed:@"chooseyes"] forState:UIControlStateNormal];
        
        if (model.isNotification) {
            [self.notificationButton setImage:[UIImage imageNamed:@"chooseyes"] forState:UIControlStateNormal];
        }else{
            [self.notificationButton setImage:[UIImage imageNamed:@"chooseno"] forState:UIControlStateNormal];
        }
        
    }else{
        [self.nameButton setImage:[UIImage imageNamed:@"chooseno"] forState:UIControlStateNormal];
        [self.notificationButton setImage:[UIImage imageNamed:@"chooseno"] forState:UIControlStateNormal];
    }
}

- (void)nameButtonDidClicked
{
    self.model.isChoose = !self.model.isChoose;
    if (self.model.isChoose) {
        [self.nameButton setImage:[UIImage imageNamed:@"chooseyes"] forState:UIControlStateNormal];
    }else{
        [self.nameButton setImage:[UIImage imageNamed:@"chooseno"] forState:UIControlStateNormal];
//        self.model.isNotification = NO;
//        [self.notificationButton setImage:[UIImage imageNamed:@"chooseno"] forState:UIControlStateNormal];
    }
}

- (void)notificationButtonDidClicked
{
    if (self.model.isChoose) {
        self.model.isNotification = !self.model.isNotification;
        if (self.model.isNotification) {
            [self.notificationButton setImage:[UIImage imageNamed:@"chooseyes"] forState:UIControlStateNormal];
        }else{
            [self.notificationButton setImage:[UIImage imageNamed:@"chooseno"] forState:UIControlStateNormal];
        }
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createEditSecurityCell];
    }
    return self;
}

- (void)createEditSecurityCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.nameButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0x666666) title:@""];
    [self.contentView addSubview:self.nameButton];
    [self.nameButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(180 * scale);
        make.top.bottom.mas_equalTo(0);
        make.width.mas_lessThanOrEqualTo(320 * scale);
    }];
    [self.nameButton addTarget:self action:@selector(nameButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
//    self.notificationButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0x666666) title:@"推送给Ta们"];
//    [self.contentView addSubview:self.notificationButton];
//    [self.notificationButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(520 * scale);
//        make.top.bottom.mas_equalTo(0);
//        make.width.mas_lessThanOrEqualTo(330 * scale);
//    }];
//    [self.notificationButton addTarget:self action:@selector(notificationButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
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
