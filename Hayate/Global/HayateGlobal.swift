//
//  HayateGlobal.swift
//  Hayate
//
//  Created by 段 文武 on 16/5/17.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

public class HayateGlobal: NSObject {
    
    static let SchedulingServerAddress: [(String,ushort)] = [("222.73.34.8",12346),("222.73.103.42",12346),("61.151.252.4",12346),("61.151.252.14",12346)];
    public static let VersionNumber: NSString = "8.34"
    public static let ChannelNo: NSString = "213"
    public static let TerminalId: NSString = "iphone"
    public static let PlatformId: NSString = "14"
    public static let SocketTimeout: NSTimeInterval = 7
    
    static let KeyChainAccessGroup: NSString = "59B8QAXTFE.com.gw.dzhiphone622";
    static let DeviceIDKey: NSString = "DeviceID"
    
    public class func deviceId() -> NSString{
        let svc = String(stringInterpolation: "\(KeyChainAccessGroup).\(DeviceIDKey)");
        let act = "com.gw"
        var deviceId : NSString? = SSKeychain.passwordForService(svc, account: act)//首先从keychain中获取
        if deviceId == nil {
            if let obj = self.userConfig().objectForKey(DeviceIDKey) {
                deviceId = obj as? NSString
                self.saveDeviceId(deviceId as String!, service: svc, account: act, onlyKeychain: true)
            }else{
                deviceId = self.generateChannelNumber();
                self.saveDeviceId(deviceId as String!, service: svc, account: act, onlyKeychain: false)
            }
        }
        return deviceId!
    }
    
    private class func saveDeviceId(deviceId: String, service: String, account: String, onlyKeychain: Bool) {
        do{
            try SSKeychain.setPassword(deviceId as String!, forService: service, account: account, error: ())
        }catch let error as NSError?{
            if !onlyKeychain {
                self.saveUserConfig(DeviceIDKey, value: deviceId)
            }
            print("设置ChannelNo错误Code:\(error!.code):\(error!.localizedDescription)")
        }
    }
    
    public class func uuidString() -> NSString {
        let uuidString = NSUUID().UUIDString;
        var str : NSString = uuidString.stringByReplacingOccurrencesOfString("-", withString: "")
        let count = str.length
        str = count >= 12 ? str.substringFromIndex(count - 12) : str
        return str;
    }
    
    private class func generateChannelNumber() -> NSString {
        let prefix = ChannelNo
        let suffix = self.uuidString()
        var retVal : NSString = String(stringInterpolation:"\(prefix)\(suffix)");
        let nLen	= 19 - retVal.length;
        var nRand : UInt32	= 0;
        // 随机生成填补位数
        for _ in 0 ..< nLen {
            nRand = arc4random() % 10
            retVal = retVal.stringByAppendingString(String(stringInterpolation: "\(nRand)"))
        }
        print("生成ChannelNo：\(retVal)");
        return retVal;
    }
    
    public class func userConfig() -> NSDictionary {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var config: NSMutableDictionary? = nil
        }
        dispatch_once(&Static.onceToken, { () -> Void in
            if let dic = self.userPreferenceConfigDic() {
                Static.config = NSMutableDictionary(dictionary: dic)
            } else {
                Static.config = NSMutableDictionary()
            }
        })
        return Static.config!
    }
    
    private class func userPreferenceConfigDic() -> NSDictionary? {
        let dataPath = self.documentFilePath("user.plist")
        return NSDictionary(contentsOfFile:dataPath)
    }
    
    public class func saveUserConfig(key: NSString, value: AnyObject?){
        let dic = self.userConfig()
        dic.setValue(value, forKey: key as String)
        dic.writeToFile(self.documentFilePath("user.plist"), atomically: true)
    }
    
    public class func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory = paths.first
        return documentsDirectory!
    }
    
    public class func documentFilePath(fileName: String) -> String{
        return "\(self.documentsDirectory())/\(fileName)"
    }
}
