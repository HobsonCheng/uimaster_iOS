//
//  NaviBarVC.swift
//  UIMaseter
//
//  Created by gongcz on 2018/4/12.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

typealias TouchEventCB = (_ objct: AnyObject, _ eventType: Int) -> Void
class NaviBarVC: BaseNameVC {
    ///是否是tabbar主页
    var isHomePage: Bool = false
    /// 页面样式数据模型
    var pageModel: PageConfigData?
    /// 导航栏
    var naviBarHead: NaviBar?
    var touchLeft: TouchEventCB?
    var touchright: TouchEventCB?
    //是否需要处理状态栏
    var isHandleStatusBar: Bool = true
    /// 获取Bar
    var naviBar: NaviBar? {
        return naviBarHead
    }
    ///是否隐藏导航栏
    var isHideNaviBar: Bool = false {
        didSet {
            naviBarHead?.isHidden = true
        }
    }
    /// 页面宽度
    var widthRate: CGFloat = 1

    // MARK: 初始化
    override init() {
        super.init()
    }

    init(pageModel: PageConfigData) {
        self.pageModel = pageModel
        kCurrentPageModel = pageModel
        super.init()
        self.pageParams = pageModel.attachment as? [String: Any] ?? [:]
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override init(name vcNameInit: String) {
        super.init(name: vcNameInit)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if !isHideNaviBar {
            // 创建NaviBar
            self.naviBarHead = NaviBar()
            naviBarHead?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: CGFloat(kNavigationBarHeight))
            // 添加
            self.view.addSubview(naviBarHead!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setDefaultBackButton() {
        self.naviBar?.setLeftBarItem(with: NaviBarItem(withImg: R.image.backWhite()!, target: self, action: #selector(goBack(_:)), imgSize: CGSize(width: 44, height: 43)))
    }
    @objc func goBack(_ sender: AnyObject) {
        _ = VCController.pop(with: VCAnimationClassic.defaultAnimation())
    }
    @objc func goDismiss(_ sender: AnyObject) {
        _ = VCController.pop(with: VCAnimationBottom.defaultAnimation())
    }
}
