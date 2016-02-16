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

class WebBrowserViewController: UIViewController, UIWebViewDelegate, UIAlertViewDelegate, NJKWebViewProgressDelegate {
    
    @IBOutlet weak var btnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var myWebView: UIWebView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var progressView: NJKWebViewProgressView!
    
    var webUrl: String?
    var progressProxy: NJKWebViewProgress?
    
    func initialWebView() -> Void {
        // 设置webView
        myWebView.backgroundColor = UIColor.clearColor()
        myWebView.scalesPageToFit = true
        myWebView.delegate = self
        self.webUrl = "http://m.hao123.com" // 默认首页网址
    }
    
    // 加载网页
    func loadWebSiteFromURL() -> Void {
        // 创建请求
        let requestUrl = NSURL(string: self.webUrl!)
        let webRequest = NSURLRequest(URL: requestUrl!)
        myWebView.loadRequest(webRequest)
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
        
        self.initialWebView()
        self.btnWidthConstraint.constant = UIScreen.mainScreen().bounds.size.width / 4.0
        let attributesStr = NSAttributedString(string: "请输入您要访问的网址", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        self.searchTextField.attributedPlaceholder = attributesStr
        self.searchTextField.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        self.searchTextField.textAlignment = NSTextAlignment.Center
        self.searchTextField.textColor = UIColor.whiteColor()
        self.loadWebSiteFromURL()
        // 初始化加载进度条
        self.progressProxy = NJKWebViewProgress()
        self.myWebView.delegate = self.progressProxy
        self.progressProxy?.webViewProxyDelegate = self
        self.progressProxy?.progressDelegate = self
    }
    
    @IBAction func gotoWebSiteAction(sender: AnyObject) {
        self.webUrl = self.searchTextField.text
        
        // 判断webURL是否合法
        if let url = self.webUrl where !url.isEmpty {
            if let has = self.webUrl?.hasPrefix("http://") {
                if has {
                    self.webUrl = self.searchTextField.text
                }else {
                    self.webUrl = "http://" + self.webUrl!
                }
            }else if let hasHttps = self.webUrl?.hasPrefix("https://") {
                if hasHttps {
                    self.webUrl = self.searchTextField.text
                }
            }
            // 显示URL
            if self.webUrl == "http://" || self.webUrl == "https://" {
                self.webUrl = ""
            }
            self.searchTextField.text = self.webUrl
            self.loadWebSiteFromURL()
            self.searchTextField.endEditing(true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIWebViewDelegate
    func webViewDidStartLoad(webView: UIWebView) {
        self.webUrl = webView.request?.URL?.absoluteString
        // 显示URL
        if self.webUrl == "http://" || self.webUrl == "https://" {
            self.webUrl = ""
        }
        self.searchTextField.text = self.webUrl
        self.searchTextField.endEditing(true)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        print("加载遇到错误: \(error?.localizedFailureReason)")
    }
    
    // MARK: NJKWebViewProgressDelegate
    func webViewProgress(webViewProgress: NJKWebViewProgress!, updateProgress progress: Float) {
        self.progressView.setProgress(progress, animated: true)
    }
}

