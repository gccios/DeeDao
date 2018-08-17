//
//  ChooseTypeViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/15.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "ChooseTypeViewController.h"
#import "ChooseTypeButton.h"
#import "MBProgressHUD+DDHUD.h"

@interface ChooseTypeViewController ()

@property (nonatomic, strong) ChooseTypeButton * myButton;
@property (nonatomic, assign) NSInteger sourceType;
@property (nonatomic, strong) UIImageView * currentImageView;

@end

@implementation ChooseTypeViewController

- (instancetype)initWithSourceType:(NSInteger)sourceType
{
    if (self = [super init]) {
        self.sourceType = sourceType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    ChooseTypeButton * myButton = [ChooseTypeButton buttonWithType:UIButtonTypeCustom];
    myButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    myButton.layer.borderWidth = 3 * scale;
    myButton.tag = 11;
    [myButton setTitleColor:UIColorFromRGB(0xDB6283) forState:UIControlStateNormal];
    [myButton setTitle:@"我的" forState:UIControlStateNormal];
    [myButton setBackgroundColor:[UIColorFromRGB(0xdb6283) colorWithAlphaComponent:.1f]];
    myButton.frame = CGRectMake(0, 0, 400 * scale, 400 * scale);
    [DDViewFactoryTool cornerRadius:200 * scale withView:myButton];
    [self.view addSubview:myButton];
    [myButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(100 * scale);
        make.centerY.mas_equalTo(-300 * scale);
        make.width.height.mas_equalTo(myButton.frame.size.width);
    }];
    [myButton addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    ChooseTypeButton * buzhuButton = [ChooseTypeButton buttonWithType:UIButtonTypeCustom];
    buzhuButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    buzhuButton.layer.borderWidth = 3 * scale;
    buzhuButton.tag = 12;
    [buzhuButton setTitleColor:UIColorFromRGB(0xDB6283) forState:UIControlStateNormal];
    [buzhuButton setTitle:@"博主" forState:UIControlStateNormal];
    [buzhuButton setBackgroundColor:[UIColorFromRGB(0xdb6283) colorWithAlphaComponent:.1f]];
    buzhuButton.frame = CGRectMake(0, 0, 300 * scale, 300 * scale);
    [DDViewFactoryTool cornerRadius:150 * scale withView:buzhuButton];
    [self.view addSubview:buzhuButton];
    [buzhuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.top.mas_equalTo(myButton.mas_top).offset(200 * scale);
        make.width.height.mas_equalTo(buzhuButton.frame.size.width);
    }];
    [buzhuButton addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    ChooseTypeButton * otherButton = [ChooseTypeButton buttonWithType:UIButtonTypeCustom];
    otherButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    otherButton.layer.borderWidth = 3 * scale;
    otherButton.tag = 13;
    [otherButton setTitleColor:UIColorFromRGB(0xDB6283) forState:UIControlStateNormal];
    [otherButton setTitle:@"其他" forState:UIControlStateNormal];
    [otherButton setBackgroundColor:[UIColorFromRGB(0xdb6283) colorWithAlphaComponent:.1f]];
    otherButton.frame = CGRectMake(0, 0, 220 * scale, 220 * scale);
    [DDViewFactoryTool cornerRadius:110 * scale withView:otherButton];
    [self.view addSubview:otherButton];
    [otherButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(350 * scale);
        make.top.mas_equalTo(myButton.mas_bottom).offset(30 * scale);
        make.width.height.mas_equalTo(otherButton.frame.size.width);
    }];
    [otherButton addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    ChooseTypeButton * alertButton = [ChooseTypeButton buttonWithType:UIButtonTypeCustom];
    alertButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    alertButton.layer.borderWidth = 3 * scale;
    alertButton.tag = 14;
    [alertButton setTitleColor:UIColorFromRGB(0xDB6283) forState:UIControlStateNormal];
    [alertButton setTitle:@"提醒" forState:UIControlStateNormal];
    [alertButton setBackgroundColor:[UIColorFromRGB(0xdb6283) colorWithAlphaComponent:.1f]];
    alertButton.frame = CGRectMake(0, 0, 220 * scale, 220 * scale);
    [DDViewFactoryTool cornerRadius:110 * scale withView:alertButton];
    [self.view addSubview:alertButton];
    [alertButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(myButton.mas_right).offset(60 * scale);
        make.top.mas_equalTo(myButton.mas_top).offset(30 * scale);
        make.width.height.mas_equalTo(alertButton.frame.size.width);
    }];
    [alertButton addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.currentImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"currentPD"]];
    [self.view addSubview:self.currentImageView];
    
    if (self.sourceType == 6) {
        [otherButton setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.currentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(otherButton);
            make.bottom.mas_equalTo(otherButton.mas_top);
            make.width.mas_equalTo(270 * scale);
            make.height.mas_equalTo(100 * scale);
        }];
    }else if (self.sourceType == 7){
        [myButton setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.currentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(myButton);
            make.bottom.mas_equalTo(myButton.mas_top);
            make.width.mas_equalTo(270 * scale);
            make.height.mas_equalTo(100 * scale);
        }];
    }else if (self.sourceType == 8){
        [buzhuButton setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.currentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(buzhuButton);
            make.bottom.mas_equalTo(buzhuButton.mas_top);
            make.width.mas_equalTo(270 * scale);
            make.height.mas_equalTo(100 * scale);
        }];
    }else if (self.sourceType == 10){
        [alertButton setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.currentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(alertButton);
            make.bottom.mas_equalTo(alertButton.mas_top);
            make.width.mas_equalTo(270 * scale);
            make.height.mas_equalTo(100 * scale);
        }];
    }
}

- (void)buttonDidClicked:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(typeDidChooseComplete:)]) {
        [self.delegate typeDidChooseComplete:button.tag];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
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
