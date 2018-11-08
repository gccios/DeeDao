//
//  ChooseImageViewController.m
//  DeeDao
//
//  Created by 郭春城 on 2018/8/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "ChooseImageViewController.h"
#import "ChooseImageCollectionViewCell.h"
#import <TZImagePickerController.h>
#import "DDBackWidow.h"

@interface ChooseImageViewController () <UICollectionViewDelegate, UICollectionViewDataSource, TZImagePickerControllerDelegate>

@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UIImage * currentImage;

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSArray * imageNameArray;

@end

@implementation ChooseImageViewController

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super init]) {
        self.currentImage = image;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageNameArray = @[@"xiangji", @"default2.jpg", @"default3.jpg", @"default4.jpg", @"default1.jpg"];
    
    [self createViews];
    [self createTopView];
}

- (void)createViews
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.view.backgroundColor = UIColorFromRGB(0x111111);
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(264 * scale, 240 * scale);
    layout.minimumLineSpacing = 60 * scale;
    layout.minimumInteritemSpacing = 60 * scale;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerClass:[ChooseImageCollectionViewCell class] forCellWithReuseIdentifier:@"ChooseImageCollectionViewCell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = UIColorFromRGB(0x333333);
    self.collectionView.contentInset = UIEdgeInsetsMake(48 * scale, 60 * scale, 48 * scale, 60 * scale);
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(336 * scale);
    }];
    
    self.imageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:self.currentImage];
    self.imageView.clipsToBounds = YES;
    [self.view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo((220 + kStatusBarHeight) * scale);
        make.bottom.mas_equalTo(-336 * scale);
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageNameArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ChooseImageCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ChooseImageCollectionViewCell" forIndexPath:indexPath];
    
    [cell configWithImageName:[self.imageNameArray objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        TZImagePickerController * picker = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
        picker.allowPickingOriginalPhoto = NO;
        picker.allowPickingVideo = NO;
        picker.allowTakeVideo = NO;
        picker.showSelectedIndex = NO;
        picker.allowCrop = NO;
        
        [self.navigationController presentViewController:picker animated:YES completion:nil];
        [[DDBackWidow shareWindow] hidden];
        
    }else{
        NSString * imageName = [self.imageNameArray objectAtIndex:indexPath.row];
        self.currentImage = [UIImage imageNamed:imageName];
        [self.imageView setImage:self.currentImage];
    }
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos
{
    if (photos) {
        self.currentImage = photos.firstObject;
        [self.imageView setImage:self.currentImage];
        if (self.chooseImageHandle) {
            self.chooseImageHandle(self.currentImage);
        }
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)createTopView
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.topView = [[UIView alloc] init];
    self.topView.userInteractionEnabled = YES;
    self.topView.backgroundColor = UIColorFromRGB(0x333333);
    [self.view addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo((220 + kStatusBarHeight) * scale);
    }];
    
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
    titleLabel.text = @"选择封面";
    [self.topView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backButton.mas_right).mas_equalTo(5 * scale);
        make.height.mas_equalTo(64 * scale);
        make.bottom.mas_equalTo(-37 * scale);
    }];
    
    UIButton * cancleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xFFFFFF) backgroundColor:[UIColor clearColor] title:DDLocalizedString(@"Yes")];
    [DDViewFactoryTool cornerRadius:12 * scale withView:cancleButton];
    cancleButton.layer.borderWidth = .5f;
    cancleButton.layer.borderColor = UIColorFromRGB(0xFFFFFF).CGColor;
    [cancleButton addTarget:self action:@selector(cancleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:cancleButton];
    [cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(190 * scale);
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
    if (self.chooseImageHandle) {
        self.chooseImageHandle(self.currentImage);
    }
    [self backButtonDidClicked];
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
