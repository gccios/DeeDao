//
//  DTieQuanxianView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/31.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieQuanxianView.h"
#import "DDViewFactoryTool.h"
#import "SecurityRequest.h"
#import <Masonry.h>
#import "DTieNewSecurityCell.h"
#import "MBProgressHUD+DDHUD.h"
#import <WXApi.h>

@interface DTieQuanxianView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) DTieModel * editDTModel;

@property (nonatomic, strong) UIButton * quanxianButton;
@property (nonatomic, strong) UILabel * quanxianLabel;
@property (nonatomic, assign) BOOL showQuanxian;
@property (nonatomic, strong) UIView * quanxianView;
@property (nonatomic, strong) UIButton * miquanButton;

@property (nonatomic, strong) UIButton * shareButton;
@property (nonatomic, strong) UILabel * shareLabel;
@property (nonatomic, assign) BOOL showShare;
@property (nonatomic, strong) UIView * shareView;

@property (nonatomic, strong) UIButton * currentQuanxianButton;
@property (nonatomic, strong) UIButton * currentShareButton;

@property (nonatomic, strong) UIView * miquanChooseView;
@property (nonatomic, strong) UIView * miquanContenView;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@end

@implementation DTieQuanxianView

- (instancetype)initWithFrame:(CGRect)frame editModel:(DTieModel *)editModel
{
    if (self = [super initWithFrame:frame]) {
        self.editDTModel = editModel;
        [self createQuanxianView];
        [self requestSecuritySource];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createQuanxianView];
        [self requestSecuritySource];
    }
    return self;
}

- (void)requestSecuritySource
{
    SecurityRequest * request = [[SecurityRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                [self.dataSource removeAllObjects];
                [self.selectSource removeAllObjects];
                
                SecurityGroupModel * model1 = [[SecurityGroupModel alloc] init];
                model1.cid = -1;
                model1.securitygroupName = @"所有朋友";
                model1.isChoose = YES;
                model1.isNotification = YES;
                [self.dataSource addObject:model1];
                
                SecurityGroupModel * model2 = [[SecurityGroupModel alloc] init];
                model2.cid = -2;
                model2.securitygroupName = @"关注我的人";
                model2.isChoose = YES;
                model2.isNotification = YES;
                [self.dataSource addObject:model2];
                
                for (NSInteger i = 0; i < data.count; i++) {
                    NSDictionary * dict = [data objectAtIndex:i];
                    NSDictionary * result = [dict objectForKey:@"securityGroup"];
                    SecurityGroupModel * model = [SecurityGroupModel mj_objectWithKeyValues:result];
                    model.isNotification = YES;
                    [self.dataSource addObject:model];
                }
                
                [self.selectSource addObject:model1];
                [self.selectSource addObject:model2];
                [self.currentQuanxianButton setImage:[UIImage imageNamed:@"singleno"] forState:UIControlStateNormal];
                [self.miquanButton setImage:[UIImage imageNamed:@"singleyes"] forState:UIControlStateNormal];
                [self configMiquanLabelText:@"好友圈(默认密圈)"];
                self.landAccountFlg = 4;
                self.currentQuanxianButton = self.miquanButton;
                
                [self.tableView reloadData];
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

#pragma mark - 选择不同的选项
- (void)gongkaiButtonDidClicked:(UIButton *)button
{
    if (self.currentQuanxianButton != button) {
        [self.currentQuanxianButton setImage:[UIImage imageNamed:@"singleno"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"singleyes"] forState:UIControlStateNormal];
        [self configQuanxianLabelText:@"浏览权限（公开）"];
        self.landAccountFlg = 1;
        self.currentQuanxianButton = button;
    }
}

- (void)yinsiButtonDidClicked:(UIButton *)button
{
    if (self.currentQuanxianButton != button) {
        [self.currentQuanxianButton setImage:[UIImage imageNamed:@"singleno"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"singleyes"] forState:UIControlStateNormal];
        [self configQuanxianLabelText:@"浏览权限（隐私）"];
        self.landAccountFlg = 2;
        self.currentQuanxianButton = button;
    }
}

- (void)miquanButtonDidClicked:(UIButton *)button
{
    if (self.dataSource.count == 0) {
        [self requestSecuritySource];
        [MBProgressHUD showTextHUDWithText:@"暂未获得好友圈" inView:self];
    }else{
        [self showChooseMiquanView];
    }
}

//选择好友圈
- (void)showChooseMiquanView
{
    [[UIApplication sharedApplication].keyWindow addSubview:self.miquanChooseView];
    [self.miquanChooseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)sureButtonDidClicked
{
    [self.currentQuanxianButton setImage:[UIImage imageNamed:@"singleno"] forState:UIControlStateNormal];
    [self.miquanButton setImage:[UIImage imageNamed:@"singleyes"] forState:UIControlStateNormal];
    [self configQuanxianLabelText:@"浏览权限（好友圈）"];
    self.landAccountFlg = 4;
    self.currentQuanxianButton = self.miquanButton;
    
    [self.selectSource removeAllObjects];
    for (SecurityGroupModel * model in self.dataSource) {
        if (model.isChoose) {
            [self.selectSource addObject:model];
        }
    }
    if (self.selectSource.count == 0) {
        [MBProgressHUD showTextHUDWithText:@"请至少选择一个" inView:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
    [self configMiquanLabelText:@"好友圈(默认密圈)"];
    
    [self hiddenMiquanView];
}

- (void)cancleButtonDidClicked
{
    [self hiddenMiquanView];
}

- (void)hiddenMiquanView
{
    [self.miquanChooseView removeFromSuperview];
}

- (void)pengyouquanButtonDidClicked:(UIButton *)button
{
    if (self.currentShareButton != button) {
        [self.currentShareButton setImage:[UIImage imageNamed:@"singleno"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"singleyes"] forState:UIControlStateNormal];
        [self configShareLabelText:@"微信分享（分享到朋友圈）"];
        self.shareType = 1;
        self.currentShareButton = button;
    }
}

- (void)weixinButtonDidClicked:(UIButton *)button
{
    if (self.currentShareButton != button) {
        [self.currentShareButton setImage:[UIImage imageNamed:@"singleno"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"singleyes"] forState:UIControlStateNormal];
        [self configShareLabelText:@"微信分享（分享到微信好友或群）"];
        self.shareType = 2;
        self.currentShareButton = button;
    }
}

#pragma mark - 点击展开或收起选项
- (void)quanxianButtonDidClicked
{
    self.showQuanxian = !self.showQuanxian;
    CGFloat scale = kMainBoundsWidth / 1080.f;
    if (self.showQuanxian) {
        
        self.quanxianView.hidden = NO;
        [self.shareButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(522 * scale);
        }];
        
    }else{
        
        self.quanxianView.hidden = YES;
        [self.shareButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(228 * scale);
        }];
        
    }
}

- (void)shareButtonDidClicked
{
    self.showShare = !self.showShare;
    if (self.showShare) {
        
        self.shareView.hidden = NO;
        
    }else{
        
        self.shareView.hidden = YES;
        
    }
}

- (void)createQuanxianView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    self.quanxianButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.quanxianButton.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.quanxianButton];
    [self.quanxianButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    
//    UIImageView * quanxianAlert = [[UIImageView alloc] initWithFrame:CGRectZero];
//    [quanxianAlert setImage:[UIImage imageNamed:@"alertEdit"]];
//    [self.quanxianButton addSubview:quanxianAlert];
//    [quanxianAlert mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(0);
//        make.right.mas_equalTo(-60 * scale);
//        make.width.height.mas_equalTo(72 * scale);
//    }];
    
    self.quanxianLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    [self.quanxianButton addSubview:self.quanxianLabel];
    [self.quanxianLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-140 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(50 * scale);
    }];
    
    self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.shareButton.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.shareButton];
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(522 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    
//    UIImageView * shareAlert = [[UIImageView alloc] initWithFrame:CGRectZero];
//    [shareAlert setImage:[UIImage imageNamed:@"alertEdit"]];
//    [self.shareButton addSubview:shareAlert];
//    [shareAlert mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(0);
//        make.right.mas_equalTo(-60 * scale);
//        make.width.height.mas_equalTo(72 * scale);
//    }];
    
    self.shareLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    [self.shareButton addSubview:self.shareLabel];
    [self.shareLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-140 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(50 * scale);
    }];
    
    NSString * quanxianText = @"浏览权限（好友圈）";
    [self configQuanxianLabelText:quanxianText];
    
    NSString * shareText = @"微信分享（分享到朋友圈）";
    [self configShareLabelText:shareText];
    
    self.quanxianView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 318 * scale)];
    [self addSubview:self.quanxianView];
    [self.quanxianView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.quanxianButton.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(318 * scale);
    }];
    
    CGFloat buttonHeight = (318 - 48) * scale / 3.f;
    UIButton * gongkaiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    gongkaiButton.titleLabel.font = kPingFangRegular(42 * scale);
    [gongkaiButton setImage:[UIImage imageNamed:@"singleyes"] forState:UIControlStateNormal];
    [gongkaiButton setTitle:@"公开" forState:UIControlStateNormal];
    [gongkaiButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    [self.quanxianView addSubview:gongkaiButton];
    [gongkaiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(24 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(buttonHeight);
    }];
    self.currentQuanxianButton = gongkaiButton;
    self.landAccountFlg = 1;
    [gongkaiButton addTarget:self action:@selector(gongkaiButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * yinsiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    yinsiButton.titleLabel.font = kPingFangRegular(42 * scale);
    [yinsiButton setImage:[UIImage imageNamed:@"singleno"] forState:UIControlStateNormal];
    [yinsiButton setTitle:@"隐私" forState:UIControlStateNormal];
    [yinsiButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    [self.quanxianView addSubview:yinsiButton];
    [yinsiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(gongkaiButton.mas_bottom);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(buttonHeight);
    }];
    [yinsiButton addTarget:self action:@selector(yinsiButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.miquanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.miquanButton.titleLabel.font = kPingFangRegular(42 * scale);
    [self.miquanButton setImage:[UIImage imageNamed:@"singleno"] forState:UIControlStateNormal];
    [self.miquanButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    [self.quanxianView addSubview:self.miquanButton];
    [self.miquanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(yinsiButton.mas_bottom);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(buttonHeight);
        make.right.mas_lessThanOrEqualTo(-60 * scale);
    }];
    [self configMiquanLabelText:@"好友圈（默认密圈）"];
    [self.miquanButton addTarget:self action:@selector(miquanButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.shareView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 228 * scale)];
    [self addSubview:self.shareView];
    [self.shareView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shareButton.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(buttonHeight * 2 + 48 * scale);
    }];
    
    UIButton * pengyouquanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pengyouquanButton.titleLabel.font = kPingFangRegular(42 * scale);
    [pengyouquanButton setImage:[UIImage imageNamed:@"singleyes"] forState:UIControlStateNormal];
    [pengyouquanButton setTitle:@"分享到朋友圈" forState:UIControlStateNormal];
    [pengyouquanButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    [self.shareView addSubview:pengyouquanButton];
    [pengyouquanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(24 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(buttonHeight);
    }];
    self.shareType = 1;
    self.currentShareButton = pengyouquanButton;
    [pengyouquanButton addTarget:self action:@selector(pengyouquanButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * weixinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    weixinButton.titleLabel.font = kPingFangRegular(42 * scale);
    [weixinButton setImage:[UIImage imageNamed:@"singleno"] forState:UIControlStateNormal];
    [weixinButton setTitle:@"分享到微信好友或群" forState:UIControlStateNormal];
    [weixinButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    [self.shareView addSubview:weixinButton];
    [weixinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(pengyouquanButton.mas_bottom);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(buttonHeight);
    }];
    [weixinButton addTarget:self action:@selector(weixinButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.showQuanxian = YES;
    self.shareView.hidden = YES;
    self.showShare = NO;
    
    if (![WXApi isWXAppInstalled]) {
        self.shareButton.hidden = YES;
    }
    
    [self.quanxianButton addTarget:self action:@selector(quanxianButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton addTarget:self action:@selector(shareButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    //创建好友圈选择
    self.miquanChooseView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.miquanChooseView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
    
    self.miquanContenView = [[UIView alloc] initWithFrame:self.bounds];
    self.miquanContenView.backgroundColor = [UIColor whiteColor];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.miquanContenView];
    self.miquanContenView.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.miquanContenView.layer.borderWidth = 6 * scale;
    [self.miquanChooseView addSubview:self.miquanContenView];
    [self.miquanContenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.mas_equalTo(840 * scale);
        make.height.mas_equalTo(772 * scale);
    }];
    
    UILabel * tipLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentCenter];
    tipLabel.text = @"好友圈选择";
    [self.miquanContenView addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(55 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(58 * scale);
    }];
    
    UIButton * cancleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0x666666) title:@"取消"];
    [self.miquanContenView addSubview:cancleButton];
    [cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.mas_equalTo(0);
        make.height.mas_equalTo(139 * scale);
        make.width.mas_equalTo(840 * scale / 2);
    }];
    [cancleButton addTarget:self action:@selector(cancleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * sureButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0x666666) title:@"确定"];
    [self.miquanContenView addSubview:sureButton];
    [sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(139 * scale);
        make.width.mas_equalTo(840 * scale / 2);
    }];
    [sureButton addTarget:self action:@selector(sureButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIView * lineView1 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView1.backgroundColor = UIColorFromRGB(0xCCCCCC);
    [self.miquanContenView addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(3 * scale);
        make.bottom.mas_equalTo(sureButton.mas_top);
    }];
    
    UIView * lineView2 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView2.backgroundColor = UIColorFromRGB(0xCCCCCC);
    [self.miquanContenView addSubview:lineView2];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(sureButton.mas_top);
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.width.mas_equalTo(3 * scale);
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[DTieNewSecurityCell class] forCellReuseIdentifier:@"DTieNewSecurityCell"];
    self.tableView.rowHeight = 90 * scale;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.miquanContenView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(tipLabel.mas_bottom).offset(40 * scale);
        make.bottom.mas_equalTo(sureButton.mas_top).offset(-60 * scale);
    }];
    
    SecurityGroupModel * model1 = [[SecurityGroupModel alloc] init];
    model1.cid = -1;
    model1.securitygroupName = @"所有朋友";
    model1.isChoose = YES;
    model1.isNotification = YES;
    [self.dataSource addObject:model1];
    
    SecurityGroupModel * model2 = [[SecurityGroupModel alloc] init];
    model2.cid = -2;
    model2.securitygroupName = @"关注我的人";
    model2.isChoose = YES;
    model2.isNotification = YES;
    [self.dataSource addObject:model2];
    [self.selectSource addObject:model1];
    [self.selectSource addObject:model2];
    [self.currentQuanxianButton setImage:[UIImage imageNamed:@"singleno"] forState:UIControlStateNormal];
    [self.miquanButton setImage:[UIImage imageNamed:@"singleyes"] forState:UIControlStateNormal];
    [self configMiquanLabelText:@"好友圈(默认密圈)"];
    self.landAccountFlg = 4;
    self.currentQuanxianButton = self.miquanButton;
    
    [self.tableView reloadData];
}

- (void)configMiquanLabelText:(NSString *)text
{
    if (self.selectSource && self.selectSource.count > 0) {
        NSString * title = @"";
        for (SecurityGroupModel * model in self.selectSource) {
            title = [title stringByAppendingString:[NSString stringWithFormat:@"%@,", model.securitygroupName]];
        }
        title = [title substringToIndex:title.length - 1];
        text = [NSString stringWithFormat:@"好友圈(%@)", title];
    }
    
    NSInteger length = text.length;
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:self.miquanButton.titleLabel.font, NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
    [attributedString addAttributes:@{NSFontAttributeName:self.quanxianLabel.font, NSForegroundColorAttributeName:UIColorFromRGB(0xDB6283)} range:NSMakeRange(4, length - 5)];
    [self.miquanButton setAttributedTitle:attributedString forState:UIControlStateNormal];
}

- (void)configQuanxianLabelText:(NSString *)text
{
    NSInteger length = text.length;
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:self.quanxianLabel.font, NSForegroundColorAttributeName:self.quanxianLabel.textColor}];
    [attributedString addAttributes:@{NSFontAttributeName:self.quanxianLabel.font, NSForegroundColorAttributeName:UIColorFromRGB(0xDB6283)} range:NSMakeRange(5, length - 6)];
    self.quanxianLabel.attributedText = attributedString;
}

- (void)configShareLabelText:(NSString *)text
{
    NSInteger length = text.length;
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:self.shareLabel.font, NSForegroundColorAttributeName:self.shareLabel.textColor}];
    [attributedString addAttributes:@{NSFontAttributeName:self.shareLabel.font, NSForegroundColorAttributeName:UIColorFromRGB(0xDB6283)} range:NSMakeRange(5, length - 6)];
    self.shareLabel.attributedText = attributedString;
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

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (NSMutableArray *)selectSource
{
    if (!_selectSource) {
        _selectSource = [[NSMutableArray alloc] init];
    }
    return _selectSource;
}

@end
