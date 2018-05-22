//
//  SeriesModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension.h>

@interface SeriesModel : NSObject

@property (nonatomic, assign) NSInteger createPerson;
@property (nonatomic, assign) NSInteger createTime;
@property (nonatomic, assign) NSInteger deleteFlg;
@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, assign) NSInteger seriesCollectionId;
@property (nonatomic, copy) NSString * seriesDesc;
@property (nonatomic, assign) NSInteger seriesOwnerId;
@property (nonatomic, assign) BOOL seriesStatus;
@property (nonatomic, copy) NSString * seriesTitle;
@property (nonatomic, assign) NSInteger seriesType;
@property (nonatomic, assign) NSInteger stickyFlag;
@property (nonatomic, assign) NSInteger stickyTime;
@property (nonatomic, assign) NSInteger updatePerson;
@property (nonatomic, assign) NSInteger updateTime;

@property (nonatomic, copy) NSString * seriesFirstPicture;

@end
