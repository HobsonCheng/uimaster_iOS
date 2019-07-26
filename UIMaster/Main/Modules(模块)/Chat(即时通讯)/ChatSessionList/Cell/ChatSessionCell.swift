//
//  ChatSessionCellTableViewCell.swift
//  UIMaster
//
//  Created by hobson on 2018/9/26.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit
import YYText
protocol ChatSessionCellDelegate: AnyObject {
    func setActionBarData(model: ChatSessionModel)
    func longPressed(model: ChatSessionModel, cell: ChatSessionCell)
}

class ChatSessionCell: UITableViewCell {
    @IBOutlet weak var avatorImgView: UIImageView!
    @IBOutlet weak var contentLabel: YYLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tipImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var unreadLabel: UILabel!
    @IBOutlet weak var sendingView: UIActivityIndicatorView!
    @IBOutlet weak var contentConstraint: NSLayoutConstraint!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var errorImageView: UIImageView!
    weak var delegate: ChatSessionCellDelegate?

    var model: ChatSessionModel? {
        didSet {
            //消息类型
            if model?.msg_kind == ChatMessageType.picture.rawValue {
                contentLabel.textColor = UIColor(hexString: "#a0271e")
                contentLabel.text = "[图片]"
            } else if model?.msg_kind == ChatMessageType.file.rawValue {
                contentLabel.textColor = UIColor(hexString: "#a0271e")
                contentLabel.text = "[文件]"
            } else {
                contentLabel.textColor = UIColor(hexString: "#777777")
                contentLabel.text = model?.last_content
            }
            //草稿
            if let content = model?.draft_content, !content.isEmpty {
                let msg = "[草稿]" + content
                let text = NSMutableAttributedString(string: msg)
                text.yy_font = UIFont.systemFont(ofSize: 14)
                text.yy_color = UIColor(hexString: "#777777")
                text.yy_setColor(UIColor(hexString: "#de2421"), range: NSRange(location: 0, length: 4))

                contentLabel.attributedText = text
            }
            //时间
            timeLabel.text = model?.update_time.getTimeTip()
            //未读标识
            let num = (model?.unread_remind_num ?? 0) > 99 ? "99+" : "\((model?.unread_remind_num ?? 0))"
            unreadLabel.text = num + "  "
            unreadLabel.isHidden = model?.unread_remind_num == 0
            //发送状态
            if ChatSendStatus(rawValue: model?.last_send_state ?? 0) == .sending {
                sendingView.isHidden = false
                errorImageView.isHidden = true
                sendingView.startAnimating()
                contentConstraint.constant = 17
            } else if ChatSendStatus(rawValue: model?.last_send_state ?? 0) == .fail {
                sendingView.isHidden = true
                errorImageView.isHidden = false
                contentConstraint.constant = 17
            } else {
                sendingView.isHidden = true
                errorImageView.isHidden = true
                contentConstraint.constant = 0
            }

            //昵称
            nickNameLabel.text = (model?.nickname.isEmpty ?? true) ?  "无昵称" : model?.nickname ?? "暂无"
            //头像
            let placeHoldImage = model?.chat_type == 1 ? R.image.groupHead() :  R.image.defaultPortrait()
            avatorImgView.kf.setImage(with: URL(string: model?.avatar ?? ""), placeholder: placeHoldImage, options: nil, progressBlock: nil, completionHandler: nil)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.textColor = UIColor(hexString: "#777777")
        //头像
        avatorImgView.cornerRadius = 5
        avatorImgView.maskToBounds = true
        //回复按钮
        replyBtn.cornerRadius = 5
        replyBtn.bordersColor = UIColor(hexString: "#777777")
        replyBtn.bordersWidth = 1
        replyBtn.maskToBounds = true

        //未读
        unreadLabel.cornerRadius = 10
        unreadLabel.maskToBounds = true
        unreadLabel.isHidden = model?.unread_num == 0
        //添加长按手势
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(guesture:)))
        longTapGesture.minimumPressDuration = 0.4
        addGestureRecognizer(longTapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func touchReply(_ sender: Any) {
        self.delegate?.setActionBarData(model: self.model ?? ChatSessionModel())
    }

    @objc func longPressed(guesture: UILongPressGestureRecognizer) {
        if guesture.state == UIGestureRecognizerState.began {
            self.delegate?.longPressed(model: self.model ?? ChatSessionModel(), cell: self)
        }
    }
    override func becomeFirstResponder() -> Bool {
        return true
    }
}
