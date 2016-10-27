//
//  HayateSocketModelBase.swift
//  Hayate
//
//  Created by Duanwwu on 16/5/28.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

public typealias ResponseComplete = (_ status: ResponseStatus, _ package: HayateRequestPackage) -> Void
public typealias ResponsePackageMatch = (_ requestHeader: HayatePackageHeader, _ responseHeader: HayatePackageHeader) -> Bool

//请求包状态
public enum RequestStatus {
    case inited //已初始化
    case enqueue //已入发送队列
    case serialized //已序列化
    case sended //已发送
    case received //已收到数据
    case deSerialized //已反序列化
    
    func toString() -> String {
        switch self {
            case .inited: return "已初始化"
            case .enqueue: return "已入发送队列"
            case .serialized: return "已序列化"
            case .sended: return "已发送"
            case .received: return "已收到数据"
            case .deSerialized: return "已反序列化"
        }
    }
}

//数据响应状态
public enum ResponseStatus {
    case success //响应成功
    case timeout //超时
    case socketClose //socket关闭
}

//请求包头协议
public protocol HayatePackageHeader {
    
    func id() -> CLong//数据包id，用于对包进行区分匹配
    
    func packageType() -> Int//数据包类型
    
    mutating func serialize(_ bodySize: UInt) -> NSMutableData//将包头值序列化成二进制数据
    
    mutating func deSerialize(_ data: Data, pos: UnsafeMutablePointer<Int>) -> Int//根据二进制数据进行反序列化设置包头值，并返回内容数据长度
    
    static func minSize() -> Int//包头最小长度
    
    static func maxSize() -> Int//包头最大长度
    
    var headerSize: Int {get}//包头最终的长度
}

protocol HayateDataCollectionItem {
    func collectionPosition() -> CInt
}

//行情数据包头
public struct DZH_DATAHEAD: HayatePackageHeader {
    
    public var tag: CUnsignedChar
    public var type: CUnsignedShort
    public var attrs: CUnsignedShort
    public var length: UInt = 0
    public var headerSize: Int = 7
    
    init(_ tag: CUnsignedChar, _ type: CUnsignedShort, _ attrs: CUnsignedShort) {
        self.tag = tag
        self.type = type
        self.attrs = attrs
    }
    
    init(_ type: CUnsignedShort, _ attrs: CUnsignedShort) {
        self.init(HayateTagCreator.sharedInstance.tag(), type, attrs)
    }
    
    init(_ type: CUnsignedShort) {
        self.init(HayateTagCreator.sharedInstance.tag(), type, 0)
    }
    
    init() {
        self.init(123, 0, 0)
    }
    
    public func id() -> CLong {
        return CLong(type) * 1000 + CLong(tag)
    }
    
    public func packageType() -> Int {
        return Int(type)
    }
    
    mutating public func serialize(_ bodySize: UInt) -> NSMutableData {
        let header: NSMutableData = NSMutableData()
        header.writeValue(tag)
        header.writeValue(type)
        header.writeValue(attrs)
        length = bodySize
        header.writeValue(ushort(bodySize))
        return header
    }
    
    mutating public func deSerialize(_ data: Data, pos: UnsafeMutablePointer<Int>) -> Int {
        data.readValue(&tag, size: MemoryLayout<CChar>.size, pos: pos)
        data.readValue(&type, size: MemoryLayout<CShort>.size, pos: pos)
        data.readValue(&attrs, size: MemoryLayout<CShort>.size, pos: pos)
        let attr = (attrs & 0x8) >> 3 //取长度扩充位，当置位时，用int表示数据长度；否则用short表示长度；
        let byteSize = attr == 1 ? MemoryLayout<Int32>.size : MemoryLayout<CShort>.size
        headerSize = 5 + byteSize
        data.readValue(&length, size: byteSize, pos: pos)//读取包的数据长度
        return Int(length)
    }
    
    public static func minSize() -> Int {
        return 7
    }
    
    public static func maxSize() -> Int {
        return 9
    }
}

//请求包基类
open class HayateRequestPackage: NSObject {
    
    var status: RequestStatus = .inited//请求包状态
    
    var header: HayatePackageHeader//包头
    
    public var responseCompletion: ResponseComplete?//响应回调block
    
    //正确配对请求包与相应包
    public var responseMatch: ResponsePackageMatch = {(requestHeader: HayatePackageHeader, responseHeader: HayatePackageHeader) in
        return requestHeader.id() == responseHeader.id()
    }
    
    public var ignorResponse: Bool = false //是否忽略掉响应
    
    public var responseParser: DZHResponseDataParser?//响应数据解析器
    
    init(header: HayatePackageHeader) {
        self.header = header
    }
    
    //如果responseParser未初始化，则调用此方法进行初始化
    func generateResponseParser(_ responseHeader: HayatePackageHeader) {
        
    }
    
    //发送请求
    final func sendRequest(_ completion: @escaping ResponseComplete) {
        self.responseCompletion = completion
        AppDelegate.theMarketSocket().sendRequestPackage(self)
    }
    
    //对数据进行序列化，生成二进制数据
    func serialize() -> Data {
        return NSMutableData() as Data
    }
    
    //收到数据处理
    func receiveData(_ responseHeader: HayatePackageHeader, data: Data?) {
        status = .received
        if responseParser == nil {
            self.generateResponseParser(responseHeader)
        }
        responseParser?.header = responseHeader
        responseParser?.deSerialize(data)
        status = .deSerialized
    }
    
    //响应数据匹配的请求包
    func isMatchPackage(_ responseHeader: HayatePackageHeader) -> Bool {
        return self.responseMatch(header, responseHeader)
    }
    
    //是否处理完成
    func isFinished() -> Bool {
        return (ignorResponse && status == .sended) || status == .deSerialized
    }
}

//行情请求包基类
open class DZHMarketRequestPackage: HayateRequestPackage {
    
    init(header: HayatePackageHeader, parser: DZHResponseDataParser?) {
        super.init(header: header)
        self.responseParser = parser
    }
    
    override convenience init(header: HayatePackageHeader) {
        self.init(header: header, parser: nil)
    }
    
    //方法调用后将返回body数据跟头部数据组合而成的数据包
    func wrapBody(_ bodyData: Data?) -> Data {
        if bodyData == nil {//空包头
            let data = self.header.serialize(0)
            status = .serialized
            return data as Data
        }else{
            let data = self.header.serialize(UInt(bodyData!.count))
            data.append(bodyData!);
            status = .serialized
            return data as Data
        }
    }
    
    public func serializeBody() -> Data? {
        return nil
    }
    
    override public func serialize() -> Data {
        return self.wrapBody(self.serializeBody())
    }
}

//行情组包请求
public class DZHMarketRequestGroupPackage: HayateRequestPackage {
    
    open var group: Array<HayateRequestPackage> = []//组包队列
    
    init() {
        super.init(header: DZH_DATAHEAD(0))
    }
    
    public func addPackage(_ package: HayateRequestPackage) {
        group.append(package)
    }
    
    override func serialize() -> Data {
        let groupData = NSMutableData()
        for package in group {
            groupData.append(package.serialize())
        }
        status = .serialized
        return groupData as Data
    }
    
    override func receiveData(_ responseHeader: HayatePackageHeader, data: Data?) {
        status = .received
        for package in group {
            if package.isMatchPackage(responseHeader) {
                package.receiveData(responseHeader, data: data)
                if package.isFinished(){//接收结束
                    package.responseCompletion?(ResponseStatus.success, package)
                }
            }
        }
    }
    
    override func isMatchPackage(_ responseHeader: HayatePackageHeader) -> Bool {
        for package in group {
            if package.isMatchPackage(responseHeader) {
                return true
            }
        }
        return false
    }
    
    override func isFinished() -> Bool {
        for package in group {
            if package.status != .deSerialized {//只要有未反序列化的包就代表还未结束
                return false
            }
        }
        return true
    }
}

//响应数据解析器基类
open class DZHResponseDataParser: NSObject {
    
    var header: HayatePackageHeader? //响应包头
    
    //反序列化数据
    open func deSerialize(_ body: Data?) {}
}

//包头tag生成类
class HayateTagCreator {
    
    public static let sharedInstance = HayateTagCreator()
    private var seqId: CUnsignedChar = 0
    
    // 请求包包头标记[1~240]除123和125; 推送包包头标记[0,241~255]
    func tag() -> CUnsignedChar {
        if (seqId > 255){
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
