//
//  DTieHeaderLogoCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"

@interface DTieHeaderLogoCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView * contenImageView;

@property (nonatomic, strong) UIView * coverView;

@property (nonatomic, strong) NSIndexPath * indexPath;

@property (nonatomic, copy) void (^deleteButtonHandle)(void);

- (void)configWithDTieModel:(DTieModel *)model;

- (void)confiEditEnable:(BOOL)edit;

@end
