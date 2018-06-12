//
//  MailDetailViewController.h
//  DeeDao
//
//  Created by 郭春城 on 2018/5/18.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDViewController.h"
#import "MailModel.h"

@protocol DTieMailDelegate <NSObject>

- (void)userDidAgreementFriend:(MailModel *)model;

@end

@interface MailDetailViewController : DDViewController

@property (nonatomic, weak) id<DTieMailDelegate> delegate;

- (instancetype)initMailModel:(MailModel *)model;

@end
