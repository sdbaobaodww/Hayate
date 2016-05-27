//
//  SchedulingServerManager.swift
//  Hayate
//
//  Created by 段 文武 on 16/5/11.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import UIKit

public let HayateReceiveServerAddress: String = "HayateReceiveServerAddress" //获取行情服务器成功通知

public class SchedulingServerManager : NSObject{
    
    var isRequesting: Bool = false
    
    public class var sharedInstance :SchedulingServerManager {
        struct Static {
            static var onceToken:dispatch_once_t = 0
            static var instance:SchedulingServerManager? = nil
        }
        dispatch_once(&Static.onceToken, { () -> Void in
            Static.instance = SchedulingServerManager()
        })
        return Static.instance!
    }
    
    public func requestMarketAddress() {
        if isRequesting {
            return
        }
        isRequesting = true
        let addresses : Array = HayateGlobal.SchedulingServerAddress;
        let address : (String,ushort) = addresses.randomObject()
        let url = String(stringInterpolation: "http://\(address.0):\(address.1)")
        let package1000 = DZHRequestPackage1000()
        
        HayateHttpManager.sharedInstance.POSTStream(url, body: package1000.serialize(), succeed: { (responseData) in
                let data = responseData as! NSData
                if data.length >= DZH_DATAHEAD.fixedSize() {
                    var pos = 0 //处理的长度
                    var header: DZH_DATAHEAD = DZH_DATAHEAD()
                    header.deSerialize(data, pos: &pos)//反序列化包头数据
                    let parser = package1000.responseParser(header)
                    parser.header = header
                    parser.deSerialize(header.length > 0 ? data.subdataWithRange(NSMakeRange(pos, header.length)) : nil)
                    NSNotificationCenter.defaultCenter().postNotificationName(HayateReceiveServerAddress, object: nil)//发出获取到行情服务器的通知
                }
                else {
                    self.performSelector(#selector(SchedulingServerManager.requestMarketAddress), withObject: nil, afterDelay: 1)
                }
                self.isRequesting = false
            }, failed:{ (error) in
                
                self.performSelector(#selector(SchedulingServerManager.requestMarketAddress), withObject: nil, afterDelay: 1)
                self.isRequesting = false
        })
    }
}
