//
//  HUDUtil.swift
//  UIMaster
//
//  Created by hobsonself.mainTable?.endRefreshCB?(noMore) on 2018/12/20.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit
final class HUDUtil {
    /// 调试  提示
    ///
    /// - Parameters:
    ///   - msg: 信息
    ///   - type: 类型
    static func debugMsg(msg: String, type: MBProgressType) {
        #if DEBUG
        DispatchQueue.main.async {
            switch type {
            case .successful:
                MBMasterHUD.showSuccess(title: "调试:" + msg)
            case .error:
                MBMasterHUD.showFail(title: "调试:" + msg)
            case .warning, .info:
                MBMasterHUD.showInfo(title: "调试:" + msg)
            }
        }
        #endif
    }
    /// 提示
    ///
    /// - Parameters:
    ///   - msg: 信息
    ///   - type: 类型
    static func msg(msg: String, type: MBProgressType) {
        if msg == "" { return }
        DispatchQueue.main.async {
            switch type {
            case .successful:
                MBMasterHUD.showSuccess(title: msg)
            case .error:
                MBMasterHUD.showFail(title: msg)
            case .warning, .info:
                MBMasterHUD.showInfo(title: msg)
            }
        }
    }

    /// 上传进度提示
    ///
    /// - Parameter view: 展示在哪个view上
    static func upLoadProgres(showOn view: UIView = kWindow) -> (_ progress: CGFloat) -> Void {
        let uploadHUD = MBMasterHUD.showProgress(view: view, title: "上传中...")
        return { (progress: CGFloat) in
            DispatchQueue.main.async {
                uploadHUD.progress = Float(progress)
                if progress >= 1 {
                    MBMasterHUD.hide {
                        MBMasterHUD.showSuccess(title: "上传成功")
                    }
                }
            }
        }
    }
    /// 加载 菊花
    ///
    /// - Parameter title: 提示文字，比如加载中...
    static func loadingHUD(title: String) {
        DispatchQueue.main.async {
            MBMasterHUD.showLoading(title: title)
        }
    }

    /// 停止刷新
    ///
    /// - Parameters:
    ///   - ok: 成功 失败
    ///   - callback: 回调
    ///   - hint: 提示语
    static func stopLoadingHUD(ok: Bool, callback: (() -> Void)?, hint: String) {
        MBMasterHUD.hide {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                guard let cb = callback else {
                    return
                }
                cb()
            })
        }
        if ok {
            MBMasterHUD.showSuccess(title: hint)
        } else {
            MBMasterHUD.showFail(title: hint)
        }
    }

    /// 停止刷洗
    ///
    /// - Parameter callback: 回调
    static func stopLoadingHUD(callback: (() -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            MBMasterHUD.hide {
                guard let cb = callback else {
                    return
                }
                cb()
            }
        })
    }
    /// 提示框 需要用户点击好的
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 消息
    static func showAlert(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "好的", style: .default, handler: nil))
        alertView.show()
    }
}
