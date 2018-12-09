//
//  MapYaoyueFooterView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/11/8.
//  Copyright © 2018 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"

@interface MapYaoyueFooterView : UIView

@property (nonatomic, copy) void (^hiddenHandle)(void);
@property (nonatomic, copy) void (^deleteHandle)(void);
@property (nonatomic, copy) void (^yaoyueHandle)(void);
@property (nonatomic, copy) void (^uploadHandle)(void);

- (void)configWithDTieModel:(DTieModel *)model;

@end
