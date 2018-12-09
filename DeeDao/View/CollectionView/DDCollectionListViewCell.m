//
//  DDCollectionListViewCell.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/16.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDCollectionListViewCell.h"
#import "DDViewFactoryTool.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "DTieDetailRequest.h"
#import "DTieImageCollectionViewCell.h"
#import "DTieTextCollectionViewCell.h"
#import "DTieVideoCollectionViewCell.h"
#import "DTiePostCollectionViewCell.h"
#import "DTieTitleCollectionViewCell.h"
#import "DDLocationManager.h"
#import "TYCyclePagerView.h"
#import "UserManager.h"
#import "MBProgressHUD+DDHUD.h"
#import "DTieCancleWYYRequest.h"
#import "DTieCancleCollectRequest.h"
#import "DTieCollectionRequest.h"
#import "DDDazhaohuView.h"
#import "UserInfoViewController.h"
#import "DDYaoYueViewController.h"
#import "DDTool.h"
#import "DDDaZhaoHuViewController.h"
#import "DDLGSideViewController.h"
#import "RDAlertView.h"
#import <TZImagePickerController.h>
#import "QNDDUploadManager.h"
#import "CreateDTieRequest.h"
#import "YueFanViewController.h"
#import "DDDazhaohuView.h"

@interface DDCollectionListViewCell ()<UITableViewDelegate, UITableViewDataSource, TZImagePickerControllerDelegate>

@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UILabel * nameLabel;

@property (nonatomic, strong) UIButton * handleButton;
@property (nonatomic, strong) UIButton * leftButton;
@property (nonatomic, strong) UIButton * centerButton;
@property (nonatomic, strong) UIButton * rightButton;

@property (nonatomic, strong) DTieModel * model;
@property (nonatomic, assign) BOOL isFirstRead;
@property (nonatomic, assign) NSIndexPath * firestIndex;
@property (nonatomic, strong) UIView * baseView;

@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, strong) DTieDetailRequest * request;
@property (nonatomic, strong) UILabel * shoucangNumberLabel;

@end

@implementation DDCollectionListViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createListViewCell];
    }
    return self;
}

- (void)leftButtonDidClicked
{
    if (self.model.authorId == [UserManager shareManager].user.cid) {
        RDAlertView * alert = [[RDAlertView alloc] initWithTitle:@"删除提示" message:@"是否确定删除该帖子？"];
        RDAlertAction * action1 = [[RDAlertAction alloc] initWithTitle:@"取消" handler:^{
            
        } bold:NO];
        RDAlertAction * action2 = [[RDAlertAction alloc] initWithTitle:@"确定" handler:^{
            
            if (self.deleteClickHandle) {
                self.deleteClickHandle();
            }
            
        } bold:NO];
        [alert addActions:@[action1, action2]];
        [alert show];
    }else{
        if (self.model.wyyFlg) {
            [DTieCancleWYYRequest cancelRequest];
            DTieCancleWYYRequest * request = [[DTieCancleWYYRequest alloc] initWithPostID:self.model.cid];
            [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
                self.model.wyyFlg = 0;
                self.model.wyyCount--;
                [self reloadStatus];
                
            } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
            } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
                
            }];
            
        }else{
            [DTieCollectionRequest cancelRequest];
            DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:self.model.cid type:1 subType:0 remark:@""];
            
            [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
                self.model.wyyFlg = 1;
                self.model.wyyCount++;
                [MBProgressHUD showTextHUDWithText:@"您刚标识了您想约这里。约点越多，被约越多。Deedao好友越多，被约越多。记得常去约饭约玩活地图 组饭局哦。" inView:[UIApplication sharedApplication].keyWindow];
                
                [self reloadStatus];
            } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                
            } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
                
            }];
        }
    }
}

- (void)centerButtonDidClicked
{
    if (self.model.authorId == [UserManager shareManager].user.cid) {
        [self uploadPhoto];
    }else{
        if ([[DDLocationManager shareManager] postIsCanDazhaohuWith:self.model]) {
            DDDazhaohuView * view = [[DDDazhaohuView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            view.block = ^(NSString *text) {
                
                [DTieCollectionRequest cancelRequest];
                DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:self.model.cid type:2 subType:1 remark:text];
                
                [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                    
                    self.model.dzfFlg = 1;
                    self.model.dzfCount++;
                    [self reloadStatus];
                    
                    [MBProgressHUD showTextHUDWithText:@"对方已收到您的信息" inView:[UIApplication sharedApplication].keyWindow];
                } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
                    
                } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
                    
                }];
            };
            [view show];
        }
    }
}

- (void)rightButtonDidClicked
{
    BMKPoiInfo * poi = [[BMKPoiInfo alloc] init];
    poi.pt = CLLocationCoordinate2DMake(self.model.sceneAddressLat, self.model.sceneAddressLng);
    poi.address = self.model.sceneAddress;
    poi.name = self.model.sceneBuilding;
    
    YueFanViewController * yuefan = [[YueFanViewController alloc] initWithBMKPoiInfo:poi friendArray:[NSMutableArray new]];
    
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    
    [na pushViewController:yuefan animated:YES];
}

- (void)handleButtonDidClicked
{
    if (self.model.wyyFlg) {
        [DTieCancleWYYRequest cancelRequest];
        DTieCancleWYYRequest * request = [[DTieCancleWYYRequest alloc] initWithPostID:self.model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            self.model.wyyFlg = 0;
            self.model.wyyCount--;
            [self reloadStatus];
            
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
        }];
        
    }else{
        [DTieCollectionRequest cancelRequest];
        DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:self.model.cid type:1 subType:0 remark:@""];
        
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            self.model.wyyFlg = 1;
            self.model.wyyCount++;
            [MBProgressHUD showTextHUDWithText:@"您刚标识了您想约这里。约点越多，被约越多。Deedao好友越多，被约越多。记得常去约饭约玩活地图 组饭局哦。" inView:[UIApplication sharedApplication].keyWindow];
            
            [self reloadStatus];
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
        }];
    }
}

- (void)uploadPhoto
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:[UIApplication sharedApplication].keyWindow];
    
    DTieDetailRequest * request = [[DTieDetailRequest alloc] initWithID:self.model.cid type:4 start:0 length:10];
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
                
                self.model = [DTieModel mj_objectWithKeyValues:data];
                
                TZImagePickerController * picker = [[TZImagePickerController alloc] initWithMaxImagesCount:100 delegate:self];
                picker.allowPickingOriginalPhoto = NO;
                picker.allowPickingVideo = NO;
                picker.showSelectedIndex = YES;
                picker.allowCrop = NO;
                
                DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                UINavigationController * na = (UINavigationController *)lg.rootViewController;
                
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
                                    @"authorID":@([UserManager shareManager].user.cid)
                                    };
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
        
        if (isEmptyString(self.model.postFirstPicture) && details.count > 0) {
            NSDictionary * dict = [details firstObject];
            self.model.postFirstPicture = [dict objectForKey:@"detailsContent"];
        }
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"上传成功" inView:self];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"上传失败" inView:[UIApplication sharedApplication].keyWindow];
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"上传失败" inView:[UIApplication sharedApplication].keyWindow];
    }];
}

- (void)dazhaohuButtonDidClicked:(UIButton *)button
{
    DTieModel * model = self.model;
    
    if (model.authorId == [UserManager shareManager].user.cid) {
        
        DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        UINavigationController * na = (UINavigationController *)lg.rootViewController;
        DDDaZhaoHuViewController * dazhaohu = [[DDDaZhaoHuViewController alloc] initWithDTieModel:self.model];
        [na pushViewController:dazhaohu animated:YES];
        
        return;
    }
    
    if (model.dzfFlg == 1) {
        [MBProgressHUD showTextHUDWithText:@"您已经打过招呼了" inView:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
    BOOL canHandle = [[DDLocationManager shareManager] postIsCanDazhaohuWith:model];
    if (!canHandle) {
        [MBProgressHUD showTextHUDWithText:[NSString stringWithFormat:@"只能和%ld米之内的的帖子打招呼", [DDLocationManager shareManager].distance] inView:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
    DDDazhaohuView * view = [[DDDazhaohuView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.block = ^(NSString *text) {
        button.enabled = NO;
        
        DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:model.cid type:2 subType:1 remark:@""];
        
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            model.dzfFlg = 1;
            model.dzfCount++;
            [self reloadStatus];
            
            button.enabled = YES;
            [MBProgressHUD showTextHUDWithText:@"对方已收到您的打招呼" inView:[UIApplication sharedApplication].keyWindow];
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            button.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            button.enabled = YES;
        }];
    };
    [view show];
}

- (void)shoucangButtonDidClicked:(UIButton *)button
{
    DTieModel * model = self.model;
    
    if (model.authorId == [UserManager shareManager].user.cid) {
//        [MBProgressHUD showTextHUDWithText:@"无法对自己的帖子进行该操作" inView:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
    button.enabled = NO;
    if (model.collectFlg) {
        
        DTieCancleCollectRequest * request = [[DTieCancleCollectRequest alloc] initWithPostID:model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            model.collectFlg = 0;
            model.collectCount--;
            [self reloadStatus];
            
            button.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            button.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            button.enabled = YES;
        }];
        
    }else{
        DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:model.cid type:0 subType:0 remark:@""];
        
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            model.collectFlg = 1;
            model.collectCount++;
            [self reloadStatus];
            
            button.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            button.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            button.enabled = YES;
        }];
    }
}

- (void)yaoyueButtonDidClicked:(UIButton *)button
{
    DTieModel * model = self.model;
    
    button.enabled = NO;
    if (model.wyyFlg) {
        
        DTieCancleWYYRequest * request = [[DTieCancleWYYRequest alloc] initWithPostID:model.cid];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            model.wyyFlg = 0;
            model.wyyCount--;
            [self reloadStatus];
            
            button.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            button.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            button.enabled = YES;
        }];
        
    }else{
        DTieCollectionRequest * request = [[DTieCollectionRequest alloc] initWithPostID:model.cid type:1 subType:0 remark:@""];
        
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
            model.wyyFlg = 1;
            model.wyyCount++;
            [MBProgressHUD showTextHUDWithText:@"您刚标识了您想约这里。约点越多，被约越多。Deedao好友越多，被约越多。记得常去约饭约玩活地图 组饭局哦" inView:[UIApplication sharedApplication].keyWindow];
            [self reloadStatus];
            
            button.enabled = YES;
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            button.enabled = YES;
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            button.enabled = YES;
        }];
    }
}

- (void)createListViewCell
{
    self.dataSource = [[NSMutableArray alloc] init];
    
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat scale = kMainBoundsWidth / 1080.f;
    
    self.baseView = [[UIView alloc] init];
    self.baseView.backgroundColor = UIColorFromRGB(0xFFFFFF);
    [self.contentView addSubview:self.baseView];
    [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.bottom.right.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:24 * scale withView:self.baseView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.baseView.backgroundColor;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = kMainBoundsHeight - (kStatusBarHeight + 780) * scale;
    self.tableView.pagingEnabled = YES;
    [self.tableView registerClass:[DTieVideoCollectionViewCell class] forCellReuseIdentifier:@"DTieVideoCollectionViewCell"];
    [self.tableView registerClass:[DTieImageCollectionViewCell class] forCellReuseIdentifier:@"DTieImageCollectionViewCell"];
    [self.tableView registerClass:[DTieTextCollectionViewCell class] forCellReuseIdentifier:@"DTieTextCollectionViewCell"];
    [self.tableView registerClass:[DTieTitleCollectionViewCell class] forCellReuseIdentifier:@"DTieTitleCollectionViewCell"];
    [self.tableView registerClass:[DTiePostCollectionViewCell class] forCellReuseIdentifier:@"DTiePostCollectionViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.baseView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60 * scale);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-300 * scale);
    }];
    
    UIView * logoBGView = [[UIView alloc] initWithFrame:CGRectZero];
    logoBGView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:logoBGView];
    [logoBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30 * scale);
        make.top.mas_equalTo(self.tableView.mas_bottom).offset(30 * scale);
        make.height.width.mas_equalTo(96 * scale);
    }];
    logoBGView.layer.cornerRadius = 48 * scale;
    logoBGView.layer.shadowColor = UIColorFromRGB(0x111111).CGColor;
    logoBGView.layer.shadowOpacity = .3f;
    logoBGView.layer.shadowRadius = 4 * scale;
    logoBGView.layer.shadowOffset = CGSizeMake(0, 2 * scale);
    
    self.logoImageView = [DDViewFactoryTool createImageViewWithFrame:CGRectZero contentModel:UIViewContentModeScaleAspectFill image:[UIImage new]];
    [logoBGView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [DDViewFactoryTool cornerRadius:48 * scale withView:self.logoImageView];
    UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookUserInfo)];
    self.logoImageView.userInteractionEnabled = YES;
    [self.logoImageView addGestureRecognizer:tap1];
    
    self.nameLabel = [DDViewFactoryTool createLabelWithFrame:CGRectZero font:kPingFangRegular(36 * scale) textColor:UIColorFromRGB(0xDB6283) alignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.logoImageView.mas_right).offset(20 * scale);
        make.right.mas_equalTo(-300 * scale);
        make.centerY.mas_equalTo(self.logoImageView);
        make.height.mas_equalTo(50 * scale);
    }];
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookUserInfo)];
    self.nameLabel.userInteractionEnabled = YES;
    [self.nameLabel addGestureRecognizer:tap2];
    
    CGFloat distance = (kMainBoundsWidth - 3 * 220 * scale - 300 * scale) / 4.f;
    
    self.handleButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(38 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@"感兴趣"];
    [self.handleButton addTarget:self action:@selector(handleButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.baseView addSubview:self.handleButton];
    [self.handleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-distance);
        make.height.mas_equalTo(100 * scale);
        make.width.mas_equalTo(280 * scale);
        make.centerY.mas_equalTo(logoBGView);
    }];
    [DDViewFactoryTool cornerRadius:50 * scale withView:self.handleButton];
    self.handleButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.handleButton.layer.borderWidth = 4 * scale;
    
    self.leftButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(38 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@""];
    [self.leftButton setBackgroundColor:[UIColor whiteColor]];
    [self.leftButton addTarget:self action:@selector(leftButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.baseView addSubview:self.leftButton];
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(distance);
        make.height.mas_equalTo(100 * scale);
        make.width.mas_equalTo(220 * scale);
        make.top.mas_equalTo(logoBGView.mas_bottom).offset(40 * scale);
    }];
    [DDViewFactoryTool cornerRadius:50 * scale withView:self.leftButton];
    self.leftButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.leftButton.layer.borderWidth = 4 * scale;
    
    self.centerButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(38 * scale) titleColor:UIColorFromRGB(0xDB6283) title:@""];
    [self.centerButton addTarget:self action:@selector(centerButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.centerButton setBackgroundColor:[UIColor whiteColor]];
    [self.baseView addSubview:self.centerButton];
    [self.centerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftButton.mas_right).offset(distance);
        make.height.mas_equalTo(100 * scale);
        make.width.mas_equalTo(220 * scale);
        make.centerY.mas_equalTo(self.leftButton);
    }];
    [DDViewFactoryTool cornerRadius:50 * scale withView:self.centerButton];
    self.centerButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.centerButton.layer.borderWidth = 4 * scale;
    
    self.rightButton = [DDViewFactoryTool createButtonWithFrame:CGRectZero font:kPingFangRegular(38 * scale) titleColor:UIColorFromRGB(0xDB6283) title:DDLocalizedString(@"OrganizeHere")];
    [self.rightButton addTarget:self action:@selector(rightButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton setBackgroundColor:[UIColor whiteColor]];
    [self.baseView addSubview:self.rightButton];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.centerButton.mas_right).offset(distance);
        make.height.mas_equalTo(100 * scale);
        make.width.mas_equalTo(220 * scale);
        make.centerY.mas_equalTo(self.leftButton);
    }];
    [DDViewFactoryTool cornerRadius:50 * scale withView:self.rightButton];
    self.rightButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
    self.rightButton.layer.borderWidth = 4 * scale;
}

- (void)tapDidClicked
{
    DDYaoYueViewController * yaoyue = [[DDYaoYueViewController alloc] initWithDtieModel:self.model];
    
    DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController * na = (UINavigationController *)lg.rootViewController;
    [na pushViewController:yaoyue animated:YES];
}

- (void)lookUserInfo
{
    DTieModel * model = self.model;
    if (model) {
        DDLGSideViewController * lg = (DDLGSideViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        UINavigationController * na = (UINavigationController *)lg.rootViewController;
        UserInfoViewController * info = [[UserInfoViewController alloc] initWithUserId:model.authorId];
        [na pushViewController:info animated:YES];
    }
}

- (void)configWithModel:(DTieModel *)model tag:(NSInteger)tag
{
    self.request = nil;
    self.model = model;
    
    self.tableView.tag = tag;
    self.isFirstRead = YES;
    
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:model.portraituri]];
    if (isEmptyString(model.portraituri)) {
        [self.logoImageView setImage:[UIImage imageNamed:@"defaultRemark"]];
    }
    
    self.nameLabel.text = model.nickname;
    [self reloadStatus];
//
//    if (model.wyyFlg) {
//        [self.collectImageView setImage:[UIImage imageNamed:@"yaoyueshu"]];
//        self.collectImageView.hidden = NO;
//    }else if (model.collectFlg) {
//        [self.collectImageView setImage:[UIImage imageNamed:@"shoucangshu"]];
//        self.collectImageView.hidden = NO;
//    }else{
//        self.collectImageView.hidden = YES;
//    }
    
    if (model.details) {
        
//        NSMutableArray * tempArray = [[NSMutableArray alloc] initWithArray:model.details];
//        for (NSInteger i = 0; i < tempArray.count; i++) {
//            DTieEditModel * editModel = [tempArray objectAtIndex:i];
//            if (editModel.type == DTieEditType_Image) {
//                [tempArray removeObject:editModel];
//                break;
//            }
//        }
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:model.details];
        
        [self.tableView setContentOffset:CGPointZero animated:NO];
        [self.tableView reloadData];
        return;
    }
    
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    
//    [DTieDetailRequest cancelRequest];
    
    NSInteger postID = model.postId;
    if (postID == 0) {
        postID = model.cid;
    }
    
    self.request = [[DTieDetailRequest alloc] initWithID:postID type:4 start:0 length:10];
    [self.request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSDictionary * data = [response objectForKey:@"data"];
            if (KIsDictionary(data)) {
                [model mj_setKeyValues:data];
                
                if (request == self.request) {
//                    NSMutableArray * tempArray = [[NSMutableArray alloc] initWithArray:model.details];
//                    for (NSInteger i = 0; i < tempArray.count; i++) {
//                        DTieEditModel * editModel = [tempArray objectAtIndex:i];
//                        if (editModel.type == DTieEditType_Image) {
//                            [tempArray removeObject:editModel];
//                            break;
//                        }
//                    }
                    [self.dataSource removeAllObjects];
                    [self.dataSource addObjectsFromArray:model.details];
                    
                    [self.tableView setContentOffset:CGPointZero animated:NO];
                    [self.tableView reloadData];
                }
            }
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

- (void)reloadStatus
{
    NSString * number = @"";
    if (self.model.wyyCount > 0) {
        number = [NSString stringWithFormat:@"%ld", self.model.wyyCount];
        if (self.model.wyyCount > 99) {
            number = @"99+";
        }
    }
    
    if (self.model.authorId == [UserManager shareManager].user.cid) {
        
        self.handleButton.hidden = NO;
        
        [self.leftButton setTitle:DDLocalizedString(@"Delete") forState:UIControlStateNormal];
        [self.centerButton setTitle:DDLocalizedString(@"AddPhotos") forState:UIControlStateNormal];
        [self.rightButton setTitle:DDLocalizedString(@"OrganizeHere") forState:UIControlStateNormal];
        
        if (self.model.wyyFlg == 1) {
            [self.handleButton setTitle:[NSString stringWithFormat:@"%@ %@", DDLocalizedString(@"HasInterestedHome"), number] forState:UIControlStateNormal];
            self.handleButton.alpha = .5f;
        }else{
            [self.handleButton setTitle:DDLocalizedString(@"InterestedHome") forState:UIControlStateNormal];
            self.handleButton.alpha = 1.f;
        }
        
    }else{
        
        self.handleButton.hidden = YES;
        
        if (self.model.wyyFlg == 1) {
            [self.leftButton setTitle:[NSString stringWithFormat:@"%@ %@", DDLocalizedString(@"HasInterestedHome"), number] forState:UIControlStateNormal];
            self.leftButton.alpha = .5f;
        }else{
            [self.leftButton setTitle:DDLocalizedString(@"InterestedHome") forState:UIControlStateNormal];
            self.leftButton.alpha = 1.f;
        }
        [self.centerButton setTitle:DDLocalizedString(@"SayHi") forState:UIControlStateNormal];
        [self.rightButton setTitle:DDLocalizedString(@"OrganizeHere") forState:UIControlStateNormal];
        
        if ([[DDLocationManager shareManager] postIsCanDazhaohuWith:self.model]) {
            self.centerButton.layer.borderColor = UIColorFromRGB(0xDB6283).CGColor;
            [self.centerButton setTitleColor:UIColorFromRGB(0xDB6283) forState:UIControlStateNormal];
        }else{
            self.centerButton.layer.borderColor = UIColorFromRGB(0xefeff4).CGColor;
            [self.centerButton setTitleColor:UIColorFromRGB(0xefeff4) forState:UIControlStateNormal];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        DTieEditModel * model = [[DTieEditModel alloc] init];
        model.type = DTieEditType_Image;
        model.detailContent = self.model.postFirstPicture;
        DTieTitleCollectionViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieTitleCollectionViewCell" forIndexPath:indexPath];
        [cell configWithModel:model Dtie:self.model];
        return cell;
    }
    
    DTieEditModel * model = [self.dataSource objectAtIndex:indexPath.row - 1];
    
    if (model.type == DTieEditType_Image) {
        DTieImageCollectionViewCell * imageCell = [tableView dequeueReusableCellWithIdentifier:@"DTieImageCollectionViewCell" forIndexPath:indexPath];
        [imageCell configWithModel:model Dtie:self.model];
        return imageCell;
    }else if (model.type == DTieEditType_Text){
        DTieTextCollectionViewCell * textCell = [tableView dequeueReusableCellWithIdentifier:@"DTieTextCollectionViewCell" forIndexPath:indexPath];
        [textCell configWithModel:model Dtie:self.model];
        return textCell;
    }else if (model.type == DTieEditType_Video) {
        DTieVideoCollectionViewCell * videoCell = [tableView dequeueReusableCellWithIdentifier:@"DTieVideoCollectionViewCell" forIndexPath:indexPath];
        [videoCell configWithModel:model Dtie:self.model];
        return videoCell;
    }else if (model.type == DTieEditType_Post) {
        DTiePostCollectionViewCell * postCell = [tableView dequeueReusableCellWithIdentifier:@"DTiePostCollectionViewCell" forIndexPath:indexPath];
        [postCell configWithModel:model Dtie:self.model];
        return postCell;
    }
    
    DTieImageCollectionViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DTieImageCollectionViewCell" forIndexPath:indexPath];
    
    [cell configWithModel:model Dtie:self.model];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableViewClickHandle) {
        self.tableViewClickHandle([NSIndexPath indexPathForItem:tableView.tag inSection:0]);
    }
}

@end
