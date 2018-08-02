//
//  OnlyMapViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "OnlyMapViewController.h"

@interface OnlyMapViewController ()

@property (nonatomic, strong) UIView * tempView;
@property (nonatomic, strong) UILabel * yearLabel;

@end

@implementation OnlyMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    self.yearLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentCenter];
    [self.view addSubview:self.yearLabel];
    [self.yearLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(120 * scale);
        make.bottom.mas_equalTo(120 * scale);
    }];
    self.yearLabel.text = [NSString stringWithFormat:@"%ld", self.year];
    if (self.year == -1) {
        self.yearLabel.text = @"全部时间";
    }
}

- (void)onBackgroundTap:(UITapGestureRecognizer *)tap
{
    if([self.delegate respondsToSelector:@selector(viewControllerDidReceiveTap:)]) {
        [self.delegate viewControllerDidReceiveTap:self];
    }
}

- (void)addOnlyMapWith:(UIView *)view
{
    [self.tempView removeFromSuperview];
    
    self.tempView = [view snapshotViewAfterScreenUpdates:NO];
    
    [self.view addSubview:self.tempView];
    [self.tempView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.mas_equalTo(0);
    }];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackgroundTap:)];
    [self.tempView addGestureRecognizer:tapGesture];
}

- (UIView *)tempView
{
    if (!_tempView) {
        _tempView = [UIView new];
    }
    return _tempView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
