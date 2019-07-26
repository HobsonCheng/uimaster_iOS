//
//  BaseModuleView.swift
//  UIDS
//
//  Created by one2much on 2018/1/22.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

protocol ModuleRefreshDelegate: AnyObject {
    /// 是否有占整页的table模块
    func setfullPageTableModule(table: BaseTableView)
    /// 模块布局，主要是高度刷新完毕
    func moduleLayoutDidRefresh()
    /// 模块数据刷新完毕
    ///
    /// - Parameter noMore: 有加载更多的传true表示没有更多数据  传nil表示没有加载更多
    func moduleDataDidRefresh(noMore: Bool)
    /// 处理导航栏的按钮
    ///
    /// - Parameters:
    ///   - isHidden: 按钮是否可见
    ///   - position: 导航栏的哪个按钮
    ///   - params: 按钮的参数
    func handleNavibarItems(isHidden: Bool, position: NavibarPositionType, params: [String: Any]?)
    /// 如果模块是VC，那么需要调用此方法把模块装载到父VC上
    ///
    /// - Parameter with: 子VC
    func assemble(with subVC: UIViewController)
}
protocol PageModuleAble: AnyObject, JsonCacheAble {
    ///模块代号（模块儿需要单独请求数据时设置这两个值moduleCode,pageKey）
    var moduleCode: String? { get set }
    ///特殊模块需要pagekey
    var pageKey: String? { get set }
    /// 样式字典
    var styleDic: [String: Any]? { get set }
    /// 模块代理
    var moduleDelegate: ModuleRefreshDelegate? { get set }
    ///上间距
    var marginTop: CGFloat? { get set }
    /// 下间距
    var marginBottom: CGFloat? { get set }
    /// 模块参数
    var moduleParams: [String: Any]? { get set }
    /// 刷新数据
    func reloadViewData()
    /// 加载更多
    func loadMoreData()
}
//// 运行时添加属性
private var keyModel: Void?
private var keyModuleCode: Void?
private var keyPageKey: Void?
private var keyCheckRefreshCB: Void?
private var keyReloadMainScrollCB: Void?
private var keyMarginTop: Void?
private var keyMarginBottom: Void?
private var keyModuleRefresh: Void?
private var keystyleDic: Void?
private var keyDelegate: Void?
private var keymoduleParams: Void?

extension PageModuleAble {
    var moduleParams: [String: Any]? {
        set {
            objc_setAssociatedObject(self, &keymoduleParams, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &keymoduleParams) as? [String: Any]
        }
    }
    var moduleCode: String? {
        set {
            objc_setAssociatedObject(self, &keyModuleCode, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &keyModuleCode) as? String
        }
    }
    var pageKey: String? {
        set {
            objc_setAssociatedObject(self, &keyPageKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &keyPageKey) as? String
        }
    }

    var marginBottom: CGFloat? {
        set {
            objc_setAssociatedObject(self, &keyMarginBottom, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &keyMarginBottom) as? CGFloat
        }
    }

    var marginTop: CGFloat? {
        set {
            objc_setAssociatedObject(self, &keyMarginTop, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &keyMarginTop) as? CGFloat
        }
    }

    func reloadViewData() {
        self.moduleDelegate?.moduleDataDidRefresh(noMore: true)
    }
    func loadMoreData() {
    }
}

//protocol PageModuleAble: class {
//    ///模块数据模型
//    var model: BaseData? { get set }
//    ///模块代号（模块儿需要单独请求数据时设置这两个值moduleCode,pageKey）
//    var moduleCode: String? { get set }
//    ///特殊模块需要pagekey
//    var pageKey: String? { get set }
//    ///上下间距
//    var marginTop: CGFloat? { get set }
//    var marginBottom: CGFloat? { get set }
//    var styleDic: [String: Any]? { set get}
//    var delegate: ModuleRefreshDelegate?{get set}
//    ///数据刷新完成之后的回调
//    var checkRefreshCB: CheckRefreshCallBack? { get set }
//    ///UI计算完之后的回调
//    var reloadMainScrollCB: VCRefreshCallBack? { get set }
//
//    var viewWillAppearCB: ViewWillAppearCB? { get set }
//    /// 下拉刷新 上拉加载更多
//    ///
//    /// - Parameter isLoadMore: 是否是加载更多，false表示刷新，true表示加载更多
//    func reloadViewData()
//    ///相应点击事件
//    func responseAction(_ action :Int)
//}
//

//
//extension BaseModuleProtocol {
//
//    var delegate: ModuleRefreshDelegate? {
//        set {
//            objc_setAssociatedObject(self, &keyModel, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//        get {
//            return objc_getAssociatedObject(self, &keyModel) as? ModuleRefreshDelegate
//        }
//    }
//    var styleDic: [String: Any]? {
//        set {
//            objc_setAssociatedObject(self, &keystyleDic, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//        get {
//            return objc_getAssociatedObject(self, &keystyleDic) as? [String: Any]
//        }
//    }
//    var model: BaseData? {
//        set {
//            objc_setAssociatedObject(self, &keyModuleRefresh, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//        get {
//            return objc_getAssociatedObject(self, &keyModuleRefresh) as? BaseData
//        }
//    }
//    var moduleCode: String? {
//        set {
//            objc_setAssociatedObject(self, &keyModuleCode, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
//        }
//        get {
//            return objc_getAssociatedObject(self, &keyModuleCode) as? String
//        }
//    }
//    var pageKey: String? {
//        set {
//            objc_setAssociatedObject(self, &keyPageKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
//        }
//        get {
//            return objc_getAssociatedObject(self, &keyPageKey) as? String
//        }
//    }
//
//    var marginBottom: CGFloat? {
//        set {
//            objc_setAssociatedObject(self, &keyMarginBottom, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
//        }
//        get {
//            return objc_getAssociatedObject(self, &keyMarginBottom) as? CGFloat
//        }
//    }
//
//    var marginTop: CGFloat? {
//        set {
//            objc_setAssociatedObject(self, &keyMarginTop, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
//        }
//        get {
//            return objc_getAssociatedObject(self, &keyMarginTop) as? CGFloat
//        }
//    }
//
//    var checkRefreshCB: VCRefreshCallBack? {
//        set {
//            objc_setAssociatedObject(self, &keyCheckRefreshCB, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
//        }
//        get {
//            return objc_getAssociatedObject(self, &keyCheckRefreshCB) as? VCRefreshCallBack
//        }
//    }
//    var viewWillAppearCB: ViewWillAppearCB? {
//        set {
//            objc_setAssociatedObject(self, &keyViewWillAppearCB, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
//        }
//        get {
//            return objc_getAssociatedObject(self, &keyViewWillAppearCB) as? ViewWillAppearCB
//        }
//    }
//    var reloadMainScrollCB: CheckRefreshCallBack? {
//        set {
//            objc_setAssociatedObject(self, &keyReloadMainScrollCB, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
//        }
//        get {
//            return objc_getAssociatedObject(self, &keyReloadMainScrollCB) as? CheckRefreshCallBack
//        }
//    }
//
//    func reloadViewData() {
//        if let safeCB = checkRefreshCB {
//            safeCB()
//        }
//    }
//
//    func responseAction(_ action: Int) {
//
//    }
//}

private var keyEvent: Void?

extension UIButton {
    ///事件
    var event: EventsData? {
        set {
            objc_setAssociatedObject(self, &keyEvent, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &keyEvent) as? EventsData
        }
    }
}
