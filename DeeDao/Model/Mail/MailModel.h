//
//  MailModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/18.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MailModelType_Share,
    MailModelType_Collect,
    MailModelType_Message,
    MailModelType_SayHello
} MailModelType;

@interface MailModel : NSObject

@end
