//
//  SeriesDetailModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension.h>
#import "DTieModel.h"

@interface SeriesDetailModel : NSObject

@property (nonatomic, copy) NSString * seriesTitle;
@property (nonatomic, copy) NSString * authorNickname;
@property (nonatomic, copy) NSString * authorPortrait;
@property (nonatomic, assign) NSInteger seriesCreatTime;
@property (nonatomic, strong) NSArray * postShowDetailRes;

@end
