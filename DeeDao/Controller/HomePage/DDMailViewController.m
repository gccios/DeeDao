//
//  DDMailViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/10.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDMailViewController.h"

@interface DDMailViewController ()

@property (nonatomic, strong) UIImageView * topImageView;

@property (nonatomic, strong) UIButton * searchButton;
@property (nonatomic, strong) UIButton * messageButton;

@end

@implementation DDMailViewController

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
    titleLabel.text = @"邮筒";
    [self.topImageView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60.5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
    self.searchButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [self.searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [self.searchButton addTarget:self action:@selector(searchButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topImageView addSubview:self.searchButton];
    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-40 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    self.messageButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [self.messageButton setImage:[UIImage imageNamed:@"message"] forState:UIControlStateNormal];
    [self.messageButton addTarget:self action:@selector(messageButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topImageView addSubview:self.messageButton];
    [self.messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.searchButton.mas_left).offset(-30 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
}

- (void)messageButtonDidClicked
{
    NSLog(@"时间");
}

- (void)searchButtonDidClicked
{
    NSLog(@"来源");
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
