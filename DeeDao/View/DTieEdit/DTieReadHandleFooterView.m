//
//  DTieReadHandleFooterView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/6/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieReadHandleFooterView.h"
#import "DDViewFactoryTool.h"
#import "UserManager.h"
#import "DTieCancleWYYRequest.h"
#import "DTieCancleCollectRequest.h"
#import "DTieCollectionRequest.h"
#import <Masonry.h>
#import "DDTool.h"
#import "DDYaoYueViewController.h"
#import "SelectPostSeeRequest.h"
#import "DTieSeeModel.h"
#import "DTieSeeShareViewController.h"
#import "MBProgressHUD+DDHUD.h"
#import "DDLGSideViewController.h"
#import "UserYaoYueBlockModel.h"
#import "DTieYaoyueBlockView.h"
#import "ChangeWYYStatusRequest.h"
//#import <BaiduMapAPI_Map/BMKMapView.h>
//#import <BaiduMapAPI_Utils/BMKGeometry.h>
//#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import "DDLocationManager.h"
#import "SecurityFriendController.h"
#import "SelectWYYBlockRequest.h"
#import "AddUserToWYYRequest.h"
#import "RDAlertView.h"
#import "DTieEditRequest.h"
#import "DTieChooseSecurityView.h"
#import <YYText.h>
#import "DTieGroupViewController.h"
#import "DDGroupAddSwitch.h"
#import "DDAuthorGroupDetailController.h"
#import "DDGroupDetailViewController.h"

@interface DTieReadHandleFooterView ()<SecurityFriendDelegate, DTieGroupViewControllerDelegate>

@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, strong) NSMutableArray * yaoyueList;
@property (nonatomic, strong) UIView * yaoyueView;

@property (nonatomic, strong) UILabel * timeLabel;
//@property (nonatomic, strong) UIButton * handleButton;

@property (nonatomic, strong) UILabel * statusLabel;
@property (nonatomic, strong) UIButton * statusButton;

@property (nonatomic, strong) UILabel * readLabel;
@property (nonatomic, strong) UIButton * readButton;
//@property (nonatomic, strong) UIButton * jubaoButton;

//@property (nonatomic, strong) UIView * mapBaseView;
//@property (nonatomic, strong) BMKMapView * mapView;

@property (nonatomic, strong) UISwitch * addUserSwitch;

@property (nonatomic, strong) UIButton * leftButton;
@property (nonatomic, strong) UIButton * rightButton;
@property (nonatomic, strong) UIButton * createButton;

@property (nonatomic, strong) UIButton * leftHandleButton;
@property (nonatomic, strong) UIButton * rightHandleButton;

@property (nonatomic, strong) DTieChooseSecurityView * securityView;
@property (nonatomic, strong) UILabel * addTipLabel;

@property (nonatomic, strong) UIView * groupAddView;
@property (nonatomic, strong) UILabel * groupAddStateLabel;
@property (nonatomic, strong) UISwitch * groupAddStateSwith;
@property (nonatomic, strong) YYLabel * groupLabel;

@end

@implementation DTieReadHandleFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self createDTieReadHandleView];
    }
    return self;
}

- (void)configWithModel:(DTieModel *)model
{
    self.model = model;
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    if ([UserManager shareManager].user.cid == model.authorId) {
        self.groupAddView.hidden = NO;
    }else{
        self.groupAddView.hidden = YES;
    }
    self.groupLabel.hidden = NO;
    self.leftHandleButton.hidden = YES;
    self.rightHandleButton.hidden = YES;
    
    if (self.model.isValid == 0) {
        self.groupAddStateSwith.on = NO;
        self.groupAddStateLabel.textColor = UIColorFromRGB(0x999999);
        self.groupAddStateLabel.text = @"不允许";
    }
    
//    BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc] init];
//    annotation.coordinate = CLLocationCoordinate2DMake(self.model.sceneAddressLat, self.model.sceneAddressLng);
//    [self.mapView addAnnotation:annotation];
    
    self.timeLabel.text = [NSString stringWithFormat:@"%@：%@", DDLocalizedString(@"Last updated"), [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.model.createTime]];
    
    if (model.authorId == [UserManager shareManager].user.cid) {
//        self.handleButton.hidden = NO;
//        self.jubaoButton.hidden = YES;
        self.readButton.hidden = NO;
        self.statusLabel.hidden = NO;
        self.statusButton.hidden = NO;
        
    }else{
//        self.handleButton.hidden = YES;
//        self.jubaoButton.hidden = YES;
        self.readButton.hidden = YES;
        self.statusLabel.hidden = YES;
        self.statusButton.hidden = YES;
    }
    
    NSString * readText = @"0";
    if (model.readTimes > 0) {
        readText = [NSString stringWithFormat:@"%ld", model.readTimes];
    }
    if (model.readTimes > 10000) {
        readText = @"10000+";
    }
    self.readLabel.text = [NSString stringWithFormat:@"%@：%@", DDLocalizedString(@"# of readers"), readText];
    
//    if (self.model.landAccountFlg == 1) {
//        [self.handleButton setTitle:[NSString stringWithFormat:@"%@:%@", DDLocalizedString(@"ReadSecurity"), DDLocalizedString(@"Open")] forState:UIControlStateNormal];
//    }else if (self.model.landAccountFlg == 2) {
//        [self.handleButton setTitle:[NSString stringWithFormat:@"%@:%@", DDLocalizedString(@"ReadSecurity"), DDLocalizedString(@"Private")] forState:UIControlStateNormal];
//    }else{
//        [self.handleButton setTitle:[NSString stringWithFormat:@"%@:%@", DDLocalizedString(@"ReadSecurity"), DDLocalizedString(@"Network")] forState:UIControlStateNormal];
//    }
    
    if (self.model.status == 0) {
        [self.statusButton setTitle:DDLocalizedString(@"Downline") forState:UIControlStateNormal];
    }else{
        [self.statusButton setTitle:DDLocalizedString(@"Online") forState:UIControlStateNormal];
    }
    
    NSMutableAttributedString * groupStr = [[NSMutableAttributedString alloc] initWithString:@"群归属：" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
    
    if ([UserManager shareManager].user.cid == self.model.authorId) {
        NSMutableAttributedString * spaceStr = [[NSMutableAttributedString alloc] initWithString:@"我的" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x999999)}];
        [groupStr appendAttributedString:spaceStr];
        if (self.model.landAccountFlg == 1) {
            NSMutableAttributedString * spaceStr1 = [[NSMutableAttributedString alloc] initWithString:@" 、" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
            [groupStr appendAttributedString:spaceStr1];
            NSMutableAttributedString * spaceStr2 = [[NSMutableAttributedString alloc] initWithString:@"公开" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x999999)}];
            [groupStr appendAttributedString:spaceStr2];
            if (self.model.groupArray.count > 0) {
                NSMutableAttributedString * spaceStr3 = [[NSMutableAttributedString alloc] initWithString:@" 、" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
                [groupStr appendAttributedString:spaceStr3];
            }else{
                NSMutableAttributedString * spaceStr = [[NSMutableAttributedString alloc] initWithString:@"  " attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
                [groupStr appendAttributedString:spaceStr];
            }
        }else{
            if (self.model.groupArray.count > 0) {
                NSMutableAttributedString * spaceStr = [[NSMutableAttributedString alloc] initWithString:@" 、" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
                [groupStr appendAttributedString:spaceStr];
            }else{
                NSMutableAttributedString * spaceStr = [[NSMutableAttributedString alloc] initWithString:@"  " attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
                [groupStr appendAttributedString:spaceStr];
            }
        }
    }else  if (self.model.landAccountFlg == 1) {
        NSMutableAttributedString * spaceStr = [[NSMutableAttributedString alloc] initWithString:@"公开" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x999999)}];
        [groupStr appendAttributedString:spaceStr];
        if (self.model.groupArray.count > 0) {
            NSMutableAttributedString * spaceStr = [[NSMutableAttributedString alloc] initWithString:@" 、" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
            [groupStr appendAttributedString:spaceStr];
        }else{
            NSMutableAttributedString * spaceStr = [[NSMutableAttributedString alloc] initWithString:@"  " attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
            [groupStr appendAttributedString:spaceStr];
        }
    }
    
    for (NSInteger i = 0; i < self.model.groupArray.count ; i++) {
        DDGroupModel * group = [self.model.groupArray objectAtIndex:i];
        NSMutableAttributedString * tempStr;
        
        if (group.postFlag == 2) {
            tempStr = [[NSMutableAttributedString alloc] initWithString:group.groupName attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0xB721FF)}];
            [tempStr yy_setTextHighlightRange:NSMakeRange(0, tempStr.length) color:UIColorFromRGB(0xB721FF) backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                
                if (group.groupCreateUser == [UserManager shareManager].user.cid) {
                    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                    UINavigationController * na = (UINavigationController *)lg.rootViewController;
                    
                    DDAuthorGroupDetailController * detail = [[DDAuthorGroupDetailController alloc] initWithModel:group];
                    [na pushViewController:detail animated:YES];
                }else{
                    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                    UINavigationController * na = (UINavigationController *)lg.rootViewController;
                    
                    DDGroupDetailViewController * detail = [[DDGroupDetailViewController alloc] initWithModel:group];
                    [na pushViewController:detail animated:YES];
                }
                
            }];
        }else{
            tempStr = [[NSMutableAttributedString alloc] initWithString:group.groupName attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0xDB6283)}];
            [tempStr yy_setTextHighlightRange:NSMakeRange(0, tempStr.length) color:UIColorFromRGB(0xDB6283) backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                
                if (group.groupCreateUser == [UserManager shareManager].user.cid) {
                    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                    UINavigationController * na = (UINavigationController *)lg.rootViewController;
                    
                    DDAuthorGroupDetailController * detail = [[DDAuthorGroupDetailController alloc] initWithModel:group];
                    [na pushViewController:detail animated:YES];
                }else{
                    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                    UINavigationController * na = (UINavigationController *)lg.rootViewController;
                    
                    DDGroupDetailViewController * detail = [[DDGroupDetailViewController alloc] initWithModel:group];
                    [na pushViewController:detail animated:YES];
                }
                
            }];
        }
        [groupStr appendAttributedString:tempStr];
        
        if (i == self.model.groupArray.count-1) {
            NSMutableAttributedString * spaceStr = [[NSMutableAttributedString alloc] initWithString:@"  " attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
            [groupStr appendAttributedString:spaceStr];
        }else{
            NSMutableAttributedString * spaceStr = [[NSMutableAttributedString alloc] initWithString:@" 、" attributes:@{NSFontAttributeName:kPingFangRegular(36 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
            [groupStr appendAttributedString:spaceStr];
        }
    }
    
    UIImage * image = [UIImage imageNamed:@"addGroup"];
    NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:image.size alignToFont:kPingFangRegular(36 * scale) alignment:YYTextVerticalAlignmentCenter];
    
    __weak typeof(self) weakSelf = self;
    [attachText yy_setTextHighlightRange:NSMakeRange(0, attachText.length) color:UIColorFromRGB(0xDB6283) backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        
        if (weakSelf.model.isValid == 0 && weakSelf.model.authorId != [UserManager shareManager].user.cid) {
            [MBProgressHUD showTextHUDWithText:@"非作者不能操作该文章" inView:[UIApplication sharedApplication].keyWindow];
        }
        
        DTieGroupViewController * group = [[DTieGroupViewController alloc] initWithModel:self.model];
        group.delegate = weakSelf;
        DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        UINavigationController * na = (UINavigationController *)lg.rootViewController;
        [na pushViewController:group animated:YES];
    }];
    [groupStr appendAttributedString:attachText];
    
    self.groupLabel.attributedText = groupStr;
    
    [self reloadStatus];
}

- (void)DTieGroupNeedUpdate
{
    UITableView * tableView = (UITableView *)self.superview;
    if ([self.superview isKindOfClass:[UITableView class]]) {
        [tableView reloadData];
    }
}

- (void)configWithWacthPhotos:(NSArray *)models
{
    self.yaoyueList = [[NSMutableArray alloc] initWithArray:models];
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    if (self.leftButton.superview) {
        [self.leftButton removeFromSuperview];
    }
    if (self.rightButton.superview) {
        [self.rightButton removeFromSuperview];
    }
    if (self.createButton.superview) {
        [self.createButton removeFromSuperview];
    }
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"userId == %d", [UserManager shareManager].user.cid];
    NSArray * tempArray = [models filteredArrayUsingPredicate:predicate];
    
    self.leftButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [DDViewFactoryTool cornerRadius:60 * scale withView:self.leftButton];
    self.leftButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.leftButton.layer.borderWidth = 3 * scale;
    
    self.rightButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [DDViewFactoryTool cornerRadius:60 * scale withView:self.rightButton];
    self.rightButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.rightButton.layer.borderWidth = 3 * scale;
    
    self.createButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:@""];
    [DDViewFactoryTool cornerRadius:60 * scale withView:self.createButton];
    self.createButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.createButton.layer.borderWidth = 3 * scale;
    
    if ([UserManager shareManager].user.cid == self.model.authorId) {
        if (self.WYYSelectType == 1) {
            [self.leftButton setTitle:DDLocalizedString(@"Yes") forState:UIControlStateNormal];
            [self.leftButton setBackgroundColor:[UIColorFromRGB(0xDB6283) colorWithAlphaComponent:.1f]];
        }else{
            [self.leftButton setTitle:DDLocalizedString(@"DeletePhotos") forState:UIControlStateNormal];
            [self.leftButton setBackgroundColor:UIColorFromRGB(0xffffff)];
        }
        [self addSubview:self.leftButton];
        [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(50 * scale);
            make.height.mas_equalTo(120 * scale);
            make.width.mas_equalTo(444 * scale);
            make.centerX.mas_equalTo(-kMainBoundsWidth/4.f);
        }];
        [self.leftButton addTarget:self action:@selector(removeButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.WYYSelectType == 2) {
            [self.rightButton setTitle:DDLocalizedString(@"Yes") forState:UIControlStateNormal];
            [self.rightButton setBackgroundColor:[UIColorFromRGB(0xDB6283) colorWithAlphaComponent:.1f]];
        }else{
            [self.rightButton setTitle:DDLocalizedString(@"MakeCover") forState:UIControlStateNormal];
            [self.rightButton setBackgroundColor:UIColorFromRGB(0xffffff)];
        }
        [self addSubview:self.rightButton];
        [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(50 * scale);
            make.height.mas_equalTo(120 * scale);
            make.width.mas_equalTo(444 * scale);
            make.centerX.mas_equalTo(kMainBoundsWidth/4.f);
        }];
        [self.rightButton addTarget:self action:@selector(coverButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.WYYSelectType == 3) {
            [self.createButton setTitle:DDLocalizedString(@"Yes") forState:UIControlStateNormal];
            [self.createButton setBackgroundColor:[UIColorFromRGB(0xDB6283) colorWithAlphaComponent:.1f]];
        }else{
            [self.createButton setTitle:DDLocalizedString(@"PhotoCreatePostLong") forState:UIControlStateNormal];
            [self.createButton setBackgroundColor:UIColorFromRGB(0xffffff)];
        }
        [self addSubview:self.createButton];
        [self.createButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.leftButton.mas_bottom).offset(60 * scale);
            make.left.mas_equalTo(60 * scale);
            make.right.mas_equalTo(-60 * scale);
            make.height.mas_equalTo(120 * scale);
        }];
        [self.createButton addTarget:self action:@selector(createButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        
//        [self.mapBaseView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(350 * scale);
//            make.height.mas_equalTo(.1);
//        }];
        
        [self.readLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(350 * scale + 90 * scale);
        }];
    }else{
        if (tempArray.count > 0) {
            if (self.WYYSelectType == 1) {
                [self.leftButton setTitle:DDLocalizedString(@"Yes") forState:UIControlStateNormal];
                [self.leftButton setBackgroundColor:[UIColorFromRGB(0xDB6283) colorWithAlphaComponent:.1f]];
            }else{
                [self.leftButton setTitle:DDLocalizedString(@"DeletePhotos") forState:UIControlStateNormal];
                [self.leftButton setBackgroundColor:UIColorFromRGB(0xffffff)];
            }
            [self addSubview:self.leftButton];
            [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(50 * scale);
                make.height.mas_equalTo(120 * scale);
                make.width.mas_equalTo(444 * scale);
                make.centerX.mas_equalTo(-kMainBoundsWidth/4.f);
            }];
            [self.leftButton addTarget:self action:@selector(removeButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
            
            if (self.WYYSelectType == 3) {
                [self.rightButton setTitle:DDLocalizedString(@"Yes") forState:UIControlStateNormal];
                [self.rightButton setBackgroundColor:[UIColorFromRGB(0xDB6283) colorWithAlphaComponent:.1f]];
            }else{
                [self.rightButton setTitle:DDLocalizedString(@"PhotoCreatePostShort") forState:UIControlStateNormal];
                [self.rightButton setBackgroundColor:UIColorFromRGB(0xffffff)];
            }
            [self addSubview:self.rightButton];
            [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(50 * scale);
                make.height.mas_equalTo(120 * scale);
                make.width.mas_equalTo(444 * scale);
                make.centerX.mas_equalTo(kMainBoundsWidth/4.f);
            }];
            [self.rightButton addTarget:self action:@selector(createButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
//            [self.mapBaseView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.top.mas_equalTo(170 * scale);
//                make.height.mas_equalTo(.1);
//            }];
            
            [self.readLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(170 * scale + 90 * scale);
            }];
        }else{
//            [self.mapBaseView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.top.mas_equalTo(50 * scale);
//                make.height.mas_equalTo(.1);
//            }];
            [self.readLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(50 * scale + 90 * scale);
            }];
        }
    }
}

- (void)configWithYaoyueModel:(NSArray *)models
{
    self.yaoyueList = [[NSMutableArray alloc] initWithArray:models];
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.groupLabel.hidden = YES;
    self.groupAddView.hidden = YES;
    self.leftHandleButton.hidden = NO;
    self.rightHandleButton.hidden = NO;
//    self.handleButton.hidden = YES;
    self.statusButton.hidden = YES;
    
    [self.yaoyueView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (!self.yaoyueView.superview) {
        [self addSubview:self.yaoyueView];
    }
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xCCCCCC);
    [self.yaoyueView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.top.mas_equalTo(59 * scale);
        make.height.mas_equalTo(2 * scale);
    }];
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentCenter];
    titleLabel.backgroundColor = UIColorFromRGB(0xEFEFF4);
    titleLabel.text = DDLocalizedString(@"Invite Friends");
    [self.yaoyueView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(550 * scale);
        make.height.mas_equalTo(72 * scale);
        make.centerY.mas_equalTo(lineView);
    }];
    CGFloat height = 0;
    if (models.count > 0) {
        
        NSInteger postID = self.model.cid;
        if (postID == 0) {
            postID = self.model.postId;
        }
        
        BOOL isAuthor = NO;
        if ([UserManager shareManager].user.cid == self.model.authorId) {
            isAuthor = YES;
        }
        
        NSInteger agreeCount = 0;
        for (NSInteger i = 0; i < self.yaoyueList.count; i++) {
            UserYaoYueBlockModel * model = [self.yaoyueList objectAtIndex:i];
            model.postID = postID;
            DTieYaoyueBlockView * view = [[DTieYaoyueBlockView alloc] initWithBlockModel:model isAuthor:isAuthor];
            
            __weak typeof(self) weakSelf = self;
            view.removeDidClicked = ^(UserYaoYueBlockModel *blockModel) {
                [weakSelf removeYaoyueBlockModel:blockModel];
            };
            [self.yaoyueView addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo((i+1) * 144 * scale);
                make.left.right.mas_equalTo(0);
                make.height.mas_equalTo(144 * scale);
            }];
            
            if (model.subtype == 1) {
                agreeCount++;
            }
        }
        
        titleLabel.text = [NSString stringWithFormat:@"邀请好友（已有%ld人确定参加）", agreeCount];
        
        NSInteger count = models.count + 1;
        height = 144 * scale * count + 60 * scale;
        
        UIButton * handleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@""];
        [self.yaoyueView addSubview:handleButton];
        height = height + 144 * scale;
        [handleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(60 * scale);
            make.right.mas_equalTo(-60 * scale);
            make.bottom.mas_equalTo(-50 * scale);
            make.height.mas_equalTo(120 * scale);
        }];
        [handleButton setBackgroundColor:UIColorFromRGB(0xDB6283)];
        [DDViewFactoryTool cornerRadius:60 * scale withView:handleButton];
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"userId == %d", [UserManager shareManager].user.cid];
        NSArray * tempArray = [models filteredArrayUsingPredicate:predicate];
        if ([UserManager shareManager].user.cid == self.model.authorId) {
            
            handleButton.hidden = YES;
            [handleButton setTitle:@"拉入DeeDao好友" forState:UIControlStateNormal];
            [handleButton addTarget:self action:@selector(addButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
            
        }else if (tempArray.count == 0) {
            
            handleButton.hidden = NO;
            if (self.model.wyyPermission == 0) {
                [handleButton setTitle:@"参与入口已关闭" forState:UIControlStateNormal];
                [handleButton setBackgroundColor:UIColorFromRGB(0xDDDDDD)];
            }else{
                [handleButton setTitle:@"我也要加入聚会" forState:UIControlStateNormal];
                [handleButton addTarget:self action:@selector(addButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
            }
            
        }else{
            
            handleButton.hidden = NO;
            [handleButton setTitle:@"退出参与" forState:UIControlStateNormal];
            [handleButton addTarget:self action:@selector(addButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self.yaoyueView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(60 * scale);
            make.right.mas_equalTo(-60 * scale);
            make.top.mas_equalTo(50 * scale);
            make.height.mas_equalTo(height);
        }];
//        [self.mapBaseView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(height + 144 * scale);
//        }];
        [self.readLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(height + 144 * scale);
        }];
    }else if (models){
        
        UIButton * handleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"我也要加入聚会"];
        [self.yaoyueView addSubview:handleButton];
        [handleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(60 * scale);
            make.right.mas_equalTo(-60 * scale);
            make.bottom.mas_equalTo(-50 * scale);
            make.height.mas_equalTo(120 * scale);
        }];
        [handleButton setBackgroundColor:UIColorFromRGB(0xDB6283)];
        [DDViewFactoryTool cornerRadius:60 * scale withView:handleButton];
        [handleButton addTarget:self action:@selector(addButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
        
        NSInteger postID = self.model.cid;
        if (postID == 0) {
            postID = self.model.postId;
        }
        
        height = 144 * scale * 2 + 60 * scale;
        
        [self.yaoyueView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(60 * scale);
            make.right.mas_equalTo(-60 * scale);
            make.top.mas_equalTo(50 * scale);
            make.height.mas_equalTo(height);
        }];
//        [self.mapBaseView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(height + 144 * scale);
//        }];
        [self.readLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(height + 144 * scale);
        }];
    }
    
    [self.leftHandleButton setTitle:DDLocalizedString(@"DeleteCurrentPost") forState:UIControlStateNormal];
    [self.rightHandleButton setTitle:DDLocalizedString(@"InviteWXFriend") forState:UIControlStateNormal];
    
    if ([UserManager shareManager].user.cid == self.model.authorId) {
        self.addTipLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
        self.addTipLabel.text = @"允许新参与者主动加入";
        [self addSubview:self.addTipLabel];
        [self.addTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(45 * scale);
            make.left.mas_equalTo(60 * scale);
            make.height.mas_equalTo(120 * scale);
        }];
        
        self.addUserSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        self.addUserSwitch.onTintColor = UIColorFromRGB(0xDB6283);
        [self.addUserSwitch addTarget:self action:@selector(switcDidChange:) forControlEvents:UIControlEventValueChanged];
        
        if (self.model.wyyPermission == 1) {
            self.addUserSwitch.on = YES;
        }else if(self.model.wyyPermission == 0) {
            self.addUserSwitch.on = NO;
        }
        
        [self addSubview:self.addUserSwitch];
        [self.addUserSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.addTipLabel);
            make.right.mas_equalTo(-60 * scale);
            make.width.mas_equalTo(51);
            make.height.mas_equalTo(31);
        }];
        
        UIView * addLineView = [[UIView alloc] initWithFrame:CGRectZero];
        addLineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
        [self addSubview:addLineView];
        [addLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(60 * scale);
            make.right.mas_equalTo(-60 * scale);
            make.height.mas_equalTo(3 * scale);
            make.top.mas_equalTo(self.addTipLabel.mas_bottom);
        }];
        
        [self.yaoyueView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(50 * scale + 144 * scale);
        }];
        
//        [self.mapBaseView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(height + 144 * scale + 144 * scale);
//        }];
        [self.readLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(height + 144 * scale + 144 * scale);
        }];
    }else{
        [self.rightHandleButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(kMainBoundsWidth - 120 * scale);
        }];
        self.leftHandleButton.hidden = YES;
    }
}

- (void)removeYaoyueBlockModel:(UserYaoYueBlockModel *)model
{
    RDAlertView * alertView = [[RDAlertView alloc] initWithTitle:DDLocalizedString(@"Information") message:[NSString stringWithFormat:@"%@  即将被您从参与者中移除，请确认。", model.nickname]];
    RDAlertAction * action1 = [[RDAlertAction alloc] initWithTitle:DDLocalizedString(@"Cancel") handler:^{
        
    } bold:NO];
    
    RDAlertAction * action2 = [[RDAlertAction alloc] initWithTitle:DDLocalizedString(@"Yes") handler:^{
        
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:self];
        ChangeWYYStatusRequest * request =  [[ChangeWYYStatusRequest alloc] initRemoveSelfWithPostID:model.postID userID:model.userId];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [hud hideAnimated:YES];
            if (self.addButtonDidClickedHandle) {
                self.addButtonDidClickedHandle();
            }
            
            [self.yaoyueList removeObject:model];
            [self configWithYaoyueModel:self.yaoyueList];
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [hud hideAnimated:YES];
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
            [hud hideAnimated:YES];
            
        }];
        
    } bold:NO];
    
    [alertView addActions:@[action1, action2]];
    [alertView show];
}

- (void)switcDidChange:(UISwitch *)sender
{
    if (sender == self.groupAddStateSwith) {
        
        NSInteger state = 0;
        if (sender.isOn) {
            self.groupAddStateLabel.textColor = UIColorFromRGB(0xDB6283);
            self.groupAddStateLabel.text = @"允许";
            state = 1;
        }else{
            self.groupAddStateLabel.textColor = UIColorFromRGB(0x999999);
            self.groupAddStateLabel.text = @"不允许";
            state = 0;
        }
        
        [DDGroupAddSwitch cancelRequest];
        DDGroupAddSwitch * request  = [[DDGroupAddSwitch alloc] initPostSwitchWithID:self.model.cid state:state];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.model.isValid = state;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
        }];
        
    }else{
        [SelectWYYBlockRequest cancelRequest];
        SelectWYYBlockRequest * request =  [[SelectWYYBlockRequest alloc] initAddUserSwitchWithPostID:self.model.cid status:sender.isOn];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
        }];
        
        if (sender.isOn) {
            self.model.postClassification = 1;
            self.addTipLabel.text = @"允许新参与者主动加入";
        }else{
            self.model.postClassification = 0;
            self.addTipLabel.text = @"不允许新参与者主动加入";
        }
    }
}

- (void)hiddenWithRemark
{
    self.readLabel.hidden = YES;
    self.readButton.hidden = YES;
    self.timeLabel.hidden = YES;
    self.leftHandleButton.hidden = YES;
    self.rightHandleButton.hidden = YES;
    self.statusLabel.hidden = YES;
    self.statusButton.hidden = YES;
    
//    CGFloat scale = kMainBoundsWidth / 1080.f;
//    [self.handleButton removeFromSuperview];
//    self.handleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0XDB6283) title:DDLocalizedString(@"Security Settings")];
//    [self addSubview:self.handleButton];
//    [self.handleButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(90 * scale);
//        make.width.mas_equalTo(260 * scale);
//        make.right.mas_equalTo(-60 * scale);
//        make.height.mas_equalTo(72 * scale);
//    }];
//    [self.handleButton addTarget:self action:@selector(handleButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
//    [DDViewFactoryTool cornerRadius:12 * scale withView:self.handleButton];
//    self.handleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
//    self.handleButton.layer.borderWidth = 3 * scale;
    
//    if (self.model.landAccountFlg == 1) {
//        [self.handleButton setTitle:[NSString stringWithFormat:@"%@:%@", DDLocalizedString(@"ReadSecurity"), DDLocalizedString(@"Open")] forState:UIControlStateNormal];
//    }else if (self.model.landAccountFlg == 2) {
//        [self.handleButton setTitle:[NSString stringWithFormat:@"%@:%@", DDLocalizedString(@"ReadSecurity"), DDLocalizedString(@"Private")] forState:UIControlStateNormal];
//    }else{
//        [self.handleButton setTitle:[NSString stringWithFormat:@"%@:%@", DDLocalizedString(@"ReadSecurity"), DDLocalizedString(@"Network")] forState:UIControlStateNormal];
//    }
    
//    self.handleButton.enabled = NO;
}

- (void)createDTieReadHandleView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
//    self.mapBaseView = [[UIView alloc] initWithFrame:CGRectZero];
//    self.mapBaseView.backgroundColor = UIColorFromRGB(0xFFFFFF);
//    [self addSubview:self.mapBaseView];
//    [self.mapBaseView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(50 * scale);
//        make.left.mas_equalTo(60 * scale);
//        make.height.mas_equalTo(450 * scale);
//        make.right.mas_equalTo(-60 * scale);
//    }];
//    self.mapBaseView.layer.cornerRadius = 24 * scale;
//    self.mapBaseView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
//    self.mapBaseView.layer.shadowOpacity = .3f;
//    self.mapBaseView.layer.shadowRadius = 24 * scale;
//    self.mapBaseView.layer.shadowOffset = CGSizeMake(0, 12 * scale);
//
//    UITapGestureRecognizer * mapTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationButtonClicked)];
//    [self.mapBaseView addGestureRecognizer:mapTap];
//
//    self.mapView = [[BMKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//
//    self.mapView.delegate = self;
//    //设置定位图层自定义样式
//    BMKLocationViewDisplayParam *userlocationStyle = [[BMKLocationViewDisplayParam alloc] init];
//    //跟随态旋转角度是否生效
//    userlocationStyle.isRotateAngleValid = NO;
//    //精度圈是否显示
//    userlocationStyle.isAccuracyCircleShow = NO;
//    userlocationStyle.locationViewOffsetX = 0;//定位偏移量（经度）
//    userlocationStyle.locationViewOffsetY = 0;//定位偏移量（纬度）
//    [self.mapView updateLocationViewWithParam:userlocationStyle];
//    self.mapView.showsUserLocation = YES;
//    self.mapView.userTrackingMode = BMKUserTrackingModeNone;
//    self.mapView.gesturesEnabled = NO;
//    self.mapView.buildingsEnabled = NO;
//    self.mapView.showMapPoi = NO;
//    [self.mapView updateLocationData:[DDLocationManager shareManager].userLocation];
//
//    [self.mapBaseView addSubview:self.mapView];
//    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(0);
//    }];
//
//    for (UIView * view in self.mapView.subviews) {
//        if ([NSStringFromClass([view class]) isEqualToString:@"BMKInternalMapView"]) {
//            for (UIView * tempView in view.subviews) {
//                if ([tempView isKindOfClass:[UIImageView class]] && tempView.frame.size.width == 66) {
//                    tempView.alpha = 0;
//                    break;
//                }
//            }
//        }
//    }
    
    self.yaoyueView = [[UIView alloc] initWithFrame:CGRectZero];
    self.yaoyueView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self addSubview:self.yaoyueView];
    self.yaoyueView.layer.cornerRadius = 24 * scale;
    self.yaoyueView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    self.yaoyueView.layer.shadowOpacity = .3f;
    self.yaoyueView.layer.shadowRadius = 24 * scale;
    self.yaoyueView.layer.shadowOffset = CGSizeMake(0, 12 * scale);
    
    self.readLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.readLabel.text = DDLocalizedString(@"# of readers");
    [self addSubview:self.readLabel];
    [self.readLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(90 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    self.readButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0XDB6283) title:DDLocalizedString(@"See Read Map")];
    [self addSubview:self.readButton];
    [self.readButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.readLabel);
        make.width.mas_equalTo(260 * scale);
        make.left.mas_equalTo(self.readLabel.mas_right).mas_equalTo(20 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    [self.readButton addTarget:self action:@selector(readButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.readLabel.mas_bottom).offset(70 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
//    self.handleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0XDB6283) title:DDLocalizedString(@"Security Settings")];
//    [self addSubview:self.handleButton];
//    [self.handleButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(self.timeLabel);
//        make.width.mas_equalTo(260 * scale);
//        make.right.mas_equalTo(-60 * scale);
//        make.height.mas_equalTo(72 * scale);
//    }];
//    [self.handleButton addTarget:self action:@selector(handleButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
//    [DDViewFactoryTool cornerRadius:12 * scale withView:self.handleButton];
//    self.handleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
//    self.handleButton.layer.borderWidth = 3 * scale;
    
//    self.jubaoButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0XDB6283) title:[NSString stringWithFormat:@" %@", DDLocalizedString(@"Report")]];
//    [self.jubaoButton setImage:[UIImage imageNamed:@"jubaoyes"] forState:UIControlStateNormal];
//    [self addSubview:self.jubaoButton];
//    [self.jubaoButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(self.timeLabel);
//        make.right.mas_equalTo(-60 * scale);
//        make.height.mas_equalTo(72 * scale);
//    }];
//    self.jubaoButton.hidden = YES;
//    [self.jubaoButton addTarget:self action:@selector(handleButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    
    self.statusLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.statusLabel.text = [NSString stringWithFormat:@"%@:", DDLocalizedString(@"Status")];
    [self addSubview:self.statusLabel];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.timeLabel);
        make.left.mas_equalTo(self.timeLabel.mas_right).offset(45 * scale);
        make.height.mas_equalTo(50 * scale);
    }];
    
    self.statusButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(36 * scale) titleColor:UIColorFromRGB(0XDB6283) title:DDLocalizedString(@"Online")];
    [self addSubview:self.statusButton];
    [self.statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.statusLabel);
        make.width.mas_equalTo(100 * scale);
        make.left.mas_equalTo(self.statusLabel.mas_right);
        make.height.mas_equalTo(50 * scale);
    }];
    [self.statusButton addTarget:self action:@selector(statusButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    
    self.groupAddView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.groupAddView];
    [self.groupAddView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(50 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(145 * scale);
    }];
    
    UILabel * groupTitle = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    groupTitle.text = @"是否允许非作者投递入群";
    [self.groupAddView addSubview:groupTitle];
    [groupTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.top.bottom.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
    
    self.groupAddStateSwith = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.groupAddStateSwith.onTintColor = UIColorFromRGB(0xDB6283);
    self.groupAddStateSwith.on = YES;
    [self.groupAddStateSwith addTarget:self action:@selector(switcDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.groupAddView addSubview:self.groupAddStateSwith];
    [self.groupAddStateSwith mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
        make.width.mas_equalTo(144 * scale);
        make.height.mas_equalTo(96 * scale);
    }];
    [self.groupAddStateSwith addTarget:self action:@selector(switcDidChange:) forControlEvents:UIControlEventValueChanged];
    
    self.groupAddStateLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(43 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    self.groupAddStateLabel.text = @"允许";
    [self.groupAddView addSubview:self.groupAddStateLabel];
    [self.groupAddStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(self.groupAddStateSwith.mas_left).offset(-48 * scale);
        make.top.bottom.mas_equalTo(0);
    }];
    
    UIView * groupLineView = [[UIView alloc] initWithFrame:CGRectZero];
    groupLineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.groupAddView addSubview:groupLineView];
    [groupLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(3 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    
    self.groupLabel = [[YYLabel alloc] init];
    self.groupLabel.numberOfLines = 0;
    self.groupLabel.preferredMaxLayoutWidth = kMainBoundsWidth - 120 * scale;
    [self addSubview:self.groupLabel];
    [self.groupLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-5 * scale);
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    
    self.leftHandleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"BackList")];
    [DDViewFactoryTool cornerRadius:60 * scale withView:self.leftHandleButton];
    self.leftHandleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.leftHandleButton.layer.borderWidth = 3 * scale;
    [self addSubview:self.leftHandleButton];
    [self.leftHandleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(-kMainBoundsWidth/4.f);
        make.height.mas_equalTo(120 * scale);
        make.width.mas_equalTo(444 * scale);
        make.bottom.mas_equalTo(-40 * scale);
    }];
    [self.leftHandleButton addTarget:self action:@selector(leftHandleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.rightHandleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:DDLocalizedString(@"SendWXFriend")];
    [DDViewFactoryTool cornerRadius:60 * scale withView:self.rightHandleButton];
    self.rightHandleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.rightHandleButton.layer.borderWidth = 3 * scale;
    [self addSubview:self.rightHandleButton];
    [self.rightHandleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(kMainBoundsWidth/4.f);
        make.height.mas_equalTo(120 * scale);
        make.width.mas_equalTo(444 * scale);
        make.bottom.mas_equalTo(-40 * scale);
    }];
    [self.rightHandleButton addTarget:self action:@selector(rightHandleButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
}

//- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
//{
//    BMKAnnotationView * view = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BMKAnnotationView"];
//    view.annotation = annotation;
//    view.image = [UIImage imageNamed:@"location"];
//    view.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:[UIView new]];
//    
//    return view;
//}
//
//- (void)mapViewDidFinishLoading:(BMKMapView *)mapView
//{
//    BMKCoordinateRegion viewRegion;
//    
//    if ([DDLocationManager shareManager].userLocation.location) {
//        
//        CLLocationDegrees lng = fabs([DDLocationManager shareManager].userLocation.location.coordinate.longitude - self.model.sceneAddressLng);
//        CLLocationDegrees lat = fabs([DDLocationManager shareManager].userLocation.location.coordinate.latitude - self.model.sceneAddressLat);
//        
//        CLLocationDegrees centerLat;
//        CLLocationDegrees centerLng;
//        if ([DDLocationManager shareManager].userLocation.location.coordinate.longitude > self.model.sceneAddressLng) {
//            centerLng = self.model.sceneAddressLng + lng / 2.f;
//        }else{
//            centerLng = [DDLocationManager shareManager].userLocation.location.coordinate.longitude + lng / 2.f;
//        }
//        
//        if ([DDLocationManager shareManager].userLocation.location.coordinate.latitude > self.model.sceneAddressLat) {
//            centerLat = self.model.sceneAddressLat + lat / 2.f;
//        }else{
//            centerLat = [DDLocationManager shareManager].userLocation.location.coordinate.latitude + lat / 2.f;
//        }
//        
//        if (lng < 0.01) {
//            lng = 0.01;
//        }
//        if (lat < 0.01) {
//            lat = 0.01;
//        }
//        
//        viewRegion = BMKCoordinateRegionMake(CLLocationCoordinate2DMake(centerLat, centerLng), BMKCoordinateSpanMake(lat * 1.5, lng * 1.5));
//    }else{
//        viewRegion = BMKCoordinateRegionMake(CLLocationCoordinate2DMake(self.model.sceneAddressLat, self.model.sceneAddressLng), BMKCoordinateSpanMake(.01, .01));
//    }
//    
//    [self.mapView setRegion:viewRegion animated:YES];
//}

- (void)statusButtonDidTouchUpInside
{
    [DTieEditRequest cancelRequest];
    
    if (self.model.status == 0) {
        self.model.status = 1;
    }else{
        self.model.status = 0;
    }
    if (self.model.status == 0) {
        [self.statusButton setTitle:DDLocalizedString(@"Downline") forState:UIControlStateNormal];
    }else{
        [self.statusButton setTitle:DDLocalizedString(@"Online") forState:UIControlStateNormal];
    }
    
    DTieEditRequest * request = [[DTieEditRequest alloc] initWithStaus:self.model.status postID:self.model.cid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)locationButtonClicked
{
    if (self.locationButtonDidClicked) {
        self.locationButtonDidClicked();
    }
}

- (void)leftHandleButtonDidClicked
{
    if (self.yaoyueList) {
        if (self.leftHandleButtonBlock) {
            self.leftHandleButtonBlock();
        }
    }else{
        if (self.backHandleButtonBlock) {
            self.backHandleButtonBlock();
        }
    }
}

- (void)readButtonDidTouchUpInside
{
    NSInteger postID = self.model.cid;
    if (postID == 0) {
        postID = self.model.postId;
    }
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:[UIApplication sharedApplication].keyWindow];
    
    SelectPostSeeRequest * request = [[SelectPostSeeRequest alloc] initWithPostID:postID];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                NSMutableArray * dataSource = [[NSMutableArray alloc] init];
                for (NSDictionary * info in data) {
                    DTieSeeModel * model = [DTieSeeModel mj_objectWithKeyValues:info];
                    [dataSource addObject:model];
                }
                DTieSeeShareViewController * share = [[DTieSeeShareViewController alloc] initWithSource:dataSource model:self.model];
                DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                UINavigationController * na = (UINavigationController *)lg.rootViewController;
                [na pushViewController:share animated:YES];
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"获取阅读信息失败" inView:[UIApplication sharedApplication].keyWindow];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:[UIApplication sharedApplication].keyWindow];
        
    }];
}

- (void)tapDidClicked
{
    DDYaoYueViewController * yaoyue = [[DDYaoYueViewController alloc] initWithDtieModel:self.model];
    
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    [na pushViewController:yaoyue animated:YES];
}

- (void)reloadStatus
{
    
}

//- (void)handleButtonDidTouchUpInside
//{
//    if (self.model.landAccountFlg == 1) {
//        self.model.landAccountFlg = 2;
//        [self.handleButton setTitle:[NSString stringWithFormat:@"%@:%@", DDLocalizedString(@"ReadSecurity"), DDLocalizedString(@"Private")] forState:UIControlStateNormal];
//
//        DTieEditRequest * request = [[DTieEditRequest alloc] initWithAccountFlg:2 groupList:nil postID:self.model.cid];
//        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
//
//        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
//
//        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
//
//        }];
//
//    }else if (self.model.landAccountFlg == 2) {
//        [self.handleButton setTitle:[NSString stringWithFormat:@"%@:%@", DDLocalizedString(@"ReadSecurity"), DDLocalizedString(@"Network")] forState:UIControlStateNormal];
//        if (self.model.allowToSeeList.count > 0) {
//            self.model.landAccountFlg = 4;
//        }else{
//            self.model.landAccountFlg = 6;
//        }
//
//        [self.securityView show];
//    }else{
//        self.model.landAccountFlg = 1;
//        [self.handleButton setTitle:[NSString stringWithFormat:@"%@:%@", DDLocalizedString(@"ReadSecurity"), DDLocalizedString(@"Open")] forState:UIControlStateNormal];
//
//        DTieEditRequest * request = [[DTieEditRequest alloc] initWithAccountFlg:1 groupList:nil postID:self.model.cid];
//        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
//
//        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
//
//        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
//
//        }];
//    }
//
//    if (self.handleButtonDidClicked) {
//        self.handleButtonDidClicked();
//    }
//}

- (void)rightHandleButtonDidTouchUpInside
{
    if (self.rightHandleButtonBlock) {
        self.rightHandleButtonBlock();
    }
}

- (void)removeButtonDidTouchUpInside
{
    if (self.WYYSelectType == 1) {
        self.WYYSelectType = 0;
    }else{
        self.WYYSelectType = 1;
    }
    
    [self configWithWacthPhotos:self.yaoyueList];
    if (self.selectButtonDidClicked) {
        self.selectButtonDidClicked(self.WYYSelectType);
    }
}

- (void)coverButtonDidTouchUpInside
{
    if (self.WYYSelectType == 2) {
        self.WYYSelectType = 0;
    }else{
        self.WYYSelectType = 2;
    }
    
    [self configWithWacthPhotos:self.yaoyueList];
    if (self.selectButtonDidClicked) {
        self.selectButtonDidClicked(self.WYYSelectType);
    }
}

- (void)createButtonDidTouchUpInside
{
    if (self.WYYSelectType == 3) {
        self.WYYSelectType = 0;
    }else{
        self.WYYSelectType = 3;
    }
    
    [self configWithWacthPhotos:self.yaoyueList];
    if (self.selectButtonDidClicked) {
        self.selectButtonDidClicked(self.WYYSelectType);
    }
}

- (void)addButtonDidClicked
{
    NSInteger postID = self.model.cid;
    if (postID == 0) {
        postID = self.model.postId;
    }
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"userId == %d", [UserManager shareManager].user.cid];
    NSArray * tempArray = [self.yaoyueList filteredArrayUsingPredicate:predicate];
    
    if ([UserManager shareManager].user.cid == self.model.authorId) {
        
        SecurityFriendController * friend = [[SecurityFriendController alloc] initMulSelectWithDataDict:[NSDictionary new] nameKeys:[NSArray new] selectModels:[NSMutableArray new]];
        friend.delegate = self;
        
        DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        UINavigationController * na = (UINavigationController *)lg.rootViewController;
        
        [na pushViewController:friend animated:YES];
        
        
    }else if (tempArray.count == 0) {
        
        ChangeWYYStatusRequest * request =  [[ChangeWYYStatusRequest alloc] initWithPostID:postID subType:1];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            if (self.addButtonDidClickedHandle) {
                self.addButtonDidClickedHandle();
            }
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
        }];
        
    }else{
        
        RDAlertView * alertView = [[RDAlertView alloc] initWithTitle:DDLocalizedString(@"Information") message:[NSString stringWithFormat:@"您将退出参与该次活动，请确认。"]];
        RDAlertAction * action1 = [[RDAlertAction alloc] initWithTitle:DDLocalizedString(@"Cancel") handler:^{
            
        } bold:NO];
        
        RDAlertAction * action2 = [[RDAlertAction alloc] initWithTitle:DDLocalizedString(@"Yes") handler:^{
            
            ChangeWYYStatusRequest * request =  [[ChangeWYYStatusRequest alloc] initRemoveSelfWithPostID:postID userID:[UserManager shareManager].user.cid];
            [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                if (self.addButtonDidClickedHandle) {
                    self.addButtonDidClickedHandle();
                }
            } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
            } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
                
            }];
            
        } bold:NO];
        
        [alertView addActions:@[action1, action2]];
        [alertView show];
    }
}

- (void)friendDidMulSelectComplete:(NSArray *)selectArray
{
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    [na popViewControllerAnimated:YES];
    
    NSMutableArray * array = [[NSMutableArray alloc] init];
    
//    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"type == 2"];
//    NSArray * tempArray = [self.modelSources filteredArrayUsingPredicate:predicate];
    
    for (UserModel * model in selectArray) {
        [array addObject:@(model.cid)];
    }
    AddUserToWYYRequest * request = [[AddUserToWYYRequest alloc] initWithUserList:array postId:self.model.cid];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (self.addButtonDidClickedHandle) {
            self.addButtonDidClickedHandle();
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (DTieChooseSecurityView *)securityView
{
    if (!_securityView) {
        _securityView = [[DTieChooseSecurityView alloc] initWithFrame:[UIScreen mainScreen].bounds model:self.model];
    }
    return _securityView;
}

@end
