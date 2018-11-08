//
//  ConverUtil.h
//  newProjcet
//
//  Created by lijiawei on 16/6/8.
//  Copyright © 2016年 SanShiChuangXiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConverUtil : NSObject

/**64编码*/
+(NSString *)base64Encoding:(NSData*) text;

/**字节转化为16进制数*/
+(NSString *) parseByte2HexString:(Byte *) bytes;

/**字节数组转化16进制数*/
+(NSString *) parseByteArray2HexString:(Byte[]) bytes length:(NSInteger)length;

/*将16进制数据转化成NSData 数组*/
+(NSData*) parseHexToByteArray:(NSString*) hexString;

//给定一个字符串，对该字符串进行Base64编码，然后返回编码后的结果
+(NSString *)base64EncodeString:(NSString *)string;

//对base64编码后的字符串进行解码
+(NSString *)base64DecodeString:(NSString *)string;

@end
