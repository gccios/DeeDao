//
//  UserInfoCollectionHeader.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "UserInfoCollectionHeader.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "SaveFriendOrConcernRequest.h"
#import "MBProgressHUD+DDHUD.h"
#import <YYText.h>
#import "UserManager.h"
#import "DDLGSideViewController.h"
#import "MineInfoViewController.h"
#import "DDAuthorGroupDetailController.h"
#import "DDGroupDetailViewController.h"

@interface UserInfoCollectionHeader ()

@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UIButton * guanzhuButton;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * miquanLabel;
@property (nonatomic, strong) UILabel * degressLabel;

@property (nonatomic, strong) UIView * geqianView;
@property (nonatomic, strong) YYLabel * geqianLabel;

@property (nonatomic, assign) BOOL isGuanzhu;
@property (nonatomic, assign) UserModel * model;

@property (nonatomic, strong) NSMutableArray * groupList;

@end

@implementation UserInfoCollectionHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createUserInfoHeader];
    }
    return self;
}

- (void)createUserInfoHeader
{
    self.backgroundColor = UIColorFromRGB(0xEFEFF4);
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * whiteBG1 = [[UIView alloc] initWithFrame:CGRectZero];
    whiteBG1.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self addSubview:whiteBG1];
    [whiteBG1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(288 * scale);
    }];
    
    UIImageView * headerBGView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"headerBG"]];
    [whiteBG1 addSubview:headerBGView];
    [headerBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(42 * scale);
        make.centerY.mas_equalTo(0);
        make.width.height.mas_equalTo(180 * scale);
    }];
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [whiteBG1 addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.centerY.mas_equalTo(0);
        make.width.height.mas_equalTo(144 * scale);
    }];
    [DDViewFactoryTool cornerRadius:72 * scale withView:self.logoImageView];
    
    self.guanzhuButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0x999999) title:@""];
    [self.guanzhuButton addTarget:self action:@selector(guanzhuButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [whiteBG1 addSubview:self.guanzhuButton];
    [self.guanzhuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60 * scale);
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(48 * scale);
        make.height.mas_equalTo(40 * scale);
    }];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(54 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    [whiteBG1 addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.guanzhuButton.mas_bottom).offset(8 * scale);
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(48 * scale);
        make.height.mas_equalTo(58 * scale);
    }];
    
    self.miquanLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(54 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    [whiteBG1 addSubview:self.miquanLabel];
    [self.miquanLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel).offset(20 * scale);
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(48 * scale);
        make.height.mas_equalTo(58 * scale);
    }];
    
    UILabel * geqian = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    geqian.text = DDLocalizedString(@"已加入的群");
    [self addSubview:geqian];
    [geqian mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.top.mas_equalTo(whiteBG1.mas_bottom).offset(48 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
    
    self.geqianView = [[UIView alloc] initWithFrame:CGRectZero];
    self.geqianView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self addSubview:self.geqianView];
    [self.geqianView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(geqian.mas_bottom).offset(24 * scale);
        make.left.mas_equalTo(0 * scale);
        make.right.mas_equalTo(0 * scale);
        make.bottom.mas_equalTo(-90 * scale);
    }];
    
    self.geqianLabel = [[YYLabel alloc] init];
    self.geqianLabel.numberOfLines = 0;
    self.geqianLabel.preferredMaxLayoutWidth = kMainBoundsWidth - 120 * scale;
    [self.geqianView addSubview:self.geqianLabel];
    [self.geqianLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(24 * scale);
        make.left.mas_equalTo(60 * scale);
        make.bottom.mas_equalTo(-24 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    
//    self.geqianLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(48 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
//    self.geqianLabel.numberOfLines = 0;
//    self.geqianLabel.text = @"暂时没有个性签名";
//    [self.geqianView addSubview:self.geqianLabel];
//    [self.geqianLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(24 * scale);
//        make.left.mas_equalTo(60 * scale);
//        make.bottom.mas_equalTo(-24 * scale);
//        make.right.mas_equalTo(-60 * scale);
//    }];
    
    UILabel * liebiao = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    liebiao.text = DDLocalizedString(@"Open D Blog");
    [self addSubview:liebiao];
    [liebiao mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.top.mas_equalTo(self.geqianView.mas_bottom).offset(48 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
}

- (void)guanzhuButtonDidClicked
{
    if (self.model.selfFlg) {
        return;
    }
    
    self.guanzhuButton.enabled = NO;
    BOOL isAdd = YES;
    if (self.isGuanzhu) {
        isAdd = NO;
    }
    SaveFriendOrConcernRequest * request = [[SaveFriendOrConcernRequest alloc] initWithHandleConcernId:self.model.cid andIsAdd:isAdd];
    
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        self.isGuanzhu = !self.isGuanzhu;
        
        if (self.isGuanzhu) {
            self.model.concernFlg = YES;
            [self.guanzhuButton setTitle:DDLocalizedString(@"Already follow") forState:UIControlStateNormal];
            self.isGuanzhu = YES;
        }else{
            self.model.concernFlg = NO;
            [self.guanzhuButton setTitle:DDLocalizedString(@"Not yet a followed") forState:UIControlStateNormal];
            self.isGuanzhu = NO;
        }
        
        self.guanzhuButton.enabled = YES;
        
        if (isAdd) {
            [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"AddFollow") inView:self];
        }else{
            [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"De-Follow") inView:self];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        self.guanzhuButton.enabled = YES;
        if (isAdd) {
            [MBProgressHUD showTextHUDWithText:@"关注失败" inView:self];
        }else{
            [MBProgressHUD showTextHUDWithText:@"取消关注失败" inView:self];
        }
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        self.guanzhuButton.enabled = YES;
        if (isAdd) {
            [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:self];
        }else{
            [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:self];
        }
        
    }];
}

- (void)configWithModel:(UserModel *)model groupList:(NSMutableArray *)groupList
{
    self.model = model;
    self.nameLabel.text = model.nickname;
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    if (!isEmptyString(model.signature)) {
        self.geqianLabel.text = model.signature;
    }
    
    if (model.selfFlg) {
        self.guanzhuButton.hidden = YES;
    }else{
        self.guanzhuButton.hidden = NO;
        if (model.concernFlg) {
            [self.guanzhuButton setTitle:DDLocalizedString(@"Already follow") forState:UIControlStateNormal];
            self.isGuanzhu = YES;
        }else{
            [self.guanzhuButton setTitle:DDLocalizedString(@"Not yet a followed") forState:UIControlStateNormal];
            self.isGuanzhu = NO;
        }
    }
    
    if (model.cid == [UserManager shareManager].user.cid) {
        CGFloat scale = kMainBoundsWidth / 375.f;
        UIButton * editTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [editTitleButton setImage:[UIImage imageNamed:@"editTitle"] forState:UIControlStateNormal];
        [self addSubview:editTitleButton];
        [editTitleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.nameLabel);
            make.right.mas_equalTo(-30 * scale);
            make.width.height.mas_equalTo(60 * scale);
        }];
        [editTitleButton addTarget:self action:@selector(editTitleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    NSMutableAttributedString * groupStr = [[NSMutableAttributedString alloc] initWithString:@"群归属：" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
    for (NSInteger i = 0; i < groupList.count ; i++) {
        
        DDGroupModel * groupModel = [groupList objectAtIndex:i];
        
        NSMutableAttributedString * tempStr = [[NSMutableAttributedString alloc] initWithString:groupModel.groupName attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0xDB6283)}];
        [tempStr yy_setTextHighlightRange:NSMakeRange(0, tempStr.length) color:UIColorFromRGB(0xDB6283) backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            
            DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            UINavigationController * na = (UINavigationController *)lg.rootViewController;
            
            if (groupModel.groupCreateUser == [UserManager shareManager].user.cid) {
                DDAuthorGroupDetailController * author = [[DDAuthorGroupDetailController alloc] initWithModel:groupModel];
                [na pushViewController:author animated:YES];
            }else{
                DDGroupDetailViewController * detail = [[DDGroupDetailViewController alloc] initWithModel:groupModel];
                [na pushViewController:detail animated:YES];
            }
            
        }];
        [groupStr appendAttributedString:tempStr];
        
        if ( i != groupList.count - 1) {
            NSMutableAttributedString * spaceStr = [[NSMutableAttributedString alloc] initWithString:@" 、" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
            [groupStr appendAttributedString:spaceStr];
        }
    }
    self.geqianLabel.attributedText = groupStr;
}

- (void)editTitleButtonDidClicked
{
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    
    MineInfoViewController * info  =[[MineInfoViewController alloc] init];
    [na presentViewController:info animated:YES completion:nil];
}

@end
