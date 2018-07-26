//
//  DDMineViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/10.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDMineViewController.h"
#import "MineHeaderView.h"
#import "MainTableViewCell.h"
#import "MineInfoViewController.h"
#import "MYWalletViewController.h"
#import "AchievementViewController.h"
#import "DDSystemViewController.h"
#import "DDFriendViewController.h"
#import "DDPrivateViewController.h"
#import "BloggerLinkViewController.h"
#import "UserManager.h"
#import "WeChatManager.h"
#import "DTieSingleImageShareView.h"
#import "MBProgressHUD+DDHUD.h"

@interface DDMineViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) UIView * shareView;

@end

@implementation DDMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createDataSource];
    [self createViews];
}

- (void)createDataSource
{
    self.dataSource = [NSMutableArray new];
    NSArray * typeArray = @[[[MineMenuModel alloc] initWithType:MineMenuType_Address],
                            [[MineMenuModel alloc] initWithType:MineMenuType_Private]];
    
    if ([UserManager shareManager].user.bloggerFlg == 1) {
        typeArray = @[[[MineMenuModel alloc] initWithType:MineMenuType_Address],
                      [[MineMenuModel alloc] initWithType:MineMenuType_Private],
                      [[MineMenuModel alloc] initWithType:MineMenuType_Blogger]];
    }
    
    NSArray * sysArray = @[[[MineMenuModel alloc] initWithType:MineMenuType_System]];
    [self.dataSource addObject:typeArray];
    [self.dataSource addObject:sysArray];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.tableView registerClass:[MainTableViewCell class] forCellReuseIdentifier:@"MainTableViewCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    MineHeaderView * headerView = [[MineHeaderView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 288 * scale)];
    self.tableView.tableHeaderView = headerView;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.tableView.contentInset = UIEdgeInsetsMake(60 * scale, 0, 0, 0);
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mineInfoDidClcked)];
    tap.numberOfTapsRequired = 1;
    [headerView addGestureRecognizer:tap];
    
    BOOL isInstallWX = [WXApi isWXAppInstalled];
    BOOL isBozhu = NO;
    if ([UserManager shareManager].user.bloggerFlg == 1) {
        isBozhu = YES;
    }
    
    if (isInstallWX || isBozhu) {
        
        UIButton * BGButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [headerView addSubview:BGButton];
        [BGButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.mas_equalTo(-50 * scale);
            make.width.height.mas_equalTo(110 * scale);
        }];
        [BGButton addTarget:self action:@selector(shareButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView * shareImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [shareImage setImage:[UIImage imageNamed:@"shareColor"]];
        [BGButton addSubview:shareImage];
        [shareImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(0);
            make.width.height.mas_equalTo(55 * scale);
        }];
    }
    
    [self createTopViews];
}

- (void)shareButtonDidClicked
{
    [[UIApplication sharedApplication].keyWindow addSubview:self.shareView];
}

- (void)createTopViews
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
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    titleLabel.text = @"个人中心";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60.5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
}

- (void)mineInfoDidClcked
{
    MineInfoViewController * info = [[MineInfoViewController alloc] init];
    [self presentViewController:info animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSArray * data = [self.dataSource objectAtIndex:indexPath.section];
    MineMenuModel * model = [data objectAtIndex:indexPath.row];
    switch (model.type) {
        case MineMenuType_Wallet:
        {
            MYWalletViewController * wallet = [[MYWalletViewController alloc] init];
            [self.navigationController pushViewController:wallet animated:YES];
        }
            break;
            
        case MineMenuType_Achievement:
        {
            AchievementViewController * achievement = [[AchievementViewController alloc] init];
            [self.navigationController pushViewController:achievement animated:YES];
        }
            break;
            
        case MineMenuType_System:
        {
            DDSystemViewController * system = [[DDSystemViewController alloc] init];
            [self.navigationController pushViewController:system animated:YES];
        }
            break;
            
        case MineMenuType_Address:
        {
            DDFriendViewController * friend = [[DDFriendViewController alloc] init];
            [self.navigationController pushViewController:friend animated:YES];
        }
            break;
            
        case MineMenuType_Private:
        {
            DDPrivateViewController * private = [[DDPrivateViewController alloc] init];
            [self.navigationController pushViewController:private animated:YES];
        }
            break;
            
        case MineMenuType_Blogger:
        {
            BloggerLinkViewController * blogger = [[BloggerLinkViewController alloc] init];
            [self.navigationController pushViewController:blogger animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * data = [self.dataSource objectAtIndex:section];
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MainTableViewCell" forIndexPath:indexPath];
    
    NSArray * data = [self.dataSource objectAtIndex:indexPath.section];
    MineMenuModel * model = [data objectAtIndex:indexPath.row];
    [cell configWithMenuModel:model];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    return 144 * scale;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    return 48 * scale;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return .1;
}

- (UIView *)shareView
{
    if (!_shareView) {
        _shareView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _shareView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:_shareView action:@selector(removeFromSuperview)];
        [_shareView addGestureRecognizer:tap];
        
        NSArray * imageNames;
        NSArray * titles;
        NSInteger startTag = 10;
        
        BOOL isInstallWX = [WXApi isWXAppInstalled];
        BOOL isBozhu = NO;;
        if ([UserManager shareManager].user.bloggerFlg == 1) {
            isBozhu = YES;
        }
        
        if (isBozhu && isInstallWX) {
            imageNames = @[@"sharepengyouquan", @"shareweixin", @"sharebozhu"];
            titles = @[@"微信朋友圈", @"微信好友或群", @"地到博主码"];
            startTag = 10;
        }else if (isBozhu && !isInstallWX) {
            imageNames = @[@"sharebozhu"];
            titles = @[@"地到博主码"];
            startTag = 12;
        }else if (!isBozhu && isInstallWX) {
            imageNames = @[@"sharepengyouquan", @"shareweixin"];
            titles = @[@"微信朋友圈", @"微信好友或群"];
            startTag = 10;
        }
        
        CGFloat width = kMainBoundsWidth / imageNames.count;
        CGFloat height = kMainBoundsWidth / 4.f;
        if (KIsiPhoneX) {
            height += 38.f;
        }
        CGFloat scale = kMainBoundsWidth / 1080.f;
        for (NSInteger i = 0; i < imageNames.count; i++) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor whiteColor];
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
    [self.shareView removeFromSuperview];
    if (button.tag == 10) {
        
        DTieSingleImageShareView * shareView = [[DTieSingleImageShareView alloc] initWithModel:[UserManager shareManager].user];
        [self.view insertSubview:shareView atIndex:0];
        [shareView startShare];
        
    }else if (button.tag == 11){
        
        [[WeChatManager shareManager] shareMiniProgramWithUser:[UserManager shareManager].user];
        
    }else{
        
        NSString * urlLink = [NSString stringWithFormat:@"pages/user/user?authorId=%lduserIs%ld", [UserManager shareManager].user.cid, [UserManager shareManager].user.cid];
        
        NSString * text = [NSString stringWithFormat:@"博主名片链接\n%@\n\n", urlLink];
        
        NSError * error = nil;
        NSFileManager * manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:DDBloggerLinkPath]) {
            NSFileHandle * writeHandle = [NSFileHandle fileHandleForWritingAtPath:DDBloggerLinkPath];
            if (writeHandle) {
                [writeHandle seekToEndOfFile];
                NSData * linkData = [text dataUsingEncoding:NSUTF8StringEncoding];
                [writeHandle writeData:linkData];
                [writeHandle closeFile];
            }else{
                error = [NSError new];
            }
        }else{
            [text writeToFile:DDBloggerLinkPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        }
        
        if (error) {
            [MBProgressHUD showTextHUDWithText:@"获取失败" inView:self.view];
        }else{
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = urlLink;
            [MBProgressHUD showTextHUDWithText:@"已复制到粘贴板和博主链接" inView:self.view];
        }
        
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
