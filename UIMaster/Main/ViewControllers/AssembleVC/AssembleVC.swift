//
//  AssembleVC.swift
//  UIDS
//
//  Created by one2much on 2018/1/10.
//  Copyright © 2018年 one2much. All rights reserved.
//

import RxSwift
import UIKit

class AssembleVC: NaviBarVC {
    var moduleList: [Any]?
    var mainView: MainScrollView?
    var startY: CGFloat = 1
    var leftList: [Any]?
    var rightList: [Any]?
    var bgImgView: UIImageView?
    var isPageVc: Bool = false

    var mainTable: BaseTableView?

    lazy var topViewContainer = { () -> UIView in
        let view = UIView()
        view.autoresizesSubviews = false
        view.layer.masksToBounds = true
        view.backgroundColor = .clear
        view.width = self.view.width
        self.mainView?.addSubview(view)
        return view
    }()
    ///记录当前页面模块的个数
    var moduleCount: Int = 0
    /// 记录pageVCView的高度
    lazy var pageVCViewHeight: CGFloat = {
        kScreenH - (self.pageModel?.naviBar?.styles?.heightNaviBar ?? 44)
    }()
    /// 是否为弹出层
    var isFloatingMenu = false {
        didSet {
            if isFloatingMenu {
                self.isHideNaviBar = isFloatingMenu
            }
        }
    }
    /// 子控件
    weak var submoduleDelegate: PageModuleAble?

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        //配置页面相关UI
        self.configurePageUI()
        //渲染模块
        self.renderModuleList()
        //配置刷新机制
        self.configureRefresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        //更改状态栏样式
//        if isHandleStatusBar {//是否需要处理
//            //是否隐藏
//            kRootBaseVC.isHiddeStatesBar = self.pageModel?.fields?.isHiddenStatusBar == 1
//            //黑色还是白色
//            kRootBaseVC.statusBarStyle = self.pageModel?.fields?.isLightContentStatusBar == 1 ? .lightContent : .default
//        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFloatingMenu {
            return
        }
        let naviHeight = (pageModel?.naviBar?.styles?.heightNaviBar ?? kNavigationBarHeight) + (kIsiPhoneX ? kStatusBarHeight : 20)
        if let mainView = mainView {
            var height = view.height + (isHomePage ? -(GlobalConfigTool.shared.tabbar?.styles?.heightTabBar ?? 0) - kiPhoneXBottomH : 0) + (isHideNaviBar ? 0: -naviHeight)
            if isHideNaviBar && !kRootBaseVC.isHiddenStatesBar && !isPageVc {
                height -= 20
                mainView.mj_y = 20
            }
            if mainView.height != height {
                mainView.height = height
                bgImgView?.height = mainView.height
                bgImgView?.mj_y = mainView.mj_y
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        dPrint("销毁")
    }
}
