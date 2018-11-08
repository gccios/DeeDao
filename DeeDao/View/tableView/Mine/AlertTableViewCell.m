//
//  AlertTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "AlertTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>

@interface AlertTableViewCell ()

@property (nonatomic, strong) AlertModel * model;

@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * statusLabel;
@property (nonatomic, strong) UISwitch * settingSwitch;

@end

@implementation AlertTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createAlertCell];
    }
    return self;
}

- (void)configWithModel:(AlertModel *)model
{
    self.model = model;
    self.nameLabel.text = model.title;
    [self.settingSwitch setOn:model.openStatus];
    [self reloadStatusLabel];
}

- (void)reloadStatusLabel
{
    if (self.model.type < 20) {
        if (self.model.openStatus) {
            self.statusLabel.text = DDLocalizedString(@"AlertYes");
            self.statusLabel.textColor = UIColorFromRGB(0xDB6283);
        }else{
            self.statusLabel.text = DDLocalizedString(@"AlertNo");
            self.statusLabel.textColor = UIColorFromRGB(0x999999);
        }
    }else{
        if (self.model.openStatus) {
            self.statusLabel.text = DDLocalizedString(@"On");
            self.statusLabel.textColor = UIColorFromRGB(0xDB6283);
        }else{
            self.statusLabel.text = DDLocalizedString(@"Off");
            self.statusLabel.textColor = UIColorFromRGB(0x999999);
        }
    }
}

- (void)createAlertCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.top.bottom.mas_equalTo(0);
    }];
    
    self.settingSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.settingSwitch addTarget:self action:@selector(switcDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.settingSwitch];
    [self.settingSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-48 * scale);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(51);
        make.height.mas_equalTo(31);
    }];
    
    self.statusLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentRight];
    [self.contentView addSubview:self.statusLabel];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(self.settingSwitch.mas_left).offset(-30 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
}

- (void)switcDidChange:(UISwitch *)swith
{
    if (self.model.type == 21) {
        DDUserDefaultsSet(@"xiangling", [NSNumber numberWithBool:swith.isOn]);
        [DDUserDefaults synchronize];
    }else if (self.model.type == 22) {
        DDUserDefaultsSet(@"zhendong", [NSNumber numberWithBool:swith.isOn]);
        [DDUserDefaults synchronize];
    }
    
    self.model.openStatus = swith.isOn;
    [self reloadStatusLabel];
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
