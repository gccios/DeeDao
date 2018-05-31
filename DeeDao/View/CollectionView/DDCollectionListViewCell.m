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
#import "DDLocationManager.h"
#import "DDTool.h"

@interface DDCollectionListViewCell ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSDictionary * dataDict;

@property (nonatomic, strong) UIImageView * baseImageView;
@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, assign) BOOL isFirstRead;
@property (nonatomic, assign) NSIndexPath * firestIndex;
@property (nonatomic, strong) UIView * baseView;
@property (nonatomic, strong) UIImageView * collectImageView;

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
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.baseView = [[UIView alloc] init];
    self.baseView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.contentView addSubview:self.baseView];
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(50 * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    self.baseImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFit image:[UIImage imageNamed:@"test"]];
    [self.baseView addSubview:self.baseImageView];
    [self.baseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];

    [DDViewFactoryTool cornerRadius:24 * scale withView:self.baseView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.baseView.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = kMainBoundsHeight - 594 * scale - 50 * scale;
    self.tableView.pagingEnabled = YES;
    [self.tableView registerClass:[DDCollectionTableViewCell class] forCellReuseIdentifier:@"DDCollectionTableViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.baseView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.collectImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [self addSubview:self.collectImageView];
    [self.collectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0 * scale);
        make.right.mas_equalTo(-40 * scale);
        make.width.mas_equalTo(60 * scale);
        make.height.mas_equalTo(400 * scale);
    }];
}

- (void)configWithModel:(DTieModel *)model tag:(NSInteger)tag
{
    self.tableView.tag = tag;
    self.isFirstRead = YES;
    [self.baseImageView setImage:[UIImage new]];
    [self.baseImageView sd_cancelCurrentAnimationImagesLoad];
    [self.baseImageView sd_cancelCurrentImageLoad];
    [self.baseImageView sd_setImageWithURL:[NSURL URLWithString:model.postFirstPicture]];
    
    if (model.wyyFlg) {
        [self.collectImageView setImage:[UIImage imageNamed:@"yaoyueshu"]];
        self.collectImageView.hidden = NO;
    }else if (model.collectFlg) {
        [self.collectImageView setImage:[UIImage imageNamed:@"shoucangshu"]];
        self.collectImageView.hidden = NO;
    }else{
        self.collectImageView.hidden = YES;
    }
    
    if (model.details) {
        self.model = model;
        [self.tableView setContentOffset:CGPointZero animated:NO];
        self.tableView.hidden = NO;
        [self.tableView reloadData];
        return;
    }
    
    self.tableView.hidden = YES;
//    [DTieDetailRequest cancelRequest];
    
    NSInteger postID = model.postId;
    if (postID == 0) {
        postID = model.cid;
    }
    
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:postID type:4 start:0 length:10];
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
    
    if (model.pFlag) {
        if ([[DDLocationManager shareManager] contentIsCanSeeWith:self.model detailModle:model]) {
            [cell configCanSee:YES];
        }else{
            [cell configCanSee:NO];
            return cell;
        }
    }
    
    if (model.type == DTieEditType_Image || model.type == DTieEditType_Video) {
        [cell configWithModel:model];
        return cell;
    }
    
    if (self.isFirstRead) {
        self.isFirstRead = NO;
        self.firestIndex = indexPath;
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
        NSString * createTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)self.model.sceneTime / 1000]];
        NSString * updateTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)self.model.updateTime / 1000]];
        [cell configFirstWithModel:model firstTime:createTime location:self.model.sceneAddress updateTime:updateTime];
    }else{
        
        if (self.firestIndex && [indexPath isEqual:self.firestIndex]) {
            NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
            NSString * createTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)self.model.sceneTime / 1000]];
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
    if (self.tableViewClickHandle) {
        self.tableViewClickHandle([NSIndexPath indexPathForItem:tableView.tag inSection:0]);
    }
}

@end
