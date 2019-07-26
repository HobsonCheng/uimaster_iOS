//
//  VCController.swift
//  UIMaseter
//
//  Created by gongcz on 2018/4/16.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

@objc protocol VCControllerPtc {
    /// VC真正被Pop后的回调方法
    @objc optional func vcWillPop()

    /**
     *  由于我们自己管理VC Stack的原因，并在iOS6和iOS7上进行全局右滑返回，这个右滑返回是做在App的Window上的，所以对于一些
     *  View如果不希望触发右滑返回，需要实现该方法来进行屏蔽
     *
     *  当触发右滑时，会调用该方法，传入点击的view对象，传入的View也可能是屏蔽右滑的View的子View
     *  该方法需要判断该view是否在不需要右滑的View中，然后进行返回，下面是该方法的一个例子
     *
     *  func viewCanRight(view:UIView) {
     *      if view.isDescendantOfView:listView {
     *          return false
     *      }
     *      else if view.isKindOfClass:InfoButton.class {
     *          return flase
     *      }
     *  }
     *
     */
    ///
    /// - Parameter view: 当触发右滑时，会调用该方法，传入点击的view对象
    /// - Returns: 返回点击的View是否接受右滑返回
    @objc optional func ignoreGesture(_ view: UIView) -> Bool

    /// 当VC右滑返回或点击返回按钮时，会先调用canGoBack方法来确认VC是否能够返回
    ///
    /// - Returns: 返回当前 VC 是否能进行返回操作
    @objc optional func canGoBack() -> Bool

    /// 如果canGoBack返回No时，会调用 VC 的 doGoBack 进行处理，通常行为是进行弹框提示
    @objc optional func doGoBack()
}

// MARK: -
private enum VCStyle {
    static let maxRightGestureTouchWidth: CGFloat = 64
    static let maxValidGestureMoveWidth: CGFloat = 20
}

// MARK: -
class VCController: NSObject, UIGestureRecognizerDelegate {
    /// VC堆栈
    fileprivate var arrayVCSubs: [UIViewController] = []
    /// 根View的Controller
    var rootBaseVController: BaseNameVC?
    /// 根View
    var rootBaseView: UIView?
    /// 视野宽度
    var spotWidth: CGFloat?
    /// 是否在滑动中
    var isPanning = false
    /// 上一次滑动的坐标
    var lastGuestPoint: CGPoint?
    /// 向右滑动的距离
    var rightMoveLength: CGFloat?
    /// 遮罩
    var maskView: UIView?
    /// 单例
    private static let singleton = VCController()

    static var shared: VCController {
        return singleton
    }

    override init() {
        super.init()
        let rootBaseVC = BaseNameVC()
        rootBaseVC.vcName = "rootBaseVC"
        rootBaseVC.view.frame = CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH)
        rootBaseVC.view.backgroundColor = .white
        self.rootBaseVController = rootBaseVC
        self.rootBaseView = rootBaseVC.view
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let window = appDelegate.window
        window?.addSubview(rootBaseView!)
        window?.rootViewController = rootBaseVC

        let maskView = UIView(frame: kScreenFrame)
        maskView.backgroundColor = .clear
        self.maskView = maskView
        /// 视野范围默认设置为屏幕size(!!!所有的VCSize的宽度必须保持和spotWidth保持一致，否者无法处理动画效果)
        self.spotWidth = kScreenW
    }

    /// 切换项目后重新设置窗口的rootVC
    func reTrigger() {
        let rootBaseVC = BaseNameVC()
        rootBaseVC.vcName = "rootBaseVC"
        rootBaseVC.view.frame = CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH)
        rootBaseVC.view.backgroundColor = .white
        self.rootBaseVController = rootBaseVC
        self.rootBaseView = rootBaseVC.view

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let window = appDelegate.window
        window?.addSubview(rootBaseView!)
        window?.rootViewController = rootBaseVC
    }

    /// 还原
    func goOriginal() {
        let frontVC = VCController.shared.arrayVCSubs.last
        var backVC: BaseNameVC?
        let vcCount = VCController.shared.arrayVCSubs.count
        if vcCount >= 2 {
            backVC = VCController.shared.arrayVCSubs[vcCount - 2] as? BaseNameVC
        }

        UIApplication.shared.beginIgnoringInteractionEvents()
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                backVC?.view.setViewX(-VCController.shared.spotWidth! / 3)
                frontVC?.view.setViewX(0)
            }) { _ in
            backVC?.view.setViewX(0)
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }

    /// 注意需要横划操作的控件需要在这里添加例外
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let translatedPoint: CGPoint = touch.location(in: gestureRecognizer.view)
        if translatedPoint.x > VCStyle.maxRightGestureTouchWidth {
            return false
        }
        //        guard let _ = touch.view else {
        //            return false
        //        }
        //        let topVC: BaseNameVC? = VCController.getTopVC()
        // TODO: 没用到的类
        //        if ((touch.view!).isKind(of: NSClassFromString("Switch")!)) {
        //            return false
        //        }
        //        else if (touch.view!.superview?.isKind(of: NSClassFromString("FilterCheckSlider")) ) {
        //            return false
        //        } else if (touch.view?.superview is NSClassFromString("FilterRedioSlider")) {
        //            return false
        //        } else
        //        if topVC != nil && (topVC?.responds(to: NSSelectorFromString("ignoreGesture:")))! {
        ////            return topVC!.ignoreGesture(touch.view)
        //        }
        return true
    }

    @objc func handlePan(from recognizer: UIPanGestureRecognizer?) {
        let vcCount = VCController.shared.arrayVCSubs.count
        // 只有2个或以下的VC时不允许进行右滑操作,因为有emptyVC所以加一个
        if vcCount < 2 {
            return
        }
        let frontVC = VCController.shared.arrayVCSubs.last as? BaseNameVC
        if !(frontVC?.canRightPan ?? true) {
            return
        }

        let backVC: BaseNameVC? = VCController.shared.arrayVCSubs[vcCount - 2] as? BaseNameVC
        //        if !isPaning! {
        //            // 初始化backVC的状态
        //        }

        if !isPanning {
            spotWidth = backVC?.view.frame.size.width
            lastGuestPoint = CGPoint(x: 0, y: 0)
            rightMoveLength = 0
            backVC?.view.setViewX(-(spotWidth! / 3))
            VCController.shared.maskView?.removeFromSuperview()
            backVC?.view.addSubview(VCController.shared.maskView!)
            //        [[[VCController mainVCC] rootBaseView] insertSubview:[backVC view] belowSubview:[frontVC view]];
        }

        // 手势进行中
        if recognizer?.state == .began || recognizer?.state == .changed {
            if recognizer?.state == .began {
                isPanning = true
            }
            var translatedPoint: CGPoint = (recognizer?.translation(in: recognizer?.view))!
            if translatedPoint.x < 0 {
                translatedPoint.x = 0
            } else if translatedPoint.x > spotWidth! {
                translatedPoint.x = spotWidth ?? 0
            }

            if translatedPoint.x >= lastGuestPoint!.x { // 向右滑动
                if translatedPoint.x >= lastGuestPoint!.x { // 相同方向
                    rightMoveLength! += translatedPoint.x - lastGuestPoint!.x
                } else { // 不同方向
                    rightMoveLength! = translatedPoint.x - lastGuestPoint!.x
                }
            } else { // 向左滑动
                if rightMoveLength! <= 0 { // 相同方向
                    rightMoveLength! += translatedPoint.x - lastGuestPoint!.x
                } else { // 不同方向
                    rightMoveLength = translatedPoint.x - lastGuestPoint!.x
                }
            }

            lastGuestPoint = translatedPoint

            // 调整frontVC和BackVC的位置
            let frontPosNew: CGFloat = translatedPoint.x
            let backPosNew: CGFloat = (-spotWidth! + translatedPoint.x) / 3
            backVC?.view.setViewX(backPosNew)
            frontVC?.view.setViewX(frontPosNew)
        }

        if recognizer?.state == .ended || recognizer?.state == .cancelled || recognizer?.state == .failed {
            isPanning = false
            self.maskView?.removeFromSuperview()
            let position = recognizer?.translation(in: backVC?.view)
            // 当向右滑动超过一定距离的时候
            if let velocity = recognizer?.velocity(in: backVC?.view) {
                if velocity.x > 720 || (position?.x)! >= spotWidth! / 4 {
                    if (frontVC?.conforms(to: VCControllerPtc.self))! { // 是否额外控制了返回
                        let frontVCTmp: BaseNameVC = frontVC!
                        var isDoNormal: Bool = true
                        // 是否走普通返回模式
                        if frontVCTmp.responds(to: NSSelectorFromString("canGoBack")) {
                            let canGoBack: Bool = frontVCTmp.canGoBack()
                            if !canGoBack {
                                isDoNormal = false
                                self.goOriginal()
                                // 是否
                                if frontVCTmp.responds(to: NSSelectorFromString("doGoBack")) {
                                    frontVCTmp.doGoBack()
                                }
                            }
                        }

                        // 如果是走普通模式
                        if isDoNormal {
                            // 动画
                            UIApplication.shared.beginIgnoringInteractionEvents()
                            VCController.shared.removeVC(frontVC)
                            UIView.animate(
                                withDuration: 0.05,
                                delay: 0,
                                options: .curveLinear,
                                animations: { () -> Void in
                                    frontVC?.view.setViewX(self.spotWidth!)
                                    backVC?.view.setViewX(0)
                                    for childVC in frontVC?.childViewControllers ?? [] {
                                        childVC.viewWillDisappear(true)
                                    }
                                    for childVC in backVC?.childViewControllers ?? [] {
                                        childVC.viewWillAppear(true)
                                    }
                                },
                                completion: { (_ finished: Bool) -> Void in
                                    frontVC?.view.removeFromSuperview()
                                    backVC?.viewWillAppear(true)
                                    backVC?.viewDidAppear(true)
                                    for childVC in frontVC?.childViewControllers ?? [] {
                                        childVC.viewDidDisappear(true)
                                    }
                                    for childVC in backVC?.childViewControllers ?? [] {
                                        childVC.viewDidAppear(true)
                                    }
                                    (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                                    // 恢复VC的可用性
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                }
                            )
                            // 处理额外的事情
                            frontVCTmp.doGoBack()
                        }
                    } else {
                        // 动画
                        UIApplication.shared.beginIgnoringInteractionEvents()
                        self.removeVC(frontVC)
                        UIView.animate(
                            withDuration: 0.15,
                            delay: 0,
                            options: .curveEaseOut,
                            animations: { () -> Void in
                                frontVC?.view.setViewX(self.spotWidth!)
                                backVC?.view.setViewX(0)
                            },
                            completion: { (_ finished: Bool) -> Void in
                                frontVC?.view.removeFromSuperview()
                                backVC?.viewWillAppear(true)
                                backVC?.viewDidAppear(true)
                                (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                                // 恢复VC的可用性
                                UIApplication.shared.endIgnoringInteractionEvents()
                            }
                        )
                    }
                } else {
                    self.goOriginal()
                }
            }
            rightMoveLength = 0
            lastGuestPoint = .zero
            kCurrentTabbarVC.viewWillAppear(true)
        }
    }

    // 通知VC事件并从栈里删除VC
    func removeVC(_ removeVC: BaseNameVC?) {
        if let aVC = removeVC {
            removeVC?.vcWillPop()
            if let elementIndex = self.arrayVCSubs.index(of: aVC) {
                self.arrayVCSubs.remove(at: elementIndex)
            }
        }
    }

    // 获取节点
    class func getVC(_ vcName: String?) -> BaseNameVC? {
        // 获取window的子VC
        if !VCController.shared.arrayVCSubs.isEmpty {
            let subsCount: Int = VCController.shared.arrayVCSubs.count
            // 从上往下逐个遍历
            for index in 0..<subsCount {
                let viewController = VCController.shared.arrayVCSubs[subsCount - index - 1]
                // 只有BaseNameVC才支持此功能
                if (viewController is BaseNameVC) == true {
                    let baseNameVC = viewController as? BaseNameVC
                    // 名称相同
                    if baseNameVC?.vcName == vcName {
                        return baseNameVC
                    }
                }
            }
        }
        return nil
    }

    // 获取最下层的
    class func getTopVC() -> BaseNameVC? {
        // 获取window的子VC
        if !VCController.shared.arrayVCSubs.isEmpty {
            let subsCount = VCController.shared.arrayVCSubs.count
            if subsCount > 0 {
                let baseNameVC = VCController.shared.arrayVCSubs[subsCount - 1] as? BaseNameVC
                return baseNameVC
            }
        }
        return nil
    }

    // 获取节点的下一层节点
    class func getPreviousWith(_ baseNameVC: BaseNameVC?) -> BaseNameVC? {
        if baseNameVC == nil {
            return nil
        }
        // 获取window的子VC
        if !VCController.shared.arrayVCSubs.isEmpty {
            let subsCount: Int = VCController.shared.arrayVCSubs.count
            // 从上往下逐个遍历
            for index in 0..<subsCount {
                let viewController = VCController.shared.arrayVCSubs[subsCount - index - 1]
                // 只有BaseNameVC才支持此功能
                if (viewController is BaseNameVC) == true {
                    let nameVC = viewController as? BaseNameVC
                    // 名称相同
                    if nameVC == baseNameVC {
                        if index + 1 < subsCount {
                            return VCController.shared.arrayVCSubs[subsCount - index - 2] as? BaseNameVC
                        }
                    }
                }
            }
        }
        return nil
    }

    // 获取最下层的
    class func getHomeVC() -> BaseNameVC? {
        // 获取window的子VC
        if !VCController.shared.arrayVCSubs.isEmpty {
            let subsCount: Int = VCController.shared.arrayVCSubs.count
            if subsCount > 0 {
                let baseNameVC = VCController.shared.arrayVCSubs[0] as? BaseNameVC
                return baseNameVC
            }
        }
        return nil
    }

    // 压入节点
    class func push(_ baseNameVC: BaseNameVC?, with animation: VCAnimationPtc?) {
        dispatch_async_safely_to_main_queue {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                HUDUtil.stopLoadingHUD(callback: nil)
            })
            //        let getname = baseNameVC?.vcName
            //        let gettopname = VCController.getTopVC()?.vcName
            //            if ([getname isEqualToString:gettopname]) {
            //                return;
            //            }
            // 加载View
            //        if baseNameVC?.isViewLoaded == false {
            //            let _ = baseNameVC?.view
            //        }
            // 注册手势
            if baseNameVC?.canRightPan ?? true {
                let gesture = UIPanGestureRecognizer(target: VCController.shared, action: #selector(handlePan(from:)))
                gesture.delegate = VCController.shared
                gesture.maximumNumberOfTouches = 1
                baseNameVC?.view.addGestureRecognizer(gesture)
            }
            // 往window中添加子VC
            if !VCController.shared.arrayVCSubs.isEmpty {
                let subsCount: Int = VCController.shared.arrayVCSubs.count
                if subsCount > 0 {
                    // 当前最前面的VC
                    let baseNameVCTop = VCController.shared.arrayVCSubs[subsCount - 1] as? BaseNameVC
                    let vcArr = baseNameVCTop?.childViewControllers ?? [UIViewController]()
                    if animation != nil {
                        baseNameVCTop?.viewWillDisappear(true)
                        for childVc in vcArr {
                            childVc.viewWillDisappear(true)
                        }
                        if baseNameVC != nil {
                            if let aVC = baseNameVC {
                                VCController.shared.arrayVCSubs.append(aVC)
                            }
                        }
                        // 设置新的根节点
                        if let aView = baseNameVC?.view {
                            VCController.shared.rootBaseView?.addSubview(aView)
                        }
                        let originFrame: CGRect? = baseNameVCTop?.view.frame
                        // 动画
                        UIApplication.shared.beginIgnoringInteractionEvents()
                        // 声明周期
                        animation?.push(fromTopVC: baseNameVCTop!, toArrive: baseNameVC!, with: { (_ finished: Bool) -> Void in
                            baseNameVCTop?.view.frame = originFrame!
                            //                                       [[baseNameVCTop view] removeFromSuperview];
                            baseNameVCTop?.viewDidDisappear(true)
                            for childVc in vcArr {
                                childVc.viewDidDisappear(true)
                            }
                            (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                            // 恢复VC的可用性
                            UIApplication.shared.endIgnoringInteractionEvents()
                        })
                    } else {
                        baseNameVCTop?.viewWillDisappear(false)
                        if let aVC = baseNameVC {
                            VCController.shared.arrayVCSubs.append(aVC)
                        }
                        // 设置新的根节点
                        baseNameVC?.view.setViewX(0)
                        if let aView = baseNameVC?.view {
                            VCController.shared.rootBaseView?.addSubview(aView)
                        }
                        // 移除上一个VC
                        //                [[baseNameVCTop view] removeFromSuperview];
                        baseNameVCTop?.viewDidDisappear(false)
                        for childVc in vcArr {
                            childVc.viewWillDisappear(true)
                            childVc.viewDidDisappear(true)
                        }
                        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                    }
                }
            } else {
                // 添加到队列中
                let arrayVCSubsNew = [BaseNameVC]()
                VCController.shared.arrayVCSubs = arrayVCSubsNew
                if let aVC = baseNameVC {
                    VCController.shared.arrayVCSubs.append(aVC)
                }
                // 设置根VC
                baseNameVC?.view.setViewX(0)
                if let aView = baseNameVC?.view {
                    VCController.shared.rootBaseView?.addSubview(aView)
                }
                (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }

    // 弹出节点
    class func pop(with animation: VCAnimationPtc?) {
        if !VCController.shared.arrayVCSubs.isEmpty {
            let subsCount = VCController.shared.arrayVCSubs.count
            if subsCount > 1 {
                // 获取顶层的VC
                let baseNameVCTop = VCController.shared.arrayVCSubs[subsCount - 1] as? BaseNameVC
                // 下一个VC
                let baseNameVCTopNew = VCController.shared.arrayVCSubs[subsCount - 2] as? BaseNameVC
                let vcArr = baseNameVCTopNew?.childViewControllers ?? [UIViewController]()
                if animation != nil {
                    VCController.shared.removeVC(baseNameVCTop)
                    //                [[[VCController mainVCC] rootBaseView] addSubview:[baseNameVCTopNew view]];
                    // 动画
                    UIApplication.shared.beginIgnoringInteractionEvents()
                    animation?.pop(fromTopVC: baseNameVCTop!, toArrive: baseNameVCTopNew!, with: { (_ finished: Bool) -> Void in
                        baseNameVCTop?.view.removeFromSuperview()
                        baseNameVCTopNew?.viewWillAppear(true)
                        baseNameVCTopNew?.viewDidAppear(true)
                        if let vcArr = baseNameVCTopNew?.childViewControllers {
                            for childVc in vcArr {
                                childVc.viewWillAppear(true)
                                childVc.viewDidAppear(true)
                            }
                        }
                        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                        // 恢复VC的可用性
                        UIApplication.shared.endIgnoringInteractionEvents()
                    })
                } else {
                    // 获取顶层的VC
                    let baseNameVCTop = VCController.shared.arrayVCSubs[subsCount - 1] as? BaseNameVC
                    // 从逻辑数组中删除VC
                    VCController.shared.removeVC(baseNameVCTop)
                    baseNameVCTop?.view.removeFromSuperview()
                    baseNameVCTopNew?.view.setViewX(0)
                    //                [[[VCController mainVCC] rootBaseView] addSubview:[baseNameVCTopNew view]];
                    baseNameVCTopNew?.viewWillAppear(false)
                    baseNameVCTopNew?.viewDidAppear(false)
                    for childVc in vcArr {
                        childVc.viewWillAppear(false)
                        childVc.viewDidAppear(false)
                    }
                    (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                }
//                return true
            }
        }
//        return false
    }

    // 弹出节点
    class func pop(toVC vcName: String?, with animation: VCAnimationPtc?) -> Bool {
        if !VCController.shared.arrayVCSubs.isEmpty {
            let subsCount = VCController.shared.arrayVCSubs.count
            // 从上往下逐个遍历
            var index = subsCount - 1
            while index >= 0 {
                guard let baseNameVCTopNew = VCController.shared.arrayVCSubs[index] as? BaseNameVC else {
                    return false
                }
                let vcArr = baseNameVCTopNew.childViewControllers
                if baseNameVCTopNew.vcName == vcName {
                    // pop到当前VC，不做任何动作
                    if index == subsCount - 1 {
                        return true
                    }
                    // 获取顶层的VC
                    //                    let baseNameVCTop = VCController.shared.arrayVCSubs[subsCount - 1] as? BaseNameVC
                    if animation != nil {
                        // 最上层节点
                        guard let baseNameVCTop = VCController.shared.arrayVCSubs[subsCount - 1] as? BaseNameVC else {
                            return false
                        }
                        // 从逻辑数据中删除目标节点之前的节点和其对应的maskView
                        var removeIndex = subsCount - 2
                        while removeIndex > index {
                            guard let baseNameVCTmp = VCController.shared.arrayVCSubs[removeIndex] as? BaseNameVC else {
                                return false
                            }
                            VCController.shared.removeVC(baseNameVCTmp)
                            baseNameVCTmp.view.removeFromSuperview()
                            removeIndex -= 1
                        }
                        // 添加VC
                        VCController.shared.removeVC(baseNameVCTop)
                        //                    [[[VCController mainVCC] rootBaseView] addSubview:[baseNameVCTopNew view]];
                        baseNameVCTopNew.viewWillAppear(true)
                        for childVc in vcArr {
                            childVc.viewWillAppear(true)
                        }
                        // 动画
                        UIApplication.shared.beginIgnoringInteractionEvents()
                        animation?.pop(fromTopVC: baseNameVCTop, toArrive: baseNameVCTopNew, with: { (_ finished: Bool) -> Void in
                            baseNameVCTop.view.removeFromSuperview()
                            baseNameVCTopNew.viewDidAppear(true)
                            for childVc in vcArr {
                                childVc.viewDidAppear(true)
                            }
                            (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                            // 恢复VC的可用性
                            UIApplication.shared.endIgnoringInteractionEvents()
                        })
                    } else {
                        baseNameVCTopNew.viewWillAppear(false)
                        // 循环删除目标节点之前的节点
                        var removeIndex = subsCount - 1
                        while removeIndex > index {
                            let baseNameVCTmp = VCController.shared.arrayVCSubs[removeIndex] as? BaseNameVC
                            // 从逻辑数据中删除
                            VCController.shared.removeVC(baseNameVCTmp)
                            // 当前的根节点
                            baseNameVCTmp?.view.removeFromSuperview()
                            removeIndex -= 1
                        }
                        // 设置新的根节点
                        baseNameVCTopNew.view.setViewX(0)
                        //                    [[[VCController mainVCC] rootBaseView] addSubview:[baseNameVCTopNew view]];
                        baseNameVCTopNew.viewDidAppear(false)
                        for childVc in vcArr {
                            childVc.viewWillAppear(false)
                            childVc.viewDidAppear(false)
                        }
                        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                    }
                    return true
                }
                index -= 1
            }
        }
        return false
    }

    // 弹出节点然后压入节点
    class func popThenPush(_ baseNameVC: BaseNameVC?, with animation: VCAnimationPtc?) -> Bool {
        // 加载View
        //        if baseNameVC?.isViewLoaded == false {
        //            let _ = baseNameVC?.view
        //        }
        // 注册手势
        if (baseNameVC?.canRightPan)! {
            let gesture = UIPanGestureRecognizer(target: VCController.shared, action: #selector(handlePan(from:)))
            gesture.delegate = VCController.shared
            gesture.maximumNumberOfTouches = 1
            baseNameVC?.view.addGestureRecognizer(gesture)
        }
        if !VCController.shared.arrayVCSubs.isEmpty {
            let subsCount = VCController.shared.arrayVCSubs.count
            if subsCount > 1 {
                // 获取顶层的VC
                let baseNameVCTop = VCController.shared.arrayVCSubs[subsCount - 1] as? BaseNameVC
                if animation != nil {
                    VCController.shared.removeVC(baseNameVCTop)
                    // 设置新的根节点
                    if let aVC = baseNameVC {
                        VCController.shared.arrayVCSubs.append(aVC)
                    }
                    if let aView = baseNameVC?.view {
                        VCController.shared.rootBaseView?.addSubview(aView)
                    }
                    // 动画
                    UIApplication.shared.beginIgnoringInteractionEvents()
                    animation?.push(fromTopVC: baseNameVCTop!, toArrive: baseNameVC!, with: { (_ finished: Bool) -> Void in
                        baseNameVCTop?.view.removeFromSuperview()
                        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                        // 恢复VC的可用性
                        UIApplication.shared.endIgnoringInteractionEvents()
                    })
                } else {
                    // 从逻辑数据中删除
                    VCController.shared.removeVC(baseNameVCTop)
                    // 设置新的根节点
                    if let aVC = baseNameVC {
                        VCController.shared.arrayVCSubs.append(aVC)
                    }
                    if let aView = baseNameVC?.view {
                        VCController.shared.rootBaseView?.addSubview(aView)
                    }
                    baseNameVCTop?.view.removeFromSuperview()
                    (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                }
                return true
            } else if subsCount == 1 {
                VCController.push(baseNameVC, with: animation)
            } else {
                if let aVC = baseNameVC {
                    VCController.shared.arrayVCSubs.append(aVC)
                }
                if let aView = baseNameVC?.view {
                    VCController.shared.rootBaseView?.addSubview(aView)
                }
                (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
            }
        } else {
            // 添加到队列中
            let arrayVCSubsNew = [UIViewController]()
            VCController.shared.arrayVCSubs = arrayVCSubsNew
            if let aVC = baseNameVC {
                VCController.shared.arrayVCSubs.append(aVC)
            }
            // 设置根VC
            baseNameVC?.view.setViewX(0)
            if let aView = baseNameVC?.view {
                VCController.shared.rootBaseView?.addSubview(aView)
            }
            (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
        }
        return false
    }

    // 弹出节点然后压入节点
    class func pop(toVC vcName: String?, thenPush baseNameVC: BaseNameVC?, with animation: VCAnimationPtc?) -> Bool {
        // 加载View
        //        if baseNameVC?.isViewLoaded == false {
        //            let _ = baseNameVC?.view
        //        }
        guard let pushVC = baseNameVC else {
            return false
        }
        // 注册手势
        if pushVC.canRightPan {
            let gesture = UIPanGestureRecognizer(target: VCController.shared, action: #selector(handlePan(from:)))
            gesture.delegate = VCController.shared
            gesture.maximumNumberOfTouches = 1
            pushVC.view.addGestureRecognizer(gesture)
        }
        if !VCController.shared.arrayVCSubs.isEmpty {
            let subsCount: Int = VCController.shared.arrayVCSubs.count
            // 从上往下逐个遍历
            var index = subsCount - 1
            while index >= 0 {
                let baseNameVCBackNew = VCController.shared.arrayVCSubs[index] as? BaseNameVC
                // 名称相同
                if baseNameVCBackNew?.vcName == vcName {
                    if index == subsCount - 1 {
                        // 跳转到当前VC，则直接Push即可
                        self.push(pushVC, with: animation)
                        return true
                    }
                    // 最上层节点
                    guard let baseNameVCTop = VCController.shared.arrayVCSubs[subsCount - 1] as? BaseNameVC else {
                        return false
                    }
                    if animation != nil {
                        // 从逻辑数据中删除目标节点之前的节点
                        var removeIndex = subsCount - 2
                        while removeIndex > index {
                            guard let baseNameVCTmp = VCController.shared.arrayVCSubs[removeIndex] as? BaseNameVC else {
                                return false
                            }
                            VCController.shared.removeVC(baseNameVCTmp)
                            baseNameVCTmp.view.removeFromSuperview()
                            removeIndex -= 1
                        }
                        VCController.shared.removeVC(baseNameVCTop)
                        // 将新界面入栈
                        VCController.shared.arrayVCSubs.append(pushVC)
                        if let aView = pushVC.view {
                            VCController.shared.rootBaseView?.addSubview(aView)
                        }
                        // 动画
                        UIApplication.shared.beginIgnoringInteractionEvents()
                        animation?.push(fromTopVC: baseNameVCTop, toArrive: pushVC, with: { (_ finished: Bool) -> Void in
                            baseNameVCTop.view.removeFromSuperview()
                            (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                            // 恢复VC的可用性
                            UIApplication.shared.endIgnoringInteractionEvents()
                        })
                    } else {
                        // 循环删除目标节点之前的节点
                        var removeIndex = subsCount - 1
                        while removeIndex > index {
                            let baseNameVCTmp = VCController.shared.arrayVCSubs[removeIndex] as? BaseNameVC
                            VCController.shared.removeVC(baseNameVCTmp)
                            baseNameVCTmp?.view.removeFromSuperview()
                            removeIndex -= 1
                        }
                        // 删除当前首节点
                        VCController.shared.removeVC(baseNameVCTop)
                        baseNameVCTop.view.removeFromSuperview()
                        // 将Push进来的VC Add到view上
                        baseNameVC?.view.setViewX(0)
                        if let aVC = baseNameVC {
                            VCController.shared.arrayVCSubs.append(aVC)
                        }
                        if let aView = baseNameVC?.view {
                            VCController.shared.rootBaseView?.addSubview(aView)
                        }
                        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                    }
                    // 已完成，跳出循环
                    return true
                }
                index -= 1
            }
        } else {
            // 添加到队列中
            let arrayVCSubsNew = [UIViewController]()
            VCController.shared.arrayVCSubs = arrayVCSubsNew
            if let aVC = baseNameVC {
                VCController.shared.arrayVCSubs.append(aVC)
            }
            // 设置根VC
            baseNameVC?.view.setViewX(0)
            if let aView = baseNameVC?.view {
                VCController.shared.rootBaseView?.addSubview(aView)
            }
            (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
        }
        return false
    }

    static func popAllThenPush(newVC: BaseNameVC?, with animation: VCAnimationPtc?) {
        VCController.shared.rootBaseView?.removeAllSubviews()
        VCController.shared.arrayVCSubs.removeAll()
        VCController.push(newVC, with: animation)
    }

    // 弹出到最下层的VC然后压入节点
    class func popToHomeVC(with animation: VCAnimationPtc?) -> Bool {
        return VCController.pop(toVC: VCController.getHomeVC()?.vcName, with: animation)
    }

    func removeAllVC() {
        self.arrayVCSubs.removeAll()
    }

    // 弹出到最下层的VC然后压入节点
    class func pop(toHomeVCThenPush baseNameVC: BaseNameVC?, with animation: VCAnimationPtc?) -> Bool {
        return VCController.pop(toVC: VCController.getHomeVC()?.vcName, thenPush: baseNameVC, with: animation)
    }
}
