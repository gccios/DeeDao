//
//  SecurityUserCollectionViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@interface SecurityUserCollectionViewCell : UICollectionViewCell

@property (nonatomic, copy) void (^cancleButtonHandle)(void);

- (void)configWithModel:(UserModel *)model;

- (void)configAddCell;

@end
