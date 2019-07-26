//
//  ChatPageList+Keyboard.swift
//  UIMaster
//
//  Created by hobson on 2018/9/27.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit

// MARK: - @extension TSChatViewController
extension ChatPageList {
    /**
     键盘控制
     */
    func keyboardControl() {
        /**
         Keyboard notifications
         */
        NotificationCenter.default
            .rx.notification(Notification.Name(rawValue: Notification.Name.UIKeyboardWillShow.rawValue), object: nil)
            .subscribe(onNext: { [weak self] notification in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.shareMoreView.isHidden = true
                strongSelf.listTableView.scrollToBottomAnimated(false)
                strongSelf.keyboardControl(notification, isShowing: true)
            })
            .disposed(by: rx.disposeBag)

        NotificationCenter.default
            .rx.notification(Notification.Name(rawValue: Notification.Name.UIKeyboardDidShow.rawValue), object: nil)
            .subscribe(onNext: { notification in
                if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                    _ = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
                }
            })
            .disposed(by: rx.disposeBag)

        NotificationCenter.default
            .rx.notification(Notification.Name(rawValue: Notification.Name.UIKeyboardWillHide.rawValue), object: nil)
            .subscribe(onNext: { [weak self] notification in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.keyboardControl(notification, isShowing: false)
            })
            .disposed(by: rx.disposeBag)

        NotificationCenter.default
            .rx.notification(Notification.Name(rawValue: Notification.Name.UIKeyboardDidHide.rawValue), object: nil)
            .subscribe(onNext: { _ in
            })
            .disposed(by: rx.disposeBag)

        //        notificationCenter.addObserverForName(
        //            UIKeyboardWillChangeFrameNotification,
        //            object: nil,
        //            queue: nil
        //            ) {[weak self] (notification) in
        //                return
        //                //如果是 表情键盘或者 分享键盘 ，走自己的处理键盘事件。高度 和 inputview 动画
        //                let keyboardType = self!.chatActionBarView.keyboardType
        //                if keyboardType == .Emotion || keyboardType == .Share {
        //                    return
        //                }
        //
        //                let userInfo = notification.userInfo!
        //                let frameEnd = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue
        //                let convertedFrameEnd = self!.view.convertRect(frameEnd, fromView: nil)
        //                let heightOffset = self!.view.bounds.size.height - convertedFrameEnd.origin.y
        //                let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.unsignedIntValue
        //                let options = UIViewAnimationOptions(rawValue: UInt(curve) << 16)
        //
        //                self!.listTableView.stopScrolling()
        //                self!.actionBarPaddingBottomConstranit?.updateOffset(-heightOffset)
        //                self!.tableViewMarginBottomConstraint.constant = heightOffset + self!.chatActionBarView.height
        //                UIView.animateWithDuration(
        //                    userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue,
        //                    delay: 0,
        //                    options: options.union(.LayoutSubviews).union(.BeginFromCurrentState),
        //                    animations: {
        //                        self!.view.layoutIfNeeded()
        //                    },
        //                    completion: { bool in
        //                })
        //        }
    }

    /**
     控制键盘事件
     http://stackoverflow.com/questions/19311045/uiscrollview-animation-of-height-and-contentoffset-jumps-content-from-bottom
     - parameter notification: Notification 对象
     - parameter isShowing:    是否显示键盘？
     */
    func keyboardControl(_ notification: Notification, isShowing: Bool) {
        /*
         如果是表情键盘或者 分享键盘 ，走自己 delegate 的处理键盘事件。
         
         因为：当点击唤起自定义键盘时，操作栏的输入框需要 resignFirstResponder，这时候会给键盘发送通知。
         通知中需要对 actionbar frame 进行重置位置计算, 在 delegate 回调中进行计算。所以在这里进行拦截。
         Button 的点击方法中已经处理了 delegate。
         */
        let keyboardType = self.chatActionBarView.keyboardType
        if keyboardType == .emotion || keyboardType == .share {
            return
        }

        /*
         处理 Default, Text 的键盘属性
         */
        var userInfo = notification.userInfo!
        let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        let curve = (userInfo[UIKeyboardAnimationCurveUserInfoKey]! as AnyObject).uint32Value

        let convertedFrame = self.view.convert(keyboardRect!, from: nil)
        let heightOffset = self.view.bounds.size.height - convertedFrame.origin.y
        let options = UIViewAnimationOptions(rawValue: UInt(curve!) << 16 | UIViewAnimationOptions.beginFromCurrentState.rawValue)
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue

        self.listTableView.stopScrolling()
//        if isiPhoneX && heightOffset != 0{
//            heightOffset -= iPhoneXBottomH
//        }
        self.actionBarPaddingBottomConstranit?.update(offset: -heightOffset)

        UIView.animate(
            withDuration: duration!,
            delay: 0,
            options: options,
            animations: {
                self.view.layoutIfNeeded()
                if isShowing {
                    self.listTableView.scrollToBottom(animated: false)
                }
            },
            completion: { _ in
            }
        )
    }

    //获取键盘的高度
    func appropriateKeyboardHeight(_ notification: Notification) -> CGFloat {
        guard let endFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return 0
        }
        var keyboardHeight: CGFloat = 0.0
        if notification.name == Notification.Name.UIKeyboardWillShow {
            keyboardHeight = min(endFrame.width, endFrame.height)
        }

        if notification.name == Notification.Name("") {
            keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            keyboardHeight -= self.tabBarController!.tabBar.frame.height
        }
        return keyboardHeight
    }

    func appropriateKeyboardHeight() -> CGFloat {
        var height = self.view.bounds.size.height
        height -= self.keyboardHeightConstraint!.constant

        guard height > 0 else {
            return 0
        }
        return height
    }

    /**
     隐藏自定义键盘，当唤醒的自定义键盘时候，这时候点击切换录音 button。需要隐藏掉
     */
    fileprivate func hideCusttomKeyboard() {
        self.listTableView.stopScrolling()
        self.actionBarPaddingBottomConstranit?.update(offset: 0)

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: UIViewAnimationOptions(),
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: { _ in
            }
        )
    }

    /**
     隐藏所有键盘,
     使用场景：
     1.点击 UITableView 使用
     2.开始滚动 UITableView 使用
     */
    func hideAllKeyboard() {
        self.hideCusttomKeyboard()
        self.chatActionBarView.resignKeyboard()
    }
}

// MARK: - @delegate TSChatActionBarViewDelegate
extension ChatPageList: ChatActionBarViewDelegate {
    /**
     隐藏自定义键盘
     */
    func chatActionBarRecordVoiceHideKeyboard() {
        self.hideCusttomKeyboard()
    }

    /**
     调起表情键盘
     */
    func chatActionBarShowEmotionKeyboard() {
//        let heightOffset = self.emotionInputView.ts_height
//        self.listTableView.stopScrolling()
//        self.actionBarPaddingBottomConstranit?.update(offset: -heightOffset)
//
//        UIView.animate(
//            withDuration: 0.25,
//            delay: 0,
//            options: UIViewAnimationOptions(),
//            animations: {
//                //表情键盘归位
//                self.emotionInputView.snp.updateConstraints { make in
//                    make.top.equalTo(self.chatActionBarView.snp.bottom).offset(0)
//                }
//                //分享键盘隐藏
//                self.shareMoreView.snp.updateConstraints { make in
//                    make.top.equalTo(self.chatActionBarView.snp.bottom).offset(self.view.ts_height)
//                }
//                self.view.layoutIfNeeded()
//                self.listTableView.scrollBottomToLastRow()
//        },
//            completion: { bool in
//        })
    }

    /**
     调起分享键盘
     */
    func chatActionBarShowShareKeyboard() {
        let heightOffset = self.shareMoreView.height
        self.listTableView.stopScrolling()
        self.actionBarPaddingBottomConstranit?.update(offset: -heightOffset)
        self.shareMoreView.isHidden = false
        self.shareMoreView.top = self.view.height
        self.view.bringSubview(toFront: self.shareMoreView)
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: UIViewAnimationOptions(),
            animations: {
                //分享键盘归位，盖在表情键盘上，所以不需要控制表情键盘
                self.shareMoreView.snp.updateConstraints { make in
                    make.top.equalTo(self.chatActionBarView.snp.bottom).offset(0)
                }
                self.view.layoutIfNeeded()
                self.listTableView.scrollBottomToLastRow()
            },
            completion: { _ in
            }
        )
    }
}
