//
//  WeChatManager.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "WeChatManager.h"
#import "MBProgressHUD+DDHUD.h"
#import "ShareImageModel.h"
#import "GetWXAccessTokenRequest.h"
#import <AFHTTPSessionManager.h>
#import <UIImageView+WebCache.h>
#import <Social/Social.h>
#import "DtieShareItem.h"
#import "DDTool.h"

#define KCompressibilityFactor 560.00

NSString * const DDUserDidGetWeChatCodeNotification = @"DDUserDidGetWeChatCodeNotification";
NSString * const DDUserDidLoginWithTelNumberNotification = @"DDUserDidLoginWithTelNumberNotification";

@interface WeChatManager ()

@property (nonatomic, strong) SLComposeViewController * slCompose;

@end

@implementation WeChatManager

+ (instancetype)shareManager
{
    static dispatch_once_t once;
    static WeChatManager * instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
        [instance getMiniProgramAccessToken];
    });
    return instance;
}

- (void)loginWithWeChat
{
    //构造SendAuthReq结构体
    SendAuthReq* req =[[SendAuthReq alloc]init];
    req.scope = @"snsapi_userinfo";
    
    NSString * bundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    if (isEmptyString(bundleID)) {
        bundleID = @"com.deedao.appstore";
    }
    req.state = bundleID;
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}

- (void)shareTimeLineWithImages:(NSArray *)images title:(NSString *)title viewController:(UIViewController *)viewController
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:[UIApplication sharedApplication].keyWindow];
    
    GetWXAccessTokenRequest * request = [[GetWXAccessTokenRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSDictionary *dict = [response objectForKey:@"data"];
            if (KIsDictionary(dict)) {
                self.miniProgramToken = [dict objectForKey:@"access_token"];
                
                NSMutableArray * shareItems = [[NSMutableArray alloc] init];
                
                NSFileManager * fileManager = [NSFileManager defaultManager];
                NSString * documentPath = [NSString stringWithFormat:@"%@/shareImageTemp", DDDocumentPath];
                [fileManager removeItemAtPath:documentPath error:nil];
                if (![fileManager fileExistsAtPath:documentPath]) {
                    [fileManager createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:nil];
                }
                
                __block NSInteger count = 0;
                for (NSInteger i = 0; i < images.count; i++) {
                    
                    [shareItems addObject:[DtieShareItem new]];
                    ShareImageModel * model = [images objectAtIndex:i];
                    UIImage * bgImage = [self getJPEGImagerImg:model.image];
                    
                    [self getMiniProgromCodeWithPostID:model.postId handle:^(UIImage *image) {
                        model.codeImage = image;
                        
                        UIImage * result;
                        if (i == images.count - 1) {
                            result = [self image:bgImage addTitle:model.title text:model.detail codeImage:model.codeImage pflg:model.PFlag];
                        }else{
                            result = [self image:bgImage addMiniProgramCodeImage:model.codeImage];
                        }
                        
                        NSString * path = [NSString stringWithFormat:@"%@/share%ld.jpg", documentPath, i];
                        [UIImagePNGRepresentation(result) writeToFile:path atomically:YES];
                        DtieShareItem * item = [[DtieShareItem alloc] initWithImage:result path:path];
                        
                        count++;
                        [shareItems replaceObjectAtIndex:i withObject:item];
                        
                        if (count == images.count) {
                            [hud hideAnimated:YES];
                            UIActivityViewController * activityView = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
                            activityView.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
                                if (activityError) {
                                    [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"SharingFailed") inView:viewController.view];
                                }else{
                                    if (completed) {
                                        [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"ShareCompleted") inView:viewController.view];
                                        [viewController dismissViewControllerAnimated:YES completion:nil];
                                    }else{
                                        [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"SharingFailed") inView:viewController.view];
                                    }
                                }
                            };
                            
                            [viewController presentViewController:activityView animated:YES completion:nil];
                        }
                        
                    }];
                }
                
            }else{
                [hud hideAnimated:YES];
                [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"SharingFailed") inView:viewController.view];
            }
        }else{
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"SharingFailed") inView:viewController.view];
        }
        
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"SharingFailed") inView:viewController.view];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:viewController.view];
        
    }];
}

- (void)savePhotoWithImages:(NSArray *)images title:(NSString *)title viewController:(UIViewController *)viewController
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:DDLocalizedString(@"Loading") inView:[UIApplication sharedApplication].keyWindow];
    
    GetWXAccessTokenRequest * request = [[GetWXAccessTokenRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSDictionary *dict = [response objectForKey:@"data"];
            if (KIsDictionary(dict)) {
                self.miniProgramToken = [dict objectForKey:@"access_token"];
                
                __block NSInteger count = 0;
                for (NSInteger i = 0; i < images.count; i++) {
                    
                    ShareImageModel * model = [images objectAtIndex:i];
//                    UIImage * bgImage = model.image;
                    UIImage * result = [self addLogoWithImage:model.image];
                    [DDTool saveImageInSystemPhotoWithNoHUD:result];
                    
                    count++;
                    
                    if (count == images.count) {
                        [hud hideAnimated:YES];
                        [MBProgressHUD showTextHUDWithText:@"保存成功，您可以在相册中查看" inView:viewController.view];
                    }
                    
//                    [self getMiniProgromCodeWithPostID:model.postId handle:^(UIImage *image) {
//                        model.codeImage = image;
//
//                        UIImage * result;
//                        if (i == images.count - 1) {
//                            result = [self image:bgImage addTitle:model.title text:model.detail codeImage:model.codeImage pflg:model.PFlag];
//                        }else{
//                            result = [self image:bgImage addMiniProgramCodeImage:model.codeImage];
//                        }
//                        [DDTool saveImageInSystemPhotoWithNoHUD:result];
//
//
//                        count++;
//
//                        if (count == images.count) {
//                            [hud hideAnimated:YES];
//                            [MBProgressHUD showTextHUDWithText:@"保存成功，您可以在相册中查看" inView:viewController.view];
//                        }
//
//                    }];
                }
                
            }else{
                [hud hideAnimated:YES];
                [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"SharingFailed") inView:viewController.view];
            }
        }else{
            [hud hideAnimated:YES];
            [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"SharingFailed") inView:viewController.view];
        }
        
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:DDLocalizedString(@"SharingFailed") inView:viewController.view];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showTextHUDWithText:@"网络不给力" inView:viewController.view];
        
    }];
}

- (void)shareMiniProgramWithPostID:(NSInteger)postID image:(UIImage *)image isShare:(BOOL)isShare title:(NSString *)title
{
    self.isShare = isShare;
    
    WXMiniProgramObject * program = [WXMiniProgramObject object];
    program.webpageUrl = @"http://www.deedao.com";
    program.userName = @"gh_3714b00f2a4c";
    program.path = [NSString stringWithFormat:@"pages/detail/detail?postId=%lduserIs%ld", postID, [UserManager shareManager].user.cid];
    program.miniProgramType = WXMiniProgramTypeRelease;
    
    NSData*  data = [NSData data];
    
    UIImage * tempImage = [self getJPEGImagerImg:image];
    data = UIImageJPEGRepresentation(tempImage, 1);
    float tempX = 0.9;
    NSInteger length = data.length;
    while (data.length > 127*1024) {
        data = UIImageJPEGRepresentation(tempImage, tempX);
        tempX -= 0.1;
        if (data.length == length) {
            break;
        }
        length = data.length;
    }
    program.hdImageData = data;
    
    WXMediaMessage * mediaMessage = [WXMediaMessage message];
    mediaMessage.title = title;
    mediaMessage.description = @"地到生活，到地可见";
    mediaMessage.mediaObject = program;
    mediaMessage.thumbData = nil;
    
    SendMessageToWXReq * req = [[SendMessageToWXReq alloc] init];
    req.message = mediaMessage;
    req.scene = WXSceneSession;
    [WXApi sendReq:req];
}

- (void)shareMiniProgramWithUser:(UserModel *)model
{
    WXMiniProgramObject * program = [WXMiniProgramObject object];
    program.webpageUrl = @"http://www.deedao.com";
    program.userName = @"gh_3714b00f2a4c";
    program.path = [NSString stringWithFormat:@"pages/user/user?authorId=%lduserIs%ld", model.cid, [UserManager shareManager].user.cid];
    program.miniProgramType = WXMiniProgramTypeRelease;
    
    UIImage * image = [self imageWithModel:model];
    
    NSData*  data = [NSData data];
    data = UIImageJPEGRepresentation(image, 1);
    float tempX = 0.9;
    NSInteger length = data.length;
    while (data.length > 127*1024) {
        data = UIImageJPEGRepresentation(image, tempX);
        tempX -= 0.1;
        if (data.length == length) {
            break;
        }
        length = data.length;
    }
    
    program.hdImageData = data;
    
    WXMediaMessage * mediaMessage = [WXMediaMessage message];
//    mediaMessage.title = @"DeeDao地到";
    if (model.cid == [UserManager shareManager].user.cid) {
        mediaMessage.title = [NSString stringWithFormat:@"%@ 邀请您在 Deedao 连接", model.nickname];
    }else{
        mediaMessage.title = [NSString stringWithFormat:@"%@ 介绍 %@ 给您", [UserManager shareManager].user.nickname, model.nickname];
    }
    mediaMessage.mediaObject = program;
    mediaMessage.thumbData = nil;
    
    SendMessageToWXReq * req = [[SendMessageToWXReq alloc] init];
    req.message = mediaMessage;
    req.scene = WXSceneSession;
    [WXApi sendReq:req];
}

- (void)shareMiniProgramWithSeries:(SeriesModel *)model image:(UIImage *)image
{
    WXMiniProgramObject * program = [WXMiniProgramObject object];
    program.webpageUrl = @"http://www.deedao.com";
    program.userName = @"gh_3714b00f2a4c";
    program.path = [NSString stringWithFormat:@"pages/album/album?albumId=%ld", model.cid];
    program.miniProgramType = WXMiniProgramTypeRelease;
    
    NSData*  data = [NSData data];
    data = UIImageJPEGRepresentation(image, 1);
    float tempX = 0.9;
    NSInteger length = data.length;
    while (data.length > 127*1024) {
        data = UIImageJPEGRepresentation(image, tempX);
        tempX -= 0.1;
        if (data.length == length) {
            break;
        }
        length = data.length;
    }
    
    program.hdImageData = data;
    
    WXMediaMessage * mediaMessage = [WXMediaMessage message];
    mediaMessage.title = model.seriesTitle;
    mediaMessage.description = model.seriesTitle;
    mediaMessage.mediaObject = program;
    mediaMessage.thumbData = nil;
    
    SendMessageToWXReq * req = [[SendMessageToWXReq alloc] init];
    req.message = mediaMessage;
    req.scene = WXSceneSession;
    [WXApi sendReq:req];
}

- (void)shareImage:(UIImage *)image
{
    WXMediaMessage * message = [WXMediaMessage message];
    message.title = @"123456789";
    message.description = @"987654321";
    
    WXImageObject * object = [WXImageObject object];
    object.imageData = UIImageJPEGRepresentation(image, 1);
    message.mediaObject = object;
    
    SendMessageToWXReq * req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;
    [WXApi sendReq:req];
}

- (void)shareFriendImage:(UIImage *)image
{
    WXMediaMessage * message = [WXMediaMessage message];
    message.title = @"123456789";
    message.description = @"987654321";
    
    WXImageObject * object = [WXImageObject object];
    object.imageData = UIImageJPEGRepresentation(image, 1);
    message.mediaObject = object;
    
    SendMessageToWXReq * req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;
    [WXApi sendReq:req];
}

- (void)shareToBiz
{
    JumpToBizProfileReq *req = [[JumpToBizProfileReq alloc]init];
    req.username=@"gh_68797f4b389f";
    req.extMsg = @"";
    req.profileType =0;
    [WXApi sendReq:req];
}

#pragma mark - 获取用户的名片图片
- (UIImage *)imageWithModel:(UserModel *)model
{
    UIImage * BGImage = [UIImage imageNamed:@"miniProgramBG"];
    CGFloat width = BGImage.size.width;
    CGFloat height = BGImage.size.height;
    
    UIImage * logoImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:model.portraituri];
    logoImage = [self clipUserLogo:logoImage];
    
    UIGraphicsBeginImageContextWithOptions(BGImage.size, NO, [UIScreen mainScreen].scale);
    
    [BGImage drawInRect:CGRectMake(0, 0, width, height)];
    
    CGFloat originY = height / 5;
    CGFloat logoWidth = height / 4;
    CGFloat originX = (width - logoWidth) / 2;
    
    CGFloat titleSize = logoWidth / 5 * 2;
    NSString * name = model.nickname;
    NSString * city = @"";
    if (!isEmptyString(model.country)) {
        city = [city stringByAppendingString:model.country];
    }
    if (!isEmptyString(model.province)) {
        city = [city stringByAppendingString:model.province];
    }
    if (!isEmptyString(model.city)) {
        city = [city stringByAppendingString:model.city];
    }
    
    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentCenter];
    [name drawInRect:CGRectMake(0, originY + logoWidth + titleSize/3, width, height) withAttributes:@{NSFontAttributeName:kPingFangMedium(titleSize), NSForegroundColorAttributeName:UIColorFromRGB(0xFFFFFF), NSParagraphStyleAttributeName:style}];
    
    NSMutableParagraphStyle* style2 = [[NSMutableParagraphStyle alloc] init];
    [style2 setAlignment:NSTextAlignmentCenter];
    [city drawInRect:CGRectMake(0, originY + logoWidth + titleSize +titleSize/2, width, height) withAttributes:@{NSFontAttributeName:kPingFangLight(titleSize/3*2), NSForegroundColorAttributeName:UIColorFromRGB(0xFFFFFF), NSParagraphStyleAttributeName:style2}];
    
    [logoImage drawInRect:CGRectMake(originX, originY, logoWidth, logoWidth)];
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (UIImage *)clipUserLogo:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    //绘制边框的圆
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddEllipseInRect(context, CGRectMake(0, 0, image.size.width, image.size.height));
    
    //剪切可视范围
    CGContextClip(context);
    
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    UIImage *iconImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return iconImage;
}

#pragma mark - 向图片中添加文字和小程序码
- (UIImage *)image:(UIImage *)image addMiniProgramCodeImage:(UIImage *)codeImage
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGFloat codeWidth = width * .12f;
    
    if (height > width) {
        codeWidth = height * .1f;
    }
    
    CGFloat leftMargin = codeWidth * .1f;
    
    [image drawInRect:CGRectMake(0, 0, width, height)];
    
    UIImage * codeDefaultImage = codeImage;
    if (nil == codeDefaultImage) {
        codeDefaultImage = [UIImage imageNamed:@"gongzhongCode"];
    }
    [codeDefaultImage drawInRect:CGRectMake(leftMargin, height - leftMargin - codeWidth, codeWidth, codeWidth)];
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (UIImage *)addLogoWithImage:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGFloat logoWidth = width * .2f;
    CGFloat codeWidth = width * .12f;
    
    if (height > width) {
        logoWidth = height * .18f;
        codeWidth = height * .1f;
    }
    
    CGFloat leftMargin = codeWidth * .1f;
    
    [image drawInRect:CGRectMake(0, 0, width, height)];
    
    UIImage * logoImage = [UIImage imageNamed:@"letterLogoShare"];
    [logoImage drawInRect:CGRectMake(width - leftMargin * 1.5 - logoWidth, leftMargin * 2, logoWidth, 36.f / 86.f * logoWidth)];
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (UIImage *)image:(UIImage *)image addTitle:(NSString *)title text:(NSString *)text codeImage:(UIImage *)codeImage pflg:(NSInteger)pflag
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGFloat logoWidth = width * .2f;
    CGFloat codeWidth = width * .12f;
    
    if (height > width) {
        logoWidth = height * .18f;
        codeWidth = height * .1f;
    }
    
    CGFloat leftMargin = codeWidth * .1f;
    
    [image drawInRect:CGRectMake(0, 0, width, height)];
    
    UIImage * logoImage = [UIImage imageNamed:@"letterLogoShare"];
    [logoImage drawInRect:CGRectMake(width - leftMargin * 1.5 - logoWidth, leftMargin * 2, logoWidth, 36.f / 86.f * logoWidth)];
//
//    UIImage * coverImage = [UIImage imageNamed:@"wxCover"];
//    [coverImage drawInRect:CGRectMake(0, originY, width, contentHeight)];
    
//    [title drawInRect:CGRectMake(leftMargin + logoWidth + leftMargin, originY + topMargin, width - leftMargin - logoWidth - leftMargin - leftMargin, labelHeight) withAttributes:@{NSFontAttributeName:kPingFangRegular(fontSize), NSForegroundColorAttributeName:UIColorFromRGB(0xffffff)}];
//
//    [text drawInRect:CGRectMake(leftMargin + logoWidth + leftMargin, originY + topMargin + fontSize + fontSize / 4, width - leftMargin - logoWidth - leftMargin - leftMargin, labelHeight) withAttributes:@{NSFontAttributeName:kPingFangRegular(fontSize), NSForegroundColorAttributeName:UIColorFromRGB(0xffffff)}];
    
    UIImage * codeDefaultImage = codeImage;
    if (nil == codeDefaultImage) {
        codeDefaultImage = [UIImage imageNamed:@"gongzhongCode"];
    }
    [codeDefaultImage drawInRect:CGRectMake(leftMargin, height - leftMargin - codeWidth, codeWidth, codeWidth)];
    
    if (!isEmptyString(text)) {
        CGFloat labelHeight = codeWidth * .5f;
        CGFloat fontSize = codeWidth * .27f;
        
        if (pflag == 1) {
            text = [text stringByAppendingString:@"，当前图片到地可见"];
        }
        
        [text drawInRect:CGRectMake(leftMargin + codeWidth + leftMargin, height - labelHeight, width - codeWidth - leftMargin * 3, labelHeight) withAttributes:@{NSFontAttributeName:kPingFangMedium(fontSize), NSForegroundColorAttributeName:UIColorFromRGB(0xffffff)}];
    }
    
    if (!isEmptyString(title)) {
        CGFloat labelHeight = codeWidth * .4f;
        CGFloat fontSize = codeWidth * .27f;
        
        [title drawInRect:CGRectMake(leftMargin + codeWidth + leftMargin, height - labelHeight - codeWidth * .5f, width - codeWidth - leftMargin * 3, labelHeight) withAttributes:@{NSFontAttributeName:kPingFangMedium(fontSize), NSForegroundColorAttributeName:UIColorFromRGB(0xffffff)}];
    }
    
//    if (pflag) {
//        NSString * flagTitle = @"到地体验更多精彩";
//        [flagTitle drawInRect:CGRectMake(leftMargin + logoWidth + leftMargin, originY + topMargin + fontSize + fontSize + fontSize/2, width - leftMargin - logoWidth - leftMargin - leftMargin, labelHeight) withAttributes:@{NSFontAttributeName:kPingFangRegular(fontSize), NSForegroundColorAttributeName:UIColorFromRGB(0xffffff)}];
//    }
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (void)getMiniProgramAccessToken
{
    GetWXAccessTokenRequest * request = [[GetWXAccessTokenRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        if (KIsDictionary(response)) {
            NSDictionary *dict = [response objectForKey:@"data"];
            if (KIsDictionary(dict)) {
                self.miniProgramToken = [dict objectForKey:@"access_token"];
            }
        }
        
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self performSelector:@selector(getMiniProgramAccessToken) withObject:nil afterDelay:15.f];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
        [self performSelector:@selector(getMiniProgramAccessToken) withObject:nil afterDelay:15.f];
        
    }];
}

- (void)getMiniProgromCodeWithPostID:(NSInteger)postID handle:(void (^)(UIImage *))handle
{
    if (isEmptyString(self.miniProgramToken)) {
        return;
    }
    
    NSString * urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/wxa/getwxacodeunlimit?access_token=%@", self.miniProgramToken];
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.f;
    
    [manager POST:urlStr parameters:@{@"scene":[NSString stringWithFormat:@"postId,%ld,userIs,%ld", postID, [UserManager shareManager].user.cid],
                                      @"page" :@"pages/detail/detail",
                                      @"width":@(430)
                                      } progress:^(NSProgress * _Nonnull uploadProgress) {
                                          
                                      } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                          
                                          UIImage * image = [UIImage imageWithData:responseObject];
                                          if (image) {
                                              
                                              if (handle) {
                                                  handle(image);
                                              }
                                              
                                          }else{
                                              if (handle) {
                                                  handle(nil);
                                              }
                                          }
                                          
                                      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                          if (handle) {
                                              handle(nil);
                                          }
                                      }];
}

- (void)getMiniProgromCodeWithUserID:(NSInteger)userID handle:(void (^)(UIImage *))handle
{
    if (isEmptyString(self.miniProgramToken)) {
        return;
    }
    
    NSString * urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/wxa/getwxacodeunlimit?access_token=%@", self.miniProgramToken];
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.f;
    
    [manager POST:urlStr parameters:@{@"scene":[NSString stringWithFormat:@"authorId,%ld,userIs,%ld", userID, [UserManager shareManager].user.cid],
                                      @"page" :@"pages/user/user",
                                      @"width":@(430)
                                      } progress:^(NSProgress * _Nonnull uploadProgress) {
                                          
                                      } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                          
                                          UIImage * image = [UIImage imageWithData:responseObject];
                                          if (image) {
                                              
                                              if (handle) {
                                                  handle(image);
                                              }
                                              
                                          }else{
                                              
                                              NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                                              NSLog(@"%@", dict);
                                              
                                              if (handle) {
                                                  handle(nil);
                                              }
                                          }
                                          
                                      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                          NSLog(@"请求失败");
                                          if (handle) {
                                              handle(nil);
                                          }
                                      }];
}

#pragma mark - 压缩多张图片 最大宽高1280 类似于微信算法
- (NSArray *)getJPEGImagerImgArr:(NSArray *)imageArr{
    NSMutableArray *newImgArr = [NSMutableArray new];
    for (int i = 0; i<imageArr.count; i++) {
        UIImage *newImg = [self getJPEGImagerImg:imageArr[i]];
        [newImgArr addObject:newImg];
    }
    return newImgArr;
}

#pragma mark - 压缩一张图片 最大宽高1280 类似于微信算法
- (UIImage *)getJPEGImagerImg:(UIImage *)image{
    CGFloat oldImg_WID = image.size.width;
    CGFloat oldImg_HEI = image.size.height;
    //CGFloat aspectRatio = oldImg_WID/oldImg_HEI;//宽高比
    if(oldImg_WID > KCompressibilityFactor || oldImg_HEI > KCompressibilityFactor){
        //超过设置的最大宽度 先判断那个边最长
        if(oldImg_WID > oldImg_HEI){
            //宽度大于高度
            oldImg_HEI = (KCompressibilityFactor * oldImg_HEI)/oldImg_WID;
            oldImg_WID = KCompressibilityFactor;
        }else{
            oldImg_WID = (KCompressibilityFactor * oldImg_WID)/oldImg_HEI;
            oldImg_HEI = KCompressibilityFactor;
        }
    }
    UIImage *newImg = [self imageWithImage:image scaledToSize:CGSizeMake(oldImg_WID, oldImg_HEI)];
    
    NSData*  data = nil;
    data = UIImageJPEGRepresentation(newImg, 0.9);
    float tempX = 0.9;
    NSInteger length = data.length;
    while (data.length > 200*1024) {
        data = UIImageJPEGRepresentation(image, tempX);
        tempX -= 0.1;
        if (data.length == length) {
            break;
        }
        length = data.length;
    }
    NSLog(@"%lf", data.length);
    return [UIImage imageWithData:data];
}

#pragma mark - 根据宽高压缩图片
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DDUserDidGetWeChatCodeNotification object:resp];
    }else {
        
    }
}

- (void)onReq:(BaseReq *)req
{
    if ([req isKindOfClass:[LaunchFromWXReq class]]) {
        
        LaunchFromWXReq * wxReq = (LaunchFromWXReq *)req;
        WXMediaMessage * message = wxReq.message;
        NSString * text = message.messageExt;
        if (!isEmptyString(text)) {
            NSArray * params = [text componentsSeparatedByString:@"="];
            NSString * postIDStr = [params lastObject];
            if (!isEmptyString(postIDStr)) {
                NSInteger postID = [postIDStr integerValue];
                [DDTool WXMiniProgramHandleWithPostID:postID];
            }
        }
        
    }
}

- (NSMutableArray *)titleList
{
    if (!_titleList) {
        _titleList = [[NSMutableArray alloc] init];
    }
    return _titleList;
}

@end
