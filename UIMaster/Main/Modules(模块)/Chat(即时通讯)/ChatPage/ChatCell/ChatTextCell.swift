//
//  TSChatTextView.swift
//  TSWeChat
//
//  Created by Hilen on 12/22/15.
//  Copyright © 2015 Hilen. All rights reserved.
//

import UIKit
import YYText

let kChatTextLeft: CGFloat = 72                                         //消息在左边的时候， 文字距离屏幕左边的距离
let kChatTextMaxWidth: CGFloat = kScreenW - kChatTextLeft - 82    //消息在右边， 70：文本离屏幕左的距离，  82：文本离屏幕右的距离
let kChatTextMarginTop: CGFloat = 11                                    //文字的顶部和气泡顶部相差 12 像素
let kChatTextMarginBottom: CGFloat = 11                                 //文字的底部和气泡底部相差 11 像素
let kChatTextMarginLeft: CGFloat = 22                                   //文字的左边 和气泡的左边相差 17 ,包括剪头部门
let kChatBubbleWidthBuffer: CGFloat = kChatTextMarginLeft * 2             //气泡比文字的宽度多出的值
let kChatBubbleBottomTransparentHeight: CGFloat = 11                    //气泡底部的透明高度 11
let kChatBubbleHeightBuffer: CGFloat = kChatTextMarginTop + kChatTextMarginBottom  //文字的顶部 + 文字底部距离
let kChatBubbleImageViewHeight: CGFloat = 54                            //气泡最小高 54 ，防止拉伸图片变形
let kChatBubbleImageViewWidth: CGFloat = 50                             //气泡最小宽 50 ，防止拉伸图片变形
let kChatBubblePaddingTop: CGFloat = 3                                  //气泡顶端有大约 3 像素的透明部分，需要和头像持平
let kChatBubbleMarginLeft: CGFloat = 5                                   //气泡和头像的 gap 值：5
let kChatBubblePaddingBottom: CGFloat = 8                               //气泡距离底部分割线 gap 值：8
let kChatBubbleLeft: CGFloat = kChatAvatarMarginLeft + kChatAvatarWidth + kChatBubbleMarginLeft  //气泡距离屏幕左的距
private let kChatTextFont = UIFont.systemFont(ofSize: 16)
//extension YYLabel{
//    override open var canBecomeFirstResponder: Bool{ return true }
//    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        if action == #selector(ChatTextCell.copyToPasteboard) {return true}
//        return false
//    }
//}
class ChatTextCell: ChatBaseCell, UIMenuAble {
    @IBOutlet weak var contentLabel: YYLabel! {
        didSet {
            contentLabel.font = kChatTextFont
            contentLabel.numberOfLines = 0
            contentLabel.backgroundColor = .clear
            contentLabel.isUserInteractionEnabled = true
            contentLabel.textVerticalAlignment = YYTextVerticalAlignment.top
            contentLabel.displaysAsynchronously = false
            contentLabel.ignoreCommonProperties = true
            contentLabel.isUserInteractionEnabled = true
            contentLabel.highlightTapAction = ({[weak self] containerView, text, range, rect in
                self!.didTapRichLabelText(self!.contentLabel, textRange: range)
            })
            contentLabel.textLongPressAction = ({[weak self] containerView, text, range, rect in
                HUDUtil.msg(msg: "已复制消息", type: .successful)
                UIPasteboard.general.string = self?.model?.richTextAttributedString?.string
            })
            //        contentLabel.setUpLongPress(view: self, lable: contentLabel)
        }}
    @IBOutlet weak var bubbleImageView: UIImageView!
    @IBOutlet weak var errorBtn: UIButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
//        contentLabel.rx.longPressGesture().subscribe(onNext: { [weak self] (guestrue) in
//            guard let strongSelf = self else { return }
//            if guestrue.state == .began{
//                self?.contentLabel.becomeFirstResponder()
//                DispatchQueue.main.async {
//                    let itemConfig = MenuItemConfig.init(title: "复制", action:  #selector(self?.copyToPasteboard))
//                    strongSelf.setupMenuController(configs: [itemConfig], targetFrame: self?.contentLabel.frame ?? .zero, in: strongSelf)
//                }
//            }
//        }).disposed(by: rx.disposeBag)
    }
//    @objc func copyToPasteboard() {
//        UIPasteboard.general.string = self.contentLabel.text
//    }

//    func debugYYLabel() -> YYTextDebugOption {
//        let debugOptions = YYTextDebugOption()
//        debugOptions.baselineColor = UIColor.red
//        debugOptions.ctFrameBorderColor = UIColor.red
//        debugOptions.ctLineFillColor = UIColor ( red: 0.0, green: 0.463, blue: 1.0, alpha: 0.18 )
//        debugOptions.cgGlyphBorderColor = UIColor ( red: 0.9971, green: 0.6738, blue: 1.0, alpha: 0.360964912280702 )
//        return debugOptions
//    }

    override func setCellContent(_ model: ChatMessageModel) {
        super.setCellContent(model)
        if let richTextLinePositionModifier = model.richTextLinePositionModifier {
            self.contentLabel.linePositionModifier = richTextLinePositionModifier
        }

        if let richTextLayout = model.richTextLayout {
            self.contentLabel.textLayout = richTextLayout
        }

        if let richTextAttributedString = model.richTextAttributedString {
            self.contentLabel.attributedText = richTextAttributedString
        }

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

        //拉伸图片区域
        let stretchImage = (model.fromMe ? R.image.senderTextNodeBkg() : R.image.receiverTextNodeBkg()) ?? UIImage.from(color: UIColor(hexString: "#777777"))
        let bubbleImage = stretchImage.resizableImage(withCapInsets: UIEdgeInsets(top: 30, left: 28, bottom: 85, right: 28), resizingMode: .stretch)
        self.bubbleImageView.image = bubbleImage
        self.setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let model = self.model else {
            return
        }

        self.contentLabel.size = model.richTextLayout!.textBoundingSize

        if model.fromMe {
            //value = 屏幕宽 - 头像的边距10 - 头像宽 - 气泡距离头像的 gap 值 - (文字宽 - 2倍的文字和气泡的左右距离 , 或者是最小的气泡图片距离)
            self.bubbleImageView.left = kScreenW - kChatAvatarMarginLeft - kChatAvatarWidth - kChatBubbleMarginLeft - max(self.contentLabel.width + kChatBubbleWidthBuffer, kChatBubbleImageViewWidth)
        } else {
            //value = 距离屏幕左边的距离
            self.bubbleImageView.left = kChatBubbleLeft
        }
        //设置气泡的宽
        self.bubbleImageView.width = max(self.contentLabel.width + kChatBubbleWidthBuffer, kChatBubbleImageViewWidth)
        //设置气泡的高度
        self.bubbleImageView.height = max(self.contentLabel.height + kChatBubbleHeightBuffer + kChatBubbleBottomTransparentHeight, kChatBubbleImageViewHeight)
        //value = 头像的底部 - 气泡透明间隔值
        self.bubbleImageView.top = self.nicknameLabel.bottom - kChatBubblePaddingTop + 7
        //valeu = 气泡顶部 + 文字和气泡的差值
        self.contentLabel.top = self.bubbleImageView.top + kChatTextMarginTop
        //valeu = 气泡左边 + 文字和气泡的差值
        self.contentLabel.left = self.bubbleImageView.left + kChatTextMarginLeft

        if model.fromMe {
            self.indicatorView.right = self.contentLabel.left - kChatTextMarginLeft - 8
            self.indicatorView.top = self.contentLabel.top + (self.contentLabel.height / 2) - 10
            self.errorBtn.right = self.contentLabel.left - kChatTextMarginLeft - 8
            self.errorBtn.top = self.contentLabel.top + (self.contentLabel.height / 2) - 10
        } else {
            self.indicatorView.isHidden = true
            self.errorBtn.isHidden = true
        }
        if model.chat_type == 1 {
        }
    }

    class func layoutHeight(_ model: ChatMessageModel) -> CGFloat {
        if model.cellHeight != 0 {
            return model.cellHeight
        }
        //解析富文本
        let attributedString = ChatTextParser.parseText(model.content, font: kChatTextFont,fromMe: model.fromMe) ?? NSMutableAttributedString()
        model.richTextAttributedString = attributedString

        //初始化排版布局对象
        let modifier = TextLinePositionModifier(font: kChatTextFont)
        model.richTextLinePositionModifier = modifier

        //初始化 YYTextContainer
        let textContainer = YYTextContainer()
        textContainer.size = CGSize(width: kChatTextMaxWidth, height: CGFloat.greatestFiniteMagnitude)
        textContainer.linePositionModifier = modifier
        textContainer.maximumNumberOfRows = 0

        //设置 layout
        let textLayout = YYTextLayout(container: textContainer, text: attributedString)
        model.richTextLayout = textLayout

        //计算高度
        var height: CGFloat = kChatAvatarMarginTop + kChatBubblePaddingBottom
        let stringHeight = modifier.heightForLineCount(Int(textLayout!.rowCount))

        height += max(stringHeight + kChatBubbleHeightBuffer + kChatBubbleBottomTransparentHeight, kChatBubbleImageViewHeight)
        model.cellHeight = height
        return model.cellHeight
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func sendFailed(_ sender: Any) {
        dispatch_async_safely_to_main_queue({[weak self] in
            guard let model = self?.model else {
                return
            }
            let alertVC = UIAlertController(title: "重新发送该消息", message: nil, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { _ in
                ChatHelper.reSendMsg(type: .text, model: model)
            }))
            alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alertVC.show()
        })
    }
    /**
     解析点击文字
     
     - parameter label:     YYLabel
     - parameter textRange: 高亮文字的 NSRange，不是 range
     */
    fileprivate func didTapRichLabelText(_ label: YYLabel, textRange: NSRange) {
        //解析 userinfo 的文字
        let attributedString = label.textLayout!.text
        if textRange.location >= attributedString.length {
            return
        }
        guard let hightlight: YYTextHighlight = attributedString.yy_attribute(YYTextHighlightAttributeName, at: UInt(textRange.location)) as? YYTextHighlight else {
            return
        }
        guard let info = hightlight.userInfo, !(info.isEmpty) else {
            return
        }

        guard let delegate = self.delegate else {
            return
        }

        if let phone: String = info[kChatTextKeyPhone] as? String {
            delegate.cellDidTapedPhone(self, phoneString: phone)
        }

        if let URL: String = info[kChatTextKeyURL] as? String {
            delegate.cellDidTapedLink(self, linkString: URL)
        }
    }
}
