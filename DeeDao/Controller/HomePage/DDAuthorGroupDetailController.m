//
//  DDAuthorGroupDetailController.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/10.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDAuthorGroupDetailController.h"
#import "UserManager.h"
#import "DDTool.h"
#import "DTieEditTextViewController.h"
#import <UIImageView+WebCache.h>
#import <TZImagePickerController.h>
#import "MBProgressHUD+DDHUD.h"
#import "DDGroupRequest.h"
#import "QNDDUploadManager.h"
#import "DDGroupPeopleManagerController.h"
#import "DDGroupPostManagerController.h"
#import "DDGroupGiveViewController.h"
#import "RDAlertView.h"
#import "DDGroupPostListViewController.h"
#import "ConverUtil.h"

@interface DDAuthorGroupDetailController () <DTEditTextViewControllerDelegate, TZImagePickerControllerDelegate>

@property (nonatomic, strong) DDGroupModel * model;

@property (nonatomic, strong) UIView * headerView;
@property (nonatomic, strong) UIImageView * coverImageview;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * infoLabel;

@property (nonatomic, strong) UILabel * updateLabel;

@property (nonatomic, strong) UILabel * switchLabel1;
@property (nonatomic, strong) UISwitch * switch1;
@property (nonatomic, strong) UILabel * switchLabel2;
@property (nonatomic, strong) UISwitch * switch2;
@property (nonatomic, strong) UILabel * switchLabel3;
@property (nonatomic, strong) UISwitch * switch3;
@property (nonatomic, strong) UILabel * switchLabel4;
@property (nonatomic, strong) UISwitch * switch4;

@property (nonatomic, strong) UILabel * editLabel;

@property (nonatomic, strong) UIView * footerView;

@property (nonatomic, strong) UIImageView * tagView;

@end

@implementation DDAuthorGroupDetailController

- (instancetype)initWithModel:(DDGroupModel *)model
{
    if (self = [super init]) {
        self.model = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 360.f;
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(-kStatusBarHeight);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    [self createHeaderView];
    tableView.tableHeaderView = self.headerView;
    
    [self createFooterView];
    tableView.tableFooterView = self.footerView;
    
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5 * scale);
        make.top.mas_equalTo(kStatusBarHeight + 5 * scale);
        make.width.height.mas_equalTo(40 * scale);
    }];
    
    UIButton * shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-5 * scale);
        make.top.mas_equalTo(kStatusBarHeight + 5 * scale);
        make.width.height.mas_equalTo(40 * scale);
    }];
}

- (void)updateGroup
{
    NSString * title = self.titleLabel.text;
    NSString * ramerk = self.infoLabel.text;
    
    NSInteger groupSearchState = 0;
    if (self.switch1.isOn) {
        groupSearchState = 1;
    }
    
    NSInteger joinAuthorize = 0;
    if (self.switch2.isOn) {
        joinAuthorize = 1;
    }
    
    NSInteger readWriteAuthorize = 2;
    if (self.switch3.isOn) {
        readWriteAuthorize = 1;
    }
    
    NSInteger groupState = 0;
    if (self.switch4.isOn) {
        groupState = 1;
    }
    
    DDGroupRequest * request = [[DDGroupRequest alloc] initUpdateWithID:self.model.cid title:title reamrk:ramerk groupPic:self.model.groupPic joinAuthorize:joinAuthorize groupState:groupState readWriteAuthorize:readWriteAuthorize groupSearchState:groupSearchState];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)shareButtonDidClicked
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    
    NSString * groupID = [NSString stringWithFormat:@"%ld", self.model.cid];
    
    NSString * string = [NSString stringWithFormat:@"group:%@+%@", timeString, groupID];
    NSString * result = [ConverUtil base64EncodeString:string];
    
    NSString * pasteString = [NSString stringWithFormat:@"【DeeDao地到】%@#复制此消息，打开DeeDao地到查看群组详情", result];
    
    UIPasteboard * pasteBoard = [UIPasteboard generalPasteboard];
    pasteBoard.string = pasteString;
    [MBProgressHUD showTextHUDWithText:@"已拷贝口令。在微博或电邮粘贴口令并发出。对方拷贝，并打开Deedao, 便可打开群组" inView:[UIApplication sharedApplication].keyWindow];
}

- (void)leftButtonDidClicked
{
    DDGroupPeopleManagerController * people = [[DDGroupPeopleManagerController alloc] initWithModel:self.model];
    [self.navigationController pushViewController:people animated:YES];
}

- (void)rightButtonDidClicked
{
    DDGroupPostManagerController * post = [[DDGroupPostManagerController alloc] initWithModel:self.model];
    [self.navigationController pushViewController:post animated:YES];
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)coverImageViewDidClicked
{
    TZImagePickerController * picker = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    picker.allowPickingOriginalPhoto = NO;
    picker.allowPickingVideo = NO;
    picker.allowTakeVideo = NO;
    picker.showSelectedIndex = NO;
    picker.allowCrop = NO;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos
{
    if (photos) {
        UIImage * image = [photos firstObject];
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在上传图片" inView:self.view];
        QNDDUploadManager * manager = [[QNDDUploadManager alloc] init];
        [manager uploadImage:image progress:^(NSString *key, float percent) {
            
        } success:^(NSString *url) {
            [hud hideAnimated:YES];
            self.model.groupPic = url;
            [self.coverImageview setImage:image];
            [self updateGroup];
        } failed:^(NSError *error) {
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"图片上传失败" inView:self.view];
        }];
    }
}

- (void)createHeaderView
{
    CGFloat scale = kMainBoundsWidth / 360.f;
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 760 * scale)];
    
    self.coverImageview = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"groupFirstImage.png"]];
    
    if (self.model.groupPic) {
        [self.coverImageview sd_setImageWithURL:[NSURL URLWithString:self.model.groupPic] placeholderImage:[UIImage imageNamed:@"groupFirstImage.png"]];
    }
    
    self.coverImageview.clipsToBounds = YES;
    [self.headerView addSubview:self.coverImageview];
    [self.coverImageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(240 * scale);
    }];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverImageViewDidClicked)];
    self.coverImageview.userInteractionEnabled = YES;
    [self.coverImageview addGestureRecognizer:tap];
    
    self.titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangMedium(24 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    self.titleLabel.text = self.model.groupName;
    [self.headerView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.coverImageview.mas_bottom).offset(16 * scale);
        make.left.mas_equalTo(20 * scale);
        make.height.mas_equalTo(28 * scale);
        make.width.mas_lessThanOrEqualTo(kMainBoundsWidth - 70 * scale);
    }];
    
    UIButton * editTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editTitleButton setImage:[UIImage imageNamed:@"editTitle"] forState:UIControlStateNormal];
    [editTitleButton addTarget:self action:@selector(editTitleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:editTitleButton];
    [editTitleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(11 * scale);
        make.width.height.mas_equalTo(24 * scale);
    }];
    
    self.infoLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentLeft];
    self.infoLabel.text = @"暂无简介";
    if (self.model.remark) {
        self.infoLabel.text = self.model.remark;
    }
    [self.headerView addSubview:self.infoLabel];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(16 * scale);
        make.left.mas_equalTo(20 * scale);
        make.height.mas_equalTo(16 * scale);
        make.width.mas_lessThanOrEqualTo(kMainBoundsWidth - 70 * scale);
    }];
    
    UIButton * editInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editInfoButton setImage:[UIImage imageNamed:@"editTitle"] forState:UIControlStateNormal];
    [editInfoButton addTarget:self action:@selector(editInfoButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:editInfoButton];
    [editInfoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.infoLabel);
        make.left.mas_equalTo(self.infoLabel.mas_right).offset(11 * scale);
        make.width.height.mas_equalTo(24 * scale);
    }];
    
    UIView * logoView = [[UIView alloc] initWithFrame:CGRectZero];
    logoView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    logoView.layer.shadowColor = [UIColor colorWithRed:245/255.0 green:166/255.0 blue:35/255.0 alpha:1.0].CGColor;
    logoView.layer.shadowOffset = CGSizeMake(0,2);
    logoView.layer.shadowOpacity = 1;
    logoView.layer.shadowRadius = 4;
    logoView.layer.cornerRadius = 20 * scale;
    [self.headerView addSubview:logoView];
    [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.infoLabel.mas_bottom).offset(16 * scale);
        make.left.mas_equalTo(20 * scale);
        make.width.height.mas_equalTo(40 * scale);
    }];
    
    UIImageView * logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [logoImageView sd_setImageWithURL:[NSURL URLWithString:[UserManager shareManager].user.portraituri]];
    [logoView addSubview:logoImageView];
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:20 * scale withView:logoImageView];
    
    UILabel * nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(12 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    nameLabel.text = [UserManager shareManager].user.nickname;
    [self.headerView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(logoImageView);
        make.left.mas_equalTo(logoImageView.mas_right).offset(8 * scale);
        make.height.mas_equalTo(20 * scale);
    }];
    
    UILabel * timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(12 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    NSString * date = [DDTool getTimeWithFormat:@"yyyy年MM月" time:self.model.groupCreateDate];
    timeLabel.text = [NSString stringWithFormat:@"%@建立", date];
    [self.headerView addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(logoImageView.mas_bottom).offset(10 * scale);
        make.left.mas_equalTo(20 * scale);
        make.height.mas_equalTo(14 * scale);
    }];
    
    self.updateLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(12 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    self.updateLabel.text = @"更新于：2018年12月21日 20:00 星期一";
    [self.headerView addSubview:self.updateLabel];
    [self.updateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(timeLabel.mas_bottom).offset(5 * scale);
        make.left.mas_equalTo(20 * scale);
        make.height.mas_equalTo(15 * scale);
    }];
    
    if (self.model.newFlag == 1) {
        self.tagView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"NEW"]];
        [self.headerView addSubview:self.tagView];
        [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.updateLabel.mas_right).offset(8 * scale);
            make.centerY.mas_equalTo(self.updateLabel);
            make.width.mas_equalTo(22 * scale);
            make.height.mas_equalTo(12 * scale);
        }];
    }
    
    UIButton * listButton = [DDViewFactoryTool createButtonWithFrame: CGRectZero font:kPingFangRegular(14 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"列表浏览"];
    [listButton setImage:[UIImage imageNamed:@"listliulan"] forState:UIControlStateNormal];
    [DDViewFactoryTool cornerRadius:20 * scale withView:listButton];
    listButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    listButton.layer.borderWidth = 1.f;
    [self.headerView addSubview:listButton];
    [listButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.updateLabel.mas_bottom).offset(20 * scale);
        make.left.mas_equalTo(20 * scale);
        make.width.mas_equalTo(148 * scale);
        make.height.mas_equalTo(40 * scale);
    }];
    [listButton addTarget:self action:@selector(listButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * mapButton = [DDViewFactoryTool createButtonWithFrame: CGRectZero font:kPingFangRegular(14 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"地图浏览"];
    [mapButton setImage:[UIImage imageNamed:@"mapliulan"] forState:UIControlStateNormal];
    [DDViewFactoryTool cornerRadius:20 * scale withView:mapButton];
    mapButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    mapButton.layer.borderWidth = 1.f;
    [self.headerView addSubview:mapButton];
    [mapButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.updateLabel.mas_bottom).offset(20 * scale);
        make.right.mas_equalTo(-20 * scale);
        make.width.mas_equalTo(148 * scale);
        make.height.mas_equalTo(40 * scale);
    }];
    [mapButton addTarget:self action:@selector(mapButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * leftButton = [DDViewFactoryTool createButtonWithFrame: CGRectZero font:kPingFangRegular(14 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"群员管理"];
    [leftButton setImage:[UIImage imageNamed:@"groupPeople"] forState:UIControlStateNormal];
    [DDViewFactoryTool cornerRadius:20 * scale withView:leftButton];
    leftButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    leftButton.layer.borderWidth = 1.f;
    [self.headerView addSubview:leftButton];
    [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(listButton.mas_bottom).offset(20 * scale);
        make.left.mas_equalTo(20 * scale);
        make.width.mas_equalTo(148 * scale);
        make.height.mas_equalTo(40 * scale);
    }];
    [leftButton addTarget:self action:@selector(leftButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * rightButton = [DDViewFactoryTool createButtonWithFrame: CGRectZero font:kPingFangRegular(14 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"群帖管理"];
    [rightButton setImage:[UIImage imageNamed:@"groupTie"] forState:UIControlStateNormal];
    [DDViewFactoryTool cornerRadius:20 * scale withView:rightButton];
    rightButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    rightButton.layer.borderWidth = 1.f;
    [self.headerView addSubview:rightButton];
    [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(listButton.mas_bottom).offset(20 * scale);
        make.right.mas_equalTo(-20 * scale);
        make.width.mas_equalTo(148 * scale);
        make.height.mas_equalTo(40 * scale);
    }];
    [rightButton addTarget:self action:@selector(rightButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIView * view1 = [[UIView alloc] initWithFrame:CGRectZero];
    view1.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.headerView addSubview:view1];
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(leftButton.mas_bottom).offset(15 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(50 * scale);
    }];
    
    UILabel * titleLabel1 = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    titleLabel1.text = @"群类型";
    [view1 addSubview:titleLabel1];
    [titleLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(20 * scale);
    }];
    
    self.switch1 = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.switch1.onTintColor = UIColorFromRGB(0xDB6283);
    [self.switch1 addTarget:self action:@selector(switcDidChange:) forControlEvents:UIControlEventValueChanged];
    [view1 addSubview:self.switch1];
    [self.switch1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-20 * scale);
        make.width.mas_equalTo(51 * scale);
        make.height.mas_equalTo(31 * scale);
    }];
    
    self.switchLabel1 = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [view1 addSubview:self.switchLabel1];
    [self.switchLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(self.switch1.mas_left).offset(-15 * scale);
        make.height.mas_equalTo(20 * scale);
    }];
    if (self.model.groupSearchState == 1) {
        self.switch1.on = YES;
        self.switchLabel1.textColor = UIColorFromRGB(0xDB6283);
        self.switchLabel1.text = @"公开群";
    }else{
        self.switch1.on = NO;
        self.switchLabel1.textColor = UIColorFromRGB(0x999999);
        self.switchLabel1.text = @"非公开群";
    }
    
    UIView * lineView1 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView1.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [view1 addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20 * scale);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(-20 * scale);
    }];
    
    UIView * view2 = [[UIView alloc] initWithFrame:CGRectZero];
    view2.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.headerView addSubview:view2];
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(view1.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(50 * scale);
    }];
    
    UILabel * titleLabel2 = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    titleLabel2.text = @"新群员加入";
    [view2 addSubview:titleLabel2];
    [titleLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(20 * scale);
    }];
    
    self.switch2 = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.switch2.on = YES;
    self.switch2.onTintColor = UIColorFromRGB(0xDB6283);
    [self.switch2 addTarget:self action:@selector(switcDidChange:) forControlEvents:UIControlEventValueChanged];
    [view2 addSubview:self.switch2];
    [self.switch2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-20 * scale);
        make.width.mas_equalTo(51 * scale);
        make.height.mas_equalTo(31 * scale);
    }];
    
    self.switchLabel2 = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [view2 addSubview:self.switchLabel2];
    [self.switchLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(self.switch2.mas_left).offset(-15 * scale);
        make.height.mas_equalTo(20 * scale);
    }];
    if (self.model.joinAuthorize == 1) {
        self.switch2.on = YES;
        self.switchLabel2.textColor = UIColorFromRGB(0xDB6283);
        self.switchLabel2.text = @"需审批";
    }else{
        self.switch2.on = NO;
        self.switchLabel2.textColor = UIColorFromRGB(0x999999);
        self.switchLabel2.text = @"不需审批";
    }
    
    UIView * lineView2 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView2.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [view2 addSubview:lineView2];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20 * scale);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(-20 * scale);
    }];
    
    UIView * view3 = [[UIView alloc] initWithFrame:CGRectZero];
    view3.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.headerView addSubview:view3];
    [view3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(view2.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(50 * scale);
    }];
    
    UILabel * titleLabel3 = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    titleLabel3.text = @"普通群员投递默认权限";
    [view3 addSubview:titleLabel3];
    [titleLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(20 * scale);
    }];
    
    self.switch3 = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.switch3.on = YES;
    self.switch3.onTintColor = UIColorFromRGB(0xDB6283);
    [self.switch3 addTarget:self action:@selector(switcDidChange:) forControlEvents:UIControlEventValueChanged];
    [view3 addSubview:self.switch3];
    [self.switch3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-20 * scale);
        make.width.mas_equalTo(51 * scale);
        make.height.mas_equalTo(31 * scale);
    }];
    
    self.switchLabel3 = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [view3 addSubview:self.switchLabel3];
    [self.switchLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(self.switch3.mas_left).offset(-15 * scale);
        make.height.mas_equalTo(20 * scale);
    }];
    if (self.model.readWriteAuthorize == 1) {
        self.switch3.on = YES;
        self.switchLabel3.textColor = UIColorFromRGB(0xDB6283);
        self.switchLabel3.text = @"需审批";
    }else{
        self.switch3.on = NO;
        self.switchLabel3.textColor = UIColorFromRGB(0x999999);
        self.switchLabel3.text = @"不需审批";
    }
    
    UIView * lineView3 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView3.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [view3 addSubview:lineView3];
    [lineView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20 * scale);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(-20 * scale);
    }];
    
    UIView * view4 = [[UIView alloc] initWithFrame:CGRectZero];
    view4.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.headerView addSubview:view4];
    [view4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(view3.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(50 * scale);
    }];
    
    UILabel * titleLabel4 = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    titleLabel4.text = @"群状态";
    [view4 addSubview:titleLabel4];
    [titleLabel4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(20 * scale);
    }];
    
    self.switch4 = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.switch4.on = YES;
    self.switch4.onTintColor = UIColorFromRGB(0xDB6283);
    [self.switch4 addTarget:self action:@selector(switcDidChange:) forControlEvents:UIControlEventValueChanged];
    [view4 addSubview:self.switch4];
    [self.switch4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-20 * scale);
        make.width.mas_equalTo(51 * scale);
        make.height.mas_equalTo(31 * scale);
    }];
    
    self.switchLabel4 = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(14 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [view4 addSubview:self.switchLabel4];
    [self.switchLabel4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(self.switch4.mas_left).offset(-15 * scale);
        make.height.mas_equalTo(20 * scale);
    }];
    if (self.model.groupState == 1) {
        self.switch4.on = YES;
        self.switchLabel4.textColor = UIColorFromRGB(0xDB6283);
        self.switchLabel4.text = @"群在线";
    }else{
        self.switch4.on = NO;
        self.switchLabel4.textColor = UIColorFromRGB(0x999999);
        self.switchLabel4.text = @"群下线";
    }
    
    UIView * lineView4 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView4.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [view4 addSubview:lineView4];
    [lineView4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20 * scale);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(-20 * scale);
    }];
}

- (void)createFooterView
{
    CGFloat scale = kMainBoundsWidth / 360.f;
    
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 200 * scale)];
    self.footerView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    UILabel * detailLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(12 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    detailLabel.numberOfLines = 0;
    detailLabel.text = @"*公开群可被所有人检索到，无需加入即可浏览群内公开内容；私密群及群内内容只有群成员可见。\n*需审批状态在新群员加入时需要群主批准，不需审批则可以直接加入。\n*需审核状态下发帖或加入帖子均需群管理员审核，无需审核状态下的发帖和加入帖子无需审核，会自动展示。\n*群在线为正常状态，群下线后只有群主可以看见该群";
    [self.footerView addSubview:detailLabel];
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5 * scale);
        make.left.mas_equalTo(20 * scale);
        make.right.mas_equalTo(-20 * scale);
    }];
    
    UIButton * deleteButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(12 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"删除群"];
    [self.footerView addSubview:deleteButton];
    [deleteButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(detailLabel.mas_bottom).offset(12 * scale);
        make.left.mas_equalTo(20 * scale);
        make.height.mas_equalTo(20 * scale);
    }];
    [deleteButton addTarget:self action:@selector(deleteButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * yijiaoButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(12 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"移交群"];
    [self.footerView addSubview:yijiaoButton];
    [yijiaoButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(detailLabel.mas_bottom).offset(12 * scale);
        make.right.mas_equalTo(-20 * scale);
        make.height.mas_equalTo(20 * scale);
    }];
    [yijiaoButton addTarget:self action:@selector(yijiaoButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)listButtonDidClicked
{
    DDGroupPostListViewController * list = [[DDGroupPostListViewController alloc] initWithModel:self.model];
    [self.navigationController pushViewController:list animated:YES];
}

- (void)mapButtonDidClicked
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DDGroupDidChange" object:self.model];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)deleteButtonDidClicked
{
    RDAlertView * alertView = [[RDAlertView alloc] initWithTitle:@"删除" message:[NSString stringWithFormat:@"确定删除群“%@”吗？", self.model.groupName]];
    RDAlertAction * action1 = [[RDAlertAction alloc] initWithTitle:@"取消" handler:^{
        
    } bold:NO];
    RDAlertAction * action2 = [[RDAlertAction alloc] initWithTitle:@"确定" handler:^{
        
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在删除" inView:self.view];
        DDGroupRequest * request = [[DDGroupRequest alloc] initDeleteGroup:self.model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [MBProgressHUD showTextHUDWithText:@"删除成功" inView:[UIApplication sharedApplication].keyWindow];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(authorNeedUpdateGroupList)]) {
                [self.delegate authorNeedUpdateGroupList];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
            NSString * msg = [response objectForKey:@"msg"];
            if (isEmptyString(msg)) {
                msg = @"删除失败";
            }
            [MBProgressHUD showTextHUDWithText:msg inView:self.view];
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"删除失败" inView:self.view];
        }];
        
    } bold:NO];
    [alertView addActions:@[action1, action2]];
    [alertView show];
}

- (void)yijiaoButtonDidClicked
{
    DDGroupGiveViewController * give = [[DDGroupGiveViewController alloc] initWithModel:self.model];
    [self.navigationController pushViewController:give animated:YES];
}

- (void)editTitleButtonDidClicked
{
    self.editLabel = self.titleLabel;
    
    NSString * title = self.titleLabel.text;
    if ([title isEqualToString:@"暂无名称"]) {
        title = @"";
    }
    
    DTieEditTextViewController * text = [[DTieEditTextViewController alloc] initWithText:title placeholder:@"请输入群名称"];
    text.delegate = self;
    [self presentViewController:text animated:YES completion:nil];
}

- (void)editInfoButtonDidClicked
{
    self.editLabel = self.infoLabel;
    
    NSString * info = self.infoLabel.text;
    if ([info isEqualToString:@"暂无简介"]) {
        info = @"";
    }
    
    DTieEditTextViewController * text = [[DTieEditTextViewController alloc] initWithText:info placeholder:@"请输入群简介"];
    text.delegate = self;
    [self presentViewController:text animated:YES completion:nil];
}

- (void)DTEditTextDidFinished:(NSString *)text
{
    if (isEmptyString(text)) {
        return;
    }
    self.editLabel.text = text;
    [self updateGroup];
}

- (void)switcDidChange:(UISwitch *)sender
{
    if (sender == self.switch1) {
        
        if (sender.isOn) {
            self.switchLabel1.textColor = UIColorFromRGB(0xDB6283);
            self.switchLabel1.text = @"公开群";
        }else{
            self.switchLabel1.textColor = UIColorFromRGB(0x999999);
            self.switchLabel1.text = @"非公开群";
        }
        
    }else if (sender == self.switch2) {
        
        if (sender.isOn) {
            self.switchLabel2.textColor = UIColorFromRGB(0xDB6283);
            self.switchLabel2.text = @"需审批";
        }else{
            self.switchLabel2.textColor = UIColorFromRGB(0x999999);
            self.switchLabel2.text = @"不需审批";
        }
        
    }else if (sender == self.switch3) {
        
        if (sender.isOn) {
            self.switchLabel3.textColor = UIColorFromRGB(0xDB6283);
            self.switchLabel3.text = @"需审批";
        }else{
            self.switchLabel3.textColor = UIColorFromRGB(0x999999);
            self.switchLabel3.text = @"不需审批";
        }
        
    }else if (sender == self.switch4) {
        
        if (sender.isOn) {
            self.switchLabel4.textColor = UIColorFromRGB(0xDB6283);
            self.switchLabel4.text = @"群在线";
        }else{
            self.switchLabel4.textColor = UIColorFromRGB(0x999999);
            self.switchLabel4.text = @"群下线";
        }
        
    }
    [self updateGroup];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
