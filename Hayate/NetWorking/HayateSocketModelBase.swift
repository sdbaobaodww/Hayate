//
//  HayateSocketModelBase.swift
//  Hayate
//
//  Created by Duanwwu on 16/5/28.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

public typealias ResponseComplete = (status: ResponseStatus) -> Void

public enum RequestStatus {
    case Default //默认
    case Inited //已初始化
    case Enqueue //已入发送队列
    case Serialized //已序列化
    case Sended //已发送
    case Received //已收到数据
    case DeSerialized //已反序列化
}

public enum ResponseStatus {
    case Success //响应成功
    case Timeout //超时
    case SocketClose //socket关闭
}

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
    public var ignorResponse: Bool = false
    public var parser: DZHResponseDataParser?
    var status: RequestStatus = .Default
    var header: DZH_DATAHEAD
    var responseCompletion: ResponseComplete?
    
    init(header: DZH_DATAHEAD) {
        self.header = header
        status = .Inited
        super.init()
    }
    
    func responseParser(responseHeader: DZH_DATAHEAD) -> DZHResponseDataParser {
        if parser == nil {
            parser = DZHResponseDataParser()
        }
        return parser!
    }
    
    //方法调用后将返回body数据跟头部数据组合而成的数据包
    private func wrapBody(bodyData: NSData?) -> NSData {
        if bodyData == nil {//空包头
            let data = self.header.serialize(0)
            status = .Serialized
            return data
        }else{
            let data = self.header.serialize(bodyData!.length)
            data.appendData(bodyData!);
            status = .Serialized
            return data
        }
    }
    
    public func serializeBody() -> NSData? {
        return nil
    }
    
    final public func sendRequest(completion: ResponseComplete) {
        self.responseCompletion = completion
        SchedulingServerManager.sharedInstance.socketManager.addRequestPackage(self)
        status = .Enqueue
    }
    
    final public func serialize() -> NSData {
        return self.wrapBody(self.serializeBody())
    }
    
    final public func receiveData(responseHeader: DZH_DATAHEAD, data: NSData?) {
        status = .Received
        let parser = self.responseParser(responseHeader)
        parser.header = header
        parser.deSerialize(data)
        status = .DeSerialized
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
