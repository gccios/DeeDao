//
//  DTieModel.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/10.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DTieModel.h"
#import "DDTool.h"
#import "UserManager.h"

@implementation DTieModel

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"wyyList": @"UserModel", @"thankList": @"UserModel", @"collectList": @"UserModel", @"details":@"DTieEditModel"};
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"cid" : @"id"//前边的是你想用的key，后边的是返回的key
             };
}

- (void)setStatus:(NSInteger)status
{
    _status = status;
    if (_status == 0) {
        _dTieType = DTieType_Edit;
    }else if (_dTieType == 0) {
        _dTieType = DTieType_MyDtie;
    }
}

- (void)setCollectFlg:(NSInteger)collectFlg
{
    _collectFlg = collectFlg;
    if (_wyyFlg == 0 && _collectFlg == 1) {
        self.dTieType = DTieType_Collection;
    }
}

- (void)setWyyFlg:(NSInteger)wyyFlg
{
    _wyyFlg = wyyFlg;
    if (_wyyFlg == 1) {
        self.dTieType = DTieType_BeFondOf;
    }
}

- (void)setPostFirstPicture:(NSString *)postFirstPicture
{
    if ([postFirstPicture hasPrefix:@"<p></p><img"]) {
        postFirstPicture = [DDTool getImageURLWithHtml:postFirstPicture];
    }
    _postFirstPicture = [DDTool getImageURLWithHtml:postFirstPicture];
}

@end
