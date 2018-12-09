//
//  FanjuTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/28.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "FanjuTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "DDTool.h"

@interface FanjuTableViewCell ()

@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, strong) UIImageView * postImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * poiLabel;
@property (nonatomic, strong) UILabel * statusLabel;
@property (nonatomic, strong) UILabel * postTitleLabel;

@property (nonatomic, strong) UILabel * alertLabel;

@property (nonatomic, strong) UILabel * infoLabel;

@end

@implementation FanjuTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createFanjuCell];
    }
    return self;
}

- (void)configWithModel:(DTieModel *)model
{
    self.model = model;
    [self.postImageView sd_setImageWithURL:[NSURL URLWithString:model.postFirstPicture]];
    self.postTitleLabel.text = model.postSummary;
    
    NSString * build = model.sceneBuilding;
    if (isEmptyString(build)) {
        build = @"";
    }
    
    self.infoLabel.text = [NSString stringWithFormat:@"%@ %@ %@", [DDTool getTimeWithFormat:@"yyyy年MM月dd日" time:model.sceneTime], [self dateWeekString], [DDTool getTimeWithFormat:@"HH:mm" time:model.sceneTime]];
    self.nameLabel.text = model.nickname;
    self.poiLabel.text = model.sceneBuilding;
    
    if (self.model.subType == 1) {
        self.statusLabel.text = DDLocalizedString(@"Attend");
    }else{
        if (self.model.subType == 0) {
            self.statusLabel.text = DDLocalizedString(@"TBD");
        }else if (self.model.subType == 2) {
            self.statusLabel.text = DDLocalizedString(@"OutFollow");
        }
    }
    
    NSInteger currentTime = [[NSDate date] timeIntervalSince1970];
    NSInteger time = self.model.sceneTime / 1000;
    NSInteger distance = time - currentTime;
    NSInteger maxDistance = 48 * 60 * 60;
    if (distance > 0 && distance <= maxDistance) {
        self.alertLabel.hidden = NO;
    }else{
        self.alertLabel.hidden = YES;
    }
}

- (void)createFanjuCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.infoLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(38 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.infoLabel];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    self.alertLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangMedium(38 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentRight];
    self.alertLabel.text = @"48小时内";
    [self.contentView addSubview:self.alertLabel];
    [self.alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40 * scale);
        make.left.mas_equalTo(self.infoLabel.mas_right).offset(30 * scale);
        make.height.mas_equalTo(50 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    self.alertLabel.hidden = YES;
    
    UIView * BGView = [[UIView alloc] initWithFrame:CGRectZero];
    BGView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:BGView];
    BGView.layer.cornerRadius = 24 * scale;
    BGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    BGView.layer.shadowOpacity = .3f;
    BGView.layer.shadowRadius = 8 * scale;
    BGView.layer.shadowOffset = CGSizeMake(0, 8 * scale);
    [BGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(140 * scale);
        make.left.mas_equalTo(60 * scale);
        make.width.height.mas_equalTo(240 * scale);
    }];
    
    self.postImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [BGView addSubview:self.postImageView];
    [self.postImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.postImageView];

    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangMedium(48 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(BGView.mas_right).offset(25 * scale);
        make.top.mas_equalTo(BGView);
        make.right.mas_equalTo(-30 * scale);
    }];
    
    self.poiLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.poiLabel];
    [self.poiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(0 * scale);
        make.left.mas_equalTo(self.nameLabel);
        make.right.mas_equalTo(self.nameLabel);
    }];
    
    self.postTitleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.postTitleLabel];
    [self.postTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.poiLabel.mas_bottom).offset(-5 * scale);
        make.left.mas_equalTo(self.poiLabel);
        make.right.mas_equalTo(self.poiLabel);
    }];
    
    self.statusLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.statusLabel];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.postTitleLabel.mas_bottom).offset(0 * scale);
        make.left.mas_equalTo(self.postTitleLabel);
        make.right.mas_equalTo(self.postTitleLabel);
    }];
    
    UIButton * leftButton = [DDViewFactoryTool createButtonWithFrame: CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"导航/拷贝POI"];
    [self.contentView addSubview:leftButton];
    [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(-kMainBoundsWidth / 4.f);
        make.width.mas_equalTo(444 * scale);
        make.height.mas_equalTo(120 * scale);
        make.top.mas_equalTo(self.postImageView.mas_bottom).offset(60 * scale);
    }];
    [DDViewFactoryTool cornerRadius:60 * scale withView:leftButton];
    leftButton.layer.borderWidth = 3 * scale;
    leftButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    [leftButton addTarget:self action:@selector(leftButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * rightButton = [DDViewFactoryTool createButtonWithFrame: CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"一键加照片"];
    [self.contentView addSubview:rightButton];
    [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(kMainBoundsWidth / 4.f);
        make.width.mas_equalTo(444 * scale);
        make.height.mas_equalTo(120 * scale);
        make.top.mas_equalTo(self.postImageView.mas_bottom).offset(60 * scale);
    }];
    [DDViewFactoryTool cornerRadius:60 * scale withView:rightButton];
    rightButton.layer.borderWidth = 3 * scale;
    rightButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    [rightButton addTarget:self action:@selector(rightButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xf5f5f5);
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(20 * scale);
    }];
}

- (void)leftButtonDidClicked
{
    if (self.leftButtonHandle) {
        self.leftButtonHandle();
    }
}

- (void)rightButtonDidClicked
{
    if (self.rightButtonHandle) {
        self.rightButtonHandle();
    }
}


- (NSString *)dateWeekString
{
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:self.model.sceneTime/1000];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents =
    [gregorian components:NSCalendarUnitWeekday fromDate:date];
    NSInteger _weekday = [weekdayComponents weekday];
    NSString *weekStr;
    if (_weekday == 1) {
        weekStr = @"星期日";
    }else if (_weekday == 2){
        weekStr = @"星期一";
    }else if (_weekday == 3){
        weekStr = @"星期二";
    }else if (_weekday == 4){
        weekStr = @"星期三";
    }else if (_weekday == 5){
        weekStr = @"星期四";
    }else if (_weekday == 6){
        weekStr = @"星期五";
    }else if (_weekday == 7){
        weekStr = @"星期六";
    }
    return weekStr;
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
