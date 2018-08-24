//
//  UserYaoYueBlockModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension.h>

@interface UserYaoYueBlockModel : NSObject

@property (nonatomic, assign) NSInteger postID;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, copy) NSString * nickname;
@property (nonatomic, copy) NSString * portrait;
@property (nonatomic, assign) NSInteger subtype;

@end
