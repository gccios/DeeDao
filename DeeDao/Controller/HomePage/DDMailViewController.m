//
//  DDMailViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/10.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDMailViewController.h"
//#import "MailShareTableViewCell.h"
#import "MailSmallTableViewCell.h"
#import "MailBigTableViewCell.h"
#import "MailDetailViewController.h"
#import "MailMessageRequest.h"
#import "MailUserCardTableViewCell.h"
#import "MBProgressHUD+DDHUD.h"
#import "UserManager.h"
#import "UserInfoViewController.h"
#import "SelectUserCardRequest.h"
#import "UserMailModel.h"
#import <BGUploadRequest.h>
#import <MJRefresh.h>
#import <AFHTTPSessionManager.h>

@interface DDMailViewController () <UITableViewDelegate, UITableViewDataSource, DTieMailDelegate, UserFriendInfoDelegate>

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UIButton * searchButton;
@property (nonatomic, strong) UIButton * messageButton;

@property (nonatomic, strong) UIButton * notificationButton;
@property (nonatomic, strong) UIButton * exchangeButton;
@property (nonatomic, strong) UIButton * userCardButton;

@property (nonatomic, strong) UITableView * notificationTableView;
@property (nonatomic, strong) UITableView * exchangeTableView;
@property (nonatomic, strong) UITableView * userCardTableView;

@property (nonatomic, strong) NSMutableArray * notificationSource;
@property (nonatomic, strong) NSMutableArray * exchangeSource;
@property (nonatomic, strong) NSMutableArray * userCarsSource;

@property (nonatomic, assign) NSInteger notificationStart;
@property (nonatomic, assign) NSInteger notificationSize;
@property (nonatomic, assign) NSInteger exchangeStart;
@property (nonatomic, assign) NSInteger exchangeSize;
@property (nonatomic, assign) NSInteger userCarsStart;
@property (nonatomic, assign) NSInteger userCarsSize;

@property (nonatomic, assign) NSInteger pageIndex;

@property (nonatomic, strong) UserMailModel * lastUserModel;

@end

@implementation DDMailViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.notificationSource = [[NSMutableArray alloc] init];
        self.exchangeSource = [[NSMutableArray alloc] init];
        self.userCarsSource = [[NSMutableArray alloc] init];
        
        [self requestNotificationMailMessage];
        [self requestExchangeMailMessage];
        [self requestUserCardMessage];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self creatViews];
    [self creatTopView];
    self.pageIndex = 1;
    [self reloadPageStatus];
}

- (void)creatViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.notificationTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.notificationTableView.backgroundColor = self.view.backgroundColor;
    self.notificationTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.notificationTableView.rowHeight = 540 * scale;
//    [self.tableView registerClass:[MailShareTableViewCell class] forCellReuseIdentifier:@"MailShareTableViewCell"];
    [self.notificationTableView registerClass:[MailSmallTableViewCell class] forCellReuseIdentifier:@"MailSmallTableViewCell"];
//    [self.notificationTableView registerClass:[MailBigTableViewCell class] forCellReuseIdentifier:@"MailBigTableViewCell"];
    self.notificationTableView.delegate = self;
    self.notificationTableView.dataSource = self;
    [self.view addSubview:self.notificationTableView];
    [self.notificationTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((364 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.notificationTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestNotificationMailMessage)];
    self.notificationTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreNoticationMailMessage)];
    
    UISwipeGestureRecognizer * swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewDidSwipe:)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.notificationTableView addGestureRecognizer:swipe];
    
    self.exchangeTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.exchangeTableView.backgroundColor = self.view.backgroundColor;
    self.exchangeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.exchangeTableView.rowHeight = 540 * scale;
    //    [self.tableView registerClass:[MailShareTableViewCell class] forCellReuseIdentifier:@"MailShareTableViewCell"];
    [self.exchangeTableView registerClass:[MailSmallTableViewCell class] forCellReuseIdentifier:@"MailSmallTableViewCell"];
    //    [self.notificationTableView registerClass:[MailBigTableViewCell class] forCellReuseIdentifier:@"MailBigTableViewCell"];
    self.exchangeTableView.delegate = self;
    self.exchangeTableView.dataSource = self;
    [self.view addSubview:self.exchangeTableView];
    [self.exchangeTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((364 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.exchangeTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestExchangeMailMessage)];
    self.exchangeTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreExchangemailMessage)];
    
    UISwipeGestureRecognizer * swipe2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewDidSwipe:)];
    swipe2.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.exchangeTableView addGestureRecognizer:swipe2];

    
    self.userCardTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.userCardTableView.backgroundColor = self.view.backgroundColor;
    self.userCardTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.userCardTableView.rowHeight = 540 * scale;
    //    [self.tableView registerClass:[MailShareTableViewCell class] forCellReuseIdentifier:@"MailShareTableViewCell"];
    [self.userCardTableView registerClass:[MailUserCardTableViewCell class] forCellReuseIdentifier:@"MailUserCardTableViewCell"];
    //    [self.notificationTableView registerClass:[MailBigTableViewCell class] forCellReuseIdentifier:@"MailBigTableViewCell"];
    self.userCardTableView.delegate = self;
    self.userCardTableView.dataSource = self;
    [self.view addSubview:self.userCardTableView];
    [self.userCardTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((364 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.userCardTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestUserCardMessage)];
    self.userCardTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreUserCardMessage)];
    
    UISwipeGestureRecognizer * swipe3 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewDidSwipe:)];
    swipe3.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.userCardTableView addGestureRecognizer:swipe3];
}

- (void)tableViewDidSwipe:(UISwipeGestureRecognizer *)swipe
{
    if (swipe.view == self.notificationTableView) {
        CGPoint point = [swipe locationInView:self.notificationTableView];
        NSIndexPath * indexPath = [self.notificationTableView indexPathForRowAtPoint:point];
        
        if (indexPath && indexPath.row < self.notificationSource.count) {
            
            MailModel * model = [self.notificationSource objectAtIndex:indexPath.row];
            NSInteger mailId = model.cid;
            [self deleteMailWithID:mailId];
            
            [self.notificationSource removeObjectAtIndex:indexPath.row];
            [self.notificationTableView beginUpdates];
            [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self.notificationTableView endUpdates];
        }
    }else if (swipe.view == self.exchangeTableView) {
        CGPoint point = [swipe locationInView:self.exchangeTableView];
        NSIndexPath * indexPath = [self.exchangeTableView indexPathForRowAtPoint:point];
        
        if (indexPath && indexPath.row < self.exchangeSource.count) {
            
            MailModel * model = [self.exchangeSource objectAtIndex:indexPath.row];
            NSInteger mailId = model.cid;
            [self deleteMailWithID:mailId];
            
            [self.exchangeSource removeObjectAtIndex:indexPath.row];
            [self.exchangeTableView beginUpdates];
            [self.exchangeTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self.exchangeTableView endUpdates];
        }
    }else if (swipe.view == self.userCardTableView) {
        CGPoint point = [swipe locationInView:self.userCardTableView];
        NSIndexPath * indexPath = [self.userCardTableView indexPathForRowAtPoint:point];
        
        if (indexPath && indexPath.row < self.userCarsSource.count) {
            
            UserMailModel * model = [self.userCarsSource objectAtIndex:indexPath.row];
            NSInteger userId = model.cid;
            [self deleteUserWithID:userId];
            
            [self.userCarsSource removeObjectAtIndex:indexPath.row];
            [self.userCardTableView beginUpdates];
            [self.userCardTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self.userCardTableView endUpdates];
        }
    }
}

- (void)deleteMailWithID:(NSInteger)mailId
{
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString * url = [NSString stringWithFormat:@"%@/mailbox/deleteMailMsg", HOSTURL];
    [manager POST:url parameters:@{@"id":@(mailId)} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)deleteUserWithID:(NSInteger)userID
{
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString * url = [NSString stringWithFormat:@"%@/userCard/deleteUserCards", HOSTURL];
    [manager POST:url parameters:@{@"userCardId":@(userID)} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

-(void)requestNotificationMailMessage
{
    self.notificationStart = 0;
    self.notificationSize = 20;
    
    MailMessageRequest * request = [[MailMessageRequest alloc] initWithNotificationStart:self.notificationStart end:self.notificationSize];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.notificationSource removeAllObjects];
                for (NSInteger i = 0; i < data.count; i++) {
                    NSDictionary * dict = [data objectAtIndex:i];
                    MailModel * model = [MailModel mj_objectWithKeyValues:dict];
                    NSDictionary * mailBox = [dict objectForKey:@"mailbox"];
                    [model mj_setKeyValues:mailBox];
                    [self.notificationSource addObject:model];
                }
                
                self.notificationStart += self.notificationSize;
                
                if (self.notificationTableView) {
                    [self.notificationTableView reloadData];
                    [self.notificationTableView.mj_footer resetNoMoreData];
                }
            }
        }
        
        if (self.notificationTableView) {
            [self.notificationTableView.mj_header endRefreshing];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (self.notificationTableView) {
            [self.notificationTableView.mj_header endRefreshing];
        }
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        if (self.notificationTableView) {
            [self.notificationTableView.mj_header endRefreshing];
        }
        
    }];
}

- (void)loadMoreNoticationMailMessage
{
    MailMessageRequest * request = [[MailMessageRequest alloc] initWithNotificationStart:self.notificationStart end:self.notificationSize];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                if (data.count > 0) {
                    for (NSInteger i = 0; i < data.count; i++) {
                        NSDictionary * dict = [data objectAtIndex:i];
                        MailModel * model = [MailModel mj_objectWithKeyValues:dict];
                        NSDictionary * mailBox = [dict objectForKey:@"mailbox"];
                        [model mj_setKeyValues:mailBox];
                        [self.notificationSource addObject:model];
                    }
                    
                    self.notificationStart += self.notificationSize;
                    
                    [self.notificationTableView reloadData];
                    [self.notificationTableView.mj_footer endRefreshing];
                    
                }else{
                    [self.notificationTableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.notificationTableView.mj_footer endRefreshing];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [self.notificationTableView.mj_footer endRefreshing];
        
    }];
}

-(void)requestExchangeMailMessage
{
    self.exchangeStart = 0;
    self.exchangeSize = 20;
    
    MailMessageRequest * request = [[MailMessageRequest alloc] initWithExchangeStart:self.exchangeStart end:self.exchangeSize];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.exchangeSource removeAllObjects];
                for (NSInteger i = 0; i < data.count; i++) {
                    NSDictionary * dict = [data objectAtIndex:i];
                    MailModel * model = [MailModel mj_objectWithKeyValues:dict];
                    NSDictionary * mailBox = [dict objectForKey:@"mailbox"];
                    [model mj_setKeyValues:mailBox];
                    [self.exchangeSource addObject:model];
                }
                
                self.exchangeStart += self.exchangeSize;
                
                if (self.exchangeTableView) {
                    [self.exchangeTableView reloadData];
                    [self.exchangeTableView.mj_footer resetNoMoreData];
                }
            }
        }
        
        if (self.exchangeTableView) {
            [self.exchangeTableView.mj_header endRefreshing];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (self.exchangeTableView) {
            [self.exchangeTableView.mj_header endRefreshing];
        }
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        if (self.exchangeTableView) {
            [self.exchangeTableView.mj_header endRefreshing];
        }
        
    }];
}

- (void)loadMoreExchangemailMessage
{
    MailMessageRequest * request = [[MailMessageRequest alloc] initWithExchangeStart:self.exchangeStart end:self.exchangeSize];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                if (data.count > 0) {
                    for (NSInteger i = 0; i < data.count; i++) {
                        NSDictionary * dict = [data objectAtIndex:i];
                        MailModel * model = [MailModel mj_objectWithKeyValues:dict];
                        NSDictionary * mailBox = [dict objectForKey:@"mailbox"];
                        [model mj_setKeyValues:mailBox];
                        [self.exchangeSource addObject:model];
                    }
                    
                    self.exchangeStart += self.exchangeSize;
                    
                    [self.exchangeTableView reloadData];
                    [self.exchangeTableView.mj_footer endRefreshing];
                    
                }else{
                    [self.exchangeTableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.exchangeTableView.mj_footer endRefreshing];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [self.exchangeTableView.mj_footer endRefreshing];
        
    }];
}

-(void)requestUserCardMessage
{
    self.userCarsStart = 0;
    self.userCarsSize = 20;

    SelectUserCardRequest * request = [[SelectUserCardRequest alloc] initWithStart:self.userCarsStart end:self.userCarsSize];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.userCarsSource removeAllObjects];
                for (NSInteger i = 0; i < data.count; i++) {
                    NSDictionary * dict = [data objectAtIndex:i];
                    
                    NSDictionary * userBean = [dict objectForKey:@"userBean"];
                    UserMailModel * model = [UserMailModel mj_objectWithKeyValues:userBean];
                    
                    NSDictionary * usersCard = [dict objectForKey:@"usersCard"];
                    [model mj_setKeyValues:usersCard];
                    
                    [self.userCarsSource addObject:model];
                }
                
                self.userCarsStart += self.userCarsSize;
                
                if (self.userCardTableView) {
                    [self.userCardTableView reloadData];
                    [self.userCardTableView.mj_footer resetNoMoreData];
                }
            }
        }
        
        if (self.userCardTableView) {
            [self.userCardTableView.mj_header endRefreshing];
        }

    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (self.userCardTableView) {
            [self.userCardTableView.mj_header endRefreshing];
        }
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {

        if (self.userCardTableView) {
            [self.userCardTableView.mj_header endRefreshing];
        }
        
    }];
}

- (void)loadMoreUserCardMessage
{
    SelectUserCardRequest * request = [[SelectUserCardRequest alloc] initWithStart:self.userCarsStart end:self.userCarsSize];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                if (data.count > 0) {
                    for (NSInteger i = 0; i < data.count; i++) {
                        NSDictionary * dict = [data objectAtIndex:i];
                        
                        NSDictionary * userBean = [dict objectForKey:@"userBean"];
                        UserMailModel * model = [UserMailModel mj_objectWithKeyValues:userBean];
                        
                        NSDictionary * usersCard = [dict objectForKey:@"usersCard"];
                        [model mj_setKeyValues:usersCard];
                        
                        [self.userCarsSource addObject:model];
                    }
                    
                    self.userCarsStart += self.userCarsSize;
                    
                    [self.userCardTableView reloadData];
                    [self.userCardTableView.mj_footer endRefreshing];
                    
                }else{
                    [self.userCardTableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.userCardTableView.mj_footer endRefreshing];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [self.userCardTableView.mj_footer endRefreshing];
        
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.notificationTableView) {
        MailModel * model = [self.notificationSource objectAtIndex:indexPath.row];
        
        MailDetailViewController * detail = [[MailDetailViewController alloc] initMailModel:model];
        detail.delegate = self;
        [self.navigationController pushViewController:detail animated:YES];
    }else if (tableView == self.exchangeTableView) {
        MailModel * model = [self.exchangeSource objectAtIndex:indexPath.row];
        
        MailDetailViewController * detail = [[MailDetailViewController alloc] initMailModel:model];
        detail.delegate = self;
        [self.navigationController pushViewController:detail animated:YES];
    }else if (tableView == self.userCardTableView) {
        UserMailModel * model = [self.userCarsSource objectAtIndex:indexPath.row];
        
        UserInfoViewController * info = [[UserInfoViewController alloc] initWithUserId:model.userId];
        self.lastUserModel = model;
        info.delegate = self;
        [self.navigationController pushViewController:info animated:YES];
    }
}

- (void)userFriendInfoDidUpdate:(UserModel *)model
{
    self.lastUserModel.ifFollowedFlg = model.concernFlg;
    self.lastUserModel.ifFriendFlg = model.friendFlg;
    
    [self.userCardTableView reloadData];
}

- (void)userDidAgreementFriend:(MailModel *)model
{
    NSInteger index = [self.notificationSource indexOfObject:model];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    NSInteger mailId = model.cid;
    [self deleteMailWithID:mailId];
    
    [self.notificationSource removeObjectAtIndex:indexPath.row];
    [self.notificationTableView beginUpdates];
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.notificationTableView endUpdates];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.notificationTableView) {
        return self.notificationSource.count;
    }else if (tableView == self.exchangeTableView) {
        return self.exchangeSource.count;
    }
    return self.userCarsSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.notificationTableView) {
        MailModel * model = [self.notificationSource objectAtIndex:indexPath.row];
        
        MailSmallTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MailSmallTableViewCell" forIndexPath:indexPath];
        
        [cell configWithModel:model];
        
        return cell;
    }else if (tableView == self.exchangeTableView) {
        MailModel * model = [self.exchangeSource objectAtIndex:indexPath.row];
        
        MailSmallTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MailSmallTableViewCell" forIndexPath:indexPath];
        
        [cell configWithModel:model];
        
        return cell;
    }
    
    UserMailModel * model = [self.userCarsSource objectAtIndex:indexPath.row];
    
    MailUserCardTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MailUserCardTableViewCell" forIndexPath:indexPath];
    
    [cell configWithModel:model];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    return 330 * scale;
}

- (void)creatTopView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.topView = [[UIView alloc] init];
    self.topView.userInteractionEnabled = YES;
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo((364 + kStatusBarHeight) * scale);
    }];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, (364 + kStatusBarHeight) * scale);
    [self.topView.layer addSublayer:gradientLayer];
    
    self.topView.layer.shadowColor = UIColorFromRGB(0xB721FF).CGColor;
    self.topView.layer.shadowOpacity = .24;
    self.topView.layer.shadowOffset = CGSizeMake(0, 4);
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    titleLabel.text = @"邮筒";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60.5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale - 144 * scale);
    }];
    
    CGFloat buttonWidth = kMainBoundsWidth / 3.f;
    self.userCardButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"名片夹"];
    self.userCardButton.alpha = .5f;
    [self.topView addSubview:self.userCardButton];
    [self.userCardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(144 * scale);
    }];
    
    self.exchangeButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"互动交流"];
    self.exchangeButton.alpha = .5f;
    [self.topView addSubview:self.exchangeButton];
    [self.exchangeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(144 * scale);
    }];
    
    self.notificationButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"信息通知"];
    [self.topView addSubview:self.notificationButton];
    [self.notificationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(144 * scale);
    }];
    
    UIView * lineView1 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView1.alpha = .5f;
    lineView1.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.topView addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.notificationButton.mas_right);
        make.centerY.mas_equalTo(self.notificationButton);
        make.width.mas_equalTo(3 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    
    UIView * lineView2 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView2.alpha = .5f;
    lineView2.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.topView addSubview:lineView2];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.exchangeButton.mas_right);
        make.centerY.mas_equalTo(self.exchangeButton);
        make.width.mas_equalTo(3 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    
    [self.notificationButton addTarget:self action:@selector(tabButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.exchangeButton addTarget:self action:@selector(tabButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.userCardButton addTarget:self action:@selector(tabButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)tabButtonDidClicked:(UIButton *)button
{
    if (button == self.notificationButton) {
        self.pageIndex = 1;
    }else if (button == self.exchangeButton) {
        self.pageIndex = 2;
    }else{
        self.pageIndex = 3;
    }
    [self reloadPageStatus];
}

- (void)reloadPageStatus
{
    if (self.pageIndex == 1) {
        
        self.notificationButton.alpha = 1.f;
        self.exchangeButton.alpha = .5f;
        self.userCardButton.alpha = .5f;
        
        self.notificationTableView.hidden = NO;
        self.exchangeTableView.hidden = YES;
        self.userCardTableView.hidden = YES;
        
    }else if (self.pageIndex == 2) {
        
        self.notificationButton.alpha = .5f;
        self.exchangeButton.alpha = 1.f;
        self.userCardButton.alpha = .5f;
        
        self.notificationTableView.hidden = YES;
        self.exchangeTableView.hidden = NO;
        self.userCardTableView.hidden = YES;
        
    }else{
        
        self.notificationButton.alpha = .5f;
        self.exchangeButton.alpha = .5f;
        self.userCardButton.alpha = 1.f;
        
        self.notificationTableView.hidden = YES;
        self.exchangeTableView.hidden = YES;
        self.userCardTableView.hidden = NO;
        
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
