//
//  SuspensionButton.swift
//  UIMaster
//
//  Created by hobson on 2019/1/14.
//  Copyright © 2019 one2much. All rights reserved.
//

import UIKit

class SuspensionUtil: SuspensionButtonDelegate {
    private var suspendButton = SuspensionButton(frame: .zero)
    static let shared = SuspensionUtil()

    private init() {
//        suspendButton.leanType = SuspensionButtonLeanType.Horizontal
//        suspendButton.initBt(frame: .zero, delegate: self)
//        suspendButton.frame = CGRect(x: kScreenW - 50, y: kScreenH - 150, width: 50, height: 50)
//        let appwindow = UIApplication.shared.delegate?.window
//        appwindow??.addSubview(suspendButton)
//        suspendButton.isHidden = true
    }

    /// 修改按钮样式
    ///
    /// - Parameter config: 按钮回调
    func configButton(config: (_ button: SuspensionButton) -> Void) {
        config(suspendButton)
    }

    /// 隐藏和显示悬浮按钮
    func showSuspensionButton(show: Bool) {
        suspendButton.isHidden = !show
    }

    func suspensionButtonClick(view: SuspensionButton) {
        PageRouter.shared.router(to: PageRouter.RouterPageType.searchProject)
    }
}

// MARK: - 生成视图
protocol SuspensionButtonDelegate: AnyObject {
    //点击按钮
    func suspensionButtonClick(view: SuspensionButton)
}

enum SuspensionButtonLeanType {
    case horizontal//左右
    case eachSide//全局
}

class SuspensionButton: UIButton {
    private weak var delegate: SuspensionButtonDelegate?

    var leanType: SuspensionButtonLeanType?

    func initBt(frame: CGRect, delegate: SuspensionButtonDelegate) {
        self.delegate = delegate

        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.alpha = 0.8

        self.setImage(UIImage(named: "2.png"), for: UIControlState.normal)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(changeLocation(recognizer:)))
        pan.delaysTouchesBegan = true
        self.addGestureRecognizer(pan)
        self.addTarget(self, action: #selector(click), for: UIControlEvents.touchUpInside)
    }

    @objc func changeLocation(recognizer: UIPanGestureRecognizer) {
        guard let appwindow = UIApplication.shared.delegate?.window else {
            return
        }
        let panPoint = recognizer.location(in: appwindow)

        if recognizer.state == UIGestureRecognizerState.began {
            self.alpha = 1
        } else if recognizer.state == UIGestureRecognizerState.changed {
            self.center = CGPoint(x: panPoint.x, y: panPoint.y)
        } else if recognizer.state == UIGestureRecognizerState.ended || recognizer.state == UIGestureRecognizerState.cancelled {
            self.alpha = 0.8
            let touchWidth = self.width
            let touchHeight = self.height
            let screenWith = kScreenW
            let screenHeight = kScreenH

            let left = Float(fabs(panPoint.x))
            let right: Float = fabs(Float(screenWith) - left)
            let top = Float(fabs(panPoint.y))
            let bottom: Float = fabs(Float(screenHeight) - top)

            var minSpace: Float = 0.0

            if self.leanType == SuspensionButtonLeanType.horizontal {
                minSpace = Float(min(left, right))
            } else {
                minSpace = Float(min(Float(min(Float(min(top, left)), bottom)), right))
            }

            var newCenter = CGPoint(x: 0, y: 0)
            var targetY: CGFloat = 0.0

            //校正Y
            if panPoint.y < 15 + touchHeight / 2.0 {
                targetY = 15 + touchHeight / 2.0
            } else if panPoint.y > (screenHeight - touchHeight / 2.0 - 15) {
                targetY = screenHeight - touchHeight / 2.0 - 15
            } else {
                targetY = panPoint.y
            }

            if minSpace == left {
                newCenter = CGPoint(x: touchHeight / 3, y: targetY)
            } else if minSpace == right {
                newCenter = CGPoint(x: screenWith - touchHeight / 3, y: targetY)
            } else if minSpace == top {
                newCenter = CGPoint(x: panPoint.x, y: touchWidth / 3)
            } else if minSpace == bottom {
                newCenter = CGPoint(x: panPoint.x, y: screenHeight - touchWidth / 3)
            }

            UIView.animate(withDuration: 0.25, animations: {
                self.center = newCenter
            })
        }
    }

    @objc func click() {
        self.delegate?.suspensionButtonClick(view: self)
    }
}
