//
//  AppDelegate.swift
//  Hayate
//
//  Created by 段 文武 on 16/5/11.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var socketMonitor: HayateSocketMonitor?
    var socketHeartBeat: HayateSocketHeartBeat = HayateSocketHeartBeat()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        socketMonitor = HayateSocketMonitor()
        let serverManager = SchedulingServerManager.sharedInstance
        serverManager.createSocket()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didConnectToServer), name: HayateConnectSuccessNotification, object: nil)
        
        return true
    }
    
    class func theAppDelegate() -> AppDelegate {
        return ((UIApplication.sharedApplication().delegate) as! AppDelegate)
    }
    
    func didConnectToServer() {
        let group = DZHMarketRequestGroupPackage()
        let request2939 = DZHRequestPackage2939(code:"300213")
        request2939.responseCompletion = { (status) in
            print("2939请求结束 \(status)")
        }
        let request2940 = DZHRequestPackage2940(code:"300213")
        request2940.responseCompletion = { (status) in
            print("2940请求结束 \(status)")
        }
        group.addPackage(request2939)
        group.addPackage(request2940)
        
        group.sendRequest { (status) in
            print("组包请求结束 \(status)")
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

