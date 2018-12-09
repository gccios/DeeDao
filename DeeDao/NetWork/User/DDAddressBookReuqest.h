//
//  DDAddressBookReuqest.h
//  DeeDao
//
//  Created by 郭春城 on 2018/11/9.
//  Copyright © 2018 郭春城. All rights reserved.
//

#import "BGNetworkRequest.h"

@interface DDAddressBookReuqest : BGNetworkRequest

- (instancetype)initWithList;

- (instancetype)initWithAddressBookList:(NSArray *)list;

@end
