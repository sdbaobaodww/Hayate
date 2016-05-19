//
//  NetworkingDataModel.swift
//  Hayate
//
//  Created by Duanwwu on 16/5/18.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

typealias PackageQueryCondition = (tag: CChar, type: CShort)

// 数据包头
struct DZH_DATAHEAD: HayateSerialize {
    var tag: CChar
    var type: CShort
    var attrs: CShort
    var length: ushort
    
    func serialize() -> NSMutableData {
        let data: NSMutableData = NSMutableData()
        data.writeValue(tag)
        data.writeValue(type)
        data.writeValue(attrs)
        data.writeValue(length)
        return data
    }
}

struct DZH_DATAHEAD_EX {
    var tag: CChar
    var type: CShort
    var attrs: CShort
    var length: Int
    
    init(header: DZH_NORMALHEAD, len: Int) {
        tag = header.tag
        type = header.type
        attrs = header.attrs
        length = len;
    }
}

struct DZH_NORMALHEAD{
    var tag: CChar
    var type: CShort
    var attrs: CShort
}

protocol HayateSerialize {
    func serialize() -> NSMutableData
}

protocol HayateDeSerialize {
    func deSerialize(data: NSData?)
}

public class DZHRequestPackage: NSObject,HayateSerialize {
    var header: DZH_DATAHEAD
    var responseParser: DZHResponseDataParser
    
    init(header: DZH_DATAHEAD, dataParser: DZHResponseDataParser) {
        self.header = header
        self.responseParser = dataParser
    }
    
    func receiveResponseData(data: NSData){
        self.responseParser.deSerialize(data)
    }
    
    func serialize() -> NSMutableData {
        return header.serialize()
    }
    
    func isMatchPackage(condition: PackageQueryCondition) -> Bool {
        return header.tag == condition.tag && header.type == condition.type
    }
}

public class DZHResponseDataParser: NSObject,HayateDeSerialize {
    var header: DZH_DATAHEAD_EX?
    
    func deSerialize(data: NSData?) {
        
        
    }
}

public class DZHRequestPackage1000: DZHRequestPackage {
    var version: NSString //版本号
    var deviceID: NSString //终端编号
    var deviceType: NSString //终端类型
    var paymentFlag: CChar //收费用户标记
    var carrier: CChar //运营商标记
    
    init(version: NSString, deviceID: NSString, deviceType: NSString) {
        self.version = version
        self.deviceID = deviceID
        self.deviceType = deviceType
        self.paymentFlag = 0
        self.carrier = 0
        super.init(header: DZH_DATAHEAD(tag: 123, type: 1000, attrs: 0, length:0), dataParser: DZHResponseDataParser1000())
    }
    
    convenience init() {
        self.init(version: HayateGlobal.VersionNumber, deviceID: HayateGlobal.deviceId(), deviceType: HayateGlobal.TerminalId)
    }
    
    override func serialize() -> NSMutableData {
        let body: NSMutableData = NSMutableData()
        body.writeValue(version)
        body.writeValue(deviceID)
        body.writeValue(deviceType)
        body.writeValue(paymentFlag)
        body.writeValue(carrier)
        self.header.length = ushort(body.length)
        let retData = super.serialize()
        retData.appendData(body)
        return retData
    }
}

class DZHResponseDataParser1000: DZHResponseDataParser {
    
}
