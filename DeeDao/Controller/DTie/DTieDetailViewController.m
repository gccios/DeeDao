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

@interface DTieDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) DTieModel * model;

@end

@implementation DTieDetailViewController

- (instancetype)initWithDTie:(DTieModel *)model
{
    if (self = [super init]) {
        self.model = model;
        self.dataSource = [[NSMutableArray alloc] initWithArray:self.model.details];
        
        if (self.model.postFirstPicture) {
            DTieEditModel * model = [[DTieEditModel alloc] init];
            model.type = DTieEditType_Image;
            model.detailContent = self.model.postFirstPicture;
            [self.dataSource insertObject:model atIndex:0];
        }else{
            for (DTieEditModel * tempModel in self.model.details) {
                if (tempModel.type == DTieEditType_Image) {
                    DTieEditModel * model = [[DTieEditModel alloc] init];
                    model.type = DTieEditType_Image;
                    model.detailContent = tempModel.detailContent;
                    [self.dataSource insertObject:model atIndex:0];
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
