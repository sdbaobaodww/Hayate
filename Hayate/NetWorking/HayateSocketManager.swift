//
//  HayateSocketManager.swift
//  Hayate
//
//  Created by Duanwwu on 16/5/28.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

extension DZHRequestPackage {
    var sendTag: CLong {
        return CLong(header.type) * 1000 + CLong(header.tag)
    }
}

public let HayateConnectSuccessNotification: String = "HayateConnectSuccessNotification" //行情服务器连接成功通知

public class HayateSocketManager: NSObject {
    private var timeout: NSTimeInterval = 7
    private var socketTransceiver: HayateSocketTransceiver
    private var reponseProcessorr: HayateResponseProcessorr
    var requestPackages = NSMutableArray()
    let packageQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
    
    override init() {
        socketTransceiver = HayateSocketTransceiver()
        reponseProcessorr = HayateResponseProcessorr()
        super.init()
        
        socketTransceiver.connectSuccessBlock = { (host: NSString, port: ushort) in
            self.didConnectHost(host, port: port)
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
        
        reponseProcessorr.finder = { (responseHeader: DZH_DATAHEAD) in
            self.findRequestPackage(responseHeader)
        }
    }
    
    func didConnectHost(host: NSString, port: ushort) {
        print("连接行情服务器成功 \(host):\(port)")
        self.removeAllRequestPackage()
        NSNotificationCenter.defaultCenter().postNotificationName(HayateConnectSuccessNotification, object: nil)
    }
    
    func didDisConnect() {
        print("行情服务器断开连接成功")
        self.removeAllRequestPackage()
    }
    
    func didWriteData(tag: CLong) {
        let requestPackage: DZHRequestPackage? = self.findRequestPackage(tag)
        if let package = requestPackage {
            package.status = RequestStatus.Sended
            if package.ignorResponse { //不需要响应数据
                self.requestPackages.removeObject(package)
            }
        }
    }
    
    func didReadData(data: NSData) {
        reponseProcessorr.receiveData(data)
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
    
    func addRequestPackage(package: DZHRequestPackage) {
        dispatch_async(packageQueue) {
            self.requestPackages.addObject(package)
            if self.isConnected() {
                self.socketTransceiver.sendData(package.serialize(), tag: package.sendTag)
            }
            if !package.ignorResponse {
                self.performSelector(#selector(HayateSocketManager.requestTimeout(_:)), withObject: package, afterDelay: self.timeout)
            }
        }
    }
    
    func requestTimeout(package: DZHRequestPackage) {
        if package.responseCompletion != nil {
            package.responseCompletion!(status: ResponseStatus.Timeout)
        }
        self.requestPackages.removeObject(package)
    }
    
    func findRequestPackage(tag: CLong) -> DZHRequestPackage? {
        var requestPackage: DZHRequestPackage?
        dispatch_sync(packageQueue) {
            var index = 0
            for item in self.requestPackages {
                let package = item as! DZHRequestPackage
                if package.sendTag == tag{
                    requestPackage = package
                    break
                }
                index += 1
            }
            
            if requestPackage != nil {
                self.requestPackages.removeObjectAtIndex(index)
            }
        }
        return requestPackage
    }
    
    func findRequestPackage(responseHeader: DZH_DATAHEAD) -> DZHRequestPackage? {
        var requestPackage: DZHRequestPackage?
        dispatch_sync(packageQueue) {
            var index = 0
            for item in self.requestPackages {
                let package = item as! DZHRequestPackage
                if package.isMatchPackage(responseHeader){
                    requestPackage = package
                    break
                }
                index += 1
            }
            
            if requestPackage != nil {
                self.requestPackages.removeObjectAtIndex(index)
            }
        }
        return requestPackage
    }
    
    func removeAllRequestPackage() {
        dispatch_async(packageQueue) {
            self.requestPackages.removeAllObjects()
        }
    }
}
