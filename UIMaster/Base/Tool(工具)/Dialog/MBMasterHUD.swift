//
//  MBMasterHUD.swift
//  UIMaseter
//
//  Created by gongcz on 2018/4/20.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Foundation
import MBProgressHUD

let MBProgressMsgLoading: String = "正在加载..."
let MBProgressMsgError: String = "加载失败"
let MBProgressMsgSuccessful: String = "加载成功"
let MBProgressMsgNoMoreData: String = "没有更多数据了"
let MBProgressMsgTimeInterval: TimeInterval = 1

let fontSize = CGFloat(15.0)
let opacityDefault = CGFloat(0.85)

/// 提示类型
enum MBProgressType {
    case successful
    case error
    case warning
    case info
}

// MARK: - 设置HUD
class MBMasterHUD: MBProgressHUD {
    /// 文字提示
    class func toast(title: String) {
            self.showAfterSecond(title: title, view: kWindow, afterSecond: MBProgressMsgTimeInterval)
    }

    /// 成功提示
    class func showSuccess(title: String) {
            self.showHUD(title: title, view: kWindow, afterSecond: MBProgressMsgTimeInterval, msgType: .successful)
    }

    /// 失败提示
    class func showFail(title: String) {
            self.showHUD(title: title, view: kWindow, afterSecond: MBProgressMsgTimeInterval, msgType: .error)
    }

    /// 警告提示
    class func showInfo(title: String) {
            self.showHUD(title: title, view: kWindow, afterSecond: MBProgressMsgTimeInterval, msgType: .info)
    }
    /// 显示加载 需手动隐藏
    class func showLoading(title: String) {
            self.showHUDTo(view: kWindow, title: title)
    }

    /// 隐藏提示
    class func hide(then callBack:() -> Void) {
        MBProgressHUD.hide(for: kWindow, animated: true)
        callBack()
    }

    /// 隐藏提示根据父视图
    class func hide(on view: UIView?, then callBack:(() -> Void)?) {
        if let view = view { MBProgressHUD.hide(for: view, animated: true) }
        if let sefaCB = callBack {
            sefaCB()
        }
    }

    /// 添加到一个视图，并选择是否显示动画
    class func showHUDTo(view: UIView, title: String, animated: Bool) {
        let HUD = MBProgressHUD.showAdded(to: view, animated: animated)
        HUD.label.font = UIFont.systemFont(ofSize: fontSize)
        HUD.label.text = title
        HUD.removeFromSuperViewOnHide = true
//        HUD.opacity = opacity
    }

    /// 添加到一个视图，有动画
    class func showHUDTo(view: UIView, title: String) {
        let HUD = MBProgressHUD.showAdded(to: view, animated: true)
        HUD.label.font = UIFont.systemFont(ofSize: fontSize)
        HUD.label.text = title
        HUD.removeFromSuperViewOnHide = true
    }

    ///进度 回调时，请在主线程用 .progress更新进度，需要手动隐藏
    class func showProgress(view: UIView, title: String) -> MBProgressHUD {
        let HUD = MBProgressHUD.showAdded(to: view, animated: true)
        HUD.label.font = UIFont.systemFont(ofSize: fontSize)
        HUD.label.text = title
        HUD.mode = .annularDeterminate
        HUD.removeFromSuperViewOnHide = true
        return HUD
    }
    class func showAfterSecond(title: String, view: UIView, afterSecond: TimeInterval) {
        let HUD = MBProgressHUD.showAdded(to: view, animated: true)
        HUD.mode = MBProgressHUDMode.text
        HUD.label.font = UIFont.systemFont(ofSize: fontSize)
        HUD.label.text = title
        HUD.removeFromSuperViewOnHide = true
        HUD.hide(animated: true, afterDelay: afterSecond)
    }

    class func showHUD(title: String, view: UIView, afterSecond: TimeInterval, msgType: MBProgressType) {
        let imageName = imageNamedWithMsgType(msgType: msgType)
        guard let img = UIImage(named: imageName) else {
            return
        }
        let HUD = MBProgressHUD.showAdded(to: view, animated: true)
        HUD.label.font = UIFont.systemFont(ofSize: fontSize)
        HUD.customView = UIImageView(image: img)
        HUD.label.text = title
        HUD.removeFromSuperViewOnHide = true
//        HUD.opacity = opacity
        HUD.mode = MBProgressHUDMode.customView
        HUD.hide(animated: true, afterDelay: afterSecond)
    }

    /// 根据显示类型来选择背景图片
    fileprivate class func imageNamedWithMsgType(msgType: MBProgressType) -> String {
        var imageName = ""

        switch msgType {
        case .successful:
            imageName = "hud_success"
        case .error:
            imageName = "hud_error"
        case .warning:
            imageName = "hud_warning"
        case .info:
            imageName = "hud_info"
        }
        return imageName
    }
}
