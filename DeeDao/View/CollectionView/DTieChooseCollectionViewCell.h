//
//  DTieChooseCollectionViewCell.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/25.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieCollectionViewCell.h"

@interface DTieChooseCollectionViewCell : DTieCollectionViewCell

- (void)configSelectStatus:(BOOL)selectStaus;

@property (nonatomic, assign) BOOL isSelect;

@end