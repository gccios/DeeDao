//
//  DTieFoundEditView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieFoundEditView.h"
#import <Masonry.h>
#import "DDViewFactoryTool.h"
#import "DDTool.h"

@interface DTieFoundEditView()<BMKGeoCodeSearchDelegate>

@property (nonatomic, strong) UIView * baseView;
@property (nonatomic, strong) BMKGeoCodeSearch *geocodesearch;

@property (nonatomic, strong) UIView * tipView;
@property (nonatomic, strong) UILabel * tipLabel;

@end

@implementation DTieFoundEditView

- (instancetype)initWithFrame:(CGRect)frame coordinate:(CLLocationCoordinate2D)coordinate
{
    if (self = [super initWithFrame:frame]) {
        self.coordinate = coordinate;
        
        [self createSelfView];
        
        self.geocodesearch = [[BMKGeoCodeSearch alloc] init];
        self.geocodesearch.delegate = self;
        [self reverseGeoCodeWith:self.coordinate];
    }
    return self;
}

#pragma mark ----反向地理编码
- (void)reverseGeoCodeWith:(CLLocationCoordinate2D)coordinate
{
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeocodeSearchOption.reverseGeoPoint = coordinate;
    [self.geocodesearch reverseGeoCode:reverseGeocodeSearchOption];;
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    self.locationLabel.text = [NSString stringWithFormat:@"%@\n%@,%@", [DDTool getCurrentTimeWithFormat:@"yyyy年MM月dd日 HH:mm"], result.address, result.sematicDescription];
}


- (void)createSelfView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
    
    self.baseView = [[UIView alloc] init];
    [self addSubview:self.baseView];
    self.baseView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(540 * scale);
    }];
    
    self.titleTextField = [[UITextField alloc] init];
    self.titleTextField.placeholder = @"写个标题";
    self.titleTextField.font = kPingFangRegular(42 * scale);
    [self.baseView addSubview:self.titleTextField];
    [self.titleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    UIView * line1 = [[UIView alloc] init];
    line1.backgroundColor = [UIColorFromRGB(0x000000) colorWithAlphaComponent:.12f];
    [self.baseView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleTextField.mas_bottom).offset(60 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(3 * scale);
    }];
    
    UIView * locationImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"location"]];
    [self.baseView addSubview:locationImageView];
    [locationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(line1.mas_bottom).offset(24 * scale);
        make.left.mas_equalTo(60 * scale);
        make.width.height.mas_equalTo(72 * scale);
    }];
    
    self.locationLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.locationLabel.numberOfLines = 0;
    [self.baseView addSubview:self.locationLabel];
    [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(locationImageView);
        make.left.mas_equalTo(144 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    
    UIButton * button = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"D贴草稿已生成，点击深度编辑"];
    [DDViewFactoryTool cornerRadius:24 * scale withView:button];
    button.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    button.layer.borderWidth = 3 * scale;
    [button addTarget:self action:@selector(editButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.baseView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.bottom.mas_equalTo(-70 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(144 * scale);
    }];
    
    UIView * closeView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:closeView];
    [closeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(self.baseView.mas_top);
    }];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeViewDidClicked)];
    tap.numberOfTapsRequired = 1;
    [closeView addGestureRecognizer:tap];
    
    [self showTipWithText:@"请确认当前信息，并点击保存"];
}

- (void)editButtonDidClicked
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(DTieFoundEditViewBeginEidt:)]) {
        [self.delegate DTieFoundEditViewBeginEidt:self];
    }
}

- (void)closeViewDidClicked
{
    if ([self.titleTextField isFirstResponder]) {
        [self.titleTextField resignFirstResponder];
    }else{
        [self removeFromSuperview];
    }
}

- (void)showTipWithText:(NSString *)text
{
    self.tipView.alpha = 0;
    
    self.tipLabel.text = text;
    [UIView animateWithDuration:.3f animations:^{
        self.tipView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hiddenTip
{
    [UIView animateWithDuration:.5f animations:^{
        self.tipView.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

- (UIView *)tipView
{
    if (!_tipView) {
        CGFloat scale = kMainBoundsWidth / 1080.f;
        
        _tipView = [[UIView alloc] initWithFrame:CGRectZero];
        _tipView.backgroundColor = [UIColorFromRGB(0x394249) colorWithAlphaComponent:.8f];
        [self addSubview:_tipView];
        [_tipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(25 * scale + (220 + kStatusBarHeight) * scale);
            make.left.mas_equalTo(24 * scale);
            make.right.mas_equalTo(-24 * scale);
            make.height.mas_equalTo(132 * scale);
        }];
        [DDViewFactoryTool cornerRadius:6 * scale withView:_tipView];
        
        UIImageView * tipImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"map"]];
        [_tipView addSubview:tipImageView];
        [tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(40 * scale);
            make.centerY.mas_equalTo(0);
            make.width.height.mas_equalTo(45 * scale);
        }];
        
        self.tipLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xF8F8F8) alignment:NSTextAlignmentCenter];
        [_tipView addSubview:self.tipLabel];
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.left.mas_equalTo(120 * scale);
            make.right.mas_equalTo(-120 * scale);
        }];
        
        UIImageView * tipAlert = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"alert"]];
        [_tipView addSubview:tipAlert];
        [tipAlert mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-40 * scale);
            make.centerY.mas_equalTo(0);
            make.width.height.mas_equalTo(60*scale);
        }];
        
        _tipView.alpha = 0;
    }
    return _tipView;
}

@end
