//
//  DZHMarketDataDecompression.h
//  iPhoneNewVersion
//
//  Created by Howard on 13-5-29.
//  Copyright (c) 2013年 DZH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DZHMarketDataDecompression : NSObject
+ (NSData *)expandMinLineData:(NSData *)data marketTime:(NSMutableArray *)marketTime minLineTotalNum:(int *)totalNum headerLen:(NSUInteger)headerLen;

+ (NSData *)expandKLineData:(NSData *)data headerLen:(NSUInteger)headerLen;
+ (NSData *)expandCodeList:(NSData *)data headerLen:(NSUInteger)headerLen stockCount:(int)stockcount unzipCount:(int)unzipcount zipCount:(int)zipcount pos:(int)pos;

@end
