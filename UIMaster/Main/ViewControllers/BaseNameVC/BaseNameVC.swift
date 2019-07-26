//
//  BaseNameVC.swift
//  UIMaseter
//
//  Created by gongcz on 2018/4/12.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

class BaseNameVC: UIViewController, VCControllerPtc {
    /// 是否可以右滑
    var canRightPan: Bool = true
    /// 页面唯一标示
    var tagInt: Int?
    /// 名称
    var vcName: String?
    /// 页面的公共参数区域
    lazy var pageParams = [String: Any]()

    var isHiddenStatesBar: Bool = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    var statusBarStyle: UIStatusBarStyle = .lightContent {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    override var prefersStatusBarHidden: Bool {
        var flag = false
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if appDelegate?.window?.rootViewController == nil {
            flag = true
        }
        return isHiddenStatesBar && flag
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        // 根据时间生成随机VCName
        let curDate = Date()
        let dateFormatter = DateFormatter()
        let gregorianLocale = Locale(identifier: NSCalendar.Identifier.gregorian.rawValue)
        dateFormatter.locale = gregorianLocale
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let curDateText = dateFormatter.string(from: curDate)
        let defaultVCName = "VCName:\(curDateText) \(NSStringFromClass(type(of: self))))"
        vcName = defaultVCName
        // 默认是支持右滑
        canRightPan = true
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    init(name vcNameInit: String) {
        super.init(nibName: nil, bundle: nil)
        if !(vcNameInit.isEmpty) {
            vcName = vcNameInit
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let appFrame: CGRect = AppInfo.appFrame()
        self.view.frame = CGRect(x: 0, y: 0, width: appFrame.size.width, height: appFrame.size.height)
        self.view.backgroundColor = UIColor(hex: 0xf2f8fb, alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func childViewControllerForStatusBarHidden() -> UIViewController? {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if appDelegate?.window?.rootViewController == nil {
            return self
        }
        if appDelegate?.window?.rootViewController == self {
            return VCController.getTopVC()
        }
        return nil
    }

    // MARK: - VCControllerPtc
    // VC即将pop的事件通知
    func vcWillPop() {
    }
    func canGoBack() -> Bool {
        return true
    }
    func doGoBack() {
    }
    func ignoreGesture(_ view: UIView) -> Bool {
        return false
    }
}
