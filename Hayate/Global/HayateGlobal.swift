//
//  HayateGlobal.swift
//  Hayate
//
//  Created by 段 文武 on 16/5/17.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

class HayateGlobal: NSObject {
    
    static var SchedulingServerAddress : [(String,ushort)] = [("222.73.34.8",12346),("222.73.103.42",12346),("61.151.252.4",12346),("61.151.252.14",12346)];
    
    static var ChannelNo = "213"
    static var TerminalId = "iphone"
    static var PlatformId = "14"
    static var keyChainAccessGroup = "59B8QAXTFE.com.gw.dzhiphone622";
    static var kDeviceIDKey = "DeviceID"
    
    class func deviceId() -> NSString{
        
        let svc = String(stringInterpolation: "\(keyChainAccessGroup).\(kDeviceIDKey)");
        let act = "com.gw"
        var deviceId : NSString = SSKeychain.passwordForService(svc, account: act)
        if deviceId.length == 0 {
            deviceId = String(self.userConfig()[kDeviceIDKey])
            if deviceId.length > 0 {
                SSKeychain.setPassword(deviceId as String, forService: svc, account: act)
            }
        }
        
        if deviceId.length == 0 {
            deviceId = self.generateChannelNumber();
            var error: NSError?
            SSKeychain.setPassword(deviceId as String, forService: svc, account: act, error: err)
            if let error = error {
                self.saveUserConfig(kDeviceIDKey, value: deviceId as String)
                print("设置ChannelNo错误Code:\(error.code):\(error.localizedDescription)")
            }
        }
    }
    
    class func uuidString() -> NSString {
        let uuidString = NSUUID().UUIDString;
        var str : NSString = uuidString.stringByReplacingOccurrencesOfString("-", withString: "")
        let count = str.length
        str = count >= 12 ? str.substringFromIndex(count - 12) : str
        return str;
    }
    
    class func generateChannelNumber() -> NSString {
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
    
    class func userConfig() -> NSDictionary{
        
        struct Static {
            static var onceToken:dispatch_once_t = 0
            static var config:Dictionary<String,AnyObject>? = nil
        }
        
        dispatch_once(&Static.onceToken, { () -> Void in
            
            if let dic = self .userPreferenceConfigDic() {
                
                Static.config = dic as? Dictionary<String, AnyObject>
            } else {
                
                Static.config = Dictionary()
            }
        })
        
        return Static.config!
    }
    
    class func saveUserConfig(key:String, value:String){
        self.userConfig().setValue(value, forKey: key)
        self.userConfig().writeToFile(self.documentFilePath("user.plist"), atomically: true)
    }
    
    class func userPreferenceConfigDic() -> NSDictionary? {
    
        let dataPath = self.documentFilePath("user.plist")
        return NSDictionary(contentsOfFile:dataPath)
    }
    
    class func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentationDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory = paths.first
        return documentsDirectory!
    }
    
    class func documentFilePath(fileName : String) -> String{
        return "\(self.documentsDirectory())/\(fileName)"
    }
}