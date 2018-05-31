//
//  UserInfoCollectionHeader.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@interface UserInfoCollectionHeader : UICollectionReusableView

- (void)configWithModel:(UserModel *)model;

@end