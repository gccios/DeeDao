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

@interface DTieDetailViewController () <UITableViewDelegate, UITableViewDataSource>

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTieEditModel * model = [self.dataSource objectAtIndex:indexPath.row];
    if (model.type == DTieEditType_Image || model.type == DTieEditType_Video) {
        
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
    
    UIImageView * logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [logoImageView sd_setImageWithURL:[NSURL URLWithString:self.model.portraituri]];
    [headerView addSubview:logoImageView];
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).offset(50 * scale);
        make.left.mas_equalTo(60 * scale);
        make.width.height.mas_equalTo(96 * scale);
    }];
    
    UILabel * nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentLeft];
    nameLabel.text = self.model.nickname;
    [headerView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(logoImageView);
        make.left.mas_equalTo(180 * scale);
        make.width.mas_equalTo(kMainBoundsWidth - 240 * scale);
        make.height.mas_equalTo(45 * scale);
    }];
    
    UILabel * detailLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0x999999) alignment:NSTextAlignmentLeft];
    detailLabel.text = [DDTool getTimeWithFormat:@"yyyy-MM-dd" time:self.model.createTime];
    [headerView addSubview:detailLabel];
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(nameLabel.mas_bottom).offset(15 * scale);;
        make.left.mas_equalTo(180 * scale);
        make.width.mas_equalTo(kMainBoundsWidth - 240 * scale);
        make.height.mas_equalTo(40* scale);
    }];
    
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
    timeLocationLabel.text = [NSString stringWithFormat:@"%@\n%@", [DDTool getTimeWithFormat:@"yyyy-MM-dd HH:mm" time:self.model.createTime], self.model.sceneAddress];
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
    lastUpdateLabel.text = [NSString stringWithFormat:@"最后更新时间：%@", [DDTool getTimeWithFormat:@"yyyy-MM-dd HH:mm" time:self.model.updateTime]];
    
    UIView * line1 = [[UIView alloc] initWithFrame:CGRectZero];
    line1.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.4f];
    [footerView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lastUpdateLabel.mas_bottom).offset(46 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(3 * scale);
        make.width.mas_equalTo(kMainBoundsWidth - 120 * scale);
    }];
    
    UIButton * addSeriButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"将当前D贴加入已有系列或新建系列中"];
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
    
    UILabel * titleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(60 * scale) textColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] alignment:NSTextAlignmentCenter];
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
