//
//  DTieDetailImageTableViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/17.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"

@interface DTieDetailImageTableViewCell : UITableViewCell

//- (void)configWithModel:(DTieEditModel *)model;

- (void)configWithModel:(DTieEditModel *)model Dtie:(DTieModel *)dtieModel;

//- (void)configWithCanSee:(BOOL)cansee;

//- (void)yulanWithModel:(DTieEditModel *)model;

@end
