//
//  DTieSingleImageShareView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@interface DTieSingleImageShareView : UIView

- (instancetype)initWithModel:(UserModel *)model;

- (void)startShare;

@end
