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
        
        goToWebView()

        let button = UIButton(frame: CGRect(x: 10, y: 100, width: 200, height: 50))
        button.setTitle("进入小鹅H5页面", for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = UIColor.blue
        button.center = view.center
        view.addSubview(button)
        button.addTarget(self, action: #selector(goToWebView), for: UIControl.Event.touchUpInside)
        
    }
    
    func gotoWeb(_ address: String, _ interceptAddress: String, appId: String, userId: String ) {
             let webViewController = WebViewController()
             //在小鹅通B端管理台复制出来的课程链接
             //webViewController.loadUrl = "https://appxrwbvfhb8064.h5.xiaoeknow.com/v1/course/alive/l_5f72e59be4b0e95a89c1be7f?type=2"
             webViewController.loadUrl = address
             webViewController.interceptAddress = interceptAddress
             webViewController.appId = appId
             webViewController.userId = userId
             self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    @objc func goToWebView() -> Void {
     
           let alertController = UIAlertController(title: "请确认登录信息",
                                                   message: nil, preferredStyle: .alert)
           alertController.addTextField { (textField) in
               textField.placeholder = "请输入店铺地址"
               textField.text = "http://apptlyqoaza9229.h5.inside.xiaoeknow.com/"
           }
           alertController.addTextField { (textField) in
               textField.placeholder = "请输入拦截地址"
               textField.text = "http://www.baidu.com/"
           }
           alertController.addTextField { (textField) in
               textField.placeholder = "请输入app_id"
               textField.text = "appTlYQOaza9229"
           }
           alertController.addTextField { (textField) in
               textField.placeholder = "请输入user_id"
               textField.text = "u_5f4cb41866714_3Wt6zwmJQW"
           }
           let cancleAction = UIAlertAction(title: "取消", style: .cancel,handler: { action in
               
           })
           let okAction = UIAlertAction(title: "确认", style: .default, handler: {[weak self]
               action in
               if  let address = alertController.textFields?[0].text as? String, let interceptAddress =  alertController.textFields?[1].text as? String, let appid = alertController.textFields?[2].text as? String, let userId =  alertController.textFields?[3].text as? String {
                   self?.gotoWeb(address, interceptAddress, appId: appid, userId: userId)
               }
           })
           alertController.addAction(cancleAction)
           alertController.addAction(okAction)
           self.present(alertController, animated: true, completion: nil)
       
    }

}

