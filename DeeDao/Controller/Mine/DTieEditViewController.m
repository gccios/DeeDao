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

@interface DTieEditViewController () <UITableViewDelegate, UITableViewDataSource, DTEditTextViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UIButton * saveButton;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, strong) NSMutableArray * moduleSource;

@property (nonatomic, strong) UILongPressGestureRecognizer * longPressGesture;
@property (nonatomic, strong) NSIndexPath * selectIndexPath;
@property (nonatomic, strong) UIView * longPressView;

@property (nonatomic, strong) NSIndexPath * currentEditIndex;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end

@implementation DTieEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createDataSource];
    [self createViews];
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
    [self createTopView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.tableView registerClass:[DTieEditTableViewCell class] forCellReuseIdentifier:@"DTieEditTableViewCell"];
    [self.tableView registerClass:[DTieEditTextTableViewCell class] forCellReuseIdentifier:@"DTieEditTextTableViewCell"];
    [self.tableView registerClass:[DTieEditImageTableViewCell class] forCellReuseIdentifier:@"DTieEditImageTableViewCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom).offset(0);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
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
    
//    if (_edgeScrollTimer) {
//        [_edgeScrollTimer invalidate];
//        _edgeScrollTimer = nil;
//    }
}

- (void)longGestureChanged:(UILongPressGestureRecognizer *)longGesture
{
    CGPoint point = [longGesture locationInView:self.tableView];
    NSIndexPath *currentIndexPath = [self.tableView indexPathForRowAtPoint:point];
    CGFloat pointY = [self tempViewYToFitTargetY:point.y];
    self.longPressView.center = CGPointMake(self.longPressView.center.x, pointY);
    
    if (currentIndexPath && ![self.selectIndexPath isEqual:currentIndexPath] && currentIndexPath.section) {
        [self.moduleSource exchangeObjectAtIndex:currentIndexPath.row withObjectAtIndex:self.selectIndexPath.row];
        [self.tableView moveRowAtIndexPath:self.selectIndexPath toIndexPath:currentIndexPath];
        self.selectIndexPath = currentIndexPath;
    }
//
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
    
//    _edgeScrollTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(processEdgeScroll)];
//    [_edgeScrollTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)processEdgeScroll
{
    [self longGestureChanged:self.longPressGesture];
    
    CGFloat minOffsetY = self.tableView.contentOffset.y + 100.f;
    CGFloat maxOffsetY = self.tableView.contentOffset.y + self.tableView.bounds.size.height - 100.f;
    CGPoint touchPoint = self.longPressView.center;
    
    //处理上下达到极限之后不再滚动tableView，其中处理了滚动到最边缘的时候，当前处于edgeScrollRange内，但是tableView还未显示完，需要显示完tableView才停止滚动
    if (touchPoint.y < 100.f) {
        if (self.tableView.contentOffset.y <= 0) {
            return;
        }else {
            if (self.tableView.contentOffset.y - 1 < 0) {
                return;
            }
            [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y - 1) animated:NO];
            self.longPressView.center = CGPointMake(self.longPressView.center.x, [self tempViewYToFitTargetY:self.longPressView.center.y - 1]);
        }
    }
    if (touchPoint.y > self.tableView.contentSize.height - 100.f) {
        if (self.tableView.contentOffset.y >= self.tableView.contentSize.height - self.tableView.bounds.size.height) {
            return;
        }else {
            if (self.tableView.contentOffset.y + 1 > self.tableView.contentSize.height - self.tableView.bounds.size.height) {
                return;
            }
            [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + 1) animated:NO];
            self.longPressView.center = CGPointMake(self.longPressView.center.x, [self tempViewYToFitTargetY:self.longPressView.center.y + 1]);
        }
    }
    
    //处理滚动
    CGFloat maxMoveDistance = 5;
    if (touchPoint.y < minOffsetY) {
        //cell在往上移动
        CGFloat moveDistance = (minOffsetY - touchPoint.y)/100.f*maxMoveDistance;
        [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y - moveDistance) animated:NO];
        self.longPressView.center = CGPointMake(self.longPressView.center.x, [self tempViewYToFitTargetY:self.longPressView.center.y - moveDistance]);
    }else if (touchPoint.y > maxOffsetY) {
        //cell在往下移动
        CGFloat moveDistance = (touchPoint.y - maxOffsetY)/100.f*maxMoveDistance;
        [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + moveDistance) animated:NO];
        self.longPressView.center = CGPointMake(self.longPressView.center.x, [self tempViewYToFitTargetY:self.longPressView.center.y + moveDistance]);
    }
}

- (void)DTEditTextDidFinished:(NSString *)text
{
    NSArray * data = [self.dataSource objectAtIndex:self.currentEditIndex.section];;
    DTieEditModel * model = [data objectAtIndex:self.currentEditIndex.row];
    
    if (model.type == DTieEditType_Title || model.type == DTieEditType_Text) {
        model.text = text;
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
            [cell configWithEditModel:model];
            return cell;
        }
            break;
            
        case DTieEditType_Text:
        {
            DTieEditTextTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieEditTextTableViewCell" forIndexPath:indexPath];
            [cell configWithEditModel:model];
            return cell;
        }
            break;
            
        case DTieEditType_Image:
        {
            DTieEditImageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieEditImageTableViewCell" forIndexPath:indexPath];
            [cell configWithEditModel:model];
            return cell;
        }
            break;
            
        case DTieEditType_Video:
        {
            DTieEditImageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieEditImageTableViewCell" forIndexPath:indexPath];
            [cell configWithEditModel:model];
            return cell;
        }
            break;
            
        default:
            break;
    }
    
    DTieEditTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieEditTableViewCell" forIndexPath:indexPath];
    
    [cell configWithEditModel:model];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    return 120 * scale;
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
        DTieEditFooterView * view = [[DTieEditFooterView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 370 * kMainBoundsWidth / 1080.f)];
        [view.AddButton addTarget:self action:@selector(addMoudle) forControlEvents:UIControlEventTouchUpInside];
        return view;
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
            DTieEditTextViewController * text = [[DTieEditTextViewController alloc] initWithText:model.text placeholder:@"写个标题..."];
            text.delegate = self;
            [self.navigationController pushViewController:text animated:YES];
        }
            break;
            
        case DTieEditType_Text:
            
        {
            DTieEditTextViewController * text = [[DTieEditTextViewController alloc] initWithText:model.text placeholder:@"写个标题..."];
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
        model.videoURL = videoUrl.absoluteString;
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[self.currentEditIndex] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    };
    
    [self.navigationController presentViewController:camera animated:YES completion:nil];
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
        
        DTieEditModel * model = [self.moduleSource objectAtIndex:self.currentEditIndex.row];
        model.image = tmpImg;
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[self.currentEditIndex] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    self.saveButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] title:@"发布"];
    [DDViewFactoryTool cornerRadius:12 * scale withView:self.saveButton];
    self.saveButton.layer.borderWidth = .5f;
    self.saveButton.layer.borderColor = UIColorFromRGB(0xFFFFFF).CGColor;
    [self.saveButton addTarget:self action:@selector(saveButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.saveButton];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(144 * scale);
        make.height.mas_equalTo(72 * scale);
        make.centerY.mas_equalTo(titleLabel);
        make.right.mas_equalTo(-60 * scale);
    }];
}

- (void)backButtonDidClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveButtonDidClicked
{
    NSLog(@"保存");
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
        _imagePickerController.allowsEditing = YES;
    }
    return _imagePickerController;
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
