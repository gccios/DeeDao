//
//  DTieMapSelectFriendView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieMapSelectFriendView.h"
#import <Masonry.h>
#import "MapFriendCollectionViewCell.h"
#import "DDViewFactoryTool.h"

@interface DTieMapSelectFriendView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray * dataSource;
@property (nonatomic, strong) NSMutableArray * selectSource;

@property (nonatomic, strong) NSArray * startSelectSource;

@property (nonatomic, strong) UICollectionView * collectionView;

@end

@implementation DTieMapSelectFriendView

- (instancetype)initWithFrendSource:(NSArray *)source
{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        self.dataSource = [NSArray arrayWithArray:source];
        [self createMapSelectFriendView];
    }
    return self;
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.startSelectSource = [[NSArray alloc] initWithArray:self.selectSource];
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MapFriendCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MapFriendCollectionViewCell" forIndexPath:indexPath];
    
    UserModel * model = [self.dataSource objectAtIndex:indexPath.row];
    [cell configWithModel:model];
    
    [cell configSelectStatus:[self.selectSource containsObject:model]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserModel * model = [self.dataSource objectAtIndex:indexPath.row];
    
    if ([self.selectSource containsObject:model]) {
        [self.selectSource removeObject:model];
        [self.collectionView reloadData];
    }else{
        [self.selectSource addObject:model];
        [self.collectionView reloadData];
    }
}

- (void)createMapSelectFriendView
{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * contenView = [[UIView alloc] initWithFrame:CGRectZero];
    contenView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self addSubview:contenView];
    [contenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(940 * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    UIButton * cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleButton setTitleColor:UIColorFromRGB(0xDB6283) forState:UIControlStateNormal];
    [cancleButton setTitle:DDLocalizedString(@"Cancel") forState:UIControlStateNormal];
    [contenView addSubview:cancleButton];
    [cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10 * scale);
        make.right.mas_equalTo(-30 * scale);
        make.width.mas_equalTo(150 * scale);
        make.height.mas_equalTo(72 * scale);
    }];
    [cancleButton addTarget:self action:@selector(cancleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kMainBoundsWidth / 3, 360 * scale);
    layout.minimumLineSpacing = 10 * scale;
    layout.minimumInteritemSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerClass:[MapFriendCollectionViewCell class] forCellWithReuseIdentifier:@"MapFriendCollectionViewCell"];
    self.collectionView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 324 * scale, 0);
    [contenView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cancleButton.mas_bottom).offset(20 * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    UIButton * handleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"OKAndSelect")];
    [DDViewFactoryTool cornerRadius:24 * scale withView:handleButton];
    handleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    handleButton.layer.borderWidth = 3 * scale;
    [contenView addSubview:handleButton];
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapSelectFriendView:didSelectFriend:)]) {
        [self.delegate mapSelectFriendView:self didSelectFriend:self.selectSource];
    }
    
    [self removeFromSuperview];
}

- (void)cancleButtonDidClicked
{
    if (self.startSelectSource) {
        self.selectSource = [[NSMutableArray alloc] initWithArray:self.startSelectSource];
    }
    [self removeFromSuperview];
}

- (void)clear
{
    [self.selectSource removeAllObjects];
    [self.collectionView reloadData];
}

- (NSMutableArray *)selectSource
{
    if (!_selectSource) {
        _selectSource = [[NSMutableArray alloc] init];
    }
    return _selectSource;
}

@end
