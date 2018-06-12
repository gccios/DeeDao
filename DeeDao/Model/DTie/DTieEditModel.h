//
//  DTieEditModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/11.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MJExtension.h>

typedef enum : NSUInteger {
    DTieEditType_Title,
    DTieEditType_Text,
    DTieEditType_Image,
    DTieEditType_Video
} DTieEditType;

@interface DTieEditModel : NSObject

//@property (nonatomic, copy) void (^needUpdateHeight)();

@property (nonatomic, assign) DTieEditType type;

@property (nonatomic, strong) UIImage * image;
@property (nonatomic, copy) NSString * imageURL;
@property (nonatomic, strong) UIImage * videoImage;
@property (nonatomic, strong) NSURL * videoURL;
@property (nonatomic, assign) NSInteger shareEnable;

@property (nonatomic, copy) NSString * detailsContent;
@property (nonatomic, assign) NSInteger detailNumber;
@property (nonatomic, copy) NSString * detailContent;
@property (nonatomic, copy) NSString * textInformation;
@property (nonatomic, assign) NSInteger createTime;
@property (nonatomic, copy) NSString * datadictionaryType;
@property (nonatomic, copy) NSString * cid;
@property (nonatomic, assign) NSInteger pFlag;
@property (nonatomic, assign) NSInteger postId;
@property (nonatomic, assign) NSInteger wxCanSee;

//@property (nonatomic, assign) CGFloat height;

@end
