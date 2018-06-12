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
#import <AFHTTPSessionManager.h>
#import <UIImageView+WebCache.h>
#import <Social/Social.h>

#define KCompressibilityFactor 1280.00  

NSString * const DDUserDidGetWeChatCodeNotification = @"DDUserDidGetWeChatCodeNotification";
NSString * const DDUserDidLoginWithTelNumberNotification = @"DDUserDidLoginWithTelNumberNotification";

@interface WeChatManager ()

@property (nonatomic, strong) SLComposeViewController * slCompose;

@property (nonatomic, copy) NSString * miniProgramToken;

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
    req.state = @"com.deedao.appstore";
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}

- (void)shareTimeLineWithImages:(NSArray *)images title:(NSString *)title viewController:(UIViewController *)viewController
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingHUDWithText:@"正在加载" inView:[UIApplication sharedApplication].keyWindow];
    
    NSMutableArray * shareItems = [[NSMutableArray alloc] init];
    __block NSInteger count = 0;
    for (NSInteger i = 0; i < images.count; i++) {
        
        ShareImageModel * model = [images objectAtIndex:i];
        UIImage * bgImage = [self getJPEGImagerImg:model.image];
        
        [self getMiniProgromCodeWithPostID:model.postId handle:^(UIImage *image) {
            model.codeImage = image;
            
            UIImage * result = [self image:bgImage addTitle:model.title text:model.detail codeImage:model.codeImage pflg:model.pflg];
            [shareItems addObject:[self getJPEGImagerImg:result]];
            
            count++;
            if (count == images.count) {
                [hud hideAnimated:YES];
                UIActivityViewController * activityView = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
                activityView.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
                    if (activityError) {
                        [MBProgressHUD showTextHUDWithText:@"分享失败" inView:viewController.view];
                    }else{
                        if (completed) {
                            [MBProgressHUD showTextHUDWithText:@"分享成功" inView:viewController.view];
                            [viewController dismissViewControllerAnimated:YES completion:nil];
                        }else{
                            [MBProgressHUD showTextHUDWithText:@"分享失败" inView:viewController.view];
                        }
                    }
                };
                
                [viewController presentViewController:activityView animated:YES completion:nil];
            }
            
        }];
        
    }
}

- (void)shareMiniProgramWithPostID:(NSInteger)postID image:(UIImage *)image isShare:(BOOL)isShare
{
    self.isShare = isShare;
    
    WXMiniProgramObject * program = [WXMiniProgramObject object];
    program.webpageUrl = @"http://www.deedao.com";
    program.userName = @"gh_3714b00f2a4c";
    program.path = [NSString stringWithFormat:@"pages/index/index?postId=%ld", postID];
    program.miniProgramType = WXMiniProgramTypeTest;
    
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
    mediaMessage.title = @"DeeDao地到";
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
    program.path = [NSString stringWithFormat:@"pages/index/index?authorId=%ld", model.cid];
    program.miniProgramType = WXMiniProgramTypeTest;
    
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
    mediaMessage.title = @"DeeDao地到";
    mediaMessage.description = model.nickname;
    mediaMessage.mediaObject = program;
    mediaMessage.thumbData = nil;
    
    SendMessageToWXReq * req = [[SendMessageToWXReq alloc] init];
    req.message = mediaMessage;
    req.scene = WXSceneSession;
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
- (UIImage *)image:(UIImage *)image addTitle:(NSString *)title text:(NSString *)text codeImage:(UIImage *)codeImage pflg:(BOOL)pflag
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGFloat fontSize = 15.f / kMainBoundsWidth * width;
    CGFloat contentHeight = 120.f / kMainBoundsWidth * width;
    CGFloat originY = image.size.height - contentHeight;
    CGFloat labelHeight = 20.f / kMainBoundsWidth * width;
    CGFloat topMargin = 55.f / kMainBoundsWidth * width;
    
    if (pflag) {
        topMargin = 45.f / kMainBoundsWidth * width;
    }
    
    CGFloat leftMargin = 15.f / kMainBoundsWidth * width;
    //    CGFloat rightMargin = 110.f / kMainBoundsWidth * width;
    
    CGFloat logoWidth = 70.f / kMainBoundsWidth * width;
    CGFloat logoTopMargin = 10.f / kMainBoundsWidth * width;
    //    CGFloat logoRightMargin = 100.f / kMainBoundsWidth * width;
    //    CGFloat logoFontSize = 15.f / kMainBoundsWidth * width;
    
    [image drawInRect:CGRectMake(0, 0, width, height)];
    
    UIImage * logoImage = [UIImage imageNamed:@"letterLogo"];
    [logoImage drawInRect:CGRectMake(width - leftMargin - logoWidth, leftMargin, logoWidth, 36.f / 50.f * logoWidth)];
    
    UIImage * coverImage = [UIImage imageNamed:@"wxCover"];
    [coverImage drawInRect:CGRectMake(0, originY, width, contentHeight)];
    
    [title drawInRect:CGRectMake(leftMargin + logoWidth + leftMargin, originY + topMargin, width - leftMargin - logoWidth - leftMargin - leftMargin, labelHeight) withAttributes:@{NSFontAttributeName:kPingFangRegular(fontSize), NSForegroundColorAttributeName:UIColorFromRGB(0xffffff)}];
    
    [text drawInRect:CGRectMake(leftMargin + logoWidth + leftMargin, originY + topMargin + fontSize + fontSize / 4 * 3, width - leftMargin - logoWidth - leftMargin - leftMargin, labelHeight) withAttributes:@{NSFontAttributeName:kPingFangRegular(fontSize), NSForegroundColorAttributeName:UIColorFromRGB(0xffffff)}];
    
    UIImage * codeDefaultImage = codeImage;
    if (nil == codeDefaultImage) {
        codeDefaultImage = [UIImage imageNamed:@"gongzhongCode"];
    }
    [codeDefaultImage drawInRect:CGRectMake(leftMargin, height - logoTopMargin - logoWidth, logoWidth, logoWidth)];
    
    if (pflag) {
        NSString * flagTitle = @"到地体验更多精彩";
        [flagTitle drawInRect:CGRectMake(leftMargin + logoWidth + leftMargin, originY + topMargin + fontSize + fontSize + fontSize, width - leftMargin - logoWidth - leftMargin - leftMargin, labelHeight) withAttributes:@{NSFontAttributeName:kPingFangRegular(fontSize), NSForegroundColorAttributeName:UIColorFromRGB(0xffffff)}];
    }
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (void)getMiniProgramAccessToken
{
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15.f;
    [manager GET:@"https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=wx5765078c1f5bb0f6&secret=3dceca0d57bee7e9a25bc60ea8a3d0d4" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        if (KIsDictionary(dict)) {
            self.miniProgramToken = [dict objectForKey:@"access_token"];
            NSInteger expires = [[dict objectForKey:@"expires_in"] integerValue];
            [self performSelector:@selector(getMiniProgramAccessToken) withObject:nil afterDelay:expires - 15];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
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
    
    [manager POST:urlStr parameters:@{@"scene":[NSString stringWithFormat:@"postId/%ld", postID],
                                      @"page" :@"pages/index/index",
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
    while (data.length > 100*1024) {
        data = UIImageJPEGRepresentation(image, tempX);
        tempX -= 0.1;
        if (data.length == length) {
            break;
        }
        length = data.length;
    }
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

- (NSMutableArray *)titleList
{
    if (!_titleList) {
        _titleList = [[NSMutableArray alloc] init];
    }
    return _titleList;
}

@end
