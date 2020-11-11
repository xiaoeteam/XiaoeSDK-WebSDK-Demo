//
//  AppDelegate.swift
//  WebSDK-iOS-Demo
//
//  Created by xiaoemac on 2020/9/29.
//  Copyright © 2020 xiaoemac. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window : UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
         let webView = ViewController()
//        let webView = WebViewController()
//        webView.loadUrl = "http://apptlyqoaza9229.h5.inside.xiaoeknow.com/"
//        webView.interceptAddress = "http://www.baidu.com/"
//        webView.appId = "appTlYQOaza9229"
//        webView.userId = "u_5f4cb41866714_3Wt6zwmJQW"
        let rootcontroller = UINavigationController(rootViewController: webView)
        window?.rootViewController = rootcontroller
        window?.makeKeyAndVisible()
        return true
    }



}

