//
//  SchedulingServerManager.swift
//  Hayate
//
//  Created by 段 文武 on 16/5/11.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import UIKit

class SchedulingServerManager : NSObject{
    
    class var sharedInstance :SchedulingServerManager {
        
        struct Static {
            static var onceToken:dispatch_once_t = 0
            static var instance:SchedulingServerManager? = nil
        }
        
        dispatch_once(&Static.onceToken, { () -> Void in
            
            Static.instance = SchedulingServerManager()
        })
        
        return Static.instance!
    }
    
    
    func requestMarketAddress() -> Void {
        
        let addresses : Array = HayateGlobal.SchedulingServerAddress;
        let count : Int = addresses.count
        srandom(UInt32(time(nil)))            // 种子,random对应的是srandom
        let index : Int = random() % count
        var address : (String,ushort) = addresses[index]
        
        
        var reqParmData : NSData = NSData()
        let tag : CChar = CChar("{")!
        let type : ushort = 1000
        let attrs : Int16 = 0
        let len : ushort = ushort(reqParmData.length);
        
        NSMutableData *reqParmData = [NSMutableData data];
        NSData *reqPostData     = [reqData objectForKey:kReqNSData];
        char tag                = '{';
        unsigned short type     = DZH_MREQ_INITLOGIN;
        short attrs             = 0;
        unsigned short len      = [reqPostData length];
        [reqParmData appendBytes:&tag length:sizeof(tag)];
        [reqParmData appendBytes:&type length:sizeof(type)];
        [reqParmData appendBytes:&attrs length:sizeof(attrs)];
        [reqParmData appendBytes:&len length:sizeof(len)];
        if (len > 0) [reqParmData appendData:reqPostData];
        
        return reqParmData;
    }

}
