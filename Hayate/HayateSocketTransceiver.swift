//
//  HayateSocketManager.swift
//  Hayate
//
//  Created by Duanwwu on 16/5/27.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

typealias ConnectSuccessBlock = (host: NSString, port: ushort)->Void
typealias DisconnectBlock = (Void)->Void
typealias WriteSuccessBlock = (tag: CLong)->Void
typealias ReadSuccessBlock = (data: NSData)->Void

class HayateSocketTransceiver: NSObject {
    var socket: GCDAsyncSocket = GCDAsyncSocket()
    let delegateQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
    var connectSuccessBlock: ConnectSuccessBlock?
    var disConnectBlock: DisconnectBlock?
    var writeSuccessBlock: WriteSuccessBlock?
    var readSuccessBlock: ReadSuccessBlock?
    
    override init() {
        super.init()
        socket.delegate = self
        socket.delegateQueue = delegateQueue
    }
    
    func connectToHost(host: String, port: ushort, timeout: NSTimeInterval) {
        do {
            try socket.connectToHost(host, onPort: port, withTimeout: timeout)
        }catch let error as NSError  {
            print("socket connect error code:\(error.code) domain:\(error.domain)")
        }
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func isConnected() -> Bool {
        return socket.isConnected
    }
    
    func sendData(data: NSData, tag: CLong) {
        print("socket send data \(tag)")
        socket.writeData(data, withTimeout: -1, tag: tag)
    }
    
    func socket(sock: GCDAsyncSocket, didConnectToHost host: NSString, port:u_short) {
        sock.performBlock { 
            sock.enableBackgroundingOnSocket()
        }
        if self.connectSuccessBlock != nil {
            self.connectSuccessBlock!(host: sock.connectedHost, port: sock.connectedPort)
        }
    }
    
    func socket(sock: GCDAsyncSocket, didWriteDataWithTag tag: CLong) {
        print("socket send data \(tag) success")
        if self.writeSuccessBlock != nil {
            self.writeSuccessBlock!(tag: tag)
        }
    }
    
    func socket(sock: GCDAsyncSocket, shouldTimeoutWriteWithTag tag: CLong, elapsed: NSTimeInterval, bytesDone length: UInt) -> NSTimeInterval {
        return 0
    }
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: CLong) {
        print("socket receive data \(tag) success")
        if self.readSuccessBlock != nil {
            self.readSuccessBlock!(data: data)
        }
    }
    
    func socket(sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: CLong, elapsed: NSTimeInterval, bytesDone length: UInt) -> NSTimeInterval {
        return 0
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError) {
        if self.disConnectBlock != nil {
            self.disConnectBlock!()
        }
    }
}
