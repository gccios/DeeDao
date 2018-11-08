//
//  CreateDTieRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/15.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"
#import "DDLocationManager.h"

@interface CreateDTieRequest : BGNetworkRequest

- (instancetype)initWithList:(NSArray *)array title:(NSString *)title address:(NSString *)address building:(NSString *)building addressLng:(double)addressLng addressLat:(double)addressLat status:(NSInteger)status remindFlg:(NSInteger)remindFlg firstPic:(NSString *)firstPic postID:(NSInteger)postId landAccountFlg:(NSInteger)landAccountFlg allowToSeeList:(NSArray *)allowToSeeList sceneTime:(NSInteger)sceneTime;

- (void)configRemark:(NSString *)remark;

- (instancetype)initChangeFirstPicWithPostID:(NSInteger)postID image:(NSString *)image;

- (instancetype)initAddWithPostID:(NSInteger)postID blocks:(NSArray *)blocks;

- (instancetype)initAddWYYWithPostID:(NSInteger)postID blocks:(NSArray *)blocks;

- (instancetype)initRepelaceWithPostID:(NSInteger)postID details:(NSArray *)details;

@end
