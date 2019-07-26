//
//  OtherWebVC.swift
//  UIDS
//
//  Created by one2much on 2018/1/25.
//  Copyright © 2018年 one2much. All rights reserved.
//

import NVActivityIndicatorView
import UIKit
import WebKit

class OtherWebVC: NaviBarVC {
    var urlString: String? {//set url 做安全处理
        didSet {
            if (urlString?.hasPrefix("http"))! || (urlString?.hasPrefix("https"))! {
            } else {
                urlString = "https://\(urlString!)"
            }
        }
    }
    var localUrlString: String?
//    {
//        didSet{
//            if !(localUrlString?.hasPrefix("file://") ?? false) {
//                urlString = "file://\(localUrlString ?? "")"
//            }
//        }
//    }

    /*
     *加载WKWebView对象
     */
    lazy var wkWebview: WKWebView = {
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        var tempWebView = WKWebView(frame: self.view.bounds, configuration: config)
        tempWebView.navigationDelegate = self
        tempWebView.frame = CGRect(x: 0, y: (self.naviBar?.bottom ?? 64), width: kScreenW, height: kScreenH - (self.naviBar?.bottom ?? 64))
        return tempWebView
    }()
    /*
     *懒加载UIProgressView进度条对象
     */
    lazy var progress: UIProgressView = {
            () -> UIProgressView in
            var rect = CGRect(x: 0, y: (self.naviBar?.bottom ?? 64), width: kScreenW, height: 2.0)
            let tempProgressView = UIProgressView(frame: rect)
            tempProgressView.tintColor = UIColor.red
            tempProgressView.backgroundColor = UIColor.gray
            return tempProgressView
    }()

    lazy var activityView = { () -> NVActivityIndicatorView in
        let activityView = NVActivityIndicatorView(frame: CGRect(x: 0, y: (self.naviBar?.bottom ?? 64) + 2, width: self.view.width, height: self.view.height - (self.naviBar?.bottom ?? 64) - 2), type: NVActivityIndicatorType.lineScale, color: UIColor.gray, padding: 170)
        activityView.backgroundColor = .white
        self.view.addSubview(activityView)
        return activityView
    }()
    /*
     *移除观察者,类似OC中的dealloc
     *观察者的创建和移除一定要成对出现
     */
    deinit {
        self.wkWebview.removeObserver(self, forKeyPath: "estimatedProgress")
        self.wkWebview.removeObserver(self, forKeyPath: "canGoBack")
        self.wkWebview.removeObserver(self, forKeyPath: "title")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        kRootBaseVC.statusBarStyle = .default
        self.setupUI()
        self.loadRequest()
        self.addKVOObserver()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        kRootBaseVC.statusBarStyle = .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.naviBar?.setLeftBarItems(with: [])
        self.view.maskToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension OtherWebVC: WKUIDelegate, WKNavigationDelegate {
    /*
     *创建BarButtonItem
     */

    func setupBarButtonItem() {
//        let backButton = NaviBarItem.init(withCode: "#xe679;", target: self, action: #selector(OtherWebVC.selectedToBack), fontSize: 18, color: .gray)

        let closeBtn = NaviBarItem(withImg: UIImage(named: "close")!, target: self, action: #selector(OtherWebVC.selectedToClose), imgSize: CGSize(width: 43, height: 44))
        closeBtn.contentMode = .center
        let backBtn = NaviBarItem(withImg: UIImage(named: "back")!, target: self, action: #selector(OtherWebVC.selectedToBack), imgSize: CGSize(width: 43, height: 44))
//            NaviBarItem.init(withCode: "#xe63d;;", target: self, action: #selector(OtherWebVC.selectedToClose), fontSize: 18, color: .gray)

        self.naviBar?.setLeftBarItems(with: [backBtn])
        self.naviBar?.setRightBarItems(with: closeBtn)
    }

    /*
     *设置UI部分
     */
    func setupUI() {
        self.view.layer.masksToBounds = true
        self.naviBar?.backgroundColor = .white
        self.setupBarButtonItem()
        self.view.addSubview(self.wkWebview)
        self.view.addSubview(self.progress)
//        self.activityView.startAnimating()
        let lineView = UIView()
        self.naviBar?.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalToSuperview().offset(-1)
        }
        lineView.backgroundColor = UIColor(hexString: "#eeeeee")
    }

    /*`
     *加载网页 request
     */
    func loadRequest() {
        if let url = URL(string: self.urlString ?? "") {
            self.wkWebview.load(URLRequest(url: url))
        }
    }

    /// 加载本地文件
    func loadLocal() {
//        let url = URL.init(fileURLWithPath: self.localUrlString ?? "")
//        let has = SandboxTool.isFileExist(in: self.localUrlString ?? "")
        let url = URL(fileURLWithPath: self.localUrlString ?? "")
//        var pathCom = self.localUrlString?.split(separator: "/").map({ (subStr) -> String in
//            return String(subStr)
//        })
//        pathCom?.removeLast()
//        let directoryUrl = URL.init(fileURLWithPath: pathCom?.joined(separator: "/") ?? "")
//        self.wkWebview.loadFileURL(url, allowingReadAccessTo: directoryUrl)
        self.wkWebview.load(URLRequest(url: url))
    }
    /*
     *添加观察者
     *作用：监听 加载进度值estimatedProgress、是否可以返回上一网页canGoBack、页面title
     */
    func addKVOObserver() {
        self.wkWebview.addObserver(self, forKeyPath: "estimatedProgress", options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old], context: nil)
        self.wkWebview.addObserver(self, forKeyPath: "canGoBack", options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old], context: nil)
        self.wkWebview.addObserver(self, forKeyPath: "title", options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old], context: nil)
    }

    /*
     *返回按钮执行事件
     */
    @objc func selectedToBack() {
        if (self.wkWebview.canGoBack == true) {
            self.wkWebview.goBack()
        } else {
            VCController.pop(with: VCAnimationClassic.defaultAnimation())
        }
    }

    /*
     *关闭按钮执行事件
     */
    @objc func selectedToClose() {
        VCController.pop(with: VCAnimationClassic.defaultAnimation())
    }

    /*
     *观察者的监听方法
     */
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            dPrint(self.progress.progress)
            self.progress.alpha = 1.0
            self.progress .setProgress(Float(self.wkWebview.estimatedProgress), animated: true)
            if self.wkWebview.estimatedProgress >= 1 {
                UIView.animate(withDuration: 1.0, animations: {
                    self.progress.alpha = 0
                }, completion: { _ in
                    self.progress .setProgress(0.0, animated: false)
                })
            }
        } else if keyPath == "title" {
            let title = self.wkWebview.title ?? ""
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 15))
            label.text = title
            label.textAlignment = .center
            self.naviBar?.titleView = label
        }
//        else if keyPath == "canGoBack" {
//            if self.wkWebview.canGoBack == true
//            {
//                let items = NSArray.init(objects: self.leftBarButton!,self.leftBarButtonSecond!)
//                self.naviBar?.leftBarItems = items as! [Any]
//            }
//            else
//            {
//                let items = NSArray.init(objects: self.leftBarButton!)
//                self.naviBar?.leftBarItems = items as! [Any]
//            }
//        } else {
//            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//        }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityView.stopAnimating()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //如果是跳转一个新页面
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        if webView.url?.absoluteString.hasPrefix("items-appss://") ?? false {
            UIApplication.shared.open(webView.url!, options: [:], completionHandler: nil)
        }
//        if (navigationAction.targetFrame == nil) {
//            webView.loadRequest :navigationAction.request
//        }
        decisionHandler(WKNavigationActionPolicy.allow)

//        let urlStr = navigationAction.request.url?.absoluteString.stringByDecodingURLFormat()
//        if urlStr?.hasPrefix("http") ?? true || urlStr?.hasPrefix("https") ?? true{
//            let otherweb = OtherWebVC.init(name: "webview")
//            otherweb.urlString = urlStr
//            VCController.push(otherweb, with: VCAnimationClassic.defaultAnimation())
//            decisionHandler(WKNavigationActionPolicy.cancel)
//        }else{
//        }
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好的", style: .default, handler: { _ in
            completionHandler()
        }))
        alert.show()
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好的", style: .default, handler: { _ in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .default, handler: { _ in
            completionHandler(false)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
