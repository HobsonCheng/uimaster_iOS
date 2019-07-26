//
//  ShareView.swift
//  UIDS
//
//  Created by Hobson on 2018/2/28.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

/** 分享类型 */
enum ShareType: String {
    case wechat
    case weibo
}

/** 分享和举报 */
protocol ShareViewDelegate: AnyObject {
    func reportClick()
    func shareClick(shareTyep: ShareType)
}

class ShareView: UIView {
    /** 遮罩View */
    var bgView: UIView?
    weak var delegate: ShareViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.width = kScreenW
        self.height = 160
        bgView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH))
    }

    // MARK: - 弹出层
    /**
     透明背景遮罩触摸事件
     */
    @objc fileprivate func didTappedBgView(_ tap: UITapGestureRecognizer) {
        dismiss()
    }

    /**
     弹出视图
     */
    func show() {
        bgView?.backgroundColor = UIColor(white: 0, alpha: 0)
        bgView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedBgView(_:))))
        UIApplication.shared.keyWindow?.addSubview(bgView!)
        UIApplication.shared.keyWindow?.addSubview(self)
        frame = CGRect(x: 0, y: kScreenH, width: kScreenW, height: 157)
        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.transform = CGAffineTransform(translationX: 0, y: -157)
                self.bgView?.backgroundColor = UIColor(white: 0, alpha: GLOBAL_SHADOW_ALPHA)
            },
            completion: { _ in
            }
        )
    }

    /**
     隐藏视图
     */
    func dismiss() {
        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.transform = CGAffineTransform.identity
                self.bgView?.backgroundColor = UIColor(white: 0, alpha: 0)
            },
            completion: { _ in
                self.bgView?.removeFromSuperview()
                self.removeFromSuperview()
            }
        )
    }

    // MARK: - 按钮点击
    @IBAction func reportButtonDidClick(_ sender: UIButton) {
        self.delegate?.reportClick()
    }

    @IBAction func shareButtonDidClick(_ sender: UIButton) {
        //根据button的label上文字判断点击的按钮
        switch sender.titleLabel?.text! {
        case ShareType.weibo.rawValue?:
            self.delegate?.shareClick(shareTyep: ShareType.weibo)
        case ShareType.wechat.rawValue?:
            self.delegate?.shareClick(shareTyep: ShareType.wechat)
        default:
            return
        }
    }
}
