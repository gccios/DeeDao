//
//  MineEditTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/10.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "MineEditTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry/Masonry.h>

@interface MineEditTableViewCell ()

@property (nonatomic, strong) UILabel * nameLabel;

@end

@implementation MineEditTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self createEditCell];
        
    }
    return self;
}

- (void)createEditCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(60 * scale);
    }];
    
    self.textField = [[DDEditTextField alloc] initWithFrame:CGRectZero];
    self.textField.textAlignment = NSTextAlignmentRight;
    self.textField.textColor = UIColorFromRGB(0x666666);
    self.textField.font = kPingFangRegular(42 * scale);
    [self.contentView addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_right).offset(25 * scale);
        make.right.mas_equalTo(-55 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(50 * scale);
    }];
}

- (void)configWithType:(EditMineType)type indexPath:(NSIndexPath *)indexPath
{
    self.textField.indexPath = indexPath;
    
    switch (type) {
        case EditMineType_Name:
            
        {
            self.nameLabel.text = @"姓名";
            self.textField.placeholder = @"请输入您的姓名";
        }
            
            break;
            
        case EditMineType_Sex:
            
        {
            self.nameLabel.text = @"性别";
            self.textField.placeholder = @"请输入您的性别";
        }
            
            break;
            
        case EditMineType_Detail:
            
        {
            self.nameLabel.text = @"签名";
            self.textField.placeholder = @"请输入您的个性签名";
        }
            
            break;
            
        case EditMineType_TelNumber:
            
        {
            self.nameLabel.text = @"手机";
            self.textField.placeholder = @"请输入您的手机号";
        }
            
            break;
            
        case EditMineType_Birthday:
            
        {
            self.nameLabel.text = @"生日";
            self.textField.placeholder = @"请输入您的公历生日";
        }
            
            break;
            
        case EditMineType_Address:
            
        {
            self.nameLabel.text = @"地址";
            self.textField.placeholder = @"请输入您的实际地址";
            self.textField.indexPath = indexPath;
        }
            
            break;
            
        case EditMineType_EMail:
            
        {
            self.nameLabel.text = @"邮箱";
            self.textField.placeholder = @"请输入您的邮箱地址";
            self.textField.indexPath = indexPath;
        }
            
            break;
            
        default:
            break;
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
