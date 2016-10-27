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

open class HayateHttpManager: NSObject {
    fileprivate var httpManager:AFHTTPSessionManager
    
    override convenience init(){
        self.init(constructing: { (manager: AFHTTPSessionManager) in
                manager.requestSerializer = AFHTTPRequestSerializer()
                manager.responseSerializer = AFHTTPResponseSerializer()
            })
    }
    
    init(constructing: (_ httpMananger: AFHTTPSessionManager) -> Void) {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForResource = 10
        httpManager = AFHTTPSessionManager(baseURL: nil, sessionConfiguration: sessionConfig);
        constructing(httpManager)
    }
    
    //POST请求 body直接使用二进制数据
    open func POSTStream(_ url: String, body: Data, succeed: @escaping Succeed, failed: @escaping Failure){
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = body
        
        httpManager.dataTask(with: request as URLRequest, completionHandler: { (response, responseObject, error) in
            if responseObject != nil {
                succeed(responseObject as AnyObject!)
            }else{
                failed(error as NSError!)
            }
        }).resume()
    }
    
    //普通HTTP POST网络请求
    open func POST(_ url: String!, body: AnyObject?, succeed: @escaping Succeed, failed: @escaping Failure) {
        httpManager.post(url,
                         parameters: body,
                         success: { (task: URLSessionDataTask, responseObject: Any) in
                            succeed(responseObject as AnyObject!)
                            },
                         failure: { (task: URLSessionDataTask, error: Error) in
                            failed(error as NSError!)
                            }
        )
    }
    
    //普通HTTP GET网络请求
    open func GET(_ url: String!, body: AnyObject?, succeed: @escaping Succeed, failed: @escaping Failure) {
        httpManager.get(url,
                        parameters: nil,
                        success: { (task: URLSessionDataTask, responseObject: Any) in
                            succeed(responseObject as AnyObject)
                        }, failure: {(task: URLSessionDataTask, error: Error) in
                            failed(error as NSError!)
                        }
        )
    }
    
    //上传图片
    open func uploadImage(_ url: String, body: Dictionary<String,String>?, imagePath: String, succeed: @escaping Succeed, failed: @escaping Failure){
        let image: UIImage? = UIImage(contentsOfFile: imagePath)
        let imageData: Data? = UIImageJPEGRepresentation(image!, 0.6)
        if imageData != nil {
            httpManager.post(url,
                             parameters: body,
                             constructingBodyWith: { (formData: AFMultipartFormData!) in
                                formData.appendPart(withFileData: imageData!, name: "upload", fileName: "upload", mimeType: "image/jpeg")
                                },
                             success: { (task: URLSessionDataTask, responseObject: Any)in
                                succeed(responseObject as AnyObject!)
                                },
                             failure: { (task: URLSessionDataTask, error: Error)in
                                failed(error as NSError!)
                                }
            )
        }
    }
}
