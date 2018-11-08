//
//  DTieWatchPhotoTableViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/10/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieEditModel.h"

@interface DTieWatchPhotoTableViewCell : UITableViewCell

@property (nonatomic, copy) void (^imageDidClicked)(DTieEditModel * editModel);

@property (nonatomic, assign) NSInteger WYYSelectType;
@property (nonatomic, assign) BOOL isAuthor;

- (void)resetStatus;

- (void)configWithModel:(DTieEditModel *)model index:(NSInteger)index;

@end
