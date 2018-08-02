//
//  DTieShareViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/28.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieShareViewController.h"
#import "XWDragCellCollectionView.h"
#import "XRWaterfallLayout.h"
#import "DDShareImageCollectionViewCell.h"
#import "WeChatManager.h"
#import "DDShareManager.h"
#import "MBProgressHUD+DDHUD.h"
#import "ShareImageModel.h"
#import "DDTool.h"

@interface DTieShareViewController ()<XWDragCellCollectionViewDataSource, XWDragCellCollectionViewDelegate, XRWaterfallLayoutDelegate>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UILabel * titleLabel;

@property (nonatomic, strong) NSMutableArray * selectSource;

@property (nonatomic, strong) XWDragCellCollectionView *mainView;

@property (nonatomic, strong) UIButton * saveButton;
@property (nonatomic, strong) UIButton * clearButton;
@property (nonatomic, strong) UIView * bottomHandleView;
//@property (nonatomic, assign) BOOL isEdit;

@end

@implementation DTieShareViewController

+ (instancetype)sharedViewController
{
    static dispatch_once_t once;
    static DTieShareViewController * instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)insertShareList:(NSMutableArray *)shareList title:(NSString *)title pflg:(BOOL)pflg postId:(NSInteger)postId
{
    NSMutableArray * share = [[NSMutableArray alloc] initWithArray:[[shareList reverseObjectEnumerator] allObjects]];
    for (ShareImageModel * model in share) {
        [self.shareList insertObject:model atIndex:0];
    }
    [[DDShareManager shareManager] updateNumber];
    [self.selectSource removeAllObjects];
    [self.mainView reloadData];
    return self;
}

- (instancetype)insertShareList:(NSMutableArray *)shareList
{
    NSMutableArray * share = [[NSMutableArray alloc] initWithArray:[[shareList reverseObjectEnumerator] allObjects]];
    for (ShareImageModel * model in share) {
        [self.shareList insertObject:model atIndex:0];
    }
    [[DDShareManager shareManager] updateNumber];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
}

//根据item的宽度与indexPath计算每一个item的高度
- (CGFloat)waterfallLayout:(XRWaterfallLayout *)waterfallLayout itemHeightForWidth:(CGFloat)itemWidth atIndexPath:(NSIndexPath *)indexPath {
    //根据图片的原始尺寸，及显示宽度，等比例缩放来计算显示高度
    ShareImageModel * model = [self.shareList objectAtIndex:indexPath.item];
    UIImage *image = model.image;
    return itemWidth * image.size.height / image.size.width;
}

#pragma mark - <XWDragCellCollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.shareList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DDShareImageCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DDShareImageCollectionViewCell" forIndexPath:indexPath];
    
    ShareImageModel * model = [self.shareList objectAtIndex:indexPath.item];
    UIImage * image = model.image;
//    [cell configImageWith:image isEdit:self.isEdit];
    [cell configWithImage:image];
    
    if ([self.selectSource containsObject:model]) {
        NSInteger i = [self.selectSource indexOfObject:model] + 1;
        [cell configIndex:i hidden:NO];
    }else{
        [cell configIndex:0 hidden:YES];
    }
    
    if (model.PFlag == 1) {
        [cell configDeeDaoEnable:YES];
    }else{
        [cell configDeeDaoEnable:NO];
    }
    
//    __weak typeof(self) weakSelf = self;
//    __weak typeof(cell) weakCell = cell;
//    cell.cancleButtonClicked = ^{
//        NSIndexPath * tempIndexPath = [self.mainView indexPathForCell:weakCell];
//        [weakSelf.shareList removeObjectAtIndex:tempIndexPath.item];
//        [weakSelf.mainView deleteItemsAtIndexPaths:@[tempIndexPath]];
//        [[DDShareManager shareManager] updateNumber];
//    };
    
//    [self.mainView.longPressGesture requireGestureRecognizerToFail:cell.tap];
    
    return cell;
}

- (NSArray *)dataSourceArrayOfCollectionView:(XWDragCellCollectionView *)collectionView{
    return self.shareList;
}

#pragma mark - <XWDragCellCollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!self.mainView.editing) {
        ShareImageModel * model = [self.shareList objectAtIndex:indexPath.row];
        if ([self.selectSource containsObject:model]) {
            [self.selectSource removeObject:model];
            
            [self.mainView reloadData];
            
        }else{
            if (self.selectSource.count >= 9) {
                [MBProgressHUD showTextHUDWithText:@"最多支持分享9张" inView:self.view];
            }else{
                [self.selectSource addObject:model];
                
                [self.mainView reloadData];
            }
        }
    }else{
        [self.mainView xw_stopEditingModel];
        self.clearButton.hidden = NO;
        self.bottomHandleView.hidden = NO;
    }
}

- (void)dragCellCollectionView:(XWDragCellCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray{
    [self.shareList removeAllObjects];
    [self.shareList addObjectsFromArray:newDataArray];
}

- (void)dragCellCollectionView:(XWDragCellCollectionView *)collectionView cellWillBeginMoveAtIndexPath:(NSIndexPath *)indexPath
{
//    if (self.isEdit) {
//        return;
//    }
    
//    self.isEdit = YES;
//    [self.mainView reloadData];
//    [collectionView.visibleCells makeObjectsPerformSelector:@selector(configEdit:) withObject:@(self.isEdit)];
    if (!self.mainView.editing) {
        [self.mainView xw_enterEditingModel];
        
        [self.saveButton setTitle:@"确定" forState:UIControlStateNormal];
        self.clearButton.hidden = YES;
        self.bottomHandleView.hidden = YES;
    }
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    //创建瀑布流布局
    XRWaterfallLayout *waterfall = [XRWaterfallLayout waterFallLayoutWithColumnCount:2];
    
    //或者一次性设置
    [waterfall setColumnSpacing:40 * scale rowSpacing:40 * scale sectionInset:UIEdgeInsetsMake(10 * scale, 40 * scale, 10 * scale, 40 * scale)];
    
    //设置代理，实现代理方法
    waterfall.delegate = self;
    CGRect frame = self.view.bounds;
    frame.origin.y = (220 + kStatusBarHeight) * scale;
    frame.size.height -= (220 + kStatusBarHeight) * scale;
    self.mainView = [[XWDragCellCollectionView alloc] initWithFrame:frame collectionViewLayout:waterfall];
    self.mainView.delegate = self;
    self.mainView.dataSource = self;
    self.mainView.shakeLevel = 1.5f;
//    self.mainView.shakeWhenMoveing = NO;
    self.mainView.backgroundColor = self.view.backgroundColor;
    [self.mainView registerClass:[DDShareImageCollectionViewCell class] forCellWithReuseIdentifier:@"DDShareImageCollectionViewCell"];
    self.mainView.contentInset = UIEdgeInsetsMake(0, 0, 324 * scale, 0);
    [self.view addSubview:self.mainView];
    
    self.bottomHandleView = [[UIView alloc] initWithFrame:CGRectZero];
    self.bottomHandleView.backgroundColor = [UIColorFromRGB(0xFFFFFF) colorWithAlphaComponent:.7f];
    [self.view addSubview:self.bottomHandleView];
    [self.bottomHandleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(324 * scale);
    }];
    
    UIButton * handleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:@"加码并保存至手机相册"];
    [DDViewFactoryTool cornerRadius:24 * scale withView:handleButton];
    handleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    handleButton.layer.borderWidth = 3 * scale;
    [self.bottomHandleView addSubview:handleButton];
    [handleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(144 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.centerY.mas_equalTo(0);
    }];
    [handleButton addTarget:self action:@selector(handleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self createTopView];
}

- (void)handleButtonDidClicked
{
    if (self.selectSource.count == 0) {
        [MBProgressHUD showTextHUDWithText:@"请选择要分享的图片" inView:self.view];
    }else if (self.selectSource.count > 9){
        [MBProgressHUD showTextHUDWithText:@"最多只能分享9张图片" inView:self.view];
    }else {
        [DDTool userLibraryAuthorizationStatusWithSuccess:^{
            
            [[WeChatManager shareManager] savePhotoWithImages:self.selectSource title:@"分享" viewController:self];
            
        } failure:^{
            [MBProgressHUD showTextHUDWithText:@"没有相册访问权限" inView:self.view];
        }];
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
    [backButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.bottom.mas_equalTo(-15 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    self.titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    self.titleLabel.text = @"地到分享";
    [self.topView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
    self.saveButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] title:@"分享"];
    [DDViewFactoryTool cornerRadius:12 * scale withView:self.saveButton];
    self.saveButton.layer.borderWidth = .5f;
    self.saveButton.layer.borderColor = UIColorFromRGB(0xFFFFFF).CGColor;
    [self.saveButton addTarget:self action:@selector(saveButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.saveButton];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(144 * scale);
        make.height.mas_equalTo(72 * scale);
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(-60 * scale);
    }];
    
    self.clearButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] title:@"清空"];
    [DDViewFactoryTool cornerRadius:12 * scale withView:self.clearButton];
    self.clearButton.layer.borderWidth = .5f;
    self.clearButton.layer.borderColor = UIColorFromRGB(0xFFFFFF).CGColor;
    [self.clearButton addTarget:self action:@selector(clearButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.clearButton];
    [self.clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(144 * scale);
        make.height.mas_equalTo(72 * scale);
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.saveButton.mas_left).offset(-40 * scale);
    }];
}

- (void)clearButtonDidClicked
{
    if (self.mainView.editing) {
        [self.mainView xw_stopEditingModel];
    }
    [self.shareList removeAllObjects];
    [self.selectSource removeAllObjects];
    [self.mainView reloadData];
    [[DDShareManager shareManager] updateNumber];
}

- (void)saveButtonDidClicked
{
    if (self.mainView.editing) {
        [self.mainView xw_stopEditingModel];
        [self.saveButton setTitle:@"分享" forState:UIControlStateNormal];
        self.clearButton.hidden = NO;
        self.bottomHandleView.hidden = NO;
    }else{
        if (self.selectSource.count == 0) {
            [MBProgressHUD showTextHUDWithText:@"请选择要分享的图片" inView:self.view];
        }else if (self.selectSource.count > 9){
            [MBProgressHUD showTextHUDWithText:@"最多只能分享9张图片" inView:self.view];
        }else {
            [[WeChatManager shareManager] shareTimeLineWithImages:self.selectSource title:@"分享" viewController:self];
        }
    }
}

- (void)backButtonDidClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSMutableArray *)shareList
{
    if (!_shareList) {
        _shareList = [[NSMutableArray alloc] init];
    }
    return _shareList;
}

- (NSMutableArray *)selectSource
{
    if (!_selectSource) {
        _selectSource = [[NSMutableArray alloc] init];
    }
    return _selectSource;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mainView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MBProgressHUD showTextHUDWithText:@"长按调整图片" inView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self clearButtonDidClicked];
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
