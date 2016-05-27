//
//  HayateDataParseCenter.swift
//  Hayate
//
//  Created by Duanwwu on 16/5/19.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

public class HayateDataDispatch: NSObject {
    let NormalHeaderLength = DZH_DATAHEAD.fixedSize()
    var receiveBytes: Int = 0
    var receiveData = NSMutableData()
    var requestPackages = NSMutableArray()
    let packageQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
    
    public func addRequestPackage(package: DZHRequestPackage) {
        dispatch_sync(packageQueue) { 
            self.requestPackages.addObject(package)
        }
    }
    
    func receiveData(data: NSMutableData) {
        self.receiveBytes += data.length
        self.receiveData.appendData(data)
        self.dispatchResponsePackage(self.receiveData)
    }
    
    func dispatchResponsePackage(data: NSMutableData) {
        var pos = 0 //处理的长度
        while data.length >= pos + NormalHeaderLength {
            var header: DZH_DATAHEAD = DZH_DATAHEAD()//数据包头
            header.deSerialize(data, pos: &pos)//反序列化包头数据
            let length = header.length
            let requestPackage = self.findRequestPackage(header)
            if requestPackage == nil {
                print("找不到请求包")
            }else{
                let parser = requestPackage!.responseParser(header)
                parser.header = header
                parser.deSerialize(length > 0 ? data.subdataWithRange(NSMakeRange(pos, length)) : nil)
            }
            pos += length
        }
        self.receiveData.replaceBytesInRange(NSMakeRange(0, pos), withBytes: nil, length: 0)
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
}
