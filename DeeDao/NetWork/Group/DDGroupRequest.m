//
//  DDGroupRequest.m
//  DeeDao
//
//  Created by 郭春城 on 2019/1/10.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "DDGroupRequest.h"

@implementation DDGroupRequest

- (instancetype)initWithSelectGroupList
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = @"deedaoGroup/selectMyAndPublicDeedaoGroup";
    }
    return self;
}

- (instancetype)initCreateWithTitle:(NSString *)name reamrk:(NSString *)remark groupPic:(NSString *)groupPic joinAuthorize:(NSInteger)joinAuthorize groupState:(NSInteger)groupState readWriteAuthorize:(NSInteger)readWriteAuthorize groupSearchState:(NSInteger)groupSearchState
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"deedaoGroup/addDeedaoGroup";
        
        [self setValue:name forParamKey:@"groupName"];
        [self setValue:remark forParamKey:@"description"];
        [self setValue:groupPic forParamKey:@"groupPic"];
        [self setIntegerValue:joinAuthorize forParamKey:@"joinAuthorize"];
        [self setIntegerValue:groupState forParamKey:@"groupState"];
        [self setIntegerValue:readWriteAuthorize forParamKey:@"readWriteAuthorize"];
        [self setIntegerValue:groupSearchState forParamKey:@"groupSearchState"];
    }
    return self;
}

- (instancetype)initUpdateWithID:(NSInteger)groupID title:(NSString *)name reamrk:(NSString *)remark groupPic:(NSString *)groupPic joinAuthorize:(NSInteger)joinAuthorize groupState:(NSInteger)groupState readWriteAuthorize:(NSInteger)readWriteAuthorize groupSearchState:(NSInteger)groupSearchState
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"deedaoGroup/editDeedaoGroup";
        
        [self setIntegerValue:groupID forParamKey:@"id"];
        [self setValue:name forParamKey:@"groupName"];
        [self setValue:remark forParamKey:@"description"];
        [self setValue:groupPic forParamKey:@"groupPic"];
        [self setIntegerValue:joinAuthorize forParamKey:@"joinAuthorize"];
        [self setIntegerValue:groupState forParamKey:@"groupState"];
        [self setIntegerValue:readWriteAuthorize forParamKey:@"readWriteAuthorize"];
        [self setIntegerValue:groupSearchState forParamKey:@"groupSearchState"];
    }
    return self;
}

- (instancetype)initApplyPeopleWithGroupID:(NSInteger)groupID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"deedaoGroup/manager/applyGroupMembership";
        
        [self setIntegerValue:groupID forParamKey:@"groupId"];
    }
    return self;
}

- (instancetype)initApplyWithID:(NSString *)applyID state:(BOOL)state
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"deedaoGroup/manager/managementApplyGroupMembership";
        
        [self setValue:applyID forParamKey:@"applyId"];
        [self setBOOLValue:state forParamKey:@"decision"];
    }
    return self;
}

- (instancetype)initApplyPostWithID:(NSString *)applyID state:(BOOL)state
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"deedaoGroup/manager/managementApplyGroupPostAdd";
        
        [self setValue:applyID forParamKey:@"applyId"];
        [self setBOOLValue:state forParamKey:@"decision"];
    }
    return self;
}

- (instancetype)initApplyPeopleListWithGroupID:(NSInteger)groupID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [NSString stringWithFormat:@"deedaoGroup/manager/getApplyGroupMembershipList/%ld", groupID];
    }
    return self;
}

- (instancetype)initApplyPostListWithGroupID:(NSInteger)groupID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [NSString stringWithFormat:@"deedaoGroup/manager/getApplyGroupPostAddList/%ld", groupID];
    }
    return self;
}

- (instancetype)initGroupPostListWithGroupID:(NSInteger)groupID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [NSString stringWithFormat:@"deedaoGroup/manager/getGroupPostList/%ld", groupID];
    }
    return self;
}

- (instancetype)initGroupPeopleListWithGroupID:(NSInteger)groupID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [NSString stringWithFormat:@"deedaoGroup/manager/getGroupMembershipList/%ld", groupID];
    }
    return self;
}

- (instancetype)initAddGroupListWithPostID:(NSInteger)postID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [NSString stringWithFormat:@"deedaoGroup/groupPostFlagList/%ld", postID];
    }
    return self;
}

- (instancetype)initAddPost:(NSInteger)postID toGroup:(NSInteger)groupID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"deedaoGroup/manager/applyGroupPostAdd";
        
        [self setIntegerValue:postID forParamKey:@"postId"];
        [self setIntegerValue:groupID forParamKey:@"groupId"];
    }
    return self;
}

- (instancetype)initRemovePost:(NSInteger)postID fromGroup:(NSInteger)groupID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"deedaoGroup/manager/deletePostFromGroup";
        
        [self setIntegerValue:postID forParamKey:@"postId"];
        [self setIntegerValue:groupID forParamKey:@"groupId"];
    }
    return self;
}

- (instancetype)initWithGroupDetail:(NSInteger)groupID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [NSString stringWithFormat:@"deedaoGroup/selectGroupDetail/%ld", groupID];
    }
    return self;
}

- (instancetype)initGiveGroup:(NSInteger)groupID toUser:(NSInteger)userID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"deedaoGroup/changeGroupManager";
        
        [self setIntegerValue:groupID forParamKey:@"groupId"];
        [self setIntegerValue:userID forParamKey:@"userId"];
    }
    return self;
}

- (instancetype)initDeleteGroup:(NSInteger)groupID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"deedaoGroup/deleteGroup";
        
        [self setIntegerValue:groupID forParamKey:@"groupId"];
    }
    return self;
}

- (instancetype)initQiutGroup:(NSInteger)groupID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"deedaoGroup/manager/quitGroup";
        
        [self setIntegerValue:groupID forParamKey:@"groupId"];
    }
    return self;
}

- (instancetype)initMoveUser:(NSInteger)userID toApplyGroup:(NSInteger)groupID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"deedaoGroup/manager/moveUserToApplyList";
        
        [self setIntegerValue:userID forParamKey:@"userId"];
        [self setIntegerValue:groupID forParamKey:@"groupID"];
    }
    return self;
}

- (instancetype)initMovePost:(NSInteger)userID toApplyGroup:(NSInteger)groupID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"deedaoGroup/manager/movePostToApplyList";
        
        [self setIntegerValue:userID forParamKey:@"postId"];
        [self setIntegerValue:groupID forParamKey:@"groupID"];
    }
    return self;
}

- (instancetype)initGetPostGroupListWithPostID:(NSInteger)postID
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = [NSString stringWithFormat:@"deedaoGroup/manager/selectGroupByPost/%ld", postID];
    }
    return self;
}

- (instancetype)initEditPost:(NSInteger)postID accountFlg:(NSInteger)accountFlg
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"post/editLandAccountFlg";
        
        [self setIntegerValue:postID forParamKey:@"postId"];
        [self setIntegerValue:accountFlg forParamKey:@"accountFlag"];
    }
    return self;
}

- (instancetype)initEditVIPWithID:(NSInteger)listID groupId:(NSInteger)groupId userId:(NSInteger)userId authority:(NSInteger)authority state:(NSInteger)state
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"deedaoGroup/manager/editGroupMember";
        
        [self setIntegerValue:listID forParamKey:@"id"];
        [self setIntegerValue:groupId forParamKey:@"groupId"];
        [self setIntegerValue:userId forParamKey:@"userId"];
        [self setIntegerValue:authority forParamKey:@"authority"];
        [self setIntegerValue:state forParamKey:@"state"];
    }
    return self;
}

- (instancetype)initCheckGroupNew
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPGet;
        self.methodName = @"deedaoGroup/selectDeedaoGroupNewFlag";
    }
    return self;
}

@end
