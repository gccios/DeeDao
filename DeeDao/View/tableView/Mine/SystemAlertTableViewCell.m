
//
//  SystemAlertTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/19.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "SystemAlertTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>

@interface SystemAlertTableViewCell ()

@property (nonatomic, strong) SettingModel * model;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UISwitch * settingSwitch;

@end

@implementation SystemAlertTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createSystemAlertCell];
    }
    return self;
}

- (void)createSystemAlertCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentLeft];
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
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xE0E0E0);
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(3 * scale);
    }];
}

- (void)switcDidChange:(UISwitch *)settingSwitch
{
    DDUserDefaultsSet(self.model.systemKey, @(settingSwitch.isOn));
    [DDUserDefaults synchronize];
    
    NSLog(@"%@", self.model.title);
}

- (void)configWithModel:(SettingModel *)model
{
    self.model = model;
    
    self.nameLabel.text = model.title;
    self.settingSwitch.on = self.model.status;
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
