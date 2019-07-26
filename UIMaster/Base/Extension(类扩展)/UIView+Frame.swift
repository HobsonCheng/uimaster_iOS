//
//  UIView+Frame.swift
//  UIMaseter
//
//  Created by gongcz on 2018/4/17.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit
// MARK: Frame
extension UIView {
    public var left: CGFloat {
        get {
            return self.frame.origin.x
        }
        set(value) {
            self.frame = CGRect(x: value, y: self.top, width: self.width, height: self.height)
        }
    }

    public var top: CGFloat {
        get {
            return self.frame.origin.y
        }
        set(value) {
            self.frame = CGRect(x: self.left, y: value, width: self.width, height: self.height)
        }
    }

    public var right: CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width
        }
        set(value) {
            var frame = self.frame
            frame.origin.x = value - frame.size.width
            self.frame = frame
        }
    }

    public var bottom: CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height
        }
        set(value) {
            var frame = self.frame
            frame.origin.y = value - frame.size.height
            self.frame = frame
        }
    }

    public var width: CGFloat {
        get {
            return self.frame.size.width
        } set(value) {
            self.frame = CGRect(x: self.left, y: self.top, width: value, height: self.height)
        }
    }

    public var height: CGFloat {
        get {
            return self.frame.size.height
        } set(value) {
            self.frame = CGRect(x: self.left, y: self.top, width: self.width, height: value)
        }
    }

    public var centerX: CGFloat {
        get {
            return self.center.x
        } set(value) {
            self.center = CGPoint(x: value, y: self.center.y)
        }
    }

    public var centerY: CGFloat {
        get {
            return self.center.y
        } set(value) {
            self.center = CGPoint(x: self.center.x, y: value)
        }
    }

    public func removeAllSubviews() {
        while !self.subviews.isEmpty {
            self.subviews.last?.removeFromSuperview()
        }
    }
}
// MARK: getOwnerVC
extension UIView {
    /**获取所在的VC*/
    public func ownerVC() -> UIViewController? {
        var nextResponder: UIResponder? = self

        repeat {
            nextResponder = nextResponder?.next

            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
        } while nextResponder != nil

        return nil
    }
}

extension UIView {
    // 设置UIView的X

    func setViewX(_ newX: CGFloat) {
        var viewFrame: CGRect = self.frame
        viewFrame.origin.x = newX
        frame = viewFrame
    }

    // 设置UIView的Y
    func setViewY(_ newY: CGFloat) {
        var viewFrame: CGRect = self.frame
        viewFrame.origin.y = newY
        frame = viewFrame
    }

    // 设置UIView的Origin
    func setViewOrigin(_ newOrigin: CGPoint) {
        var viewFrame: CGRect = self.frame
        viewFrame.origin = newOrigin
        frame = viewFrame
    }

    // 设置UIView的width
    func setViewWidth(_ newWidth: CGFloat) {
        var viewFrame: CGRect = self.frame
        viewFrame.size.width = newWidth
        frame = viewFrame
    }

    // 设置UIView的height
    func setViewHeight(_ newHeight: CGFloat) {
        var viewFrame: CGRect = self.frame
        viewFrame.size.height = newHeight
        frame = viewFrame
    }

    // 设置UIView的Size
    func setViewSize(_ newSize: CGSize) {
        var viewFrame: CGRect = self.frame
        viewFrame.size = newSize
        frame = viewFrame
    }

    /*!
     *  获取
     */
    class func  loadFromXib() -> AnyObject {
        let className = "\(self)"
        let xibArray = Bundle.main.loadNibNamed(className, owner: nil, options: nil)
        return xibArray?[0] as AnyObject
    }

    class func loadFromXib(_ index: Int) -> AnyObject {
        let className = "\(self)"
        let xibArray = Bundle.main.loadNibNamed(className, owner: nil, options: nil)
        if index < (xibArray?.count ?? 0) {
            return xibArray?[index] as AnyObject
        }
        return xibArray?[0] as AnyObject
    }

    func drawDashLine(color: UIColor, width: CGFloat, radius: CGFloat) {
        let border = CAShapeLayer()
        //虚线的颜色
        border.strokeColor = color.cgColor
        //填充的颜色
        border.fillColor = UIColor.clear.cgColor
        //设置路径
        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius)
        border.path = path.cgPath
        border.frame = self.bounds
        //虚线的宽度
        border.lineWidth = width
        //设置线条的样式//
        border.lineCap = "square"
        //虚线的间隔
        border.lineDashPattern = [4, 2]
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.layer.addSublayer(border)
    }
}
