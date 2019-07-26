//
//  ChatFileCell.swift
//  UIMaster
//
//  Created by hobson on 2018/10/13.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit

private let kChatVoiceBubbleTopTransparentGapValue: CGFloat = 7  //气泡顶端有大约 7 像素的透明部分，绿色部分需要和头像持平
private let kChatVoicePlayingMarginLeft: CGFloat = 16  //播放小图标距离气泡箭头的值
private let kChatVoiceMaxWidth: CGFloat = 200

class ChatFileCell: ChatBaseCell {
    @IBOutlet weak var fileIcon: UIImageView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileSizeLabel: UILabel!
    @IBOutlet weak var errorBtn: UIButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var fileBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setCellContent(_ model: ChatMessageModel) {
        super.setCellContent(model)
        fileNameLabel.text = model.filename
        do {
            let fileSize = try FileManager.default.attributesOfItem(atPath: model.localStoreName)[FileAttributeKey("NSFileSize")]
            fileSizeLabel.text = String(fileSize as? Int ?? 0)
        } catch {
            dPrint(error)
        }
        //设置 Normal 背景Image
        let stretchImage = model.fromMe ? R.image.senderTextNodeBkg() : R.image.receiverTextNodeBkg()
        let bubbleImage = stretchImage?.resizableImage(withCapInsets: UIEdgeInsets(top: 30, left: 28, bottom: 85, right: 28), resizingMode: .stretch)
        self.fileBtn.setBackgroundImage(bubbleImage, for: UIControlState())

        //发送状态
        if ChatSendStatus(rawValue: model.send_state) == .sending {
            errorBtn.isHidden = true
            indicatorView.isHidden = false
            indicatorView.startAnimating()
        } else if ChatSendStatus(rawValue: model.send_state) == .fail {
            indicatorView.isHidden = true
            errorBtn.isHidden = false
        } else {
            indicatorView.isHidden = true
            errorBtn.isHidden = true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let model = self.model else {
            return
        }

        //设置气泡的宽
        self.fileBtn.width = kChatTextMaxWidth
        //设置气泡的高度
        self.fileBtn.height = 80
        //value = 头像的底部 - 气泡透明间隔值
        self.fileBtn.top = self.nicknameLabel.bottom
        self.fileNameLabel.top = self.fileBtn.top + kChatAvatarMarginLeft
        self.fileSizeLabel.top = self.fileNameLabel.bottom
        self.fileIcon.top = self.fileBtn.top + kChatAvatarMarginLeft
        if model.fromMe {
            //value = 屏幕宽 - 头像的边距10 - 头像宽 - 气泡距离头像的 gap 值 - 文字宽 - 2倍的文字和气泡的左右距离
            self.fileBtn.left = kScreenW - kChatAvatarMarginLeft - kChatAvatarWidth - kChatBubbleMarginLeft - self.fileBtn.width
            self.fileNameLabel.width = self.fileBtn.width - self.fileIcon.width - 30
            self.fileIcon.right = self.fileBtn.right - kChatBubbleMarginLeft - kChatAvatarMarginLeft
            self.fileSizeLabel.left = self.fileBtn.left + self.fileSizeLabel.width
            self.fileNameLabel.right = self.fileIcon.left
            //失败按钮和发送中view
            self.errorBtn.right = self.fileBtn.left + kChatTextMarginLeft - 15
            self.errorBtn.top = self.fileBtn.top + (self.fileBtn.height / 2) - 10
            self.indicatorView.right = self.fileBtn.left + kChatTextMarginLeft - 15
            self.indicatorView.top = self.fileBtn.top + (self.fileBtn.height / 2) - 10
        } else {
            //value = 距离屏幕左边的距离
            self.fileBtn.left = kChatBubbleLeft - kChatBubbleMarginLeft
            self.fileNameLabel.width = self.fileBtn.width - self.fileIcon.right + 30
            self.fileNameLabel.left = self.fileIcon.right + 5
            self.fileSizeLabel.right = self.fileBtn.right - 5
            //失败按钮和发送中view
            self.indicatorView.isHidden = true
            self.errorBtn.isHidden = true
        }
    }

    class func layoutHeight(_ model: ChatMessageModel) -> CGFloat {
        if model.cellHeight != 0 {
            return model.cellHeight
        }

        model.cellHeight = 100
        return model.cellHeight
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func tapfile(_ sender: Any) {
        self.delegate?.cellDidTapedFileButton(self)
    }

    @IBAction func reSendMessage(_ sender: Any) {
        dispatch_async_safely_to_main_queue({[weak self] in
            guard let model = self?.model else {
                return
            }
            let alertVC = UIAlertController(title: "重新发送该消息", message: nil, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { _ in
                ChatHelper.reSendMsg(type: ChatMessageType.file, model: model)
            }))
            alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alertVC.show()
        })
    }
}
