//
//  UserInfoViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "UserInfoViewController.h"
#import "MBProgressHUD+DDHUD.h"
#import "DTieModel.h"
#import "DTieCollectionViewCell.h"
#import "UserInfoRequest.h"
#import "UserInfoCollectionHeader.h"
#import "DDTool.h"
#import "AddFriendRequest.h"
#import "SaveFriendOrConcernRequest.h"
#import "DDCollectionViewController.h"
#import "DTieDetailRequest.h"
#import "DTieNewEditViewController.h"
#import "DTieSearchRequest.h"
#import "DDTool.h"
#import "MBProgressHUD+DDHUD.h"

@interface UserInfoViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, assign) NSInteger userId;

@property (nonatomic, strong) UICollectionViewFlowLayout * layout;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) UserInfoCollectionHeader * header;

@property (nonatomic, strong) UserModel * model;
@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) UIView * bottomHandleView;
@property (nonatomic, strong) UIButton * leftHandleButton;
@property (nonatomic, strong) UIButton * rightHandleButton;

@end

@implementation UserInfoViewController

- (instancetype)initWithUserId:(NSInteger)userId
{
    if (self = [super init]) {
        self.userId = userId;
        self.dataSource = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
    
    [self getData];
}

- (void)leftHandleButtonDidClicked
{
    if (self.model.friendFlg) {
        [self deleteFriend];
    }else{
        [self addFriend];
    }
}

- (void)rightHandleButtonDidClicked
{
    self.rightHandleButton.enabled = NO;
    BOOL isAdd = YES;
    if (self.model.concernFlg) {
        isAdd = NO;
    }
    SaveFriendOrConcernRequest * request = [[SaveFriendOrConcernRequest alloc] initWithHandleConcernId:self.model.cid andIsAdd:isAdd];
    
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        self.model.concernFlg = !self.model.concernFlg;
        
        [self reloadBottomViewStatus];
        [self.header configWithModel:self.model];
        
        self.rightHandleButton.enabled = YES;
        
        if (isAdd) {
            [MBProgressHUD showTextHUDWithText:@"关注成功" inView:self.view];
        }else{
            [MBProgressHUD showTextHUDWithText:@"取消关注" inView:self.view];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        self.rightHandleButton.enabled = YES;
        if (isAdd) {
            [MBProgressHUD showTextHUDWithText:@"关注失败" inView:self.view];
        }else{
            [MBProgressHUD showTextHUDWithText:@"取消关注失败" inView:self.view];
        }
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        self.rightHandleButton.enabled = YES;
        if (isAdd) {
            [MBProgressHUD showTextHUDWithText:@"关注失败" inView:self.view];
        }else{
            [MBProgressHUD showTextHUDWithText:@"取消关注失败" inView:self.view];
        }
        
    }];
}



- (void)getData
{
    UserInfoRequest * request = [[UserInfoRequest alloc] initWithUserId:self.userId];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                UserModel * model = [UserModel mj_objectWithKeyValues:data];
                self.model = model;
            }
            [self createHeaderView];
            [self reloadBottomViewStatus];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)addFriend
{
    AddFriendRequest * request = [[AddFriendRequest alloc] initWithUserId:self.userId];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [MBProgressHUD showTextHUDWithText:@"好友请求已发送" inView:self.view];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [MBProgressHUD showTextHUDWithText:@"好友请求发送失败" inView:self.view];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [MBProgressHUD showTextHUDWithText:@"好友请求发送失败" inView:self.view];
        
    }];
}

- (void)deleteFriend
{
    SaveFriendOrConcernRequest * request = [[SaveFriendOrConcernRequest alloc] initWithHandleFriendId:self.userId andIsAdd:NO];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [MBProgressHUD showTextHUDWithText:@"删除好友成功" inView:self.view];
//        [self getData];
        if (self.delegate && [self.delegate respondsToSelector:@selector(userFriendInfoDidUpdate)]) {
            [self.delegate userFriendInfoDidUpdate];
        }
        self.model.friendFlg = 0;
        [self reloadBottomViewStatus];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [MBProgressHUD showTextHUDWithText:@"删除好友失败" inView:self.view];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [MBProgressHUD showTextHUDWithText:@"删除好友失败" inView:self.view];
        
    }];
}

- (void)createHeaderView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    CGFloat height = 630 * scale;
    if (isEmptyString(self.model.signature)) {
        height += 45 * scale;
    }else{
        height += [DDTool getHeightByWidth:kMainBoundsWidth - 120 * scale title:self.model.signature font:kPingFangRegular(48 * scale)];
    }
    self.layout.headerReferenceSize = CGSizeMake(kMainBoundsWidth, height);
    
    [self.collectionView reloadData];
    
//    if (!self.model.selfFlg) {
//        if (self.model.friendFlg) {
//            self.deleteButton.hidden = NO;
//            self.addButton.hidden = YES;
//        }else{
//            self.deleteButton.hidden = YES;
//            self.addButton.hidden = NO;
//        }
//    }
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.layout = [[UICollectionViewFlowLayout alloc] init];
    self.layout.itemSize = CGSizeMake(kMainBoundsWidth / 2, 360 * scale);
    self.layout.minimumLineSpacing = 30 * scale;
    self.layout.minimumInteritemSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    [self.collectionView registerClass:[DTieCollectionViewCell class] forCellWithReuseIdentifier:@"DTieCollectionViewCell"];
    [self.collectionView registerClass:[UserInfoCollectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UserInfoCollectionHeader"];
    self.collectionView.backgroundColor = self.view.backgroundColor;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    if (!self.model.selfFlg) {
        self.bottomHandleView = [[UIView alloc] initWithFrame:CGRectZero];
        self.bottomHandleView.backgroundColor = [UIColorFromRGB(0xEEEEF4) colorWithAlphaComponent:.7f];
        [self.view addSubview:self.bottomHandleView];
        [self.bottomHandleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.mas_equalTo(0);
            make.height.mas_equalTo(324 * scale);
        }];
        
        self.leftHandleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:@"删除好友"];
        [DDViewFactoryTool cornerRadius:24 * scale withView:self.leftHandleButton];
        self.leftHandleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
        self.leftHandleButton.layer.borderWidth = 3 * scale;
        [self.bottomHandleView addSubview:self.leftHandleButton];
        [self.leftHandleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(60 * scale);
            make.width.mas_equalTo(444 * scale);
            make.height.mas_equalTo(144 * scale);
            make.centerY.mas_equalTo(0);
        }];
        
        self.rightHandleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:@"添加关注"];
        [DDViewFactoryTool cornerRadius:24 * scale withView:self.rightHandleButton];
        self.rightHandleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
        self.rightHandleButton.layer.borderWidth = 3 * scale;
        [self.bottomHandleView addSubview:self.rightHandleButton];
        [self.rightHandleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-60 * scale);
            make.width.mas_equalTo(444 * scale);
            make.height.mas_equalTo(144 * scale);
            make.centerY.mas_equalTo(0);
        }];
        
        [self.leftHandleButton addTarget:self action:@selector(leftHandleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.rightHandleButton addTarget:self action:@selector(rightHandleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.collectionView setContentInset:UIEdgeInsetsMake(0, 0, 350 * scale, 0)];
    }
    
    [self createTopView];
}

- (void)reloadBottomViewStatus
{
    if (self.model.friendFlg == 1) {
        [self.leftHandleButton setTitle:@"删除好友" forState:UIControlStateNormal];
        [self.leftHandleButton setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.leftHandleButton setTitleColor:UIColorFromRGB(0xDB6283) forState:UIControlStateNormal];
    }else{
        [self.leftHandleButton setTitle:@"添加好友" forState:UIControlStateNormal];
        [self.leftHandleButton setBackgroundColor:UIColorFromRGB(0xDB6283)];
        [self.leftHandleButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    }
    
    if (self.model.concernFlg == 1) {
        [self.rightHandleButton setTitle:@"取消关注" forState:UIControlStateNormal];
        [self.rightHandleButton setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.rightHandleButton setTitleColor:UIColorFromRGB(0xDB6283) forState:UIControlStateNormal];
    }else{
        [self.rightHandleButton setTitle:@"添加关注" forState:UIControlStateNormal];
        [self.rightHandleButton setBackgroundColor:UIColorFromRGB(0xDB6283)];
        [self.rightHandleButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DTieCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DTieCollectionViewCell" forIndexPath:indexPath];
    
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.item];
    
    cell.indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section];
    
    [cell configWithDTieModel:model];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UserInfoCollectionHeader * header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UserInfoCollectionHeader" forIndexPath:indexPath];
        self.header = header;
        [header configWithModel:self.model];
        
        return header;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DTieModel * model = [self.dataSource objectAtIndex:indexPath.item];
    switch (model.dTieType) {
            
        case DTieType_Edit:
        {
            MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在获取草稿" inView:self.view];
            
            DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:model.postId type:4 start:0 length:10];
            [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                [hud hideAnimated:YES];
                
                if (KIsDictionary(response)) {
                    NSDictionary * data = [response objectForKey:@"data"];
                    if (KIsDictionary(data)) {
                        DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                        DTieNewEditViewController * edit = [[DTieNewEditViewController alloc] initWithDtieModel:dtieModel];
                        [self.navigationController pushViewController:edit animated:YES];
                    }
                }
            } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                [hud hideAnimated:YES];
            } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
                [hud hideAnimated:YES];
            }];
        }
            break;
            
        default:
        {
            DDCollectionViewController * collection = [[DDCollectionViewController alloc] initWithDataSource:self.dataSource index:indexPath.row];
            [self.navigationController pushViewController:collection animated:YES];
        }
            break;
    }
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
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentCenter];
    titleLabel.text = @"详细资料";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
    UIButton * jubaoButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] title:@"举报"];
    [DDViewFactoryTool cornerRadius:12 * scale withView:jubaoButton];
    jubaoButton.layer.borderWidth = .5f;
    jubaoButton.layer.borderColor = UIColorFromRGB(0xFFFFFF).CGColor;
    [jubaoButton addTarget:self action:@selector(jubaoButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:jubaoButton];
    [jubaoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(144 * scale);
        make.height.mas_equalTo(72 * scale);
        make.centerY.mas_equalTo(titleLabel);
        make.right.mas_equalTo(-60 * scale);
    }];
}

- (void)jubaoButtonDidClicked
{
    NSLog(@"举报");
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setModel:(UserModel *)model
{
    _model = model;
    _dataSource = [[NSMutableArray alloc] initWithArray:model.postBeanList];
}

//- (UIButton *)addButton
//{
//    if (!_addButton) {
//        CGFloat scale = kMainBoundsWidth / 1080.f;
//        _addButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0XDB6283) title:@"添加好友"];
//        [self.view addSubview:_addButton];
//        [_addButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(60 * scale);
//            make.right.mas_equalTo(-60 * scale);
//            make.bottom.mas_equalTo(-95 * scale);
//            make.height.mas_equalTo(144 * scale);
//        }];
//        [DDViewFactoryTool cornerRadius:24 * scale withView:_addButton];
//        _addButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
//        _addButton.layer.borderWidth = 3 * scale;
//        _addButton.backgroundColor = self.view.backgroundColor;
//        [_addButton addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
//        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//        gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
//        gradientLayer.startPoint = CGPointMake(0, 1);
//        gradientLayer.endPoint = CGPointMake(1, 0);
//        gradientLayer.locations = @[@0, @1.0];
//        gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth - 120 * scale, (144 * scale));
//        [_addButton.layer addSublayer:gradientLayer];
//    }
//    return _addButton;
//}
//
//- (UIButton *)deleteButton
//{
//    if (!_deleteButton) {
//        CGFloat scale = kMainBoundsWidth / 1080.f;
//        _deleteButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0XDB6283) title:@"删除好友"];
//        [self.view addSubview:_deleteButton];
//        [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(60 * scale);
//            make.right.mas_equalTo(-60 * scale);
//            make.bottom.mas_equalTo(-95 * scale);
//            make.height.mas_equalTo(144 * scale);
//        }];
//        [DDViewFactoryTool cornerRadius:24 * scale withView:_deleteButton];
//        _deleteButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
//        _deleteButton.layer.borderWidth = 3 * scale;
//        _deleteButton.backgroundColor = self.view.backgroundColor;
//        [_deleteButton addTarget:self action:@selector(deleteFriend) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _deleteButton;
//}

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
