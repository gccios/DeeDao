//
//  DDAddressBookReuqest.m
//  DeeDao
//
//  Created by 郭春城 on 2018/11/9.
//  Copyright © 2018 郭春城. All rights reserved.
//

#import "DDAddressBookReuqest.h"

@implementation DDAddressBookReuqest

- (instancetype)initWithList
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"api/open/existPhoneList";
    }
    return self;
}

- (instancetype)initWithAddressBookList:(NSArray *)list
{
    if (self = [super init]) {
        self.httpMethod = BGNetworkRequestHTTPPost;
        self.methodName = @"api/open/synPhoneList";
        
        [self setValue:list forParamKey:@"phoneList"];
    }
    return self;
}

@end
