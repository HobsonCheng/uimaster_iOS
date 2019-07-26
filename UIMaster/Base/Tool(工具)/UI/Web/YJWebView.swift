//
//  YJWebView.swift
//  UIMaster
//
//  Created by hobson on 2018/7/26.
//  Copyright © 2018年 one2much. All rights reserved.
//

import dsBridge
import NVActivityIndicatorView
import UIKit

class YJWebView: DWKWebView {
    //遮罩
    lazy var activityView = { () -> NVActivityIndicatorView in
        let activityView = NVActivityIndicatorView(frame: self.bounds, type: NVActivityIndicatorType.lineScale, color: UIColor.gray, padding: kScreenW - 165)
        activityView.height += self.bounds.height / 3
        activityView.top -= self.bounds.height / 3
        activityView.backgroundColor = .white
        self.addSubview(activityView)
        return activityView
    }()

//    //单例
//    static fileprivate let singleton = YJWebView()
//    static var shared: YJWebView{
//        return singleton
//    }

    override private init(frame: CGRect, configuration: WKWebViewConfiguration) {
//        let config = WKWebViewConfiguration.init()
//        config.dataDetectorTypes = .lookupSuggestion
        super.init(frame: frame, configuration: configuration)
        self.becomeFirstResponder()
//        self.autoresizingMask = UIViewAutoresizing.init(rawValue: 1|4)
//        self.isMultipleTouchEnabled = true
//        self.autoresizesSubviews = true
//        self.scrollView.alwaysBounceVertical = true
//        self.allowsBackForwardNavigationGestures = true
//        self.layer.masksToBounds = true
        self.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadLocal(localUrlStr: String?) {
        let has = SandboxTool.isFileExist(in: localUrlStr?.removingPercentEncoding ?? "")
        if has {
            let url = URL(fileURLWithPath: localUrlStr?.removingPercentEncoding ?? "")
            self.load(URLRequest(url: url))
        }
    }
}
