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
    public func readValue(value: UnsafeMutablePointer<Void>, size: Int, pos : UnsafeMutablePointer<Int>) {
        if pos.memory + size <= self.length {
            self.getBytes(value, range: NSMakeRange(pos.memory, size))
            pos.memory += size
        }
    }
    
    //从字节数组中读取一串字符串
    public func readString(value: UnsafeMutablePointer<NSString?>, pos: UnsafeMutablePointer<Int>){
        var str: NSString? = nil
        var len: Int = 0
        self.readValue(&len, size: sizeof(ushort), pos: pos)
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
    public func readStringArray(value: UnsafeMutablePointer<Array<NSString>?>, pos: UnsafeMutablePointer<Int>){
        var count: Int = 0
        self.readValue(&count, size: sizeof(ushort), pos: pos)
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
    public func writeString(string: NSString) {
        var len: ushort = ushort(string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        self.appendBytes(&len, length: sizeof(ushort))//写入字符串长度
        self.appendData(string.dataUsingEncoding(NSUTF8StringEncoding)!)//写入字符串内容
    }
    
    public func writeBaseValue<T>(value: T) {
        var data = value
        self.appendBytes(&data, length: sizeof(T))
    }
    
    //往字节数组中写入指定类型的数据
    public func writeValue<T>(value: T) {
        switch value {
            //Int各类型
        case _ as Int:
            self.writeBaseValue(value)
        case _ as Int8:
            self.writeBaseValue(value)
        case _ as Int16:
            self.writeBaseValue(value)
        case _ as Int32:
            self.writeBaseValue(value)
        case _ as Int64:
            self.writeBaseValue(value)
            
            //UInt各类型
        case _ as UInt:
            self.writeBaseValue(value)
        case _ as UInt8:
            self.writeBaseValue(value)
        case _ as UInt16:
            self.writeBaseValue(value)
        case _ as UInt32:
            self.writeBaseValue(value)
        case _ as UInt64:
            self.writeBaseValue(value)
            
            //Bool
        case _ as Bool:
            self.writeBaseValue(value)
           
            //浮点型
        case _ as Float:
            self.writeBaseValue(value)
        case _ as Double:
            self.writeBaseValue(value)
            
            //字符串
        case let str as String:
            self.writeString(str)
        case let str as NSString:
            self.writeString(str)
            
            //数组
        case let arr as NSArray:
            var count = ushort(arr.count)
            self.appendBytes(&count, length: sizeof(ushort))//写入数组长度
            for item in arr {
                self.writeValue(item)//写入数组内容
            }
        default:
            break
            
        }
    }
    
    //往字节数组中写入基本数据类型的数组
    public func writeArray<T>(arr: Array<T>) {
        var count = ushort(arr.count)
        self.appendBytes(&count, length: sizeof(ushort))//写入数组长度
        for item in arr {
            self.writeValue(item)//写入数组内容
        }
    }
}

extension Array {
    public func randomObject() -> Element? {
        if self.count == 0 {
            return nil
        }else{
            srandom(UInt32(time(nil)))            // 种子,random对应的是srandom
            return self[random() % self.count]
        }
    }
}

extension NSArray {
    public func randomObject() -> AnyObject? {
        if self.count == 0 {
            return nil
        }else{
            srandom(UInt32(time(nil)))            // 种子,random对应的是srandom
            return self[random() % self.count]
        }
    }
}

extension CInt {
    public func expand() -> Int64 {
        let v1: Int64 = Int64((self >> 30) & 0x03)
        if v1 == 0 {
            return Int64(self)
        }else{
            return Int64(self & 0x3FFFFFFF) << (v1 * 4)
        }
    }
}

extension Int64 {
    public func expand() -> Int64 {
        let v1: Int64 = Int64((self >> 30) & 0x03)
        if v1 == 0 {
            return self
        }else{
            return (self & 0x3FFFFFFF) << (v1 * 4)
        }
    }
}

extension NSMutableArray {
    public func insertObjects(array: [AnyObject], atIndex index: Int) {
        self.insertObjects(array, atIndexes: NSIndexSet(indexesInRange: NSMakeRange(index, array.count)))
    }
}

