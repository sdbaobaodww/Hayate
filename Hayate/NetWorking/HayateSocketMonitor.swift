//
//  HayateSocketMonitor.swift
//  Hayate
//
//  Created by Duanwwu on 16/5/31.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

//socket检测管理类
open class HayateSocketMonitor: NSObject {
    
    var globalWaitSendCount: Int = 0
    var globalWaitResponseCount: Int = 0
    var socketManagers: Array<HayateSocketManagerBase> = []
    
    func addMonitorObject(_ manager: HayateSocketManagerBase) {
        socketManagers.append(manager)
    }
    
    func notify(_ manager: HayateSocketManagerBase) {
        var waitSend: Int = 0
        var waitResponse: Int = 0
        for item in socketManagers {
            waitSend += item.waitSendCount()
            waitResponse += item.waitResponseCount()
        }
        globalWaitSendCount = waitSend
        globalWaitResponseCount = waitResponse
        print("待发送队列数:\(globalWaitSendCount) 待接收队列数:\(globalWaitResponseCount)")
        DispatchQueue.main.async { 
            if waitSend + waitResponse > 0 {
                if UIApplication.shared.isNetworkActivityIndicatorVisible == false {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                }
            }else{
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}

class HayateSocketHeartBeat: NSObject {
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(self.didConnectToServer), name: NSNotification.Name(rawValue: HayateConnectSuccessNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didDisConnectToServer), name: NSNotification.Name(rawValue: HayateDisConnectNotification), object: nil)
    }
    
    func didConnectToServer() {
        self.performSelector(onMainThread: #selector(self.startHeartBeat), with: nil, waitUntilDone: true)
    }
    
    func didDisConnectToServer() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.startHeartBeat), object: nil)
    }
    
    func startHeartBeat() {
        let heartBeat = DZHRequestPackage2963()
        heartBeat.ignorResponse = true
        heartBeat.sendRequest { (status) in
            
        }
        self.perform(#selector(self.startHeartBeat), with: nil, afterDelay: 20)
    }
}
