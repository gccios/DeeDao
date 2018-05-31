//
//  DTieContentView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/31.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"

@interface DTieContentView : UIView

@property (nonatomic, weak) UINavigationController * parentDDViewController;

- (instancetype)initWithFrame:(CGRect)frame editModel:(DTieModel *)editModel;

@property (nonatomic, strong) UITextField * titleTextField;
@property (nonatomic, strong) UILabel * locationLabel;
@property (nonatomic, strong) UILabel * timeLabel;

- (void)showChoosePhotoPicker;

@end
