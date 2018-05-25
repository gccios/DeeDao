//
//  DDFriendViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/14.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDFriendViewController.h"
#import "DDFriendTableViewCell.h"
#import "DDFriendTableHeaderView.h"
#import "SelectFriendRequest.h"
#import "UserInfoViewController.h"

@interface DDFriendViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) NSMutableDictionary * dataDict;
@property (nonatomic, strong) NSArray * nameKeys;
@property (nonatomic, strong) NSMutableArray * dataSource;

@end

@implementation DDFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource = [[NSMutableArray alloc] init];
    self.dataDict = [[NSMutableDictionary alloc] init];
    
    [self createViews];
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
    
    [self creatTopView];
    
    [self requestFriendList];
}

- (void)requestFriendList
{
    SelectFriendRequest * request = [[SelectFriendRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                for (NSInteger i = 0; i < data.count; i++) {
                    NSDictionary * dict = [data objectAtIndex:i];
                    UserModel * model = [UserModel mj_objectWithKeyValues:dict];
                    [self.dataSource addObject:model];
                }
                [self sortFriends];
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)sortFriends
{
    // 将耗时操作放到子线程
    dispatch_queue_t queue = dispatch_queue_create("DDFriends.infoDict", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        
        for (UserModel * model in self.dataSource) {
            // 获取并返回首字母
            NSString * firstLetterString =model.firstLetter;
            
            //如果该字母对应的联系人模型不为空,则将此联系人模型添加到此数组中
            if (self.dataDict[firstLetterString])
            {
                [self.dataDict[firstLetterString] addObject:model];
            }
            //没有出现过该首字母，则在字典中新增一组key-value
            else
            {
                //创建新发可变数组存储该首字母对应的联系人模型
                NSMutableArray *arrGroupNames = [[NSMutableArray alloc] init];
                
                [arrGroupNames addObject:model];
                //将首字母-姓名数组作为key-value加入到字典中
                [self.dataDict setObject:arrGroupNames forKey:firstLetterString];
            }
        }
        
        // 将addressBookDict字典中的所有Key值进行排序: A~Z
        NSArray *nameKeys = [[self.dataDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
        self.nameKeys = [[NSArray alloc] initWithArray:nameKeys];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * key = [self.nameKeys objectAtIndex:indexPath.section];
    NSArray * data = [self.dataDict objectForKey:key];
    UserModel * model = [data objectAtIndex:indexPath.row];
    
    UserInfoViewController * info = [[UserInfoViewController alloc] initWithUserId:model.cid];
    [self.navigationController pushViewController:info animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.nameKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString * key = [self.nameKeys objectAtIndex:section];
    NSArray * data = [self.dataDict objectForKey:key];
    
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDFriendTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DDFriendTableViewCell" forIndexPath:indexPath];
    
    NSString * key = [self.nameKeys objectAtIndex:indexPath.section];
    NSArray * data = [self.dataDict objectForKey:key];
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

- (void)creatTopView
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
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentCenter];
    titleLabel.text = @"好友列表";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
//    
//    UIButton * searchButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
//    [searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
//    [searchButton addTarget:self action:@selector(searchButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.topView addSubview:searchButton];
//    [searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-40 * scale);
//        make.bottom.mas_equalTo(-20 * scale);
//        make.width.height.mas_equalTo(100 * scale);
//    }];
//    
//    UIButton * addButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
//    [addButton setImage:[UIImage imageNamed:@"addFriend"] forState:UIControlStateNormal];
//    [addButton addTarget:self action:@selector(addButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.topView addSubview:addButton];
//    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(searchButton.mas_left).offset(-30 * scale);
//        make.bottom.mas_equalTo(-20 * scale);
//        make.width.height.mas_equalTo(100 * scale);
//    }];
}

- (void)searchButtonDidClicked
{
    NSLog(@"搜索");
}

- (void)addButtonDidClicked
{
    NSLog(@"添加好友");
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
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
