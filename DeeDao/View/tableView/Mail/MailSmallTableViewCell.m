//
//  MailSmallTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/14.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "MailSmallTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import "DDTool.h"
#import "SaveFriendOrConcernRequest.h"
#import "DTieDetailRequest.h"
#import "DTieNewDetailViewController.h"
#import "MBProgressHUD+DDHUD.h"
#import <UIImageView+WebCache.h>
#import "DDLGSideViewController.h"

@interface MailSmallTableViewCell ()

@property (nonatomic, strong) UIImageView * coverImageView;

@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UIView * baseView;
@property (nonatomic, strong) UILabel * InfoLabel;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) MailModel * model;

@property (nonatomic, strong) UIButton * leftButton;
@property (nonatomic, strong) UIButton * rightButton;

@end

@implementation MailSmallTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createSmallCell];
    }
    return self;
}

- (void)createSmallCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.backgroundColor = UIColorFromRGB(0xEFEFF4);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.baseView];
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(54 * scale);
        make.left.mas_equalTo(54 * scale);
        make.right.mas_equalTo(-54 * scale);
        make.bottom.mas_equalTo(0);
    }];
    
    UIImage * bgImage = [UIImage imageNamed:@"smallkuang"];
    self.coverImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleToFill image:[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(bgImage.size.height*0.9, bgImage.size.width*0.9, bgImage.size.height*0.9, bgImage.size.width*0.9) resizingMode:UIImageResizingModeStretch]];
    self.coverImageView.layer.masksToBounds = YES;
    [self.baseView addSubview:self.coverImageView];
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
    }];
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"yt-dazhaohu"]];
    [self.baseView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(70 * scale);
        make.centerY.mas_equalTo(-40 * scale);
        make.width.height.mas_equalTo(90 * scale);
    }];
    [DDViewFactoryTool cornerRadius:45 * scale withView:self.logoImageView];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentRight];
    [self.baseView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(45 * scale);
        make.right.mas_equalTo(-45 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    //    self.nameLabel.text = @"Just丶DeeDao";
    [self.baseView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(45 * scale);
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(35 * scale);
        make.right.mas_equalTo(self.timeLabel.mas_left).offset(-20 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
    
    self.InfoLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    self.InfoLabel.text = @"在你的D帖的位置向你打招呼";
    [self.baseView addSubview:self.InfoLabel];
    [self.InfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.logoImageView.mas_bottom);
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(35 * scale);
        make.right.mas_equalTo(-45 * scale);
    }];
    
    self.rightButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"添加关注"];
    [self.baseView addSubview:self.rightButton];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.InfoLabel);
        make.right.mas_equalTo(-45 * scale);
        make.height.mas_equalTo(72 * scale);
        make.width.mas_equalTo(216 * scale);
    }];
    [DDViewFactoryTool cornerRadius:12 * scale withView:self.rightButton];
    self.rightButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.rightButton.layer.borderWidth = 3 * scale;
    self.rightButton.hidden = YES;
    
    self.leftButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"添加好友"];
    [self.baseView addSubview:self.leftButton];
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.InfoLabel);
        make.right.mas_equalTo(self.rightButton.mas_left).offset(-48 * scale);
        make.height.mas_equalTo(72 * scale);
        make.width.mas_equalTo(216 * scale);
    }];
    [DDViewFactoryTool cornerRadius:12 * scale withView:self.leftButton];
    self.leftButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.leftButton.layer.borderWidth = 3 * scale;
    self.leftButton.hidden = YES;
    
    UIView * coverView = [[UIView alloc] initWithFrame:CGRectZero];
    coverView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.contentView addSubview:coverView];
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(24 * scale);
    }];
    coverView.layer.shadowColor = UIColorFromRGB(0x333333).CGColor;
    coverView.layer.shadowOpacity = .2f;
    coverView.layer.shadowOffset = CGSizeMake(0, -12 * scale);
    
    [self.leftButton addTarget:self action:@selector(leftButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addTarget:self action:@selector(rightButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)leftButtonDidClicked
{
    if (self.model.mailTypeId == 8) {
        [MBProgressHUD showTextHUDWithText:@"已拒绝" inView:[UIApplication sharedApplication].keyWindow];
    }
}

- (void)rightButtonDidClicked
{
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    
    NSInteger type = self.model.mailTypeId;
    if (type == 1 || type == 3 || type == 4 || type == 5 || type == 7 || type == 10 || type == 11) {
        
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:na.view];
        
        DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:self.model.postId type:4 start:0 length:10];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
            
            if (KIsDictionary(response)) {
                
                NSInteger code = [[response objectForKey:@"status"] integerValue];
                if (code == 4002) {
                    [MBProgressHUD showTextHUDWithText:@"该帖已被作者删除~" inView:na.view];
                    return;
                }
                
                NSDictionary * data = [response objectForKey:@"data"];
                if (KIsDictionary(data)) {
                    DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                    
                    if (dtieModel.deleteFlg == 1) {
                        [MBProgressHUD showTextHUDWithText:@"该帖已被作者删除~" inView:na.view];
                        return;
                    }
                    
                    if (dtieModel.landAccountFlg == 2 && dtieModel.authorId != [UserManager shareManager].user.cid) {
                        [MBProgressHUD showTextHUDWithText:@"该帖已被作者设为私密状态" inView:[UIApplication sharedApplication].keyWindow];
                        return;
                    }
                    
                    DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initWithDTie:dtieModel];
                    [na pushViewController:detail animated:YES];
                }
            }
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            [hud hideAnimated:YES];
        }];
        
    }else if (type == 8){
        
        [SaveFriendOrConcernRequest cancelRequest];
        SaveFriendOrConcernRequest * request = [[SaveFriendOrConcernRequest alloc] initWithHandleFriendId:self.model.mailSendId andIsAdd:YES];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [MBProgressHUD showTextHUDWithText:@"添加成功" inView:na.view];
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [MBProgressHUD showTextHUDWithText:@"添加失败" inView:na.view];
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
            [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:na.view];
            
        }];
    }else{
        
    }
}

- (void)configWithModel:(MailModel *)model
{
    self.model = model;
    self.InfoLabel.text = [MailModel getTitleWithMailTypeId:model.mailTypeId];
    self.nameLabel.text = model.nickName;
    self.timeLabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:model.createTime];
//    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraitUri]];
    
    if (model.type == MailModelType_System) {
        [self.logoImageView setImage:[UIImage imageNamed:@"yt_shoucang"]];
        UIImage * bgImage = [UIImage imageNamed:@"kuang_blue"];
        [self.coverImageView setImage:[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(bgImage.size.height*0.9, bgImage.size.width*0.9, bgImage.size.height*0.9, bgImage.size.width*0.9) resizingMode:UIImageResizingModeStretch]];
    }else{
        UIImage * bgImage = [UIImage imageNamed:@"smallkuang"];
        [self.coverImageView setImage:[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(bgImage.size.height*0.9, bgImage.size.width*0.9, bgImage.size.height*0.9, bgImage.size.width*0.9) resizingMode:UIImageResizingModeStretch]];
        [self.logoImageView setImage:[UIImage imageNamed:@"yt-dazhaohu"]];
    }
    
    if (!isEmptyString(model.portraitUri)) {
        [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraitUri]];
    }
    [self reloadWithModelStatus];
}

- (void)reloadWithModelStatus
{
    NSInteger type = self.model.mailTypeId;
    CGFloat scale = kMainBoundsWidth / 1080.f;
    if (type == 1 || type == 3 || type == 4 || type == 5 || type == 7 || type == 10 || type == 11) {
        self.leftButton.hidden = YES;
        self.rightButton.hidden = NO;
        [self.rightButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(216 * scale);
        }];
        [self.InfoLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-280 * scale);
        }];
        [self.rightButton setTitle:@"点击查看" forState:UIControlStateNormal];
    }else if (type == 8) {
        self.leftButton.hidden = NO;
        self.rightButton.hidden = NO;
        [self.rightButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(132 * scale);
        }];
        [self.leftButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(132 * scale);
        }];
        [self.InfoLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-375 * scale);
        }];
        [self.rightButton setTitle:@"同意" forState:UIControlStateNormal];
        [self.leftButton setTitle:@"拒绝" forState:UIControlStateNormal];
    }else{
        self.leftButton.hidden = YES;
        self.rightButton.hidden = YES;
        [self.InfoLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-45 * scale);
        }];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
