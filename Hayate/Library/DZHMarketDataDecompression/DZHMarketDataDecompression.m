//
//  DZHMarketDataDecompression.m
//  iPhoneNewVersion
//
//  Created by Howard on 13-5-29.
//  Copyright (c) 2013年 DZH. All rights reserved.
//

#import "DZHMarketDataDecompression.h"
#import "dzhbitstream.h"
#import <zlib.h>

@implementation DZHMarketDataDecompression

+ (NSData *)expandMinLineData:(NSData *)data marketTime:(NSMutableArray *)marketTime minLineTotalNum:(int *)totalNum headerLen:(NSUInteger)headerLen
{
    NSData * tempData   = nil;
    
	char *phead = (char *)[data bytes];
	JAVA_HEAD * pCmdHead = (JAVA_HEAD *)phead;
    
	if (pCmdHead->attrs & 0x0002)
	{
		unsigned short exlen = 1024 * 10;
        char *presult = (char *)calloc(exlen, 1);
		char *presultH = presult;
		
		MARKETTIME* pMarketTime = NULL;
        unsigned short minTotalNum = 0;
		NewExpandMinData((JAVA_HEAD *)phead, (JAVA_HEAD *)presult, &exlen, &minTotalNum, &pMarketTime);
        *totalNum = minTotalNum;
//        marketTime = [NSMutableArray arrayWithArray:[self marketTimeData:pMarketTime]];
		
		exlen = ((JAVA_HEAD *)presult)->length + headerLen;
		if (exlen <= headerLen)
        {
			free(presultH);
			return nil;
		}
		
		tempData = [[NSData alloc] initWithBytes:presult length:exlen];
		free(presultH);
		presultH = NULL;
	}
	else
    {
		tempData = data;
	}
    
    return tempData;
}

+ (NSData *)expandKLineData:(NSData *)data headerLen:(NSUInteger)headerLen
{
    NSData * tempData       = nil;
	char *phead             = (char *)[data bytes];
	JAVA_HEAD * pCmdHead    = (JAVA_HEAD *)phead;
//	BOOL bCompress = NO;
	if (pCmdHead->attrs&0x0002)
	{
//		bCompress = YES;
		unsigned short exlen = 1024 * 10;
//		char *presult = (char *)malloc(exlen);
//		memset(presult, 0, exlen);
        char *presult = (char *)calloc(exlen, 1);
		char *presultH = presult;

		NewExpandKLineData((JAVA_HEAD *)phead, (JAVA_HEAD *)presult, &exlen);
		exlen = ((JAVA_HEAD *)presult)->length + headerLen;
		tempData = [[NSData alloc] initWithBytes:presult length:exlen];
		free(presultH);
		presultH = NULL;
	}
	else {
		tempData = data;
	}
    
    return tempData;
}

+ (NSData *)expandCodeList:(NSData *)data headerLen:(NSUInteger)headerLen stockCount:(int)stockcount unzipCount:(int)unzipcount zipCount:(int)zipcount pos:(int)pos
{
    NSData *unzipdata = nil;
    
	char *phead = (char *)[data bytes];
	JAVA_HEAD * pCmdHead = (JAVA_HEAD *)phead;
    
	if (pCmdHead->attrs & 0x0004)
    {
		if (stockcount > 0 && unzipcount > 0)
        {
			uLongf nDestLen = unzipcount;
			Bytef *pDest = (Bytef *)malloc(nDestLen);
			Bytef *pSrc  = (Bytef *)phead;
			uLong nSrcLen = zipcount;
			pSrc += headerLen + 12;
			int nRet = uncompress(pDest, &nDestLen, pSrc, nSrcLen);
            
            if (nRet == Z_OK)
            {
                unzipdata = [[NSData alloc] initWithBytes:pDest length:nDestLen];
                //if (bShowLog) NSLog(@"[2956码表]收到的数据长度：%lu，压缩前长度：%d，解压后长度：%d", nSrcLen, unzipcount, nDestLen);
            }
            
            free(pDest);
            pDest = NULL;
		}
	}
	else
    {
		unzipdata = [data subdataWithRange:NSMakeRange(pos, zipcount)];
	}
    
    return unzipdata;
}

@end
