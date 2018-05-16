//
//  DDNetworkConfiguration.m
//  DeeDao
//
//  Created by 郭春城 on 2018/5/9.
//  Copyright © 2018年 郭春城. All rights reserved.
//

#import "DDNetworkConfiguration.h"
#import "DesUtil.h"
#import "BGUtilFunction.h"

@implementation DDNetworkConfiguration

-(NSString *)baseURLString {
    return HOSTURL;
}

- (NSDictionary *)requestCommonHTTPHeaderFields {
    return @{
             @"Content-Type":@"application/json;charset:utf-8",
             @"User-Agent":@"iPhone",
             };
}


- (NSDictionary *)requestHTTPHeaderFields:(BGNetworkRequest *)request {
    NSMutableDictionary *allHTTPHeaderFileds = [[self requestCommonHTTPHeaderFields] mutableCopy];
    [request.requestHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        allHTTPHeaderFileds[key] = obj;
    }];
    return allHTTPHeaderFileds;
}

-(NSString *)queryStringForURLWithRequest:(BGNetworkRequest *)request{
    
    switch (request.httpMethod) {
        case BGNetworkRequestHTTPGet: {
            NSString *paramString = BGQueryStringFromParamDictionary(request.parametersDic);
            return [NSString stringWithFormat:@"%@", paramString];
        }
        case BGNetworkRequestHTTPPost: {
            return nil;
        }
        default:
            break;
    }
}

- (NSData *)httpBodyDataWithRequest:(BGNetworkRequest *)request{
    if(request.httpMethod == BGNetworkRequestHTTPGet || !request.parametersDic.count){
        return nil;
    }
    NSError *error = nil;
    NSData *httpBody = [NSJSONSerialization dataWithJSONObject:request.parametersDic options: (NSJSONWritingOptions)0 error:&error];
    if(error){
        return nil;
    }
    //加密
    if([request.requestHTTPHeaderFields[@"des"] isEqualToString:@"true"]) {
        httpBody = [DesUtil encryptUseDESWithData:httpBody key:kEncryptOrDecryptKey];
    }
    return httpBody;
}

- (BOOL)shouldBusinessSuccessWithResponseData:(NSDictionary *)responseData task:(NSURLSessionDataTask *)task request:(BGNetworkRequest *)request {
    return YES;
}

- (NSData *)decryptResponseData:(NSData *)responseData response:(NSURLResponse *)response request:(BGNetworkRequest *)request{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSString *des = [httpResponse.allHeaderFields objectForKey:@"des"];
    if([des isEqualToString:@"true"]){
        responseData = [DesUtil decryptUseDESWithData:responseData key:kEncryptOrDecryptKey];
        return responseData;
    }
    return responseData;
}

@end
