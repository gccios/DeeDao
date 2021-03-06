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
#import "GuidePageView.h"
#import "UIViewController+LGSideMenuController.h"
#import "DDNotificationViewController.h"
#import "NewAchievementViewController.h"
#import "ConverUtil.h"
#import "DDMailViewController.h"
#import "DDFriendCardViewController.h"
#import "DDManagerViewController.h"
#import "UserInfoViewController.h"
#import "DDJubaoManagerController.h"

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
    self.view.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    self.dataSource = [NSMutableArray new];
    NSArray * typeArray = @[[[MineMenuModel alloc] initWithType:MineMenuType_MYHome],
//                            [[MineMenuModel alloc] initWithType:MineMenuType_shareMingPian],
//                            [[MineMenuModel alloc] initWithType:MineMenuType_FriendCard],
//                            [[MineMenuModel alloc] initWithType:MineMenuType_Address],
                            [[MineMenuModel alloc] initWithType:MineMenuType_hudongMessage],
//                            [[MineMenuModel alloc] initWithType:MineMenuType_Private],
                            [[MineMenuModel alloc] initWithType:MineMenuType_AlertList],
                            [[MineMenuModel alloc] initWithType:MineMenuType_System]];
    
    if ([UserManager shareManager].user.bloggerFlg == 1) {
        typeArray = @[[[MineMenuModel alloc] initWithType:MineMenuType_MYHome],
//                      [[MineMenuModel alloc] initWithType:MineMenuType_shareMingPian],
//                      [[MineMenuModel alloc] initWithType:MineMenuType_FriendCard],
//                      [[MineMenuModel alloc] initWithType:MineMenuType_Address],
                      [[MineMenuModel alloc] initWithType:MineMenuType_hudongMessage],
//                      [[MineMenuModel alloc] initWithType:MineMenuType_Private],
                      [[MineMenuModel alloc] initWithType:MineMenuType_Blogger],
                      [[MineMenuModel alloc] initWithType:MineMenuType_AlertList],
                      [[MineMenuModel alloc] initWithType:MineMenuType_System]];
    }
    
    [self.dataSource addObjectsFromArray:typeArray];
    
    if ([[UserManager shareManager].user.signature isEqualToString:@"S"]) {
        [self.dataSource addObject:[[MineMenuModel alloc] initWithType:MineMenuType_SystemMnager]];
        [self.dataSource addObject:[[MineMenuModel alloc] initWithType:MineMenuType_JubaoMnager]];
    }
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.tableView registerClass:[MainTableViewCell class] forCellReuseIdentifier:@"MainTableViewCell"];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    
    MineHeaderView * headerView = [[MineHeaderView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 600 * scale)];
    [self.view addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(600 * scale);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(headerView.mas_bottom);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.tableView.contentInset = UIEdgeInsetsMake(60 * scale, 0, 0, 0);
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mineInfoDidClcked)];
    tap.numberOfTapsRequired = 1;
    [headerView addGestureRecognizer:tap];
    
//    [self createTopViews];
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
    
//    NSArray * data = [self.dataSource objectAtIndex:indexPath.section];
    MineMenuModel * model = [self.dataSource objectAtIndex:indexPath.row];
    
    UINavigationController * nav = (UINavigationController *)self.sideMenuController.rootViewController;
    
    switch (model.type) {
        case MineMenuType_MYHome:
        {
            [self hideLeftViewAnimated:nil];
            UserInfoViewController * info = [[UserInfoViewController alloc] initWithUserId:[UserManager shareManager].user.cid];
            [nav pushViewController:info animated:YES];
        }
            break;
            
        case MineMenuType_Wallet:
        {
            [self hideLeftViewAnimated:nil];
            MYWalletViewController * wallet = [[MYWalletViewController alloc] init];
            [nav pushViewController:wallet animated:YES];
        }
            break;
            
        case MineMenuType_Achievement:
        {
            [self hideLeftViewAnimated:nil];
            NewAchievementViewController * achievement = [[NewAchievementViewController alloc] init];
            [nav pushViewController:achievement animated:YES];
        }
            break;
            
        case MineMenuType_System:
        {
            [self hideLeftViewAnimated:nil];
            DDSystemViewController * system = [[DDSystemViewController alloc] init];
            [nav pushViewController:system animated:YES];
        }
            break;
            
        case MineMenuType_Address:
        {
            [self hideLeftViewAnimated:nil];
            DDFriendViewController * friend = [[DDFriendViewController alloc] init];
            [nav pushViewController:friend animated:YES];
        }
            break;
            
        case MineMenuType_Private:
        {
            [self hideLeftViewAnimated:nil];
            DDPrivateViewController * private = [[DDPrivateViewController alloc] init];
            [nav pushViewController:private animated:YES];
        }
            break;
            
        case MineMenuType_Blogger:
        {
            [self hideLeftViewAnimated:nil];
            BloggerLinkViewController * blogger = [[BloggerLinkViewController alloc] init];
            [nav pushViewController:blogger animated:YES];
        }
            break;
            
        case MineMenuType_SystemMnager:
        {
            [self hideLeftViewAnimated:nil];
            DDManagerViewController * manager = [[DDManagerViewController alloc] init];
            [nav pushViewController:manager animated:YES];
        }
            break;
            
        case MineMenuType_FriendCard:
        {
            [self hideLeftViewAnimated:nil];
            DDFriendCardViewController * card = [[DDFriendCardViewController alloc] init];
            [nav pushViewController:card animated:YES];
        }
            break;
            
        case MineMenuType_HandleGuide:
        {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:DDLocalizedString(@"Information") message:@"确定要重新阅读操作提示吗？" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * action1 = [UIAlertAction actionWithTitle:DDLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            UIAlertAction * action2 = [UIAlertAction actionWithTitle:DDLocalizedString(@"Yes") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                UITabBarController * tabbar = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
////                [self.navigationController popToRootViewControllerAnimated:NO];
//                [tabbar setSelectedIndex:0];
//                GuidePageView * guide = [[GuidePageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//                [[UIApplication sharedApplication].keyWindow addSubview:guide];
            }];
            
            [alert addAction:action1];
            [alert addAction:action2];
            [self presentViewController:alert animated:YES completion:nil];
        }
            break;
            
        case MineMenuType_AlertList:
        {
            [self hideLeftViewAnimated:nil];
            DDNotificationViewController * notification = [[DDNotificationViewController alloc] initWithNotificationID:0];
            [nav pushViewController:notification animated:YES];
        }
            break;
            
        case MineMenuType_shareMingPian:
        {
            [self shareButtonDidClicked];
        }
            break;
            
        case MineMenuType_hudongMessage:
        {
            [self hideLeftViewAnimated:nil];
            DDMailViewController * mail = [[DDMailViewController alloc] init];
            [nav pushViewController:mail animated:YES];
            
        }
            break;
            
        case MineMenuType_JubaoMnager:
        {
            [self hideLeftViewAnimated:nil];
            DDJubaoManagerController * jubao = [[DDJubaoManagerController alloc] init];
            [nav pushViewController:jubao animated:YES];
        }
            break;
            
        default:
            break;
    }
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return self.dataSource.count;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSArray * data = [self.dataSource objectAtIndex:section];
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MainTableViewCell" forIndexPath:indexPath];
    
//    NSArray * data = [self.dataSource objectAtIndex:indexPath.section];
    MineMenuModel * model = [self.dataSource objectAtIndex:indexPath.row];
    [cell configWithMenuModel:model];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    return 144 * scale;
}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    CGFloat scale = kMainBoundsWidth / 1080.f;
//    return 48 * scale;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return .1;
//}

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
            imageNames = @[@"shareweixin", @"shareKouling", @"sharebozhu"];
            titles = @[@"微信好友", @"好友口令", @"地到博主码"];
            startTag = 11;
        }else if (isBozhu && !isInstallWX) {
            imageNames = @[@"shareKouling", @"sharebozhu"];
            titles = @[@"好友口令", @"地到博主码"];
            startTag = 12;
        }else if (!isBozhu && isInstallWX) {
            imageNames = @[@"shareweixin",  @"shareKouling"];
            titles = @[@"微信好友", @"好友口令"];
            startTag = 11;
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
        [[UIApplication sharedApplication].keyWindow insertSubview:shareView atIndex:0];
        [shareView startShare];
        
    }else if (button.tag == 11){
        
        [[WeChatManager shareManager] shareMiniProgramWithUser:[UserManager shareManager].user];
        
    }else if(button.tag == 12) {
        
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 1000;
        NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
        
        NSString * userID = [NSString stringWithFormat:@"%ld", [UserManager shareManager].user.cid];
        
        NSString * string = [NSString stringWithFormat:@"%@+%@", timeString, userID];
        NSString * result = [ConverUtil base64EncodeString:string];
        
        NSString * pasteString = [NSString stringWithFormat:@"【DeeDao地到】%@#复制此消息，打开DeeDao地到查看好友名片", result];
        
        UIPasteboard * pasteBoard = [UIPasteboard generalPasteboard];
        pasteBoard.string = pasteString;
        [MBProgressHUD showTextHUDWithText:@"口令复制成功，快去发送给好友吧" inView:[UIApplication sharedApplication].keyWindow];
        
    }else{
        
        NSString * urlLink = [NSString stringWithFormat:@"pages/user/user?authorId=%lduserIs%ldisBlogger", [UserManager shareManager].user.cid, [UserManager shareManager].user.cid];
        
        NSString * text = [NSString stringWithFormat:@"博主名片链接\n请把以下文字和链接放置到您的微信公众号博文里：点击这里，一键在 Deedao 小程序（和 APP）里关注我。 不再错过我的优质生活推荐😃\n%@\n\n", urlLink];
        
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
