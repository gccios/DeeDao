//
//  DDTelLoginViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/6/4.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"

typedef enum : NSUInteger {
    DDTelLoginPageType_Register,
    DDTelLoginPageType_Login
} DDTelLoginPageType;

@interface DDTelLoginViewController : DDViewController

@property (nonatomic, copy) void (^loginSucess)(void);

- (instancetype)initWithDDTelLoginType:(DDTelLoginPageType)type;

@end
