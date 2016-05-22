//
//  SchedulingServerManager.swift
//  Hayate
//
//  Created by 段 文武 on 16/5/11.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import UIKit

public class SchedulingServerManager : NSObject{
    
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
    
    func requestMarketAddress() {
        let addresses : Array = HayateGlobal.SchedulingServerAddress;
        let count : Int = addresses.count
        srandom(UInt32(time(nil)))            // 种子,random对应的是srandom
        let index : Int = random() % count
        let address : (String,ushort) = addresses[index]
        let url = String(stringInterpolation: "http://\(address.0):\(address.1)")
        let package1000 = DZHRequestPackage1000()
        
        HayateHttpManager.sharedInstance.POSTStream(url, body: package1000.serialize(), succeed: { (responseData) in
                let NormalHeaderLength = strideof(DZH_NORMALHEAD)
                let data = responseData as! NSData
                if data.length > NormalHeaderLength {
                    let parser = package1000.responseParser
                    var normalHeader: DZH_NORMALHEAD?;
                    var pos = 0 //处理的长度
                    data.readValue(&normalHeader, pos: &pos)//获取包头数据
                    let attr = (normalHeader!.attrs & 0x8) >> 3 //取长度扩充位，当置位时，用int表示数据长度；否则用short表示长度；
                    let byteSize = attr == 1 ? strideof(Int32) : strideof(CShort)
                    var length = 0
                    data.readValue(&length, size: byteSize, pos: &pos)//读取包的数据长度
                    parser.header = DZH_DATAHEAD_EX(header: normalHeader!, len: length)
                    parser.deSerialize(length > 0 ? data.subdataWithRange(NSMakeRange(pos, length)) : nil)
                }
            }, failed:{ (error) in
                print("receive failed")
        })
    }
}
