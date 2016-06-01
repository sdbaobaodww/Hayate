//
//  HayateSocketMonitor.swift
//  Hayate
//
//  Created by Duanwwu on 16/5/31.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

//socket检测管理类
public class HayateSocketMonitor: NSObject {
    
    var globalWaitSendCount: Int = 0
    var globalWaitResponseCount: Int = 0
    var socketManagers: Array<HayateSocketManagerBase> = []
    
    func addMonitorObject(manager: HayateSocketManagerBase) {
        socketManagers.append(manager)
    }
    
    func notify(manager: HayateSocketManagerBase) {
        var waitSend: Int = 0
        var waitResponse: Int = 0
        for item in socketManagers {
            waitSend += item.waitSendCount()
            waitResponse += item.waitResponseCount()
        }
        globalWaitSendCount = waitSend
        globalWaitResponseCount = waitResponse
        print("待发送队列数:\(globalWaitSendCount) 待接收队列数:\(globalWaitResponseCount)")
        dispatch_async(dispatch_get_main_queue()) { 
            if waitSend + waitResponse > 0 {
                if UIApplication.sharedApplication().networkActivityIndicatorVisible == false {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                }
            }else{
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
        }
    }
}

class HayateSocketHeartBeat: NSObject {
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didConnectToServer), name: HayateConnectSuccessNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didDisConnectToServer), name: HayateDisConnectNotification, object: nil)
    }
    
    func didConnectToServer() {
        self.performSelectorOnMainThread(#selector(self.startHeartBeat), withObject: nil, waitUntilDone: true)
    }
    
    func didDisConnectToServer() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(self.startHeartBeat), object: nil)
    }
    
    func startHeartBeat() {
        let heartBeat = DZHRequestPackage2963()
        heartBeat.ignorResponse = true
        heartBeat.sendRequest { (status) in
            
        }
        self.performSelector(#selector(self.startHeartBeat), withObject: nil, afterDelay: 20)
    }
}
