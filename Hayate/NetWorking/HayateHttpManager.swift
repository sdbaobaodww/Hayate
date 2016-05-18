//
//  HayateHttpManager.swift
//  Hayate
//
//  Created by 段 文武 on 16/5/17.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

typealias Succeed = (NSURLSessionDataTask!,AnyObject!)->Void

typealias Failure = (NSURLSessionDataTask!,NSError!)->Void

class HayateHttpManager: NSObject {
 
    var httpManager:AFHTTPSessionManager
    
    class var sharedInstance :HayateHttpManager {
        
        struct Static {
            static var onceToken:dispatch_once_t = 0
            static var instance:HayateHttpManager? = nil
        }
        
        dispatch_once(&Static.onceToken, { () -> Void in
            
            Static.instance = HayateHttpManager()
        })
        
        return Static.instance!
    }
    
    override init(){
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfig.timeoutIntervalForResource = 10
        httpManager = AFHTTPSessionManager(baseURL: nil, sessionConfiguration: sessionConfig);
    }
    
    //普通post网络请求
    func POST(url:String!,body:AnyObject?,succeed:Succeed,failed:Failure) {
        
        let mysucceed:Succeed = succeed
        let myfailure:Failure = failed
        
        httpManager.POST(url, parameters: body, success: { (task:NSURLSessionDataTask!, responseObject:AnyObject!)  in
            mysucceed(task,responseObject)
        }){ (task:NSURLSessionDataTask!, error:NSError!) in
            myfailure(task,error)
        }
    }
    
    //普通get网络请求
    func GET(url:String!,body:AnyObject?,succeed:Succeed,failed:Failure) {
        
        let mysucceed:Succeed = succeed
        let myfailure:Failure = failed
        
        httpManager.GET(url, parameters: nil,
                        success: { (task:NSURLSessionDataTask!, responseObject:AnyObject!) in
                            
                            mysucceed(task,responseObject)
                            
                        }, failure: {(task:NSURLSessionDataTask!, error:NSError!) in
                            
                            myfailure(task,error)
        })
    }
    
    //上传图片
    func  uploadImage(url:String,body:Dictionary<String,String>?,imagePath:String,succeed:Succeed,failed:Failure){
        let image: UIImage? = UIImage(contentsOfFile:imagePath)
        let imageData: NSData? = UIImageJPEGRepresentation(image!, 1.0)
        
        if imageData != nil {
         
            let mysucceed: Succeed = succeed
            let myfailure: Failure = failed
            httpManager.POST(url, parameters: body, constructingBodyWithBlock: { (formData:AFMultipartFormData!) in
                
                formData.appendPartWithFileData(imageData!, name: "upload", fileName: "upload", mimeType: "image/jpeg")
                
                }, success: { (task:NSURLSessionDataTask!, responseObject:AnyObject!)in
                    
                    mysucceed(task,responseObject)
                    
                }, failure: { (task:NSURLSessionDataTask!, error:NSError!)in
                    
                    myfailure(task,error)
            })
        }
    }
}