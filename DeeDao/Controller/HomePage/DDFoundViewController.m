//
//  DDFoundViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDFoundViewController.h"

@interface DDFoundViewController ()

@property (nonatomic, strong) UIImageView * topImageView;

@property (nonatomic, strong) UIButton * sourceButton;
@property (nonatomic, strong) UIButton * timeButton;

@end

@implementation DDFoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self creatViews];
}

- (void)creatViews
{
    [self.navigationController setNavigationBarHidden:YES];
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.topImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"navBack"]];
    self.topImageView.userInteractionEnabled = YES;
    [self.view addSubview:self.topImageView];
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(240 * scale);
    }];
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentCenter];
    titleLabel.text = @"发现";
    [self.topImageView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60.5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
    self.sourceButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [self.sourceButton setImage:[UIImage imageNamed:@"source"] forState:UIControlStateNormal];
    [self.sourceButton addTarget:self action:@selector(sourceButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    self.sourceButton.alpha = .4f;
    [self.topImageView addSubview:self.sourceButton];
    [self.sourceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-40 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    self.timeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [self.timeButton setImage:[UIImage imageNamed:@"time"] forState:UIControlStateNormal];
    [self.timeButton addTarget:self action:@selector(timeButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    self.timeButton.alpha = .4f;
    [self.topImageView addSubview:self.timeButton];
    [self.timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.sourceButton.mas_left).offset(-30 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
}

- (void)timeButtonDidClicked
{
    self.timeButton.alpha = 1.f;
    self.sourceButton.alpha = .4f;
}

- (void)sourceButtonDidClicked
{
    self.timeButton.alpha = .4f;
    self.sourceButton.alpha = 1.f;
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
