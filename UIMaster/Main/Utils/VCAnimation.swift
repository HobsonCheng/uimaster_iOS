//
//  VCAnimationBottom.swift
//  UIMaseter
//
//  Created by gongcz on 2018/4/16.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

// MARK: -
protocol VCAnimationPtc {
    /// 压入节点动画
    ///
    /// - Parameters:
    ///   - topVC: push在底部的VC
    ///   - arriveVC: push在顶部的VC
    ///   - completion: push动画完成后的处理回调
    func push(fromTopVC: UIViewController, toArrive: UIViewController, with completion:  @escaping (_ finished: Bool) -> Void)

    /// 弹出节点动画
    ///
    /// - Parameters:
    ///   - topVC: pop在顶部的VC
    ///   - arriveVC: pop在底部的VC
    ///   - ompletion: pop动画完成后的处理回调
    func pop(fromTopVC: UIViewController, toArrive: UIViewController, with completion: @escaping (_ finished: Bool) -> Void)
}

// MARK: -
class VCAnimationBottom: NSObject, VCAnimationPtc {
    static func defaultAnimation() -> VCAnimationBottom {
        return VCAnimationBottom()
    }

    func push(fromTopVC: UIViewController, toArrive: UIViewController, with completion: @escaping (Bool) -> Void) {
        toArrive.view.setViewY(toArrive.view.height)
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                toArrive.view.setViewY(0)
            },
            completion: completion
        )
    }

    func pop(fromTopVC: UIViewController, toArrive: UIViewController, with completion: @escaping (Bool) -> Void) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                fromTopVC.view.setViewY(fromTopVC.view.height)
            },
            completion: completion
        )
    }
}

class VCAnimationClassic: NSObject, VCAnimationPtc {
    func push(fromTopVC: UIViewController, toArrive: UIViewController, with completion: @escaping (Bool) -> Void) {
        toArrive.view.setViewX(toArrive.view.width)
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                fromTopVC.view.setViewX(-fromTopVC.view.width)
                toArrive.view.setViewX(0)
            },
            completion: completion
        )
    }

    func pop(fromTopVC: UIViewController, toArrive: UIViewController, with completion: @escaping (Bool) -> Void) {
        toArrive.view.setViewX(-toArrive.view.width)
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                fromTopVC.view.setViewX(fromTopVC.view.width)
                toArrive.view.setViewX(0)
            },
            completion: completion
        )
    }

    static func defaultAnimation() -> VCAnimationClassic {
        return VCAnimationClassic()
    }
}
