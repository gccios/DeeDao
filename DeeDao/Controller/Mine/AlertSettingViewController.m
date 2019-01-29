//
//  AlertSettingViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "AlertSettingViewController.h"
#import "AlertHeaderView.h"
#import "AlertTableViewCell.h"
#import "AlertSingleTableViewCell.h"
#import "SelectRemindStatusRequest.h"
#import "SaveRemindStatusRequest.h"
#import "MBProgressHUD+DDHUD.h"

@interface AlertSettingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) NSMutableArray * openList;

@property (nonatomic, strong) NSMutableArray * firstSource;
@property (nonatomic, strong) NSMutableArray * secondSource;

@property (nonatomic, assign) NSInteger thirdChooseIndex;
@property (nonatomic, assign) NSInteger forthChooseIndex;

@property (nonatomic, assign) NSInteger remindID;

@end

@implementation AlertSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.openList = [[NSMutableArray alloc] init];
    [self.openList addObject:[NSNumber numberWithBool:YES]];
    [self.openList addObject:[NSNumber numberWithBool:NO]];
    [self.openList addObject:[NSNumber numberWithBool:NO]];
    [self.openList addObject:[NSNumber numberWithBool:NO]];
    
    self.firstSource = [[NSMutableArray alloc] init];
    [self.firstSource addObject:[[AlertModel alloc] initWithTitle:DDLocalizedString(@"Follow") status:YES type:11]];
//    [self.firstSource addObject:[[AlertModel alloc] initWithTitle:DDLocalizedString(@"POI Collection") status:YES type:12]];
    [self.firstSource addObject:[[AlertModel alloc] initWithTitle:DDLocalizedString(@"POI Collection") status:YES type:13]];
//    [self.firstSource addObject:[[AlertModel alloc] initWithTitle:DDLocalizedString(@"Friend’s D Page") status:YES type:14]];
    
    self.secondSource = [[NSMutableArray alloc] init];
    BOOL xiangling = [DDUserDefaultsGet(@"xiangling") boolValue];
    BOOL zhendong = [DDUserDefaultsGet(@"zhendong") boolValue];
    [self.secondSource addObject:[[AlertModel alloc] initWithTitle:DDLocalizedString(@"Bell") status:xiangling type:21]];
    [self.secondSource addObject:[[AlertModel alloc] initWithTitle:DDLocalizedString(@"Vibrate") status:zhendong type:22]];
    
    NSInteger shichangtype = [DDUserDefaultsGet(@"shichangtype") integerValue];
    self.thirdChooseIndex = shichangtype;
    
    self.forthChooseIndex = 0;
    
    [self createViews];
    [self createTopView];
    [self requestRemindStatus];
}

- (void)requestRemindStatus
{
    SelectRemindStatusRequest * request = [[SelectRemindStatusRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                [self.firstSource removeAllObjects];
                NSInteger ifConcern = [[data objectForKey:@"ifConcern"] integerValue];
                NSInteger ifCollection = [[data objectForKey:@"ifCollection"] integerValue];
                NSInteger ifWyy = [[data objectForKey:@"ifWyy"] integerValue];
                NSInteger ifFriend = [[data objectForKey:@"ifFriend"] integerValue];
                [self.firstSource addObject:[[AlertModel alloc] initWithTitle:DDLocalizedString(@"Follow") status:ifConcern type:11]];
//                [self.firstSource addObject:[[AlertModel alloc] initWithTitle:DDLocalizedString(@"POI Collection") status:ifCollection type:12]];
                [self.firstSource addObject:[[AlertModel alloc] initWithTitle:DDLocalizedString(@"POI Collection") status:ifWyy type:13]];
//                [self.firstSource addObject:[[AlertModel alloc] initWithTitle:DDLocalizedString(@"Friend’s D Page") status:ifFriend type:14]];
                
                NSInteger remindInterval = [[data objectForKey:@"remindInterval"] integerValue];
                if (remindInterval == 0) {
                    self.forthChooseIndex = 3;
                }else if (remindInterval == 1) {
                    self.forthChooseIndex = 2;
                }else if (remindInterval == 2) {
                    self.forthChooseIndex = 1;
                }else{
                    self.forthChooseIndex = 0;
                }
                
                self.remindID = [[data objectForKey:@"id"] integerValue];
                
                [self.tableView reloadData];
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BOOL isOpen = [[self.openList objectAtIndex:section] boolValue];
    if (isOpen) {
        
        if (section == 0) {
            return self.firstSource.count;
        }else if (section == 1) {
            return self.secondSource.count;
        }else if (section == 2) {
            return 3;
        }else if (section == 3) {
            return 4;
        }
        
        return 0;
        
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger section = indexPath.section;
    if (section == 0) {
        
        AlertTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"AlertTableViewCell" forIndexPath:indexPath];
        AlertModel * model = [self.firstSource objectAtIndex:indexPath.row];
        [cell configWithModel:model];
        return cell;
        
    }else if (section == 1) {
        
        AlertTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"AlertTableViewCell" forIndexPath:indexPath];
        AlertModel * model = [self.secondSource objectAtIndex:indexPath.row];
        [cell configWithModel:model];
        return cell;
        
    }else if (section == 2) {
        
        AlertSingleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"AlertSingleTableViewCell" forIndexPath:indexPath];
        
        if (indexPath.row == 0) {
            [cell configTitle:[NSString stringWithFormat:@"2 %@", DDLocalizedString(@"Seconds")]];
        }else if (indexPath.row == 1) {
            [cell configTitle:[NSString stringWithFormat:@"5 %@", DDLocalizedString(@"Seconds")]];
        }else{
            [cell configTitle:[NSString stringWithFormat:@"10 %@", DDLocalizedString(@"Seconds")]];
        }
        if (self.thirdChooseIndex == indexPath.row) {
            [cell configChooseStatus:YES];
        }else{
            [cell configChooseStatus:NO];
        }
        
        return cell;
        
    }else if (section == 3) {
        
        AlertSingleTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"AlertSingleTableViewCell" forIndexPath:indexPath];
        
        if (indexPath.row == 0) {
            [cell configTitle:DDLocalizedString(@"No more for today")];
        }else if (indexPath.row == 1) {
            [cell configTitle:DDLocalizedString(@"Not in 3 months")];
        }else if (indexPath.row == 2) {
            [cell configTitle:DDLocalizedString(@"Not in 1 year")];
        }else{
            [cell configTitle:DDLocalizedString(@"Never this again")];
        }
        if (self.forthChooseIndex == indexPath.row) {
            [cell configChooseStatus:YES];
        }else{
            [cell configChooseStatus:NO];
        }
        
        return cell;
        
    }
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        self.thirdChooseIndex = indexPath.row;
        DDUserDefaultsSet(@"shichangtype", [NSNumber numberWithInteger:indexPath.row]);
        [DDUserDefaults synchronize];
        [tableView reloadData];
    }else if (indexPath.section == 3) {
        self.forthChooseIndex = indexPath.row;
        [tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 144 * kMainBoundsWidth / 1080.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    AlertHeaderView * view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"AlertHeaderView"];
    
    if (section == 0) {
        [view configWithTitle:DDLocalizedString(@"Items")];
    }else if (section == 1){
        [view configWithTitle:DDLocalizedString(@"AlertType")];
    }else if (section == 2) {
        [view configWithTitle:DDLocalizedString(@"Duration")];
    }else{
        [view configWithTitle:DDLocalizedString(@"Intervals")];
    }
    
    BOOL isOpen = [[self.openList objectAtIndex:section] boolValue];
    [view configWithOpenStaus:isOpen];
    
    __weak typeof(self) weakSelf = self;
    view.clickedHandle = ^{
        BOOL isOpen = [[weakSelf.openList objectAtIndex:section] boolValue];
        isOpen = !isOpen;
        [weakSelf.openList replaceObjectAtIndex:section withObject:[NSNumber numberWithBool:isOpen]];
        [weakSelf.tableView reloadData];
    };
    
    return view;
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[AlertHeaderView class] forHeaderFooterViewReuseIdentifier:@"AlertHeaderView"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.tableView registerClass:[AlertTableViewCell class] forCellReuseIdentifier:@"AlertTableViewCell"];
    [self.tableView registerClass:[AlertSingleTableViewCell class] forCellReuseIdentifier:@"AlertSingleTableViewCell"];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 350 * scale, 0);
    
    UIButton * handleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"SaveBack")];
    [DDViewFactoryTool cornerRadius:24 * scale withView:handleButton];
    handleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    handleButton.layer.borderWidth = 3 * scale;
    [self.view addSubview:handleButton];
    [handleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(144 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.bottom.mas_equalTo(-60 * scale);
    }];
    [handleButton addTarget:self action:@selector(handleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)handleButtonDidClicked
{
    AlertModel * model1 = [self.firstSource objectAtIndex:0];
    AlertModel * model2 = [self.firstSource objectAtIndex:1];
//    AlertModel * model3 = [self.firstSource objectAtIndex:2];
//    AlertModel * model4 = [self.firstSource objectAtIndex:3];
    
    NSInteger remindInterval = 0;
    if (self.forthChooseIndex == 0) {
        remindInterval = 3;
    }else if (self.forthChooseIndex == 1) {
        remindInterval = 2;
    }else if (self.forthChooseIndex == 2) {
        remindInterval = 1;
    }else{
        remindInterval = 0;
    }
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在保存" inView:self.view];
    SaveRemindStatusRequest * request = [[SaveRemindStatusRequest alloc] initWithId:self.remindID concern:model1.openStatus collection:0 wyy:model2.openStatus friend:0 remindInterval:remindInterval];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"保存失败" inView:self.view];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:self.view];
        
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
    titleLabel.text = @"提醒设置";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
//    UIButton * cancleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] title:@"恢复默认"];
//    [DDViewFactoryTool cornerRadius:12 * scale withView:cancleButton];
//    cancleButton.layer.borderWidth = .5f;
//    cancleButton.layer.borderColor = UIColorFromRGB(0xFFFFFF).CGColor;
//    [cancleButton addTarget:self action:@selector(cancleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.topView addSubview:cancleButton];
//    [cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(192 * scale);
//        make.height.mas_equalTo(72 * scale);
//        make.centerY.mas_equalTo(titleLabel);
//        make.right.mas_equalTo(-60 * scale);
//    }];
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancleButtonDidClicked
{
    [self backButtonDidClicked];
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
