//
//  DTieEditViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/11.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieEditViewController.h"
#import "DTieEditTableViewCell.h"
#import "DTieEditTextTableViewCell.h"
#import "DTieEditTextViewController.h"
#import "DTieEditImageTableViewCell.h"
#import "XFCameraController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "DTieEditFooterView.h"
#import "MBProgressHUD+DDHUD.h"
#import "QNDDUploadManager.h"
#import "CreateDTieRequest.h"
#import "DTieEditReadViewController.h"
#import "DTieChooseLocationController.h"
#import "DTieModel.h"
#import <UIImageView+WebCache.h>
#import "DTieDetailViewController.h"
#import "DDTool.h"
#import "DDPrivateViewController.h"
#import "WeChatManager.h"
#import "DTieShareViewController.h"
#import "DatePickerView.h"

NSString * const DTieDidCreateNotification = @"DTieDidCreateNotification";

@interface DTieEditViewController () <UITableViewDelegate, UITableViewDataSource, DTEditTextViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChooseLocationDelegate, DDPrivateViewSelectDelegate, DatePickerViewDelegate>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UIButton * putButton;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, strong) NSMutableArray * moduleSource;

@property (nonatomic, strong) BMKPoiInfo * choosePOI;

@property (nonatomic, strong) UILongPressGestureRecognizer * longPressGesture;
@property (nonatomic, strong) NSIndexPath * selectIndexPath;
@property (nonatomic, strong) NSIndexPath * lastSelectIndex;
@property (nonatomic, strong) UIView * longPressView;

@property (nonatomic, strong) NSIndexPath * currentEditIndex;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@property (nonatomic, strong) UIImageView * QXImageView;
@property (nonatomic, strong) UILabel * QXLabel;
@property (nonatomic, strong) UIImageView * PYQImageView;
@property (nonatomic, strong) UIImageView * WXImageView;
@property (nonatomic, assign) BOOL QXEnable;
@property (nonatomic, assign) BOOL PYQEnable;
@property (nonatomic, assign) BOOL WXEnable;
@property (nonatomic, strong) NSMutableArray * shareImages;

@property (nonatomic, strong) DTieEditFooterView * footerView;

@property (nonatomic, copy) NSString * editTitle;
@property (nonatomic, copy) NSString * editLocation;

@property (nonatomic, assign) NSInteger status;

@property (nonatomic, strong) DTieModel * editModel;

@property (nonatomic, strong) SecurityGroupModel * groupModel;
@property (nonatomic, assign) NSInteger sharePostId;

@property (nonatomic, strong) DatePickerView * datePicker;
@property (nonatomic, assign) NSInteger createTime;

@end

@implementation DTieEditViewController

- (instancetype)initWithTitle:(NSString *)title address:(NSString *)address
{
    if (self = [super init]) {
        self.editTitle = title;
        self.editLocation = address;
    }
    return self;
}

- (instancetype)initWithDtieModel:(DTieModel *)model
{
    if (self = [super init]) {
        self.editModel = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.createTime = [[NSDate date] timeIntervalSince1970] * 1000;
    [self createDataSource];
    [self createViews];
    
    if (!isEmptyString(self.editLocation)) {
        self.footerView.locationLabel.text = self.editLocation;
    }else{
        self.footerView.locationLabel.text = [DDLocationManager shareManager].result.address;
    }
    
    if (self.editModel) {
        
        if (self.editModel.sceneTime > 0) {
            self.createTime = self.editModel.sceneTime;
            self.footerView.timeLabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.editModel.sceneTime];
        }
        
        [self.dataSource removeAllObjects];
        [self.moduleSource removeAllObjects];
        
        [self.moduleSource addObjectsFromArray:self.editModel.details];
        [self.dataSource addObject:self.moduleSource];
        
        DTieEditModel * model = [[DTieEditModel alloc] init];
        model.type = DTieEditType_Title;
        model.detailsContent = self.editModel.postSummary;
        [self.dataSource insertObject:@[model] atIndex:0];
        
        [self.tableView reloadData];
    }
}

- (void)createDataSource
{
    self.dataSource = [NSMutableArray new];
    
    self.moduleSource = [NSMutableArray new];
    for (NSInteger i = 0; i < 4; i++) {
        DTieEditModel * model = [[DTieEditModel alloc] init];
        if (i == 0) {
            model.type = DTieEditType_Title;
            [self.dataSource addObject:@[model]];
        }else{
            model.type = i;
            [self.moduleSource addObject:model];
        }
    }
    [self.dataSource addObject:self.moduleSource];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.footerView = [[DTieEditFooterView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 370 * scale)];
    [self.footerView.locationButton addTarget:self action:@selector(chooseLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView.AddButton addTarget:self action:@selector(addMoudle) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeViewDidTap)];
    self.footerView.timeLabel.userInteractionEnabled = YES;
    [self.footerView.timeLabel addGestureRecognizer:tap];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.tableView registerClass:[DTieEditTableViewCell class] forCellReuseIdentifier:@"DTieEditTableViewCell"];
    [self.tableView registerClass:[DTieEditTextTableViewCell class] forCellReuseIdentifier:@"DTieEditTextTableViewCell"];
    [self.tableView registerClass:[DTieEditImageTableViewCell class] forCellReuseIdentifier:@"DTieEditImageTableViewCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionHeaderHeight = 0.1;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    [self createTableFooterView];
    
    [self createTopView];
    
    [self.tableView addGestureRecognizer:self.longPressGesture];
}

#pragma mark - 用户交互
- (void)addMoudle
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"选择" message:@"请选择添加模块类型" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"文字" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self addMoudleWith:DTieEditType_Text];
    }];
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self addMoudleWith:DTieEditType_Image];
    }];
    UIAlertAction * action3 = [UIAlertAction actionWithTitle:@"视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self addMoudleWith:DTieEditType_Video];
    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancelAction];
    
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)addMoudleWith:(DTieEditType)type
{
    DTieEditModel * model = [[DTieEditModel alloc] init];
    model.type = type;
    [self.moduleSource addObject:model];
    
    [self.tableView beginUpdates];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.moduleSource.count - 1 inSection:1];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)chooseLocation
{
    DTieChooseLocationController * chosse = [[DTieChooseLocationController alloc] init];
    chosse.delegate = self;
    [self.navigationController pushViewController:chosse animated:YES];
}

- (void)chooseLocationDidChoose:(BMKPoiInfo *)poi
{
    self.choosePOI = poi;
    self.footerView.locationLabel.text = [NSString stringWithFormat:@"%@%@", poi.address, poi.name];
}

- (void)yulanButtonDidClicked
{
    self.status = 1;
    [self putDTie];
}

- (void)editCoverButtonDidClicked
{
    NSArray * titleArray = [self.dataSource firstObject];
    DTieEditModel * titleModel = [titleArray firstObject];
    NSString * title = titleModel.detailsContent;
    if (isEmptyString(title)) {
        [MBProgressHUD showTextHUDWithText:@"请输入标题" inView:self.view];
        return;
    }
    
    DTieModel * dtie = [[DTieModel alloc] init];
    dtie.postSummary = title;
    dtie.createTime = [[NSDate date] timeIntervalSince1970] * 1000;
    dtie.sceneTime = [[NSDate date] timeIntervalSince1970] * 1000;
    dtie.updateTime = [[NSDate date] timeIntervalSince1970] * 1000;
    dtie.details = [NSArray arrayWithArray:self.moduleSource];
    dtie.sceneAddress = self.footerView.locationLabel.text;
    DTieEditReadViewController * read = [[DTieEditReadViewController alloc] initWithDTie:dtie];
    [self.navigationController pushViewController:read animated:YES];
    
}

- (void)saveButtonDidClicked
{
    self.status = 0;
    [self putDTie];
}

#pragma mark - 长按移动cell
- (void)DDLongPressGesture:(UILongPressGestureRecognizer *)longGesture
{
    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self longGestureBegan:longGesture];
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            [self longGestureChanged:longGesture];
        }
            
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            [self longGestureEnded:longGesture];
        }
            
            break;
            
        default:
            break;
    }
}

- (void)longGestureEnded:(UILongPressGestureRecognizer *)longGesture
{
    [self.longPressView removeFromSuperview];
    DTieEditTableViewCell * cell = [self.tableView cellForRowAtIndexPath:self.selectIndexPath];
    cell.hidden = NO;
    self.selectIndexPath = nil;
}

- (void)longGestureChanged:(UILongPressGestureRecognizer *)longGesture
{
    CGPoint point = [longGesture locationInView:self.tableView];
    NSIndexPath *currentIndexPath = [self.tableView indexPathForRowAtPoint:point];
    CGFloat pointY = point.y;
    self.longPressView.center = CGPointMake(self.longPressView.center.x, pointY);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (currentIndexPath && ![self.selectIndexPath isEqual:currentIndexPath] && currentIndexPath.section && self.selectIndexPath) {
            [self.moduleSource exchangeObjectAtIndex:currentIndexPath.row withObjectAtIndex:self.selectIndexPath.row];
            [self.tableView moveRowAtIndexPath:self.selectIndexPath toIndexPath:currentIndexPath];
            self.lastSelectIndex = self.selectIndexPath;
            self.selectIndexPath = currentIndexPath;
        }
    });

//    if (self.longPressView.center.y <= self.tableView.contentOffset.y) {
//        if (self.selectIndexPath.row != 0) {
//            [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + 1) animated:NO];
//            self.longPressView.center = CGPointMake(self.longPressView.center.x, [self tempViewYToFitTargetY:self.longPressView.center.y + 1]);
//        }
//    }
}

- (CGFloat)tempViewYToFitTargetY:(CGFloat)targetY
{
    CGFloat minValue = self.longPressView.bounds.size.height/2.0;
    CGFloat maxValue = self.tableView.contentSize.height - minValue;
    return MIN(maxValue, MAX(minValue, targetY));
}

- (void)longGestureBegan:(UILongPressGestureRecognizer *)longGesture
{
    CGPoint point = [longGesture locationInView:self.tableView];
    self.selectIndexPath = [self.tableView indexPathForRowAtPoint:point];
    if (self.selectIndexPath.section == 1) {
        
        DTieEditTableViewCell * cell = [self.tableView cellForRowAtIndexPath:self.selectIndexPath];
        self.longPressView = [cell snapshotViewAfterScreenUpdates:NO];
        //配置默认样式
        self.longPressView.layer.shadowColor = [UIColor grayColor].CGColor;
        self.longPressView.layer.masksToBounds = NO;
        self.longPressView.layer.cornerRadius = 0;
        self.longPressView.layer.shadowOffset = CGSizeMake(-5, 0);
        self.longPressView.layer.shadowOpacity = 0.4;
        self.longPressView.layer.shadowRadius = 5;
        self.longPressView.frame = cell.frame;
        [self.tableView addSubview:self.longPressView];
        cell.hidden = YES;
    }
}

- (void)DTEditTextDidFinished:(NSString *)text
{
    NSArray * data = [self.dataSource objectAtIndex:self.currentEditIndex.section];;
    DTieEditModel * model = [data objectAtIndex:self.currentEditIndex.row];
    
    if (model.type == DTieEditType_Title || model.type == DTieEditType_Text) {
        model.detailsContent = text;
    }
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[self.currentEditIndex] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * data = [self.dataSource objectAtIndex:section];
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * data = [self.dataSource objectAtIndex:indexPath.section];;
    
    DTieEditModel * model = [data objectAtIndex:indexPath.row];
    
    switch (model.type) {
        case DTieEditType_Title:
        {
            DTieEditTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieEditTableViewCell" forIndexPath:indexPath];
            if ([self.selectIndexPath isEqual:indexPath]) {
                cell.hidden = YES;
            }
            if (!isEmptyString(self.editTitle)) {
                model.detailsContent = self.editTitle;
            }
            
            [cell configWithEditModel:model];
            return cell;
        }
            break;
            
        case DTieEditType_Text:
        {
            DTieEditTextTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieEditTextTableViewCell" forIndexPath:indexPath];
            if ([self.selectIndexPath isEqual:indexPath]) {
                cell.hidden = YES;
            }
            [cell configWithEditModel:model];
            return cell;
        }
            break;
            
        case DTieEditType_Image:
        {
            DTieEditImageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieEditImageTableViewCell" forIndexPath:indexPath];
            if ([self.selectIndexPath isEqual:indexPath]) {
                cell.hidden = YES;
            }
            [cell configWithEditModel:model];
            return cell;
        }
            break;
            
        case DTieEditType_Video:
        {
            DTieEditImageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieEditImageTableViewCell" forIndexPath:indexPath];
            if ([self.selectIndexPath isEqual:indexPath]) {
                cell.hidden = YES;
            }
            [cell configWithEditModel:model];
            return cell;
        }
            break;
            
        default:
            break;
    }
    
    DTieEditTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieEditTableViewCell" forIndexPath:indexPath];
    if ([self.selectIndexPath isEqual:indexPath]) {
        cell.hidden = YES;
    }
    [cell configWithEditModel:model];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    return 120 * scale;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * dataArray = [self.dataSource objectAtIndex:indexPath.section];
    DTieEditModel * model = [dataArray objectAtIndex:indexPath.row];
    if (model.type == DTieEditType_Image || model.type == DTieEditType_Video) {
        
        if (model.image) {
            UIImage * image = model.image;
            CGFloat scale = image.size.height / image.size.width;
            return kMainBoundsWidth * scale + 170 * kMainBoundsWidth / 1080.f;
        }else if (!isEmptyString(model.detailContent)){
            UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:model.detailContent];
            
            // 没有找到已下载的图片就使用默认的占位图，当然高度也是默认的高度了，除了高度不固定的文字部分。
            if (!image) {
                image = [UIImage imageNamed:@"test"];
                
                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:model.detailContent] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    
                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                    [[SDImageCache sharedImageCache] storeImage:image forKey:model.detailContent toDisk:YES completion:nil];
                    model.image = image;
                    [self.tableView beginUpdates];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [self.tableView endUpdates];
                }];
            }else{
                model.image = image;
            }
            
            CGFloat scale = image.size.height / image.size.width;
            return kMainBoundsWidth * scale + 170 * kMainBoundsWidth / 1080.f;
            
        }
        
    }
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 370.f * kMainBoundsWidth / 1080.f;
    }
    
    return 0.1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return self.footerView;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * data = [self.dataSource objectAtIndex:indexPath.section];;
    
    DTieEditModel * model = [data objectAtIndex:indexPath.row];
    self.currentEditIndex = indexPath;
    switch (model.type) {
        case DTieEditType_Title:
            
        {
            DTieEditTextViewController * text = [[DTieEditTextViewController alloc] initWithText:model.detailsContent placeholder:@"写个标题..."];
            text.delegate = self;
            [self.navigationController pushViewController:text animated:YES];
        }
            break;
            
        case DTieEditType_Text:
            
        {
            DTieEditTextViewController * text = [[DTieEditTextViewController alloc] initWithText:model.detailsContent placeholder:@"说点让你感到不同或惊艳的..."];
            text.delegate = self;
            [self.navigationController pushViewController:text animated:YES];
        }
            
            break;
            
        case DTieEditType_Image:
            
        {
            [self selectImageFromAlbum];
        }
            break;
            
        case DTieEditType_Video:
            
        {
            [self takeVideo];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark 从相册获取图片或视频
- (void)selectImageFromAlbum
{
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self.imagePickerController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)takeVideo
{
    XFCameraController * camera = [XFCameraController defaultCameraController];
    
    __weak typeof(camera) weakCamera = camera;
    camera.shootCompletionBlock = ^(NSURL *videoUrl, CGFloat videoTimeLength, UIImage *thumbnailImage, NSError *error) {
        
        [weakCamera dismissViewControllerAnimated:YES completion:nil];
        NSArray * data = [self.dataSource objectAtIndex:self.currentEditIndex.section];;
        DTieEditModel * model = [data objectAtIndex:self.currentEditIndex.row];
        
        model.image = thumbnailImage;
        model.videoURL = videoUrl;
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[self.currentEditIndex] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    };
    
    [self presentViewController:camera animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate
//适用获取所有媒体资源，只需判断资源类型
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    //判断资源类型
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        
        UIImage *tmpImg = [info objectForKey:UIImagePickerControllerEditedImage];
        
        if (nil == tmpImg) {
            tmpImg = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        NSData*  data = [NSData data];
        data = UIImageJPEGRepresentation(tmpImg, 1);
        float tempX = 0.9;
        NSInteger length = data.length;
        while (data.length > 500*1024) {
            data = UIImageJPEGRepresentation(tmpImg, tempX);
            tempX -= 0.1;
            if (data.length == length) {
                break;
            }
            length = data.length;
        }
        
        DTieEditModel * model = [self.moduleSource objectAtIndex:self.currentEditIndex.row];
        model.image = [UIImage imageWithData:data];
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[self.currentEditIndex] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)createTableFooterView
{
    CGFloat scale = kMainBoundsWidth / 1100.f;
    
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 1080 * scale)];
    footerView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    UIButton * QXButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0x000000) title:@""];
    self.QXEnable = YES;
    [QXButton addTarget:self action:@selector(QXButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:QXButton];
    [QXButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0 * scale);
        make.left.mas_equalTo(60 * scale);
        make.width.mas_equalTo(kMainBoundsWidth - 120 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    self.QXLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x000000) alignment:NSTextAlignmentLeft];
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@"默认当前D贴权限为" attributes:@{NSFontAttributeName:kPingFangRegular(42 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"公开" attributes:@{NSFontAttributeName:kPingFangRegular(42 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0xDB6283)}]];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"，点击更改" attributes:@{NSFontAttributeName:kPingFangRegular(42 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}]];
    self.QXLabel.attributedText = string;
    [QXButton addSubview:self.QXLabel];
    [self.QXLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(0);
    }];
    self.QXImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"qx"]];
    [QXButton addSubview:self.QXImageView];
    [self.QXImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.width.height.mas_equalTo(72 * scale);
    }];
    
    UIView * lineView1 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView1.backgroundColor = UIColorFromRGB(0xCCCCCC);
    [QXButton addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(3 * scale);
    }];
    
    UIButton * PYQButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0x000000) title:@""];
    self.PYQEnable = YES;
    [PYQButton addTarget:self action:@selector(PYQButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:PYQButton];
    [PYQButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(QXButton.mas_bottom);
        make.left.mas_equalTo(60 * scale);
        make.width.mas_equalTo(kMainBoundsWidth - 120 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    UILabel * PYQLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    PYQLabel.text = @"同步分享到朋友圈";
    [PYQButton addSubview:PYQLabel];
    [PYQLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(0);
    }];
    self.PYQImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"qx"]];
    [PYQButton addSubview:self.PYQImageView];
    [self.PYQImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.width.height.mas_equalTo(72 * scale);
    }];
    UIView * lineView2 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView2.backgroundColor = UIColorFromRGB(0xCCCCCC);
    [PYQButton addSubview:lineView2];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(3 * scale);
    }];
    
    UIButton * WXButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0x000000) title:@""];
    self.WXEnable = NO;
    [WXButton addTarget:self action:@selector(WXButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:WXButton];
    [WXButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(PYQButton.mas_bottom);
        make.left.mas_equalTo(60 * scale);
        make.width.mas_equalTo(kMainBoundsWidth - 120 * scale);
        make.height.mas_equalTo(120 * scale);
    }];
    UILabel * WXLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    WXLabel.text = @"分享D帖给微信好友或微信群";
    [WXButton addSubview:WXLabel];
    [WXLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(0);
    }];
    self.WXImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"qxno"]];
    [WXButton addSubview:self.WXImageView];
    [self.WXImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.width.height.mas_equalTo(72 * scale);
    }];
    UIView * lineView3 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView3.backgroundColor = UIColorFromRGB(0xCCCCCC);
    [WXButton addSubview:lineView3];
    [lineView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(3 * scale);
    }];
    
    UIButton * yulanButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xFFFFFF) title:@"发布"];
    [footerView addSubview:yulanButton];
    [yulanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(WXButton.mas_bottom).offset(90 * scale);
        make.left.mas_equalTo(60 * scale);
        make.width.mas_equalTo(kMainBoundsWidth - 120 * scale);
        make.height.mas_equalTo(144 * scale);
    }];
    [yulanButton addTarget:self action:@selector(yulanButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [DDViewFactoryTool cornerRadius:24 * scale withView:yulanButton];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xDB6283).CGColor, (__bridge id)UIColorFromRGB(0XB721FF).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.frame = CGRectMake(0, 0, kMainBoundsWidth - 120 * scale, 144 * scale);
    [yulanButton.layer insertSublayer:gradientLayer atIndex:0];
    
    UIButton * editCoverButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"预览"];
    [editCoverButton addTarget:self action:@selector(editCoverButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:editCoverButton];
    [editCoverButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.top.mas_equalTo(yulanButton.mas_bottom).offset(36 * scale);
        make.width.mas_equalTo(450 * scale);
        make.height.mas_equalTo(144 * scale);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:editCoverButton];
    editCoverButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    editCoverButton.layer.borderWidth = 3 * scale;
    
    UIButton * saveButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(48 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"保存草稿"];
    [saveButton addTarget:self action:@selector(saveButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:saveButton];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-60 * scale);
        make.top.mas_equalTo(yulanButton.mas_bottom).offset(36 * scale);
        make.width.mas_equalTo(450 * scale);
        make.height.mas_equalTo(144 * scale);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:saveButton];
    saveButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    saveButton.layer.borderWidth = 3 * scale;
    
    UIView * tipLine = [[UIView alloc] initWithFrame:CGRectZero];
    tipLine.backgroundColor = UIColorFromRGB(0xCCCCCC);
    [footerView addSubview:tipLine];
    [tipLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.width.mas_equalTo(kMainBoundsWidth - 120 * scale);
        make.height.mas_equalTo(3 * scale);
        make.top.mas_equalTo(saveButton.mas_bottom).offset(107 * scale);
    }];
    
    UILabel * tipLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xCCCCCC) alignment:NSTextAlignmentCenter];
    tipLabel.text = @"小提示";
    tipLabel.backgroundColor = footerView.backgroundColor;
    [footerView addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(tipLine);
        make.height.mas_equalTo(40 * scale);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(216 * scale);
    }];
    
    UILabel * bottomLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xCCCCCC) alignment:NSTextAlignmentLeft];
    bottomLabel.text = @"您可以预览确认后再发布，也可以点击发布标签直接发布，或先保存草稿，稍晚编辑后再发布";
    bottomLabel.numberOfLines = 0;
    [footerView addSubview:bottomLabel];
    [bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.width.mas_equalTo(kMainBoundsWidth - 120 * scale);
        make.top.mas_equalTo(tipLabel.mas_bottom).offset(46 * scale);
    }];
    
    self.tableView.tableFooterView = footerView;
}

- (void)QXButtonDidClicked
{
    DDPrivateViewController * private = [[DDPrivateViewController alloc] init];
    private.delegate = self;
    [self.navigationController pushViewController:private animated:YES];
}

- (void)securityDidSelectWith:(SecurityGroupModel *)model
{
    self.groupModel = model;
    CGFloat scale = kMainBoundsWidth / 1080.f;
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:@"当前D贴权限为" attributes:@{NSFontAttributeName:kPingFangRegular(42 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
    NSString * name = model.securitygroupName;
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:name attributes:@{NSFontAttributeName:kPingFangRegular(42 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0xDB6283)}]];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"，点击更改" attributes:@{NSFontAttributeName:kPingFangRegular(42 * scale), NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}]];
    self.QXLabel.attributedText = string;
}

- (void)PYQButtonDidClicked
{
    self.PYQEnable = !self.PYQEnable;
    
    if (self.PYQEnable) {
        [self.PYQImageView setImage:[UIImage imageNamed:@"qx"]];
    }else{
        [self.PYQImageView setImage:[UIImage imageNamed:@"qxno"]];
    }
    
    if (self.WXEnable && self.PYQEnable) {
        self.WXEnable = NO;
        [self.WXImageView setImage:[UIImage imageNamed:@"qxno"]];
    }
}

- (void)WXButtonDidClicked
{
    self.WXEnable = !self.WXEnable;
    if (self.WXEnable) {
        [self.WXImageView setImage:[UIImage imageNamed:@"qx"]];
    }else{
        [self.WXImageView setImage:[UIImage imageNamed:@"qxno"]];
    }
    
    if (self.WXEnable && self.PYQEnable) {
        self.PYQEnable = NO;
        [self.PYQImageView setImage:[UIImage imageNamed:@"qxno"]];
    }
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
    titleLabel.text = @"编辑D贴";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
//    self.putButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] title:@"发布"];
//    [DDViewFactoryTool cornerRadius:12 * scale withView:self.putButton];
//    self.putButton.layer.borderWidth = .5f;
//    self.putButton.layer.borderColor = UIColorFromRGB(0xFFFFFF).CGColor;
//    [self.putButton addTarget:self action:@selector(putButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.topView addSubview:self.putButton];
//    [self.putButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(144 * scale);
//        make.height.mas_equalTo(72 * scale);
//        make.centerY.mas_equalTo(titleLabel);
//        make.right.mas_equalTo(-60 * scale);
//    }];
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)putButtonDidClicked
{
    [self putDTie];
}

- (void)putDTie
{
    NSArray * titleArray = [self.dataSource firstObject];
    DTieEditModel * titleModel = [titleArray firstObject];
    NSString * title = titleModel.detailsContent;
    if (isEmptyString(title)) {
        [MBProgressHUD showTextHUDWithText:@"请输入标题" inView:self.view];
        return;
    }
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在上传Dtie" inView:self.view];
    NSMutableArray * listArray = [[NSMutableArray alloc] init];
    __block NSInteger tempCount = 0;
    
    NSMutableArray * tempArray = [[NSMutableArray alloc] initWithArray:self.moduleSource];
    [self.shareImages removeAllObjects];
    
    for (NSInteger i = 0; i < tempArray.count; i++) {
        
        DTieEditModel * model = [tempArray objectAtIndex:i];
        
        [listArray addObject:@{@"detailNumber":@"1",
                               @"datadictionaryType":@"CONTENT_TEXT",
                               @"detailsContent":@"",
                               @"textInformation":@"",
                               @"pFlg":@(model.pFlag)}];
        
        switch (model.type) {
            case DTieEditType_Text:
            {
                if (isEmptyString(model.detailsContent)) {
                    
                    if (isEmptyString(model.detailContent)) {
                        [tempArray removeObjectAtIndex:i];
                        [listArray removeObjectAtIndex:i];
                        i--;
                        tempCount++;
                        if (tempCount == self.moduleSource.count) {
                            [hud hideAnimated:YES];
                            [self uploadDtieWithList:listArray withTitle:title];
                        }
                        continue;
                        
                    }else{
                        model.detailsContent = model.detailContent;
                    }
                    
                }
                
                NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                        @"datadictionaryType":@"CONTENT_TEXT",
                                        @"detailsContent":model.detailsContent,
                                        @"textInformation":@"",
                                        @"pFlg":@(model.pFlag)};
                [listArray replaceObjectAtIndex:i withObject:dict];
                tempCount++;
                if (tempCount == self.moduleSource.count) {
                    [hud hideAnimated:YES];
                    [self uploadDtieWithList:listArray withTitle:title];
                }
            }
                
                break;
                
            case DTieEditType_Image:
            {
                if (model.image) {
                    [self.shareImages addObject:model.image];
                }
                
                if (!model.image) {
                    if (model.detailContent) {
                        NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                                @"datadictionaryType":@"CONTENT_IMG",
                                                @"detailsContent":model.detailsContent,
                                                @"textInformation":@"",
                                                @"pFlg":@(model.pFlag)};
                        [listArray replaceObjectAtIndex:i withObject:dict];
                        tempCount++;
                        if (tempCount == self.moduleSource.count) {
                            [hud hideAnimated:YES];
                            [self uploadDtieWithList:listArray withTitle:title];
                        }
                    }else{
                        [tempArray removeObjectAtIndex:i];
                        [listArray removeObjectAtIndex:i];
                        i--;
                        tempCount++;
                        if (tempCount == self.moduleSource.count) {
                            [hud hideAnimated:YES];
                            [self uploadDtieWithList:listArray withTitle:title];
                        }
                    }
                    continue;
                }
                
                QNDDUploadManager * manager = [[QNDDUploadManager alloc] init];
                
                [manager uploadImage:model.image progress:^(NSString *key, float percent) {
                    
                } success:^(NSString *url) {
                    
                    model.detailsContent = url;
                    NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                            @"datadictionaryType":@"CONTENT_IMG",
                                            @"detailsContent":model.detailsContent,
                                            @"textInformation":@"",
                                            @"pFlg":@(model.pFlag)};
                    [listArray replaceObjectAtIndex:i withObject:dict];
                    tempCount++;
                    if (tempCount == self.moduleSource.count) {
                        [hud hideAnimated:YES];
                        [self uploadDtieWithList:listArray withTitle:title];
                    }
                    
                } failed:^(NSError *error) {
                    
                    tempCount++;
                    if (tempCount == self.moduleSource.count) {
                        [hud hideAnimated:YES];
                        [self uploadDtieWithList:listArray withTitle:title];
                    }
                    
                }];
            }
                
                break;
                
            case DTieEditType_Video:
            {
                
                if (!model.image) {
                    if (model.detailContent) {
                        NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                                @"datadictionaryType":@"CONTENT_VIDEO",
                                                @"detailsContent":model.detailsContent,
                                                @"textInformation":model.textInformation,
                                                @"pFlg":@(model.pFlag)};
                        [listArray replaceObjectAtIndex:i withObject:dict];
                        tempCount++;
                        if (tempCount == self.moduleSource.count) {
                            [hud hideAnimated:YES];
                            [self uploadDtieWithList:listArray withTitle:title];
                        }
                    }else{
                        [tempArray removeObjectAtIndex:i];
                        [listArray removeObjectAtIndex:i];
                        i--;
                        tempCount++;
                        if (tempCount == self.moduleSource.count) {
                            [hud hideAnimated:YES];
                            [self uploadDtieWithList:listArray withTitle:title];
                        }
                    }
                    continue;
                }
                
                QNDDUploadManager * manager = [[QNDDUploadManager alloc] init];
                
                [manager uploadImage:model.image progress:^(NSString *key, float percent) {
                    
                } success:^(NSString *url) {
                    model.detailsContent = url;
                    [manager uploadVideoWith:model.image filePath:model.videoURL progress:^(NSString *key, float percent) {
                        
                    } success:^(NSString *url) {
                        
                        model.textInformation = url;
                        NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                                @"datadictionaryType":@"CONTENT_VIDEO",
                                                @"detailsContent":model.detailsContent,
                                                @"textInformation":model.textInformation,
                                                @"pFlg":@(model.pFlag)};
                        [listArray replaceObjectAtIndex:i withObject:dict];
                        tempCount++;
                        if (tempCount == self.moduleSource.count) {
                            [hud hideAnimated:YES];
                            [self uploadDtieWithList:listArray withTitle:title];
                        }
                        
                    } failed:^(NSError *error) {
                        
                        tempCount++;
                        if (tempCount == self.moduleSource.count) {
                            [hud hideAnimated:YES];
                            [self uploadDtieWithList:listArray withTitle:title];
                        }
                        
                    }];
                    
                } failed:^(NSError *error) {
                    
                    tempCount++;
                    if (tempCount == self.moduleSource.count) {
                        [hud hideAnimated:YES];
                        [self uploadDtieWithList:listArray withTitle:title];
                    }
                    
                }];
            }
                
                break;
                
            default:
                break;
        }
        
    }
}

- (void)uploadDtieWithList:(NSMutableArray *)array withTitle:(NSString *)title
{
    if (array.count == 0) {
        [MBProgressHUD showTextHUDWithText:@"不能发布空贴哟~" inView:self.view];
        return;
    }
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在创建Dtie" inView:self.view];
    
    //获取参数配置
    NSString * address = self.footerView.locationLabel.text;
    double lon;
    double lat;
    if (self.choosePOI) {
        lon = self.choosePOI.pt.longitude;
        lat = self.choosePOI.pt.latitude;
    }else if (self.editModel){
        lon = self.editModel.sceneAddressLng;
        lat = self.editModel.sceneAddressLat;
    }else{
        lon = [DDLocationManager shareManager].userLocation.location.coordinate.longitude;
        lat = [DDLocationManager shareManager].userLocation.location.coordinate.latitude;
    }
    NSString * firstPic = @"";
    for (NSInteger i = 0; i < array.count; i++) {
        NSDictionary * dict = [array objectAtIndex:i];
        NSString * type = [dict objectForKey:@"datadictionaryType"];
        if ([type isEqualToString:@"CONTENT_IMG"] || [type isEqualToString:@"CONTENT_VIDEO"]) {
            firstPic = [dict objectForKey:@"detailsContent"];
            break;
        }
    }
    
    NSInteger postId = 0;
    if (self.editModel) {
        postId = self.editModel.postId;
    }
    
    NSMutableArray * allowToSeeList = [[NSMutableArray alloc] init];
    if (self.groupModel) {
        [allowToSeeList addObject:@(self.groupModel.cid)];
    }
    
    CreateDTieRequest * request = [[CreateDTieRequest alloc] initWithList:array title:title address:address addressLng:lon addressLat:lat status:self.status remindFlg:1 firstPic:firstPic postID:postId landAccountFlg:1 allowToSeeList:allowToSeeList sceneTime:self.createTime];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                [MBProgressHUD showTextHUDWithText:@"创建成功" inView:self.view];
                
                DTieModel * DTie = [DTieModel mj_objectWithKeyValues:data];
                self.sharePostId = DTie.postId;
                if (self.status) {
                    DTie.dTieType = DTieType_MyDtie;
                }else{
                    DTie.dTieType = DTieType_Edit;
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:DTieDidCreateNotification object:nil];
                [self.navigationController popViewControllerAnimated:YES];
                
                if (self.PYQEnable || self.WXEnable) {
                    if (self.status == 1) {
                        [self checkShare];
                    }
                }
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"创建失败" inView:self.view];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"创建失败" inView:self.view];
    }];
    
    NSLog(@"%@", array);
}

- (void)checkShare
{
    if (self.PYQEnable) {
        if (self.shareImages && self.shareImages.count > 0) {
            DTieShareViewController * share = [[DTieShareViewController alloc] initWithShareList:self.shareImages];
            [self.navigationController presentViewController:share animated:YES completion:nil];
        }
    }else if(self.WXEnable){
        
        if (self.sharePostId == 0) {
            return;
        }
        
        [WeChatManager shareManager].isShare = YES;
        UIImage * image = [UIImage imageNamed:@"DeeDao-logo"];
        if (self.shareImages && self.shareImages.count > 0) {
            image = [self.shareImages firstObject];
        }
        [[WeChatManager shareManager] shareMiniProgramWithPostID:self.editModel.cid image:image];
    }
}

- (UILongPressGestureRecognizer *)longPressGesture
{
    if (!_longPressGesture) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(DDLongPressGesture:)];
        _longPressGesture.minimumPressDuration = .5f;
    }
    return _longPressGesture;
}

- (UIImagePickerController *)imagePickerController
{
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        _imagePickerController.allowsEditing = NO;
    }
    return _imagePickerController;
}

- (NSMutableArray *)shareImages
{
    if (!_shareImages) {
        _shareImages = [[NSMutableArray alloc] initWithCapacity:9];
    }
    return _shareImages;
}

- (DatePickerView *)datePicker
{
    if (!_datePicker) {
        _datePicker = [[DatePickerView alloc] initWithFrame:CGRectMake(0, kMainBoundsHeight / 3 * 2, kMainBoundsWidth, kMainBoundsHeight / 3)];
        _datePicker.delegate = self;
        [[UIApplication sharedApplication].keyWindow addSubview:_datePicker];
    }
    return _datePicker;
}

- (void)timeViewDidTap
{
    [self.datePicker showDateTimePickerView];
}

- (void)didClickFinishDateTimePickerView:(NSString *)date
{
    self.createTime = self.datePicker.currentTime;
    NSString * str = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.createTime];
    self.footerView.timeLabel.text = str;
    [self.datePicker hideDateTimePickerView];
}

- (void)dealloc
{
    
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
