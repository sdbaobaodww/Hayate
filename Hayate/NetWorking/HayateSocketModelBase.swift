//
//  HayateSocketModelBase.swift
//  Hayate
//
//  Created by Duanwwu on 16/5/28.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

public typealias ResponseComplete = (status: ResponseStatus) -> Void

//请求包状态
public enum RequestStatus {
    case Default //默认
    case Inited //已初始化
    case Enqueue //已入发送队列
    case Serialized //已序列化
    case Sended //已发送
    case Received //已收到数据
    case DeSerialized //已反序列化
    
    func toString() -> String {
        switch self {
            case Default: return "默认"
            case Inited: return "已初始化"
            case Enqueue: return "已入发送队列"
            case Serialized: return "已序列化"
            case Sended: return "已发送"
            case Received: return "已收到数据"
            case DeSerialized: return "已反序列化"
        }
    }
}

//数据响应状态
public enum ResponseStatus {
    case Success //响应成功
    case Timeout //超时
    case SocketClose //socket关闭
}

//请求包头协议
protocol HayatePackageHeader {
    
    func id() -> CLong//数据包id，用于对包进行区分匹配
    
    func packageType() -> Int//数据包类型
    
    mutating func serialize(bodySize: UInt) -> NSMutableData//将包头值序列化成二进制数据
    
    mutating func deSerialize(data: NSData, pos: UnsafeMutablePointer<Int>) -> Int//根据二进制数据进行反序列化设置包头值，并返回内容数据长度
    
    static func minSize() -> Int//包头最小长度
    
    static func maxSize() -> Int//包头最大长度
    
    var headerSize: Int {get}//包头最终的长度
}

//行情数据包头
public struct DZH_DATAHEAD: HayatePackageHeader {
    
    public var tag: CUnsignedChar
    public var type: CUnsignedShort
    public var attrs: CUnsignedShort
    public var length: UInt
    public var headerSize: Int = 7
    
    init() {
        self.init(123, 0, 0, 0)
    }
    
    init(_ tag: CUnsignedChar, _ type: CUnsignedShort, _ attrs: CUnsignedShort, _ length: UInt) {
        self.tag = tag
        self.type = type
        self.attrs = attrs
        self.length = length
    }
    
    func id() -> CLong {
        return CLong(type) * 1000 + CLong(tag)
    }
    
    func packageType() -> Int {
        return Int(type)
    }
    
    mutating func serialize(bodySize: UInt) -> NSMutableData {
        let header: NSMutableData = NSMutableData()
        header.writeValue(tag)
        header.writeValue(type)
        header.writeValue(attrs)
        length = bodySize
        header.writeValue(ushort(bodySize))
        return header
    }
    
    mutating func deSerialize(data: NSData, pos: UnsafeMutablePointer<Int>) -> Int {
        data.readValue(&tag, size: sizeof(CChar), pos: pos)
        data.readValue(&type, size: sizeof(CShort), pos: pos)
        data.readValue(&attrs, size: sizeof(CShort), pos: pos)
        let attr = (attrs & 0x8) >> 3 //取长度扩充位，当置位时，用int表示数据长度；否则用short表示长度；
        let byteSize = attr == 1 ? sizeof(Int32) : sizeof(CShort)
        headerSize = 5 + byteSize
        data.readValue(&length, size: byteSize, pos: pos)//读取包的数据长度
        return Int(length)
    }
    
    static func minSize() -> Int {
        return 7
    }
    
    static func maxSize() -> Int {
        return 9
    }
}

//请求包基类
public class HayateRequestPackage: NSObject {
    
    var status: RequestStatus = .Default//请求包状态
    
    var header: HayatePackageHeader//包头
    
    public var responseCompletion: ResponseComplete?//响应回调block
    
    public var ignorResponse: Bool = false //是否忽略掉响应
    
    public var responseParser: DZHResponseDataParser?//响应数据解析器
    
    init(header: HayatePackageHeader) {
        self.header = header
        status = .Inited
    }
    
    //如果responseParser未初始化，则调用此方法进行初始化
    func generateResponseParser(responseHeader: HayatePackageHeader) {
        
    }
    
    //发送请求
    final func sendRequest(completion: ResponseComplete) {
        self.responseCompletion = completion
        SchedulingServerManager.sharedInstance.socketManager.addRequestPackage(self)
    }
    
    //对数据进行序列化，生成二进制数据
    func serialize() -> NSData {
        return NSMutableData()
    }
    
    //收到数据处理
    func receiveData(responseHeader: HayatePackageHeader, data: NSData?) {
        status = .Received
        if responseParser == nil {
            self.generateResponseParser(responseHeader)
        }
        responseParser?.header = responseHeader
        responseParser?.deSerialize(data)
        status = .DeSerialized
    }
    
    //响应数据匹配的请求包
    func isMatchPackage(responseHeader: HayatePackageHeader) -> Bool {
        return header.id() == responseHeader.id()
    }
    
    //是否处理完成
    func isFinished() -> Bool {
        return (ignorResponse && status == .Sended) || status == .DeSerialized
    }
}

//行情请求包基类
public class DZHMarketRequestPackage: HayateRequestPackage {
    
    init(header: HayatePackageHeader, parser: DZHResponseDataParser?) {
        super.init(header: header)
        self.responseParser = parser
    }
    
    override convenience init(header: HayatePackageHeader) {
        self.init(header: header, parser: nil)
    }
    
    //方法调用后将返回body数据跟头部数据组合而成的数据包
    func wrapBody(bodyData: NSData?) -> NSData {
        if bodyData == nil {//空包头
            let data = self.header.serialize(0)
            status = .Serialized
            return data
        }else{
            let data = self.header.serialize(UInt(bodyData!.length))
            data.appendData(bodyData!);
            status = .Serialized
            return data
        }
    }
    
    func serializeBody() -> NSData? {
        return nil
    }
    
    override func serialize() -> NSData {
        return self.wrapBody(self.serializeBody())
    }
}

//行情组包请求
public class DZHMarketRequestGroupPackage: HayateRequestPackage {
    
    var group: Array<HayateRequestPackage> = []//组包队列
    
    init() {
        super.init(header: DZH_DATAHEAD(HayateTagCreator.sharedInstance.tag(), 0, 0, 0))
    }
    
    func addPackage(package: HayateRequestPackage) {
        group.append(package)
    }
    
    override func serialize() -> NSData {
        let groupData = NSMutableData()
        for package in group {
            groupData.appendData(package.serialize())
        }
        status = .Serialized
        return groupData
    }
    
    override func receiveData(responseHeader: HayatePackageHeader, data: NSData?) {
        status = .Received
        for package in group {
            if package.isMatchPackage(responseHeader) {
                package.receiveData(responseHeader, data: data)
                if package.isFinished(){//接收结束
                    package.responseCompletion?(status: ResponseStatus.Success)
                }
            }
        }
    }
    
    override func isMatchPackage(responseHeader: HayatePackageHeader) -> Bool {
        for package in group {
            if package.isMatchPackage(responseHeader) {
                return true
            }
        }
        return false
    }
    
    override func isFinished() -> Bool {
        for package in group {
            if package.status != .DeSerialized {//只要有未反序列化的包就代表还未结束
                return false
            }
        }
        return true
    }
}

//响应数据解析器基类
public class DZHResponseDataParser: NSObject {
    
    var header: HayatePackageHeader? //响应包头
    
    //反序列化数据
    public func deSerialize(body: NSData?) {}
}

//包头tag生成类
class HayateTagCreator {
    
    private var seqId: CUnsignedChar = 0
    
    class var sharedInstance: HayateTagCreator {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: HayateTagCreator? = nil
        }
        dispatch_once(&Static.onceToken, { () -> Void in
            Static.instance = HayateTagCreator()
        })
        return Static.instance!
    }
    
    // 请求包包头标记[1~240]除123和125; 推送包包头标记[0,241~255]
    func tag() -> CUnsignedChar {
        if (seqId > 240){
            seqId = 1
        }else{
            seqId += 1
        }
        if (seqId == 123 || seqId == 125) {
            seqId += 1
        }
        return seqId;
    }
}
