//
//  EditSecurityController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"
#import "SecurityGroupModel.h"

@protocol EditSecurityDelegate <NSObject>

- (void)securityGroupDidEdit;

@end

@interface EditSecurityController : DDViewController

@property (nonatomic, weak) id<EditSecurityDelegate> delegate;

- (instancetype)initWithModel:(SecurityGroupModel *)model friends:(NSArray *)friends posts:(NSArray *)posts;

@end
