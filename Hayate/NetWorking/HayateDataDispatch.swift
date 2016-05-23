//
//  HayateDataParseCenter.swift
//  Hayate
//
//  Created by Duanwwu on 16/5/19.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

public class HayateDataDispatch: NSObject {
    let NormalHeaderLength = DZH_NORMALHEAD.size()
    var receiveBytes: Int = 0
    var receiveData = NSMutableData()
    var requestPackages = NSMutableArray()
    let packageQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
    
    func addRequestPackage(package: DZHRequestPackage) {
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
        while data.length > pos + NormalHeaderLength {
            var normalHeader: DZH_NORMALHEAD?;
            data.readValue(&normalHeader, pos: &pos)//获取包头数据
            let attr = (normalHeader!.attrs & 0x8) >> 3 //取长度扩充位，当置位时，用int表示数据长度；否则用short表示长度；
            let byteSize = attr == 1 ? sizeof(Int32) : sizeof(CShort)
            var length = 0
            data.readValue(&length, size: byteSize, pos: &pos)//读取包数据长度
            let header: DZH_DATAHEAD_EX = DZH_DATAHEAD_EX(header: normalHeader!, len: length)//包头
            let requestPackage = self.findRequestPackage(PackageQueryCondition(header.tag, header.type))
            if requestPackage == nil {
                print("找不到请求包")
            }else{
                let parser = requestPackage!.responseParser
                parser.header = header
                parser.deSerialize(length > 0 ? data.subdataWithRange(NSMakeRange(pos, length)) : nil)
            }
            pos += length
        }
        self.receiveData.replaceBytesInRange(NSMakeRange(0, pos), withBytes: nil, length: 0)
    }
    
    func findRequestPackage(condition: PackageQueryCondition) -> DZHRequestPackage? {
        var requestPackage: DZHRequestPackage?
        dispatch_sync(packageQueue) {
            var index = 0
            for item in self.requestPackages {
                let package = item as! DZHRequestPackage
                if package.isMatchPackage(condition){
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
