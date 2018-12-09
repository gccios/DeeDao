//
//  DTieDetailPostTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/7/26.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieDetailPostTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "DDTool.h"
#import "DTieDetailRequest.h"
#import "DTieNewDetailViewController.h"
#import "MBProgressHUD+DDHUD.h"
#import "DDLGSideViewController.h"

@interface DTieDetailPostTableViewCell ()

@property (nonatomic, strong) UIView * baseView;
@property (nonatomic, strong) UIImageView * postImageView;
@property (nonatomic, strong) UILabel * postNameLabel;
@property (nonatomic, strong) UILabel * addressLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UIImageView * bozhuImageView;

@property (nonatomic, strong) DTieEditModel * model;

@property (nonatomic, strong) UIImageView * deedaoImageView;
@property (nonatomic, strong) UIImageView * shareImageView;

@property (nonatomic, strong) UIView * baseCornerView;
@property (nonatomic, strong) UIView * authorHandleView;

@end

@implementation DTieDetailPostTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self createDtiePostCell];
        
    }
    return self;
}

- (void)createDtiePostCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.baseView];
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(45 * scale);
        make.left.mas_equalTo(60 * scale);
        make.bottom.mas_equalTo(-45 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    self.baseView.layer.cornerRadius = 24 * scale;
    self.baseView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    self.baseView.layer.shadowOpacity = .3f;
    self.baseView.layer.shadowRadius = 24 * scale;
    self.baseView.layer.shadowOffset = CGSizeMake(0, 12 * scale);
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPostDetail)];
    [self.baseView addGestureRecognizer:tap];
    
    self.baseCornerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.baseView addSubview:self.baseCornerView];
    self.baseCornerView.layer.cornerRadius = 24 * scale;
    self.baseCornerView.layer.masksToBounds = YES;
    [self.baseCornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.postImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [self.baseCornerView addSubview:self.postImageView];
    [self.postImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-144 * scale);
    }];
    
    UIView * postNameView = [[UIView alloc] initWithFrame:CGRectZero];
    postNameView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    [self.postImageView addSubview:postNameView];
    [postNameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(120 * scale);
    }];
    
    self.postNameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xFFFFFF) alignment:NSTextAlignmentLeft];
    [postNameView addSubview:self.postNameLabel];
    [self.postNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    
    UIView * infoView = [[UIView alloc] initWithFrame:CGRectZero];
    infoView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.baseCornerView addSubview:infoView];
    [infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.postImageView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [infoView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-400 * scale);
    }];
    
    self.addressLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [infoView addSubview:self.addressLabel];
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(5 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-400 * scale);
    }];
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [infoView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.timeLabel.mas_right).offset(40 * scale);
        make.top.mas_equalTo(15 * scale);
        make.width.height.mas_equalTo(80 * scale);
    }];
    [DDViewFactoryTool cornerRadius:40 * scale withView:self.logoImageView];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [infoView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(20 * scale);
        make.centerY.mas_equalTo(self.logoImageView);
        make.right.mas_equalTo(-40 * scale);
    }];
    
    self.bozhuImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.bozhuImageView setImage:[UIImage imageNamed:@"bozhuTag"]];
    [infoView addSubview:self.bozhuImageView];
    [self.bozhuImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.logoImageView.mas_bottom).offset(-15 * scale);
        make.width.mas_equalTo(120 * scale);
        make.height.mas_equalTo(34 * scale);
        make.centerX.mas_equalTo(self.logoImageView);
    }];
    
    self.authorHandleView = [[UIView alloc] initWithFrame:CGRectZero];
    self.authorHandleView.backgroundColor = UIColorFromRGB(0xf5f5f5);
    [self.baseCornerView addSubview:self.authorHandleView];
    [self.authorHandleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    
    UIButton * upButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [upButton setImage:[UIImage imageNamed:@"readUp"] forState:UIControlStateNormal];
    [self.authorHandleView addSubview:upButton];
    [upButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(60 * scale);
        make.width.height.mas_equalTo(80 * scale);
    }];
    
    UIButton * downButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [downButton setImage:[UIImage imageNamed:@"readDown"] forState:UIControlStateNormal];
    [self.authorHandleView addSubview:downButton];
    [downButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
        make.width.height.mas_equalTo(80 * scale);
    }];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xDB6283);
    [self.authorHandleView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.mas_equalTo(2 * scale);
        make.height.mas_equalTo(40 * scale);
    }];
    
    UIButton * deleteButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"删除模块"];
    [self.authorHandleView addSubview:deleteButton];
    [deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(120 * scale);
        make.right.mas_equalTo(lineView.mas_left).offset(-80 * scale);
    }];
    
    UIButton * editButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"编辑修改"];
    [self.authorHandleView addSubview:editButton];
    [editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(120 * scale);
        make.left.mas_equalTo(lineView.mas_right).offset(80 * scale);
    }];
    
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addButton setImage:[UIImage imageNamed:@"addEdit"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.addButton];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.baseView.mas_bottom).offset(60 * scale);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(72 * scale);
    }];
    
    [self.addButton addTarget:self action:@selector(addButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [upButton addTarget:self action:@selector(upButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [downButton addTarget:self action:@selector(downButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [deleteButton addTarget:self action:@selector(deleteButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [editButton addTarget:self action:@selector(editButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addButtonDidClicked
{
    if (self.addButtonHandle) {
        self.addButtonHandle();
    }
}

- (void)deedaoButtonDidClicked
{
    if (self.model.pFlag == 1) {
        self.model.pFlag = 0;
        [self.deedaoImageView setImage:[UIImage imageNamed:@"chooseno"]];
    }else{
        self.model.pFlag = 1;
        [self.deedaoImageView setImage:[UIImage imageNamed:@"chooseyes"]];
    }
}

- (void)shareButtonDidClicked
{
    if (self.model.shareEnable == 1) {
        self.model.shareEnable = 0;
        self.model.wxCanSee = 0;
        [self.shareImageView setImage:[UIImage imageNamed:@"chooseno"]];
    }else{
        self.model.shareEnable = 1;
        self.model.wxCanSee = 1;
        [self.shareImageView setImage:[UIImage imageNamed:@"chooseyes"]];
    }
}

- (void)upButtonDidClicked
{
    if (self.upButtonHandle) {
        self.upButtonHandle();
    }
}

- (void)downButtonDidClicked
{
    if (self.downButtonHandle) {
        self.downButtonHandle();
    }
}

- (void)deleteButtonDidClicked
{
    if (self.deleteButtonHandle) {
        self.deleteButtonHandle();
    }
}

- (void)editButtonDidClicked
{
    if (self.editButtonHandle) {
        self.editButtonHandle();
    }
}

- (void)configWithModel:(DTieEditModel *)model Dtie:(DTieModel *)dtieModel
{
    self.model = model;
    [self.postImageView sd_setImageWithURL:[NSURL URLWithString:model.postFirstPicture]];
    self.postNameLabel.text = model.postSummary;
    self.timeLabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:model.updateTime];
    self.addressLabel.text = model.sceneAddress;
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    self.nameLabel.text = model.nickname;
    if (model.bloggerFlg == 1) {
        self.bozhuImageView.hidden = NO;
    }else{
        self.bozhuImageView.hidden = YES;
    }
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    if ([UserManager shareManager].user.cid == dtieModel.authorId) {
        self.authorHandleView.hidden = NO;
        self.addButton.hidden = NO;
        [self.postImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-288 * scale);
        }];
        [self.baseView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-45 * scale - 120 * scale);
        }];
        
        if (self.model.shareEnable == 1) {
            [self.shareImageView setImage:[UIImage imageNamed:@"chooseyes"]];
        }else{
            [self.shareImageView setImage:[UIImage imageNamed:@"chooseno"]];
        }
        
        if (self.model.pFlag == 1) {
            [self.deedaoImageView setImage:[UIImage imageNamed:@"chooseyes"]];
        }else{
            [self.deedaoImageView setImage:[UIImage imageNamed:@"chooseno"]];
        }
    }else{
        self.authorHandleView.hidden = YES;
        self.addButton.hidden = YES;
        [self.postImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-144 * scale);
        }];
        [self.baseView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-45 * scale);
        }];
    }
}

- (void)showPostDetail
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:[UIApplication sharedApplication].keyWindow];
    
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:self.model.postId type:4 start:0 length:10];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        
        if (KIsDictionary(response)) {
            
            NSInteger code = [[response objectForKey:@"status"] integerValue];
            if (code == 4002) {
                [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"PageHasDelete") inView:self];
                return;
            }
            
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                
                if (dtieModel.deleteFlg == 1) {
                    [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"PageHasDelete") inView:self];
                    return;
                }
                
                if (dtieModel.landAccountFlg == 2 && dtieModel.authorId != [UserManager shareManager].user.cid) {
                    [MBProgressHUD showTextHUDWithText:@"该帖已被作者设为私密状态" inView:[UIApplication sharedApplication].keyWindow];
                    return;
                }
                
                DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initWithDTie:dtieModel];
                DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                UINavigationController * na = (UINavigationController *)lg.rootViewController;
                [na pushViewController:detail animated:YES];
            }
        }
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
    }];
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
