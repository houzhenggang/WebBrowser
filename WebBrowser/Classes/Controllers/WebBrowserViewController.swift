//
//  WebBrowserViewController.swift
//  WebBrowser
//
//  Created by xuran on 16/2/15.
//  Copyright © 2016年 X.R. All rights reserved.
//

/**
 *  WebView实现简易浏览器
 */

import UIKit

class WebBrowserViewController: UIViewController, UIWebViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var btnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var myWebView: UIWebView!
    @IBOutlet weak var searchTextField: UITextField!
    var webUrl: String?
    
    func initialWebView() -> Void {
        // 设置webView
        myWebView.backgroundColor = UIColor.clearColor()
        myWebView.scalesPageToFit = true
        myWebView.delegate = self
        self.webUrl = "http://www.hao123.com" // 默认首页网址
    }
    
    // 加载网页
    func loadWebSiteFromURL() -> Void {
        // 创建请求
        let requestUrl = NSURL(string: self.webUrl!)
        let webRequest = NSURLRequest(URL: requestUrl!, cachePolicy: NSURLRequestCachePolicy.ReloadRevalidatingCacheData, timeoutInterval: 60)
        myWebView.loadRequest(webRequest)
    }
    
    // 开始加载
    func webStartLoading() -> Void {
        if !self.activityView.isAnimating() {
            self.view.userInteractionEnabled = false
            self.myWebView.hidden = true
            self.activityView.startAnimating()
        }
    }
    
    // 停止加载
    func webStopLoading() -> Void {
        if self.activityView.isAnimating() {
            self.view.userInteractionEnabled = true
            self.activityView.stopAnimating()
            self.myWebView.hidden = false
        }
    }
    
    func initialActivityView() -> Void {
        // 初始化加载View
        self.activityView.color = UIColor.grayColor()
        self.activityView.hidesWhenStopped = true
        
        // 立刻开始转
        self.webStartLoading()
    }
    
    @IBAction func goBackAction(sender: AnyObject) {
        if self.myWebView.canGoBack {
            self.myWebView.goBack()
        }
    }
    
    @IBAction func stopAction(sender: AnyObject) {
        if self.myWebView.loading {
            self.myWebView.stopLoading()
        }
    }
    
    @IBAction func reloadAction(sender: AnyObject) {
        self.myWebView.reload()
    }
    
    @IBAction func goForWardAction(sender: AnyObject) {
        if self.myWebView.canGoForward {
            self.myWebView.goForward()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialActivityView()
        self.initialWebView()
        self.btnWidthConstraint.constant = UIScreen.mainScreen().bounds.size.width / 4.0
        let attributesStr = NSAttributedString(string: "请输入您要访问的网址", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        self.searchTextField.attributedPlaceholder = attributesStr
        self.searchTextField.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.searchTextField.textAlignment = NSTextAlignment.Center
        self.searchTextField.textColor = UIColor.whiteColor()
        self.loadWebSiteFromURL()
    }
    
    @IBAction func gotoWebSiteAction(sender: AnyObject) {
        self.webUrl = self.searchTextField.text
        if let has = self.webUrl?.hasPrefix("http://") {
            if has {
                self.webUrl = self.searchTextField.text
            }else {
                self.webUrl = "http://" + self.webUrl!
            }
        }
        self.loadWebSiteFromURL()
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIWebViewDelegate
    func webViewDidStartLoad(webView: UIWebView) {
        print("\(self.myWebView.request?.URL?.absoluteString)")
        self.webStartLoading()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.webStopLoading()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        self.webStopLoading()
        // 弹出alert
        let alert = UIAlertView(title: "加载失败", message: "", delegate: self, cancelButtonTitle: "关闭", otherButtonTitles: "重新加载")
        alert.show()
    }
    
    // MARK: UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            self.myWebView.reload()
        }
    }
}

