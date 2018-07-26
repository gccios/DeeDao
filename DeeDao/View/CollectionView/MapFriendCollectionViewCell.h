//
//  MapFriendCollectionViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@interface MapFriendCollectionViewCell : UICollectionViewCell

- (void)configWithModel:(UserModel *)model;

- (void)configSelectStatus:(BOOL)status;

@end
