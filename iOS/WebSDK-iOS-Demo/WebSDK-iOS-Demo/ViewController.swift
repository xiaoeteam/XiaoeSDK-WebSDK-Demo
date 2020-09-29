//
//  ViewController.swift
//  WebSDK-iOS-Demo
//
//  Created by xiaoemac on 2020/9/29.
//  Copyright © 2020 xiaoemac. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        //测试按钮
        let button = UIButton(frame: CGRect(x: 10, y: 100, width: 200, height: 50))
        button.setTitle("进入小鹅H5页面", for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = UIColor.blue
        button.center = view.center
        view.addSubview(button)
        button.addTarget(self, action: #selector(goToWebView), for: UIControl.Event.touchUpInside)
        
    }
    
    @objc func goToWebView() -> Void {
        let webViewController = WebViewController()
        webViewController.loadUrl = "https://appxrwbvfhb8064.h5.xiaoeknow.com/v1/course/alive/l_5f72e59be4b0e95a89c1be7f?type=2"
        self.navigationController?.pushViewController(webViewController, animated: true)
    }

}

