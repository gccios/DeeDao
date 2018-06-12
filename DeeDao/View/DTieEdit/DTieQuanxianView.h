//
//  DTieQuanxianView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/31.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"
#import "SecurityGroupModel.h"

@interface DTieQuanxianView : UIView

@property (nonatomic, strong) NSMutableArray * selectSource;
@property (nonatomic, assign) NSInteger shareType;
@property (nonatomic, assign) NSInteger landAccountFlg;

- (instancetype)initWithFrame:(CGRect)frame editModel:(DTieModel *)editModel;

@end
