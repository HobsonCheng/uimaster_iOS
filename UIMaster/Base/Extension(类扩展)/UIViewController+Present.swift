//
//  UIViewController+Present.swift
//  UIMaseter
//
//  Created by gongcz on 2018/4/18.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

extension UIViewController {
//    static func awake() {
//        UIViewController.classInit()
//    }
    static func classInit() {
        swizzleMethod
    }
    // 自调用闭包 created by Hobson
    private static let swizzleMethod: Void = {
        let presentM = class_getInstanceMethod(UIViewController.self, #selector(present(_:animated:completion:)))
        let presentSwizzlingM = class_getInstanceMethod(UIViewController.self, #selector(dy_present(_:animated:completion:)))
        method_exchangeImplementations(presentM!, presentSwizzlingM!)
    }()

    @objc func dy_present(_ viewControllerToPresent: UIViewController?, animated flag: Bool, completion: @escaping () -> Void) {
        if viewControllerToPresent is UIAlertController {
            dPrint("title : \((viewControllerToPresent as? UIAlertController)?.title ?? "")")
            dPrint("message : \((viewControllerToPresent as? UIAlertController)?.message ?? "")")
            let alertController = viewControllerToPresent as? UIAlertController
            if alertController?.title == nil && alertController?.message == nil {
                return
            } else {
                dy_present(viewControllerToPresent, animated: flag, completion: completion)
                return
            }
        }
        dy_present(viewControllerToPresent, animated: flag, completion: completion)
    }
}
