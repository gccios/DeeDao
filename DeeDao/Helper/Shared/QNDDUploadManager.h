//
//  QNDDUploadManager.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/15.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QiniuSDK.h>

typedef void(^QNUpSuccess)(NSString * url);
typedef void(^QNUpFailed)(NSError * error);

@interface QNDDUploadManager : NSObject

- (void)uploadImage:(UIImage *)image progress:(QNUpProgressHandler)progressHandle success:(QNUpSuccess)success failed:(QNUpFailed)failed;

- (void)uploadVideoWith:(UIImage *)image filePath:(NSURL *)path progress:(QNUpProgressHandler)progressHandle success:(QNUpSuccess)success failed:(QNUpFailed)failed;

@end
