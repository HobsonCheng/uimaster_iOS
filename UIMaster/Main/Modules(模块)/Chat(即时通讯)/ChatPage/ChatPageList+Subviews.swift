//
//  ChatPageList+Subviews.swift
//  UIMaster
//
//  Created by hobson on 2018/9/27.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit

let kCustomKeyboardHeight: CGFloat = 216
//216

// MARK: - @extension TSChatViewController
extension ChatPageList {
    /**
     创建聊天的各种子 view
     */
//    func setupSubviews(_ delegate: UITextViewDelegate) {
//        self.setupActionBar(delegate)
//        self.setupKeyboardInputView()
//        self.setupVoiceIndicatorView()
//        self.setupIndicatorView()
//        self.setupNaibarEvent()
//    }

//    func setupNaibarEvent(){
//        if currentSessionModel.chat_type == 0{
//            if let assembleVC = self.parent as? AssembleVC{
//                assembleVC.addPersonCenterEventDatas(with: (currentSessionModel.receiver,currentSessionModel.receiver_pid))
//            }
//        }else{
//            if let assembleVC = self.parent as? AssembleVC{
//                let chatGroupDetail = DatabaseTool.shared.queryChatGroupInfo(gid: Int(self.currentSessionModel.session_id), pid: self.currentSessionModel.receiver_pid )
//                guard let detail  = chatGroupDetail else{
//                    HUDUtil.msg(msg: "获取群信息失败", type: .error)
//                    return
//                }
//                assembleVC.addGroupChatEventDatas(with: detail)
//            }
//        }
//        
//    }
    /**
     初始化操作栏
     */
//    fileprivate func setupActionBar(_ delegate: UITextViewDelegate) {
//        self.chatActionBarView = UIView.viewFromNib(ChatActionBarView.self)
//        self.chatActionBarView.delegate = self
//        self.chatActionBarView.inputChatView.delegate = delegate
//        self.chatActionBarView.inputTopContraint.constant = 5
//        self.view.addSubview(self.chatActionBarView)
//        self.chatActionBarView.snp.makeConstraints { [weak self] (make) -> Void in
//            guard let strongSelf = self else { return }
//            make.left.equalTo(strongSelf.view.snp.left)
//            make.right.equalTo(strongSelf.view.snp.right)
//            strongSelf.actionBarPaddingBottomConstranit = make.bottom.equalTo(strongSelf.view.snp.bottom).constraint
//            make.height.equalTo(kChatActionBarOriginalHeight)
//        }
//    }

    /**
     初始化表情键盘，分享更多键盘
     */
    fileprivate func setupKeyboardInputView() {
        //emotionInputView init
//        self.emotionInputView = UIView.viewFromNib(ChatEmotionInputView.self)
//        self.emotionInputView.delegate = self
//        self.view.addSubview(self.emotionInputView)
//        self.emotionInputView.snp.makeConstraints {[weak self] (make) -> Void in
//            guard let strongSelf = self else { return }
//            make.left.equalTo(strongSelf.view.snp.left)
//            make.right.equalTo(strongSelf.view.snp.right)
//            make.top.equalTo(strongSelf.chatActionBarView.snp.bottom).offset(0)
//            make.height.equalTo(kCustomKeyboardHeight)
//        }
//        
        //shareMoreView init
//        self.shareMoreView = UIView.viewFromNib(ChatShareMoreView.self)
//        self.shareMoreView!.delegate = self
//        self.view.addSubview(self.shareMoreView)
//        self.shareMoreView.snp.makeConstraints {[weak self] (make) -> Void in
//            guard let strongSelf = self else { return }
//            make.left.equalTo(strongSelf.view.snp.left)
//            make.right.equalTo(strongSelf.view.snp.right)
//            make.top.equalTo(strongSelf.chatActionBarView.snp.bottom).offset(0)
//            make.height.equalTo(kCustomKeyboardHeight)
//        }
    }

    /**
     初始化 VoiceIndicator
     */
    fileprivate func setupVoiceIndicatorView() {
//        //voiceIndicatorView init
//        self.voiceIndicatorView = UIView.ts_viewFromNib(TSChatVoiceIndicatorView.self)
//        self.view.addSubview(self.voiceIndicatorView)
//        self.voiceIndicatorView.snp.makeConstraints {[weak self] (make) -> Void in
//            guard let strongSelf = self else { return }
//            make.top.equalTo(strongSelf.view.snp.top).offset(100)
//            make.left.equalTo(strongSelf.view.snp.left)
//            make.bottom.equalTo(strongSelf.view.snp.bottom).offset(-100)
//            make.right.equalTo(strongSelf.view.snp.right)
//        }
//        self.voiceIndicatorView.isHidden = true
    }
}
