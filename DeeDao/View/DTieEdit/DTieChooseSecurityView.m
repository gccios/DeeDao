//
//  DTieChooseSecurityView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/11/16.
//  Copyright © 2018 郭春城. All rights reserved.
//

#import "DTieChooseSecurityView.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import "SecurityRequest.h"
#import "SecurityGroupModel.h"
#import "DTieNewSecurityCell.h"
#import "GetDtieSecurityRequest.h"
#import "DTieEditRequest.h"

@interface DTieChooseSecurityView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) DTieModel * model;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@end

@implementation DTieChooseSecurityView

- (instancetype)initWithFrame:(CGRect)frame model:(DTieModel *)model
{
    if (self = [super initWithFrame:frame]) {
        
        self.model = model;
        self.dataSource = [[NSMutableArray alloc] init];
        
        [self createChooseSecurityView];
    }
    return self;
}

- (void)requestDataSource
{
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    
    SecurityGroupModel * model1 = [[SecurityGroupModel alloc] init];
    model1.cid = -1;
    model1.securitygroupName = @"所有朋友";
    model1.isNotification = YES;
    [self.dataSource addObject:model1];
    
    SecurityGroupModel * model2 = [[SecurityGroupModel alloc] init];
    model2.cid = -2;
    model2.securitygroupName = DDLocalizedString(@"My Fans");
    model2.isNotification = YES;
    [self.dataSource addObject:model2];
    
//    NSInteger accountFlg = self.model.landAccountFlg;
    
    SecurityRequest * request = [[SecurityRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                
                for (NSInteger i = 0; i < data.count; i++) {
                    NSDictionary * dict = [data objectAtIndex:i];
                    NSDictionary * result = [dict objectForKey:@"securityGroup"];
                    SecurityGroupModel * model = [SecurityGroupModel mj_objectWithKeyValues:result];
                    model.isNotification = YES;
                    
                    [self.dataSource addObject:model];
                }
            }
        }
        
        GetDtieSecurityRequest * request1 = [[GetDtieSecurityRequest alloc] initWithModel:self.model];
        [request1 sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            model1.isChoose = YES;
//            if (accountFlg == 3) {
//                model1.isChoose = YES;
//            }else if (accountFlg == 5) {
//                model2.isChoose = YES;
//            }else if (accountFlg == 6) {
//                model1.isChoose = YES;
//                model2.isChoose = YES;
//            }else if (accountFlg == 7){
//                model2.isChoose = YES;
//            }
            
            if (KIsDictionary(response)) {
                NSArray * data = [response objectForKey:@"data"];
                for (NSDictionary * dict in data) {
                    SecurityGroupModel * model = [SecurityGroupModel mj_objectWithKeyValues:dict];
                    
                    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"cid == %ld", model.cid];
                    NSArray * tempArray = [self.dataSource filteredArrayUsingPredicate:predicate];
                    if (tempArray && tempArray.count > 0) {
                        model.isChoose = YES;;
                    }
                    [self.dataSource addObject:model];
                }
            }
            [self.tableView reloadData];
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [self.tableView reloadData];
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
            [self.tableView reloadData];
            
        }];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)createChooseSecurityView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
    
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth - 240 * scale, kMainBoundsHeight / 2.f)];
    contentView.backgroundColor = UIColorFromRGB(0xffffff);
    [DDViewFactoryTool cornerRadius:40 * scale withView:contentView];
    [self addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.mas_equalTo(kMainBoundsWidth - 240 * scale);
        make.height.mas_equalTo(kMainBoundsHeight / 2.f);
    }];
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentCenter];
    titleLabel.text = @"请选择权限";
    [contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(120 * scale);
    }];
    
    UIView * linewView = [[UIView alloc] initWithFrame:CGRectZero];
    linewView.backgroundColor = UIColorFromRGB(0x999999);
    [titleLabel addSubview:linewView];
    [linewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(2 * scale);
    }];
    
    UIView * handleView = [[UIView alloc] initWithFrame:CGRectZero];
    [contentView addSubview:handleView];
    [handleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(120 * scale);
    }];
    
    UIView * bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
    bottomLineView.backgroundColor = UIColorFromRGB(0x999999);
    [handleView addSubview:bottomLineView];
    [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(2 * scale);
    }];
    
    UIView * handleLineView = [[UIView alloc] initWithFrame:CGRectZero];
    [handleView addSubview:handleLineView];
    [handleLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.height.mas_equalTo(40 * scale);
        make.width.mas_equalTo(2 * scale);
    }];
    
    UIButton * leftButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0x333333) title:DDLocalizedString(@"Cancel")];
    [leftButton addTarget:self action:@selector(leftButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [handleView addSubview:leftButton];
    [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(0);
        make.right.mas_equalTo(handleLineView.mas_left);
    }];
    
    UIButton * rightButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0x333333) title:DDLocalizedString(@"Yes")];
    [rightButton addTarget:self action:@selector(rightButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [handleView addSubview:rightButton];
    [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(0);
        make.left.mas_equalTo(handleLineView.mas_right);
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = contentView.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[DTieNewSecurityCell class] forCellReuseIdentifier:@"DTieNewSecurityCell"];
    self.tableView.rowHeight = 90 * scale;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [contentView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(handleView.mas_top);
    }];
    self.tableView.contentInset = UIEdgeInsetsMake(30 * scale, 0 * scale, 30 * scale, 0 * scale);
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTieNewSecurityCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieNewSecurityCell" forIndexPath:indexPath];
    
    SecurityGroupModel * model = [self.dataSource objectAtIndex:indexPath.row];
    [cell configWithModel:model];
    
    return cell;
}

- (void)show
{
    [self requestDataSource];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (void)leftButtonDidClicked
{
    [self removeFromSuperview];
}

- (void)rightButtonDidClicked
{
    NSInteger landAccountFlg = 4;
    
    NSMutableArray * allowToSeeList = [[NSMutableArray alloc] init];
    for (SecurityGroupModel * groupModel in self.dataSource) {
        
        if (groupModel.isChoose == YES) {
            if (groupModel.cid == -1) {
                if (landAccountFlg == 5) {
                    landAccountFlg = 6;
                }else{
                    landAccountFlg = 3;
                }
            }else if (groupModel.cid == -2){
                if (landAccountFlg == 3) {
                    landAccountFlg = 6;
                }else{
                    landAccountFlg = 5;
                }
            }else{
                [allowToSeeList addObject:@(groupModel.cid)];
            }
        }
    }
    
    if (allowToSeeList.count > 0) {
        if (landAccountFlg == 2) {
            landAccountFlg = 2;
        }else if (landAccountFlg == 3) {
            landAccountFlg = 3;
        }else if (landAccountFlg == 5) {
            landAccountFlg = 7;
        }else if (landAccountFlg == 6) {
            landAccountFlg = 6;
        }
    }else{
        allowToSeeList = nil;
        if (landAccountFlg == 4) {
            landAccountFlg = 0;
        }
    }
    
    if (landAccountFlg > 0) {
        self.model.landAccountFlg = landAccountFlg;
        
        DTieEditRequest * request = [[DTieEditRequest alloc] initWithAccountFlg:landAccountFlg groupList:allowToSeeList postID:self.model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
        }];
    }
    
    [self removeFromSuperview];
}

@end
