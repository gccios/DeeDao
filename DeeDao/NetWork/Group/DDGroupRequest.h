//
//  DDGroupRequest.h
//  DeeDao
//
//  Created by 郭春城 on 2019/1/10.
//  Copyright © 2019 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDGroupRequest : BGNetworkRequest

- (instancetype)initWithSelectGroupList;

- (instancetype)initCreateWithTitle:(NSString *)name reamrk:(NSString *)remark groupPic:(NSString *)groupPic joinAuthorize:(NSInteger)joinAuthorize groupState:(NSInteger)groupState readWriteAuthorize:(NSInteger)readWriteAuthorize groupSearchState:(NSInteger)groupSearchState;

- (instancetype)initUpdateWithID:(NSInteger)groupID title:(NSString *)name reamrk:(NSString *)remark groupPic:(NSString *)groupPic joinAuthorize:(NSInteger)joinAuthorize groupState:(NSInteger)groupState readWriteAuthorize:(NSInteger)readWriteAuthorize groupSearchState:(NSInteger)groupSearchState;

- (instancetype)initApplyPeopleWithGroupID:(NSInteger)groupID;

- (instancetype)initApplyWithID:(NSString *)applyID state:(BOOL)state;

- (instancetype)initApplyPostWithID:(NSString *)applyID state:(BOOL)state;

- (instancetype)initApplyPeopleListWithGroupID:(NSInteger)groupID;

- (instancetype)initApplyPostListWithGroupID:(NSInteger)groupID;

- (instancetype)initGroupPeopleListWithGroupID:(NSInteger)groupID;

- (instancetype)initGroupPostListWithGroupID:(NSInteger)groupID;

- (instancetype)initAddGroupListWithPostID:(NSInteger)postID;

- (instancetype)initAddPost:(NSInteger)postID toGroup:(NSInteger)groupID;

- (instancetype)initRemovePost:(NSInteger)postID fromGroup:(NSInteger)groupID;

- (instancetype)initWithGroupDetail:(NSInteger)groupID;

- (instancetype)initGiveGroup:(NSInteger)groupID toUser:(NSInteger)userID;

- (instancetype)initDeleteGroup:(NSInteger)groupID;

- (instancetype)initQiutGroup:(NSInteger)groupID;

- (instancetype)initMoveUser:(NSInteger)userID toApplyGroup:(NSInteger)groupID;

- (instancetype)initMovePost:(NSInteger)userID toApplyGroup:(NSInteger)groupID;

- (instancetype)initGetPostGroupListWithPostID:(NSInteger)postID;

- (instancetype)initEditPost:(NSInteger)postID accountFlg:(NSInteger)accountFlg;

@end

NS_ASSUME_NONNULL_END
