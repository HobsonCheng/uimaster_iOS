//
//  ChatActionBarView.swift
//  UIMaster
//
//  Created by hobson on 2018/9/26.
//  Copyright © 2018 one2much. All rights reserved.
//

import RxSwift
import UIKit
//isiPhoneX ? iPhoneXBottomH + 50 :
let kChatActionBarOriginalHeight: CGFloat = 50      //ActionBar orginal height
let kChatActionBarTextViewMaxHeight: CGFloat = 120   //Expandable textview max height

/**
 *  表情按钮和分享按钮来控制键盘位置
 */
protocol ChatActionBarViewDelegate: AnyObject {
    /**
     不显示任何自定义键盘，并且回调中处理键盘frame
     当唤醒的自定义键盘时候，这时候点击切换录音 button。需要隐藏掉
     */
    func chatActionBarRecordVoiceHideKeyboard()

    /**
     显示表情键盘，并且处理键盘高度
     */
    func chatActionBarShowEmotionKeyboard()

    /**
     显示分享键盘，并且处理键盘高度
     */
    func chatActionBarShowShareKeyboard()
}

class ChatActionBarView: UIView {
    enum ChatKeyboardType: Int {
        case `default`, text, emotion, share
    }

    var keyboardType: ChatKeyboardType? = .default
    weak var delegate: ChatActionBarViewDelegate?
    var inputTextViewCurrentHeight: CGFloat = kChatActionBarOriginalHeight

    @IBOutlet weak var inputChatView: UITextView! {
        didSet {
            inputChatView.font = UIFont.systemFont(ofSize: 17)
            inputChatView.layer.borderColor = UIColor(hexString: "#DADADA").cgColor
            inputChatView.layer.borderWidth = 1
            inputChatView.layer.cornerRadius = 5.0
            inputChatView.scrollsToTop = false
            inputChatView.textContainerInset = UIEdgeInsets(top: 7, left: 5, bottom: 5, right: 5)
            inputChatView.backgroundColor = UIColor(hexString: "#f8fefb")
            inputChatView.returnKeyType = .send
            inputChatView.isHidden = false
            inputChatView.textContainer.lineFragmentPadding = 0
            inputChatView.enablesReturnKeyAutomatically = true
            inputChatView.layoutManager.allowsNonContiguousLayout = false
            inputChatView.showsVerticalScrollIndicator = true
            inputChatView.scrollsToTop = false
        }
    }
    @IBOutlet weak var shareBtn: ChatButton! {
        didSet {
            shareBtn.showTypingKeyboard = false
        }
    }
    @IBOutlet weak var voiceBtn: ChatButton!
    @IBOutlet weak var inputTopContraint: NSLayoutConstraint!

    @IBOutlet weak var recieverNameLabel: UILabel!
    @IBOutlet weak var recieverAvator: UIImageView!
    @IBOutlet weak var emojiBtn: ChatButton! {
        didSet {
            emojiBtn.showTypingKeyboard = false
        }
    }

    @IBOutlet weak var recordBtn: UIButton! {
        didSet {
            recordBtn.setBackgroundImage(UIImage.imageWithColor(UIColor(hexString: "#F3F4F8")), for: .normal)
            recordBtn.setBackgroundImage(UIImage.imageWithColor(UIColor(hexString: "#C6C7CB")), for: .highlighted)
            recordBtn.layer.borderColor = UIColor(hexString: "#C2C3C7").cgColor
            recordBtn.layer.borderWidth = 0.5
            recordBtn.layer.cornerRadius = 5.0
            recordBtn.layer.masksToBounds = true
            recordBtn.isHidden = true
        }
    }

    /// 当前的sessionID
    var currentSessionID: Int64?
    /// 聊天类型
    var chatType: Int?

    override init (frame: CGRect) {
        super.init(frame: frame)
        self.initContent()
    }

    convenience init () {
        self.init(frame: CGRect.zero)
        self.initContent()
    }
    override func awakeFromNib() {
        initContent()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func initContent() {
        let topBorder = UIView()
        let bottomBorder = UIView()
        topBorder.backgroundColor = UIColor(hexString: "#C2C3C7")
        bottomBorder.backgroundColor = UIColor(hexString: "#C2C3C7")
        self.addSubview(topBorder)
        self.addSubview(bottomBorder)

        topBorder.snp.makeConstraints { make -> Void in
            make.top.left.right.equalTo(self)
            make.height.equalTo(0.5)
        }
        bottomBorder.snp.makeConstraints { make -> Void in
            make.bottom.left.right.equalTo(self)
            make.height.equalTo(0.5)
        }

        //文字框的点击，唤醒键盘
        let tap = UITapGestureRecognizer()
        self.inputChatView.addGestureRecognizer(tap)
        tap.rx.event.subscribe { [weak self] _ in
            self?.inputChatView.inputView = nil
            self?.inputChatView.becomeFirstResponder()
            self?.inputChatView.reloadInputViews()
        }.disposed(by: rx.disposeBag)
    }
}

extension ChatActionBarView {
    //重置所有 Button 的图片
    func resetButtonUI() {
        voiceBtn.setBackgroundImage(R.image.tool_voice_1(), for: .normal)
        voiceBtn.setBackgroundImage(R.image.tool_voice_2(), for: .highlighted)

        emojiBtn.setBackgroundImage(R.image.tool_emotion_1(), for: .normal)
        emojiBtn.setBackgroundImage(R.image.tool_emotion_2(), for: .highlighted)

        shareBtn.setBackgroundImage(R.image.tool_share_1(), for: .normal)
        shareBtn.setBackgroundImage(R.image.tool_share_2(), for: .highlighted)
    }

    //当是表情键盘 或者 分享键盘的时候，此时点击文本输入框，唤醒键盘事件。
    func inputTextViewCallKeyboard() {
        self.keyboardType = .text
        self.inputChatView.isHidden = false
        shareBtn.setBackgroundImage(R.image.tool_share_1(), for: .normal)
        //设置接下来按钮的动作
        self.recordBtn.isHidden = true
        voiceBtn.showTypingKeyboard = false
        emojiBtn.showTypingKeyboard = false
        shareBtn.showTypingKeyboard = false
    }

    //显示文字输入的键盘
    func showTyingKeyboard() {
        self.keyboardType = .text
        self.inputChatView.becomeFirstResponder()
        self.inputChatView.isHidden = false

        //设置接下来按钮的动作
        self.recordBtn.isHidden = true
        voiceBtn.showTypingKeyboard = false
        emojiBtn.showTypingKeyboard = false
        shareBtn.showTypingKeyboard = false
    }

    //显示录音
    func showRecording() {
        self.keyboardType = .default
        self.inputChatView.resignFirstResponder()
        self.inputChatView.isHidden = true
        if let delegate = self.delegate {
            delegate.chatActionBarRecordVoiceHideKeyboard()
        }
        //设置接下来按钮的动作
        self.recordBtn.isHidden = false
        voiceBtn.showTypingKeyboard = true
        emojiBtn.showTypingKeyboard = false
        shareBtn.showTypingKeyboard = false
    }

    /*
     显示表情键盘
     当点击唤起自定义键盘时，操作栏的输入框需要 resignFirstResponder，这时候会给键盘发送通知。
     通知在  TSChatViewController+Keyboard.swift 中需要对 actionbar 进行重置位置计算
     */
    func showEmotionKeyboard() {
        self.keyboardType = .emotion
        self.inputChatView.resignFirstResponder()
        self.inputChatView.isHidden = false
        if let delegate = self.delegate {
            delegate.chatActionBarShowEmotionKeyboard()
        }

        //设置接下来按钮的动作
        self.recordBtn.isHidden = true
        emojiBtn.showTypingKeyboard = true
        shareBtn.showTypingKeyboard = false
    }

    //显示分享键盘
    func showShareKeyboard() {
        self.keyboardType = .share
        self.inputChatView.resignFirstResponder()
        self.inputChatView.isHidden = false
        shareBtn.setBackgroundImage(R.image.tool_close(), for: .normal)
        if let delegate = self.delegate {
            delegate.chatActionBarShowShareKeyboard()
        }

        //设置接下来按钮的动作
        self.recordBtn.isHidden = true
        emojiBtn.showTypingKeyboard = false
        shareBtn.showTypingKeyboard = true
    }

    //取消输入
    func resignKeyboard() {
        self.keyboardType = .default
        self.shareBtn.setBackgroundImage(R.image.tool_share_1(), for: .normal)
        self.inputChatView.resignFirstResponder()
        let content = self.inputChatView.text
        if let sessionID = currentSessionID, let type = chatType {
            DatabaseTool.shared.modifyDraft(with: sessionID, chatType: type, content: content ?? "")
        }
        //设置接下来按钮的动作
        emojiBtn.showTypingKeyboard = false
        shareBtn.showTypingKeyboard = false
    }
}
