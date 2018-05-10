//
//  DTieModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/10.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    DTieType_Add,
    DTieType_Edit,
    DTieType_Collection,
    DTieType_BeFondOf,
    DTieType_MyDtie
} DTieType;

@interface DTieModel : NSObject

@property (nonatomic, copy) NSString * title;
@property (nonatomic, assign) DTieType type;

@end
