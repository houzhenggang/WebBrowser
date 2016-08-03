//
//  WebCacheURLProtocol.swift
//  WebBrowser
//
//  Created by xuran on 16/8/1.
//  Copyright © 2016年 X.R. All rights reserved.
//

import UIKit
import CoreData

// 记录请求的数量
var requestCount = 0
let webCacheURLProtocolHandleKey = "webCacheURLProtocolHandleKey"

class WebCacheURLProtocol: NSURLProtocol, NSURLSessionTaskDelegate, NSURLSessionDataDelegate {

    var urlDataTask: NSURLSessionDataTask?
    var urlResponse: NSURLResponse?
    var receivedData: NSMutableData?
    
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        
        // 跳过已处理的请求，防止无限循环
        if let _ = NSURLProtocol.propertyForKey(webCacheURLProtocolHandleKey, inRequest: request) {
            return false
        }
        return true
    }
    
    // 返回规范化的请求
    override class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        
        return request
    }
    
    // 判断是否是同一个请求，同一个请求就加载缓存数据，否则从网络进行加载数据
    override class func requestIsCacheEquivalent(a: NSURLRequest, toRequest b: NSURLRequest) -> Bool {
        
        return super.requestIsCacheEquivalent(a, toRequest: b)
    }
    
    // 开始处理请求
    override func startLoading() {
        
        requestCount += 1
        
        print("count: \(request.URL!.absoluteString)")
        
        // 判断是否有本地缓存
        let cacheRequest = self.fetchCacheResponseForRequest() as? WebCache
        if let cacheRes = cacheRequest {
            
            print("从缓存中获取内容")
            
            // 获取本地数据
            let data = cacheRes.data
            let mimeType = cacheRes.mimetype
            let encoding = cacheRes.encoding
            
            // 创建NSURLResponse
            let response = NSURLResponse(URL: request.URL!, MIMEType: mimeType, expectedContentLength: data!.length, textEncodingName: encoding)
            
            // 将数据返回客户端，调用NSURLProtocol DidFinishedLoading结束加载
            self.client?.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .NotAllowed)
            self.client?.URLProtocol(self, didLoadData: data!)
            self.client?.URLProtocolDidFinishLoading(self)
        }
        else {
            
            // 请求网络数据
            print("从网络获取数据")
            
            let netRequest = self.request.mutableCopy() as! NSMutableURLRequest
            // 通过NSURLProtocol的setProperty()方法为URLRequest设置标签
            // 把处理过的请求做个标记，下一次不再处理，避免无限循环
            NSURLProtocol.setProperty(true, forKey: webCacheURLProtocolHandleKey, inRequest: netRequest)
        
            // 使用NSURLSession获取数据
            let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
            self.urlDataTask = urlSession.dataTaskWithRequest(netRequest)
            self.urlDataTask?.resume()
        }
    }
    
    // 结束处理请求
    override func stopLoading() {
        
        self.urlDataTask?.cancel()
        self.urlDataTask = nil
        self.receivedData = nil
        self.urlResponse = nil
    }
    
    // 查询是否有缓存
    func fetchCacheResponseForRequest() -> NSManagedObject? {
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context  = delegate.managedObjectContext
        
        // 查询
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("WebCache", inManagedObjectContext: context)
        
        fetchRequest.entity = entity
        
        // 设置查询条件
        let predicate = NSPredicate(format: "url == %@", request.URL!.absoluteString)
        fetchRequest.predicate = predicate
        
        do {
            let result = try context.executeFetchRequest(fetchRequest) as? Array<NSManagedObject>
            
            if let res = result {
                if !res.isEmpty {
                    return res.first
                }
            }
        }
        catch let error as NSError {
            print("查询本地缓存失败！error: \(error)")
        }
        
        return nil
    }
    
    func saveResponse() -> Void {
        
        print("缓存网络数据")
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext
        
        let managedObject = NSEntityDescription.insertNewObjectForEntityForName("WebCache", inManagedObjectContext: context) as! WebCache
        managedObject.data = self.receivedData
        managedObject.mimetype = self.urlResponse?.MIMEType
        managedObject.encoding = self.urlResponse?.textEncodingName
        managedObject.url = self.urlResponse?.URL?.absoluteString
        managedObject.timestamp = NSDate()
        
        // 保存数据到CoreData
        dispatch_async(dispatch_get_main_queue()) { 
            
            do {
                try context.save()
            }
            catch let error as NSError {
                print("CoreData保存失败！error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: NSURLSessionDataDelegate
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        self.client?.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .NotAllowed)
        self.urlResponse = response
        self.receivedData = NSMutableData()
        completionHandler(.Allow)
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        
        self.client?.URLProtocol(self, didLoadData: data)
        self.receivedData?.appendData(data)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        if let err = error where err.code != NSURLErrorCancelled {
            self.client?.URLProtocol(self, didFailWithError: err)
        }
        else {
            // 保存数据
            self.saveResponse()
            self.client?.URLProtocolDidFinishLoading(self)
        }
    }
    
    
}
