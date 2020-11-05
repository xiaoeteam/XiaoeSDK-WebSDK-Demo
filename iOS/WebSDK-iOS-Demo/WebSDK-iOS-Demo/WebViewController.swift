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
    
    lazy var webView : WKWebView = {
        var rect = self.view.bounds
        rect.origin.y = isIphoneX ? 88 : 64
        rect.size.height = rect.size.height - rect.origin.y
        let view = WKWebView.init(frame: rect )
        view.uiDelegate = self;
        view.navigationDelegate = self;
        return view
    }()
    
    ///在小鹅通B端管理台复制出来的课程链接
    var loadUrl:String?
    
    var interceptAddress: String?
    
    var appId: String?
    
    var userId: String?
    
    /// 登录操作前的页面
    var loginFrontUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        //添加webView
        view.addSubview(webView)
        
        //加载网页
        if let urlstr = loadUrl, let url = URL(string: urlstr) {
            webView.load(URLRequest(url: url))
        }
        
    }
    
    //自定义的加载视图（展示）
    func showLoading() -> Void {
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
    
}

extension WebViewController {
    
    //APP测登录态获取同步方法事例
    func goToLogin() -> Void {
       

        let urlString = "http://platform.h5.inside.xiaoe-tech.com/platform/login_cooperate/get_login_url"
        let params: Any = ["app_id":appId ?? "" ,"user_id": userId ?? "","data":["login_type":"2","redirect_uri": loginFrontUrl]]
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
                            self?.webView.load(URLRequest(url: url))
                        }
                    } else {
                        /// 授权成功
                        if  let urlstr = dic["login_url"] ,  let url = URL(string: urlstr) {
                            self?.webView.load(URLRequest(url: url))
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
        
        // 请求
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let dataTask = session.dataTask(with: request, completionHandler: completionHandler)
        dataTask.resume()
    }
}

//网页代理回调
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
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        /**
         APP需要拦截判断小鹅通课堂H5内发起的请求APP同步登录态信息的特定URL,
         调起APP测的登录态处理流程，处理方式参考goToLogin方法样例
         */
        if let urlstr = navigationAction.request.url?.absoluteString , urlstr.hasPrefix(interceptAddress ?? "")  {
            //发起登录请求
            goToLogin()
        } else {
            loginFrontUrl = navigationAction.request.url?.absoluteString
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    
}
