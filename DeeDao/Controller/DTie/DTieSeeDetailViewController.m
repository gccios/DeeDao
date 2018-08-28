//
//  DTieSeeDetailViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/13.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieSeeDetailViewController.h"
#import "DDTool.h"
#import "MBProgressHUD+DDHUD.h"
#import "GetWXAccessTokenRequest.h"
#import "WeChatManager.h"
#import <UIImageView+WebCache.h>
#import "GCCScreenImage.h"

@interface DTieSeeDetailViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, strong) UIView * resultView;

@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UIView * shareView;

@end

@implementation DTieSeeDetailViewController

- (instancetype)initWithModel:(DTieModel *)model shareImage:(UIImage *)image
{
    if (self = [super init]) {
        self.model = model;
        self.image = image;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createViews];
    
    [self createTopView];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    self.resultView = [[UIView alloc] init];
    self.resultView.backgroundColor = [UIColor whiteColor];
    self.resultView.frame = CGRectMake(0, 0, kMainBoundsWidth, 1730 * scale);
    
    UILabel * topTitle = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentCenter];
    topTitle.text = @"我的D帖粉丝遍布...";
    [self.resultView addSubview:topTitle];
    [topTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(160 * scale);
    }];
    
    UIView * BGView = [[UIView alloc] initWithFrame:CGRectZero];
    BGView.backgroundColor = [UIColor whiteColor];
    [self.resultView addSubview:BGView];
    [BGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(160 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(BGView.mas_width);
    }];
    BGView.layer.cornerRadius = 24 * scale;
    BGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    BGView.layer.shadowOpacity = .3f;
    BGView.layer.shadowRadius = 12 * scale;
    BGView.layer.shadowOffset = CGSizeMake(0, 6 * scale);
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [imageView setImage:self.image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.resultView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(160 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(imageView.mas_width);
    }];
    imageView.layer.cornerRadius = 24 * scale;
    imageView.clipsToBounds = YES;
    
    UIImageView * letterImageview = [[UIImageView alloc] init];
    [letterImageview setImage:[UIImage imageNamed:@"letterLogo"]];
    [imageView addSubview:letterImageview];
    [letterImageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.width.mas_equalTo(168 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    
    UIView * logoBGView = [[UIView alloc] initWithFrame:CGRectZero];
    logoBGView.backgroundColor = [UIColor whiteColor];
    [self.resultView addSubview:logoBGView];
    [logoBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).offset(-132 * scale);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(264 * scale);
    }];
    logoBGView.layer.cornerRadius = 132 * scale;
    logoBGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    logoBGView.layer.shadowOpacity = .5f;
    logoBGView.layer.shadowRadius = 24 * scale;
    logoBGView.layer.shadowOffset = CGSizeMake(0, 12 * scale);
    
    self.logoImageView = [[UIImageView alloc] init];
    [logoBGView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.height.mas_equalTo(220 * scale);
    }];
    self.logoImageView.layer.cornerRadius = 80 * scale;
    self.logoImageView.clipsToBounds = YES;
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = kPingFangRegular(36 * scale);
    label.textColor = UIColorFromRGB(0x333333);
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 3;
    label.text = [NSString stringWithFormat:@"%@\n%@\n长按识别小程序，浏览D贴内容及位置信息", self.model.postSummary, [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.model.updateTime]];
    [self.resultView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.logoImageView.mas_bottom).offset(80 * scale);
    }];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.resultView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(120 * scale);
        make.bottom.mas_equalTo(-119 * scale);
        make.right.mas_equalTo(-120 * scale);
        make.height.mas_equalTo(3 * scale);
    }];
    
    UILabel * tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    tipLabel.backgroundColor = [UIColor whiteColor];
    tipLabel.font = kPingFangRegular(36 * scale);
    tipLabel.numberOfLines = 2;
    tipLabel.textColor = UIColorFromRGB(0xCCCCCC);
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.text = @"www.deedao.com\nDeeDao地到";
    [self.resultView addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(lineView);
        make.width.mas_equalTo(420 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:[UIApplication sharedApplication].keyWindow];
    
    GetWXAccessTokenRequest * request = [[GetWXAccessTokenRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSDictionary *dict = [response objectForKey:@"data"];
            if (KIsDictionary(dict)) {
                [WeChatManager shareManager].miniProgramToken = [dict objectForKey:@"access_token"];
            }
        }
        
        NSInteger postID = self.model.cid;
        if (postID == 0) {
            postID = self.model.postId;
        }
        
        [[WeChatManager shareManager] getMiniProgromCodeWithPostID:postID handle:^(UIImage *image) {
            [hud hideAnimated:YES];
            if (image) {
                [self.logoImageView setImage:image];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
                [MBProgressHUD showTextHUDWithText:@"信息获取失败" inView:[UIApplication sharedApplication].keyWindow];
            }
        }];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.navigationController popViewControllerAnimated:YES];
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"信息获取失败" inView:[UIApplication sharedApplication].keyWindow];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [self.navigationController popViewControllerAnimated:YES];
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:[UIApplication sharedApplication].keyWindow];
        
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.rowHeight = .1 * scale;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = self.resultView;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    [self.view addSubview:self.shareView];
    [self.shareView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(kMainBoundsWidth / 4.f);
    }];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kMainBoundsWidth / 4.f, 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
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
    titleLabel.text = @"阅读地图热力图";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView *)shareView
{
    if (!_shareView) {
        _shareView = [[UIView alloc] initWithFrame:CGRectZero];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:_shareView action:@selector(removeFromSuperview)];
        [_shareView addGestureRecognizer:tap];
        
        NSArray * imageNames;
        NSArray * titles;
        NSInteger startTag = 10;
        
        BOOL isInstallWX = [WXApi isWXAppInstalled];
        
        if (isInstallWX) {
            imageNames = @[@"sharepengyouquan", @"shareweixin", @"saveToPhone"];
            titles = @[@"微信朋友圈", @"微信好友或群", @"保存到手机"];
            startTag = 10;
        }else {
            imageNames = @[@"saveToPhone"];
            titles = @[@"保存到手机"];
            startTag = 12;
        }
        
        CGFloat width = kMainBoundsWidth / imageNames.count;
        CGFloat height = kMainBoundsWidth / 4.f;
        if (KIsiPhoneX) {
            height += 38.f;
        }
        CGFloat scale = kMainBoundsWidth / 1080.f;
        for (NSInteger i = 0; i < imageNames.count; i++) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.8f];
            button.tag = startTag + i;
            [button addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_shareView addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(i * width);
                make.height.mas_equalTo(height);
                make.bottom.mas_equalTo(0);
                make.width.mas_equalTo(width);
            }];
            
            UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
            [button addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(0);
                make.top.mas_equalTo(50 * scale);
                make.width.height.mas_equalTo(96 * scale);
            }];
            
            UILabel * label = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentCenter];
            label.text = [titles objectAtIndex:i];
            [button addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.mas_equalTo(0);
                make.height.mas_equalTo(45 * scale);
                make.top.mas_equalTo(imageView.mas_bottom).offset(20 * scale);
            }];
        }
    }
    return _shareView;
}

- (void)buttonDidClicked:(UIButton *)button
{
    UIImage * shareImage = [GCCScreenImage screenView:self.resultView];
    if (button.tag == 10) {
        
        [[WeChatManager shareManager] shareImage:shareImage];
        
    }else if (button.tag == 11){
        
        [[WeChatManager shareManager] shareFriendImage:shareImage];
        
    }else{
        
        [DDTool userLibraryAuthorizationStatusWithSuccess:^{
            
            [DDTool saveImageInSystemPhoto:shareImage];
        } failure:^{
            [MBProgressHUD showTextHUDWithText:@"没有相册访问权限" inView:[UIApplication sharedApplication].keyWindow];
        }];
        
    }
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
