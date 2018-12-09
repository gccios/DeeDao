//
//  DDFriendCardViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/11/13.
//  Copyright © 2018 郭春城. All rights reserved.
//

#import "DDFriendCardViewController.h"
#import "MailSmallTableViewCell.h"
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

@interface DDFriendCardViewController () <UITableViewDelegate, UITableViewDataSource, DTieMailDelegate, UserFriendInfoDelegate>

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UIButton * friendButton;
@property (nonatomic, strong) UIButton * userCardButton;

@property (nonatomic, strong) UITableView * friendTableView;
@property (nonatomic, strong) UITableView * userCardTableView;

@property (nonatomic, strong) NSMutableArray * friendSource;
@property (nonatomic, strong) NSMutableArray * userCarsSource;

@property (nonatomic, assign) NSInteger friendStart;
@property (nonatomic, assign) NSInteger friendSize;
@property (nonatomic, assign) NSInteger userCarsStart;
@property (nonatomic, assign) NSInteger userCarsSize;

@property (nonatomic, assign) NSInteger pageIndex;

@property (nonatomic, strong) UserMailModel * lastUserModel;

@end

@implementation DDFriendCardViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.friendSource = [[NSMutableArray alloc] init];
        self.userCarsSource = [[NSMutableArray alloc] init];
        
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
    
    self.friendTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.friendTableView.backgroundColor = self.view.backgroundColor;
    self.friendTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.friendTableView.rowHeight = 540 * scale;
    [self.friendTableView registerClass:[MailSmallTableViewCell class] forCellReuseIdentifier:@"MailSmallTableViewCell"];
    self.friendTableView.delegate = self;
    self.friendTableView.dataSource = self;
    [self.view addSubview:self.friendTableView];
    [self.friendTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((364 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.friendTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestExchangeMailMessage)];
    self.friendTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreExchangemailMessage)];
    
    UISwipeGestureRecognizer * swipe2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewDidSwipe:)];
    swipe2.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.friendTableView addGestureRecognizer:swipe2];
    
    self.userCardTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.userCardTableView.backgroundColor = self.view.backgroundColor;
    self.userCardTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.userCardTableView.rowHeight = 540 * scale;
    [self.userCardTableView registerClass:[MailUserCardTableViewCell class] forCellReuseIdentifier:@"MailUserCardTableViewCell"];
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
    if (swipe.view == self.friendTableView) {
        CGPoint point = [swipe locationInView:self.friendTableView];
        NSIndexPath * indexPath = [self.friendTableView indexPathForRowAtPoint:point];
        
        if (indexPath && indexPath.row < self.friendSource.count) {
            
            MailModel * model = [self.friendSource objectAtIndex:indexPath.row];
            NSInteger mailId = model.cid;
            [self deleteMailWithID:mailId];
            
            [self.friendSource removeObjectAtIndex:indexPath.row];
            [self.friendTableView beginUpdates];
            [self.friendTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            [self.friendTableView endUpdates];
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

-(void)requestExchangeMailMessage
{
    self.friendStart = 0;
    self.friendSize = 20;
    
    MailMessageRequest * request = [[MailMessageRequest alloc] initWithExchangeStart:self.friendStart end:self.friendSize];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.friendSource removeAllObjects];
                for (NSInteger i = 0; i < data.count; i++) {
                    NSDictionary * dict = [data objectAtIndex:i];
                    MailModel * model = [MailModel mj_objectWithKeyValues:dict];
                    NSDictionary * mailBox = [dict objectForKey:@"mailbox"];
                    [model mj_setKeyValues:mailBox];
                    
                    if (model.mailTypeId == 8) {
                        [self.friendSource addObject:model];
                    }
                }
                
                self.friendStart += self.friendSize;
                
                if (self.friendTableView) {
                    [self.friendTableView reloadData];
                    [self.friendTableView.mj_footer resetNoMoreData];
                }
            }
        }
        
        if (self.friendTableView) {
            [self.friendTableView.mj_header endRefreshing];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (self.friendTableView) {
            [self.friendTableView.mj_header endRefreshing];
        }
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        if (self.friendTableView) {
            [self.friendTableView.mj_header endRefreshing];
        }
        
    }];
}

- (void)loadMoreExchangemailMessage
{
    MailMessageRequest * request = [[MailMessageRequest alloc] initWithExchangeStart:self.friendStart end:self.friendSize];
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
                        if (model.mailTypeId == 8) {
                            [self.friendSource addObject:model];
                        }
                    }
                    
                    self.friendStart += self.friendSize;
                    
                    [self.friendTableView reloadData];
                    [self.friendTableView.mj_footer endRefreshing];
                    
                }else{
                    [self.friendTableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.friendTableView.mj_footer endRefreshing];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [self.friendTableView.mj_footer endRefreshing];
        
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
                    
                    if (model) {
                        NSDictionary * usersCard = [dict objectForKey:@"usersCard"];
                        [model mj_setKeyValues:usersCard];
                        
                        [self.userCarsSource addObject:model];
                    }
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
    if (tableView == self.friendTableView) {
        MailModel * model = [self.friendSource objectAtIndex:indexPath.row];
        
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.friendTableView) {
        return self.friendSource.count;
    }else if (tableView == self.userCardTableView) {
        return self.userCarsSource.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.friendTableView) {
        MailModel * model = [self.friendSource objectAtIndex:indexPath.row];
        
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
    
    UIButton * backButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.bottom.mas_equalTo(-159 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    titleLabel.text = DDLocalizedString(@"InvitesAndCards");
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale - 144 * scale);
    }];
    
    CGFloat buttonWidth = kMainBoundsWidth / 2.f;
    self.userCardButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"Name card")];
    self.userCardButton.alpha = .5f;
    [self.topView addSubview:self.userCardButton];
    [self.userCardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(144 * scale);
    }];
    
    self.friendButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"Invites")];
    [self.topView addSubview:self.friendButton];
    [self.friendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(144 * scale);
    }];
    
    UIView * lineView3 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView3.alpha = .5f;
    lineView3.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.userCardButton addSubview:lineView3];
    [lineView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(3 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    
    [self.friendButton addTarget:self action:@selector(tabButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.userCardButton addTarget:self action:@selector(tabButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tabButtonDidClicked:(UIButton *)button
{
    if (button == self.friendButton) {
        self.pageIndex = 1;
    }else{
        self.pageIndex = 2;
    }
    [self reloadPageStatus];
}

- (void)reloadPageStatus
{
    if (self.pageIndex == 1) {
        
        self.friendButton.alpha = 1.f;
        self.userCardButton.alpha = .5f;
        
        self.friendTableView.hidden = NO;
        self.userCardTableView.hidden = YES;
        
    }else{
        
        self.friendButton.alpha = .5f;
        self.userCardButton.alpha = 1.f;
        
        self.friendTableView.hidden = YES;
        self.userCardTableView.hidden = NO;
        
    }
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
