//
//  LightControl.swift
//  UIMaseter
//
//  Created by one2much on 2018/4/16.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

/// 是用来解决 UIButton 无法做到点击时将子View也设置为Highlight状态的控件
class LightControl: UIControl {
    /// 自定义信息，可用来进行数据传递
    var customInfo: AnyObject?

    fileprivate var imageNormal: UIImage?
    fileprivate var imageHighlight: UIImage?
    fileprivate var imageDisable: UIImage?

    override var frame: CGRect {
        didSet {
            super.frame = frame
            self.setNeedsDisplay()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            super.isHighlighted = isHighlighted
            self.setNeedsDisplay()//刷新自己
            self.setNeedsLayout()//刷新儿子
        }
    }
    override var isEnabled: Bool {
        didSet {
            super.isEnabled = isEnabled
            self.setNeedsDisplay()//刷新自己
            self.setNeedsLayout()//刷新儿子
        }
    }

    // MARK: -

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: -

    /// 设置背景图
    ///
    /// - Parameters:
    ///   - image: 背景图的image
    ///   - state: 背景图对应的按钮状态
    func setBackgroundImage(_ image: UIImage, for state: UIControlState) {
        switch state {
        case UIControlState.normal:
            self.imageNormal = image
            if imageHighlight == nil { imageHighlight = image }
            if imageDisable == nil { imageDisable = image }
        case UIControlState.highlighted:
            imageHighlight = image
        case UIControlState.disabled:
            imageDisable = image
        default:
            break
        }
    }
    // MARK: - 重新布局
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let width = self.bounds.size.width
        let height = self.bounds.size.height
        if isEnabled == false {
            imageDisable?.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        } else if isHighlighted == true {
            if let imageHi = imageHighlight {
                imageHi.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        } else {
            imageNormal?.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setSubHighlighted(self.isHighlighted, forParent: self)
        self.setSubviewEnabled(self.isEnabled, forParent: self)//刷新儿子
    }

    // MARK: -

    fileprivate func setSubHighlighted(_ highlighted: Bool, forParent view: UIView) {
        for subview in view.subviews {
            switch subview.self {
            case is UILabel:
                let view = subview as? UILabel
                view?.isHighlighted = true
            case is UIImageView:
                let view = subview as? UIImageView
                view?.isHighlighted = true
            case is UIControl:
                let view = subview as? UIControl
                view?.isHighlighted = true
            default:
                setSubHighlighted(highlighted, forParent: subview)
            }
        }
    }
    fileprivate func setSubviewEnabled(_ enable: Bool, forParent view: UIView) {
        for subview in view.subviews {
            switch subview.self {
            case is UILabel:
                let view = subview as? UILabel
                view?.isEnabled = true
            case is UIControl:
                let view = subview as? UIControl
                view?.isEnabled = true
            default:
                setSubviewEnabled(enable, forParent: subview)
            }
        }
    }
}
