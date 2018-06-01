//
//  DTieContentView.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/31.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieContentView.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import "DDTool.h"
#import "DTieNewEditImageCell.h"
#import "DTieNewEditTextCell.h"
#import "DTieNewEditVideoCell.h"
#import <TZImagePickerController.h>
#import "MBProgressHUD+DDHUD.h"
#import "XFCameraController.h"
#import "DTieEditTextViewController.h"
#import "DTieChooseLocationController.h"
#import "RTDragCellTableView.h"
#import "DTieChooseLocationController.h"
#import "DatePickerView.h"
#import "LookImageViewController.h"
#import <AVKit/AVKit.h>

@interface DTieContentView() <RTDragCellTableViewDelegate, RTDragCellTableViewDataSource, TZImagePickerControllerDelegate, DTEditTextViewControllerDelegate, ChooseLocationDelegate, DatePickerViewDelegate>

@property (nonatomic, strong) RTDragCellTableView * tableView;

@property (nonatomic, strong) UIView * addChooseView;

@property (nonatomic, strong) UIButton * chooseButton;
@property (nonatomic, assign) NSInteger insertIndex;
@property (nonatomic, strong) DTieEditModel * currentModel;

@property (nonatomic, strong) UIButton * tempAddButton;
@property (nonatomic, strong) UIButton * imageButton;
@property (nonatomic, strong) UIButton * videoButton;
@property (nonatomic, strong) UIButton * textButton;

@property (nonatomic, strong) DatePickerView * datePicker;

@property (nonatomic, strong) DTieModel * editDTModel;

//@property (nonatomic, strong) TZImagePickerController * picker;
//@property (nonatomic, strong) NSMutableArray * selectPHAsset;

@end

@implementation DTieContentView

- (instancetype)initWithFrame:(CGRect)frame editModel:(DTieModel *)editModel
{
    if (self = [super initWithFrame:frame]) {
        self.editDTModel = editModel;
        [self.modleSources addObjectsFromArray:editModel.details];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"detailNumber" ascending:YES];
        [self.modleSources sortUsingDescriptors:@[sort]];
        [self createContenView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createContenView];
    }
    return self;
}

#pragma mark - 时间和地点的选择
- (void)timeViewDidTap
{
    [self.datePicker showDateTimePickerViewWithDate:[NSDate dateWithTimeIntervalSince1970:self.createTime/1000]];
}

- (void)didClickFinishDateTimePickerView:(NSString *)date
{
    self.createTime = self.datePicker.currentTime;
    NSString * str = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.createTime];
    self.timeLabel.text = str;
    [self.datePicker hideDateTimePickerView];
}

- (void)chooseLocation
{
    DTieChooseLocationController * chosse = [[DTieChooseLocationController alloc] init];
    if (self.choosePOI) {
        chosse.startPoi = self.choosePOI;
    }
    chosse.delegate = self;
    [self.parentDDViewController pushViewController:chosse animated:YES];
}

- (void)chooseLocationDidChoose:(BMKPoiInfo *)poi
{
    self.choosePOI = poi;
    self.locationLabel.text = [NSString stringWithFormat:@"%@%@", poi.address, poi.name];
}

#pragma mark - 选取照片
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos
{
//    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在处理图片" inView:self.parentDDViewController.view];
    
    NSMutableArray * models = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < photos.count; i++) {
        
        UIImage * tmpImg = [photos objectAtIndex:i];
        
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
        
        DTieEditModel * model = [[DTieEditModel alloc] init];
        model.type = DTieEditType_Image;
        model.image = [UIImage imageWithData:data];
        [models addObject:model];
    }
    [self.modleSources insertObjects:models atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.insertIndex, models.count)]];
    [self.tableView reloadData];
//    [hud hideAnimated:YES];
}

- (void)showChoosePhotoPicker
{
    TZImagePickerController * picker = [[TZImagePickerController alloc] initWithMaxImagesCount:100 delegate:self];
    picker.allowPickingOriginalPhoto = NO;
    picker.allowPickingVideo = NO;
    picker.allowTakeVideo = NO;
    picker.showSelectedIndex = YES;
    picker.allowCrop = NO;
    
    [self.parentDDViewController presentViewController:picker animated:YES completion:nil];
}

#pragma mark - 录制小视频
- (void)takeVideo
{
    XFCameraController * camera = [XFCameraController defaultCameraController];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(camera) weakCamera = camera;
    camera.shootCompletionBlock = ^(NSURL *videoUrl, CGFloat videoTimeLength, UIImage *thumbnailImage, NSError *error) {
        
        [weakCamera dismissViewControllerAnimated:YES completion:nil];
        DTieEditModel * model = [[DTieEditModel alloc] init];
        model.type = DTieEditType_Video;
        model.image = thumbnailImage;
        model.videoURL = videoUrl;
        
        [weakSelf.modleSources insertObject:model atIndex:weakSelf.insertIndex];
        [weakSelf.tableView beginUpdates];
        [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.insertIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [weakSelf.tableView endUpdates];
    };
    
    [self.parentDDViewController presentViewController:camera animated:YES completion:nil];
}

#pragma mark - 编辑文字
- (void)showTextEditController
{
    DTieEditTextViewController * edit = [[DTieEditTextViewController alloc] initWithText:@"" placeholder:@"请输入文字"];
    edit.delegate = self;
    [self.parentDDViewController presentViewController:edit animated:YES completion:nil];
}

- (void)DTEditTextDidFinished:(NSString *)text
{
    if (self.currentModel) {
        
        if (isEmptyString(text)) {
            [self.modleSources removeObject:self.currentModel];
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.insertIndex-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
        
    }else{
        
        if (isEmptyString(text)) {
            
        }else{
            DTieEditModel * model = [[DTieEditModel alloc] init];
            model.type = DTieEditType_Text;
            model.detailContent = text;
            
            [self.modleSources insertObject:model atIndex:self.insertIndex];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.insertIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
    }
    self.currentModel = nil;
}

#pragma mark - 添加新的元素
//添加按钮被点击
- (void)addButtonDidClicked:(UIButton *)button
{
    [self showChooseViewWithButton:button insertIndex:0];
}

//展示进行选择添加项
- (void)showChooseViewWithButton:(UIButton *)button insertIndex:(NSInteger)insertIndex;
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.chooseButton = button;
    self.insertIndex = insertIndex;
    self.chooseButton.hidden = YES;
    
    CGRect frame = [button convertRect:button.bounds toView:self];
    CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    
    [self addSubview:self.addChooseView];
    [self.addChooseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.imageButton.center = center;
    self.videoButton.center = center;
    self.textButton.center = center;
    self.tempAddButton.center = center;
    
    CGPoint leftCenter = CGPointMake(center.x - 120 * scale, center.y - 80 * scale);
    CGPoint centerCenter = CGPointMake(center.x, center.y - 130 * scale);
    CGPoint rightCenter = CGPointMake(center.x + 120 * scale, center.y - 80 * scale);
    
    [UIView animateWithDuration:.5f delay:0.f usingSpringWithDamping:.5f initialSpringVelocity:15.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.imageButton.center = leftCenter;
        self.videoButton.center = centerCenter;
        self.textButton.center = rightCenter;
        self.addChooseView.alpha = 1;
        self.tempAddButton.transform = CGAffineTransformMakeRotation(M_PI/4.f);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hiddenChooseView
{
    [self.addChooseView removeFromSuperview];
    self.chooseButton.hidden = NO;
    self.tempAddButton.transform = CGAffineTransformMakeRotation(0);
    self.chooseButton = nil;
}

- (void)createContenView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 684 * scale)];
    
    UILabel * titleLeftView = [DDViewFactoryTool createLabelWithFrame:CGRectMake(0, 0, 186 * scale, 144 * scale) font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x333333) alignment:NSTextAlignmentRight];
    titleLeftView.text = @"标题：";
    self.titleTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.titleTextField.backgroundColor = UIColorFromRGB(0xFFFFFF);
    self.titleTextField.leftView = titleLeftView;
    self.titleTextField.leftViewMode = UITextFieldViewModeAlways;
    [headerView addSubview:self.titleTextField];
    [self.titleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xE0E0E0);
    [self.titleTextField addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(190 * scale);
        make.height.mas_equalTo(3 * scale);
        make.bottom.mas_equalTo(-24 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    
    UIButton * locationButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 144 * scale) font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@""];
    [locationButton addTarget:self action:@selector(chooseLocation) forControlEvents:UIControlEventTouchUpInside];
    locationButton.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:locationButton];
    [locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleTextField.mas_bottom).offset(24 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    
    self.locationLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0XDB6283) alignment:NSTextAlignmentLeft];
    NSString * location = [DDLocationManager shareManager].result.address;
    if (isEmptyString(location)) {
        self.locationLabel.text = @"请选择当前位置";
    }else{
        self.locationLabel.text = location;
    }
    [locationButton addSubview:self.locationLabel];
    [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-180 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(50 * scale);
    }];
    
    UIImageView * locationImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"locationEdit"]];
    [locationButton addSubview:locationImageView];
    [locationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
        make.width.height.mas_equalTo(72 * scale);
    }];
    
    UIButton * timeButton = [DDViewFactoryTool createButtonWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 144 * scale) font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@""];
    [timeButton addTarget:self action:@selector(timeViewDidTap) forControlEvents:UIControlEventTouchUpInside];
    timeButton.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:timeButton];
    [timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(locationButton.mas_bottom).offset(24 * scale);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(144 * scale);
    }];
    
    self.timeLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0XDB6283) alignment:NSTextAlignmentLeft];
    NSString * time = [DDTool getCurrentTimeWithFormat:@"yyyy年MM月dd日 HH:mm"];
    if (isEmptyString(location)) {
        self.timeLabel.text = @"请选择时间";
    }else{
        self.timeLabel.text = time;
    }
    [timeButton addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60 * scale);
        make.right.mas_equalTo(-180 * scale);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(50 * scale);
    }];
    
    UIImageView * timeImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage imageNamed:@"timeEdit"]];
    [timeButton addSubview:timeImageView];
    [timeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-60 * scale);
        make.width.height.mas_equalTo(72 * scale);
    }];
    
    UIButton * addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setImage:[UIImage imageNamed:@"addEdit"] forState:UIControlStateNormal];
    [headerView addSubview:addButton];
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(timeButton.mas_bottom).offset(34 * scale);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(72 * scale);
    }];
    [addButton addTarget:self action:@selector(addButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView = [[RTDragCellTableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    self.tableView.rowHeight = 408 * scale;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[DTieNewEditImageCell class] forCellReuseIdentifier:@"DTieNewEditImageCell"];
    [self.tableView registerClass:[DTieNewEditVideoCell class] forCellReuseIdentifier:@"DTieNewEditVideoCell"];
    [self.tableView registerClass:[DTieNewEditTextCell class] forCellReuseIdentifier:@"DTieNewEditTextCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 324 * scale, 0);
    
    UISwipeGestureRecognizer * swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewDidSwipe:)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.tableView addGestureRecognizer:swipe];
    
    self.tableView.tableHeaderView = headerView;
    
    [self createChooseView];
}

- (void)createChooseView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenChooseView)];
    self.addChooseView = [[UIView alloc] initWithFrame:self.bounds];
    self.addChooseView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
    [self.addChooseView addGestureRecognizer:tap];
    
    self.imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.imageButton setImage:[UIImage imageNamed:@"imageChoose"] forState:UIControlStateNormal];
    [self.addChooseView addSubview:self.imageButton];
    self.imageButton.frame = CGRectMake(0, 0, 120 * scale, 120 * scale);
    self.imageButton.center = self.addChooseView.center;
    [self.imageButton addTarget:self action:@selector(imageButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.videoButton setImage:[UIImage imageNamed:@"videoChoose"] forState:UIControlStateNormal];
    [self.addChooseView addSubview:self.videoButton];
    self.videoButton.frame = CGRectMake(0, 0, 120 * scale, 120 * scale);
    self.videoButton.center = self.addChooseView.center;
    [self.videoButton addTarget:self action:@selector(videoButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.textButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.textButton setImage:[UIImage imageNamed:@"textChoose"] forState:UIControlStateNormal];
    [self.addChooseView addSubview:self.textButton];
    self.textButton.frame = CGRectMake(0, 0, 120 * scale, 120 * scale);
    self.textButton.center = self.addChooseView.center;
    [self.textButton addTarget:self action:@selector(textButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.tempAddButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.tempAddButton setImage:[UIImage imageNamed:@"addEdit"] forState:UIControlStateNormal];
    [self.addChooseView addSubview:self.tempAddButton];
    self.tempAddButton.frame = CGRectMake(0, 0, 72 * scale, 72 * scale);
    self.tempAddButton.center = self.addChooseView.center;
    [self.tempAddButton addTarget:self action:@selector(hiddenChooseView) forControlEvents:UIControlEventTouchUpInside];
    
    self.createTime = [[NSDate date] timeIntervalSince1970] * 1000;
    self.timeLabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.createTime];
    
    if (self.editDTModel) {
        [self reloadWithEditModel];
    }
}

#pragma mark - 左滑删除
- (void)tableViewDidSwipe:(UISwipeGestureRecognizer *)swipe
{
    CGPoint point = [swipe locationInView:self.tableView];
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if (indexPath && indexPath.row < self.modleSources.count) {
        
        [self.modleSources removeObjectAtIndex:indexPath.row];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    }
}

#pragma mark - 当时草稿进来时，需要将页面刷新止草稿本来的状态
- (void)reloadWithEditModel
{
    self.titleTextField.text = self.editDTModel.postSummary;
    if (self.editDTModel.sceneTime > 0) {
        self.createTime = self.editDTModel.sceneTime;
        self.timeLabel.text = [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:self.editDTModel.sceneTime];
    }
    self.locationLabel.text = self.editDTModel.sceneAddress;
    BMKPoiInfo * poi = [[BMKPoiInfo alloc] init];
    poi.pt = CLLocationCoordinate2DMake(self.editDTModel.sceneAddressLat, self.editDTModel.sceneAddressLng);
    self.choosePOI = poi;
}

- (void)imageButtonDidClicked
{
    [self showChoosePhotoPicker];
    [self hiddenChooseView];
}

- (void)videoButtonDidClicked
{
    [self takeVideo];
    [self hiddenChooseView];
}

- (void)textButtonDidClicked
{
    [self showTextEditController];
    [self hiddenChooseView];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTieEditModel * model = [self.modleSources objectAtIndex:indexPath.row];
    if (model.type == DTieEditType_Image) {
        if (model.image) {
            LookImageViewController * lookImage = [[LookImageViewController alloc] initWithImage:model.image];
            [self.parentDDViewController presentViewController:lookImage animated:YES completion:nil];
        }else{
            LookImageViewController * lookImage = [[LookImageViewController alloc] initWithImageURL:model.detailContent];
            [self.parentDDViewController presentViewController:lookImage animated:YES completion:nil];
        }
    }else if (model.type == DTieEditType_Video) {
        
        NSURL * url = nil;
        if (model.videoURL) {
            url = model.videoURL;
        }else{
            url = [NSURL URLWithString:model.detailContent];
        }
        
        AVPlayerViewController * player = [[AVPlayerViewController alloc] init];
        player.videoGravity = AVLayerVideoGravityResizeAspect;
        player.player = [[AVPlayer alloc] initWithURL:url];
        [self.parentDDViewController presentViewController:player animated:YES completion:nil];
    }else{
        DTieEditTextViewController * text = [[DTieEditTextViewController alloc] initWithText:model.detailsContent placeholder:@"请输入文字"];
        text.delegate = self;
        [self.parentDDViewController presentViewController:text animated:YES completion:nil];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.modleSources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTieEditModel * model = [self.modleSources objectAtIndex:indexPath.row];
    if (model.type == DTieEditType_Image) {
        DTieNewEditImageCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieNewEditImageCell" forIndexPath:indexPath];
        
        [cell configWithModel:model];
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(cell) weakCell = cell;
        cell.addButtonHandle = ^{
            
            NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
            [weakSelf showChooseViewWithButton:weakCell.addButton insertIndex:indexPath.row+1];
        };
        
        return cell;
    }else if(model.type == DTieEditType_Video){
        DTieNewEditVideoCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieNewEditVideoCell" forIndexPath:indexPath];
        
        [cell configWithModel:model];
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(cell) weakCell = cell;
        cell.addButtonHandle = ^{
            
            NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
            [weakSelf showChooseViewWithButton:weakCell.addButton insertIndex:indexPath.row+1];
        };
        
        return cell;
    }
    
    DTieNewEditTextCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieNewEditTextCell" forIndexPath:indexPath];
    
    [cell configWithModel:model];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(cell) weakCell = cell;
    cell.addButtonHandle = ^{
        
        NSIndexPath * indexPath = [weakSelf.tableView indexPathForCell:weakCell];
        [weakSelf showChooseViewWithButton:weakCell.addButton insertIndex:indexPath.row+1];
    };
    
    return cell;
}

- (NSArray *)originalArrayDataForTableView:(RTDragCellTableView *)tableView
{
    return self.modleSources;
}

- (void)tableView:(RTDragCellTableView *)tableView newArrayDataForDataSource:(NSArray *)newArray
{
    [self.modleSources removeAllObjects];
    [self.modleSources addObjectsFromArray:newArray];
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

- (NSMutableArray *)modleSources
{
    if (!_modleSources) {
        _modleSources = [[NSMutableArray alloc] init];
    }
    return _modleSources;
}

//- (TZImagePickerController *)picker
//{
//    if (!_picker) {
//        _picker = [[TZImagePickerController alloc] initWithMaxImagesCount:100 delegate:self];
//        _picker.allowPickingOriginalPhoto = NO;
//        _picker.allowPickingVideo = NO;
//        _picker.allowTakeVideo = NO;
//        _picker.showSelectedIndex = YES;
//        _picker.allowCrop = NO;
//    }
//    return _picker;
//}
//
//- (NSMutableArray *)selectPHAsset
//{
//    if (!_selectPHAsset) {
//        _selectPHAsset = [[NSMutableArray alloc] init];
//    }
//    return _selectPHAsset;
//}

@end
