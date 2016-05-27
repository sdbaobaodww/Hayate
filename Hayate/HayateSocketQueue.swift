//
//  HayateSocketManager.swift
//  Hayate
//
//  Created by Duanwwu on 16/5/27.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

public class HayateSocketQueue {
    
    let queue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
    var socket: GCDAsyncSocket?
    var requestPackages = NSMutableArray()
    
    init() {
        self.socket = GCDAsyncSocket(delegate:self, delegateQueue:queue)
    }
    
    public func addRequestPackage(package: DZHRequestPackage) {
        dispatch_sync(queue) {
            self.requestPackages.addObject(package)
        }
    }
    
    func findRequestPackage(responseHeader: DZH_DATAHEAD) -> DZHRequestPackage? {
        var requestPackage: DZHRequestPackage?
        dispatch_sync(queue) {
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
    
    
    func socket(sock: GCDAsyncSocket, didConnectToHost host: NSString, port:u_short) {
        
    }
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: CLong) {
        
    }
    
    func socket(sock: GCDAsyncSocket, didWriteDataWithTag tag: CLong) {
        
    }
    
    func socket(sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: CLong, elapsed: NSTimeInterval, bytesDone length: UInt) -> NSTimeInterval {
        
        return 0
    }
    
    func socket(sock: GCDAsyncSocket, shouldTimeoutWriteWithTag tag: CLong, elapsed: NSTimeInterval, bytesDone length: UInt) -> NSTimeInterval {
        
        return 0
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError) {
        
    }

}