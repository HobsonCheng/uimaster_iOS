//
//  UIButton+Addition.swift
//  UIMaseter
//
//  Created by gongcz on 2018/4/17.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

typealias ActionBlock = () -> Void
private var buttonBlockKey: String = "buttonBlockKey"

extension UIButton {
    var block: ActionBlock? {
        get {
            return (objc_getAssociatedObject(self, &buttonBlockKey) as? ActionBlock)
        }
        set(newValue) {
            objc_setAssociatedObject(self, &buttonBlockKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    func configButton(imagename: String?, hightImagename: String?, bgImagename: String?, target: AnyObject?, action: Selector) {
        let button = self //UIButton()
        if target != nil && target!.responds(to: action) {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        if imagename != nil {
            button.setImage(UIImage(named: imagename ?? ""), for: .normal)
        }
        if hightImagename != nil {
            button.setImage(UIImage(named: hightImagename ?? ""), for: .normal)
        }
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.contentMode = .center
    }

    func configButton(title: String?, normalColor: UIColor?, selectedColor: UIColor?, fontSize: CGFloat, target: AnyObject?, action: Selector) {
        setTitle(title, for: .normal)
        setBackgroundImage(UIImage.from(color: normalColor), for: .normal)
        setBackgroundImage(UIImage.from(color: selectedColor), for: .highlighted)
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        addTarget(target, action: action, for: .touchUpInside)
    }

    convenience init(imagename: String?, hightImagename: String?, bgImagename: String?, target: AnyObject?, action: Selector) {
        self.init()
        self.configButton(imagename: imagename, hightImagename: hightImagename, bgImagename: bgImagename, target: target, action: action)
    }
    convenience init(imagename: String?, hightImagename: String?, bgImagename: String?, touchBlock block: @escaping () -> Void) {
        self.init()
        self.configButton(imagename: imagename, hightImagename: hightImagename, bgImagename: bgImagename, target: self, action: #selector(btnTouch(_:)))
        self.block = block
    }
    @objc func btnTouch(_ button: UIButton?) {
        if let bBlock = button?.block {
            bBlock()
        }
    }
    convenience init(title: String?, normalColor: UIColor?, selectedColor: UIColor?, fontSize: CGFloat, touchBlock block: @escaping () -> Void) {
        self.init()
        self.configButton(title: title, normalColor: normalColor, selectedColor: selectedColor, fontSize: fontSize, target: self, action: #selector(btnTouch(_:)))
        self.block = block
    }
    convenience init(title: String?, normalColor: UIColor?, diableColor: UIColor?, fontSize: CGFloat, target: AnyObject?, action: Selector) {
        self.init()
        self.configButton(title: title, normalColor: normalColor, selectedColor: nil, fontSize: fontSize, target: target, action: action)
        let button = self //UIButton()
        if diableColor != nil && title != nil {
            button.setTitleColor(diableColor, for: .disabled)
        }
    }

    convenience init(title: String?, normalColor: UIColor?, selectedColor: UIColor?, fontSize: CGFloat, target: AnyObject?, action: Selector) {
        self.init()
        self.configButton(title: title, normalColor: normalColor, selectedColor: selectedColor, fontSize: fontSize, target: target, action: action)
    }

    // MARK: 验证
    func startTime() {
        var timeout: Int = 59
        //倒计时时间
        let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        timer.schedule(deadline: .now(), repeating: .seconds(1))
        timer.setEventHandler(handler: {
            if timeout <= 0 {
                //倒计时结束，关闭
                timer.cancel()
                DispatchQueue.main.async(execute: {() -> Void in
                    //设置界面的按钮显示 根据自己需求设置（倒计时结束后调用）
                    self.setTitle("获取验证码", for: .normal)
                    //设置不可点击
                    self.isUserInteractionEnabled = true
                    self.backgroundColor = UIColor(hexString: "#4895e0")
                })
            } else {
                //            int minutes = timeout / 60;    //这里注释掉了，这个是用来测试多于60秒时计算分钟的。
                let seconds: Int = timeout % 60
                let strTime = "\(seconds)"
                DispatchQueue.main.async(execute: {() -> Void in
                    //设置界面的按钮显示 根据自己需求设置
                    self.setTitle("重新发送(\(strTime)秒)", for: .normal)
                    //设置可点击
                    self.isUserInteractionEnabled = false
                    //                self.backgroundColor = [UIColor colorWithHexString:@""];
                })
                timeout -= 1
            }
        })
        timer.resume()
    }
}
