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
    
    func findRequestPackage(_ tag: CLong) -> HayateRequestPackage?//根据请求id查找对应的发送包
    
    func findRequestPackage(_ responseHeader: HayatePackageHeader) -> HayateRequestPackage?//根据返回数据包头查找对应的发送包
}

/**
 * Socket管理基类
 */
open class HayateSocketManagerBase: NSObject,HayateSocketDataManager {
    open var timeout: TimeInterval = 7//超时时间
    open var receiveBytes: Int = 0//接收到的数据长度
    fileprivate let maxWaitResponse: Int //等待响应队列数据个数限制
    fileprivate let maxWaitSend: Int //等待发送队列数据个数限制
    var header: HayatePackageHeader//数据包头
    let headerLength: Int//包头最少占用的长度
    var socketTransceiver: HayateSocketTransceiver//socket数据收发器
    var waitSendQueue = NSMutableArray()//等待发送队列
    var waitResponseQueue = NSMutableArray()//等待响应队列
    var receiveDatas = NSMutableData()//响应数据
    let operateQueue = DispatchQueue(label: "SocketManager", attributes: [])//socket delegate回调 和 对请求包操作所在的线程
    weak var monitor: HayateSocketMonitor?
    
    init(header: HayatePackageHeader, maxWaitSend: Int, maxWaitResponse: Int, monitor: HayateSocketMonitor?) {
        self.header = header
        self.maxWaitSend = maxWaitSend
        self.maxWaitResponse = maxWaitResponse
        self.monitor = monitor
        headerLength = type(of: header).minSize()
        socketTransceiver = HayateSocketTransceiver(delegateQueue: operateQueue)
        super.init()
        
        self.monitor?.addMonitorObject(self)
        
        socketTransceiver.connectSuccessBlock = { [unowned self] (host: NSString, port: ushort) in
            self.didConnectHost(host, port: port)
        }
        socketTransceiver.connectFailureBlock = { [unowned self] (host: NSString, port: ushort) in
            self.connectHostFailure(host, port: port)
        }
        socketTransceiver.disConnectBlock = { [unowned self] () in
            self.didDisConnect()
        }
        socketTransceiver.writeSuccessBlock = { [unowned self] (tag: CLong) in
            self.didWriteData(tag)
        }
        socketTransceiver.readSuccessBlock = { [unowned self] (data: Data) in
            self.didReadData(data)
        }
    }
    
    func didConnectHost(_ host: NSString, port: ushort) {
        LOG_DEBUG(LogModule.socket, "连接行情服务器成功 \(host):\(port)")
    }
    
    func connectHostFailure(_ host: NSString, port: ushort) {
        LOG_DEBUG(LogModule.socket, "连接行情服务器失败 \(host):\(port)")
    }
    
    func didDisConnect() {
        LOG_DEBUG(LogModule.socket, "行情服务器断开连接成功")
        self.removeAllPackage(self.waitSendQueue)
        self.removeAllPackage(self.waitResponseQueue)
        self.notifyPackageCountChange()
    }
    
    func didWriteData(_ tag: CLong) {
        let requestPackage = self.findRequestPackage(tag)//从等待发送队列查找请求包
        if let package = requestPackage {
            package.status = RequestStatus.sended
            if package.ignorResponse { //不需要等待返回的发送完成后，直接结束请求流程
                self.setPackageResponseStatus(package, status: ResponseStatus.success)//响应状态置为Success
            }else{//需要响应数据的加入待响应队列
                LOG_DEBUG(LogModule.socket, "加入待响应队列:\(package.header.id())")
                self.waitResponseQueue.add(package)
            }
            self.waitSendQueue.remove(package)
            LOG_DEBUG(LogModule.socket, "从待发送队列移除:\(package.header.id())")
            self.notifyPackageCountChange()//包个数变更处理
        }
        self.notifySendPackage()//如果可能，发送请求数据
    }
    
    func didReadData(_ data: Data) {
        receiveBytes += data.count
        receiveDatas.append(data)
        self.responseDataHandle(receiveDatas as Data)
        self.notifySendPackage()//如果可能，发送请求数据
    }
    
    open func sendRequestPackage(_ package: HayateRequestPackage) {
        operateQueue.async {
            if self.isConnected() {//socket已连接
                self.waitSendQueue.add(package)//加入等待发送队列
                LOG_DEBUG(LogModule.socket, "加入待发送队列:\(package.header.id())")
                package.status = RequestStatus.enqueue
                if !package.ignorResponse { //只有需要等待返回的才有超时处理
                    self.addTimeoutHandle(package)
                }
                if self.waitSendQueue.count > self.maxWaitSend {
                    self.removePackageAtIndex(self.waitSendQueue, index: 0)
                }
                self.notifyPackageCountChange()//包个数变更处理
                self.notifySendPackage()//如果可能，发送请求数据
            }else{//socket未连接
                self.setPackageResponseStatus(package, status: ResponseStatus.socketClose)
            }
        }
    }
    
    func notifySendPackage() {
        //从待发送队列中找出第一个还未进行发送的请求包
        for item in self.waitSendQueue {
            let package = item as! HayateRequestPackage
            if package.status == RequestStatus.enqueue {
                //1，不需要返回数据，直接发送；2，需要返回数据，则判断等待响应队列是否超出阀值
                if package.ignorResponse || self.waitResponseQueue.count < self.maxWaitResponse {
                    self.socketTransceiver.sendData(package.serialize(), tag: package.header.id())
                    print("发送请求包:\(package.header.id())")
                }
                break
            }
        }
    }
    
    func responseDataHandle(_ data: Data) {
        var pos = 0 //处理的长度
        while data.count >= pos + headerLength {
            var itempos = pos //每个包独立一个位置变量
            let length = header.deSerialize(data, pos: &itempos)//反序列化包头数据
            if itempos + length > data.count {//缺少数据情况，忽略掉该头部数据，以便接受完数据后继续处理
                LOG_DEBUG(LogModule.socket, "数据未完全返回:\(header.id())")
                break
            }else{//数据正常
                let requestPackage = self.findRequestPackage(header)//从等待响应队列查找请求包
                if requestPackage == nil {
                    LOG_ERROR(LogModule.socket, "找不到请求包:\(header.id())")
                }else{
                    LOG_DEBUG(LogModule.socket, "接收到响应数据:\(header.id())")
                    let package = requestPackage!
                    //无响应数据请求没有超时处理、组包请求第一次收到数据就已取消过超时处理
                    if !package.ignorResponse && package.status != RequestStatus.received{
                        self.cancelTimeoutHandle(package)
                    }
                    package.receiveData(header, data: length > 0 ? data.subdata(in: Range(itempos ..< itempos + length)) : nil)
                    if package.isFinished() {//接收结束
                        self.setPackageResponseStatus(package, status: ResponseStatus.success)//响应状态置为Success
                        self.waitResponseQueue.remove(package)//已接收完成数据，将包从等待响应队列移除
                        LOG_DEBUG(LogModule.socket, "从待响应队列移除:\(package.header.id())")
                    }
                }
                itempos += length
                pos = itempos
            }
        }
        self.receiveDatas.replaceBytes(in: NSMakeRange(0, pos), withBytes: nil, length: 0)//删除处理完成的数据
        self.notifyPackageCountChange()//包个数变更处理
    }
    
    open func connectHost(_ host: String, port: ushort) {
        socketTransceiver.connectToHost(host, port: port, timeout: timeout)
    }
    
    open func disconnect() {
        socketTransceiver.disconnect()
    }
    
    open func isConnected() -> Bool {
        return socketTransceiver.isConnected()
    }
    
    func notifyPackageCountChange() {
        monitor?.notify(self)
    }
    
    func removePackageAtIndex(_ queue: NSMutableArray, index: Int) {
        let package = queue.object(at: index) as! HayateRequestPackage
        self.cancelTimeoutHandle(package)
        queue.removeObject(at: index)
    }
    
    func removeAllPackage(_ queue: NSMutableArray) {
        for item in queue {
            let package = item as! HayateRequestPackage
            self.cancelTimeoutHandle(package)//取消超时处理
            self.setPackageResponseStatus(package, status: ResponseStatus.socketClose)//响应状态置为SocketClose
        }
        queue.removeAllObjects()
    }
    
    func setPackageResponseStatus(_ package: HayateRequestPackage, status: ResponseStatus) {
        if let completion = package.responseCompletion {
            completion(status, package)//响应状态置为SocketClose
        }
    }
    
    func addTimeoutHandle(_ package: HayateRequestPackage) {
        DispatchQueue.main.async {
            self.perform(#selector(self.requestTimeout(_:)), with: package, afterDelay: self.timeout)
        }
    }
    
    func cancelTimeoutHandle(_ package : HayateRequestPackage) {
        DispatchQueue.main.async {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.requestTimeout(_:)), object: package)
        }
    }
    
    func requestTimeout(_ package: HayateRequestPackage) {
        operateQueue.async {
            print("请求包超时:\(package.header.id()) 当前状态:\(package.status)")
            if package.status == RequestStatus.serialized {//如果已经序列化了，则请求包位于等待响应队列，否则位于等待发送队列
                self.waitResponseQueue.remove(package)
            }else{
                self.waitSendQueue.remove(package)
            }
            self.setPackageResponseStatus(package, status: ResponseStatus.timeout)//响应状态置为Timeout
        }
    }
    
    func waitSendCount() -> Int {
        return self.waitSendQueue.count
    }
    
    func waitResponseCount() -> Int {
        return self.waitResponseQueue.count
    }
    
    func findRequestPackage(_ tag: CLong) -> HayateRequestPackage? {
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
    
    func findRequestPackage(_ responseHeader: HayatePackageHeader) -> HayateRequestPackage? {
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

open class HayateMarketSocketManager: HayateSocketManagerBase {
    
    init(monitor: HayateSocketMonitor?) {
        super.init(header: DZH_DATAHEAD(), maxWaitSend: 10, maxWaitResponse: 10, monitor: monitor)
    }
    
    override func didConnectHost(_ host: NSString, port: ushort) {
        super.didConnectHost(host, port: port)
        NotificationCenter.default.post(name: Notification.Name(rawValue: HayateConnectSuccessNotification), object: nil)
    }
    
    override func didDisConnect() {
        super.didDisConnect()
        NotificationCenter.default.post(name: Notification.Name(rawValue: HayateDisConnectNotification), object: nil)
    }
}
