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
#import <BGUploadRequest.h>
#import <MJRefresh.h>
#import <AFHTTPSessionManager.h>

@interface DDMailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UIButton * searchButton;
@property (nonatomic, strong) UIButton * messageButton;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@end

@implementation DDMailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = [[NSMutableArray alloc] init];
    [self creatViews];
}

- (void)creatViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 540 * scale;
//    [self.tableView registerClass:[MailShareTableViewCell class] forCellReuseIdentifier:@"MailShareTableViewCell"];
    [self.tableView registerClass:[MailSmallTableViewCell class] forCellReuseIdentifier:@"MailSmallTableViewCell"];
    [self.tableView registerClass:[MailBigTableViewCell class] forCellReuseIdentifier:@"MailBigTableViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestMailMessage)];
    
    UISwipeGestureRecognizer * swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewDidSwipe:)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.tableView addGestureRecognizer:swipe];
    
    [self createTopView];
    
    [self requestMailMessage];
}

- (void)tableViewDidSwipe:(UISwipeGestureRecognizer *)swipe
{
    CGPoint point = [swipe locationInView:self.tableView];
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if (indexPath && indexPath.row < self.dataSource.count) {
        
        MailModel * model = [self.dataSource objectAtIndex:indexPath.row];
        NSInteger mailId = model.cid;
        [self deleteMailWithID:mailId];
        
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
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

-(void)requestMailMessage
{
    MailMessageRequest * request = [[MailMessageRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.dataSource removeAllObjects];
                for (NSInteger i = 0; i < data.count; i++) {
                    NSDictionary * dict = [data objectAtIndex:i];
                    MailModel * model = [MailModel mj_objectWithKeyValues:dict];
                    NSDictionary * mailBox = [dict objectForKey:@"mailbox"];
                    [model mj_setKeyValues:mailBox];
                    [self.dataSource addObject:model];
                }
                [self.tableView reloadData];
            }
        }
        
        [self.tableView.mj_header endRefreshing];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.tableView.mj_header endRefreshing];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [self.tableView.mj_header endRefreshing];
        
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MailModel * model = [self.dataSource objectAtIndex:indexPath.row];
    
    MailDetailViewController * detail = [[MailDetailViewController alloc] initMailModel:model];
    [self.navigationController pushViewController:detail animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MailModel * model = [self.dataSource objectAtIndex:indexPath.row];
//    if (model.type == MailModelType_System || model.type == MailModelType_HuDong) {
//        
//        MailSmallTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MailSmallTableViewCell" forIndexPath:indexPath];
//        
//        [cell configWithModel:model];
//        
//        return cell;
//        
//    }else if (model.type == MailModelType_DTie) {
//        
//        MailBigTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MailBigTableViewCell" forIndexPath:indexPath];
//        
//        [cell configWithModel:model];
//        
//        return cell;
//        
//    }
    
    MailSmallTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MailSmallTableViewCell" forIndexPath:indexPath];
    
    [cell configWithModel:model];
    
    return cell;
    
//    MailShareTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MailShareTableViewCell" forIndexPath:indexPath];
    
//    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
//    MailModel * model = [self.dataSource objectAtIndex:indexPath.row];
//    if (model.type == MailModelType_System || model.type == MailModelType_HuDong) {
//        
//        return 300 * scale;
//        
//    }else if (model.type == MailModelType_DTie) {
//        
//        return 550 * scale;
//        
//    }
    
    return 300 * scale;
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
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentCenter];
    titleLabel.text = @"邮筒";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60.5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
//    
//    self.searchButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
//    [self.searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
//    [self.searchButton addTarget:self action:@selector(searchButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.topView addSubview:self.searchButton];
//    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-40 * scale);
//        make.bottom.mas_equalTo(-20 * scale);
//        make.width.height.mas_equalTo(100 * scale);
//    }];
//    
//    self.messageButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
//    [self.messageButton setImage:[UIImage imageNamed:@"message"] forState:UIControlStateNormal];
//    [self.messageButton addTarget:self action:@selector(messageButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.topView addSubview:self.messageButton];
//    [self.messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(self.searchButton.mas_left).offset(-30 * scale);
//        make.bottom.mas_equalTo(-20 * scale);
//        make.width.height.mas_equalTo(100 * scale);
//    }];
}

- (void)messageButtonDidClicked
{
    NSLog(@"时间");
}

- (void)searchButtonDidClicked
{
    NSLog(@"来源");
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
