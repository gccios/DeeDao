//
//  DTieEditTextTableViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/11.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieEditModel.h"
#import "RDTextView.h"

@interface DTieEditTextTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL canSee;

- (void)configWithEditModel:(DTieEditModel *)model;

@end
