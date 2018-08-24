//
//  DDBackWidow.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDBackWidow.h"
#import <Masonry.h>
#import "DDLGSideViewController.h"

@interface DDBackWidow ()

@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) BOOL isHalfShow;

@property (nonatomic, assign) BOOL isShouldHiddenHalf;

@property (nonatomic, strong) UIPanGestureRecognizer * pan;
@property (nonatomic, strong) UITapGestureRecognizer * tap;

@end

@implementation DDBackWidow

+ (instancetype)shareWindow
{
    static dispatch_once_t once;
    static DDBackWidow * instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self createDDBackWindow];
    }
    return self;
}

- (void)windowDidClicked:(UITapGestureRecognizer *)tap
{
    if (self.isHalfShow) {
        [self showAllFromHalf];
        [self shouldHiddenHalf];
    }else if (self.isShow) {
        
        [self shouldHiddenHalf];
        DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        if ([lg isKindOfClass:[DDLGSideViewController class]]) {
            UINavigationController * na = (UINavigationController *)lg.rootViewController;
            if ([na isKindOfClass:[UINavigationController class]]) {
                [na popToRootViewControllerAnimated:YES];
            }
        }
    }
}

- (void)backWindowDidPan:(UIPanGestureRecognizer *)pan
{
    // 得到我们在视图上移动的偏移量
    CGPoint currentPoint = [pan translationInView:self];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        
        if (self.isShouldHiddenHalf) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenHalf) object:nil];
            self.isShouldHiddenHalf = NO;
        }
        
    }else if (pan.state == UIGestureRecognizerStateChanged) {
        
        CGFloat originY = self.frame.origin.y + currentPoint.y;
        CGFloat height = self.frame.size.height;
        
        if (originY < height) {
            originY = height;
        }
        
        if (originY > kMainBoundsHeight - height * 2) {
            originY = kMainBoundsHeight - height * 2;
        }
        
        self.frame = CGRectMake(self.frame.origin.x, originY, self.frame.size.width, self.frame.size.height);
        
        [pan setTranslation:CGPointZero inView:self];
        
    }else {
        
        [self shouldHiddenHalf];
        
    }
}

- (void)createDDBackWindow
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    self.frame = CGRectMake(-10 * scale, kMainBoundsHeight / 4.f * 3, 290 * scale, 150 * scale);
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setImage:[UIImage imageNamed:@"backWindow"]];
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(backWindowDidPan:)];
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(windowDidClicked:)];
    [self addGestureRecognizer:self.pan];
    [self addGestureRecognizer:self.tap];
}

- (void)show
{
    if (self.isShow) {
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];
        return;
    }
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.isShow = YES;
    [self shouldHiddenHalf];
}

- (void)hidden
{
    if (self.isShow) {
        [self removeFromSuperview];
        self.isShow = NO;
        self.isHalfShow = NO;
    }
}

- (void)showAllFromHalf
{
    self.pan.enabled = NO;
    self.tap.enabled = NO;
    [UIView animateWithDuration:.3f animations:^{
        CGRect frame = self.frame;
        frame.origin.x = -10 * kMainBoundsWidth / 1080.f;
        self.frame = frame;
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        self.tap.enabled = YES;
        self.pan.enabled = YES;
        self.isHalfShow = NO;
    }];
}

- (void)shouldHiddenHalf
{
    if (self.isShouldHiddenHalf) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenHalf) object:nil];
        self.isShouldHiddenHalf = NO;
    }
    [self performSelector:@selector(hiddenHalf) withObject:nil afterDelay:3.f];
    self.isShouldHiddenHalf = YES;
}

- (void)hiddenHalf
{
    self.pan.enabled = NO;
    self.tap.enabled = NO;
    [UIView animateWithDuration:.3f animations:^{
        CGFloat scale = kMainBoundsWidth / 1080.f;
        CGRect frame = self.frame;
        frame.origin.x = -170 * scale;
        self.frame = frame;
        self.alpha = .5f;
    } completion:^(BOOL finished) {
        self.tap.enabled = YES;
        self.isHalfShow = YES;
    }];
}

@end
