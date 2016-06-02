//
//  DZHMarketDataDecompression.m
//  iPhoneNewVersion
//
//  Created by Howard on 13-5-29.
//  Copyright (c) 2013年 DZH. All rights reserved.
//

#import "DZHMarketDataDecompression.h"
#import <zlib.h>

@implementation DZHMarketDataDecompression

+ (NSData *)expandMinLineData:(NSData *)data marketTime:(NSMutableString *)marketTime minLineTotalNum:(unsigned short *)totalNum 
{
    unsigned short exlen = 1024 * 10;
    char *presult = (char *)calloc(exlen, 1);
    
    MARKETTIME* pMarketTime = NULL;
    NewExpandMinData([data bytes], data.length, presult, &exlen, totalNum, &pMarketTime);
    
    if (marketTime == nil) {
        marketTime = [[NSMutableString alloc] init];
    }
    
    if (pMarketTime && (pMarketTime->m_nNum > 0))
    {
        int size =  MIN(pMarketTime->m_nNum, 8) - 1;
        for (int i = 0; i <= size; i++)
        {
            [marketTime appendFormat:@"%d,%d",pMarketTime->m_TradeTime[i].m_wOpen,pMarketTime->m_TradeTime[i].m_wEnd];
            if (i != size) {
                [marketTime appendString:@","];
            }
        }
    }
    
    NSData *tempData = [[NSData alloc] initWithBytes:presult length:exlen];
    free(presult);
    presult = NULL;
    
    return tempData;
}

+ (NSData *)expandKLineData:(NSData *)data
{
    unsigned short exlen    = 1024 * 10;
    char *presult           = (char *)calloc(exlen, 1);
    
    NewExpandKLineData([data bytes], data.length, presult, &exlen);
    NSData *tempData = [[NSData alloc] initWithBytes:presult length:exlen];
    free(presult);
    presult = NULL;
    return tempData;
}

@end
