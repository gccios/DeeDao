//
//  DDGroupCollectionViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2019/1/3.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDGroupModel.h"

@interface DDGroupCollectionViewCell : UICollectionViewCell

- (void)configWithModel:(DDGroupModel *)model;

- (void)hiddenChooseImageView;
- (void)showChooseImageView;

@property (nonatomic, copy) void (^groupDidChooseHandle)(void);

@end
