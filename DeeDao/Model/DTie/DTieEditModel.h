//
//  DTieEditModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/11.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MJExtension.h>
#import <Photos/Photos.h>

typedef enum : NSUInteger {
    DTieEditType_Title,
    DTieEditType_Text,
    DTieEditType_Image,
    DTieEditType_Video,
    DTieEditType_Post
} DTieEditType;

@interface DTieEditModel : NSObject

//@property (nonatomic, copy) void (^needUpdateHeight)();

@property (nonatomic, assign) DTieEditType type;

//文字，图片，视频
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, copy) NSString * imageURL;
@property (nonatomic, strong) UIImage * videoImage;
@property (nonatomic, strong) NSURL * videoURL;
@property (nonatomic, assign) NSInteger shareEnable;
@property (nonatomic, strong) PHAsset * asset;

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

@property (nonatomic, assign) NSInteger dataLength;

@property (nonatomic, assign) BOOL isFirstImage;

//Post类型
@property (nonatomic, copy) NSString * portraituri;
@property (nonatomic, copy) NSString * nickname;
@property (nonatomic, copy) NSString * postFirstPicture;
@property (nonatomic, copy) NSString * postSummary;
@property (nonatomic, copy) NSString * sceneAddress;
@property (nonatomic, copy) NSString * sceneBuilding;
@property (nonatomic, assign) NSInteger updateTime;
@property (nonatomic, assign) NSInteger bloggerFlg;
@property (nonatomic, assign) BOOL isPost;

//@property (nonatomic, assign) CGFloat height;

@end
