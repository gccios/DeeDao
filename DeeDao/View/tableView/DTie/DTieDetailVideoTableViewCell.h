//
//  DTieDetailVideoTableViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/17.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"

@interface DTieDetailVideoTableViewCell : UITableViewCell

//- (void)configWithCanSee:(BOOL)cansee;
//
//- (void)configWithModel:(DTieEditModel *)model;

- (void)configWithModel:(DTieEditModel *)model Dtie:(DTieModel *)dtieModel;

//- (void)yulanWithModel:(DTieEditModel *)model;

@end
