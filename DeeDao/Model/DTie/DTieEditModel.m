//
//  DTieEditModel.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/11.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieEditModel.h"
#import "DDTool.h"

@implementation DTieEditModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"cid" : @"id"//前边的是你想用的key，后边的是返回的key
             };
}

- (instancetype)init
{
    if (self = [super init]) {
        self.detailsContent = @"";
    }
    return self;
}

- (void)setDatadictionaryType:(NSString *)datadictionaryType
{
    _datadictionaryType = datadictionaryType;
    if ([_datadictionaryType isEqualToString:@"CONTENT_TEXT"]) {
        _type = DTieEditType_Text;
    }else if ([_datadictionaryType isEqualToString:@"CONTENT_IMG"]){
        _type = DTieEditType_Image;
    }else if ([_datadictionaryType isEqualToString:@"CONTENT_VIDEO"]){
        _type = DTieEditType_Video;
    }
}

- (void)setDetailContent:(NSString *)detailContent
{
    if ([detailContent hasPrefix:@"<p></p><img"]) {
        detailContent = [DDTool getImageURLWithHtml:detailContent];
    }else if ([detailContent hasPrefix:@"<p><font"]) {
        detailContent = [DDTool getTextWithHtml:detailContent];
    }
    
    _detailsContent = detailContent;
    _detailContent = detailContent;
}

- (void)setWxCanSee:(NSInteger)wxCanSee
{
    _wxCanSee = wxCanSee;
    _shareEnable = wxCanSee;
}

@end
