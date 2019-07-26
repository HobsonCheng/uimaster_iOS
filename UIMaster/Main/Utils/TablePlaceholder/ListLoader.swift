//
//  ListLoader.swift
//  UIMaster
//
//  Created by hobson on 2018/9/4.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

@objc protocol ListLoadable {
    func ld_visibleContentViews() -> [UIView]
}

@objc extension UITableView: ListLoadable {
    func ld_visibleContentViews() -> [UIView] {
        return (self.visibleCells as NSArray).value(forKey: "contentView") as? [UIView] ?? []
    }
}

@objc extension UIView {
    func showLoader() {
        self.isUserInteractionEnabled = false
        if let table = self as? UITableView {
            ListLoader.addLoaderTo(table)
        } else if let collection = self as? UICollectionView {
            ListLoader.addLoaderTo(collection)
        } else {
            ListLoader.addLoaderToViews([self])
        }
    }

    func hideLoader() {
        self.isUserInteractionEnabled = true
        if let table = self as? UITableView {
            ListLoader.removeLoaderFrom(table)
        } else if let collection = self as? UICollectionView {
            ListLoader.removeLoaderFrom(collection)
        } else {
            ListLoader.removeLoaderFromViews([self])
        }
    }
}

@objc extension UICollectionView: ListLoadable {
    func ld_visibleContentViews() -> [UIView] {
        return (self.visibleCells as NSArray).value(forKey: "contentView") as? [UIView] ?? [UIView()]
    }
}

@objc extension UIColor {
    static func backgroundFadedGrey() -> UIColor {
        return UIColor(red: (246.0 / 255.0), green: (247.0 / 255.0), blue: (248.0 / 255.0), alpha: 1)
    }

    static func gradientFirstStop() -> UIColor {
        return UIColor(red: (238.0 / 255.0), green: (238.0 / 255.0), blue: (238.0 / 255.0), alpha: 1.0)
    }

    static func gradientSecondStop() -> UIColor {
        return UIColor(red: (221.0 / 255.0), green: (221.0 / 255.0), blue: (221.0 / 255.0), alpha: 1.0)
    }
}

@objc extension UIView {
    func boundInside(_ superView: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview": self]))
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview": self]))
    }
}

extension CGFloat {
    func doubleValue() -> Double {
        return Double(self)
    }
}

class ListLoader: NSObject {
    static func addLoaderToViews(_ views: [UIView]) {
        CATransaction.begin()
        views.forEach {
            $0.ld_addLoader()
        }
        CATransaction.commit()
    }

    static func removeLoaderFromViews(_ views: [UIView]) {
        CATransaction.begin()
        views.forEach {
            $0.ld_removeLoader()
        }
        CATransaction.commit()
    }

    static func addLoaderTo(_ list: ListLoadable) {
        self.addLoaderToViews(list.ld_visibleContentViews())
    }

    static func removeLoaderFrom(_ list: ListLoadable) {
        self.removeLoaderFromViews(list.ld_visibleContentViews())
    }
}

class CutoutView: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(self.bounds)
        let subViews = self.superview?.subviews ?? []
        for view in subViews where view != self {
            context?.setBlendMode(.clear)
            let rect = view.frame
            let clipPath: CGPath = UIBezierPath(roundedRect: rect, cornerRadius: view.layer.cornerRadius).cgPath
            context?.addPath(clipPath)
            context?.setFillColor(UIColor.clear.cgColor)
            context?.closePath()
            context?.fillPath()
        }
    }

    override func layoutSubviews() {
        self.setNeedsDisplay()
        self.superview?.ld_getGradient()?.frame = (self.superview?.bounds)!
    }
}

// TODO :- Allow caller to tweak these
var cutoutHandle: UInt8 = 0
var gradientHandle: UInt8 = 0
var loaderDuration = 0.85
var gradientWidth = 0.17
var gradientFirstStop = 0.1

@objc extension UIView {
    fileprivate func ld_getCutoutView() -> UIView? {
        return objc_getAssociatedObject(self, &cutoutHandle) as? UIView
    }

    fileprivate func ld_setCutoutView(_ aView: UIView) {
        return objc_setAssociatedObject(self, &cutoutHandle, aView, .OBJC_ASSOCIATION_RETAIN)
    }

    fileprivate func ld_getGradient() -> CAGradientLayer? {
        return objc_getAssociatedObject(self, &gradientHandle) as? CAGradientLayer
    }

    fileprivate func ld_setGradient(_ aLayer: CAGradientLayer) {
        return objc_setAssociatedObject(self, &gradientHandle, aLayer, .OBJC_ASSOCIATION_RETAIN)
    }

    fileprivate func ld_addLoader() {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        self.layer.insertSublayer(gradient, at: 0)

        self.configureAndAddAnimationToGradient(gradient)
        self.addCutoutView()
    }

    fileprivate func ld_removeLoader() {
        self.ld_getCutoutView()?.removeFromSuperview()
        self.ld_getGradient()?.removeAllAnimations()
        self.ld_getGradient()?.removeFromSuperlayer()

        for view in self.subviews {
            view.alpha = 1
        }
    }

    func configureAndAddAnimationToGradient(_ gradient: CAGradientLayer) {
        gradient.startPoint = CGPoint(x: -1.0 + CGFloat(gradientWidth), y: 0)
        gradient.endPoint = CGPoint(x: 1.0 + CGFloat(gradientWidth), y: 0)

        gradient.colors = [
            UIColor.backgroundFadedGrey().cgColor,
            UIColor.gradientFirstStop().cgColor,
            UIColor.gradientSecondStop().cgColor,
            UIColor.gradientFirstStop().cgColor,
            UIColor.backgroundFadedGrey().cgColor
        ]

        let startLocations = [NSNumber(value: gradient.startPoint.x.doubleValue() as Double), NSNumber(value: gradient.startPoint.x.doubleValue() as Double), NSNumber(value: 0 as Double), NSNumber(value: gradientWidth as Double), NSNumber(value: 1 + gradientWidth as Double)]

        gradient.locations = startLocations
        let gradientAnimation = CABasicAnimation(keyPath: "locations")
        gradientAnimation.fromValue = startLocations
        gradientAnimation.toValue = [NSNumber(value: 0 as Double), NSNumber(value: 1 as Double), NSNumber(value: 1 as Double), NSNumber(value: 1 + (gradientWidth - gradientFirstStop) as Double), NSNumber(value: 1 + gradientWidth as Double)]

        gradientAnimation.repeatCount = Float.infinity
        gradientAnimation.fillMode = kCAFillModeForwards
        gradientAnimation.isRemovedOnCompletion = false
        gradientAnimation.duration = loaderDuration
        gradient.add(gradientAnimation, forKey: "locations")

        self.ld_setGradient(gradient)
    }

    fileprivate func addCutoutView() {
        let cutout = CutoutView()
        cutout.frame = self.bounds
        cutout.backgroundColor = UIColor.clear

        self.addSubview(cutout)
        cutout.setNeedsDisplay()
        cutout.boundInside(self)

        for view in self.subviews where view != cutout {
            view.alpha = 0
        }

        self.ld_setCutoutView(cutout)
    }
}
