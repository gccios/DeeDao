//
//  EditSecurityController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "EditSecurityController.h"
#import "SecurityUserCollectionViewCell.h"
#import "SecurityHeaderView.h"
#import "SecurityFooterView.h"
#import "SelectFriendRequest.h"
#import "SecurityFriendController.h"
#import "DDCollectionHandleView.h"
#import "SecurityDTieViewController.h"
#import "MBProgressHUD+DDHUD.h"
#import "UserManager.h"
#import "AddOrUpdateSecurityRequest.h"
#import "DeleteSecurityRequest.h"
#import <AFHTTPSessionManager.h>

@interface EditSecurityController ()<UICollectionViewDelegate, UICollectionViewDataSource, SecurityFriendDelegate>

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UICollectionView * collectionView;

@property (nonatomic, strong) NSMutableDictionary * dataDict;
@property (nonatomic, strong) NSArray * nameKeys;
@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) NSMutableArray * DTieSource;
@property (nonatomic, strong) NSMutableArray * selectFriend;
@property (nonatomic, strong) NSMutableArray * selectDTie;

@property (nonatomic, strong) SecurityHeaderView * headerView;

@property (nonatomic, strong) SecurityGroupModel * model;

@end

@implementation EditSecurityController

- (instancetype)initWithModel:(SecurityGroupModel *)model friends:(NSArray *)friends posts:(NSArray *)posts
{
    if (self = [super init]) {
        self.model = model;
        self.selectDTie = [[NSMutableArray alloc] initWithArray:posts];
        self.selectFriend = [[NSMutableArray alloc] initWithArray:friends];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
    
    [self requestFriendList];
}

- (void)requestFriendList
{
    [SelectFriendRequest cancelRequest];
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
            
            if (isEmptyString(firstLetterString)) {
                continue;
            }
            
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
            
        });
        
    });
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kMainBoundsWidth / 5, 240 * scale);
    layout.minimumLineSpacing = 48 * scale;
    layout.minimumInteritemSpacing = 0;
    layout.headerReferenceSize = CGSizeMake(kMainBoundsWidth, 710 * scale);
    layout.footerReferenceSize = CGSizeMake(kMainBoundsWidth, 330 * scale);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerClass:[SecurityUserCollectionViewCell class] forCellWithReuseIdentifier:@"SecurityUserCollectionViewCell"];
    [self.collectionView registerClass:[SecurityHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SecurityHeaderView"];
    [self.collectionView registerClass:[DDCollectionHandleView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"DDCollectionHandleView"];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    [self createTopView];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == self.selectFriend.count) {
        [self chooseFriend];
    }
}

- (void)chooseFriend
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    if (self.dataSource.count == 0) {
        [self requestFriendList];
    }
    SecurityFriendController * friend = [[SecurityFriendController alloc] initMulSelectWithDataDict:self.dataDict nameKeys:self.nameKeys selectModels:self.selectFriend];
    friend.delegate = self;
    [self.navigationController pushViewController:friend animated:YES];
}

- (void)securityFriendDidSelectWith:(UserModel *)model
{
    int tempID = (int)model.cid;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"cid == %d", tempID];
    NSArray * tempArray = [self.selectFriend filteredArrayUsingPredicate:predicate];
    
    if (tempArray && tempArray.count > 0) {
        [MBProgressHUD showTextHUDWithText:@"该用户已存在" inView:self.navigationController.view];
    }else{
        [self.selectFriend addObject:model];
        [self.collectionView reloadData];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)friendDidMulSelectComplete:(NSArray *)selectArray
{
    [self.collectionView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.selectFriend.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SecurityUserCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SecurityUserCollectionViewCell" forIndexPath:indexPath];
    
    if (indexPath.item == self.selectFriend.count) {
        [cell configAddCell];
    }else{
        UserModel * model = [self.selectFriend objectAtIndex:indexPath.row];
        [cell configWithModel:model];
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(cell) weakCell = cell;
        cell.cancleButtonHandle = ^{
            NSIndexPath * tempIndex = [weakSelf.collectionView indexPathForCell:weakCell];
            if (tempIndex) {
                [weakSelf.selectFriend removeObjectAtIndex:tempIndex.row];
                [weakSelf.collectionView deleteItemsAtIndexPaths:@[tempIndex]];
            }
        };
    }
    
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        SecurityHeaderView * view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SecurityHeaderView" forIndexPath:indexPath];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choosDTieDidClicked)];
        [view.whiteView2 addGestureRecognizer:tap];
        
        if (self.model) {
            view.nameTextField.text = self.model.securitygroupName;
        }
        
        self.headerView = view;
        
        return view;
    }else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        DDCollectionHandleView * view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"DDCollectionHandleView" forIndexPath:indexPath];
        
        [view configButtonBackgroundColor:UIColorFromRGB(0xFFFFFF) title:@"删除密圈"];
        if (self.model) {
            view.handleButton.hidden = NO;
        }else{
            view.handleButton.hidden = YES;
        }
        
        view.handleButtonClicked = ^{
            [self deleteSelfSecueity];
        };
        
        return view;
    }
    return nil;
}

- (void)deleteSelfSecueity
{
    if (!self.model) {
        return;
    }
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    NSString * url = [NSString stringWithFormat:@"%@/scyGroup/delScyGroup", HOSTURL];
    [manager POST:url parameters:@{@"scyGroupId":@(self.model.cid)} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

    } progress:^(NSProgress * _Nonnull uploadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        [MBProgressHUD showTextHUDWithText:@"操作成功" inView:self.navigationController.view];
        if (self.delegate && [self.delegate respondsToSelector:@selector(securityGroupDidEdit)]) {
            [self.delegate securityGroupDidEdit];
        }
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD showTextHUDWithText:@"操作失败" inView:self.view];
    }];
}

- (void)choosDTieDidClicked
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    SecurityDTieViewController * Dtie = [[SecurityDTieViewController alloc] initWithChooseSource:self.selectDTie DTieSource:self.DTieSource];
    [self.navigationController pushViewController:Dtie animated:YES];
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
    titleLabel.text = @"编辑好友圈";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
    UIButton * createButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] title:@"保存"];
    [DDViewFactoryTool cornerRadius:12 * scale withView:createButton];
    createButton.layer.borderWidth = .5f;
    createButton.layer.borderColor = UIColorFromRGB(0xFFFFFF).CGColor;
    [createButton addTarget:self action:@selector(createButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:createButton];
    [createButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(144 * scale);
        make.height.mas_equalTo(72 * scale);
        make.centerY.mas_equalTo(titleLabel);
        make.right.mas_equalTo(-60 * scale);
    }];
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createButtonDidClicked
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    if (isEmptyString(self.headerView.nameTextField.text)) {
        [MBProgressHUD showTextHUDWithText:@"请输入标题" inView:self.view];
        return;
    }
    
    NSInteger groupId = 0;
    NSString * groupPropName = @"";
    if (self.model) {
        groupId = self.model.cid;
        groupPropName = self.model.securitygroupPropName;
    }
    
    AddOrUpdateSecurityRequest * request = [[AddOrUpdateSecurityRequest alloc] initWithCreatePerson:[UserManager shareManager].user.cid deleteFlg:0 groupId:groupId groupName:self.headerView.nameTextField.text groupPropName:@"" posts:self.selectDTie friends:self.selectFriend];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [MBProgressHUD showTextHUDWithText:@"操作成功" inView:self.navigationController.view];
        if (self.delegate && [self.delegate respondsToSelector:@selector(securityGroupDidEdit)]) {
            [self.delegate securityGroupDidEdit];
        }
        [self.navigationController popViewControllerAnimated:YES];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [MBProgressHUD showTextHUDWithText:@"操作失败" inView:self.view];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:self.view];
    }];
}

#pragma mark - getter
- (NSMutableArray *)selectFriend
{
    if (!_selectFriend) {
        _selectFriend = [[NSMutableArray alloc] init];
    }
    return _selectFriend;
}

- (NSMutableArray *)selectDTie
{
    if (!_selectDTie) {
        _selectDTie = [[NSMutableArray alloc] init];
    }
    return _selectDTie;
}

- (NSMutableDictionary *)dataDict
{
    if (!_dataDict) {
        _dataDict = [[NSMutableDictionary alloc] init];
    }
    return _dataDict;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (NSMutableArray *)DTieSource
{
    if (!_DTieSource) {
        _DTieSource = [[NSMutableArray alloc] init];
    }
    return _DTieSource;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
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
