//
//  DTieYaoyueBlockView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieYaoyueBlockView.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "ChangeWYYStatusRequest.h"
#import "UserManager.h"

@interface DTieYaoyueBlockView ()

@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UIButton * removeButton;
@property (nonatomic, strong) UIButton * handleButton;

@property (nonatomic, strong) UserYaoYueBlockModel * model;
@property (nonatomic, assign) BOOL isAuthor;

@end

@implementation DTieYaoyueBlockView

- (instancetype)initWithBlockModel:(UserYaoYueBlockModel *)model isAuthor:(BOOL)isAuthor
{
    if (self = [super init]) {
        self.model = model;
        self.isAuthor = isAuthor;
        [self createYaoyueBlockView];
    }
    return self;
}

- (void)createYaoyueBlockView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(100 * scale);
        make.centerY.mas_equalTo(0);
        make.width.height.mas_equalTo(96 * scale);
    }];
    [DDViewFactoryTool cornerRadius:48 * scale withView:self.imageView];
    
    if (self.isAuthor) {
        if (self.model.userId != [UserManager shareManager].user.cid) {
            self.removeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(12 * scale) titleColor:UIColorFromRGB(0xffffff) title:@""];
            [self.removeButton setImage:[UIImage imageNamed:@"wyyremove"] forState:UIControlStateNormal];
            [self addSubview:self.removeButton];
            [self.removeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.imageView);
                make.right.mas_equalTo(self.imageView.mas_left).offset(-20 * scale);
                make.width.height.mas_equalTo(20);
            }];
            [self.removeButton addTarget:self action:@selector(removeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imageView.mas_right).offset(20 * scale);
        make.right.mas_equalTo(250 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(72 * scale);
    }];
    
    self.handleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [self addSubview:self.handleButton];
    [self.handleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(200 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    [DDViewFactoryTool cornerRadius:36 * scale withView:self.handleButton];
    self.handleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.handleButton.layer.borderWidth = 3 * scale;
    [self.handleButton addTarget:self action:@selector(handleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.model.portrait]];
    self.nameLabel.text = self.model.nickname;
    [self reloadButtonStatus];
}

- (void)removeButtonDidClicked
{
    if (self.removeDidClicked) {
        self.removeDidClicked(self.model);
    }
}

- (void)handleButtonDidClicked
{
    if (self.model.userId != [UserManager shareManager].user.cid) {
        return;
    }
    
    NSInteger resultStatus = 1;
    if (self.model.subtype == 1) {
        resultStatus = 2;
    }else if (self.model.subtype == 2) {
        resultStatus = 0;
    }else if (self.model.subtype == 0) {
        resultStatus = 1;
    }
    [ChangeWYYStatusRequest cancelRequest];
    ChangeWYYStatusRequest * request =  [[ChangeWYYStatusRequest alloc] initWithPostID:self.model.postID subType:resultStatus];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        self.model.subtype = resultStatus;
        [self reloadButtonStatus];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)reloadButtonStatus
{
    if (self.model.subtype == 1) {
        [self.handleButton setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.handleButton setTitleColor:UIColorFromRGB(0xDB6283) forState:UIControlStateNormal];
        [self.handleButton setTitle:DDLocalizedString(@"Attend") forState:UIControlStateNormal];
    }else if (self.model.subtype == 0) {
        [self.handleButton setBackgroundColor:[UIColorFromRGB(0xDB6283) colorWithAlphaComponent:.5f]];
        [self.handleButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        [self.handleButton setTitle:DDLocalizedString(@"TBD") forState:UIControlStateNormal];
    }else if (self.model.subtype == 2) {
        [self.handleButton setBackgroundColor:UIColorFromRGB(0xDB6283)];
        [self.handleButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        [self.handleButton setTitle:DDLocalizedString(@"OutFollow") forState:UIControlStateNormal];
    }
}

@end
