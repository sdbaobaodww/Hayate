//
//  HayateHttpManager.swift
//  Hayate
//
//  Created by 段 文武 on 16/5/17.
//  Copyright © 2016年 Duanwwu. All rights reserved.
//

import Foundation

public typealias Succeed = (AnyObject!)->Void
public typealias Failure = (NSError!)->Void

public class HayateHttpManager: NSObject {
    private var httpManager:AFHTTPSessionManager
    
    override convenience init(){
        self.init(constructing: { (manager: AFHTTPSessionManager) in
                manager.requestSerializer = AFHTTPRequestSerializer()
                manager.responseSerializer = AFHTTPResponseSerializer()
            })
    }
    
    init(constructing: (httpMananger: AFHTTPSessionManager) -> Void) {
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfig.timeoutIntervalForResource = 10
        httpManager = AFHTTPSessionManager(baseURL: nil, sessionConfiguration: sessionConfig);
        constructing(httpMananger: httpManager)
    }
    
    //POST请求 body直接使用二进制数据
    public func POSTStream(url: String, body: NSData, succeed: Succeed, failed: Failure){
        let mysucceed: Succeed = succeed
        let myfailure: Failure = failed
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = body
        httpManager.dataTaskWithRequest(request, completionHandler: { (response: NSURLResponse!, responseObject: AnyObject!, error: NSError?) in
            if error != nil {
                myfailure(error)
            }else{
                mysucceed(responseObject)
            }
        }).resume()
    }
    
    //普通HTTP POST网络请求
    public func POST(url: String!, body: AnyObject?, succeed: Succeed, failed: Failure) {
        let mysucceed: Succeed = succeed
        let myfailure: Failure = failed
        httpManager.POST(url, parameters: body, success: { (task:NSURLSessionDataTask!, responseObject:AnyObject!) in
                mysucceed(responseObject)
            }, failure:{ (task: NSURLSessionDataTask!, error: NSError!) in
                myfailure(error)
        })
    }
    
    //普通HTTP GET网络请求
    public func GET(url: String!, body: AnyObject?, succeed: Succeed, failed: Failure) {
        let mysucceed: Succeed = succeed
        let myfailure: Failure = failed
        httpManager.GET(url, parameters: nil,
                        success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!) in
                            mysucceed(responseObject)
                        }, failure: {(task: NSURLSessionDataTask!, error: NSError!) in
                            myfailure(error)
        })
    }
    
    //上传图片
    public func uploadImage(url: String, body: Dictionary<String,String>?, imagePath: String, succeed: Succeed, failed: Failure){
        let image: UIImage? = UIImage(contentsOfFile: imagePath)
        let imageData: NSData? = UIImageJPEGRepresentation(image!, 1.0)
        if imageData != nil {
            let mysucceed: Succeed = succeed
            let myfailure: Failure = failed
            httpManager.POST(url, parameters: body, constructingBodyWithBlock: { (formData: AFMultipartFormData!) in
                formData.appendPartWithFileData(imageData!, name: "upload", fileName: "upload", mimeType: "image/jpeg")
                }, success: { (task: NSURLSessionDataTask!, responseObject: AnyObject!)in
                    mysucceed(responseObject)
                }, failure: { (task: NSURLSessionDataTask!, error: NSError!)in
                    myfailure(error)
            })
        }
    }
}
