//
//  CreateOrUpdateSeriesRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface CreateOrUpdateSeriesRequest : BGNetworkRequest

- (instancetype)initWithStatus:(NSInteger)status seriesId:(NSInteger)seriesId seriesTitle:(NSString *)seriesTitle seriesType:(NSInteger)seriesType stickyFlag:(NSInteger)stickyFlag seriesOwnerId:(NSInteger)seriesOwnerId createPerson:(NSInteger)createPerson seriesDesc:(NSString *)seriesDesc deleteFlg:(NSInteger)deleteFlg seriesCollectionId:(NSInteger)seriesCollectionId postIdList:(NSArray *)postIdList;

@end
