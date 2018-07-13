//
//  DTieMapShareView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/12.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"

@interface DTieMapShareView : UIView

- (instancetype)initWithModel:(DTieModel *)model shareImage:(UIImage *)image;

- (void)startShare;

- (void)startShareFriend;

- (void)savePhoto;

@end
