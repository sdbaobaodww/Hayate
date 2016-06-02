//
//  DZHMarketDataDecompression.h
//  iPhoneNewVersion
//
//  Created by Howard on 13-5-29.
//  Copyright (c) 2013年 DZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "dzhbitstream.h"

@interface DZHMarketDataDecompression : NSObject

+ (NSData *)expandMinLineData:(NSData *)data marketTime:(NSMutableString *)marketTime minLineTotalNum:(unsigned short *)totalNum;

+ (NSData *)expandKLineData:(NSData *)data;

@end
