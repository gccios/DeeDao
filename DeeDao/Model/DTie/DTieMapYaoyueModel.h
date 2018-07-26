//
//  DTieMapYaoyueModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/26.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension.h>

@interface DTieMapYaoyueModel : NSObject

@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, assign) NSInteger postId;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger subType;
@property (nonatomic, assign) NSInteger authorId;

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, copy) NSString * sceneBuilding;
@property (nonatomic, copy) NSString * sceneAddress;
@property (nonatomic, assign) double sceneAddressLat;
@property (nonatomic, assign) double sceneAddressLng;

@end
