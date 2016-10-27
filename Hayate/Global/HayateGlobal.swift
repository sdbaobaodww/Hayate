//
//  HayateGlobal.swift
//  Hayate
//
//  Created by 段 文武 on 16/5/17.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

open class HayateGlobal: NSObject {
    
    static let SchedulingServerAddress: [(String,ushort)] = [("222.73.34.8",12346),("222.73.103.42",12346),("61.151.252.4",12346),("61.151.252.14",12346)];
    open static let VersionNumber: NSString = "8.34"
    open static let ChannelNo: NSString = "213"
    open static let TerminalId: NSString = "iphone"
    open static let PlatformId: NSString = "14"
    open static let SocketTimeout: TimeInterval = 7
    
    static let KeyChainAccessGroup: NSString = "59B8QAXTFE.com.gw.dzhiphone622";
    static let DeviceIDKey: NSString = "DeviceID"
    
    open class func deviceId() -> NSString{
        let svc = String(stringInterpolation: "\(KeyChainAccessGroup).\(DeviceIDKey)");
        let act = "com.gw"
        var deviceId : NSString? = SSKeychain.password(forService: svc, account: act) as NSString?//首先从keychain中获取
        if deviceId == nil {
            if let obj = self.userConfig().object(forKey: DeviceIDKey) {
                deviceId = obj as? NSString
                self.saveDeviceId(deviceId as String!, service: svc, account: act, onlyKeychain: true)
            }else{
                deviceId = self.generateChannelNumber();
                self.saveDeviceId(deviceId as String!, service: svc, account: act, onlyKeychain: false)
            }
        }
        return deviceId!
    }
    
    fileprivate class func saveDeviceId(_ deviceId: String, service: String, account: String, onlyKeychain: Bool) {
        do{
            try SSKeychain.setPassword(deviceId as String!, forService: service, account: account, error: ())
        }catch let error as NSError?{
            if !onlyKeychain {
                self.saveUserConfig(DeviceIDKey, value: deviceId as AnyObject?)
            }
            print("设置ChannelNo错误Code:\(error!.code):\(error!.localizedDescription)")
        }
    }
    
    open class func uuidString() -> String {
        let uuidString = UUID().uuidString;
        var str = uuidString.replacingOccurrences(of: "-", with: "")
        let count = str.characters.count
        str = count >= 12 ? str.substring(from: str.index(str.endIndex, offsetBy: -12)) : str
        return str;
    }
    
    private class func generateChannelNumber() -> NSString {
        let prefix = ChannelNo
        let suffix = self.uuidString()
        var retVal : NSString = String(stringInterpolation:"\(prefix)\(suffix)") as NSString;
        let nLen	= 19 - retVal.length;
        var nRand : UInt32	= 0;
        // 随机生成填补位数
        for _ in 0 ..< nLen {
            nRand = arc4random() % 10
            retVal = retVal.appending(String(stringInterpolation: "\(nRand)")) as NSString
        }
        print("生成ChannelNo：\(retVal)");
        return retVal;
    }
    
    open class func userConfig() -> NSDictionary {
        if let dic = self.userPreferenceConfigDic() {
            return NSMutableDictionary(dictionary: dic)
        } else {
            return NSMutableDictionary()
        }
    }
    
    private class func userPreferenceConfigDic() -> NSDictionary? {
        let dataPath = self.documentFilePath("user.plist")
        return NSDictionary(contentsOfFile:dataPath)
    }
    
    open class func saveUserConfig(_ key: NSString, value: AnyObject?){
        let dic = self.userConfig()
        dic.setValue(value, forKey: key as String)
        dic.write(toFile: self.documentFilePath("user.plist"), atomically: true)
    }
    
    open class func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = paths.first
        return documentsDirectory!
    }
    
    open class func documentFilePath(_ fileName: String) -> String{
        return "\(self.documentsDirectory())/\(fileName)"
    }
}
