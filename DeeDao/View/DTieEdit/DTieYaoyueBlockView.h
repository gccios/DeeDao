//
//  DTieYaoyueBlockView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/8/21.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserYaoYueBlockModel.h"

@interface DTieYaoyueBlockView : UIView

@property (nonatomic, copy) void (^removeDidClicked)(UserYaoYueBlockModel * blockModel);

- (instancetype)initWithBlockModel:(UserYaoYueBlockModel *)model isAuthor:(BOOL)isAuthor;

@end
