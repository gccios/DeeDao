//
//  MapShowYaoyueView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieMapYaoyueModel.h"
#import "DDGroupModel.h"

@interface MapShowYaoyueView : UIView

- (instancetype)initWithModel:(DTieMapYaoyueModel *)model groupModel:(DDGroupModel *)groupModel;

- (void)show;

@end
