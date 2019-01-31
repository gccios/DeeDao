//
//  MapShowPostView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/20.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"
#import "DDGroupModel.h"

@interface MapShowPostView : UIView

@property (nonatomic, copy) void (^uploadHandle)(DTieModel * dtieModel);

- (instancetype)initWithModel:(DTieModel *)model source:(NSArray *)source index:(NSInteger)index groupModel:(DDGroupModel *)groupModel;

- (void)show;

@end
