//
//  YueFanViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "YueFanViewController.h"
#import "DTieQuanXianViewController.h"
#import "SecurityGroupModel.h"
#import "DTieChooseLocationController.h"
#import <PGDatePickManager.h>
#import "DDTool.h"
#import "SelectFriendRequest.h"
#import "SecurityFriendController.h"
#import "MBProgressHUD+DDHUD.h"
#import "OnlyLogoCollectionViewCell.h"
#import "QNDDUploadManager.h"
#import "CreateDTieRequest.h"
#import "AddUserToWYYRequest.h"
#import "ChooseImageViewController.h"
#import "DTieDetailRequest.h"
#import "DTieNewDetailViewController.h"
#import "WeChatManager.h"
#import "DDLGSideViewController.h"
#import "DDBackWidow.h"

@interface YueFanViewController () <UICollectionViewDelegate, UICollectionViewDataSource, DTieQuanXianViewControllerDelegate, ChooseLocationDelegate, PGDatePickerDelegate, SecurityFriendDelegate>

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UIImageView * topImageView;

@property (nonatomic, strong) UILabel * locationLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UICollectionView * friendCollectionView;
@property (nonatomic, strong) UITextField * remarkTextField;

@property (nonatomic, strong) DTieQuanXianViewController * quanxian;
@property (nonatomic, strong) UILabel * quanxianLabel;
@property (nonatomic, assign) NSInteger landAccountFlg;

@property (nonatomic, strong) BMKPoiInfo * choosePOI;
@property (nonatomic, strong) NSMutableArray * selectSource;

@property (nonatomic, assign) NSInteger createTime;

@property (nonatomic, strong) NSMutableDictionary * dataDict;
@property (nonatomic, strong) NSArray * nameKeys;
@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, strong) NSMutableArray * selectFriend;

@property (nonatomic, strong) NSArray * startArray;

@end

@implementation YueFanViewController

- (instancetype)initWithBMKPoiInfo:(BMKPoiInfo *)poiInfo friendArray:(NSArray *)friendArray
{
    if (self = [super init]) {
        self.choosePOI = poiInfo;
        self.startArray = [NSArray arrayWithArray:friendArray];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.createTime = [[NSDate date] timeIntervalSince1970] * 1000;
    [self createViews];
    [self createTopView];
    [self requestFriendList];
}

- (void)requestFriendList
{
    [SelectFriendRequest cancelRequest];
    SelectFriendRequest * request = [[SelectFriendRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSArray * data = [response objectForKey:@"data"];
            if (KIsArray(data)) {
                for (NSInteger i = 0; i < data.count; i++) {
                    NSDictionary * dict = [data objectAtIndex:i];
                    UserModel * model = [UserModel mj_objectWithKeyValues:dict];
                    
                    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"userId == %d", model.cid];
                    NSArray * tempArray = [self.startArray filteredArrayUsingPredicate:predicate];
                    if (tempArray && tempArray.count > 0) {
                        [self.selectFriend addObject:model];
                    }
                    
                    [self.dataSource addObject:model];
                }
                [self sortFriends];
            }
        }
        [self.friendCollectionView reloadData];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)chooseFriend
{
    if (self.dataSource.count == 0) {
        [self requestFriendList];
    }
    SecurityFriendController * friend = [[SecurityFriendController alloc] initMulSelectWithDataDict:self.dataDict nameKeys:self.nameKeys selectModels:self.selectFriend];
    friend.delegate = self;
    [self.navigationController pushViewController:friend animated:YES];
}

- (void)friendDidMulSelectComplete:(NSArray *)selectArray
{
    [self.friendCollectionView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)timeViewDidTap
{
    PGDatePickManager *datePickManager = [[PGDatePickManager alloc]init];
    datePickManager.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
    datePickManager.confirmButtonTextColor = UIColorFromRGB(0xDB6283);
    
    PGDatePicker *datePicker = datePickManager.datePicker;
    
    datePicker.delegate = self;
    datePicker.datePickerMode = PGDatePickerModeDateHourMinute;
    datePicker.textColorOfSelectedRow = UIColorFromRGB(0xDB6283);
    datePicker.lineBackgroundColor = UIColorFromRGB(0xDB6283);
    datePicker.middleTextColor = UIColorFromRGB(0xDB6283);
    
    [self presentViewController:datePickManager animated:false completion:nil];
    [[DDBackWidow shareWindow] hidden];
}

- (void)datePicker:(PGDatePicker *)datePicker didSelectDate:(NSDateComponents *)dateComponents {
    
    NSDate * date = [NSDate setYear:dateComponents.year month:dateComponents.month day:dateComponents.day hour:dateComponents.hour minute:dateComponents.minute];
    self.createTime = [date timeIntervalSince1970] * 1000;
    NSString * str = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.createTime];
    self.timeLabel.text = str;
}

- (void)chooseLocation
{
    DTieChooseLocationController * chosse = [[DTieChooseLocationController alloc] init];
    if (self.choosePOI) {
        chosse.startPoi = self.choosePOI;
    }
    chosse.delegate = self;
    [self.navigationController pushViewController:chosse animated:YES];
}

- (void)chooseLocationDidChoose:(BMKPoiInfo *)poi
{
    self.choosePOI = poi;
    self.locationLabel.text = [NSString stringWithFormat:@"%@", poi.address];
}

- (void)quanxianButtonDidClicked
{
    [self.navigationController presentViewController:self.quanxian animated:YES completion:nil];
    [[DDBackWidow shareWindow] hidden];
}

- (void)DTieQuanxianDidCompleteWith:(NSArray *)source landAccountFlg:(NSInteger)landAccountFlg
{
    self.selectSource = [[NSMutableArray alloc] initWithArray:source];
    self.landAccountFlg = landAccountFlg;
    
    NSString * title = @"";
    if (landAccountFlg == 1) {
        title = @"公开";
    }else if (landAccountFlg == 2) {
        title = @"私密";
    }else{
        if (source.count == 0) {
            title = @"私密";
        }else{
            for (SecurityGroupModel * model in source) {
                title = [NSString stringWithFormat:@"%@,%@", title, model.securitygroupName];
            }
            if (title.length > 2) {
                title = [title substringFromIndex:1];
            }
        }
    }
    self.quanxianLabel.text = title;
}

- (void)chooseImage
{
    ChooseImageViewController * chooseImage = [[ChooseImageViewController alloc] initWithImage:self.topImageView.image];
    
    __weak typeof(self) weakSelf = self;
    chooseImage.chooseImageHandle = ^(UIImage *image) {
        weakSelf.topImageView.image = image;
    };
    [self.navigationController pushViewController:chooseImage animated:YES];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 1360 * scale)];
    baseView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    self.topImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [baseView addSubview:self.topImageView];
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(self.topImageView.mas_width).multipliedBy(480.f/1080.f);
    }];
    [self.topImageView setImage:[UIImage imageNamed:@"default1.jpg"]];
    self.topImageView.clipsToBounds = YES;
    UITapGestureRecognizer * imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseImage)];
    self.topImageView.userInteractionEnabled = YES;
    [self.topImageView addGestureRecognizer:imageTap];
    
    UIView * locationView = [[UIView alloc] initWithFrame:CGRectZero];
    [baseView addSubview:locationView];
    [locationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topImageView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(147 * scale);
    }];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseLocation)];
    [locationView addGestureRecognizer:tap];
    
    UIView * locationLineView = [[UIView alloc] initWithFrame:CGRectZero];
    locationLineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [locationView addSubview:locationLineView];
    [locationLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(3 * scale);
    }];
    
    UILabel * locationTitleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    locationTitleLabel.text = @"相约地址：";
    [locationView addSubview:locationTitleLabel];
    [locationTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(56 * scale);
        make.width.mas_equalTo(180 * scale);
    }];
    
    self.locationLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    self.locationLabel.text = @"请选择要约的地址";
    [locationView addSubview:self.locationLabel];
    [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.centerY.mas_equalTo(locationTitleLabel);
        make.left.mas_equalTo(locationTitleLabel.mas_right).offset(12 * scale);
        make.right.mas_equalTo(-180 * scale);
    }];
    if (self.choosePOI) {
        self.locationLabel.text = self.choosePOI.address;
    }
    
    UIImageView * locationImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"locationEdit"]];
    [locationView addSubview:locationImageView];
    [locationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
        make.width.height.mas_equalTo(72 * scale);
    }];
    
    UIView * timeView = [[UIView alloc] initWithFrame:CGRectZero];
    [baseView addSubview:timeView];
    [timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(locationView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    UITapGestureRecognizer * timeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeViewDidTap)];
    [timeView addGestureRecognizer:timeTap];
    
    UILabel * timeTitleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    timeTitleLabel.text = @"相约时间：";
    [timeView addSubview:timeTitleLabel];
    [timeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(56 * scale);
    }];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    self.timeLabel.text = @"请选择要约的时间";
    [timeView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.centerY.mas_equalTo(timeTitleLabel);
        make.left.mas_equalTo(timeTitleLabel.mas_right).offset(12 * scale);
        make.right.mas_equalTo(-180 * scale);
    }];
    
    NSString * str = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.createTime];
    self.timeLabel.text = str;
    
    UIImageView * timeImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"timeEdit"]];
    [timeView addSubview:timeImageView];
    [timeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
        make.width.height.mas_equalTo(72 * scale);
    }];
    
    UIView * timeLineView = [[UIView alloc] initWithFrame:CGRectZero];
    timeLineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [baseView addSubview:timeLineView];
    [timeLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(timeView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(24 * scale);
    }];
    
    UIView * friendView = [[UIView alloc] initWithFrame:CGRectZero];
    [baseView addSubview:friendView];
    [friendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(timeLineView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    UITapGestureRecognizer * friendTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseFriend)];
    [friendView addGestureRecognizer:friendTap];
    
    UILabel * friendTitleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    friendTitleLabel.text = @"邀请好友：";
    [friendView addSubview:friendTitleLabel];
    [friendTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(56 * scale);
    }];
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(96 * scale, 96 * scale);
    layout.minimumLineSpacing = 24 * scale;
    layout.minimumInteritemSpacing = 24 * scale;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    self.friendCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.friendCollectionView registerClass:[OnlyLogoCollectionViewCell class] forCellWithReuseIdentifier:@"OnlyLogoCollectionViewCell"];
    self.friendCollectionView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.friendCollectionView.delegate = self;
    self.friendCollectionView.dataSource = self;
    self.friendCollectionView.scrollEnabled = NO;
    [friendView addSubview:self.friendCollectionView];
    [self.friendCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(96 * scale);
        make.left.mas_equalTo(friendTitleLabel.mas_right).offset(12 * scale);
        make.right.mas_equalTo(-180 * scale);
    }];
    
    UIImageView * friendImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"friendEdit"]];
    [friendView addSubview:friendImageView];
    [friendImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
        make.width.height.mas_equalTo(72 * scale);
    }];
    
    UIView * friendLineView = [[UIView alloc] initWithFrame:CGRectZero];
    friendLineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [baseView addSubview:friendLineView];
    [friendLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(friendView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(3 * scale);
    }];
    
    UIView * remarkView = [[UIView alloc] initWithFrame:CGRectZero];
    [baseView addSubview:remarkView];
    [remarkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(friendLineView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    
    UILabel * ramerkTitleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    ramerkTitleLabel.text = @"备      注：";
    [remarkView addSubview:ramerkTitleLabel];
    [ramerkTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(56 * scale);
    }];
    
    self.remarkTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.remarkTextField.placeholder = @"人均消费情况或聚会主题等……";
    self.remarkTextField.font = kPingFangRegular(36 * scale);
    self.remarkTextField.textColor = UIColorFromRGB(0x999999);
    [remarkView addSubview:self.remarkTextField];
    [self.remarkTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ramerkTitleLabel.mas_right).offset(12 * scale);
        make.top.bottom.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
    }];
    
    UIView * remarkLineView = [[UIView alloc] initWithFrame:CGRectZero];
    remarkLineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [baseView addSubview:remarkLineView];
    [remarkLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(remarkView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(3 * scale);
    }];
    
    UIView * quanxianView = [[UIView alloc] initWithFrame:CGRectZero];
    [baseView addSubview:quanxianView];
    [quanxianView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(remarkLineView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    UITapGestureRecognizer * quanxianTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(quanxianButtonDidClicked)];
    [quanxianView addGestureRecognizer:quanxianTap];
    
    UILabel * quanxianTitleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    quanxianTitleLabel.text = @"浏览权限";
    [quanxianView addSubview:quanxianTitleLabel];
    [quanxianTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(56 * scale);
    }];
    
    self.quanxianLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentRight];
    self.quanxianLabel.text = @"公开";
    [quanxianView addSubview:self.quanxianLabel];
    [self.quanxianLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(quanxianTitleLabel.mas_right).offset(12 * scale);
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
        make.height.mas_equalTo(144 * scale);
    }];
    self.landAccountFlg = 1;
    
    UIView * tipView = [[UIView alloc] initWithFrame:CGRectZero];
    tipView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [baseView addSubview:tipView];
    [tipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(quanxianView.mas_bottom);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    UIImageView * tipImageview = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"alertEdit"]];
    [tipView addSubview:tipImageview];
    [tipImageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.centerY.mas_equalTo(0);
        make.width.height.mas_equalTo(72 * scale);
    }];
    
    UILabel * tipLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(35 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    tipLabel.text = @"标记约这可以让您的DeeDao直接好友知道您的兴趣。";
    [tipView addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tipImageview.mas_right).offset(20 * scale);
        make.right.mas_equalTo(-60 * scale);
        make.top.bottom.mas_equalTo(0);
    }];
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    tableView.rowHeight = 150 * scale;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 324 * scale, 0);
    
    tableView.tableHeaderView = baseView;
    tableView.tableFooterView = [UIView new];
    
    UIButton * leftHandleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) backgroundColor:UIColorFromRGB(0xFFFFFF) title:@"标记约这"];
    [DDViewFactoryTool cornerRadius:24 * scale withView:leftHandleButton];
    leftHandleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    leftHandleButton.layer.borderWidth = 3 * scale;
    [self.view addSubview:leftHandleButton];
    [leftHandleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.width.mas_equalTo(444 * scale);
        make.height.mas_equalTo(144 * scale);
        make.bottom.mas_equalTo(-90 * scale);
    }];
    
    UIButton * rightHandleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) backgroundColor:UIColorFromRGB(0xDB6283) title:@"直接约起来"];
    [DDViewFactoryTool cornerRadius:24 * scale withView:rightHandleButton];
    [self.view addSubview:rightHandleButton];
    [rightHandleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.width.mas_equalTo(444 * scale);
        make.height.mas_equalTo(144 * scale);
        make.bottom.mas_equalTo(-90 * scale);
    }];
    
    [leftHandleButton addTarget:self action:@selector(leftButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [rightHandleButton addTarget:self action:@selector(rightButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)leftButtonDidClicked
{
    [self createPostWithShare:NO];
}

- (void)rightButtonDidClicked
{
    [self createPostWithShare:YES];
}

- (void)createPostWithShare:(BOOL)share
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:self.view];
    
    if (nil == self.choosePOI) {
        [MBProgressHUD showTextHUDWithText:@"请选择要约地点" inView:self.view];
        return;
    }
    
    //获取参数配置
    NSString * address = self.choosePOI.address;
    
    NSString * building = self.choosePOI.name;
    if (isEmptyString(building)) {
        building = address;
    }
    
    double lon = self.choosePOI.pt.longitude;
    double lat = self.choosePOI.pt.latitude;
    
    NSInteger landAccountFlg = self.landAccountFlg;
    
    NSMutableArray * allowToSeeList = [[NSMutableArray alloc] init];
    if (landAccountFlg == 4) {
        
        for (SecurityGroupModel * groupModel in self.selectSource) {
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
                NSInteger remindFlg = 0;
                if (groupModel.isNotification) {
                    remindFlg = 1;
                }
                [allowToSeeList addObject:@{@"securityGroupId":@(groupModel.cid), @"remindFlg":@(remindFlg)}];
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
        }
    }
    
    NSMutableArray * userList = [[NSMutableArray alloc] init];
    for (UserModel * model in self.selectFriend) {
        [userList addObject:@(model.cid)];
    }
    
    NSString * title = building;
    if (isEmptyString(title)) {
        title = @"";
    }
    
    UIImage * firstImage = self.topImageView.image;
    QNDDUploadManager * manager = [[QNDDUploadManager alloc] init];
    [manager uploadImage:firstImage progress:^(NSString *key, float percent) {
        
    } success:^(NSString *url) {
        
        NSString * firstPic = url;
        
        NSMutableArray * details = [NSMutableArray new];
        
        NSDictionary * dict = @{@"detailNumber":@"1",
                                @"datadictionaryType":@"CONTENT_IMG",
                                @"detailsContent":url,
                                @"textInformation":@"",
                                @"pFlag":@(0),
                                @"wxCansee":@(1)};
        [details addObject:dict];
        
        if (!isEmptyString(self.remarkTextField.text)) {
            NSDictionary * remarkDict = @{@"detailNumber":@"2",
                                    @"datadictionaryType":@"CONTENT_TEXT",
                                    @"detailsContent":self.remarkTextField.text,
                                    @"textInformation":@"",
                                    @"pFlag":@(0),
                                    @"wxCansee":@(1)};
            [details addObject:remarkDict];
        }
        
        CreateDTieRequest * request = [[CreateDTieRequest alloc] initWithList:details title:building address:address building:building addressLng:lon addressLat:lat status:1 remindFlg:1 firstPic:firstPic postID:0 landAccountFlg:landAccountFlg allowToSeeList:allowToSeeList sceneTime:[DDTool getTimeCurrentWithDouble]];
        [request configRemark:@"WYY"];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            [hud hideAnimated:YES];
            if (KIsDictionary(response)) {
                NSDictionary * data = [response objectForKey:@"data"];
                if (KIsDictionary(data)) {
                    //                    [MBProgressHUD showTextHUDWithText:@"操作成功" inView:self.view];
                    DTieModel * DTie = [DTieModel mj_objectWithKeyValues:data];
                    
                    NSInteger newPostID = DTie.cid;
                    if (newPostID == 0) {
                        newPostID = DTie.postId;
                    }
                    
                    AddUserToWYYRequest * request = [[AddUserToWYYRequest alloc] initWithUserList:userList postId:newPostID];
                    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                        
                    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                        
                    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
                        
                    }];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    if (share) {
                        [self checkShareWithPostId:newPostID share:YES];
                    }
                    
                }
            }
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"操作失败" inView:self.view];
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:@"操作失败" inView:self.view];
        }];
        
    } failed:^(NSError *error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"操作失败" inView:self.view];
    }];
}

- (void)checkShareWithPostId:(NSInteger)postId share:(BOOL)sharenable;
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:[UIApplication sharedApplication].keyWindow];
    
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:postId type:4 start:0 length:10];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                
                if (dtieModel.deleteFlg == 1) {
                    [MBProgressHUD showTextHUDWithText:@"该帖已被作者删除~" inView:self.view];
                    return;
                }
                DTieNewDetailViewController * detail = [[DTieNewDetailViewController alloc] initWithDTie:dtieModel];
                DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                UINavigationController * na = (UINavigationController *)lg.rootViewController;
                
                [na pushViewController:detail animated:YES];
                
                if (sharenable) {
                    [detail showShareWithCreatePost];
                }
            }
        }
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.selectFriend.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OnlyLogoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OnlyLogoCollectionViewCell" forIndexPath:indexPath];
    
    UserModel * model = [self.selectFriend objectAtIndex:indexPath.row];
    [cell configWithUserModel:model];
    
    return cell;
}

- (void)createTopView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.topView = [[UIView alloc] init];
    self.topView.userInteractionEnabled = YES;
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo((220 + kStatusBarHeight) * scale);
    }];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth, (220 + kStatusBarHeight) * scale);
    [self.topView.layer addSublayer:gradientLayer];
    
    self.topView.layer.shadowColor = UIColorFromRGB(0xB721FF).CGColor;
    self.topView.layer.shadowOpacity = .24;
    self.topView.layer.shadowOffset = CGSizeMake(0, 4);
    
    UIButton * backButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(10) titleColor:[UIColor whiteColor] title:@""];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.bottom.mas_equalTo(-15 * scale);
        make.width.height.mas_equalTo(100 * scale);
    }];
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentLeft];
    titleLabel.text = @"约这";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
    UIButton * cancleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] title:@"取消约这"];
    [DDViewFactoryTool cornerRadius:12 * scale withView:cancleButton];
    cancleButton.layer.borderWidth = .5f;
    cancleButton.layer.borderColor = UIColorFromRGB(0xFFFFFF).CGColor;
    [cancleButton addTarget:self action:@selector(cancleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:cancleButton];
    [cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(192 * scale);
        make.height.mas_equalTo(72 * scale);
        make.centerY.mas_equalTo(titleLabel);
        make.right.mas_equalTo(-60 * scale);
    }];
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancleButtonDidClicked
{
    [self backButtonDidClicked];
}

- (DTieQuanXianViewController *)quanxian
{
    if (!_quanxian) {
        _quanxian = [[DTieQuanXianViewController alloc] init];
        _quanxian.delegate = self;
    }
    return _quanxian;
}

- (NSMutableDictionary *)dataDict
{
    if (!_dataDict) {
        _dataDict = [[NSMutableDictionary alloc] init];
    }
    return _dataDict;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (NSMutableArray *)selectFriend
{
    if (!_selectFriend) {
        _selectFriend = [[NSMutableArray alloc] init];
    }
    return _selectFriend;
}

- (void)sortFriends
{
    // 将耗时操作放到子线程
    dispatch_queue_t queue = dispatch_queue_create("DDFriends.infoDict", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        
        for (UserModel * model in self.dataSource) {
            // 获取并返回首字母
            NSString * firstLetterString =model.firstLetter;
            
            if (isEmptyString(firstLetterString)) {
                continue;
            }
            
            //如果该字母对应的联系人模型不为空,则将此联系人模型添加到此数组中
            if (self.dataDict[firstLetterString])
            {
                [self.dataDict[firstLetterString] addObject:model];
            }
            //没有出现过该首字母，则在字典中新增一组key-value
            else
            {
                //创建新发可变数组存储该首字母对应的联系人模型
                NSMutableArray *arrGroupNames = [[NSMutableArray alloc] init];
                
                [arrGroupNames addObject:model];
                //将首字母-姓名数组作为key-value加入到字典中
                [self.dataDict setObject:arrGroupNames forKey:firstLetterString];
            }
        }
        
        // 将addressBookDict字典中的所有Key值进行排序: A~Z
        NSArray *nameKeys = [[self.dataDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
        self.nameKeys = [[NSArray alloc] initWithArray:nameKeys];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
        
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[DDBackWidow shareWindow] show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
