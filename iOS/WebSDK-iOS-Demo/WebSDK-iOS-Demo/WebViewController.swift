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
    
    lazy var webView : WKWebView = {
        let view = WKWebView.init(frame: self.view.bounds)
        view.uiDelegate = self;
        view.navigationDelegate = self;
        return view
    }()
    
    var loadUrl:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        //添加webView
        view.addSubview(webView)
        
        //加载网页
        if let urlstr = loadUrl , let url = URL(string: urlstr) {
            webView.load(URLRequest(url: url))
        }
        
    }
    
    func goToLogin() -> Void {
        /**
            APP端发起和小鹅通提供的服务器端API对接，
            APP -> 请求APP Server -> 请求小鹅通Server  -> 返回登录注册成功后的带登录态的url，
            登录态获取成功：APP端的wkwebview重新发起对带登录态的url网页加载，
            登录态获取失败：建议弹一个错误提示框告知用户，其他不需要额外处理，小鹅通课堂H5请求APP同步登录态信息的特定URL会内置提供手动刷新重新发起登录态获取请求
         */
        
        
    }
    
    //自定义的加载视图（展示）
    func showLoading() -> Void {
        var content = VHUDContent(.loop(3.0))
        content.shape = .circle
        content.style = .light
        VHUD.show(content)
    }
    
    //自定义的加载视图（隐藏）
    func hideLoading() -> Void {
        VHUD.dismiss(1.0, 1.0)
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
        //APP需要拦截判断小鹅通课堂H5内发起的请求APP同步登录态信息的特定URL
        /**
            APP需要拦截判断小鹅通课堂H5内发起的请求APP同步登录态信息的特定URL,
            调起APP测的登录态处理流程，处理方式参考goToLogin方法样例
         */
        if let urlstr = navigationAction.request.url?.absoluteString , urlstr == "http://www.baidu.com/login" {
            //发起登录请求
            goToLogin()
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
}
