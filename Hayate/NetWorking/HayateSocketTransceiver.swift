//
//  HayateSocketManager.swift
//  Hayate
//
//  Created by Duanwwu on 16/5/27.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

typealias ConnectSuccessBlock = (_ host: NSString, _ port: ushort)->Void
typealias DisconnectBlock = (Void)->Void
typealias WriteSuccessBlock = (_ tag: CLong)->Void
typealias ReadSuccessBlock = (_ data: Data)->Void

class HayateSocketTransceiver: NSObject {
    var socket: GCDAsyncSocket = GCDAsyncSocket()
    var connectSuccessBlock: ConnectSuccessBlock?
    var connectFailureBlock: ConnectSuccessBlock?
    var disConnectBlock: DisconnectBlock?
    var writeSuccessBlock: WriteSuccessBlock?
    var readSuccessBlock: ReadSuccessBlock?
    
    init(delegateQueue: DispatchQueue) {
        super.init()
        socket.delegate = self
        socket.delegateQueue = delegateQueue
    }
    
    func connectToHost(_ host: String, port: ushort, timeout: TimeInterval) {
        do {
            try socket.connect(toHost: host, onPort: port, withTimeout: timeout)
        }catch let error as NSError  {
            print("socket connect error code:\(error.code) domain:\(error.domain)")
            if self.connectFailureBlock != nil {
                self.connectFailureBlock!(host as NSString, port)
            }
        }
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func isConnected() -> Bool {
        return socket.isConnected
    }
    
    func sendData(_ data: Data, tag: CLong) {
        socket.write(data, withTimeout: -1, tag: tag)
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: NSString, port:u_short) {
        if self.connectSuccessBlock != nil {
            self.connectSuccessBlock!(sock.connectedHost as NSString, sock.connectedPort)
        }
        sock.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: CLong) {
        if self.writeSuccessBlock != nil {
            self.writeSuccessBlock!(tag)
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, shouldTimeoutWriteWithTag tag: CLong, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        return 0
    }
    
    func socket(_ sock: GCDAsyncSocket, didReadData data: Data, withTag tag: CLong) {
        if self.readSuccessBlock != nil {
            self.readSuccessBlock!(data)
        }
        sock.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: CLong, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        return 0
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: NSError) {
        if self.disConnectBlock != nil {
            self.disConnectBlock!()
        }
    }
}
