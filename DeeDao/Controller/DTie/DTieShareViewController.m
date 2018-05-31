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

@interface DTieShareViewController ()<XWDragCellCollectionViewDataSource, XWDragCellCollectionViewDelegate, XRWaterfallLayoutDelegate>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UILabel * titleLabel;

@property (nonatomic, strong) NSMutableArray * shareList;

@property (nonatomic, strong) XWDragCellCollectionView *mainView;
@property (nonatomic, assign) BOOL isEdit;

@end

@implementation DTieShareViewController

- (instancetype)initWithShareList:(NSMutableArray *)shareList
{
    if (self = [super init]) {
        self.shareList = shareList;
    }
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
    UIImage *image = self.shareList[indexPath.item];
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
    
    UIImage * image = [self.shareList objectAtIndex:indexPath.row];
    [cell configImageWith:image isEdit:self.isEdit];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(cell) weakCell = cell;
    cell.cancleButtonClicked = ^{
        NSIndexPath * tempIndexPath = [self.mainView indexPathForCell:weakCell];
        [weakSelf.shareList removeObjectAtIndex:tempIndexPath.item];
        [weakSelf.mainView deleteItemsAtIndexPaths:@[tempIndexPath]];
        [[DDShareManager shareManager] updateNumber];
    };
    
    [self.mainView.longPressGesture requireGestureRecognizerToFail:cell.tap];
    
    return cell;
}

- (NSArray *)dataSourceArrayOfCollectionView:(XWDragCellCollectionView *)collectionView{
    return self.shareList;
}

#pragma mark - <XWDragCellCollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击了%ld",indexPath.row);
}

- (void)dragCellCollectionView:(XWDragCellCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray{
    [self.shareList removeAllObjects];
    [self.shareList addObjectsFromArray:newDataArray];
}

- (void)dragCellCollectionView:(XWDragCellCollectionView *)collectionView cellWillBeginMoveAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEdit) {
        return;
    }
    
    self.isEdit = YES;
//    [self.mainView reloadData];
    [collectionView.visibleCells makeObjectsPerformSelector:@selector(configEdit:) withObject:@(self.isEdit)];
    [self.mainView xw_enterEditingModel];
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
    [self.view addSubview:self.mainView];
    
    [self createTopView];
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
    
    self.titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentCenter];
    self.titleLabel.text = @"分享列表";
    [self.topView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
    UIButton * saveButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] title:@"确定"];
    [DDViewFactoryTool cornerRadius:12 * scale withView:saveButton];
    saveButton.layer.borderWidth = .5f;
    saveButton.layer.borderColor = UIColorFromRGB(0xFFFFFF).CGColor;
    [saveButton addTarget:self action:@selector(saveButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:saveButton];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(144 * scale);
        make.height.mas_equalTo(72 * scale);
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(-60 * scale);
    }];
}

- (void)saveButtonDidClicked
{
    if (self.isEdit) {
        self.isEdit = NO;
        [self.mainView reloadData];
        [self.mainView xw_stopEditingModel];
    }else{
        [[WeChatManager shareManager] shareTimeLineWithImages:self.shareList title:@"分享" viewController:self];
    }
}

- (void)backButtonDidClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
