//
//  DDCollectionHandleView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDCollectionHandleView.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>

@interface DDCollectionHandleView ()

@end

@implementation DDCollectionHandleView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createDDCollectionHandleView];
    }
    return self;
}

- (void)createDDCollectionHandleView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.handleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@""];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.handleButton];
    self.handleButton.layer.borderColor = UIColorFromRGB(0xDB5282).CGColor;
    self.handleButton.layer.borderWidth = 3 * scale;
    [self addSubview:self.handleButton];
    [self.handleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.bottom.mas_equalTo(-63 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(144 * scale);
    }];
    [self.handleButton addTarget:self action:@selector(handleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)handleButtonDidClicked
{
    if (self.handleButtonClicked) {
        self.handleButtonClicked();
    }
}

- (void)configButtonBackgroundColor:(UIColor *)color title:(NSString *)title
{
    [self setBackgroundColor:color];
    [self.handleButton setTitle:title forState:UIControlStateNormal];
}

@end
