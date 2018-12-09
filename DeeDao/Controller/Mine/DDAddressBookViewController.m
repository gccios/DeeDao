//
//  DDAddressBookViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/11/7.
//  Copyright © 2018 郭春城. All rights reserved.
//

#import "DDAddressBookViewController.h"
#import "MBProgressHUD+DDHUD.h"
#import "DDAddressBookReuqest.h"
#import "DDFriendTableViewCell.h"
#import "DDFriendTableHeaderView.h"
#import "UserManager.h"
#import "UserInfoViewController.h"
#import <PPGetAddressBook.h>

@interface DDAddressBookViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) NSMutableDictionary * friendDataDict;
@property (nonatomic, strong) NSArray * nameKeys;

@property (nonatomic, strong) UITableView * tableView;

@end

@implementation DDAddressBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.friendDataDict = [NSMutableDictionary new];
    
    [self createViews];
    [self createTopView];
    
    [[PPAddressBookHandle sharedAddressBookHandle] requestAuthorizationWithSuccessBlock:^{
         [self uploadAddressBook];
    }];
    [self createDataSource];
}

- (void)uploadAddressBook
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在获取通讯录" inView:self.view];
    [PPGetAddressBook getOriginalAddressBook:^(NSArray<PPPersonModel *> *addressBookArray) {
        
        NSMutableArray * addressBookDictSource = [[NSMutableArray alloc] init];
        for (PPPersonModel * model in addressBookArray) {
            
            for (NSString * mobile in model.mobileArray) {
                NSDictionary * dict = @{@"phoneName" : model.name,
                                        @"phoneNum" : mobile,
                                        };
                [addressBookDictSource addObject:dict];
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self uploadAddressBookWith:addressBookDictSource];
        });
        
    } authorizationFailure:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"获取通讯录失败" inView:self.view];
        });
    }];
}

- (void)uploadAddressBookWith:(NSArray *)list
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在同步通讯录" inView:self.view];
    DDAddressBookReuqest * request = [[DDAddressBookReuqest alloc] initWithAddressBookList:list];
    
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"通讯录同步成功" inView:self.view];
        [self createDataSource];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"通讯录同步失败" inView:self.view];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"通讯录同步成功" inView:self.view];
        [self createDataSource];
        
    }];
}

- (void)createDataSource
{
    DDAddressBookReuqest * request = [[DDAddressBookReuqest alloc] initWithList];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        NSArray * data = [response objectForKey:@"data"];
        if (KIsArray(data)) {
            NSMutableArray * source = [[NSMutableArray alloc] init];
            for (NSInteger i = 0; i < data.count; i++) {
                NSDictionary * dict = [data objectAtIndex:i];
                UserModel * model = [UserModel mj_objectWithKeyValues:dict];
                [source addObject:model];
            }
            [self sortFriends:source dataDict:self.friendDataDict];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)sortFriends:(NSMutableArray *)source dataDict:(NSMutableDictionary *)dataDict
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"cid == %d", [UserManager shareManager].user.cid];
    NSArray * tempArray = [source filteredArrayUsingPredicate:predicate];
    if (tempArray && tempArray.count > 0) {
        
    }else{
        [source addObject:[UserManager shareManager].user];
    }
    
    [dataDict removeAllObjects];
    
    // 将耗时操作放到子线程
    dispatch_queue_t queue = dispatch_queue_create("DDFriends.infoDict", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        
        for (UserModel * model in source) {
            // 获取并返回首字母
            NSString * firstLetterString =model.firstLetter;
            
            if (isEmptyString(firstLetterString)) {
                continue;
            }
            
            //如果该字母对应的联系人模型不为空,则将此联系人模型添加到此数组中
            if (dataDict[firstLetterString])
            {
                [dataDict[firstLetterString] addObject:model];
            }
            //没有出现过该首字母，则在字典中新增一组key-value
            else
            {
                //创建新发可变数组存储该首字母对应的联系人模型
                NSMutableArray *arrGroupNames = [[NSMutableArray alloc] init];
                
                [arrGroupNames addObject:model];
                //将首字母-姓名数组作为key-value加入到字典中
                [dataDict setObject:arrGroupNames forKey:firstLetterString];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSArray *nameKeys = [[self.friendDataDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
            self.nameKeys = [[NSArray alloc] initWithArray:nameKeys];
            
            [self.tableView reloadData];
        });
        
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.nameKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString * key = [self.nameKeys objectAtIndex:section];
    NSArray * data = [self.friendDataDict objectForKey:key];
    
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDFriendTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DDFriendTableViewCell" forIndexPath:indexPath];
    
    NSString * key = [self.nameKeys objectAtIndex:indexPath.section];
    NSArray * data = [self.friendDataDict objectForKey:key];
    UserModel * model = [data objectAtIndex:indexPath.row];
    
    [cell configWithModel:model];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DDFriendTableHeaderView * view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DDFriendTableHeaderView"];
    
    NSString * key = [self.nameKeys objectAtIndex:section];
    [view configWithPre:key];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    return 80 * scale;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * key = [self.nameKeys objectAtIndex:indexPath.section];
    NSArray * data = [self.friendDataDict objectForKey:key];
    UserModel * model = [data objectAtIndex:indexPath.row];
    
    UserInfoViewController * info = [[UserInfoViewController alloc] initWithUserId:model.cid];
    [self.navigationController pushViewController:info animated:YES];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 150 * scale;
    [self.tableView registerClass:[DDFriendTableViewCell class] forCellReuseIdentifier:@"DDFriendTableViewCell"];
    [self.tableView registerClass:[DDFriendTableHeaderView class] forHeaderFooterViewReuseIdentifier:@"DDFriendTableHeaderView"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
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
        make.right.mas_equalTo(-10 * scale);
        make.width.mas_equalTo(350 * scale);
        make.height.mas_equalTo(80 * scale);
    }];
    [addressBookButton addTarget:self action:@selector(uploadAddressBook) forControlEvents:UIControlEventTouchUpInside];
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
