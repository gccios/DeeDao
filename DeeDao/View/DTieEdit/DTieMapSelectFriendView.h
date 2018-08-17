//
//  DTieMapSelectFriendView.h
//  DeeDao
//
//  Created by 郭春城 on 2018/7/24.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTieMapSelectFriendView;
@protocol DTieMapSelecteFriendDelegate <NSObject>

- (void)mapSelectFriendView:(DTieMapSelectFriendView *)selectView didSelectFriend:(NSArray *)selectFriend;

@end

@interface DTieMapSelectFriendView : UIView

@property (nonatomic, weak) id<DTieMapSelecteFriendDelegate> delegate;

- (instancetype)initWithFrendSource:(NSArray *)source;

- (void)show;

- (void)clear;

@end
