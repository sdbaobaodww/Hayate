//
//  NetworkingDataModel.swift
//  Hayate
//
//  Created by Duanwwu on 16/5/18.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

open class DZHRequestPackage1000: DZHMarketRequestPackage {
    open var version: NSString //版本号
    open var deviceID: NSString //终端编号
    open var deviceType: NSString //终端类型
    open var paymentFlag: CChar //收费用户标记
    open var carrier: CChar //运营商标记
    open var serverList: Array<CInt>
    
    init(version: NSString, deviceID: NSString, deviceType: NSString) {
        self.version = version
        self.deviceID = deviceID
        self.deviceType = deviceType
        self.paymentFlag = 0
        self.carrier = 0
        self.serverList = [1]
        super.init(header: DZH_DATAHEAD(123, 1000, 0), parser: DZHResponsePackage1000())
    }
    
    convenience init() {
        self.init(version: HayateGlobal.VersionNumber, deviceID: HayateGlobal.deviceId(), deviceType: HayateGlobal.TerminalId)
    }
    
    override open func serializeBody() -> Data? {
        let body: NSMutableData = NSMutableData()
        body.writeValue(version)
        body.writeValue(deviceID)
        body.writeValue(deviceType)
        body.writeValue(paymentFlag)
        body.writeValue(carrier)
        body.writeArray(serverList)
        return body as Data
    }
}

open class DZHResponsePackage1000: DZHResponseDataParser {
    open var hqServerAddresses: Array<NSString>? // 行情服务器地址数组
    open var wtServerAddresses: Array<NSString>? // 委托服务器地址数组
    open var noticeText: NSString? // 公告信息
    open var newVersionNum: NSString? // 新版本号
    open var downloadAddress: NSString? // 下载地址
    open var isAlertUpdate: Bool = false // 是否提醒升级
    open var isForceUpdate: Bool = false // 是否强制升级
    open var isAlertLogin: Bool = false // 是否提示登录
    open var carrierIP: CChar = 0 // 用户运营商ip   0表示未知；非0表示有效，
    open var uploadLogInterval: CShort = 0 // 统计信息时间间隔  单位秒,如果为0表示不统计信息
    open var updateNotice: NSString? // 升级提示文字
    open var noticeCRC: CShort = 0 // 公告crc
    open var noticeType: CChar = 0 // 公告提示类型
    open var scheduleAddresses: Array<NSString>? // 调度地址
    open var serverDict: Dictionary<Int32,Array<NSString>>? // 不同服务器地址列表
    
    override open func deSerialize(_ body: Data?) {
        if body != nil {
            let data = body!
            var pos: Int = 0
            data.readStringArray(&hqServerAddresses, pos: &pos)
            data.readStringArray(&wtServerAddresses, pos: &pos)
            data.readString(&noticeText, pos: &pos)
            data.readString(&newVersionNum, pos: &pos)
            data.readString(&downloadAddress, pos: &pos)
            data.readValue(&isAlertUpdate, size: MemoryLayout<CChar>.size, pos: &pos)
            data.readValue(&isForceUpdate, size: MemoryLayout<CChar>.size, pos: &pos)
            data.readValue(&isAlertLogin, size: MemoryLayout<CChar>.size, pos: &pos)
            data.readValue(&carrierIP, size: MemoryLayout<CChar>.size, pos: &pos)
            data.readValue(&uploadLogInterval, size: MemoryLayout<CShort>.size, pos: &pos)
            data.readString(&updateNotice, pos: &pos)
            data.readValue(&noticeCRC, size: MemoryLayout<CShort>.size, pos: &pos)
            data.readValue(&noticeType, size: MemoryLayout<CChar>.size, pos: &pos)
            data.readStringArray(&scheduleAddresses, pos: &pos)
            var count: Int = 0
            data.readValue(&count, size: MemoryLayout<ushort>.size, pos: &pos)
            if count > 0 {
                var servDic: Dictionary<Int32,Array<NSString>> = Dictionary()
                var serviceId: Int32 = 0
                var serviceArray: Array<NSString>?
                for _ in 0 ..< count {
                    data.readValue(&serviceId, size:MemoryLayout<Int32>.size, pos: &pos)
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
    open var code: NSString//代码
    
    init(code: NSString) {
        self.code = code
        super.init(header: DZH_DATAHEAD(2939), parser: nil)
    }
    
    override func generateResponseParser(_ responseHeader: HayatePackageHeader) {
        if responseParser == nil {
            responseParser = responseHeader.packageType() == 2939 ? DZHResponsePackage2939() : DZHResponsePackage2943()
        }
    }
    
    override public func serializeBody() -> Data? {
        let body: NSMutableData = NSMutableData()
        body.writeValue(code)
        return body as Data
    }
}

open class DZHResponsePackage2939: DZHResponseDataParser {
    open var code: NSString?//代码
    open var name: NSString?//名称
    open var type: CChar = 0//类型
    open var presicion: CChar = 0//价格位数
    open var volumeUnit: CShort = 0//成交量单位
    open var lastClose: CInt = 0//昨收
    open var limitUp: CInt = 0//涨停
    open var limitDown: CInt = 0//跌停
    open var yposition: CInt = 0//昨日持仓
    open var ysettlement: CInt = 0//昨结算价
    open var circulatedCapital: Int64 = 0//流通盘
    open var totalCapital: Int64 = 0//总股本
    open var securitiesMargin: CChar = 0//融资融券标记
    open var eachNumber: CInt = 0//交易量单位,这个主要用于港股的委托使用的交易量，对其它市场该数值和成交量单位相同
    open var extendType: CChar = 0//证券扩展分类,0无效，1基础三板，2创新三板
    
    override open func deSerialize(_ body: Data?) {
        if body != nil {
            let data = body!
            var pos: Int = 0
            data.readString(&code, pos: &pos)
            data.readString(&name, pos: &pos)
            data.readValue(&type, size: MemoryLayout<CChar>.size, pos: &pos)
            data.readValue(&presicion, size: MemoryLayout<CChar>.size, pos: &pos)
            data.readValue(&volumeUnit, size: MemoryLayout<CShort>.size, pos: &pos)
            data.readValue(&lastClose, size: MemoryLayout<CInt>.size, pos: &pos)
            data.readValue(&limitUp, size: MemoryLayout<CInt>.size, pos: &pos)
            if type == 7 || type == 8 {//对期货或期指是昨日持仓，其它为流通盘
                data.readValue(&yposition, size: MemoryLayout<CInt>.size, pos: &pos)
            }else{
                data.readValue(&circulatedCapital, size: MemoryLayout<CInt>.size, pos: &pos)
                circulatedCapital = circulatedCapital.expand()
            }
            if type == 17 || type == 7 || type == 8 || type == 5 {//对商品、期货是昨结算价，其它是总股本
                data.readValue(&ysettlement, size: MemoryLayout<CInt>.size, pos: &pos)
            }else{
                data.readValue(&totalCapital, size: MemoryLayout<CInt>.size, pos: &pos)
                totalCapital = totalCapital.expand()
            }
            data.readValue(&securitiesMargin, size: MemoryLayout<CChar>.size, pos: &pos)
            data.readValue(&eachNumber, size: MemoryLayout<CInt>.size, pos: &pos)
            data.readValue(&extendType, size: MemoryLayout<CChar>.size, pos: &pos)
        }
    }
}

open class DZHResponsePackage2943: DZHResponseDataParser {
    
    override open func deSerialize(_ body: Data?) {
        if body != nil {
            
        }
    }
}

open class DZHRequestPackage2940: DZHMarketRequestPackage {
    open var code: NSString//代码
    
    init(code: NSString) {
        self.code = code
        super.init(header: DZH_DATAHEAD(2940), parser: DZHResponsePackage2940())
    }
    
    override public func serializeBody() -> Data? {
        let body: NSMutableData = NSMutableData()
        body.writeValue(code)
        return body as Data
    }
}

open class DZHOrderItem: NSObject {
    open var price: CInt = 0//买卖价
    open var volume: CInt = 0//买卖量
    
    init(price: CInt, volume: CInt) {
        self.price = price
        self.volume = volume
    }
}

open class DZHResponsePackage2940: DZHResponseDataParser {
    open var tag: CChar = 0//数据标记
    open var newPrice: CInt = 0//最新
    open var open: CInt = 0//今开
    open var high: CInt = 0//最高
    open var low: CInt = 0//最低
    open var volume: CInt = 0//成交量,也叫总手
    open var turnover: CInt = 0//总额
    open var sellVolume: CInt = 0//内盘
    open var currentVol: CInt = 0//现手
    open var averagePrice: CInt = 0//均价
    open var settlement: CInt = 0//结算价
    open var position: CInt = 0//持仓
    open var incPosition: CInt = 0//增仓
    open var voluemRatio: CShort = 0//量比
    open var buyData = NSMutableArray()//买盘记录
    open var sellData = NSMutableArray()//卖盘记录
    
    override open func deSerialize(_ body: Data?) {
        if body != nil {
            let data = body!
            var pos: Int = 0
            data.readValue(&tag, size: MemoryLayout<CChar>.size, pos: &pos)
            let intSize = MemoryLayout<CInt>.size
            data.readValue(&newPrice, size: intSize, pos: &pos)
            data.readValue(&open, size: intSize, pos: &pos)
            data.readValue(&high, size: intSize, pos: &pos)
            data.readValue(&low, size: intSize, pos: &pos)
            data.readValue(&volume, size: intSize, pos: &pos)
            data.readValue(&turnover, size: intSize, pos: &pos)
            data.readValue(&sellVolume, size: intSize, pos: &pos)
            data.readValue(&currentVol, size: intSize, pos: &pos)
            data.readValue(&averagePrice, size: intSize, pos: &pos)
            if tag == 1 {
                data.readValue(&settlement, size: intSize, pos: &pos)
                data.readValue(&position, size: intSize, pos: &pos)
                data.readValue(&incPosition, size: intSize, pos: &pos)
            }
            data.readValue(&voluemRatio, size: MemoryLayout<CShort>.size, pos: &pos)
            var count: Int = 0
            data.readValue(&count, size: MemoryLayout<CShort>.size, pos: &pos)
            let half = count / 2;//先卖盘后买盘
            var price: CInt = 0
            var vol: CInt = 0
            for _ in 0 ..< half {//卖盘
                data.readValue(&price, size: intSize, pos: &pos)
                data.readValue(&vol, size: intSize, pos: &pos)
                self.sellData.add(DZHOrderItem(price: price, volume: vol))
            }
            for _ in half ..< count {//买盘
                data.readValue(&price, size: intSize, pos: &pos)
                data.readValue(&vol, size: intSize, pos: &pos)
                self.buyData.add(DZHOrderItem(price: price, volume: vol))
            }
        }
    }
}

open class DZHRequestPackage2963: DZHMarketRequestPackage {
    
    init() {
        super.init(header: DZH_DATAHEAD(123, 2963, 0), parser: DZHResponsePackage2963())
    }
}

open class DZHResponsePackage2963: DZHResponseDataParser {
    open var year: CShort = 0//年
    open var month: CChar = 0//月
    open var day: CChar = 0//日
    open var hour: CChar = 0//时
    open var minute: CChar = 0//分
    open var second: CChar = 0//秒
    
    override open func deSerialize(_ body: Data?) {
        if body != nil {
            let data = body!
            var pos: Int = 0
            let charSize = MemoryLayout<CChar>.size
            data.readValue(&year, size: MemoryLayout<CShort>.size, pos: &pos)
            data.readValue(&month, size: charSize, pos: &pos)
            data.readValue(&day, size: charSize, pos: &pos)
            data.readValue(&hour, size: charSize, pos: &pos)
            data.readValue(&minute, size: charSize, pos: &pos)
            data.readValue(&second, size: charSize, pos: &pos)
        }
    }
}

open class DZHRequestPackage2942: DZHMarketRequestPackage {
    open var code: NSString//代码
    open var position: CShort//数据位置
    
    init(code: NSString, position: CShort) {
        self.code = code
        self.position = position
        super.init(header: DZH_DATAHEAD(2942, 2), parser: DZHResponsePackage2942())
    }
    
    override public func serializeBody() -> Data? {
        let body: NSMutableData = NSMutableData()
        body.writeValue(code)
        body.writeValue(position)
        return body as Data
    }
}

open class DZHResponsePackage2942Item: NSObject {
    open var time: Int = 0 //时间
    open var price: Int = 0//最新价
    open var volume: Int = 0//成交量
    open var averagePrice: Int = 0//均价
    open var holdVolume: Int = 0//持仓量
    
    func deSerialize(_ data: Data, pos: UnsafeMutablePointer<Int>) {
        let byteSize = MemoryLayout<CInt>.size
        data.readValue(&time, size: byteSize, pos: pos)
        data.readValue(&price, size: byteSize, pos: pos)
        data.readValue(&volume, size: byteSize, pos: pos)
        data.readValue(&averagePrice, size: byteSize, pos: pos)
        data.readValue(&holdVolume, size: byteSize, pos: pos)
    }
}

open class DZHResponsePackage2942: DZHResponseDataParser {
    open var marketTime: NSMutableString = NSMutableString()//交易时间段
    open var totalNum: CUnsignedShort = 0 //总分时点个数
    open var holdTag: CChar = 0 //持仓标记
    open var bombCount: CChar = 0 //信息地雷数
    open var starVal: CChar = 0 //五星评级
    open var position: CShort = 0 //数据位置
    open var items: NSMutableArray = NSMutableArray()//分时数据
    
    override open func deSerialize(_ body: Data?) {
        if body != nil {
            let attrs = (header as! DZH_DATAHEAD).attrs
            let depressData: Data
            if (attrs >> 1 & 0x1) == 1 {
                depressData = DZHMarketDataDecompression.expandMinLineData(body, marketTime: marketTime, minLineTotalNum: &totalNum)
            }else{
                depressData = body!
            }
            var pos: Int = 0
            depressData.readValue(&holdTag, size: MemoryLayout<CChar>.size, pos: &pos)
            depressData.readValue(&bombCount, size: MemoryLayout<CChar>.size, pos: &pos)
            depressData.readValue(&starVal, size: MemoryLayout<CChar>.size, pos: &pos)
            depressData.readValue(&position, size: MemoryLayout<CShort>.size, pos: &pos)
            var itemCount = 0
            depressData.readValue(&itemCount, size: MemoryLayout<CShort>.size, pos: &pos)
            let arr: NSMutableArray = NSMutableArray.init(capacity: itemCount)
            for _ in 0 ..< itemCount {
                let item = DZHResponsePackage2942Item()
                item.deSerialize(depressData, pos: &pos)
                arr.add(item)
            }
            items = arr
        }
    }
}

open class DZHRequestPackage2944: DZHMarketRequestPackage {
    open var code: NSString//代码
    open var type: CChar//K线类型
    open var endDate: CInt//截至日期
    open var reqNumber: CShort//请求根数
    
    init(code: NSString, type: CChar, endDate: CInt, reqNumber: CShort) {
        self.code = code
        self.type = type
        self.endDate = endDate
        self.reqNumber = reqNumber
        super.init(header: DZH_DATAHEAD(2944, 2), parser: DZHResponsePackage2944())
    }
    
    override public func serializeBody() -> Data? {
        let body: NSMutableData = NSMutableData()
        body.writeValue(code)
        body.writeValue(type)
        body.writeValue(endDate)
        body.writeValue(reqNumber)
        return body as Data
    }
}

open class DZHResponsePackage2944Item: NSObject {
    open var date: CInt = 0 //日期
    open var open: CInt = 0//开盘价
    open var high: CInt = 0//最高价
    open var low: CInt = 0//最低价
    open var close: CInt = 0//收盘价
    open var volume: Int64 = 0//成交量
    open var turnover: CInt = 0//成交额
    open var holdVolume: CInt = 0//持仓量
    
    func deSerialize(_ data: Data, pos: UnsafeMutablePointer<Int>) {
        let byteSize = MemoryLayout<CInt>.size
        data.readValue(&date, size: byteSize, pos: pos)
        data.readValue(&open, size: byteSize, pos: pos)
        data.readValue(&high, size: byteSize, pos: pos)
        data.readValue(&low, size: byteSize, pos: pos)
        data.readValue(&close, size: byteSize, pos: pos)
        data.readValue(&volume, size: byteSize, pos: pos)
        volume = volume.expand()
        data.readValue(&turnover, size: byteSize, pos: pos)
        data.readValue(&holdVolume, size: byteSize, pos: pos)
    }
}

open class DZHResponsePackage2944: DZHResponseDataParser {
    open var holdTag: CChar = 0 //持仓标记
    open var items: NSMutableArray = NSMutableArray()//k线数据
    
    override open func deSerialize(_ body: Data?) {
        if body != nil {
            let attrs = (header as! DZH_DATAHEAD).attrs
            let depressData: Data
            if (attrs >> 1 & 0x1) == 1 {
                depressData = DZHMarketDataDecompression.expandKLineData(body)
            }else{
                depressData = body!
            }
            var pos: Int = 0
            depressData.readValue(&holdTag, size: MemoryLayout<CChar>.size, pos: &pos)
            var itemCount = 0
            depressData.readValue(&itemCount, size: MemoryLayout<CShort>.size, pos: &pos)
            let arr: NSMutableArray = NSMutableArray.init(capacity: itemCount)
            for _ in 0 ..< itemCount {
                let item = DZHResponsePackage2944Item()
                item.deSerialize(depressData, pos: &pos)
                arr.add(item)
            }
            items = arr
        }
    }
}

open class DZHRequestPackage2958: DZHMarketRequestPackage {
    open var code: NSString//代码
    open var type: CChar//除权方式
    
    init(code: NSString, type: CChar) {
        self.code = code
        self.type = type
        super.init(header: DZH_DATAHEAD(2958), parser: DZHResponsePackage2944())
    }
    
    override public func serializeBody() -> Data? {
        let body: NSMutableData = NSMutableData()
        body.writeValue(code)
        body.writeValue(type)
        return body as Data
    }
}

open class DZHResponsePackage2958Item: NSObject {
    open var date: CInt = 0 //日期
    open var ratio: CFloat = 0//系数
    open var constant: CFloat = 0//常数
    
    func deSerialize(_ data: Data, pos: UnsafeMutablePointer<Int>) {
        let byteSize = MemoryLayout<CInt>.size
        data.readValue(&date, size: byteSize, pos: pos)
        data.readValue(&ratio, size: byteSize, pos: pos)
        data.readValue(&constant, size: byteSize, pos: pos)
    }
}

open class DZHResponsePackage2958: DZHResponseDataParser {
    open var items: NSMutableArray = NSMutableArray()//除权数据
    
    override open func deSerialize(_ body: Data?) {
        if body != nil {
            var pos: Int = 0
            let data = body!
            var itemCount = 0
            data.readValue(&itemCount, size: MemoryLayout<CShort>.size, pos: &pos)
            let arr: NSMutableArray = NSMutableArray.init(capacity: itemCount)
            for _ in 0 ..< itemCount {
                let item = DZHResponsePackage2958Item()
                item.deSerialize(data, pos: &pos)
                arr.add(item)
            }
            items = arr
        }
    }
}
