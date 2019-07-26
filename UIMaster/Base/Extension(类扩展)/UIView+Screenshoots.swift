//
//  UIView+Screenshoots.swift
//  UIMaster
//
//  Created by gongcz on 2018/5/19.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

// MARK: - 截屏
extension UIView {
    func screenSnapshot() -> UIImage? {
        // 用下面这行而不是UIGraphicsBeginImageContext()，因为前者支持Retina
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
//    /**
//     Init from nib and get the view
//     Notice: The nib file name is the same as the calss name
//     
//     Demo： UIView.ts_viewFromNib(TSCustomView)
//     
//     - parameter aClass: your class
//     
//     - returns: Your class's view
//     */
//    class func viewFromNib<T>(_ aClass: T.Type) -> T {
//        let name = String(describing: aClass)
//        if Bundle.main.path(forResource: name, ofType: "nib") != nil {
//            return UINib(nibName: name, bundle:nil).instantiate(withOwner: nil, options: nil)[0] as! T
//        } else {
//            fatalError("\(String(describing: aClass)) nib is not exist")
//        }
//    }
}

public extension UIView {
    /**
     Init from nib
     Notice: The nib file name is the same as the calss name
     
     - returns: UINib
     */
    class func getNib() -> UINib {
        let hasNib: Bool = Bundle.main.path(forResource: self.getClassName, ofType: "nib") != nil
        guard hasNib else {
            assert(!hasNib, "Nib is not exist")
            return UINib()
        }
        return UINib(nibName: self.getClassName, bundle: nil)
    }

    /**
     Init from nib and get the view
     Notice: The nib file name is the same as the calss name
     
     Demo： UIView.ts_viewFromNib(TSCustomView)
     
     - parameter aClass: your class
     
     - returns: Your class's view
     */
    class func viewFromNib<T>(_ aClass: T.Type) -> T? {
        let name = String(describing: aClass)
        if let nib = Bundle.main.path(forResource: name, ofType: "nib") {
            return UINib(nibName: name, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? T
        }
        return nil
    }

    /**
     All subviews of the UIView
     
     - returns: A group of UIView
     */
    func allSubviews() -> [UIView] {
        var stack = [self]
        var views = [UIView]()
        while !stack.isEmpty {
            let subviews = stack[0].subviews as [UIView]
            views += subviews
            stack += subviews
            stack.remove(at: 0)
        }
        return views
    }

    /**
     Take snap shot
     
     - returns: UIImage
     */
    func takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    /// Check the view is visible
    @available(iOS 8.0, *)
    var viewIsVisible: Bool {
        get {
            if self.window == nil || self.isHidden || self.alpha == 0 {
                return true
            }

            let viewRect = self.convert(self.bounds, to: nil)
            guard let app = UIApplication.sharedApplication() else {
                return false
            }
            guard let window = app.keyWindow else {
                return true
            }
            return viewRect.intersects(window.bounds) == false
        }
    }
}
extension NSObject {
    /// The class's name
    class var getClassName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last! as String
    }

    /// The class's identifier, for UITableView，UICollectionView register its cell
    class var getIdentifier: String {
        return String(format: "%@_identifier", self.getClassName)
    }
    class var getFullClassName: String {
        return NSStringFromClass(self)
    }
}

extension UIApplication {
    /// Avoid the error: [UIApplication sharedApplication] is unavailable in xxx extension
    ///
    /// - returns: UIApplication?
    public class func sharedApplication() -> UIApplication? {
        let selector = NSSelectorFromString("sharedApplication")
        guard UIApplication.responds(to: selector) else { return nil }
        return UIApplication.perform(selector).takeUnretainedValue() as? UIApplication
    }

    ///Get screen orientation
    public class var screenOrientation: UIInterfaceOrientation? {
        guard let app = self.sharedApplication() else {
            return nil
        }
        return app.statusBarOrientation
    }

    ///Get status bar's height
    @available(iOS 8.0, *)
    public class var screenStatusBarHeight: CGFloat {
        guard let app = UIApplication.sharedApplication() else {
            return 0
        }
        return app.statusBarFrame.height
    }

    /**
     Run a block in background after app resigns activity
     
     - parameter closure:           The closure
     - parameter expirationHandler: The expiration handler
     */
    public func runIntoBackground(_ closure: @escaping () -> Void, expirationHandler: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let taskID: UIBackgroundTaskIdentifier
            if let expirationHandler = expirationHandler {
                taskID = self.beginBackgroundTask(expirationHandler: expirationHandler)
            } else {
                taskID = self.beginBackgroundTask(expirationHandler: { })
            }
            closure()
            self.endBackgroundTask(taskID)
        }
    }
}
