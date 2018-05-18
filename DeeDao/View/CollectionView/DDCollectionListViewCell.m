//
//  DDCollectionListViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/16.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDCollectionListViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import <UIView+WebCache.h>
#import "DTieDetailRequest.h"
#import "DDCollectionTableViewCell.h"
#import "TYCyclePagerView.h"

@interface DDCollectionListViewCell ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSDictionary * dataDict;

@property (nonatomic, strong) UIImageView * baseImageView;
@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, assign) BOOL isFirstRead;
@property (nonatomic, assign) NSIndexPath * firestIndex;

@end

@implementation DDCollectionListViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createListViewCell];
    }
    return self;
}

- (void)createListViewCell
{
    self.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.baseImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFit image:[UIImage imageNamed:@"test"]];
    [self.contentView addSubview:self.baseImageView];
    [self.baseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];

    [DDViewFactoryTool cornerRadius:24 * scale withView:self];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = kMainBoundsHeight - 594 * scale;
    self.tableView.pagingEnabled = YES;
    [self.tableView registerClass:[DDCollectionTableViewCell class] forCellReuseIdentifier:@"DDCollectionTableViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)configWithModel:(DTieModel *)model tag:(NSInteger)tag
{
    self.tableView.tag = tag;
    self.isFirstRead = YES;
    [self.baseImageView sd_cancelCurrentAnimationImagesLoad];
    [self.baseImageView sd_cancelCurrentImageLoad];
    [self.baseImageView sd_setImageWithURL:[NSURL URLWithString:model.postFirstPicture]];
    self.tableView.hidden = YES;
    
    if (model.details) {
        self.model = model;
        [self.tableView setContentOffset:CGPointZero animated:NO];
        self.tableView.hidden = NO;
        [self.tableView reloadData];
        return;
    }
    
    self.tableView.hidden = YES;
    [DTieDetailRequest cancelRequest];
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:model.postId type:4 start:0 length:10];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                [model mj_setKeyValues:data];
                self.model = model;
                [self.tableView setContentOffset:CGPointZero animated:NO];
                self.tableView.hidden = NO;
                [self.tableView reloadData];
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.model.details.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDCollectionTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DDCollectionTableViewCell" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        DTieEditModel * model = [[DTieEditModel alloc] init];
        model.type = DTieEditType_Image;
        model.detailContent = self.model.postFirstPicture;
        [cell configWithModel:model];
        return cell;
    }
    
    DTieEditModel * model = [self.model.details objectAtIndex:indexPath.row - 1];
    
    if (model.type == DTieEditType_Image || model.type == DTieEditType_Video) {
        [cell configWithModel:model];
        return cell;
    }
    
    if (self.isFirstRead) {
        self.isFirstRead = NO;
        self.firestIndex = indexPath;
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString * createTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)self.model.createTime / 1000]];
        NSString * updateTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)self.model.updateTime / 1000]];
        [cell configFirstWithModel:model firstTime:createTime location:self.model.sceneAddress updateTime:updateTime];
    }else{
        
        if (self.firestIndex && [indexPath isEqual:self.firestIndex]) {
            NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSString * createTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)self.model.createTime / 1000]];
            NSString * updateTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)self.model.updateTime / 1000]];
            [cell configFirstWithModel:model firstTime:createTime location:self.model.sceneAddress updateTime:updateTime];
        }else{
            [cell configWithModel:model];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView * view = tableView.superview;
    if ([view isKindOfClass:[TYCyclePagerView class]]) {
        TYCyclePagerView * pagerView = (TYCyclePagerView *)view;
        [pagerView.delegate pagerView:pagerView didSelectedItemCell:[pagerView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:tableView.tag inSection:0]] atIndex:tableView.tag];
    }else{
        view = view.superview;
        if ([view isKindOfClass:[TYCyclePagerView class]]) {
            TYCyclePagerView * pagerView = (TYCyclePagerView *)view;
            [pagerView.delegate pagerView:pagerView didSelectedItemCell:[pagerView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:tableView.tag inSection:0]] atIndex:tableView.tag];
        }else{
            view = view.superview;
            if ([view isKindOfClass:[TYCyclePagerView class]]) {
                TYCyclePagerView * pagerView = (TYCyclePagerView *)view;
                [pagerView.delegate pagerView:pagerView didSelectedItemCell:[pagerView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:tableView.tag inSection:0]] atIndex:tableView.tag];
            }else{
                view = view.superview;
                if ([view isKindOfClass:[TYCyclePagerView class]]) {
                    TYCyclePagerView * pagerView = (TYCyclePagerView *)view;
                    [pagerView.delegate pagerView:pagerView didSelectedItemCell:[pagerView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:tableView.tag inSection:0]] atIndex:tableView.tag];
                }
            }
        }
    }
}

@end
