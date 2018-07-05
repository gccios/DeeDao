//
//  QNDDUploadManager.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/15.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "QNDDUploadManager.h"
#import <QN_GTM_Base64.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "DDTool.h"

@interface QNDDUploadManager ()

@property (nonatomic, strong) QNUploadManager * uploadManager;

@property (nonatomic, strong) NSMutableArray * handleURLArray;

@end

@implementation QNDDUploadManager

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)uploadImage:(UIImage *)image progress:(QNUpProgressHandler)progressHandle success:(QNUpSuccess)success failed:(QNUpFailed)failed
{
    NSData*  data = [NSData data];
    data = UIImageJPEGRepresentation(image, 1);
    float tempX = 0.9;
    NSInteger length = data.length;
    while (data.length > 500*1024) {
        data = UIImageJPEGRepresentation(image, tempX);
        tempX -= 0.1;
        if (data.length == length) {
            break;
        }
        length = data.length;
    }
    
    NSString * token = [self createUploadToken];
    
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone = [QNFixedZone zone0];
    }];
    
    QNUploadOption * option = [[QNUploadOption alloc] initWithProgressHandler:progressHandle];
    
    self.uploadManager = [[QNUploadManager alloc] initWithConfiguration:config];
    [self.uploadManager putData:data key:nil token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        
        if (info.statusCode == 200) {
            NSString * name = [resp objectForKey:@"key"];
            if (!isEmptyString(name)) {
                success([NSString stringWithFormat:@"%@/%@", QNEndPoint, name]);
            }
        }else{
            failed(info.error);
        }
        
    } option:option];
}

- (void)uploadVideoWith:(UIImage *)image filePath:(NSURL *)path progress:(QNUpProgressHandler)progressHandle success:(QNUpSuccess)success failed:(QNUpFailed)failed
{
    NSData * data = [NSData dataWithContentsOfURL:path];
    
    NSString * token = [self createUploadToken];
    
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone = [QNFixedZone zone0];
    }];
    
    QNUploadOption * option = [[QNUploadOption alloc] initWithProgressHandler:progressHandle];
    
    self.uploadManager = [[QNUploadManager alloc] initWithConfiguration:config];
    [self.uploadManager putData:data key:nil token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        
        if (info.statusCode == 200) {
            NSString * name = [resp objectForKey:@"key"];
            if (!isEmptyString(name)) {
                success([NSString stringWithFormat:@"%@/%@", QNEndPoint, name]);
            }
        }else{
            failed(info.error);
        }
        
    } option:option];
}

- (void)uploadPHAsset:(PHAsset *)asset progress:(QNUpProgressHandler)progressHandle success:(QNUpSuccess)success failed:(QNUpFailed)failed
{
    NSString * token = [self createUploadToken];
    
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone = [QNFixedZone zone0];
    }];
    
    QNUploadOption * option = [[QNUploadOption alloc] initWithProgressHandler:progressHandle];
    
    self.uploadManager = [[QNUploadManager alloc] initWithConfiguration:config];
    [self.uploadManager putPHAsset:asset key:nil token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        
        if (info.statusCode == 200) {
            NSString * name = [resp objectForKey:@"key"];
            if (!isEmptyString(name)) {
                success([NSString stringWithFormat:@"%@/%@", QNEndPoint, name]);
            }
        }else{
            failed(info.error);
        }
        
    } option:option];
}

//生成上传token
- (NSString *)createUploadToken
{
    NSMutableDictionary *uploadInfo = [NSMutableDictionary dictionary];
    
    [uploadInfo setObject:QNBucketName forKey:@"scope"];
    [uploadInfo
     setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970] + 3600]
     forKey:@"deadline"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:uploadInfo options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *encodedString = [self urlSafeBase64Encode:jsonData];
    
    NSString *encodedSignedString = [self HMACSHA1:QNAccessKeySecret text:encodedString];
    
    NSString *token = [NSString stringWithFormat:@"%@:%@:%@", QNAccessKeyID, encodedSignedString, encodedString];
    
    return token;
}

- (NSString *)urlSafeBase64Encode:(NSData *)text {
    
    NSString *base64 =
    [[NSString alloc] initWithData:[QN_GTM_Base64 encodeData:text] encoding:NSUTF8StringEncoding];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    return base64;
}

- (NSString *)HMACSHA1:(NSString *)key text:(NSString *)text {
    
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    
    char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    NSString *hash = [self urlSafeBase64Encode:HMAC];
    return hash;
}

@end
