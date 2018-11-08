
//
//  DTieCreateLocationView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/5.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieCreateLocationView.h"
#import "DDViewFactoryTool.h"
#import "MBProgressHUD+DDHUD.h"
#import "DDTool.h"
#import "RDTextView.h"
#import <Masonry.h>

@interface DTieCreateLocationView ()

@property (nonatomic, copy) NSString * address;

@property (nonatomic, strong) UITextField * addressField;
@property (nonatomic, strong) UITextField * nameField;
@property (nonatomic, strong) RDTextView * introduceField;

@end

@implementation DTieCreateLocationView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createDtieCreateLocationView];
    }
    return self;
}

- (void)createDtieCreateLocationView
{
    self.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.addressField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.addressField.textColor = UIColorFromRGB(0xDB6283);
    self.addressField.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.addressField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.addressField.placeholder = @"请输入您想要的地址";
    [self addSubview:self.addressField];
    [self.addressField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.top.right.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    
    UIView * addressLine = [[UIView alloc] initWithFrame:CGRectZero];
    addressLine.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.addressField addSubview:addressLine];
    [addressLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(3 * scale);
    }];
    
    self.nameField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.nameField.textColor = UIColorFromRGB(0x333333);
    self.nameField.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameField.placeholder = @"请输入您想要的名称";
    self.nameField.text = [NSString stringWithFormat:@"%@ %@", DDLocalizedString(@"Deedao POI"), [DDTool getCurrentTimeWithFormat:@"yyyy/MM/dd"]];
    [self addSubview:self.nameField];
    [self.nameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.addressField.mas_bottom);
        make.right.mas_equalTo(0);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(144 * scale);
    }];
    
    UIView * nameLine = [[UIView alloc] initWithFrame:CGRectZero];
    nameLine.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.nameField addSubview:nameLine];
    [nameLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(3 * scale);
    }];
    
    self.introduceField = [[RDTextView alloc] initWithFrame:CGRectZero];
    self.introduceField.textColor = UIColorFromRGB(0x333333);
    self.introduceField.backgroundColor = UIColorFromRGB(0xFFFFFF);
//    self.introduceField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.introduceField.maxSize = 100;
    self.introduceField.placeholderLabel.textColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.7];
    self.introduceField.placeholderLabel.font = kPingFangRegular(42 * scale);
    self.introduceField.font = kPingFangRegular(42 * scale);
    self.introduceField.placeholder = DDLocalizedString(@"Describe");
    [self addSubview:self.introduceField];
    [self.introduceField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameField.mas_bottom);
        make.right.mas_equalTo(0);
        make.left.mas_equalTo(55 * scale);
        make.bottom.mas_equalTo(-270 * scale);
    }];
    
    UIView * introduceLine = [[UIView alloc] initWithFrame:CGRectZero];
    introduceLine.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.introduceField addSubview:introduceLine];
    [introduceLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(3 * scale);
    }];
    
    UIButton * leftHandleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"Cancel")];
    [DDViewFactoryTool cornerRadius:24 * scale withView:leftHandleButton];
    leftHandleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    leftHandleButton.layer.borderWidth = 3 * scale;
    [self addSubview:leftHandleButton];
    [leftHandleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.width.mas_equalTo(444 * scale);
        make.height.mas_equalTo(144 * scale);
        make.bottom.mas_equalTo(-90 * scale);
    }];
    
    UIButton * rightHandleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"Create")];
    [DDViewFactoryTool cornerRadius:24 * scale withView:rightHandleButton];
    rightHandleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    rightHandleButton.layer.borderWidth = 3 * scale;
    [self addSubview:rightHandleButton];
    [rightHandleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.width.mas_equalTo(444 * scale);
        make.height.mas_equalTo(144 * scale);
        make.bottom.mas_equalTo(-90 * scale);
    }];
    
    [leftHandleButton addTarget:self action:@selector(leftButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [rightHandleButton addTarget:self action:@selector(rightButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)leftButtonDidClicked
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(DTieCreateLocationDidCancle)]) {
        [self.delegate DTieCreateLocationDidCancle];
    }
}

- (void)rightButtonDidClicked
{
    NSString * address = self.addressField.text;
    NSString * name = self.nameField.text;
    NSString * introduce = self.introduceField.text;
    
    if (isEmptyString(address)) {
        [MBProgressHUD showTextHUDWithText:@"请输入地址" inView:self];
        return;
    }
    if (isEmptyString(name)) {
        [MBProgressHUD showTextHUDWithText:@"请输入地点名称" inView:self];
        return;
    }
    if (isEmptyString(introduce)) {
        introduce = @"";
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(DTieCreateLocationDidCompleteAddress:name:introduce:)]) {
        [self.delegate DTieCreateLocationDidCompleteAddress:address name:name introduce:introduce];
    }
}

- (void)configAddress:(NSString *)address
{
    if (!isEmptyString(address)) {
        self.address = address;
        self.addressField.text = address;
    }
}

- (void)endEdit
{
    if (self.addressField.isFirstResponder) {
        [self.addressField resignFirstResponder];
    }
    if (self.nameField.isFirstResponder) {
        [self.nameField resignFirstResponder];
    }
    if (self.introduceField.isFirstResponder) {
        [self.introduceField resignFirstResponder];
    }
}

@end
