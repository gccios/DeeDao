//
//  DDDTieViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDDTieViewController.h"

@interface DDDTieViewController ()

@property (nonatomic, strong) UIImageView * topImageView;

@property (nonatomic, strong) UIButton * searchButton;
@property (nonatomic, strong) UIButton * mapButton;
@property (nonatomic, strong) UIButton * seriesButton;

@end

@implementation DDDTieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createViews];
}

- (void)createViews
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
    titleLabel.text = @"D贴";
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
    
    self.mapButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [self.mapButton setImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal];
    [self.mapButton addTarget:self action:@selector(mapButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topImageView addSubview:self.mapButton];
    [self.mapButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.searchButton.mas_left).offset(-20 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    self.seriesButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [self.seriesButton setImage:[UIImage imageNamed:@"series"] forState:UIControlStateNormal];
    [self.seriesButton addTarget:self action:@selector(seriesButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topImageView addSubview:self.seriesButton];
    [self.seriesButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mapButton.mas_left).offset(-20 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
}

- (void)seriesButtonDidClicked
{
    NSLog(@"系列");
}

- (void)mapButtonDidClicked
{
    NSLog(@"地图");
}

- (void)searchButtonDidClicked
{
    NSLog(@"搜索");
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
