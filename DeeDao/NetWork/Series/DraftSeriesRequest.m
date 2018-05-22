//
//  DraftSeriesRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/22.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DraftSeriesRequest.h"

@implementation DraftSeriesRequest

- (instancetype)initWithStatus:(NSInteger)status seriesId:(NSInteger)seriesId seriesTitle:(NSString *)seriesTitle seriesType:(NSInteger)seriesType stickyFlag:(NSInteger)stickyFlag seriesOwnerId:(NSInteger)seriesOwnerId createPerson:(NSInteger)createPerson seriesDesc:(NSString *)seriesDesc deleteFlg:(NSInteger)deleteFlg seriesCollectionId:(NSInteger)seriesCollectionId postIdList:(NSArray *)postIdList
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"series/addOrUpdateDraftSeries";
        
        if (seriesId) {
            [self setIntegerValue:seriesId forParamKey:@"seriesId"];
        }
        
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setObject:@(createPerson) forKey:@"createPerson"];
        [dict setObject:@(deleteFlg) forKey:@"deleteFlg"];
        [dict setObject:@(seriesCollectionId) forKey:@"seriesCollectionId"];
        [dict setObject:seriesDesc forKey:@"seriesDesc"];
        [dict setObject:@(seriesOwnerId) forKey:@"seriesOwnerId"];
        [dict setObject:@(status) forKey:@"seriesStatus"];
        [dict setObject:seriesTitle forKey:@"seriesTitle"];
        [dict setObject:@(seriesType) forKey:@"seriesType"];
        
        [self setValue:dict forParamKey:@"series"];
        
        [self setValue:postIdList forParamKey:@"postIdList"];
    }
    return self;
}

@end
