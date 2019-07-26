//
//  AlertInputView.swift
//  UIMaseter
//
//  Created by gongcz on 2018/4/19.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

enum KeyboardType: Int {
    case `default` = 0
    // Default type for the current input metho
    case url = 1
    // A type optimized for URL entry (shows . / .com prominently).
    case numberPad = 2
    // A number pad with locale-appropriate digits (0-9, ۰-۹, ०-९, etc.). Suitable for PIN entry.
    case phonePad = 3
    // A phone pad (1-9, *, 0, #, with letters under the numbers).
    case namePhonePad = 4
}

class AlertInputView: UIView, UITextViewDelegate {
    //字数限制默认不限
    var num: Int = 0

    //备注文本View高度
    fileprivate var noteTextHeight: Float = 0.0
    fileprivate var title: String? = ""
    fileprivate var placeholderContent: String? = ""
    fileprivate var type = KeyboardType.default
    fileprivate var alertView: UIView?
    fileprivate var titLa: UILabel?
    fileprivate var textView: PlacehoderTextView?
    fileprivate var qxbtn: UIButton?
    fileprivate var okbtn: UIButton?

    fileprivate typealias DoneBlock = (_: String) -> Void
    fileprivate lazy var shadowView: UIView? = {
        let shadowView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH))
        shadowView.backgroundColor = UIColor.black
        shadowView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToDismissNinaView))
        shadowView.addGestureRecognizer(tap)
        return shadowView
    }()
    fileprivate var doneBlock: DoneBlock?

    /// 初始化
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - PlaceholderText: 默认提示语句
    ///   - bordtype: 键盘类型
    ///   - completeBlock: 点击回调
    convenience init(title: String?, placeholderText placeholder: String?, withKeybordType bordtype: KeyboardType, completeBlock: @escaping (_ contents: String?) -> Void) {
        self.init()
        self.title = title
        self.placeholderContent = placeholder
        type = bordtype
        frame = CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH)
        if let aView = shadowView {
            insertSubview(aView, belowSubview: self)
        }
        creatUI()
//        if completeBlock != nil {
        doneBlock = {(_ contents: String?) -> Void in
            completeBlock(contents)
        }
//        }
    }
    func creatUI() {
        alertView = UIView()
        guard let alertView = self.alertView else {
            return
        }
        alertView.backgroundColor = UIColor.white
        alertView.layer.cornerRadius = 8
        shadowView?.addSubview(alertView)
        titLa = UILabel()
        guard let titLa = self.titLa else {
            return
        }
        titLa.text = title
        titLa.textAlignment = .center
        titLa.font = UIFont.systemFont(ofSize: 17)
        alertView.addSubview(titLa)
        textView = PlacehoderTextView()
        guard let textView = self.textView else {
            return
        }
        switch type {
        case .default:
            textView.keyboardType = .default
        case .url:
            textView.keyboardType = .URL
        case .numberPad:
             textView.keyboardType = .numberPad
        case .phonePad:
            textView.keyboardType = .phonePad
        default:
            textView.keyboardType = .namePhonePad
        }
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.autoresizingMask = .flexibleHeight
        textView.placeholder = placeholderContent
        textView.layer.borderColor = UIColor(hexString: "#E3E3E5").cgColor
        textView.layer.borderWidth = 0.5
        textView.delegate = self
        alertView.addSubview(textView)
        qxbtn = UIButton()
        guard let qxBtn = self.qxbtn else {
            return
        }
        qxBtn.backgroundColor = UIColor(hexString: "#E3E3E5")
        qxBtn.addTarget(self, action: #selector(qxTap), for: .touchUpInside)
        qxBtn.setTitle("取消", for: .normal)
        alertView.addSubview(qxBtn)
        okbtn = UIButton()
        guard let okBtn = self.okbtn else {
            return
        }
        okBtn.addTarget(self, action: #selector(okTap), for: .touchUpInside)
        okBtn.backgroundColor = UIColor(hexString: "229aee")
        okBtn.setTitle("确定", for: .normal)
        alertView.addSubview(okBtn)
        updateViewsFrame()
    }
    /**
     *  界面布局 frame
     */
    func updateViewsFrame() {
        if noteTextHeight == 0 {
            noteTextHeight = 35
        }

        alertView?.snp.makeConstraints({ make in
            make.centerX.equalTo(centerX)
            make.centerY.equalTo(centerY - 60)
            make.width.equalTo(kScreenW - 80)
        })

        titLa?.snp.makeConstraints({ make in
            make.top.equalTo(20)
            make.left.right.equalTo(0)
            make.height.equalTo(20)
        })

        textView?.snp.makeConstraints({ make in
            make.top.equalTo(titLa!.snp.bottom).offset(15)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(noteTextHeight)
        })

        qxbtn?.snp.makeConstraints({ make in
            make.top.equalTo(textView!.snp.bottom).offset(25)
            make.left.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo((kScreenW - 80) / 2 - 1)
        })

        okbtn?.snp.makeConstraints({ make in
            make.top.equalTo(textView!.snp.bottom).offset(25)
            make.left.equalTo(qxbtn!.snp.right).offset(1)
            make.height.equalTo(40)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        })
    }
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textChanged()
        return true
    }
    /**
     *  文本高度自适应
     */
    func textChanged() {
        guard let textView = self.textView else { return }
        var orgRect: CGRect = textView.frame
        //获取原始UITextView的frame
        //获取尺寸
        let size = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat(MAXFLOAT)))
        orgRect.size.height = size.height + 5
        //获取自适应文本内容高度
        //如果文本框没字了恢复初始尺寸
        if orgRect.size.height > 40 {
            noteTextHeight = Float(orgRect.size.height)
        } else {
            noteTextHeight = 40
        }
        updateViewsFrame()
    }

    //文本框每次输入文字都会调用  -> 更改文字个数提示框
    func textViewDidChangeSelection(_ textView: UITextView) {
        if num > 0 {
            if textView.text.count > num {
                textView.text = (textView.text as NSString?)?.substring(to: num) ?? ""
            }
        }
        textChanged()
    }

    // MARK: - LazyLoad
//    func shadowView() -> UIView? {
//        if !shadowView {
//            shadowView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
//            shadowView.backgroundColor = UIColor.black
//            shadowView.backgroundColor = RGBA(0, 0, 0, 0.4)
//            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapToDismissNinaView))
//            shadowView()?.addGestureRecognizer(tap)
//        }
//        return shadowView
//    }
    @objc func tapToDismissNinaView() {
        textView?.resignFirstResponder()
    }
    func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.layoutIfNeeded()
        }, completion: {(_ finished: Bool) -> Void in
            self.subviews.forEach { $0.removeFromSuperview() }
            self.removeFromSuperview()
        })
    }

    /**
     显示
     **/
    func show() {
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            UIApplication.shared.keyWindow?.addSubview(self)
        })
    }
    @objc func qxTap() {
        dismiss()
    }
    @objc func okTap() {
        doneBlock?(textView!.text)
        dismiss()
    }
}
