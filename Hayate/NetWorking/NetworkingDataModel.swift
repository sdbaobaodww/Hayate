//
//  NetworkingDataModel.swift
//  Hayate
//
//  Created by Duanwwu on 16/5/18.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

// 数据包头
public struct DZH_DATAHEAD {
    public var tag: CChar
    public var type: CShort
    public var attrs: CShort
    public var length: Int
    
    init() {
        self.init(123, 0, 0, 0)
    }
    
    init(_ tag: CChar, _ type: CShort, _ attrs: CShort, _ length: Int) {
        self.tag = tag
        self.type = type
        self.attrs = attrs
        self.length = length
    }
    
    public mutating func serialize(bodySize: Int) -> NSMutableData {
        let header: NSMutableData = NSMutableData()
        header.writeValue(tag)
        header.writeValue(type)
        header.writeValue(attrs)
        length = bodySize
        header.writeValue(ushort(bodySize))
        return header
    }
    
    public mutating func deSerialize(data: NSData, pos: UnsafeMutablePointer<Int>) {
        data.readValue(&tag, size: sizeof(CChar), pos: pos)
        data.readValue(&type, size: sizeof(CShort), pos: pos)
        data.readValue(&attrs, size: sizeof(CShort), pos: pos)
        let attr = (attrs & 0x8) >> 3 //取长度扩充位，当置位时，用int表示数据长度；否则用short表示长度；
        let byteSize = attr == 1 ? sizeof(Int32) : sizeof(CShort)
        data.readValue(&length, size: byteSize, pos: pos)//读取包的数据长度
    }
    
    public static func fixedSize() -> Int {
        return 7
    }
}

public class DZHRequestPackage: NSObject {
    var header: DZH_DATAHEAD
    var parser: DZHResponseDataParser?
    
    init(header: DZH_DATAHEAD) {
        self.header = header
    }
    
    public func responseParser(responseHeader: DZH_DATAHEAD) -> DZHResponseDataParser {
        if parser == nil {
            parser = DZHResponseDataParser()
        }
        return parser!
    }
    
    public func serialize() -> NSMutableData {
        return self.header.serialize(0)//默认写一个空包头
    }
    
    public func isMatchPackage(responseHeader: DZH_DATAHEAD) -> Bool {
        return header.tag == responseHeader.tag && header.type == responseHeader.type
    }
}

public class DZHResponseDataParser: NSObject {
    var header: DZH_DATAHEAD?
    
    public func deSerialize(body: NSData?) {
        
    }
}

public class DZHRequestPackage1000: DZHRequestPackage {
    public var version: NSString //版本号
    public var deviceID: NSString //终端编号
    public var deviceType: NSString //终端类型
    public var paymentFlag: CChar //收费用户标记
    public var carrier: CChar //运营商标记
    public var serverList: Array<CInt>
    
    init(version: NSString, deviceID: NSString, deviceType: NSString) {
        self.version = version
        self.deviceID = deviceID
        self.deviceType = deviceType
        self.paymentFlag = 0
        self.carrier = 0
        self.serverList = [1]
        super.init(header: DZH_DATAHEAD(123, 1000, 0, 0))
    }
    
    convenience init() {
        self.init(version: HayateGlobal.VersionNumber, deviceID: HayateGlobal.deviceId(), deviceType: HayateGlobal.TerminalId)
    }
    
    override public func responseParser(responseHeader: DZH_DATAHEAD) -> DZHResponseDataParser {
        if parser == nil {
            parser = DZHResponseDataParser1000()
        }
        return parser!
    }
    
    override public func serialize() -> NSMutableData {
        let body: NSMutableData = NSMutableData()
        body.writeValue(version)
        body.writeValue(deviceID)
        body.writeValue(deviceType)
        body.writeValue(paymentFlag)
        body.writeValue(carrier)
        body.writeArray(serverList)
        let header = self.header.serialize(body.length)
        header.appendData(body)
        return header
    }
}

public class DZHResponseDataParser1000: DZHResponseDataParser {
    public var hqServerAddresses: Array<NSString>? // 行情服务器地址数组
    public var wtServerAddresses: Array<NSString>? // 委托服务器地址数组
    public var noticeText: NSString? // 公告信息
    public var newVersionNum: NSString? // 新版本号
    public var downloadAddress: NSString? // 下载地址
    public var isAlertUpdate: Bool? // 是否提醒升级
    public var isForceUpdate: Bool? // 是否强制升级
    public var isAlertLogin: Bool? // 是否提示登录
    public var carrierIP: CChar? // 用户运营商ip   0表示未知；非0表示有效，
    public var uploadLogInterval: CShort? // 统计信息时间间隔  单位秒,如果为0表示不统计信息
    public var updateNotice: NSString? // 升级提示文字
    public var noticeCRC: CShort? // 公告crc
    public var noticeType: CChar? // 公告提示类型
    public var scheduleAddresses: Array<NSString>? // 调度地址
    public var serverDict: Dictionary<Int32,Array<NSString>>? // 不同服务器地址列表
    
    override public func deSerialize(body: NSData?) {
        if body != nil {
            let data = body!
            var pos: Int = 0
            data.readStringArray(&hqServerAddresses, pos: &pos)
            data.readStringArray(&wtServerAddresses, pos: &pos)
            data.readString(&noticeText, pos: &pos)
            data.readString(&newVersionNum, pos: &pos)
            data.readString(&downloadAddress, pos: &pos)
            data.readValue(&isAlertUpdate, size: sizeof(CChar), pos: &pos)
            data.readValue(&isForceUpdate, size: sizeof(CChar), pos: &pos)
            data.readValue(&isAlertLogin, size: sizeof(CChar), pos: &pos)
            data.readValue(&carrierIP, size: sizeof(CChar), pos: &pos)
            data.readValue(&uploadLogInterval, size: sizeof(CShort), pos: &pos)
            data.readString(&updateNotice, pos: &pos)
            data.readValue(&noticeCRC, size: sizeof(CShort), pos: &pos)
            data.readValue(&noticeType, size: sizeof(CChar), pos: &pos)
            data.readStringArray(&scheduleAddresses, pos: &pos)
            var count: Int = 0
            data.readValue(&count, size: sizeof(ushort), pos: &pos)
            if count > 0 {
                var servDic: Dictionary<Int32,Array<NSString>> = Dictionary()
                var serviceId: Int32 = 0
                var serviceArray: Array<NSString>?
                for _ in 0 ..< count {
                    data.readValue(&serviceId, size:sizeof(Int32), pos: &pos)
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
