//
//  CLTextView.swift
//  UIDS
//
//  Created by one2much on 2018/1/23.
//  Copyright © 2018年 one2much. All rights reserved.
//

import RxSwift
import UIKit

let kCommentTextViewHeight: CGFloat = 150.0
let kMininumKeyboardHeight: CGFloat = 180.0

class CLTextView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var containerViewConstraintHeight: NSLayoutConstraint!

    weak var delegate: CLBottomCommentViewDelegate?
    var backgroundView: UIVisualEffectView?
    private var disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)

        Bundle.main.loadNibNamed("CLTextView", owner: self, options: nil)
        self.contentView.frame = CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH)
        self.addSubview(self.contentView)

        self.configure()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        self.backgroundView = UIVisualEffectView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH))
        self.backgroundView?.backgroundColor = UIColor.black
        self.backgroundView?.alpha = 0.5
        self.backgroundView?.effect = UIBlurEffect(style: UIBlurEffectStyle.dark)

        self.commentTextView.layer.borderColor = UIColor(hex: 0xBCBAC1, alpha: 1).cgColor
        self.commentTextView.toolbarPlaceholder = "留下足迹..."
        self.commentTextView.layer.borderWidth = 0.5
        self.commentTextView.delegate = self

        self.sendButton.setTitleColor(UIColor(hex: 0x333333, alpha: 1), for: UIControlState.normal)

        let tapGr = UITapGestureRecognizer(target: self, action: #selector(CLTextView.tapAction(sender:)))
        let swipeGr = UISwipeGestureRecognizer(target: self, action: #selector(CLTextView.swipeAction(sender:)))
        swipeGr.direction = UISwipeGestureRecognizerDirection.down

        self.gestureRecognizers = [tapGr, swipeGr]

        self.insertSubview(self.backgroundView!, at: 0)

        NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardDidShow)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] ntf in
                self?.keyboardWasShown(aNotification: ntf)
            })
            .disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillHide)
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] ntf in
                self?.keyboardhidShown(aNotification: ntf)
            })
            .disposed(by: disposeBag)
    }

    @IBAction func cancelAction(_ sender: Any) {
        self.commentTextView.resignFirstResponder()
        self.dismissCommentTextView()
    }

    @IBAction func sendAction(_ sender: Any) {
        self.delegate?.cl_textViewDidEndEditing(self)
        self.commentTextView.resignFirstResponder()
        self.commentTextView.text = ""
        self.dismissCommentTextView()
    }

    @objc func tapAction(sender: UITapGestureRecognizer) {
        self.commentTextView.resignFirstResponder()
        self.dismissCommentTextView()
    }

    @objc func swipeAction(sender: UISwipeGestureRecognizer) {
        if sender.direction == UISwipeGestureRecognizerDirection.down {
            self.commentTextView.resignFirstResponder()
            self.dismissCommentTextView()
        }
    }

    @objc func keyboardhidShown(aNotification: Notification) {
        self.dismissCommentTextView()
    }

    @objc func keyboardWasShown(aNotification: Notification) {
        let info = aNotification.userInfo
        let keyBoardBounds = (info?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue

        if keyBoardBounds?.size.height > kMininumKeyboardHeight {
            self.containerViewConstraintHeight.constant = kCommentTextViewHeight + 20 + (keyBoardBounds?.size.height ?? 0)
        } else {
            self.containerViewConstraintHeight.constant = kCommentTextViewHeight + 20 + kMininumKeyboardHeight
        }
    }

    @objc func dismissCommentTextView() {
        self.removeFromSuperview()
    }

    func show() {
        self.commentTextView.becomeFirstResponder()
        UIApplication.shared.keyWindow?.addSubview(self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextViewDelegate
extension CLTextView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //替换文本为空，表示删除
        if text.isEmpty {
            return true
        }
        //拼接总文本
        let str = textView.text + text
        //如果总文本长度大于60，提示用户，同时禁止输入
        if str.count >= 60 {
            HUDUtil.msg(msg: "最多60个字哦~", type: .info)
            textView.text = String(str[str.startIndex...str.index(str.startIndex, offsetBy: 59)])
            return false
        } else {
            return true
        }
    }
}
