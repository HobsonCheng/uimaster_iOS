//
//  UIViewExtension.swift
//  Pods
//
//  Created by Millman YANG on 2017/4/2.
//
//

import UIKit

extension UIViewController {
    func drawer() -> DrawerViewController? {
        return self.findDrawer(controller: self)
    }

    private func findDrawer(controller: UIViewController?) -> DrawerViewController? {
        if let controllerParent = controller?.parent {
            if let parent = controllerParent as? DrawerViewController {
                return parent
            } else {
                return self.findDrawer(controller: controllerParent)
            }
        }
        return nil
    }
}
