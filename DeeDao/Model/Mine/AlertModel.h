//
//  AlertModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertModel : NSObject

- (instancetype)initWithTitle:(NSString *)title status:(BOOL)status type:(NSInteger)type;

@property (nonatomic, copy) NSString * title;
@property (nonatomic, assign) BOOL openStatus;
@property (nonatomic, assign) NSInteger type;

@end
