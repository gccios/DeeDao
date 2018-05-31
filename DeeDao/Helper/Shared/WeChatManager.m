//
//  WeChatManager.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "WeChatManager.h"
#import "MBProgressHUD+DDHUD.h"
#import "ShareImageItem.h"
#import <Social/Social.h>

#define KCompressibilityFactor 1280.00  

NSString * const DDUserDidGetWeChatCodeNotification = @"DDUserDidGetWeChatCodeNotification";

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
//    BOOL ret = [SLComposeViewController isAvailableForServiceType:@"com.tencent.xin.sharetimeline"];
//
//    self.slCompose = [SLComposeViewController composeViewControllerForServiceType:@"com.tencent.xin.sharetimeline"];
//    if (!self.slCompose) {
//        [MBProgressHUD showTextHUDWithText:@"系统错误" inView:viewController.view];
//        return;
//    }
    
    NSMutableArray * shareItems = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < images.count; i++) {
//        NSString * path = [NSString stringWithFormat:@"%@/TimeLine%ld.jpg", DDDocumentPath, i];
        
        UIImage * image = [self getJPEGImagerImg:[images objectAtIndex:i]];
//        BOOL ret = [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
//        if (ret) {
//            NSLog(@"写入成功%@", path);
//        }else{
//            NSLog(@"写入失败%@", path);
//        }
//        ShareImageItem * item = [[ShareImageItem alloc] initWithData:image andFile:[NSURL URLWithString:path]];
        [shareItems addObject:image];
        
//        [self.slCompose addURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    }
//    [viewController presentViewController:self.slCompose animated:YES completion:^{
//
//    }];
//    self.slCompose.completionHandler = ^(SLComposeViewControllerResult result) {
//
//    };
    
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

- (void)shareMiniProgramWithPostID:(NSInteger)postID image:(UIImage *)image
{
    self.isShare = YES;
    
    WXMiniProgramObject * program = [WXMiniProgramObject object];
    program.webpageUrl = @"http://www.deedao.com";
    program.userName = @"gh_3714b00f2a4c";
    program.path = [NSString stringWithFormat:@"pages/detail/detail?postId=%ld", postID];
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

@end
