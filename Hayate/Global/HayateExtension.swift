//
//  HayateExtension.swift
//  Hayate
//
//  Created by Duanwwu on 16/5/18.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

extension NSData {
    
    //从字节数组中读取指定size的数据，有可能会产生类型改变，如可以读取2个字节的数据到一个Int类型
    func readValue(value: UnsafeMutablePointer<Void>, size: Int, pos : UnsafeMutablePointer<Int>) {
        if pos.memory + size <= self.length {
            self.getBytes(value, range: NSMakeRange(pos.memory, size))
            pos.memory += size
        }
    }
    
    //从字节数组中读取指定类型的数据，只有在基础类型或者结构体时使用
    func readValue<T>(value: UnsafeMutablePointer<T>, pos : UnsafeMutablePointer<Int>) {
        self.readValue(value, size: strideof(T), pos: pos)
    }
    
    //从字节数组中读取一串字符串
    func readString(value: UnsafeMutablePointer<NSString?>, pos: UnsafeMutablePointer<Int>){
        var str: NSString? = nil
        var len: Int = 0
        self.readValue(&len, size: strideof(ushort), pos: pos)
        if len > 0 {
            let data = self.subdataWithRange(NSMakeRange(pos.memory, len))
            pos.memory += len
            str = NSString(data:data, encoding:NSUTF8StringEncoding)
            if str == nil {
                str = NSString(data:data, encoding:NSString.defaultCStringEncoding())
            }
        }
        value.memory = str
    }
    
    //从字节数组中读取一个字符串数组
    func readStringArray(value: UnsafeMutablePointer<Array<NSString>?>, pos: UnsafeMutablePointer<Int>){
        var count: Int = 0
        self.readValue(&count, size: strideof(ushort), pos: pos)
        if count > 0 {
            var arr: Array<NSString> = Array()
            var str: NSString?
            for _ in 0 ..< count {
                self.readString(&str, pos: pos)
                if str != nil {
                    arr.append(str!)
                }
            }
            value.memory = arr
        }else{
            value.memory = nil
        }
    }
}

extension NSMutableData {
    
    //往字节数组中写入字符串
    func writeString(string: NSString) {
        var len: ushort = ushort(string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        self.appendBytes(&len, length: strideof(ushort))//写入字符串长度
        self.appendData(string.dataUsingEncoding(NSUTF8StringEncoding)!)//写入字符串内容
    }
    
    //往字节数组中写入指定类型的数据
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
        case let arr as NSArray:
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
