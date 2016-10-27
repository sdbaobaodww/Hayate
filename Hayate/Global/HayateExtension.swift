//
//  HayateExtension.swift
//  Hayate
//
//  Created by Duanwwu on 16/5/18.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

extension Data {
    
    //从字节数组中读取指定size的数据，有可能会产生类型改变，如可以读取2个字节的数据到一个Int类型
    public func readValue(_ value: UnsafeMutableRawPointer, size: Int, pos : UnsafeMutablePointer<Int>) {
        if pos.pointee + size <= self.count {
            (self as NSData).getBytes(value, range: NSMakeRange(pos.pointee, size))
            pos.pointee += size
        }
    }
    
    //从字节数组中读取一串字符串
    public func readString(_ value: UnsafeMutablePointer<NSString?>, pos: UnsafeMutablePointer<Int>){
        var str: NSString? = nil
        var len: Int = 0
        self.readValue(&len, size: MemoryLayout<ushort>.size, pos: pos)
        if len > 0 {
            let data = self.subdata(in: Range((pos.pointee) ..< (pos.pointee + len)))
            pos.pointee += len
            str = NSString(data:data, encoding:String.Encoding.utf8.rawValue)
            if str == nil {
                str = NSString(data:data, encoding:NSString.defaultCStringEncoding)
            }
        }
        value.pointee = str
    }
    
    //从字节数组中读取一个字符串数组
    public func readStringArray(_ value: UnsafeMutablePointer<Array<NSString>?>, pos: UnsafeMutablePointer<Int>){
        var count: Int = 0
        self.readValue(&count, size: MemoryLayout<ushort>.size, pos: pos)
        if count > 0 {
            var arr: Array<NSString> = Array()
            var str: NSString?
            for _ in 0 ..< count {
                self.readString(&str, pos: pos)
                if str != nil {
                    arr.append(str!)
                }
            }
            value.pointee = arr
        }else{
            value.pointee = nil
        }
    }
}

extension NSMutableData {
    
    //往字节数组中写入字符串
    public func writeString(_ string: NSString) {
        var len: ushort = ushort(string.lengthOfBytes(using: String.Encoding.utf8.rawValue))
        self.append(&len, length: MemoryLayout<ushort>.size)//写入字符串长度
        self.append(string.data(using: String.Encoding.utf8.rawValue)!)//写入字符串内容
    }
    
    public func writeBaseValue<T>(_ value: T) {
        var data = value
        self.append(&data, length: MemoryLayout<T>.size)
    }
    
    //往字节数组中写入指定类型的数据
    public func writeValue<T>(_ value: T) {
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
            self.writeString(str as NSString)
        case let str as NSString:
            self.writeString(str)
            
            //数组
        case let arr as NSArray:
            var count = ushort(arr.count)
            self.append(&count, length: MemoryLayout<ushort>.size)//写入数组长度
            for item in arr {
                self.writeValue(item)//写入数组内容
            }
        default:
            break
            
        }
    }
    
    //往字节数组中写入基本数据类型的数组
    public func writeArray<T>(_ arr: Array<T>) {
        var count = ushort(arr.count)
        self.append(&count, length: MemoryLayout<ushort>.size)//写入数组长度
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
            return self[Int(arc4random()) % self.count]
        }
    }
}

extension NSArray {
    public func randomObject() -> AnyObject? {
        if self.count == 0 {
            return nil
        }else{
            srandom(UInt32(time(nil)))            // 种子,random对应的是srandom
            return self[Int(arc4random()) % self.count] as AnyObject?
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

public enum HayateDataVary: Int {
    case unknown //不支持的类型
    case Init //第一次拿到数据
    case frontInsert //头插入数据
    case endAppend //尾添加数据
    case update //尾部数据更新或者部分更新部分添加
}

//页面数据变更信息
public typealias HayatePageUpdate = (type: HayateDataVary, range: NSRange)

extension NSMutableArray {
    
    public func insertObjects(_ array: [AnyObject], atIndex index: Int) {
        self.insert(array, at: IndexSet(integersIn: NSMakeRange(index, array.count).toRange() ?? 0..<0))
    }
    
    public func addPageData(_ pageData: NSArray) -> HayatePageUpdate {
        if pageData.count > 0 {
            let pageFromPos = (pageData.firstObject as! HayateDataCollectionItem).collectionPosition()
            let pageToPos = (pageData.lastObject as! HayateDataCollectionItem).collectionPosition()
            
            if self.count == 0 {
                self.addObjects(from: pageData as [AnyObject])
                return (.Init, NSMakeRange(0, pageData.count))
            }else{
                let fromPos = (self.firstObject as! HayateDataCollectionItem).collectionPosition()
                let toPos = (self.lastObject as! HayateDataCollectionItem).collectionPosition()
                
                if pageFromPos > toPos {//后面添加
                    self.addObjects(from: pageData as [AnyObject])
                    return (.endAppend, NSMakeRange(0, pageData.count))
                }else if pageToPos < fromPos {//前面添加
                    self.insertObjects(pageData as [AnyObject], atIndex: 0)
                    return (.frontInsert, NSMakeRange(0, pageData.count))
                }else if pageToPos > toPos && pageFromPos <= toPos {//两者相交，部分更新，部分新增
                    var index: Int = -1
                    for (i, item) in pageData.enumerated() {
                        let item = item as! HayateDataCollectionItem
                        //找出等于toPos的数据，[pageFromPos,toPos]为修改，(toPos,pageToPos]为新增
                        if item.collectionPosition() == toPos {
                            index = i
                        }
                    }
                    if index != -1 { //等于－1则数据有误，不处理
                        let replaceCount = index + 1
                        let update = pageData.subarray(with: NSMakeRange(0, replaceCount))//需更新的数据
                        self.replaceObjects(at: IndexSet(integersIn: NSMakeRange(self.count - replaceCount, replaceCount).toRange() ?? 0..<0), with: update)
                        let add: [AnyObject] = pageData.subarray(with: NSMakeRange(replaceCount, pageData.count - replaceCount)) as [AnyObject]//需要新增的数据
                        self.addObjects(from: add)
                        return (.update, NSMakeRange(self.count - replaceCount, pageData.count))
                    }
                }
                else if pageToPos == toPos {//datas包含pageData，更新datas最后几个元素
                    let range = NSMakeRange(self.count - pageData.count, pageData.count)
                    self.replaceObjects(at: IndexSet(integersIn: range.toRange() ?? 0..<0), with: pageData as [AnyObject])
                    return (.update, range)
                }else {//datas包含pageData，更新datas某个区间的值，忽略掉，暂不处理
                    print("暂不处理更新某个区间的值")
                }
            }
        }
        return (.unknown, NSRange())
    }
}

