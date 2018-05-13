//
//  DTieEditTextTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/11.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieEditTextTableViewCell.h"
#import <Masonry.h>
#import "DDViewFactoryTool.h"

@interface DTieEditTextTableViewCell ()

@property (nonatomic, strong) RDTextView * textView;
@property (nonatomic, strong) DTieEditModel * model;

@property (nonatomic, strong) UIButton * seeButton;

@end

@implementation DTieEditTextTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createEditCell];
    }
    return self;
}

- (void)createEditCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    self.textView = [[RDTextView alloc] initWithFrame:CGRectZero];
    self.textView.maxSize = MAXFLOAT;
    self.textView.userInteractionEnabled = NO;
    self.textView.scrollEnabled = NO;
    self.textView.font = kPingFangRegular(42 * scale);
    [self.contentView addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(30 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.bottom.mas_equalTo(-170 * scale);
    }];
    
    UIView * lineView = [[UIView alloc] init];
    lineView.backgroundColor = UIColorFromRGB(0x000000);
    lineView.alpha = .12;
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textView.mas_bottom).offset(40 * scale);
        make.left.mas_equalTo(self.textView);
        make.right.mas_equalTo(self.textView);
        make.height.mas_equalTo(2 * scale);
    }];
    
    self.seeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"设置到地可见"];
    [self.seeButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.contentView addSubview:self.seeButton];
    [self.seeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lineView.mas_bottom).offset(20 * scale);
        make.bottom.mas_equalTo(-40 * scale);
        make.right.mas_equalTo(-30 * scale);
        make.width.mas_equalTo(350 * scale);
    }];
}

- (void)configWithEditModel:(DTieEditModel *)model
{
    if (model.type == DTieEditType_Text) {
        self.textView.placeholder = @"说点让你感到不同或惊艳的...";
        if (isEmptyString(model.text)) {
            self.textView.text = @"";
        }else{
            self.textView.text = model.text;
        }
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
