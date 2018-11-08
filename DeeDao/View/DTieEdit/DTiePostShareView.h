//
//  DTiePostShareView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/12.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"

@interface DTiePostShareView : UIView

- (instancetype)initWithModel:(DTieModel *)model;

- (void)startShare;

- (void)saveToAlbum;

@end
