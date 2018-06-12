//
//  DDShareManager.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/28.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDShareManager.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import "DDTool.h"
#import "MBProgressHUD+DDHUD.h"
#import "DTieShareViewController.h"

@interface DDShareManager ()

@property (nonatomic, strong) ShareImageModel * handleImage;

@property (nonatomic, strong) UIView * handleView;
@property (nonatomic, strong) UIButton * savePhotoButton;
@property (nonatomic, strong) UIButton * addShareListButton;
@property (nonatomic, strong) UILabel * numberLabel;
@property (nonatomic, strong) NSMutableArray * shareList;

@end

@implementation DDShareManager

+ (instancetype)shareManager
{
    static dispatch_once_t once;
    static DDShareManager * instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)updateNumber
{
    NSString * number = [NSString stringWithFormat:@"%lu/9", (unsigned long)self.shareList.count];
    self.numberLabel.text = number;
    if (self.tempNumberLabel) {
        [self.tempNumberLabel setTitle:number forState:UIControlStateNormal];
    }
}

- (void)addShareList
{
    if (self.handleImage) {
        
        if (self.shareList.count >= 9) {
            [self showShareList];
            [MBProgressHUD showTextHUDWithText:@"最多只能分享9张图片" inView:[UIApplication sharedApplication].keyWindow];
        }else{
            [self.shareList addObject:self.handleImage];
            [self hiddenHandleView];
            [self updateNumber];
            if (self.shareList.count >= 9) {
                [self showShareList];
            }
        }
    }
}

- (void)showShareList
{
    UITabBarController * tabbar = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if ([tabbar isKindOfClass:[UITabBarController class]]) {
        
        DTieShareViewController * share = [[DTieShareViewController alloc] initWithShareList:self.shareList];
        [tabbar.selectedViewController presentViewController:share animated:YES completion:nil];
    }
}

- (void)savePhoto
{
    if (self.handleImage) {
        [DDTool userLibraryAuthorizationStatusWithSuccess:^{
            
            [DDTool saveImageInSystemPhoto:self.handleImage.image];
            [self hiddenHandleView];
        } failure:^{
            [MBProgressHUD showTextHUDWithText:@"没有相册访问权限" inView:self.handleView];
        }];
    }
}

- (void)showHandleViewWithImage:(ShareImageModel *)image
{
    if (nil == image) {
        return;
    }
    
    self.numberLabel.text = [NSString stringWithFormat:@"%lu/9", (unsigned long)self.shareList.count];
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    self.handleImage = image;
    [[UIApplication sharedApplication].keyWindow addSubview:self.handleView];
    
    [self.handleView layoutIfNeeded];
    [self.addShareListButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
    }];
    [self.savePhotoButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
    }];
    [UIView animateWithDuration:.5f delay:0.f usingSpringWithDamping:.5f initialSpringVelocity:25.f options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        [self.handleView layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hiddenHandleView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    [self.handleView removeFromSuperview];
    [self.addShareListButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(360 * scale);
    }];
    [self.savePhotoButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(-360 * scale);
    }];
    self.handleImage = nil;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self createShareUI];
        self.shareList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)createShareUI
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.handleView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.handleView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenHandleView)];
    [self.handleView addGestureRecognizer:tap];
    
    self.savePhotoButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self.handleView addSubview:self.savePhotoButton];
    [self.savePhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(-360 * scale);
        make.centerY.mas_equalTo(0);
        make.width.height.mas_equalTo(360 * scale);
    }];
    CAGradientLayer *gradientLayer1 = [CAGradientLayer layer];
    gradientLayer1.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer1.startPoint = CGPointMake(0, 1);
    gradientLayer1.endPoint = CGPointMake(1, 0);
    gradientLayer1.locations = @[@0, @1.0];
    gradientLayer1.frame = CGRectMake(0, 0, 360 * scale, 360 * scale);
    [self.savePhotoButton.layer addSublayer:gradientLayer1];
    [DDViewFactoryTool cornerRadius:180 * scale withView:self.savePhotoButton];
    
    UILabel * saveLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentCenter];
    saveLabel.text = @"保存图片到手机";
    [self.savePhotoButton addSubview:saveLabel];
    [saveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(180 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
    UIImageView * saveImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"save"]];
    [self.savePhotoButton addSubview:saveImageView];
    [saveImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(75 * scale);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(72 * scale);
    }];
    
    self.addShareListButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self.handleView addSubview:self.addShareListButton];
    [self.addShareListButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(360 * scale);
        make.centerY.mas_equalTo(0);
        make.width.height.mas_equalTo(360 * scale);
    }];
    CAGradientLayer *gradientLayer2 = [CAGradientLayer layer];
    gradientLayer2.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer2.startPoint = CGPointMake(0, 1);
    gradientLayer2.endPoint = CGPointMake(1, 0);
    gradientLayer2.locations = @[@0, @1.0];
    gradientLayer2.frame = CGRectMake(0, 0, 360 * scale, 360 * scale);
    [self.addShareListButton.layer addSublayer:gradientLayer2];
    [DDViewFactoryTool cornerRadius:180 * scale withView:self.addShareListButton];
    
    UILabel * addLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentCenter];
    addLabel.text = @"加入分享列表";
    [self.addShareListButton addSubview:addLabel];
    [addLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(180 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
    UIImageView * addImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"addshare"]];
    [self.addShareListButton addSubview:addImageView];
    [addImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(75 * scale);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(72 * scale);
    }];
    
    self.numberLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:[UIColorFromRGB(0xFFFFFF) colorWithAlphaComponent:.5f] alignment:NSTextAlignmentCenter];
    [self.addShareListButton addSubview:self.numberLabel];
    self.numberLabel.text = @"0/9";
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(addLabel.mas_bottom).offset(10 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(40 * scale);
    }];
    [self.savePhotoButton addTarget:self action:@selector(savePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.addShareListButton addTarget:self action:@selector(addShareList) forControlEvents:UIControlEventTouchUpInside];
}

@end
