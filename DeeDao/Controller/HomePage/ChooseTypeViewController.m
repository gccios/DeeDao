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
#import "DDBackWidow.h"

@interface ChooseTypeViewController ()

@property (nonatomic, strong) ChooseTypeButton * myButton;
@property (nonatomic, assign) NSInteger sourceType;
@property (nonatomic, strong) UIImageView * currentImageView;
@property (nonatomic, strong) UIImageView * BGImageView;

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
    
//    self.BGImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:self.BGImage];
//    [self.view addSubview:self.BGImageView];
//    [self.BGImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(0);
//    }];
    
    UIView * BGView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:BGView];
    [BGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight);
    gradientLayer.opacity = .8f;
    [BGView.layer addSublayer:gradientLayer];
    
    UIView * buzhuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500 * scale, 500 * scale)];
    [self.view addSubview:buzhuView];
    [buzhuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(50 * scale);
        make.centerY.mas_equalTo(-350 * scale);
        make.width.height.mas_equalTo(buzhuView.frame.size.width);
    }];
    
    ChooseTypeButton * buzhuButton = [ChooseTypeButton buttonWithType:UIButtonTypeCustom];
    buzhuButton.tag = 12;
    buzhuButton.alpha = .5f;
//    [buzhuButton setTitle:DDLocalizedString(@"Blogger") forState:UIControlStateNormal];
    [buzhuButton setBackgroundImage:[UIImage imageNamed:@"PDButton"] forState:UIControlStateNormal];
    [buzhuButton setImage:[UIImage imageNamed:@"PDBozhu"] forState:UIControlStateNormal];
    [buzhuButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 25 * scale, 0)];
    buzhuButton.frame = CGRectMake(0, 0, 500 * scale, 500 * scale);
    [self.view addSubview:buzhuButton];
    [buzhuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(50 * scale);
        make.centerY.mas_equalTo(-400 * scale);
        make.width.height.mas_equalTo(buzhuButton.frame.size.width);
    }];
    [buzhuButton addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * buzhuLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0xffffff) alignment:NSTextAlignmentCenter];
    buzhuLabel.text = DDLocalizedString(@"Blogger");
    [buzhuButton addSubview:buzhuLabel];
    [buzhuLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(buzhuButton);
        make.bottom.mas_equalTo(buzhuButton.mas_bottom).offset(-25 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    UIView * myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 350 * scale, 350 * scale)];
    [self.view addSubview:myView];
    [myView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(buzhuButton.mas_right).offset(-30 * scale);
        make.top.mas_equalTo(buzhuButton.mas_top).offset(0 * scale);
        make.width.height.mas_equalTo(myView.frame.size.width);
    }];
    
    ChooseTypeButton * myButton = [ChooseTypeButton buttonWithType:UIButtonTypeCustom];
    myButton.tag = 11;
    myButton.alpha = .5f;
//    [myButton setTitle:DDLocalizedString(@"Friend") forState:UIControlStateNormal];
    [myButton setBackgroundImage:[UIImage imageNamed:@"PDButton"] forState:UIControlStateNormal];
    [myButton setImage:[UIImage imageNamed:@"PDHaoyou"] forState:UIControlStateNormal];
    [myButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 25 * scale, 0)];
    myButton.frame = CGRectMake(0, 0, 350 * scale, 350 * scale);
    [self.view addSubview:myButton];
    [myButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(buzhuButton.mas_right).offset(-30 * scale);
        make.top.mas_equalTo(buzhuButton.mas_top).offset(0 * scale);
        make.width.height.mas_equalTo(myButton.frame.size.width);
    }];
    [myButton addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * myLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0xffffff) alignment:NSTextAlignmentCenter];
    myLabel.text = DDLocalizedString(@"Friend");
    [myButton addSubview:myLabel];
    [myLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(myButton);
        make.bottom.mas_equalTo(myButton.mas_bottom).offset(-5 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    UIView * alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400 * scale, 400 * scale)];
    [self.view addSubview:alertView];
    [alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0 * scale);
        make.top.mas_equalTo(buzhuButton.mas_top).offset(300 * scale);
        make.width.height.mas_equalTo(alertView.frame.size.width);
    }];
    
    ChooseTypeButton * alertButton = [ChooseTypeButton buttonWithType:UIButtonTypeCustom];
    alertButton.tag = 14;
    alertButton.alpha = .5f;
//    [alertButton setTitle:DDLocalizedString(@"Reminder") forState:UIControlStateNormal];
    alertButton.frame = CGRectMake(0, 0, 400 * scale, 400 * scale);
    [alertButton setBackgroundImage:[UIImage imageNamed:@"PDButton"] forState:UIControlStateNormal];
    [alertButton setImage:[UIImage imageNamed:@"PDTixing"] forState:UIControlStateNormal];
    [alertButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 25 * scale, 0)];
    [self.view addSubview:alertButton];
    [alertButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0 * scale);
        make.top.mas_equalTo(buzhuButton.mas_top).offset(300 * scale);
        make.width.height.mas_equalTo(alertButton.frame.size.width);
    }];
    [alertButton addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * alertLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0xffffff) alignment:NSTextAlignmentCenter];
    alertLabel.text = DDLocalizedString(@"Reminder");
    [alertButton addSubview:alertLabel];
    [alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(alertButton);
        make.bottom.mas_equalTo(alertButton.mas_bottom).offset(-5 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    UIView * ziwoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400 * scale, 400 * scale)];
    [self.view addSubview:ziwoView];
    [ziwoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(150 * scale);
        make.top.mas_equalTo(buzhuButton.mas_bottom).offset(300 * scale);
        make.width.height.mas_equalTo(ziwoView.frame.size.width);
    }];
    
    ChooseTypeButton * ziwoButton = [ChooseTypeButton buttonWithType:UIButtonTypeCustom];
    ziwoButton.tag = 15;
    ziwoButton.alpha = .5f;
//    [ziwoButton setTitle:DDLocalizedString(@"My") forState:UIControlStateNormal];
//    [ziwoButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 25 * scale, 0)];
    [ziwoButton setBackgroundImage:[UIImage imageNamed:@"PDButton"] forState:UIControlStateNormal];
    [ziwoButton setImage:[UIImage imageNamed:@"PDWode"] forState:UIControlStateNormal];
    [ziwoButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 25 * scale, 0)];
    ziwoButton.frame = CGRectMake(0, 0, 400 * scale, 400 * scale);
    [self.view addSubview:ziwoButton];
    [ziwoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(150 * scale);
        make.top.mas_equalTo(buzhuButton.mas_bottom).offset(300 * scale);
        make.width.height.mas_equalTo(ziwoButton.frame.size.width);
    }];
    [ziwoButton addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * ziwoLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0xffffff) alignment:NSTextAlignmentCenter];
    ziwoLabel.text = DDLocalizedString(@"My");
    [ziwoButton addSubview:ziwoLabel];
    [ziwoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ziwoButton);
        make.bottom.mas_equalTo(ziwoButton.mas_bottom).offset(-5 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    UIView * otherView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300 * scale, 300 * scale)];
    [self.view addSubview:otherView];
    [otherView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.top.mas_equalTo(myButton.mas_bottom).offset(170 * scale);
        make.width.height.mas_equalTo(otherView.frame.size.width);
    }];
    
    ChooseTypeButton * otherButton = [ChooseTypeButton buttonWithType:UIButtonTypeCustom];
    otherButton.tag = 13;
    otherButton.alpha = .5f;
//    [otherButton setTitle:DDLocalizedString(@"Other") forState:UIControlStateNormal];
//    [otherButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 25 * scale, 0)];
    [otherButton setBackgroundImage:[UIImage imageNamed:@"PDButton"] forState:UIControlStateNormal];
    [otherButton setImage:[UIImage imageNamed:@"PDQita"] forState:UIControlStateNormal];
    [otherButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 25 * scale, 0)];
    otherButton.frame = CGRectMake(0, 0, 300 * scale, 300 * scale);
    [self.view addSubview:otherButton];
    [otherButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.top.mas_equalTo(myButton.mas_bottom).offset(170 * scale);
        make.width.height.mas_equalTo(otherButton.frame.size.width);
    }];
    [otherButton addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * otherLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0xffffff) alignment:NSTextAlignmentCenter];
    otherLabel.text = DDLocalizedString(@"Other");
    [otherButton addSubview:otherLabel];
    [otherLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(otherButton);
        make.bottom.mas_equalTo(otherButton.mas_bottom).offset(0 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    UIView * wyyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400 * scale, 400 * scale)];
    [self.view addSubview:wyyView];
    [wyyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-120 * scale);
        make.top.mas_equalTo(buzhuButton.mas_bottom).offset(230 * scale);
        make.width.height.mas_equalTo(wyyView.frame.size.width);
    }];
    
    ChooseTypeButton * wyyButton = [ChooseTypeButton buttonWithType:UIButtonTypeCustom];
    wyyButton.tag = 16;
    wyyButton.alpha = .5f;
//    [wyyButton setTitle:DDLocalizedString(@"D") forState:UIControlStateNormal];
//    [wyyButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 25 * scale, 0)];
    [wyyButton setBackgroundImage:[UIImage imageNamed:@"PDButton"] forState:UIControlStateNormal];
    [wyyButton setImage:[UIImage imageNamed:@"PDZuju"] forState:UIControlStateNormal];
    [wyyButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 25 * scale, 0)];
    wyyButton.frame = CGRectMake(0, 0, 400 * scale, 400 * scale);
    [self.view addSubview:wyyButton];
    [wyyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-120 * scale);
        make.top.mas_equalTo(buzhuButton.mas_bottom).offset(230 * scale);
        make.width.height.mas_equalTo(wyyView.frame.size.width);
    }];
    [wyyButton addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * wyyLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0xffffff) alignment:NSTextAlignmentCenter];
    wyyLabel.text = DDLocalizedString(@"D");
    [wyyButton addSubview:wyyLabel];
    [wyyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(wyyButton);
        make.bottom.mas_equalTo(wyyButton.mas_bottom).offset(-5 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    UIView * allView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400 * scale, 400 * scale)];
    [self.view addSubview:allView];
    [allView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(340 * scale);
        make.top.mas_equalTo(myButton.mas_bottom).offset(60 * scale);
        make.width.height.mas_equalTo(allView.frame.size.width);
    }];
    
    ChooseTypeButton * allButton = [ChooseTypeButton buttonWithType:UIButtonTypeCustom];
    allButton.tag = 17;
    allButton.alpha = .5f;
//    [allButton setTitle:DDLocalizedString(@"All") forState:UIControlStateNormal];
//    [allButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 25 * scale, 0)];
    [allButton setBackgroundImage:[UIImage imageNamed:@"PDButton"] forState:UIControlStateNormal];
    [allButton setImage:[UIImage imageNamed:@"PDQuanbu"] forState:UIControlStateNormal];
    [allButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 25 * scale, 0)];
    allButton.frame = CGRectMake(0, 0, 400 * scale, 400 * scale);
    [self.view addSubview:allButton];
    [allButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(340 * scale);
        make.top.mas_equalTo(myButton.mas_bottom).offset(60 * scale);
        make.width.height.mas_equalTo(allView.frame.size.width);
    }];
    [allButton addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * allLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0xffffff) alignment:NSTextAlignmentCenter];
    allLabel.text = DDLocalizedString(@"All");
    [allButton addSubview:allLabel];
    [allLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(allButton);
        make.bottom.mas_equalTo(allButton.mas_bottom).offset(-5 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    self.currentImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"currentPD"]];
    [self.view addSubview:self.currentImageView];
    
    if (self.sourceType == 6) {
        otherButton.alpha = 1.f;
        [otherButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        [self.currentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(otherButton);
            make.bottom.mas_equalTo(otherButton.mas_top);
            make.width.mas_equalTo(270 * scale);
            make.height.mas_equalTo(100 * scale);
        }];
    }else if (self.sourceType == 7){
        myButton.alpha = 1.f;
        [myButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        [self.currentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(myButton);
            make.bottom.mas_equalTo(myButton.mas_top).offset(40 * scale);
            make.width.mas_equalTo(270 * scale);
            make.height.mas_equalTo(100 * scale);
        }];
    }else if (self.sourceType == 8){
        buzhuButton.alpha = 1.f;
        [buzhuButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        [self.currentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(buzhuButton);
            make.bottom.mas_equalTo(buzhuButton.mas_top).offset(40 * scale);
            make.width.mas_equalTo(270 * scale);
            make.height.mas_equalTo(100 * scale);
        }];
    }else if (self.sourceType == 10){
        alertButton.alpha = 1.f;
        [alertButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        [self.currentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(alertButton);
            make.bottom.mas_equalTo(alertButton.mas_top).offset(40 * scale);
            make.width.mas_equalTo(270 * scale);
            make.height.mas_equalTo(100 * scale);
        }];
    }else if (self.sourceType == 1) {
        ziwoButton.alpha = 1.f;
        [ziwoButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        [self.currentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(ziwoButton);
            make.bottom.mas_equalTo(ziwoButton.mas_top).offset(40 * scale);
            make.width.mas_equalTo(270 * scale);
            make.height.mas_equalTo(100 * scale);
        }];
    }else if (self.sourceType == 666) {
        wyyButton.alpha = 1.f;
        [wyyButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        [self.currentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(wyyButton);
            make.bottom.mas_equalTo(wyyButton.mas_top).offset(40 * scale);
            make.width.mas_equalTo(270 * scale);
            make.height.mas_equalTo(100 * scale);
        }];
    }else if (self.sourceType == 11) {
        allButton.alpha = 1.f;
        [allButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        [self.currentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(allButton);
            make.bottom.mas_equalTo(allButton.mas_top).offset(40 * scale);
            make.width.mas_equalTo(270 * scale);
            make.height.mas_equalTo(100 * scale);
        }];
    }
    
    UILabel * tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    tipLabel.textColor = [UIColorFromRGB(0xffffff) colorWithAlphaComponent:.5f];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.text = DDLocalizedString(@"Go to a channel");
    tipLabel.font = kPingFangRegular(36 * scale);
    [self.view addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-150 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    UIButton * backButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [backButton setImage:[UIImage imageNamed:@"contentClose"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(35 * scale);
        make.top.mas_equalTo(70 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
}

- (void)backButtonDidClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)buttonDidClicked:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(typeDidChooseComplete:)]) {
        [self.delegate typeDidChooseComplete:button.tag];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[DDBackWidow shareWindow] hidden];
    });
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
