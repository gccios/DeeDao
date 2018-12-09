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
    }else if ([_datadictionaryType isEqualToString:@"CONTENT_POST"]){
        _type = DTieEditType_Post;
        
        [self handleDetailContenJson];
    }
}

- (void)setDetailContent:(NSString *)detailContent
{
    if ([detailContent hasPrefix:@"<p></p><img"]) {
        detailContent = [DDTool getImageURLWithHtml:detailContent];
    }else if ([detailContent hasPrefix:@"<p><font"]) {
        detailContent = [DDTool getTextWithHtml:detailContent];
    }
    
    if (_type == DTieEditType_Post) {
        [self handleDetailContenJson];
    }
    
    _detailsContent = detailContent;
    _detailContent = detailContent;
}

- (void)setWxCanSee:(NSInteger)wxCanSee
{
    _wxCanSee = wxCanSee;
    _shareEnable = wxCanSee;
}

- (void)setPostId:(NSInteger)postId
{
    if (_isPost) {
        
    }else{
        _postId = postId;
    }
}

- (void)configPostID:(NSInteger)postID
{
    _postId = postID;
}

- (void)handleDetailContenJson
{
    if (!isEmptyString(self.detailContent)) {
        NSData *jsonData = [self.detailContent dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
        
        _bloggerFlg = [[dic objectForKey:@"bloggerFlg"] integerValue];
        _nickname = [dic objectForKey:@"nickname"];
        _portraituri = [dic objectForKey:@"portrait"];
        NSDictionary * postBean = [dic objectForKey:@"postBean"];
        if (KIsDictionary(postBean)) {
            _postFirstPicture = [postBean objectForKey:@"postFirstPicture"];
            _postSummary = [postBean objectForKey:@"postSummary"];
            _sceneAddress = [postBean objectForKey:@"sceneAddress"];
            _sceneBuilding = [postBean objectForKey:@"sceneBuilding"];
            _updateTime = [[postBean objectForKey:@"updateTime"] integerValue];
            _postId = [[postBean objectForKey:@"id"] integerValue];
            _isPost = YES;
        }
    }
}

- (void)changeNoSelect
{
    self.isChoose = NO;
}

@end
