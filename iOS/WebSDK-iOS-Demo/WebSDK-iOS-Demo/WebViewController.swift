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
}
