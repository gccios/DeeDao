//
//  ChooseCategoryView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/16.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "ChooseCategoryView.h"
#import "DDViewFactoryTool.h"
#import "ChooseCategroyCell.h"
#import <Masonry.h>

@interface ChooseCategoryView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView * collectionView;

@property (nonatomic, strong) NSArray * titleArray;

@end

@implementation ChooseCategoryView

- (instancetype)init
{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        [self createChooseTimeView];
    }
    return self;
}

- (void)createChooseTimeView
{
    self.titleArray = @[DDLocalizedString(@"Blogger"), DDLocalizedString(@"Friend"), DDLocalizedString(@"Reminder"), DDLocalizedString(@"Open"), DDLocalizedString(@"My")];
    
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
    layout.itemSize = CGSizeMake((kMainBoundsWidth - 180 * scale) / 2, 120 * scale);
    layout.minimumLineSpacing = 59 * scale;
    layout.minimumInteritemSpacing = 60 * scale;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerClass:[ChooseCategroyCell class] forCellWithReuseIdentifier:@"ChooseCategroyCell"];
    self.collectionView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(59 * scale, 59 * scale, 59 * scale, 59 * scale);
    [contenView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cancleButton.mas_bottom).offset(20 * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.titleArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ChooseCategroyCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ChooseCategroyCell" forIndexPath:indexPath];
    
    [cell configTitle:self.titleArray[indexPath.row]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.handleButtonClicked) {
        
        NSInteger tag = 0;
        if (indexPath.row == 0) {
            tag = 8;
        }else if (indexPath.row == 1) {
            tag = 7;
        }else if (indexPath.row == 2) {
            tag = 10;
        }else if (indexPath.row == 3) {
            tag = 6;
        }else if (indexPath.row == 4) {
            tag = 1;
        }
        
        self.handleButtonClicked(tag);
        
    }
    [self removeFromSuperview];
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (void)cancleButtonDidClicked
{
    [self removeFromSuperview];
}

@end
