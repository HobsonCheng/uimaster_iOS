//
//  TSChatVoiceView.swift
//  TSWeChat
//
//  Created by Hilen on 12/22/15.
//  Copyright © 2015 Hilen. All rights reserved.
//

import UIKit

private let kChatVoiceBubbleTopTransparentGapValue: CGFloat = 7  //气泡顶端有大约 7 像素的透明部分，绿色部分需要和头像持平
private let kChatVoicePlayingMarginLeft: CGFloat = 16  //播放小图标距离气泡箭头的值
private let kChatVoiceMaxWidth: CGFloat = 200

class ChatVoiceCell: ChatBaseCell {
    @IBOutlet weak var listenVoiceButton: UIButton! {didSet {
            listenVoiceButton.imageView!.animationDuration = 1
            listenVoiceButton.isSelected = false
        }}

    @IBOutlet weak var durationLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setCellContent(_ model: ChatMessageModel) {
        super.setCellContent(model)
        self.durationLabel.text = String(format: "%zd\"", Int(model.duration))

        //设置 Normal 背景Image
        let stretchImage = model.fromMe ? R.image.senderTextNodeBkg() : R.image.receiverTextNodeBkg()
        let bubbleImage = stretchImage?.resizableImage(withCapInsets: UIEdgeInsets(top: 30, left: 28, bottom: 85, right: 28), resizingMode: .stretch)
        self.listenVoiceButton.setBackgroundImage(bubbleImage, for: UIControlState())

        //设置 Highlighted  背景Image
        let stretchImageHL = model.fromMe ? R.image.senderTextNodeBkgHL() : R.image.receiverTextNodeBkgHL()
        let bubbleImageHL = stretchImageHL?.resizableImage(withCapInsets: UIEdgeInsets(top: 30, left: 28, bottom: 85, right: 28), resizingMode: .stretch)
        self.listenVoiceButton.setBackgroundImage(bubbleImageHL, for: .highlighted)

        //设置声音 icon 的 Image
        let voiceImage = model.fromMe ? R.image.senderVoiceNodePlaying() : R.image.receiverVoiceNodePlaying()
        self.listenVoiceButton.setImage(voiceImage, for: UIControlState())

        //设置声音 icon 的 Edge
        self.listenVoiceButton.imageEdgeInsets = model.fromMe ? UIEdgeInsets(top: -kChatBubbleBottomTransparentHeight, left: 0, bottom: 0, right: kChatVoicePlayingMarginLeft) : UIEdgeInsets(top: -kChatBubbleBottomTransparentHeight, left: kChatVoicePlayingMarginLeft, bottom: 0, right: 0)

        //设置声音 icon 的对齐方式
        self.listenVoiceButton.contentHorizontalAlignment = model.fromMe ? .right : .left

        if model.fromMe {
            self.listenVoiceButton.imageView!.animationImages = [
                R.image.senderVoiceNodePlaying001() ?? UIImage.from(color: UIColor(hexString: "#777777")),
                R.image.senderVoiceNodePlaying002() ?? UIImage.from(color: UIColor(hexString: "#777777")),
                R.image.senderVoiceNodePlaying003() ?? UIImage.from(color: UIColor(hexString: "#777777"))
            ]
        } else {
            self.listenVoiceButton.imageView!.animationImages = [
                R.image.receiverVoiceNodePlaying001() ?? UIImage.from(color: UIColor(hexString: "#777777")),
                R.image.receiverVoiceNodePlaying002() ?? UIImage.from(color: UIColor(hexString: "#777777")),
                R.image.receiverVoiceNodePlaying003() ?? UIImage.from(color: UIColor(hexString: "#777777"))
            ]
        }
    }

    @IBAction func playingTaped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.listenVoiceButton.imageView!.startAnimating()
        } else {
            self.listenVoiceButton.imageView!.stopAnimating()
        }

        guard let delegate = self.delegate else {
            return
        }
        delegate.cellDidTapedVoiceButton(self, isPlayingVoice: sender.isSelected)
    }

    //停止音频的动画
    func resetVoiceAnimation() {
        self.listenVoiceButton.imageView!.stopAnimating()
        self.listenVoiceButton.isSelected = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let model = self.model else {
            return
        }
        let duration = model.duration
        guard duration > 0 else {
            return
        }

        let voiceLength = 70 + 130 * CGFloat(duration / 60)

        //设置气泡的宽
        self.listenVoiceButton.width = min(voiceLength, kChatVoiceMaxWidth)
        //设置气泡的高度
        self.listenVoiceButton.height = kChatBubbleImageViewHeight
        //value = 头像的底部 - 气泡透明间隔值
        self.listenVoiceButton.top = self.nicknameLabel.bottom - kChatVoiceBubbleTopTransparentGapValue

        if model.fromMe {
            //value = 屏幕宽 - 头像的边距10 - 头像宽 - 气泡距离头像的 gap 值 - 文字宽 - 2倍的文字和气泡的左右距离
            self.listenVoiceButton.left = kScreenW - kChatAvatarMarginLeft - kChatAvatarWidth - kChatBubbleMarginLeft - self.listenVoiceButton.width
            //value = 声音的左 - 秒数文字的宽 - 间隔值
            self.durationLabel.left = self.listenVoiceButton.left - self.durationLabel.width
            self.durationLabel.textAlignment = .right
        } else {
            //value = 距离屏幕左边的距离
            self.listenVoiceButton.left = kChatBubbleLeft
            //value = 声音的右+间隔值
            self.durationLabel.left = self.listenVoiceButton.right
            self.durationLabel.textAlignment = .left
        }

        self.durationLabel.height = self.listenVoiceButton.height
        self.durationLabel.top = self.listenVoiceButton.top
    }

    class func layoutHeight(_ model: ChatMessageModel) -> CGFloat {
        if model.cellHeight != 0 {
            return model.cellHeight
        }

        if model.duration == 0 {
            return 0
        }

        var height: CGFloat = 0
        height += kChatAvatarMarginTop + kChatBubblePaddingBottom
        height += kChatBubbleImageViewHeight
        model.cellHeight = height
        return model.cellHeight
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
