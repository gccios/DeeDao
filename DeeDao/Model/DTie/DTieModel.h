//
//  DTieModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/10.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTieEditModel.h"
#import "UserModel.h"

typedef enum : NSUInteger {
    DTieType_Add,
    DTieType_Edit,
    DTieType_Collection,
    DTieType_BeFondOf,
    DTieType_MyDtie
} DTieType;

@interface DTieModel : NSObject

@property (nonatomic, assign) DTieType dTieType;

@property (nonatomic, assign) NSInteger ifCanSee;

@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, assign) NSInteger authorId;
@property (nonatomic, assign) NSInteger collectCount;
@property (nonatomic, assign) NSInteger collectFlg;
@property (nonatomic, assign) NSInteger dzfCount;
@property (nonatomic, assign) NSInteger dzfFlg;
@property (nonatomic, assign) NSInteger messageCount;
@property (nonatomic, copy) NSString * nickname;
@property (nonatomic, copy) NSString * portraituri;
@property (nonatomic, copy) NSString * postFirstPicture;
@property (nonatomic, assign) NSInteger postId;
@property (nonatomic, copy) NSString * postSummary;
@property (nonatomic, copy) NSString * postTypeName;
@property (nonatomic, copy) NSString * sceneAddress;
@property (nonatomic, copy) NSString * sceneBuilding;
@property (nonatomic, assign) double sceneAddressLat;
@property (nonatomic, assign) double sceneAddressLng;
@property (nonatomic, assign) NSInteger sceneTime;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) NSInteger thankCount;
@property (nonatomic, assign) NSInteger thankFlg;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger updateTime;
@property (nonatomic, assign) NSInteger wyyCount;
@property (nonatomic, assign) NSInteger wyyFlg;
@property (nonatomic, assign) NSInteger createTime;
@property (nonatomic, assign) NSInteger deleteFlg;
@property (nonatomic, assign) NSInteger landAccountFlg;
@property (nonatomic, strong) NSArray * allowToSeeList;

@property (nonatomic, strong) NSArray * postPictureList;
@property (nonatomic, strong) NSArray * wyyList;
@property (nonatomic, strong) NSArray * thankList;
@property (nonatomic, strong) NSArray * collectList;
@property (nonatomic, strong) NSArray * details;

@end
