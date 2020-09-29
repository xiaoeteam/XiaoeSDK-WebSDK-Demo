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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        //添加webView
        view.addSubview(webView)
        
        
    }
}

//网页代理回调
extension WebViewController : WKUIDelegate,WKNavigationDelegate {
    
}
