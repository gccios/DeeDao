//
//  ChooseTimeView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/15.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "ChooseTimeView.h"
#import "DDViewFactoryTool.h"
#import <PGDatePicker.h>
#import <NSDate+PGCategory.h>
#import <Masonry.h>
#import "MBProgressHUD+DDHUD.h"

@interface ChooseTimeView () <PGDatePickerDelegate>

@property (nonatomic, strong) PGDatePicker * leftPicker;
@property (nonatomic, strong) PGDatePicker * rightPicker;

@property (nonatomic, assign) NSInteger minTime;
@property (nonatomic, assign) NSInteger maxTime;

@end

@implementation ChooseTimeView

- (instancetype)init
{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        [self createChooseTimeView];
    }
    return self;
}

- (void)createChooseTimeView
{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * contenView = [[UIView alloc] initWithFrame:CGRectZero];
    contenView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self addSubview:contenView];
    [contenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(940 * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    UIButton * cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleButton setTitleColor:UIColorFromRGB(0xDB6283) forState:UIControlStateNormal];
    [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    [contenView addSubview:cancleButton];
    [cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10 * scale);
        make.right.mas_equalTo(-30 * scale);
        make.width.mas_equalTo(150 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    [cancleButton addTarget:self action:@selector(cancleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * handleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:@"确定并筛选"];
    [DDViewFactoryTool cornerRadius:24 * scale withView:handleButton];
    handleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    handleButton.layer.borderWidth = 3 * scale;
    [contenView addSubview:handleButton];
    [handleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(144 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.bottom.mas_equalTo(-60 * scale);
    }];
    [handleButton addTarget:self action:@selector(handleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.leftPicker = [[PGDatePicker alloc] initWithFrame:CGRectZero];
    self.leftPicker.datePickerMode = PGDatePickerModeYearAndMonth;
    self.leftPicker.textColorOfSelectedRow = UIColorFromRGB(0xDB6283);
    self.leftPicker.lineBackgroundColor = UIColorFromRGB(0xDB6283);
    self.leftPicker.middleTextColor = UIColorFromRGB(0xDB6283);
    ///< 当前时间
    NSDate *currentdata = [NSDate date];
    
    ///< NSCalendar -- 日历类，它提供了大部分的日期计算接口，并且允许您在NSDate和NSDateComponents之间转换
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *datecomps = [[NSDateComponents alloc] init];
    [datecomps setYear:-1];
    [datecomps setMonth:0];
    [datecomps setDay:0];
    
    ///< dateByAddingComponents: 在参数date基础上，增加一个NSDateComponents类型的时间增量
    NSDate *calculatedate = [calendar dateByAddingComponents:datecomps toDate:currentdata options:0];
    [self.leftPicker setDate:calculatedate];
    self.minTime = [calculatedate timeIntervalSince1970] * 1000;
    
    self.leftPicker.maximumDate = [NSDate date];
    self.leftPicker.autoSelected = YES;
    
    self.leftPicker.delegate = self;
    [contenView addSubview:self.leftPicker];
    [self.leftPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cancleButton.mas_bottom).offset(100 * scale);
        make.left.mas_equalTo(80 * scale);
        make.bottom.mas_equalTo(handleButton.mas_top).offset(-100 * scale);
        make.width.mas_equalTo(kMainBoundsWidth / 2 - 160 * scale);
    }];
    
    self.rightPicker = [[PGDatePicker alloc] initWithFrame:CGRectZero];
    self.rightPicker.datePickerMode = PGDatePickerModeYearAndMonth;
    self.rightPicker.textColorOfSelectedRow = UIColorFromRGB(0xDB6283);
    self.rightPicker.lineBackgroundColor = UIColorFromRGB(0xDB6283);
    self.rightPicker.middleTextColor = UIColorFromRGB(0xDB6283);
    self.rightPicker.maximumDate = [NSDate date];
    [self.rightPicker setDate:[NSDate date]];
    self.maxTime = [[NSDate date] timeIntervalSince1970] * 1000;
    self.rightPicker.autoSelected = YES;
    self.rightPicker.delegate = self;
    [contenView addSubview:self.rightPicker];
    [self.rightPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cancleButton.mas_bottom).offset(100 * scale);
        make.right.mas_equalTo(-80 * scale);
        make.bottom.mas_equalTo(handleButton.mas_top).offset(-100 * scale);
        make.width.mas_equalTo(kMainBoundsWidth / 2 - 160 * scale);
    }];
    
    UILabel * middelLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    middelLabel.textAlignment = NSTextAlignmentCenter;
    middelLabel.font = kPingFangRegular(48 * scale);
    middelLabel.textColor = UIColorFromRGB(0x999999);
    middelLabel.text = @"至";
    [contenView addSubview:middelLabel];
    [middelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(self.leftPicker);
        make.height.mas_equalTo(72 * scale);
        make.width.mas_equalTo(120 * scale);
    }];
}

- (void)datePicker:(PGDatePicker *)datePicker didSelectDate:(NSDateComponents *)dateComponents
{
    if (datePicker == self.leftPicker) {
        
        NSDate * date = [NSDate setYear:dateComponents.year month:dateComponents.month];
        self.minTime = [date timeIntervalSince1970] * 1000;
        
    }else if (datePicker == self.rightPicker) {
        
        NSDate * date = [NSDate setYear:dateComponents.year month:dateComponents.month + 1];
        self.maxTime = [date timeIntervalSince1970] * 1000;
        
    }
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (void)cancleButtonDidClicked
{
    [self removeFromSuperview];
}

- (void)handleButtonDidClicked
{
    if (self.minTime >= self.maxTime) {
        [MBProgressHUD showTextHUDWithText:@"开始时间必须小于结束时间" inView:self];
        return;
    }
    
    if (self.handleButtonClicked) {
        self.handleButtonClicked(self.minTime, self.maxTime);
    }
    [self removeFromSuperview];
}

@end
