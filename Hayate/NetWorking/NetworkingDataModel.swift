//
//  NetworkingDataModel.swift
//  Hayate
//
//  Created by Duanwwu on 16/5/18.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

// 数据包头
struct DZH_DATAHEAD {
    var tag: CChar
    var type: CShort
    var attrs: CShort
    var length: ushort
}

struct DZH_DATAHEAD_EX {
    var tag: CChar
    var type: CShort
    var attrs: CShort
    var length: uint
}

struct DZH_NORMALHEAD{
    var tag: CChar
    var type: CShort
    var attrs: CShort
}

protocol HayateSerialize {
    func serialize() -> NSMutableData
}

class DZHRequestPakage1000: NSObject,HayateSerialize {
    var header : DZH_DATAHEAD
    var version: NSString //版本号
    var deviceID: NSString //终端编号
    var deviceType: NSString //终端类型
    var paymentFlag: CChar //收费用户标记
    var carrier: CChar //运营商标记
    
    override convenience init(){
        self.init(version: HayateGlobal.VersionNumber, deviceID: HayateGlobal.deviceId(), deviceType: HayateGlobal.TerminalId)
    }
    
    init(version: NSString, deviceID: NSString, deviceType: NSString){
        self.header = DZH_DATAHEAD(tag: CChar("{")!, type: 1000, attrs: 0, length:0)
        self.version = version
        self.deviceID = deviceID
        self.deviceType = deviceType
        self.paymentFlag = 0
        self.carrier = 0
    }
    
    func serialize() -> NSMutableData {
        let data: NSMutableData = NSMutableData()
        data.writeValue(header)
        data.writeValue(version)
        data.writeValue(deviceID)
        data.writeValue(deviceType)
        data.writeValue(paymentFlag)
        data.writeValue(carrier)
        var length: ushort = ushort(data.length)
        data.replaceBytesInRange(NSMakeRange(6, 2), withBytes: &length, length:2)
        return data
    }
}