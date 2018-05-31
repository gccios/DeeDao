//
//  DDShareImageCollectionViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/28.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDShareImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UITapGestureRecognizer * tap;

@property (nonatomic, copy) void (^cancleButtonClicked)(void);

- (void)configImageWith:(UIImage *)image isEdit:(BOOL)isEdit;

- (void)configEdit:(NSNumber *)isEdit;

@end