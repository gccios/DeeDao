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
    
    self.view.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    UIView * buzhuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400 * scale, 400 * scale)];
    buzhuView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.view addSubview:buzhuView];
    [buzhuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(100 * scale);
        make.centerY.mas_equalTo(-300 * scale);
        make.width.height.mas_equalTo(buzhuView.frame.size.width);
    }];
    buzhuView.layer.cornerRadius = 200 * scale;
    buzhuView.layer.shadowColor = UIColorFromRGB(0xDB6283).CGColor;
    buzhuView.layer.shadowOpacity = .3f;
    buzhuView.layer.shadowRadius = 18 * scale;
    buzhuView.layer.shadowOffset = CGSizeMake(0, 9 * scale);
    
    ChooseTypeButton * buzhuButton = [ChooseTypeButton buttonWithType:UIButtonTypeCustom];
    buzhuButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    buzhuButton.layer.borderWidth = 3 * scale;
    buzhuButton.tag = 12;
    [buzhuButton setTitleColor:UIColorFromRGB(0xDB6283) forState:UIControlStateNormal];
    [buzhuButton setTitle:@"博主" forState:UIControlStateNormal];
    [buzhuButton setBackgroundColor:[UIColorFromRGB(0xdb6283) colorWithAlphaComponent:.1f]];
    buzhuButton.frame = CGRectMake(0, 0, 400 * scale, 400 * scale);
    [DDViewFactoryTool cornerRadius:200 * scale withView:buzhuButton];
    [self.view addSubview:buzhuButton];
    [buzhuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(100 * scale);
        make.centerY.mas_equalTo(-300 * scale);
        make.width.height.mas_equalTo(buzhuButton.frame.size.width);
    }];
    [buzhuButton addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView * myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220 * scale, 220 * scale)];
    myView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.view addSubview:myView];
    [myView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(buzhuButton.mas_right).offset(60 * scale);
        make.top.mas_equalTo(buzhuButton.mas_top).offset(30 * scale);
        make.width.height.mas_equalTo(myView.frame.size.width);
    }];
    myView.layer.cornerRadius = 110 * scale;
    myView.layer.shadowColor = UIColorFromRGB(0xF38364).CGColor;
    myView.layer.shadowOpacity = .3f;
    myView.layer.shadowRadius = 18 * scale;
    myView.layer.shadowOffset = CGSizeMake(0, 9 * scale);
    
    ChooseTypeButton * myButton = [ChooseTypeButton buttonWithType:UIButtonTypeCustom];
    myButton.layer.borderColor = UIColorFromRGB(0xF38364).CGColor;
    myButton.layer.borderWidth = 3 * scale;
    myButton.tag = 11;
    [myButton setTitleColor:UIColorFromRGB(0xF38364) forState:UIControlStateNormal];
    [myButton setTitle:@"好友" forState:UIControlStateNormal];
    [myButton setBackgroundColor:[UIColorFromRGB(0xF29B83) colorWithAlphaComponent:.1f]];
    myButton.frame = CGRectMake(0, 0, 220 * scale, 220 * scale);
    [DDViewFactoryTool cornerRadius:110 * scale withView:myButton];
    [self.view addSubview:myButton];
    [myButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(buzhuButton.mas_right).offset(60 * scale);
        make.top.mas_equalTo(buzhuButton.mas_top).offset(30 * scale);
        make.width.height.mas_equalTo(myButton.frame.size.width);
    }];
    [myButton addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView * alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300 * scale, 300 * scale)];
    alertView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.view addSubview:alertView];
    [alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.top.mas_equalTo(buzhuButton.mas_top).offset(200 * scale);
        make.width.height.mas_equalTo(alertView.frame.size.width);
    }];
    alertView.layer.cornerRadius = 150 * scale;
    alertView.layer.shadowColor = UIColorFromRGB(0xF38364).CGColor;
    alertView.layer.shadowOpacity = .3f;
    alertView.layer.shadowRadius = 18 * scale;
    alertView.layer.shadowOffset = CGSizeMake(0, 9 * scale);
    
    ChooseTypeButton * alertButton = [ChooseTypeButton buttonWithType:UIButtonTypeCustom];
    alertButton.layer.borderColor = UIColorFromRGB(0xF38364).CGColor;
    alertButton.layer.borderWidth = 3 * scale;
    alertButton.tag = 14;
    [alertButton setTitleColor:UIColorFromRGB(0xF38364) forState:UIControlStateNormal];
    [alertButton setTitle:@"提醒" forState:UIControlStateNormal];
    [alertButton setBackgroundColor:[UIColorFromRGB(0xF29B83) colorWithAlphaComponent:.1f]];
    alertButton.frame = CGRectMake(0, 0, 300 * scale, 300 * scale);
    [DDViewFactoryTool cornerRadius:150 * scale withView:alertButton];
    [self.view addSubview:alertButton];
    [alertButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.top.mas_equalTo(buzhuButton.mas_top).offset(200 * scale);
        make.width.height.mas_equalTo(alertButton.frame.size.width);
    }];
    [alertButton addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView * ziwoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300 * scale, 300 * scale)];
    ziwoView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.view addSubview:ziwoView];
    [ziwoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(200 * scale);
        make.top.mas_equalTo(buzhuButton.mas_bottom).offset(120 * scale);
        make.width.height.mas_equalTo(ziwoView.frame.size.width);
    }];
    ziwoView.layer.cornerRadius = 150 * scale;
    ziwoView.layer.shadowColor = UIColorFromRGB(0xDB6283).CGColor;
    ziwoView.layer.shadowOpacity = .3f;
    ziwoView.layer.shadowRadius = 18 * scale;
    ziwoView.layer.shadowOffset = CGSizeMake(0, 9 * scale);
    
    ChooseTypeButton * ziwoButton = [ChooseTypeButton buttonWithType:UIButtonTypeCustom];
    ziwoButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    ziwoButton.layer.borderWidth = 3 * scale;
    ziwoButton.tag = 15;
    [ziwoButton setTitleColor:UIColorFromRGB(0xDB6283) forState:UIControlStateNormal];
    [ziwoButton setTitle:@"我的" forState:UIControlStateNormal];
    [ziwoButton setBackgroundColor:[UIColorFromRGB(0xdb6283) colorWithAlphaComponent:.1f]];
    ziwoButton.frame = CGRectMake(0, 0, 300 * scale, 300 * scale);
    [DDViewFactoryTool cornerRadius:150 * scale withView:ziwoButton];
    [self.view addSubview:ziwoButton];
    [ziwoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(200 * scale);
        make.top.mas_equalTo(buzhuButton.mas_bottom).offset(120 * scale);
        make.width.height.mas_equalTo(ziwoButton.frame.size.width);
    }];
    [ziwoButton addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView * otherView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220 * scale, 220 * scale)];
    otherView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.view addSubview:otherView];
    [otherView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(450 * scale);
        make.top.mas_equalTo(myButton.mas_bottom).offset(100 * scale);
        make.width.height.mas_equalTo(otherView.frame.size.width);
    }];
    otherView.layer.cornerRadius = 110 * scale;
    otherView.layer.shadowColor = UIColorFromRGB(0x999999).CGColor;
    otherView.layer.shadowOpacity = .3f;
    otherView.layer.shadowRadius = 18 * scale;
    otherView.layer.shadowOffset = CGSizeMake(0, 9 * scale);
    
    ChooseTypeButton * otherButton = [ChooseTypeButton buttonWithType:UIButtonTypeCustom];
    otherButton.layer.borderColor = UIColorFromRGB(0xCCCCCC).CGColor;
    otherButton.layer.borderWidth = 3 * scale;
    otherButton.tag = 13;
    [otherButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
    [otherButton setTitle:@"其他" forState:UIControlStateNormal];
    [otherButton setBackgroundColor:[UIColorFromRGB(0x999999) colorWithAlphaComponent:.1f]];
    otherButton.frame = CGRectMake(0, 0, 220 * scale, 220 * scale);
    [DDViewFactoryTool cornerRadius:110 * scale withView:otherButton];
    [self.view addSubview:otherButton];
    [otherButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(450 * scale);
        make.top.mas_equalTo(myButton.mas_bottom).offset(100 * scale);
        make.width.height.mas_equalTo(otherButton.frame.size.width);
    }];
    [otherButton addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView * wyyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300 * scale, 300 * scale)];
    wyyView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.view addSubview:wyyView];
    [wyyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-200 * scale);
        make.top.mas_equalTo(buzhuButton.mas_bottom).offset(170 * scale);
        make.width.height.mas_equalTo(wyyView.frame.size.width);
    }];
    wyyView.layer.cornerRadius = 150 * scale;
    wyyView.layer.shadowColor = UIColorFromRGB(0xDB6283).CGColor;
    wyyView.layer.shadowOpacity = .3f;
    wyyView.layer.shadowRadius = 18 * scale;
    wyyView.layer.shadowOffset = CGSizeMake(0, 9 * scale);
    
    ChooseTypeButton * wyyButton = [ChooseTypeButton buttonWithType:UIButtonTypeCustom];
    wyyButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    wyyButton.layer.borderWidth = 3 * scale;
    wyyButton.tag = 16;
    [wyyButton setTitleColor:UIColorFromRGB(0xDB6283) forState:UIControlStateNormal];
    [wyyButton setTitle:@"约这" forState:UIControlStateNormal];
    [wyyButton setBackgroundColor:[UIColorFromRGB(0xdb6283) colorWithAlphaComponent:.1f]];
    wyyButton.frame = CGRectMake(0, 0, 300 * scale, 300 * scale);
    [DDViewFactoryTool cornerRadius:150 * scale withView:wyyButton];
    [self.view addSubview:wyyButton];
    [wyyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-200 * scale);
        make.top.mas_equalTo(buzhuButton.mas_bottom).offset(170 * scale);
        make.width.height.mas_equalTo(wyyButton.frame.size.width);
    }];
    [wyyButton addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
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
    }else if (self.sourceType == 1) {
        [ziwoButton setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.currentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(ziwoButton);
            make.bottom.mas_equalTo(ziwoButton.mas_top);
            make.width.mas_equalTo(270 * scale);
            make.height.mas_equalTo(100 * scale);
        }];
    }else if (self.sourceType == 666) {
        [wyyButton setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.currentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(wyyButton);
            make.bottom.mas_equalTo(wyyButton.mas_top);
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
