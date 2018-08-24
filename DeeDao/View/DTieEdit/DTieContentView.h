//
//  DTieContentView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/31.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTieModel.h"
#import "DDLocationManager.h"

@interface DTieContentView : UIView

@property (nonatomic, weak) UINavigationController * parentDDViewController;

@property (nonatomic, strong) NSMutableArray * modleSources;

@property (nonatomic, assign) NSInteger createTime;

@property (nonatomic, strong) UITextField * titleTextField;
@property (nonatomic, strong) UILabel * locationLabel;
@property (nonatomic, strong) UILabel * timeLabel;

@property (nonatomic, strong) BMKPoiInfo * choosePOI;

@property (nonatomic, strong) NSMutableArray * selectSource;
@property (nonatomic, assign) NSInteger shareType;
@property (nonatomic, assign) NSInteger landAccountFlg;

- (instancetype)initWithFrame:(CGRect)frame editModel:(DTieModel *)editModel;
- (void)showChoosePhotoPicker;

- (void)configChoosePOI:(BMKPoiInfo *)poi;

@end
