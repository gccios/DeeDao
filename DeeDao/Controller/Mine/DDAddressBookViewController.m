//
//  DDAddressBookViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/11/7.
//  Copyright © 2018 郭春城. All rights reserved.
//

#import "DDAddressBookViewController.h"
#import "MBProgressHUD+DDHUD.h"
#import <PPGetAddressBook.h>

@interface DDAddressBookViewController ()

@property (nonatomic, strong) UIView * topView;

@end

@implementation DDAddressBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
    [self createTopView];
    
    [[PPAddressBookHandle sharedAddressBookHandle] requestAuthorizationWithSuccessBlock:^{
         [self uploadAddressBook];
    }];
    [self uploadAddressBook];
    [self createDataSource];
}

- (void)uploadAddressBook
{
    [PPGetAddressBook getOriginalAddressBook:^(NSArray<PPPersonModel *> *addressBookArray) {
        
        NSMutableArray * addressBookDictSource = [[NSMutableArray alloc] init];
        for (PPPersonModel * model in addressBookArray) {
            
            for (NSString * mobile in model.mobileArray) {
                NSDictionary * dict = @{@"name" : model.name,
                                        @"mobile" : mobile,
                                        };
                [addressBookDictSource addObject:dict];
            }
            
        }
        NSLog(@"%@", addressBookDictSource);
        
    } authorizationFailure:^{
        [MBProgressHUD showTextHUDWithText:@"获取通讯录失败" inView:self.view];
    }];
}

- (void)createDataSource
{
    
}

- (void)createTopView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.topView = [[UIView alloc] init];
    self.topView.userInteractionEnabled = YES;
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo((220 + kStatusBarHeight) * scale);
    }];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, (220 + kStatusBarHeight) * scale);
    [self.topView.layer addSublayer:gradientLayer];
    
    self.topView.layer.shadowColor = UIColorFromRGB(0xB721FF).CGColor;
    self.topView.layer.shadowOpacity = .24;
    self.topView.layer.shadowOffset = CGSizeMake(0, 4);
    
    UIButton * backButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.bottom.mas_equalTo(-15 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    titleLabel.text = DDLocalizedString(@"Details");
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
    UIButton * addressBookButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xffffff) title:@"同步通讯录"];
    [self.topView addSubview:addressBookButton];
    [addressBookButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(titleLabel);
        make.right.mas_equalTo(-30 * scale);
        make.width.mas_equalTo(350 * scale);
        make.height.mas_equalTo(80 * scale);
    }];
    [addressBookButton addTarget:self action:@selector(uploadAddressBook) forControlEvents:UIControlEventTouchUpOutside];
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
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
