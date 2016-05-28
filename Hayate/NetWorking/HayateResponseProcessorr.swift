//
//  HayateDataParseCenter.swift
//  Hayate
//
//  Created by Duanwwu on 16/5/19.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

typealias RequestPackageFinder = (responseHeader: DZH_DATAHEAD) -> DZHRequestPackage?

class HayateResponseProcessorr: NSObject {
    let NormalHeaderLength = DZH_DATAHEAD.fixedSize()
    var receiveBytes: Int = 0
    var receiveData = NSMutableData()
    var finder: RequestPackageFinder?
    
    func receiveData(data: NSData) {
        self.receiveBytes += data.length
        self.receiveData.appendData(data)
        if self.finder != nil {
            self.dispatchResponsePackage(self.receiveData, finder: self.finder!)
        }
    }
    
    func dispatchResponsePackage(data: NSMutableData, finder: RequestPackageFinder) {
        var pos = 0 //处理的长度
        while data.length >= pos + NormalHeaderLength {
            var header: DZH_DATAHEAD = DZH_DATAHEAD()//数据包头
            header.deSerialize(data, pos: &pos)//反序列化包头数据
            let length = header.length
            let requestPackage = finder(responseHeader: header)
            if requestPackage == nil {
                print("找不到请求包")
            }else{
                requestPackage!.receiveData(header, data: length > 0 ? data.subdataWithRange(NSMakeRange(pos, length)) : nil)
            }
            pos += length
        }
        self.receiveData.replaceBytesInRange(NSMakeRange(0, pos), withBytes: nil, length: 0)
    }
}
