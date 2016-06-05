//
//  SchedulingServerManager.swift
//  Hayate
//
//  Created by 段 文武 on 16/5/11.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

public let HayateServerManagerNotification: String = "HayateServerManagerNotification" //获取行情服务器成功通知

public class SchedulingServerManager : NSObject{
    
    public var package1000: DZHRequestPackage1000?
    var isRequesting: Bool = false
    let socketManager: HayateMarketSocketManager
    let httpManager: HayateHttpManager = HayateHttpManager()
    
    init(socketManager: HayateMarketSocketManager) {
        self.socketManager = socketManager
        super.init()
    }
    
    private func cachedAddressesFromDisk() -> Array<NSString>? {
        return HayateGlobal.userConfig().objectForKey("ServerAddresses") as? Array<NSString>
    }
    
    public func createSocket() {
        if let addresses = self.cachedAddressesFromDisk() where addresses.count > 0 {
            self.createSocket(addresses)//使用保存的行情服务器地址
        }
        self.requestMarketAddress()//请求下一次的行情地址
    }
    
    private func createSocket(addresses: Array<NSString>) {
        if let addressAndPort = addresses.randomObject() {
            self.createSocket(addressAndPort)
        }
    }
    
    private func createSocket(addressAndPort: NSString) {
        var arr: Array = addressAndPort.componentsSeparatedByString(":")
        if arr.count == 2 {
            self.socketManager.connectHost(arr[0], port: ushort(arr[1])!)
        }
    }
    
    private func receiveMarketAddress(package1000: DZHRequestPackage1000) {
        print("保存行情服务器地址")
        HayateGlobal.saveUserConfig("ServerAddresses", value: (package1000.responseParser as! DZHResponsePackage1000).hqServerAddresses!)//保存行情服务器地址
        if !self.socketManager.isConnected() {
            print("行情服务器还未连接，使用最新行情地址")
            self.createSocket((package1000.responseParser as! DZHResponsePackage1000).hqServerAddresses!)
        }
        NSNotificationCenter.defaultCenter().postNotificationName(HayateServerManagerNotification, object: package1000)//发出获取到行情服务器的通知
    }
    
    public func requestMarketAddress() {
        if isRequesting {
            return
        }
        isRequesting = true
        let address: (String,ushort) = HayateGlobal.SchedulingServerAddress.randomObject()!
        let url = String(stringInterpolation: "http://\(address.0):\(address.1)")
        let package1000 = DZHRequestPackage1000()
        
        httpManager.POSTStream(url, body: package1000.serialize(), succeed: { (responseData) in
                let data = responseData as! NSData
                if data.length >= DZH_DATAHEAD.minSize() {
                    var pos = 0 //处理的长度
                    var header: DZH_DATAHEAD = DZH_DATAHEAD()
                    let length = header.deSerialize(data, pos: &pos)//反序列化包头数据
                    package1000.receiveData(header, data: length > 0 ? data.subdataWithRange(NSMakeRange(pos, length)) : nil)
                    self.package1000 = package1000
                    self.receiveMarketAddress(package1000)
                }
                else {
                    self.performSelector(#selector(self.requestMarketAddress), withObject: nil, afterDelay: 1)
                }
                self.isRequesting = false
            }, failed:{ (error) in
                
                self.performSelector(#selector(self.requestMarketAddress), withObject: nil, afterDelay: 1)
                self.isRequesting = false
        })
    }
}
