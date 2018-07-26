//
//  MapYaoyueHeaderView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"

@interface MapYaoyueHeaderView : UICollectionReusableView

@property (nonatomic, copy) void (^postHandle)(void);
@property (nonatomic, copy) void (^userHandle)(void);
@property (nonatomic, copy) void (^yaoyueHandle)(void);

- (void)configWithDTieModel:(DTieModel *)model;

@end
