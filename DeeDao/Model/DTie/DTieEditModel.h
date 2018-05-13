//
//  DTieEditModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/11.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    DTieEditType_Title,
    DTieEditType_Text,
    DTieEditType_Image,
    DTieEditType_Video
} DTieEditType;

@interface DTieEditModel : NSObject

//@property (nonatomic, copy) void (^needUpdateHeight)();

@property (nonatomic, assign) DTieEditType type;
@property (nonatomic, copy) NSString * text;

@property (nonatomic, strong) UIImage * image;
@property (nonatomic, copy) NSString * imageURL;
@property (nonatomic, copy) NSString * imageQiniuURL;
@property (nonatomic, strong) UIImage * videoImage;
@property (nonatomic, copy) NSString * videoURL;
@property (nonatomic, copy) NSString * videoQiniuURL;

//@property (nonatomic, assign) CGFloat height;

@end
