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
#import "DTieDetailRequest.h"
#import "DDCollectionTableViewCell.h"

@interface DDCollectionListViewCell ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSDictionary * dataDict;

@property (nonatomic, strong) UIImageView * baseImageView;
@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, assign) BOOL isFirstRead;

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

- (void)configWithModel:(DTieModel *)model
{
    self.isFirstRead = YES;
    [self.baseImageView sd_setImageWithURL:[NSURL URLWithString:model.postFirstPicture]];
    self.tableView.hidden = YES;
    
    if (model.details) {
        self.model = model;
        self.tableView.hidden = NO;
        [self.tableView reloadData];
        return;
    }
    
    self.tableView.hidden = YES;
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:model.postId type:4 start:0 length:10];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                [model mj_setKeyValues:data];
                self.model = model;
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
        model.detailContent = self.model.postFirstPicture;
        [cell configWithModel:model];
        return cell;
    }
    
    DTieEditModel * model = [self.model.details objectAtIndex:indexPath.row - 1];
    
    if (self.isFirstRead) {
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString * createTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)self.model.createTime]];
        NSString * updateTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(double)self.model.updateTime]];
        [cell configFirstWithModel:model firstTime:createTime location:self.model.sceneAddress updateTime:updateTime];
    }
    
    if (model.type == DTieEditType_Text) {
        self.isFirstRead = NO;
    }
    
    return cell;
}

@end
