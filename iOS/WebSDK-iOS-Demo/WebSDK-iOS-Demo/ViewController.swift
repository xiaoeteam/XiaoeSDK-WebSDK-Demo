//
//  ViewController.swift
//  WebSDK-iOS-Demo
//
//  Created by xiaoemac on 2020/9/29.
//  Copyright © 2020 xiaoemac. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var loadUrl: XETextField = {
        let text = XETextField(frame: CGRect(x: 10, y: 210, width: UIScreen.main.bounds.width, height: 20))
        return text
    }()
        
    var appId: XETextField = {
        let text = XETextField(frame: CGRect(x: 10, y: 240, width: UIScreen.main.bounds.width, height: 20))
        return text
    }()
    
    var userId: XETextField = {
        let text = XETextField(frame: CGRect(x: 10, y: 270, width: UIScreen.main.bounds.width, height: 20))
        return text
    }()

    var client_id: XETextField = {
        let text = XETextField(frame: CGRect(x: 10, y: 300, width: UIScreen.main.bounds.width, height: 20))
        return text
    }()
    
    var client_secret: XETextField = {
        let text = XETextField(frame: CGRect(x: 10, y: 330, width: UIScreen.main.bounds.width, height: 20))
        return text
    }()
    
    var loginUrl: XETextField = {
        let text = XETextField(frame: CGRect(x: 10, y: 360, width: UIScreen.main.bounds.width, height: 20))
        return text
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        //测试按钮
        
        loadUrl.setTitle("banner:")
        loadUrl.setText("https://apppcHqlTPT3482.h5.inside.xiaoeknow.com")
        view.addSubview(loadUrl)
        
        appId.setTitle("appId:")
        appId.setText("apppcHqlTPT3482")
        view.addSubview(appId)
        
        userId.setTitle("userId:")
        userId.setText("u_qq_5f73f163c3b20_76fGHOcybRT")
        view.addSubview(userId)
        
        client_id.setTitle("client_id:")
        client_id.setText("xop3glkgRnh3725")
        view.addSubview(client_id)
        
        client_secret.setTitle("client_secret:")
        client_secret.setText("W6FtfqHeyKbipng7Reb5F5ohUa5ywcDN")
        view.addSubview(client_secret)

        loginUrl.setTitle("loginUrl")
        loginUrl.setText("https://platform.h5.inside.xiaoe-tech.com/platform/demo_sdk")
        view.addSubview(loginUrl)
        
        let button = UIButton(frame: CGRect(x: (UIScreen.main.bounds.width-200)/2, y: 420, width: 200, height: 50))
        button.setTitle("进入小鹅H5页面", for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = UIColor.blue
//        button.center = view.center
        view.addSubview(button)
        button.addTarget(self, action: #selector(gotoWeb), for: UIControl.Event.touchUpInside)
        
    }
    
    @objc func gotoWeb() {
        let webViewController = WebViewController()
        //在小鹅通B端管理台复制出来的课程链接
        //webViewController.loadUrl = "https://appxrwbvfhb8064.h5.xiaoeknow.com/v1/course/alive/l_5f72e59be4b0e95a89c1be7f?type=2"
        webViewController.loadUrl = self.loadUrl.getText()
        webViewController.appId = self.appId.getText()
        webViewController.userId = self.userId.getText()
        webViewController.loginUrl = self.loginUrl.getText()
        webViewController.client_id = self.client_id.getText()
        webViewController.client_secret = self.client_secret.getText()
        webViewController.loginUrl = self.loginUrl.getText()

        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
}

class XETextField: UIView {
    
    var label: UILabel = {
        let label = UILabel(frame: CGRect.init(x: 0, y: 0, width: 60, height: 27))
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    var input: UITextField = {
        let input = UITextField(frame: CGRect.init(x: 65, y: 0, width: 280, height: 27))
        input.backgroundColor = UIColor.gray
        return input
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        addSubview(input)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ title: String){
        label.text = title;
    }
    
    func setText(_ text: String){
        input.text = text
    }
    
    func getText() -> String{
        return input.text ?? ""
    }
    
    
}
