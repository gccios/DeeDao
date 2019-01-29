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
#import "DDTool.h"
#import "WeChatManager.h"
#import "UserManager.h"
#import "MBProgressHUD+DDHUD.h"
#import "ConverUtil.h"
#import <YYText.h>
#import "DDGroupRequest.h"

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

@property (nonatomic, strong) UIView * shareView;

@property (nonatomic, strong) NSMutableArray * groupList;

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
    
    [self getGroupList];
}

- (void)getGroupList
{
    DDGroupRequest * request = [[DDGroupRequest alloc] initWithSelectGroupList];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.groupList removeAllObjects];
        NSDictionary * data = [response objectForKey:@"data"];
        if (KIsDictionary(data)) {
            
            NSArray * myArray = [data objectForKey:@"myFoundGroupList"];
            if (KIsArray(myArray)) {
                [self.groupList addObjectsFromArray:[DDGroupModel mj_objectArrayWithKeyValuesArray:myArray]];
            }
            
            NSArray * array = [data objectForKey:@"myGroupList"];
            if (KIsArray(array)) {
                [self.groupList addObjectsFromArray:[DDGroupModel mj_objectArrayWithKeyValuesArray:array]];
            }
        }
        [self createHeaderView];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
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
        [self.header configWithModel:self.model groupList:self.groupList];
        
        self.rightHandleButton.enabled = YES;
        
        if (isAdd) {
            [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"AddFollow") inView:self.view];
        }else{
            [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"De-Follow") inView:self.view];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(userFriendInfoDidUpdate:)]) {
            [self.delegate userFriendInfoDidUpdate:self.model];
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
            [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:self.view];
        }else{
            [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:self.view];
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
                [model.postBeanList makeObjectsPerformSelector:@selector(configWithAuthor:) withObject:model];
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
        
        [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:self.view];
        
    }];
}

- (void)deleteFriend
{
    SaveFriendOrConcernRequest * request = [[SaveFriendOrConcernRequest alloc] initWithHandleFriendId:self.userId andIsAdd:NO];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [MBProgressHUD showTextHUDWithText:@"删除好友成功" inView:self.view];
//        [self getData];
        if (self.delegate && [self.delegate respondsToSelector:@selector(userFriendInfoDidUpdate:)]) {
            [self.delegate userFriendInfoDidUpdate:self.model];
        }
        self.model.friendFlg = 0;
        [self reloadBottomViewStatus];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [MBProgressHUD showTextHUDWithText:@"删除好友失败" inView:self.view];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:self.view];
        
    }];
}

- (void)createHeaderView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    CGFloat height = 630 * scale;
    
    if (self.groupList.count == 0) {
        height += 45 * scale;
    }else{
        
        NSMutableAttributedString * groupStr = [[NSMutableAttributedString alloc] initWithString:@"群归属：" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
        for (NSInteger i = 0; i < self.groupList.count ; i++) {
            
            DDGroupModel * model = [self.groupList objectAtIndex:i];
            
            NSMutableAttributedString * tempStr = [[NSMutableAttributedString alloc] initWithString:model.groupName attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0xDB6283)}];
            [groupStr appendAttributedString:tempStr];
            
            if ( i != self.groupList.count - 1) {
                NSMutableAttributedString * spaceStr = [[NSMutableAttributedString alloc] initWithString:@" 、" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
                [groupStr appendAttributedString:spaceStr];
            }
        }
        
        UIImage * image = [UIImage imageNamed:@"addFriendColor"];
        NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:image.size alignToFont:kPingFangRegular(36 * scale) alignment:YYTextVerticalAlignmentCenter];
        [groupStr appendAttributedString:attachText];
        
        //计算文本尺寸
        YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(kMainBoundsWidth - 120 * scale, 10000) text:groupStr];
        YYLabel * groupLabel = [[YYLabel alloc] init];
        groupLabel.numberOfLines = 0;
        groupLabel.attributedText = groupStr;
        groupLabel.preferredMaxLayoutWidth = kMainBoundsWidth - 120 * scale;
        groupLabel.textLayout = layout;
        CGFloat introHeight = layout.textBoundingSize.height;
        
        height = height + introHeight + 10 * scale;
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
    
//    if ([UserManager shareManager].user.cid != self.userId) {
//        self.bottomHandleView = [[UIView alloc] initWithFrame:CGRectZero];
//        self.bottomHandleView.backgroundColor = [UIColorFromRGB(0xEEEEF4) colorWithAlphaComponent:.7f];
//        [self.view addSubview:self.bottomHandleView];
//        [self.bottomHandleView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.bottom.right.mas_equalTo(0);
//            make.height.mas_equalTo(324 * scale);
//        }];
//
//        self.leftHandleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"Disconnect")];
//        [DDViewFactoryTool cornerRadius:24 * scale withView:self.leftHandleButton];
//        self.leftHandleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
//        self.leftHandleButton.layer.borderWidth = 3 * scale;
//        [self.bottomHandleView addSubview:self.leftHandleButton];
//        [self.leftHandleButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(60 * scale);
//            make.width.mas_equalTo(444 * scale);
//            make.height.mas_equalTo(144 * scale);
//            make.centerY.mas_equalTo(0);
//        }];
//
//        self.rightHandleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"AddFollow")];
//        [DDViewFactoryTool cornerRadius:24 * scale withView:self.rightHandleButton];
//        self.rightHandleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
//        self.rightHandleButton.layer.borderWidth = 3 * scale;
//        [self.bottomHandleView addSubview:self.rightHandleButton];
//        [self.rightHandleButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.mas_equalTo(-60 * scale);
//            make.width.mas_equalTo(444 * scale);
//            make.height.mas_equalTo(144 * scale);
//            make.centerY.mas_equalTo(0);
//        }];
//
//        [self.leftHandleButton addTarget:self action:@selector(leftHandleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//        [self.rightHandleButton addTarget:self action:@selector(rightHandleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//        [self.collectionView setContentInset:UIEdgeInsetsMake(0, 0, 350 * scale, 0)];
//    }
    
    [self createTopView];
}

- (void)reloadBottomViewStatus
{
    if (self.model.friendFlg == 1) {
        [self.leftHandleButton setTitle:DDLocalizedString(@"Disconnect") forState:UIControlStateNormal];
        [self.leftHandleButton setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.leftHandleButton setTitleColor:UIColorFromRGB(0xDB6283) forState:UIControlStateNormal];
    }else{
        [self.leftHandleButton setTitle:DDLocalizedString(@"Connect") forState:UIControlStateNormal];
        [self.leftHandleButton setBackgroundColor:UIColorFromRGB(0xDB6283)];
        [self.leftHandleButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
    }
    
    if (self.model.concernFlg == 1) {
        [self.rightHandleButton setTitle:DDLocalizedString(@"De-Follow") forState:UIControlStateNormal];
        [self.rightHandleButton setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [self.rightHandleButton setTitleColor:UIColorFromRGB(0xDB6283) forState:UIControlStateNormal];
    }else{
        [self.rightHandleButton setTitle:DDLocalizedString(@"AddFollow") forState:UIControlStateNormal];
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
        [header configWithModel:self.model groupList:self.groupList];
        
        return header;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    DTieModel * model = [self.dataSource objectAtIndex:indexPath.item];
    
//    if (model.status == 0) {
//        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在获取草稿" inView:self.view];
//
//        DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:model.postId type:4 start:0 length:10];
//        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
//            [hud hideAnimated:YES];
//
//            if (KIsDictionary(response)) {
//                NSDictionary * data = [response objectForKey:@"data"];
//                if (KIsDictionary(data)) {
//                    DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
//                    DTieNewEditViewController * edit = [[DTieNewEditViewController alloc] initWithDtieModel:dtieModel];
//                    [self.navigationController pushViewController:edit animated:YES];
//                }
//            }
//        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
//            [hud hideAnimated:YES];
//        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
//            [hud hideAnimated:YES];
//        }];
//    }else{
        DDCollectionViewController * collection = [[DDCollectionViewController alloc] initWithDataSource:self.dataSource index:indexPath.row];
        [self.navigationController pushViewController:collection animated:YES];
//    }
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
    
    CGFloat rightMargin = 60 * scale;
    
    UIButton * shareButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:shareButton];
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-40 * scale);
        make.bottom.mas_equalTo(-20 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    rightMargin = 160 * scale;
    
//    UIButton * jubaoButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] title:@"举报"];
//    [DDViewFactoryTool cornerRadius:12 * scale withView:jubaoButton];
//    jubaoButton.layer.borderWidth = .5f;
//    jubaoButton.layer.borderColor = UIColorFromRGB(0xFFFFFF).CGColor;
//    [jubaoButton addTarget:self action:@selector(jubaoButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.topView addSubview:jubaoButton];
//    [jubaoButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(144 * scale);
//        make.height.mas_equalTo(72 * scale);
//        make.centerY.mas_equalTo(titleLabel);
//        make.right.mas_equalTo(-rightMargin);
//    }];
}

- (void)jubaoButtonDidClicked
{
    NSLog(@"举报");
}

- (void)shareButtonDidClicked
{
//    [[WeChatManager shareManager] shareMiniProgramWithUser:self.model];
    [[UIApplication sharedApplication].keyWindow addSubview:self.shareView];
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
        
        if (isInstallWX) {
            imageNames = @[@"shareweixin", @"shareKouling"];
            titles = @[@"微信好友", @"好友口令"];
            startTag = 11;
        }else{
            imageNames = @[@"shareKouling"];
            titles = @[@"好友口令"];
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
    if (button.tag == 11){
        
        [[WeChatManager shareManager] shareMiniProgramWithUser:self.model];
        
    }else if(button.tag == 12) {
        
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 1000;
        NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
        
        NSString * userID = [NSString stringWithFormat:@"%ld", self.model.cid];
        
        NSString * string = [NSString stringWithFormat:@"%@+%@", timeString, userID];
        NSString * result = [ConverUtil base64EncodeString:string];
        
        NSString * pasteString = [NSString stringWithFormat:@"【DeeDao地到】%@#复制此消息，打开DeeDao地到查看好友名片", result];
        
        UIPasteboard * pasteBoard = [UIPasteboard generalPasteboard];
        pasteBoard.string = pasteString;
        [MBProgressHUD showTextHUDWithText:@"口令复制成功，快去发送给好友吧" inView:[UIApplication sharedApplication].keyWindow];
        
    }
}

- (NSMutableArray *)groupList
{
    if (!_groupList) {
        _groupList = [[NSMutableArray alloc] init];
    }
    return _groupList;
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
