//
//  CommentModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/23.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension.h>

@interface CommentModel : NSObject

@property (nonatomic, copy) NSString * postViewId;
@property (nonatomic, copy) NSString * commentContent;
@property (nonatomic, assign) NSInteger commentId;
@property (nonatomic, assign) NSInteger commentTime;
@property (nonatomic, assign) NSInteger commentatorId;
@property (nonatomic, copy) NSString * commentatorName;
@property (nonatomic, copy) NSString * commentatorPic;
@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, copy) NSString * toCommentatorName;
@property (nonatomic, copy) NSString * toCommentatorPic;

@end
