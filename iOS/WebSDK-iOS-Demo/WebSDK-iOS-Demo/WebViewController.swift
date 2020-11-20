//
//  WebViewController.swift
//  WebSDK-iOS-Demo
//
//  Created by xiaoemac on 2020/9/29.
//  Copyright © 2020 xiaoemac. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class WebViewController : UIViewController {
    
    var isIphoneX: Bool {
        get {
            let kScreenHeight = UIScreen.main.bounds.size.height
            return kScreenHeight >= 812 && kScreenHeight < 1024
        }
    }
    
    ///在小鹅通B端管理台复制出来的课程链接
    var loadUrl:String?
    
    var appId: String?
    
    var userId: String?
    
    var loginUrl: String?
    
    var client_id: String?
    
    var client_secret: String?
    
    var isloadPayLink: Bool = false
    
    /// 登录操作前的页面
    var loginFrontUrl: String?
    
    lazy var webView : WKWebView = {
        
        /// - react
        var react = self.view.bounds
        react.origin.y = isIphoneX ? 88 : 64
        react.size.height = react.size.height - react.origin.y
        
        /// - config
        let webConfig = WKWebViewConfiguration()
        webConfig.preferences = WKPreferences()
        webConfig.processPool  = WKProcessPool()
        webConfig.preferences.minimumFontSize = 10;
        webConfig.preferences.javaScriptEnabled = true
        webConfig.preferences.javaScriptCanOpenWindowsAutomatically = false
        
        /// - cookieValue
        let cookieValue = "document.cookie = 'xe_websdk=1';"
        let userContentController = WKUserContentController()
        let cookieScript = WKUserScript(source: cookieValue, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
        userContentController.addUserScript(cookieScript)
        webConfig.userContentController = userContentController
        
        /// - webview
        let webView = WKWebView(frame: react, configuration: webConfig)
        webView.uiDelegate = self;
        webView.navigationDelegate = self;
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        let navitem = UIBarButtonItem(image: UIImage(named: "navi_back"),
                                      style: .plain,
                                      target: self,
                                      action: #selector(back))
        self.navigationItem.leftBarButtonItem = navitem
        
        /// 添加webView
        view.addSubview(webView)
        
        /// load网页
        if let urlstr = loadUrl  {
            loadRequestWithUrlString(urlstr)
        }
        
    }
    
    /// 自定义的加载视图（展示）
    func showLoading() -> Void {
        VHUD.dismiss(0.0,0.0)
        var content = VHUDContent(.loop(3.0))
        content.shape = .circle
        content.style = .light
        VHUD.show(content)
    }
    
    func showError(_ msg: String){
        hideLoading()
        let alertController = UIAlertController(title: "系统提示",
                                                message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "好的", style: .default, handler: {
            action in
            print("点击了确定")
        })
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //自定义的加载视图（隐藏）
    func hideLoading() -> Void {
        VHUD.dismiss(0.25, 0.25)
    }
    
    deinit {
        hideLoading()
    }
}


// - 私有方法
extension WebViewController {
    
    /// replace的方法清空路由栈，防止返回重复登录页面
    /// - Parameters:
    ///   - url: 加载的链接
    @objc  func openUrl(_ url: String) {
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript("window.location.replace('\(url)')", completionHandler: nil)
        }
    }
    
    /// 加载携带的Cookie
    /// - Parameters:
    ///   - urlString: 第一次的加载需要携带cookie的链接
    func loadRequestWithUrlString(_ urlString: String) {
        
        /// cookie
        let cookieValue = "xe_websdk=1;"
        
        let url:NSURL = NSURL(string:urlString)!
        
        let request : NSMutableURLRequest = NSMutableURLRequest(url: url as URL)
        
        request.addValue(cookieValue, forHTTPHeaderField: "Cookie")
        
        webView.load(request as URLRequest)
        
    }
    
    @objc func back() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

// MARK: - 登陆，网络request
extension WebViewController {
    
    /// - 模拟登陆流程
    func showlogin() {
        let alter = UIAlertController.init(title: "确定登录", message: "", preferredStyle: .alert)
        let cancle = UIAlertAction.init(title: "取消", style: .cancel) { (action) in
        }
        let sure = UIAlertAction.init(title: "确定", style: .default) {[weak self] (action) in
            /// 发起登录请求
            self?.goToLogin()
        }
        alter.addAction(cancle)
        alter.addAction(sure)
        self.present(alter, animated: true, completion: nil)
    }
    
    /// APP测登录态获取同步方法事例
    @objc func goToLogin(){
        
        let urlString = loginUrl ?? ""
        let params: Any = ["app_id":self.appId ?? "" ,"client_id":self.client_id ?? "","client_secret":self.client_secret ?? "","user_id": self.userId ?? "","grant_type":"client_credential","banner_url":loginFrontUrl]
        guard let body = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) else {
            return
        }
        
        httpSend(urlString: urlString, body: String(data: body, encoding: .utf8)
            ,completionHandler: {[weak self] (data, response, error) in
                if error != nil {
                    self?.showError("登录失败！")
                    return
                }
                if let reslutData = data as NSData?,
                    let reslut = self?.nsdataToJSON(data: reslutData) as? [String: Any]{
                    guard let dic = reslut["data"] as? [String: String] else {
                        return
                    }
                    /// 授权失败
                    if let code = reslut["code"] as? Int, code != 0{
                        if let urlstr = dic["permission_denied_url"] ,  let url = URL(string: urlstr) {
                            self?.openUrl(urlstr)
                        }
                    } else {
                        /// 授权成功
                        if  let urlstr = dic["login_url"] ,  let url = URL(string: urlstr) {
                            self?.openUrl(urlstr)
                        }
                    }
                }
        })
        
    }
    
    
    func nsdataToJSON(data: NSData) -> AnyObject? {
        do {
            return try JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers) as AnyObject
        } catch {
            print(error)
        }
        return nil
    }
    
    func httpSend(urlString:String, body:String?, completionHandler: @escaping(Data?, URLResponse?, Error?) -> Void){
        /// 参数
        let str = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        let url:URL! = URL.init(string: str)
        var request:URLRequest = URLRequest(url: url)
        
        if body != nil{
            request.httpMethod = "POST"
            let bodyData = body?.data(using: String.Encoding.utf8)
            request.httpBody = bodyData
            request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "content-type")
        }else{
            request.httpMethod = "GET"
        }
        
        ///  请求
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let dataTask = session.dataTask(with: request, completionHandler: completionHandler)
        dataTask.resume()
    }
    
}

// MARK: - WKUIDelegate,WKNavigationDelegate
extension WebViewController : WKUIDelegate,WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showLoading()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideLoading()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideLoading()
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let  card = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential,card);
        }
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        /**
         APP需要拦截判断小鹅通课堂H5内发起的请求APP同步登录态信息的特定URL,
         调起APP测的登录态处理流程，处理方式参考goToLogin方法样例
         */
        
        guard let urlstr = navigationAction.request.url?.absoluteString else {
            decisionHandler(WKNavigationActionPolicy.cancel)
            return
        }
        
        /// - 设置支付的ref
        /// 建议使用base64等加密，处理请求的链接，
        if urlstr.contains("https://wx.tenpay.com/cgi-bin/mmpayweb-bin/checkmweb")
        {
            if !self.isloadPayLink {
                var mRequest = navigationAction.request
                mRequest.setValue("h5-pay.sdk.xiaoe-tech.com://", forHTTPHeaderField: "Referer")
                self.webView.load(mRequest)
                self.isloadPayLink = true
                decisionHandler(.cancel)
                return
            }else {
                decisionHandler(.allow)
                self.isloadPayLink = true
                return
            }
        }
        self.isloadPayLink = false
        
        /// 微信支付
        if urlstr.hasPrefix("weixin://wap/pay") {
            let url = URL.init(string: urlstr)!
            let canOpen =  UIApplication.shared.canOpenURL(url)
            if canOpen {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            decisionHandler(.cancel)
            self.isloadPayLink = false
            return
        }
        
        /// 拦截登录
        if urlstr.contains("/outLoginHint")  {
            self.showlogin()
        } else {
            if !urlstr.contains("captcha") {
                loginFrontUrl = urlstr
            }
        }
        
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    
}
