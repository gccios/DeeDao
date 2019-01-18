//
//  DDManagerTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/14.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDManagerTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import "UIView+LayerCurve.h"
#import <UIImageView+WebCache.h>
#import "SuperManagerRequest.h"

@interface DDManagerTableViewCell ()

@property (nonatomic, strong) UserModel * model;

@property (nonatomic, strong) UIImageView * logoImageview;
@property (nonatomic, strong) UILabel * nameLabel;

@property (nonatomic, strong) UILabel * stateLabel;
@property (nonatomic, strong) UISwitch * managerSwitch;

@end

@implementation DDManagerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createManagerCell];
    }
    return self;
}

- (void)configWithModel:(UserModel *)model
{
    self.model = model;
    
    [self.logoImageview sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    self.nameLabel.text = model.nickname;
    
    if (isEmptyString(model.signature)) {
        self.managerSwitch.on = NO;
        self.stateLabel.text = @"状态正常";
    }else{
        if ([model.signature isEqualToString:@"F"]) {
            self.managerSwitch.on = YES;
            self.stateLabel.text = @"已被冻结";
        }else{
            self.managerSwitch.on = NO;
            self.stateLabel.text = @"状态正常";
        }
    }
}

- (void)createManagerCell
{
    CGFloat scale = kMainBoundsWidth / 360.f;
    
    self.contentView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView * logoView = [[UIView alloc] initWithFrame:CGRectZero];
    logoView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    logoView.layer.shadowColor = [UIColor colorWithRed:245/255.0 green:166/255.0 blue:35/255.0 alpha:1.0].CGColor;
    logoView.layer.shadowOffset = CGSizeMake(0,2);
    logoView.layer.shadowOpacity = 1;
    logoView.layer.shadowRadius = 4;
    logoView.layer.cornerRadius = 18 * scale;
    [self.contentView addSubview:logoView];
    [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(20 * scale);
        make.width.height.mas_equalTo(36 * scale);
    }];
    
    self.logoImageview = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [logoView addSubview:self.logoImageview];
    [self.logoImageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:18 * scale withView:self.logoImageview];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(16 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(self.logoImageview.mas_right).offset(15 * scale);
        make.height.mas_equalTo(25 * scale);
        make.right.mas_equalTo(-120 * scale);
    }];
    
    self.managerSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.managerSwitch.onTintColor = UIColorFromRGB(0xDB6283);
    self.managerSwitch.on = NO;
    [self.managerSwitch addTarget:self action:@selector(switcDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.managerSwitch];
    [self.managerSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-20 * scale);
        make.width.mas_equalTo(51 * scale);
        make.height.mas_equalTo(31 * scale);
    }];
    
    self.stateLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    self.stateLabel.text = @"状态正常";
    [self.contentView addSubview:self.stateLabel];
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(self.managerSwitch.mas_left).offset(-15 * scale);
        make.height.mas_equalTo(20 * scale);
    }];
}

- (void)switcDidChange:(UISwitch *)sender
{
    if (sender == self.managerSwitch) {
        
        if (sender.isOn) {
            self.stateLabel.text = @"已被冻结";
        }else{
            self.stateLabel.text = @"状态正常";
        }
        
        SuperManagerRequest * request = [[SuperManagerRequest alloc] initFreezeUser:self.model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
        }];
        
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
