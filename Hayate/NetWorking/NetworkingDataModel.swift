//
//  NetworkingDataModel.swift
//  Hayate
//
//  Created by Duanwwu on 16/5/18.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

public class DZHRequestPackage1000: DZHMarketRequestPackage {
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
        super.init(header: DZH_DATAHEAD(123, 1000, 0, 0), parser: DZHResponsePackage1000())
    }
    
    convenience init() {
        self.init(version: HayateGlobal.VersionNumber, deviceID: HayateGlobal.deviceId(), deviceType: HayateGlobal.TerminalId)
    }
    
    override public func serializeBody() -> NSData? {
        let body: NSMutableData = NSMutableData()
        body.writeValue(version)
        body.writeValue(deviceID)
        body.writeValue(deviceType)
        body.writeValue(paymentFlag)
        body.writeValue(carrier)
        body.writeArray(serverList)
        return body
    }
}

public class DZHResponsePackage1000: DZHResponseDataParser {
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

public class DZHRequestPackage2939: DZHMarketRequestPackage {
    var code: NSString
    
    init(code: NSString) {
        self.code = code
        super.init(header: DZH_DATAHEAD(HayateTagCreator.sharedInstance.tag(), 2939, 0, 0), parser: nil)
    }
    
    override func generateResponseParser(responseHeader: HayatePackageHeader) {
        if responseParser == nil {
            responseParser = responseHeader.packageType() == 2939 ? DZHResponsePackage2939() : DZHResponsePackage2943()
        }
    }
    
    override func serializeBody() -> NSData? {
        let body: NSMutableData = NSMutableData()
        body.writeValue(code)
        return body
    }
}

public class DZHResponsePackage2939: DZHResponseDataParser {
    
    override public func deSerialize(body: NSData?) {
        if body != nil {
            
        }
    }
}

public class DZHResponsePackage2943: DZHResponseDataParser {
    
    override public func deSerialize(body: NSData?) {
        if body != nil {
            
        }
    }
}

public class DZHRequestPackage2940: DZHMarketRequestPackage {
    var code: NSString
    
    init(code: NSString) {
        self.code = code
        super.init(header: DZH_DATAHEAD(HayateTagCreator.sharedInstance.tag(), 2940, 0, 0), parser: DZHResponsePackage2940())
    }
    
    override func serializeBody() -> NSData? {
        let body: NSMutableData = NSMutableData()
        body.writeValue(code)
        return body
    }
}

public class DZHResponsePackage2940: DZHResponseDataParser {
    
    override public func deSerialize(body: NSData?) {
        if body != nil {
            
        }
    }
}

public class DZHRequestPackage2963: DZHMarketRequestPackage {
    
    init() {
        super.init(header: DZH_DATAHEAD(123, 2963, 0, 0), parser: DZHResponsePackage2963())
    }
}

public class DZHResponsePackage2963: DZHResponseDataParser {
    
    override public func deSerialize(body: NSData?) {
        if body != nil {
            
        }
    }
}
