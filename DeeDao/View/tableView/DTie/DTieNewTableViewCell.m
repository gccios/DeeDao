//
//  DTieNewTableViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/11/13.
//  Copyright © 2018 郭春城. All rights reserved.
//

#import "DTieNewTableViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "DDTool.h"
#import "UserManager.h"
#import "DDLocationManager.h"
#import "MBProgressHUD+DDHUD.h"
#import "DDLGSideViewController.h"
#import "DTieDetailRequest.h"
#import "QNDDUploadManager.h"
#import "CreateDTieRequest.h"
#import <TZImagePickerController.h>

@interface DTieNewTableViewCell ()<TZImagePickerControllerDelegate>

@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, strong) UIImageView * postImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * poiLabel;
@property (nonatomic, strong) UILabel * statusLabel;
@property (nonatomic, strong) UILabel * postTitleLabel;

@property (nonatomic, strong) UIButton * leftButton;
@property (nonatomic, strong) UIButton * rightButton;

@property (nonatomic, strong) UILabel * infoLabel;

@end

@implementation DTieNewTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createFanjuCell];
    }
    return self;
}

- (void)configWithModel:(DTieModel *)model
{
    self.model = model;
    [self.postImageView sd_setImageWithURL:[NSURL URLWithString:model.postFirstPicture]];
    self.postTitleLabel.text = model.postSummary;
    
    NSString * build = model.sceneBuilding;
    if (isEmptyString(build)) {
        build = @"";
    }
    
    self.infoLabel.text = [NSString stringWithFormat:@"%@", [DDTool getTimeWithFormat:@"yyyy年MM月dd日 HH:mm" time:model.sceneTime]];
    self.nameLabel.text = model.nickname;
    self.poiLabel.text = model.sceneBuilding;
    
    if (self.model.subType == 1) {
        self.statusLabel.text = DDLocalizedString(@"Attend");
    }else{
        if (self.model.subType == 0) {
            self.statusLabel.text = DDLocalizedString(@"TBD");
        }else if (self.model.subType == 2) {
            self.statusLabel.text = DDLocalizedString(@"OutFollow");
        }
    }
    
    if (self.model.authorId == [UserManager shareManager].user.cid) {
        self.rightButton.hidden = NO;
    }else{
        self.rightButton.hidden = YES;
    }
}

- (void)createFanjuCell
{
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    self.infoLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(38 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.infoLabel];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40 * scale);
        make.left.mas_equalTo(60 * scale);
        make.height.mas_equalTo(50 * scale);
        make.right.mas_equalTo(-60 * scale);
    }];
    
    UIView * BGView = [[UIView alloc] initWithFrame:CGRectZero];
    BGView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:BGView];
    BGView.layer.cornerRadius = 24 * scale;
    BGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    BGView.layer.shadowOpacity = .3f;
    BGView.layer.shadowRadius = 8 * scale;
    BGView.layer.shadowOffset = CGSizeMake(0, 8 * scale);
    [BGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(140 * scale);
        make.left.mas_equalTo(60 * scale);
        make.width.height.mas_equalTo(240 * scale);
    }];
    
    self.postImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [BGView addSubview:self.postImageView];
    [self.postImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.postImageView];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangMedium(48 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(BGView.mas_right).offset(25 * scale);
        make.top.mas_equalTo(BGView);
        make.right.mas_equalTo(-30 * scale);
    }];
    
    self.poiLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.poiLabel];
    [self.poiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(0 * scale);
        make.left.mas_equalTo(self.nameLabel);
        make.right.mas_equalTo(self.nameLabel);
    }];
    
    self.postTitleLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0x666666) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.postTitleLabel];
    [self.postTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.poiLabel.mas_bottom).offset(-5 * scale);
        make.left.mas_equalTo(self.poiLabel);
        make.right.mas_equalTo(self.poiLabel);
    }];
    
    self.statusLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(42 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.statusLabel];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.postTitleLabel.mas_bottom).offset(0 * scale);
        make.left.mas_equalTo(self.postTitleLabel);
        make.right.mas_equalTo(self.postTitleLabel);
    }];
    self.statusLabel.hidden = YES;
    
    self.leftButton = [DDViewFactoryTool createButtonWithFrame: CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"导航/拷贝POI"];
    [self.contentView addSubview:self.leftButton];
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(-kMainBoundsWidth / 4.f);
        make.width.mas_equalTo(444 * scale);
        make.height.mas_equalTo(120 * scale);
        make.top.mas_equalTo(self.postImageView.mas_bottom).offset(60 * scale);
    }];
    [DDViewFactoryTool cornerRadius:60 * scale withView:self.leftButton];
    self.leftButton.layer.borderWidth = 3 * scale;
    self.leftButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    [self.leftButton addTarget:self action:@selector(leftButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.rightButton = [DDViewFactoryTool createButtonWithFrame: CGRectZero font:kPingFangRegular(42 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"一键加照片"];
    [self.contentView addSubview:self.rightButton];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(kMainBoundsWidth / 4.f);
        make.width.mas_equalTo(444 * scale);
        make.height.mas_equalTo(120 * scale);
        make.top.mas_equalTo(self.postImageView.mas_bottom).offset(60 * scale);
    }];
    [DDViewFactoryTool cornerRadius:60 * scale withView:self.rightButton];
    self.rightButton.layer.borderWidth = 3 * scale;
    self.rightButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    [self.rightButton addTarget:self action:@selector(rightButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(20 * scale);
    }];
}

- (void)leftButtonDidClicked
{
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    
    [[DDLocationManager shareManager] mapNavigationToLongitude:self.model.sceneAddressLng latitude:self.model.sceneAddressLat poiName:self.model.sceneBuilding withViewController:na];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.model.sceneBuilding;
    [MBProgressHUD showTextHUDWithText:@"地址已复制到粘贴板" inView:na.view];
}

- (void)rightButtonDidClicked
{
    [self uploadPhotoWithModel:self.model];
}

- (void)uploadPhotoWithModel:(DTieModel *)model
{
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:[UIApplication sharedApplication].keyWindow];
    
    NSInteger postID = model.cid;
    if (postID == 0) {
        postID = model.postId;
    }
    
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:postID type:4 start:0 length:10];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        
        if (KIsDictionary(response)) {
            
            NSInteger code = [[response objectForKey:@"status"] integerValue];
            if (code == 4002) {
                [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"PageHasDelete") inView:[UIApplication sharedApplication].keyWindow];
                
                return;
            }
            
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                DTieModel * dtieModel = [DTieModel mj_objectWithKeyValues:data];
                
                if (dtieModel.deleteFlg == 1) {
                    [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"PageHasDelete") inView:[UIApplication sharedApplication].keyWindow];
                    
                    return;
                }
                
                if (dtieModel.landAccountFlg == 2 && dtieModel.authorId != [UserManager shareManager].user.cid) {
                    [MBProgressHUD showTextHUDWithText:@"该帖已被作者设为私密状态" inView:[UIApplication sharedApplication].keyWindow];
                    return;
                }
                
                self.model = dtieModel;
                
                TZImagePickerController * picker = [[TZImagePickerController alloc] initWithMaxImagesCount:100 delegate:self];
                picker.allowPickingOriginalPhoto = NO;
                picker.allowPickingVideo = NO;
                picker.showSelectedIndex = YES;
                picker.allowCrop = NO;
                [na presentViewController:picker animated:YES completion:nil];
                
            }else{
                NSString * msg = [response objectForKey:@"msg"];
                if (!isEmptyString(msg)) {
                    [MBProgressHUD showTextHUDWithText:msg inView:[UIApplication sharedApplication].keyWindow];
                }
            }
        }
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
    }];
}

#pragma mark - 选取照片
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos
{
    if (picker.showSelectedIndex) {
        
        NSMutableArray * details = [[NSMutableArray alloc] init];
        
        MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在上传" inView:[UIApplication sharedApplication].keyWindow];
        QNDDUploadManager * manager = [[QNDDUploadManager alloc] init];
        
        __block NSInteger count = 0;
        NSInteger totalCount = photos.count+self.model.details.count;
        for (NSInteger i = self.model.details.count; i < totalCount; i++) {
            
            UIImage * image = [photos objectAtIndex:i-self.model.details.count];
            
            [manager uploadImage:image progress:^(NSString *key, float percent) {
                
            } success:^(NSString *url) {
                
                NSDictionary * dict = @{@"detailNumber":[NSString stringWithFormat:@"%ld", i+1],
                                        @"datadictionaryType":@"CONTENT_IMG",
                                        @"detailsContent":url,
                                        @"textInformation":@"",
                                        @"pFlag":@(0),
                                        @"wxCansee":@(1),
                                        @"authorID":@([UserManager shareManager].user.cid)};
                [details addObject:dict];
                count++;
                if (count == photos.count) {
                    [hud hideAnimated:YES];
                    [self uploadWithPhotos:details];
                }
                
            } failed:^(NSError *error) {
                if (count == photos.count) {
                    [hud hideAnimated:YES];
                    [self uploadWithPhotos:details];
                }
            }];
        }
        
        
    }
}

- (void)uploadWithPhotos:(NSMutableArray *)details
{
    [details sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSInteger detailNumber1 = [[obj1 objectForKey:@"detailNumber"] integerValue];
        NSInteger detailNumber2 = [[obj2 objectForKey:@"detailNumber"] integerValue];
        if (detailNumber1 > detailNumber2) {
            return NSOrderedDescending;
        }else if (detailNumber1 < detailNumber2) {
            return NSOrderedAscending;
        }else{
            return NSOrderedSame;
        }
    }];
    
    NSInteger postID = self.model.cid;
    if (postID == 0) {
        postID = self.model.postId;
    }
    
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在添加照片" inView:[UIApplication sharedApplication].keyWindow];
    CreateDTieRequest * request = [[CreateDTieRequest alloc] initAddWithPostID:self.model.cid blocks:details];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (self.model.details.count == 0) {
            self.model.details = [NSArray arrayWithArray:[DTieEditModel mj_objectArrayWithKeyValuesArray:details]];
        }else{
            NSMutableArray * data = [[NSMutableArray alloc] initWithArray:self.model.details];
            [data addObjectsFromArray:[DTieEditModel mj_objectArrayWithKeyValuesArray:details]];
            self.model.details = [NSArray arrayWithArray:data];
        }
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"上传成功" inView:self];
        
        [self configWithModel:self.model];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"上传失败" inView:self];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"上传失败" inView:self];
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
