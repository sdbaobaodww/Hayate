//
//  SchedulingServerManager.swift
//  Hayate
//
//  Created by 段 文武 on 16/5/11.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import UIKit

class SchedulingServerManager : NSObject{
    
    class var sharedInstance :SchedulingServerManager {
        struct Static {
            static var onceToken:dispatch_once_t = 0
            static var instance:SchedulingServerManager? = nil
        }
        dispatch_once(&Static.onceToken, { () -> Void in
            Static.instance = SchedulingServerManager()
        })
        return Static.instance!
    }
    
    func requestMarketAddress() {
        let addresses : Array = HayateGlobal.SchedulingServerAddress;
        let count : Int = addresses.count
        srandom(UInt32(time(nil)))            // 种子,random对应的是srandom
        let index : Int = random() % count
        let address : (String,ushort) = addresses[index]
        let url = String(stringInterpolation: "http://\(address.0):\(address.1)")
        let package1000 = DZHRequestPakage1000()
        
        HayateHttpManager.sharedInstance.POST(url, body: package1000.serialize(), succeed: { (task, data) in
            
            print("receive succeed")
            
        }, failed: { (task, error) in
            
            print("receive failed")
        })
        
        HayateHttpManager.sharedInstance.GET("http://www.baidu.com", body: nil, succeed: { (task, data) in
            
                print("receive succeed")
            
            }, failed: { (task, error) in
                
                print("receive failed")
        })
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = package1000.serialize()
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            print("receive")
        }.resume()
    }
}
