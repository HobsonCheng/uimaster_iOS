//
//  CLBottomCommentView.swift
//  UIDS
//
//  Created by one2much on 2018/1/23.
//  Copyright © 2018年 one2much. All rights reserved.
//

import RxSwift
import UIKit
class CLBottomCommentView: UIView {
    @IBOutlet weak var editTextField: UITextField!
    @IBOutlet weak var praiseButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var editView: UIView!
    var disposeBag = DisposeBag()

    var clTextView: CLTextView?
    var topicData: TopicData? {
        didSet {
            praiseNum = topicData?.praise_num ?? 0
            self.configure()
        }
    }
    var scrollCB: (() -> Void)?
    var praiseNum = 0
    weak var delegate: CLBottomCommentViewDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.rx.notification(Notification.Name(kBeginCommentNotification)).takeUntil(self.rx.deallocated).subscribe(onNext: {
            [weak self] ntf in
            if let id = ntf.object as? Int {
                if self?.topicData?.id == id {
                    self?.clTextView?.commentTextView.becomeFirstResponder()
                    UIApplication.shared.keyWindow?.addSubview((self?.clTextView!)!)
                }
            }
        }).disposed(by: disposeBag)
    }

    func configure() {
        self.editView.layer.cornerRadius = 15
        self.editView.clipsToBounds = true
        self.editView.layer.borderColor = UIColor(hex: 0xaaaaaa, alpha: 1).cgColor
        self.editView.layer.borderWidth = 0.5

        praiseButton.isSelected = topicData?.praised == 1 ? true : false
        praiseButton.addTarget(self, action: #selector(praised), for: .touchUpInside)
        praiseButton.setYJIcon(icon: .praise2, iconSize: 22, forState: .normal)
        praiseButton.setYJIcon(icon: .praised, iconSize: 22, forState: .selected)
        praiseButton.rx.tap.subscribe(onNext: { [weak self]() in
            self?.handlePraiseBtnState()
        }).disposed(by: disposeBag)
        reportButton.setYJText(prefixText: "", icon: YJType.report, postfixText: "", size: 18, forState: .normal)
        reportButton.addTarget(self, action: #selector(report), for: .touchUpInside)
        let lineView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.width, height: 0.5))
        lineView.backgroundColor = UIColor(hex: 0xBCBAC1, alpha: 1)
//        self.contentView.addSubview(lineView)

        self.editTextField.delegate = self

        self.clTextView = CLTextView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH))
        self.clTextView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.clTextView?.delegate = self
    }

    // MARK: - Public Method
    func showTextView() {
        self.editTextField.becomeFirstResponder()
    }

    func clearComment() {
        self.editTextField.text = ""
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextFieldDelegate
extension CLBottomCommentView: UITextFieldDelegate, CLBottomCommentViewDelegate {
    func bottomViewDidShare() {}

    func bottomViewDidMark(_ markButton: UIButton) {}

    func cl_textViewDidChange(_ textView: CLTextView) {}

    func cl_textViewDidEndEditing(_ textView: CLTextView) {
        if let safeCB = scrollCB {
            safeCB()
        }
        if !(textView.commentTextView.text.isEmpty) {
            let objData = self.topicData
            let params = NSMutableDictionary()
            params.setValue(textView.commentTextView.text.trim(), forKey: "content")
            params.setValue(objData?.id, forKey: "group_invitation_id")
            params.setValue(objData?.group_pid, forKey: "group_pid")
            NetworkUtil.request(target: .addReply(content: textView.commentTextView.text ?? "", group_invitation_id: objData?.id ?? 0, group_pid: objData?.group_pid ?? 0, parent_id: 0), success: {  _ in
                let commentNotification = Notification(name: Notification.Name(rawValue: kDidCommentNotification), object: nil, userInfo: nil)
                NotificationCenter.default.post(commentNotification)
            }) { error in
                dPrint(error)
            }
        }
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        self.addSubview(self.clTextView!)

        let textlen = textField.text?.count ?? 0
        if textlen > 4 {
            let string = NSMutableString(string: textField.text!)
            self.clTextView?.commentTextView.text = string.substring(from: 4)
        }
        self.clTextView?.commentTextView.becomeFirstResponder()
        UIApplication.shared.keyWindow?.addSubview(self.clTextView!)
        return false
    }

    @objc func praised(sender: UIButton) {
        //发送请求记录按钮状态
        let params = NSMutableDictionary()
        params.setValue(topicData?.group_pid, forKey: "group_pid")
        params.setValue(topicData?.id, forKey: "group_invitation_id")
        params.setValue(!sender.isSelected, forKey: "praise")
        NetworkUtil.request(target: .praiseInvitation(praise: !sender.isSelected, group_invitation_id: topicData?.id ?? 0, group_pid: topicData?.group_pid ?? 0), success: { _ in
        }) { error in
            dPrint(error)
        }
    }

    func handlePraiseBtnState() {
        //点击之后，选中状态置反
        let isSelected = !self.praiseButton.isSelected
//        if isSelected {
//            praiseNum += 1
//            self.praiseButton.setYJText(prefixText: "", icon: .praised, postfixText: "", size: 14, forState: .selected)
//        } else {
//            praiseNum -= 1
//            self.praiseButton.setYJText(prefixText: "", icon: .praise, postfixText: "", size: 14, forState: .normal)
//        }
        self.praiseButton.isSelected = isSelected
    }

    @objc func comment() {
    }
    @objc func report() {
        let id = topicData?.id ?? 0
        let pid = topicData?.group_pid ?? 0
        var reason = ""
        let alertVC = UIAlertController(title: "举报", message: "请选择举报的类型", preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "侵权举报", style: .destructive, handler: { _ in
            reason = "侵权举报"
            NetworkUtil.request(target: .tipOffInvitation(reason: reason, group_invitation_id: id, group_pid: pid), success: { _ in
                HUDUtil.msg(msg: "举报成功", type: .successful)
            }) { error in
                dPrint(error)
            }
        }))
        alertVC.addAction(UIAlertAction(title: "有害信息举报", style: .destructive, handler: { _ in
            reason = "有害信息举报"
            NetworkUtil.request(target: .tipOffInvitation(reason: reason, group_invitation_id: id, group_pid: pid), success: { _ in
                HUDUtil.msg(msg: "举报成功", type: .successful)
            }) { error in
                dPrint(error)
            }
        }))
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        kWindowRootVC?.present(alertVC, animated: true, completion: nil)
    }
}
