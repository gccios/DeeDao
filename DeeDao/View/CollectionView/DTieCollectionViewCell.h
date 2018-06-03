//
//  DTieCollectionViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/10.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"

@interface DTieCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView * contenImageView;

@property (nonatomic, strong) NSIndexPath * indexPath;

@property (nonatomic, copy) void (^deleteButtonHandle)(void);

- (void)configWithDTieModel:(DTieModel *)model;

- (void)confiEditEnable:(BOOL)edit;

@end
