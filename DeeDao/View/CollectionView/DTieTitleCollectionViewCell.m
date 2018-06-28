//
//  DTieTitleCollectionViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/20.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieTitleCollectionViewCell.h"
#import "DDViewFactoryTool.h"
#import "DDTool.h"
#import <UIImageView+WebCache.h>
#import <Masonry.h>
#import "DDShareManager.h"
#import "DTiePOIViewController.h"
#import "UserManager.h"

@interface DTieTitleCollectionViewCell ()

@property (nonatomic, strong) UIImageView * detailImageView;
@property (nonatomic, strong) DTieModel * dtieModel;
@property (nonatomic, strong) DTieEditModel * model;

@property (nonatomic, strong) UIImageView * firstMarkImageView;
@property (nonatomic, strong) UIImageView * secondMarkImageView;

@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UIButton * locationButton;
@property (nonatomic, strong) UILabel * locationLabel;
@property (nonatomic, strong) UILabel * summaryLabel;

@property (nonatomic, strong) UIView * baseView;

@end

@implementation DTieTitleCollectionViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createDetailTitleCell];
    }
    return self;
}

- (void)createDetailTitleCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.baseView];
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.right.mas_equalTo(-30 * scale);
        make.top.mas_equalTo(40 * scale);
        make.height.mas_equalTo((kMainBoundsWidth - 360 * scale) / 4.f * 3.f);
    }];
    self.baseView.layer.cornerRadius = 24 * scale;
    self.baseView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    self.baseView.layer.shadowOpacity = .3f;
    self.baseView.layer.shadowRadius = 12 * scale;
    self.baseView.layer.shadowOffset = CGSizeMake(0, 6 * scale);
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.detailImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.detailImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.baseView addSubview:self.detailImageView];
    [self.detailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.detailImageView];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.detailImageView.mas_bottom).offset(60 * scale);
        make.left.mas_equalTo(30 * scale);
        make.right.mas_equalTo(-30 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
    
    self.locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:self.locationButton];
    [self.locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(80 * scale);
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(0 * scale);
    }];
    [self.locationButton addTarget:self action:@selector(locationShouldChooseNavi) forControlEvents:UIControlEventTouchUpInside];
    
    self.locationLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [self.locationButton addSubview:self.locationLabel];
    [self.locationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.right.mas_equalTo(-160 * scale);
        make.height.mas_equalTo(45 * scale);
        make.centerY.mas_equalTo(0);
    }];
    
    UIImageView * locationImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"locationEdit"]];
    [self.locationButton addSubview:locationImageView];
    [locationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
        make.width.height.mas_equalTo(48 * scale);
    }];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xFBEFF2);
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.locationButton.mas_bottom).offset(15 * scale);
        make.left.mas_equalTo(30 * scale);
        make.right.mas_equalTo(-30 * scale);
        make.height.mas_equalTo(3 * scale);
    }];
    
    self.summaryLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangMedium(72 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    self.summaryLabel.numberOfLines = 0;
    [self.contentView addSubview:self.summaryLabel];
    [self.summaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lineView.mas_bottom).offset(40 * scale);
        make.left.mas_equalTo(30 * scale);
        make.right.mas_equalTo(-30 * scale);
        make.bottom.mas_lessThanOrEqualTo(-10 * scale);
    }];
    
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDidHandle:)];
    self.detailImageView.userInteractionEnabled = YES;
    [self.detailImageView addGestureRecognizer:longPress];
    
    self.firstMarkImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"DTieCollection"]];
    [self.contentView addSubview:self.firstMarkImageView];
    [self.firstMarkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0 * scale);
        make.width.mas_equalTo(84 * scale);
        make.height.mas_equalTo(348 * scale);
        make.right.mas_equalTo(self.detailImageView.mas_right).offset(-30 * scale);
    }];
    self.firstMarkImageView.hidden = YES;
    
    self.secondMarkImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"DTieBeFoundTo"]];
    [self.contentView addSubview:self.secondMarkImageView];
    [self.secondMarkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0 * scale);
        make.width.mas_equalTo(84 * scale);
        make.height.mas_equalTo(348 * scale);
        make.right.mas_equalTo(self.detailImageView.mas_right).offset(-124 * scale);
    }];
    self.secondMarkImageView.hidden = YES;
}

- (void)locationShouldChooseNavi
{
    DTieModel * model = self.dtieModel;
    if (model) {
        UITabBarController * tab = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        if ([tab isKindOfClass:[UITabBarController class]]) {
            UINavigationController * na = (UINavigationController *)tab.selectedViewController;
            if ([na isKindOfClass:[UINavigationController class]]) {
                DTiePOIViewController * poi = [[DTiePOIViewController alloc] initWithDtieModel:model];
                [na pushViewController:poi animated:YES];
            }
        }
    }
}

- (void)longPressDidHandle:(UILongPressGestureRecognizer *)longPress
{
    ShareImageModel * model = [[ShareImageModel alloc] init];
    NSInteger postId = self.dtieModel.cid;
    if (postId == 0) {
        postId = self.dtieModel.postId;
    }
    model.postId = postId;
    model.image = self.detailImageView.image;
    model.title = self.dtieModel.postSummary;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"pFlag == %d", 1];
    NSArray * tempArray = [self.dtieModel.details filteredArrayUsingPredicate:predicate];
    if (tempArray && tempArray.count > 0) {
        model.pflg = 1;
    }
    
    [[DDShareManager shareManager] showHandleViewWithImage:model];
}

- (void)configWithModel:(DTieEditModel *)model Dtie:(DTieModel *)dtieModel
{
    self.model = model;
    self.dtieModel = dtieModel;
    if (model.image) {
        [self.detailImageView setImage:model.image];
    }else{
        
        [self.detailImageView sd_setImageWithURL:[NSURL URLWithString:model.detailContent] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            model.image = image;
        }];
    }
    self.timeLabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:dtieModel.sceneTime];
    self.locationLabel.text = dtieModel.sceneBuilding;
    self.summaryLabel.text = dtieModel.postSummary;
    
    if (dtieModel.collectFlg == 1 && dtieModel.wyyFlg == 1) {
        [self.firstMarkImageView setImage:[UIImage imageNamed:@"DTieCollection"]];
        [self.secondMarkImageView setImage:[UIImage imageNamed:@"DTieBeFoundTo"]];
        self.firstMarkImageView.hidden = NO;
        self.secondMarkImageView.hidden = NO;
    }else if (dtieModel.collectFlg == 1){
        [self.firstMarkImageView setImage:[UIImage imageNamed:@"DTieCollection"]];
        self.firstMarkImageView.hidden = NO;
        self.secondMarkImageView.hidden = YES;
    }else if (dtieModel.wyyFlg == 1) {
        [self.firstMarkImageView setImage:[UIImage imageNamed:@"DTieBeFoundTo"]];
        self.firstMarkImageView.hidden = NO;
        self.secondMarkImageView.hidden = YES;
    }else{
        self.firstMarkImageView.hidden = YES;
        self.secondMarkImageView.hidden = YES;
    }
}

@end
