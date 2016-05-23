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
    
    static func size() -> Int {
        return 5
    }
}

protocol HayateSerialize {
    func serialize() -> NSMutableData
}

protocol HayateDeSerialize {
    func deSerialize(body: NSData?)
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
    
    func deSerialize(body: NSData?) {
        
    }
}

public class DZHRequestPackage1000: DZHRequestPackage {
    var version: NSString //版本号
    var deviceID: NSString //终端编号
    var deviceType: NSString //终端类型
    var paymentFlag: CChar //收费用户标记
    var carrier: CChar //运营商标记
    var serverList: Array<CInt>
    
    init(version: NSString, deviceID: NSString, deviceType: NSString) {
        self.version = version
        self.deviceID = deviceID
        self.deviceType = deviceType
        self.paymentFlag = 0
        self.carrier = 0
        self.serverList = [1]
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
        body.writeValue(serverList)
        self.header.length = ushort(body.length)
        let retData = super.serialize()
        retData.appendData(body)
        return retData
    }
}

class DZHResponseDataParser1000: DZHResponseDataParser {
    var hqServerAddresses: Array<NSString>? // 行情服务器地址数组
    var wtServerAddresses: Array<NSString>? // 委托服务器地址数组
    var noticeText: NSString? // 公告信息
    var newVersionNum: NSString? // 新版本号
    var downloadAddress: NSString? // 下载地址
    var isAlertUpdate: Bool? // 是否提醒升级
    var isForceUpdate: Bool? // 是否强制升级
    var isAlertLogin: Bool? // 是否提示登录
    var carrierIP: CChar? // 用户运营商ip   0表示未知；非0表示有效，
    var uploadLogInterval: CShort? // 统计信息时间间隔  单位秒,如果为0表示不统计信息
    var updateNotice: NSString? // 升级提示文字
    var noticeCRC: CShort? // 公告crc
    var noticeType: CChar? // 公告提示类型
    var scheduleAddresses: Array<NSString>? // 调度地址
    var serverDict: Dictionary<Int32,Array<NSString>>? // 不同服务器地址列表
    
    override func deSerialize(body: NSData?) {
        if body != nil {
            let data = body!
            var pos: Int = 0
            data.readStringArray(&hqServerAddresses, pos: &pos)
            data.readStringArray(&wtServerAddresses, pos: &pos)
            data.readString(&noticeText, pos: &pos)
            data.readString(&newVersionNum, pos: &pos)
            data.readString(&downloadAddress, pos: &pos)
            data.readValue(&isAlertUpdate, size: 1, pos: &pos)
            data.readValue(&isForceUpdate, size: 1, pos: &pos)
            data.readValue(&isAlertLogin, size: 1, pos: &pos)
            data.readValue(&carrierIP, pos: &pos)
            data.readValue(&uploadLogInterval, pos: &pos)
            data.readString(&updateNotice, pos: &pos)
            data.readValue(&noticeCRC, pos: &pos)
            data.readValue(&noticeType, pos: &pos)
            data.readStringArray(&scheduleAddresses, pos: &pos)
            var count: Int = 0
            data.readValue(&count, size: sizeof(ushort), pos: &pos)
            if count > 0 {
                var servDic: Dictionary<Int32,Array<NSString>> = Dictionary()
                var serviceId: Int32 = 0
                var serviceArray: Array<NSString>?
                for _ in 0 ..< count {
                    data.readValue(&serviceId, pos: &pos)
                    data.readStringArray(&serviceArray, pos: &pos)
                    if serviceArray != nil && serviceArray!.count > 0{
                        servDic.updateValue(serviceArray!, forKey: serviceId)
                    }
                }
                serverDict = servDic
            }
        }
    }
}
