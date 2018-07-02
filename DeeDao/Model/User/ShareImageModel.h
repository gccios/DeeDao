//
//  ShareImageModel.h
//  DeeDao
//
//  Created by 郭春城 on 2018/6/8.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareImageModel : NSObject

@property (nonatomic, assign) NSInteger postId;
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, strong) UIImage * codeImage;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * detail;
@property (nonatomic, assign) NSInteger PFlag;

@end
