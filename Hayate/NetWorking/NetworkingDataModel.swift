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

public class DZHRequestPackage2942: DZHMarketRequestPackage {
    var code: NSString
    var position: CShort
    
    init(code: NSString, position: CShort) {
        self.code = code
        self.position = position
        super.init(header: DZH_DATAHEAD(HayateTagCreator.sharedInstance.tag(), 2942, 2, 0), parser: DZHResponsePackage2942())
    }
    
    override func serializeBody() -> NSData? {
        let body: NSMutableData = NSMutableData()
        body.writeValue(code)
        body.writeValue(position)
        return body
    }
}

public class DZHResponsePackage2942Item: NSObject {
    var time: Int = 0 //时间
    var price: Int = 0//最新价
    var volume: Int = 0//成交量
    var averagePrice: Int = 0//均价
    var holdVolume: Int = 0//持仓量
    
    func deSerialize(data: NSData, pos: UnsafeMutablePointer<Int>) {
        let byteSize = sizeof(CInt)
        data.readValue(&time, size: byteSize, pos: pos)
        data.readValue(&price, size: byteSize, pos: pos)
        data.readValue(&volume, size: byteSize, pos: pos)
        data.readValue(&averagePrice, size: byteSize, pos: pos)
        data.readValue(&holdVolume, size: byteSize, pos: pos)
    }
}

public class DZHResponsePackage2942: DZHResponseDataParser {
    var marketTime: NSMutableString = NSMutableString()//交易时间段
    var totalNum: CUnsignedShort = 0 //总分时点个数
    var holdTag: CChar = 0 //持仓标记
    var bombCount: CChar = 0 //信息地雷数
    var starVal: CChar = 0 //五星评级
    var position: CShort = 0 //数据位置
    var items: NSMutableArray = NSMutableArray()
    
    override public func deSerialize(body: NSData?) {
        if body != nil {
            let attrs = (header as! DZH_DATAHEAD).attrs
            let depressData: NSData
            if (attrs >> 1 & 0x1) == 1 {
                depressData = DZHMarketDataDecompression.expandMinLineData(body, marketTime: marketTime, minLineTotalNum: &totalNum)
            }else{
                depressData = body!
            }
            var pos: Int = 0
            depressData.readValue(&holdTag, size: sizeof(CChar), pos: &pos)
            depressData.readValue(&bombCount, size: sizeof(CChar), pos: &pos)
            depressData.readValue(&starVal, size: sizeof(CChar), pos: &pos)
            depressData.readValue(&position, size: sizeof(CShort), pos: &pos)
            var itemCount = 0
            depressData.readValue(&itemCount, size: sizeof(CShort), pos: &pos)
            let arr: NSMutableArray = NSMutableArray.init(capacity: itemCount)
            for _ in 0 ..< itemCount {
                let item = DZHResponsePackage2942Item()
                item.deSerialize(depressData, pos: &pos)
                arr.addObject(item)
            }
            items = arr
        }
    }
}

public class DZHRequestPackage2944: DZHMarketRequestPackage {
    var code: NSString
    var type: CChar
    var endDate: CInt
    var reqNumber: CShort
    
    init(code: NSString, type: CChar, endDate: CInt, reqNumber: CShort) {
        self.code = code
        self.type = type
        self.endDate = endDate
        self.reqNumber = reqNumber
        super.init(header: DZH_DATAHEAD(HayateTagCreator.sharedInstance.tag(), 2944, 2, 0), parser: DZHResponsePackage2944())
    }
    
    override func serializeBody() -> NSData? {
        let body: NSMutableData = NSMutableData()
        body.writeValue(code)
        body.writeValue(type)
        body.writeValue(endDate)
        body.writeValue(reqNumber)
        return body
    }
}

public class DZHResponsePackage2944Item: NSObject {
    var date: CInt = 0 //日期
    var open: CInt = 0//开盘价
    var high: CInt = 0//最高价
    var low: CInt = 0//最低价
    var close: CInt = 0//收盘价
    var volume: Int64 = 0//成交量
    var turnover: CInt = 0//成交额
    var holdVolume: CInt = 0//持仓量
    
    func deSerialize(data: NSData, pos: UnsafeMutablePointer<Int>) {
        let byteSize = sizeof(CInt)
        data.readValue(&date, size: byteSize, pos: pos)
        data.readValue(&open, size: byteSize, pos: pos)
        data.readValue(&high, size: byteSize, pos: pos)
        data.readValue(&low, size: byteSize, pos: pos)
        data.readValue(&close, size: byteSize, pos: pos)
        data.readValue(&volume, size: byteSize, pos: pos)
        data.readValue(&turnover, size: byteSize, pos: pos)
        data.readValue(&holdVolume, size: byteSize, pos: pos)
    }
}

public class DZHResponsePackage2944: DZHResponseDataParser {
    var holdTag: CChar = 0 //持仓标记
    var items: NSMutableArray = NSMutableArray()
    
    override public func deSerialize(body: NSData?) {
        if body != nil {
            let attrs = (header as! DZH_DATAHEAD).attrs
            let depressData: NSData
            if (attrs >> 1 & 0x1) == 1 {
                depressData = DZHMarketDataDecompression.expandKLineData(body)
            }else{
                depressData = body!
            }
            var pos: Int = 0
            depressData.readValue(&holdTag, size: sizeof(CChar), pos: &pos)
            var itemCount = 0
            depressData.readValue(&itemCount, size: sizeof(CShort), pos: &pos)
            let arr: NSMutableArray = NSMutableArray.init(capacity: itemCount)
            for _ in 0 ..< itemCount {
                let item = DZHResponsePackage2944Item()
                item.deSerialize(depressData, pos: &pos)
                arr.addObject(item)
            }
            items = arr
        }
    }
}
