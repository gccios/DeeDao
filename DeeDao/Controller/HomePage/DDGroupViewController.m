
//
//  DDGroupViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/3.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDGroupViewController.h"
#import "DDGroupCollectionViewCell.h"
#import "DDGroupTitleReusableView.h"
#import "DDBackWidow.h"
#import "DDGroupSearchViewController.h"
#import "DDGroupRequest.h"
#import "DDCreateGroupViewController.h"
#import "UserManager.h"
#import "DDAuthorGroupDetailController.h"
#import "DDGroupDetailViewController.h"
#import "MBProgressHUD+DDHUD.h"

@interface DDGroupViewController () <UICollectionViewDelegate, UICollectionViewDataSource, CAAnimationDelegate, DDCreateGroupViewControllerDelegate, DDAuthorGroupDetailControllerDelegate, DDGroupDetailViewControllerDelegate>

@property (nonatomic, strong) UICollectionView * collectionView;

@property (nonatomic, strong) NSMutableArray * defaultSource;
@property (nonatomic, strong) NSMutableArray * mySource;
@property (nonatomic, strong) NSMutableArray * addSource;
@property (nonatomic, strong) NSMutableArray * otherSource;

@end

@implementation DDGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DDGroupModel * homeModel = [[DDGroupModel alloc] initWithMyHome];
    [self.defaultSource addObject:homeModel];
    
    DDGroupModel * myModel = [[DDGroupModel alloc] initWithMy];
    [self.defaultSource addObject:myModel];
    
    DDGroupModel * collectModel = [[DDGroupModel alloc] initWithMyCollect];
    [self.defaultSource addObject:collectModel];
    
    DDGroupModel * wyyModel = [[DDGroupModel alloc] initWithMyWYY];
    [self.defaultSource addObject:wyyModel];
    
    DDGroupModel * otherModel = [[DDGroupModel alloc] initWithPublic];
    [self.defaultSource addObject:otherModel];
    
    DDGroupModel * createModel = [[DDGroupModel alloc] initWithCreate];
    [self.defaultSource addObject:createModel];
    
    [self createViews];
    
    [self setupData];
}

- (void)setupData
{
    DDGroupRequest * request = [[DDGroupRequest alloc] initWithSelectGroupList];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.mySource removeAllObjects];
        [self.addSource removeAllObjects];
        [self.otherSource removeAllObjects];
        
        NSDictionary * data = [response objectForKey:@"data"];
        if (KIsDictionary(data)) {
            
            NSArray * myGroupList = [data objectForKey:@"myFoundGroupList"];
            [self.mySource addObjectsFromArray:[DDGroupModel mj_objectArrayWithKeyValuesArray:myGroupList]];
            
            NSArray * foundGroupList = [data objectForKey:@"myGroupList"];
            [self.addSource addObjectsFromArray:[DDGroupModel mj_objectArrayWithKeyValuesArray:foundGroupList]];
            
            NSArray * publicGroupList = [data objectForKey:@"publicGroupList"];
            [self.otherSource addObjectsFromArray:[DDGroupModel mj_objectArrayWithKeyValuesArray:publicGroupList]];
        }
        
//        DDGroupModel * createModel = [[DDGroupModel alloc] initWithCreate];
//        [self.mySource addObject:createModel];
        
        [self.collectionView reloadData];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 360.f;
    
    UIView * BGView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:BGView];
    [BGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight);
    gradientLayer.opacity = .8f;
    [BGView.layer addSublayer:gradientLayer];
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((kMainBoundsWidth - 50 * scale) / 2.f, 150 * scale);
    layout.headerReferenceSize = CGSizeMake(kMainBoundsWidth, 40 * scale);
    layout.minimumLineSpacing = 10 * scale;
    layout.minimumInteritemSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerClass:[DDGroupCollectionViewCell class] forCellWithReuseIdentifier:@"DDGroupCollectionViewCell"];
    [self.collectionView registerClass:[DDGroupTitleReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"DDGroupTitleReusableView"];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(20 * scale);
        make.right.mas_equalTo(-20 * scale);
        make.bottom.mas_equalTo(0);
    }];
    
    UIButton * backButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [backButton setImage:[UIImage imageNamed:@"contentClose"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15 * scale);
        make.top.mas_equalTo(40 * scale);
        make.width.height.mas_equalTo(30 * scale);
    }];
    
    UIButton * searchButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [searchButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [self.view addSubview:searchButton];
    [searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15 * scale);
        make.top.mas_equalTo(40 * scale);
        make.width.height.mas_equalTo(35 * scale);
    }];
    [searchButton addTarget:self action:@selector(searchButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)searchButtonDidClicked
{
    DDGroupSearchViewController * search = [[DDGroupSearchViewController alloc] init];
    
    CATransition *transition = [CATransition animation];
    
    transition.duration = 0.35;
    
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    
    transition.type = kCATransitionPush;
    
    transition.subtype = kCATransitionFromTop;
    
    transition.delegate = self;
    
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    [self.navigationController pushViewController:search animated:NO];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 4;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.defaultSource.count;
    }else if (section == 1) {
        return self.mySource.count;
    }else if (section == 2) {
        return self.addSource.count;
    }else{
        return self.otherSource.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DDGroupCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DDGroupCollectionViewCell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        DDGroupModel * model = [self.defaultSource objectAtIndex:indexPath.row];
        [cell configWithModel:model];
        if (model.cid == self.currentModel.cid) {
            [cell showChooseImageView];
        }else{
            [cell hiddenChooseImageView];
        }
    }else if (indexPath.section == 1) {
        DDGroupModel * model = [self.mySource objectAtIndex:indexPath.row];
        [cell configWithModel:model];
        if (model.cid == self.currentModel.cid) {
            [cell showChooseImageView];
        }else{
            [cell hiddenChooseImageView];
        }
    }else if (indexPath.section == 2) {
        DDGroupModel * model = [self.addSource objectAtIndex:indexPath.row];
        [cell configWithModel:model];
        if (model.cid == self.currentModel.cid) {
            [cell showChooseImageView];
        }else{
            [cell hiddenChooseImageView];
        }
    }else if (indexPath.section == 3) {
        DDGroupModel * model = [self.otherSource objectAtIndex:indexPath.row];
        [cell configWithModel:model];
        if (model.cid == self.currentModel.cid) {
            [cell showChooseImageView];
        }else{
            [cell hiddenChooseImageView];
        }
    }
    
    __weak typeof(self) weakSelf = self;
    cell.groupDidChooseHandle = ^{
        [weakSelf didSelectItemAtIndexPath:indexPath];
    };
    
    return cell;
}

- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == self.defaultSource.count-1) {
            DDCreateGroupViewController * create = [[DDCreateGroupViewController alloc] init];
            create.delegate = self;
            [self.navigationController pushViewController:create animated:YES];
        }else{
            DDGroupModel * model = [self.defaultSource objectAtIndex:indexPath.row];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DDGroupDidChange" object:model];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }else if (indexPath.section == 1) {
        DDGroupModel * model = [self.mySource objectAtIndex:indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DDGroupDidChange" object:model];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if (indexPath.section == 2) {
        DDGroupModel * model = [self.addSource objectAtIndex:indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DDGroupDidChange" object:model];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        DDGroupModel * model = [self.otherSource objectAtIndex:indexPath.row];
        DDGroupDetailViewController * detail = [[DDGroupDetailViewController alloc] initWithModel:model];
        detail.delegate = self;
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (void)authorNeedUpdateGroupList
{
    [self setupData];
}

- (void)userNeedUpdateGroupList
{
    [self setupData];
}

- (void)groupDidCreate
{
    [self setupData];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        DDGroupTitleReusableView * view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"DDGroupTitleReusableView" forIndexPath:indexPath];
        
        if (indexPath.section == 0) {
            [view configWithTitle:@"-  默 认 群  -"];
        }else if (indexPath.section == 1) {
            [view configWithTitle:@"-  我 创 建 的 群  -"];
        }else if (indexPath.section == 2){
            [view configWithTitle:@"-  我 加 入 的 群  -"];
        }else{
            [view configWithTitle:@"-  其 他 公 开 群  -"];
        }
        
        return view;
    }
    
    return nil;
}

- (void)backButtonDidClicked
{
    CATransition *transition = [CATransition animation];
    
    transition.duration = 0.35;
    
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    
    transition.type = kCATransitionPush;
    
    transition.subtype = kCATransitionFromBottom;
    
    transition.delegate = self;
    
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[DDBackWidow shareWindow] hidden];
    });
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (NSMutableArray *)mySource
{
    if (!_defaultSource) {
        _defaultSource = [[NSMutableArray alloc] init];
    }
    return _defaultSource;
}

- (NSMutableArray *)defaultSource
{
    if (!_mySource) {
        _mySource = [[NSMutableArray alloc] init];
    }
    return _mySource;
}

- (NSMutableArray *)otherSource
{
    if (!_otherSource) {
        _otherSource = [[NSMutableArray alloc] init];
    }
    return _otherSource;
}

- (NSMutableArray *)addSource
{
    if (!_addSource) {
        _addSource = [[NSMutableArray alloc] init];
    }
    return _addSource;
}


@end
