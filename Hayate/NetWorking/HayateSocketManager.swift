//
//  HayateSocketManager.swift
//  Hayate
//
//  Created by Duanwwu on 16/5/28.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

public let HayateConnectSuccessNotification: String = "HayateConnectSuccessNotification" //行情服务器连接成功通知
public let HayateDisConnectNotification: String = "HayateDisConnectNotification" //行情服务器关闭成功通知

protocol HayateSocketDataManager {
    
    var receiveBytes: Int {get}
    
    func waitSendCount() -> Int
    
    func waitResponseCount() -> Int
    
    func findRequestPackage(tag: CLong) -> HayateRequestPackage?//根据请求id查找对应的发送包
    
    func findRequestPackage(responseHeader: HayatePackageHeader) -> HayateRequestPackage?//根据返回数据包头查找对应的发送包
}

public class HayateSocketManagerBase: NSObject,HayateSocketDataManager {
    public var timeout: NSTimeInterval = 7//超时时间
    public var receiveBytes: Int = 0//接收到的数据长度
    private let maxWaitResponse: Int //等待响应队列数据个数限制
    private let maxWaitSend: Int //等待发送队列数据个数限制
    var header: HayatePackageHeader//数据包头
    let headerLength: Int//包头最少占用的长度
    var socketTransceiver: HayateSocketTransceiver//socket数据收发器
    var waitSendQueue = NSMutableArray()//等待发送队列
    var waitResponseQueue = NSMutableArray()//等待响应队列
    var receiveDatas = NSMutableData()//响应数据
    let operateQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)//socket delegate回调 和 对请求包操作所在的线程
    weak var monitor: HayateSocketMonitor?
    
    init(header: HayatePackageHeader, maxWaitSend: Int, maxWaitResponse: Int, monitor: HayateSocketMonitor?) {
        self.header = header
        self.maxWaitSend = maxWaitSend
        self.maxWaitResponse = maxWaitResponse
        self.monitor = monitor
        headerLength = header.dynamicType.minSize()
        socketTransceiver = HayateSocketTransceiver(delegateQueue: operateQueue)
        super.init()
        
        self.monitor?.addMonitorObject(self)
        
        socketTransceiver.connectSuccessBlock = { (host: NSString, port: ushort) in
            self.didConnectHost(host, port: port)
        }
        socketTransceiver.connectFailureBlock = { (host: NSString, port: ushort) in
            self.connectHostFailure(host, port: port)
        }
        socketTransceiver.disConnectBlock = { () in
            self.didDisConnect()
        }
        socketTransceiver.writeSuccessBlock = { (tag: CLong) in
            self.didWriteData(tag)
        }
        socketTransceiver.readSuccessBlock = { (data: NSData) in
            self.didReadData(data)
        }
    }
    
    func didConnectHost(host: NSString, port: ushort) {
        print("连接行情服务器成功 \(host):\(port)")
    }
    
    func connectHostFailure(host: NSString, port: ushort) {
        print("连接行情服务器失败 \(host):\(port)")
    }
    
    func didDisConnect() {
        print("行情服务器断开连接成功")
        self.removeAllPackage(self.waitSendQueue)
        self.removeAllPackage(self.waitResponseQueue)
        self.notifyPackageCountChange()
    }
    
    func didWriteData(tag: CLong) {
        let requestPackage = self.findRequestPackage(tag)//从等待发送队列查找请求包
        if let package = requestPackage {
            package.status = RequestStatus.Sended
            if package.ignorResponse { //不需要等待返回的发送完成后，直接结束请求流程
                self.setPackageResponseStatus(package, status: ResponseStatus.Success)//响应状态置为Success
            }else{//需要响应数据的加入待响应队列
                print("加入待响应队列:\(package.header.id())")
                self.waitResponseQueue.addObject(package)
            }
            self.waitSendQueue.removeObject(package)
            print("从待发送队列移除:\(package.header.id())")
            self.notifyPackageCountChange()//包个数变更处理
        }
        self.notifySendPackage()//如果可能，发送请求数据
    }
    
    func didReadData(data: NSData) {
        receiveBytes += data.length
        receiveDatas.appendData(data)
        self.responseDataHandle(receiveDatas)
        self.notifySendPackage()//如果可能，发送请求数据
    }
    
    func addRequestPackage(package: HayateRequestPackage) {
        dispatch_async(operateQueue) {
            if self.isConnected() {//socket已连接
                self.waitSendQueue.addObject(package)//加入等待发送队列
                print("加入待发送队列:\(package.header.id())")
                package.status = RequestStatus.Enqueue
                if !package.ignorResponse { //只有需要等待返回的才有超时处理
                    self.addTimeoutHandle(package)
                }
                if self.waitSendQueue.count > self.maxWaitSend {
                    self.removePackageAtIndex(self.waitSendQueue, index: 0)
                }
                self.notifyPackageCountChange()//包个数变更处理
                self.notifySendPackage()//如果可能，发送请求数据
            }else{//socket未连接
                self.setPackageResponseStatus(package, status: ResponseStatus.SocketClose)
            }
        }
    }
    
    func notifySendPackage() {
        //从待发送队列中找出第一个还未进行发送的请求包
        for item in self.waitSendQueue {
            let package = item as! HayateRequestPackage
            if package.status == RequestStatus.Enqueue {
                //1，不需要返回数据，直接发送；2，需要返回数据，则判断等待响应队列是否超出阀值
                if package.ignorResponse || self.waitResponseQueue.count < self.maxWaitResponse {
                    self.socketTransceiver.sendData(package.serialize(), tag: package.header.id())
                    print("发送请求包:\(package.header.id())")
                }
                break
            }
        }
    }
    
    func responseDataHandle(data: NSData) {
        var pos = 0 //处理的长度
        while data.length >= pos + headerLength {
            var itempos = pos //每个包独立一个位置变量
            let length = header.deSerialize(data, pos: &itempos)//反序列化包头数据
            if itempos + length > data.length {//缺少数据情况，忽略掉该头部数据，以便接受完数据后继续处理
                print("数据未完全返回:\(header.id())")
                break
            }else{//数据正常
                let requestPackage = self.findRequestPackage(header)//从等待响应队列查找请求包
                if requestPackage == nil {
                    print("找不到请求包:\(header.id())")
                }else{
                    print("接收到响应数据:\(header.id())")
                    let package = requestPackage!
                    //无响应数据请求没有超时处理、组包请求第一次收到数据就已取消过超时处理
                    if !package.ignorResponse && package.status != RequestStatus.Received{
                        self.cancelTimeoutHandle(package)
                    }
                    package.receiveData(header, data: length > 0 ? data.subdataWithRange(NSMakeRange(itempos, length)) : nil)
                    if package.isFinished() {//接收结束
                        self.setPackageResponseStatus(package, status: ResponseStatus.Success)//响应状态置为Success
                        self.waitResponseQueue.removeObject(package)//已接收完成数据，将包从等待响应队列移除
                        print("从待响应队列移除:\(package.header.id())")
                    }
                }
                itempos += length
                pos = itempos
            }
        }
        self.receiveDatas.replaceBytesInRange(NSMakeRange(0, pos), withBytes: nil, length: 0)//删除处理完成的数据
        self.notifyPackageCountChange()//包个数变更处理
    }
    
    public func connectHost(host: String, port: ushort) {
        socketTransceiver.connectToHost(host, port: port, timeout: timeout)
    }
    
    public func disconnect() {
        socketTransceiver.disconnect()
    }
    
    public func isConnected() -> Bool {
        return socketTransceiver.isConnected()
    }
    
    func notifyPackageCountChange() {
        monitor?.notify(self)
    }
    
    func removePackageAtIndex(queue: NSMutableArray, index: Int) {
        let package = queue.objectAtIndex(index) as! HayateRequestPackage
        self.cancelTimeoutHandle(package)
        queue.removeObjectAtIndex(index)
    }
    
    func removeAllPackage(queue: NSMutableArray) {
        for item in queue {
            let package = item as! HayateRequestPackage
            self.cancelTimeoutHandle(package)//取消超时处理
            self.setPackageResponseStatus(package, status: ResponseStatus.SocketClose)//响应状态置为SocketClose
        }
        queue.removeAllObjects()
    }
    
    func setPackageResponseStatus(package: HayateRequestPackage, status: ResponseStatus) {
        if let completion = package.responseCompletion {
            completion(status: status, package: package)//响应状态置为SocketClose
        }
    }
    
    func addTimeoutHandle(package: HayateRequestPackage) {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSelector(#selector(self.requestTimeout(_:)), withObject: package, afterDelay: self.timeout)
        }
    }
    
    func cancelTimeoutHandle(package : HayateRequestPackage) {
        dispatch_async(dispatch_get_main_queue()) {
            NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(self.requestTimeout(_:)), object: package)
        }
    }
    
    func requestTimeout(package: HayateRequestPackage) {
        dispatch_async(operateQueue) {
            print("请求包超时:\(package.header.id()) 当前状态:\(package.status)")
            if package.status == RequestStatus.Serialized {//如果已经序列化了，则请求包位于等待响应队列，否则位于等待发送队列
                self.waitResponseQueue.removeObject(package)
            }else{
                self.waitSendQueue.removeObject(package)
            }
            self.setPackageResponseStatus(package, status: ResponseStatus.Timeout)//响应状态置为Timeout
        }
    }
    
    func waitSendCount() -> Int {
        return self.waitSendQueue.count
    }
    
    func waitResponseCount() -> Int {
        return self.waitResponseQueue.count
    }
    
    func findRequestPackage(tag: CLong) -> HayateRequestPackage? {
        var requestPackage: HayateRequestPackage?
        for item in self.waitSendQueue {
            let package = item as! HayateRequestPackage
            if package.header.id() == tag{
                requestPackage = package
                break
            }
        }
        return requestPackage
    }
    
    func findRequestPackage(responseHeader: HayatePackageHeader) -> HayateRequestPackage? {
        var requestPackage: HayateRequestPackage?
        for item in self.waitResponseQueue {
            let package = item as! HayateRequestPackage
            if package.isMatchPackage(responseHeader){
                requestPackage = package
                break
            }
        }
        return requestPackage
    }
}

public class HayateMarketSocketManager: HayateSocketManagerBase {
    
    init(monitor: HayateSocketMonitor?) {
        super.init(header: DZH_DATAHEAD(), maxWaitSend: 10, maxWaitResponse: 10, monitor: monitor)
    }
    
    override func didConnectHost(host: NSString, port: ushort) {
        super.didConnectHost(host, port: port)
        NSNotificationCenter.defaultCenter().postNotificationName(HayateConnectSuccessNotification, object: nil)
    }
    
    override func didDisConnect() {
        super.didDisConnect()
        NSNotificationCenter.defaultCenter().postNotificationName(HayateDisConnectNotification, object: nil)
    }
}
