//
//  HayateExtension.swift
//  Hayate
//
//  Created by Duanwwu on 16/5/18.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

extension NSMutableData{
    
    func writeString(string: NSString) {
        var len: ushort = ushort(string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        self.appendBytes(&len, length: strideof(ushort))//写入字符串长度
        self.appendData(string.dataUsingEncoding(NSUTF8StringEncoding)!)//写入字符串内容
    }
    
    func writeValue<T>(value: T) {
        switch value {
        case let str as String:
            self.writeString(str)
        case let str as NSString:
            self.writeString(str)
        case let arr as Array<AnyObject>:
            var count = ushort(arr.count)
            self.appendBytes(&count, length: strideof(ushort))//写入数组长度
            for item in arr {
                self.writeValue(item)//写入数组内容
            }
        default:
            var data = value
            self.appendBytes(&data, length: strideofValue(value))
        }
    }
}