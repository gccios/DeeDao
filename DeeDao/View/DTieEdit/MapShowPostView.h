//
//  MapShowPostView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/20.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"

@interface MapShowPostView : UIView

- (instancetype)initWithModel:(DTieModel *)model source:(NSArray *)source index:(NSInteger)index;

- (void)show;

@end
