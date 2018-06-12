//
//  DTieDetailViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/17.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieDetailViewController.h"
#import "DTieDetailTextTableViewCell.h"
#import "DTieDetailImageTableViewCell.h"
#import "DTieDetailVideoTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "DDTool.h"
#import "DDHandleView.h"
#import "DDTool.h"
#import "DTieCollectionRequest.h"
#import "DTieCancleCollectRequest.h"
#import "DTieCancleWYYRequest.h"
#import "LiuYanViewController.h"
#import "UserInfoViewController.h"
#import <AVKit/AVKit.h>
#import "DDShareManager.h"
#import "DDLocationManager.h"
#import "UserManager.h"
#import "MBProgressHUD+DDHUD.h"

@interface DTieDetailViewController () <UITableViewDelegate, UITableViewDataSource, DDHandleViewDelegate>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, strong) DDHandleView * handleView;

@property (nonatomic, strong) NSString * firstPicURL;

@end

@implementation DTieDetailViewController

- (instancetype)initWithDTie:(DTieModel *)model
{
    if (self = [super init]) {
        self.model = model;
        self.dataSource = [[NSMutableArray alloc] initWithArray:self.model.details];
        
        if (self.model.postFirstPicture) {
            self.firstPicURL = self.model.postFirstPicture;
        }else{
            for (DTieEditModel * tempModel in self.model.details) {
                if (tempModel.type == DTieEditType_Image) {
                    self.firstPicURL = tempModel.detailContent;
                }
            }
        }
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
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[DTieDetailTextTableViewCell class] forCellReuseIdentifier:@"DTieDetailTextTableViewCell"];
    [self.tableView registerClass:[DTieDetailImageTableViewCell class] forCellReuseIdentifier:@"DTieDetailImageTableViewCell"];
    [self.tableView registerClass:[DTieDetailVideoTableViewCell class] forCellReuseIdentifier:@"DTieDetailVideoTableViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    [self createHeaderView];
    [self createFooterView];
    
    [self createHandleView];
    [self createTopView];
    
    [self reloadHandleView];
}

#pragma mark - 用户主要交互事件
- (void)handleViewDidClickedYaoyue
{
    if (self.model.authorId == [UserManager shareManager].user.cid) {
        [MBProgressHUD showTextHUDWithText:@"无法对自己的帖子进行该操作" inView:self.view];
        return;
    }
    
    self.handleView.yaoyueButton.enabled = NO;
    if (self.model.wyyFlg) {
        
        DTieCancleWYYRequest * request = [[DTieCancleWYYRequest alloc] initWithPostID:self.model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            self.model.wyyFlg = 0;
            self.model.wyyCount--;
            [self reloadHandleView];
            
            self.handleView.yaoyueButton.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.handleView.yaoyueButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.handleView.yaoyueButton.enabled = YES;
        }];
        
    }else{
        DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:self.model.cid type:1 subType:0 remark:@""];
        
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            self.model.wyyFlg = 1;
            self.model.wyyCount++;
            [self reloadHandleView];
            
            self.handleView.yaoyueButton.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.handleView.yaoyueButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.handleView.yaoyueButton.enabled = YES;
        }];
    }
}

- (void)handleViewDidClickedShoucang
{
    if (self.model.authorId == [UserManager shareManager].user.cid) {
        [MBProgressHUD showTextHUDWithText:@"无法对自己的帖子进行该操作" inView:self.view];
        return;
    }
    
    self.handleView.shoucangButton.enabled = NO;
    if (self.model.collectFlg) {
        
        DTieCancleCollectRequest * request = [[DTieCancleCollectRequest alloc] initWithPostID:self.model.postId];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            self.model.collectFlg = 0;
            self.model.collectCount--;
            [self reloadHandleView];
            
            self.handleView.shoucangButton.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.handleView.shoucangButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.handleView.shoucangButton.enabled = YES;
        }];
        
    }else{
        DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:self.model.postId type:0 subType:0 remark:@""];
        
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            self.model.collectFlg = 1;
            self.model.collectCount++;
            [self reloadHandleView];
            
            self.handleView.shoucangButton.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            self.handleView.shoucangButton.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            self.handleView.shoucangButton.enabled = YES;
        }];
    }
}

- (void)handleViewDidClickedDazhaohu
{
    if (self.model.authorId == [UserManager shareManager].user.cid) {
        [MBProgressHUD showTextHUDWithText:@"无法对自己的帖子进行该操作" inView:self.view];
        return;
    }
    
    self.handleView.dazhaohuButton.enabled = NO;
    
    DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:self.model.cid type:0 subType:1 remark:@""];
    
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        self.model.dzfFlg = 1;
        self.model.dzfCount++;
        [self reloadHandleView];
        
        self.handleView.shoucangButton.enabled = YES;
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        self.handleView.shoucangButton.enabled = YES;
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        self.handleView.shoucangButton.enabled = YES;
    }];
}

- (void)liuyanButtonDidClicked
{
    LiuYanViewController * liuyan = [[LiuYanViewController alloc] initWithPostID:self.model.cid commentId:self.model.authorId];
    [self.navigationController pushViewController:liuyan animated:YES];
}

- (void)reloadHandleView
{
    NSString * wyy = @"99+";
    if (self.model.wyyCount < 100) {
        wyy = [NSString stringWithFormat:@"%ld", self.model.wyyCount];
    }
    [self.handleView.yaoyueButton configTitle:wyy];
    
    NSString * shoucang = @"99+";
    if (self.model.collectCount < 100) {
        shoucang = [NSString stringWithFormat:@"%ld", self.model.collectCount];
    }
    [self.handleView.shoucangButton configTitle:shoucang];
    
    NSString * dazhoahu = @"99+";
    if (self.model.dzfCount < 100) {
        dazhoahu = [NSString stringWithFormat:@"%ld", self.model.dzfCount];
    }
    [self.handleView.dazhaohuButton configTitle:dazhoahu];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTieEditModel * model = [self.dataSource objectAtIndex:indexPath.row];
    if (model.type == DTieEditType_Text) {
        
        DTieDetailTextTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieDetailTextTableViewCell" forIndexPath:indexPath];
        [cell configWithModel:model];
        return cell;
        
    }else if (model.type == DTieEditType_Image){
        
        DTieDetailImageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieDetailImageTableViewCell" forIndexPath:indexPath];
        [cell configWithModel:model];
        return cell;
    }else if (model.type == DTieEditType_Video){
        
        DTieDetailVideoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieDetailVideoTableViewCell" forIndexPath:indexPath];
        [cell configWithModel:model];
        return cell;
    }
    return [tableView dequeueReusableCellWithIdentifier:@"DTieDetailTextTableViewCell" forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTieEditModel * model = [self.dataSource objectAtIndex:indexPath.row];
    if (!isEmptyString(model.textInformation)) {
        AVPlayerViewController * playView = [[AVPlayerViewController alloc] init];
        playView = [[AVPlayerViewController alloc] init];
        playView.player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:model.textInformation]];
        playView.videoGravity = AVLayerVideoGravityResizeAspect;
        [self presentViewController:playView animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTieEditModel * model = [self.dataSource objectAtIndex:indexPath.row];
    if (model.type == DTieEditType_Image) {
        
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:model.detailContent];

        // 没有找到已下载的图片就使用默认的占位图，当然高度也是默认的高度了，除了高度不固定的文字部分。
        if (!image) {
            image = [UIImage imageNamed:@"test"];

            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:model.detailContent] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {

            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                [[SDImageCache sharedImageCache] storeImage:image forKey:model.detailContent toDisk:YES completion:nil];
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
            }];
        }
        
//        手动计算cell
        CGFloat imgHeight = image.size.height * kMainBoundsWidth / image.size.width;
        return imgHeight;
        
    }else if(model.type == DTieEditType_Video){
        return  kMainBoundsWidth / 16.f * 9.f;
    }
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    return 500 * scale;
}

- (void)createHeaderView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    CGFloat height = 0.f;
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 385 * scale)];
    headerView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    if (self.firstPicURL) {
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.firstPicURL];
        
        // 没有找到已下载的图片就使用默认的占位图，当然高度也是默认的高度了，除了高度不固定的文字部分。
        if (!image) {
            image = [UIImage imageNamed:@"test"];
            
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:self.firstPicURL] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                [[SDImageCache sharedImageCache] storeImage:image forKey:self.firstPicURL toDisk:YES completion:nil];
                [self createHeaderView];
            }];
        }
        
        [imageView setImage:image];
        //        手动计算cell
        CGFloat imgHeight = image.size.height * kMainBoundsWidth / image.size.width;
        height += imgHeight;
    }else{
        UIImage * image = [UIImage imageNamed:@"test"];
        [imageView setImage:image];
        CGFloat imgHeight = image.size.height * kMainBoundsWidth / image.size.width;
        height += imgHeight;
    }
    [headerView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(height);
    }];
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDidHandle:)];
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer:longPress];
    
    UIImageView * headerBGView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"headerBG"]];
    [headerView addSubview:headerBGView];
    [headerBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).offset(40 * scale);
        make.left.mas_equalTo(50 * scale);
        make.width.height.mas_equalTo(116 * scale);
    }];
    
    UIImageView * logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [logoImageView sd_setImageWithURL:[NSURL URLWithString:self.model.portraituri]];
    [headerView addSubview:logoImageView];
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).offset(50 * scale);
        make.left.mas_equalTo(60 * scale);
        make.width.height.mas_equalTo(96 * scale);
    }];
    [DDViewFactoryTool cornerRadius:48 * scale withView:logoImageView];
    UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookUserInfo)];
    logoImageView.userInteractionEnabled = YES;
    [logoImageView addGestureRecognizer:tap1];
    
    UILabel * nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentLeft];
    nameLabel.text = self.model.nickname;
    [headerView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(logoImageView);
        make.left.mas_equalTo(180 * scale);
        make.width.mas_equalTo(kMainBoundsWidth - 240 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookUserInfo)];
    nameLabel.userInteractionEnabled = YES;
    [nameLabel addGestureRecognizer:tap2];
    
    UILabel * detailLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    detailLabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日" time:self.model.sceneTime];
    [headerView addSubview:detailLabel];
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(nameLabel.mas_bottom).offset(15 * scale);;
        make.left.mas_equalTo(180 * scale);
        make.width.mas_equalTo(kMainBoundsWidth - 240 * scale);
        make.height.mas_equalTo(40* scale);
    }];
    UITapGestureRecognizer * tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookUserInfo)];
    detailLabel.userInteractionEnabled = YES;
    [detailLabel addGestureRecognizer:tap3];
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(54 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentLeft];
    titleLabel.text = self.model.postSummary;
    [headerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(logoImageView.mas_bottom).offset(48 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(58 * scale);
        make.width.mas_equalTo(kMainBoundsWidth - 120 * scale);
    }];
    
    UILabel * timeLocationLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    timeLocationLabel.numberOfLines = 0;
    timeLocationLabel.text = [NSString stringWithFormat:@"%@\n%@", [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.model.sceneTime], self.model.sceneAddress];
    [headerView addSubview:timeLocationLabel];
    [timeLocationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(20 * scale);
        make.left.mas_equalTo(60 * scale);
        make.width.mas_equalTo(kMainBoundsWidth - 200 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    
    UIImageView * locationImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"location"]];
    [headerView addSubview:locationImageView];
    [locationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(timeLocationLabel);
        make.right.mas_equalTo(-76 * scale);
        make.width.height.mas_equalTo(70 * scale);
    }];
    
    height += 385 * scale;
    headerView.frame = CGRectMake(0, 0, kMainBoundsWidth, height);
    
    self.tableView.tableHeaderView = headerView;
}

- (void)longPressDidHandle:(UILongPressGestureRecognizer *)longPress
{
    UIImageView * imageView = (UIImageView *)longPress.view;
    if ([imageView isKindOfClass:[UIImageView class]]) {
        ShareImageModel * model = [[ShareImageModel alloc] init];
        NSInteger postId = self.model.cid;
        if (postId == 0) {
            postId = self.model.postId;
        }
        model.postId = postId;
        model.image = imageView.image;
        model.title = self.model.postSummary;
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"pFlag == %d", 1];
        NSArray * tempArray = [self.model.details filteredArrayUsingPredicate:predicate];
        if (tempArray && tempArray.count > 0) {
            model.pflg = 1;
        }
        [[DDShareManager shareManager] showHandleViewWithImage:model];
    }
}

- (void)lookUserInfo
{
    UserInfoViewController * info = [[UserInfoViewController alloc] initWithUserId:self.model.authorId];
    [self.navigationController pushViewController:info animated:YES];
}

- (void)createFooterView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 720 * scale)];
    footerView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    UILabel * lastUpdateLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x3F3F3F) alignment:NSTextAlignmentLeft];
    [footerView addSubview:lastUpdateLabel];
    [lastUpdateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(48 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
    lastUpdateLabel.text = [NSString stringWithFormat:@"最后更新时间：%@", [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.model.updateTime]];
    
    UIView * line1 = [[UIView alloc] initWithFrame:CGRectZero];
    line1.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.4f];
    [footerView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lastUpdateLabel.mas_bottom).offset(46 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(3 * scale);
        make.width.mas_equalTo(kMainBoundsWidth - 120 * scale);
    }];
    
    UIButton * addSeriButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"将当前D帖加入已有系列或新建系列中"];
    [footerView addSubview:addSeriButton];
    [addSeriButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(line1.mas_bottom);
        make.left.mas_equalTo(60 * scale);
        make.width.mas_equalTo(kMainBoundsWidth - 120 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    
    UIView * line2 = [[UIView alloc] initWithFrame:CGRectZero];
    line2.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.4f];
    [footerView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(addSeriButton.mas_bottom);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(3 * scale);
        make.width.mas_equalTo(kMainBoundsWidth - 120 * scale);
    }];
    
    DDHandleButton * jubaoButton = [DDHandleButton buttonWithType:UIButtonTypeCustom];
    [jubaoButton configImage:[UIImage imageNamed:@"jubao"]];
    [jubaoButton configTitle:@"举报"];
    [footerView addSubview:jubaoButton];
    [jubaoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(line2.mas_bottom).offset(50 * scale);
        make.left.mas_equalTo(60 * scale);
        make.width.height.mas_equalTo(96 * scale);
    }];
    
    DDHandleButton * pinglunButton = [DDHandleButton buttonWithType:UIButtonTypeCustom];
    [pinglunButton addTarget:self action:@selector(liuyanButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [pinglunButton configImage:[UIImage imageNamed:@"liuyan"]];
    [pinglunButton configTitle:@"96"];
    [footerView addSubview:pinglunButton];
    [pinglunButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(line2.mas_bottom).offset(50 * scale);
        make.left.mas_equalTo(jubaoButton.mas_right).offset(24 * scale);
        make.width.height.mas_equalTo(96 * scale);
    }];
    
    for (NSInteger i = 2; i > -1; i--) {
        UIImageView * imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
        imageView.tag = i + 1;
        if (i % 3  == 1) {
            imageView.backgroundColor = UIColorFromRGB(0xDB6283);
        }else{
            imageView.backgroundColor = UIColorFromRGB(0XB721FF);
        }
        [footerView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo((492 + 52 * i) * scale);
            make.centerY.mas_equalTo(jubaoButton);
            make.width.height.mas_equalTo(96 * scale);
        }];
        [DDViewFactoryTool cornerRadius:48 * scale withView:imageView];
    }
    
    UIButton * thankButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"感 谢"];
    [DDViewFactoryTool cornerRadius:6 * scale withView:thankButton];
    [footerView addSubview:thankButton];
    [thankButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.centerY.mas_equalTo(jubaoButton);
        make.width.mas_equalTo(288 * scale);
        make.height.mas_equalTo(96 * scale);
    }];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, 288 * scale, 96 * scale);
    [thankButton.layer insertSublayer:gradientLayer atIndex:0];
    
    UIButton * messageButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0XDB6283) title:@"查看留言"];
    [DDViewFactoryTool cornerRadius:24 * scale withView:messageButton];
    [messageButton addTarget:self action:@selector(liuyanButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    messageButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    messageButton.layer.borderWidth = 3 * scale;
    [footerView addSubview:messageButton];
    [messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(48 * scale);
        make.bottom.mas_equalTo(-80 * scale);
        make.width.mas_equalTo(kMainBoundsWidth - 96 * scale);
        make.height.mas_equalTo(144 * scale);
    }];
    
    self.tableView.tableFooterView = footerView;
}

- (void)createHandleView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.handleView = [[DDHandleView alloc] init];
    self.handleView.delegate = self;
    [self.view addSubview:self.handleView];
    [self.handleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(192 * scale);
    }];
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
    titleLabel.text = self.model.postSummary;
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
    
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
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
