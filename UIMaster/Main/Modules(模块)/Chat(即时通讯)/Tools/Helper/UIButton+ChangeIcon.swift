//
//  UIButton+ChangeIcon.swift
//  UIMaster
//
//  Created by hobson on 2018/9/27.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit

// MARK: - @extension ChatButton
extension UIButton {
    /**
     控制——切换声音按钮和键盘切换的图标变化
     
     - parameter showKeyboard: 是否显示键盘
     */
    func emotionSwiftVoiceButtonUI(showKeyboard: Bool) {
        if showKeyboard {
            self.setBackgroundImage(R.image.tool_keyboard_1(), for: UIControlState())
            self.setBackgroundImage(R.image.tool_keyboard_2(), for: .highlighted)
        } else {
            self.setBackgroundImage(R.image.tool_voice_1(), for: UIControlState())
            self.setBackgroundImage(R.image.tool_voice_2(), for: .highlighted)
        }
    }

    /**
     控制——表情按钮和键盘切换的图标变化
     
     - parameter showKeyboard: 是否显示键盘
     */
    func replaceEmotionButtonUI(showKeyboard: Bool) {
        if showKeyboard {
            self.setBackgroundImage(R.image.tool_keyboard_1(), for: UIControlState())
            self.setBackgroundImage(R.image.tool_keyboard_2(), for: .highlighted)
        } else {
            self.setBackgroundImage(R.image.tool_emotion_1(), for: UIControlState())
            self.setBackgroundImage(R.image.tool_emotion_2(), for: .highlighted)
        }
    }

    /**
     控制--声音按钮的 UI 切换
     
     - parameter isRecording: 是否开始录音
     */
    func replaceRecordButtonUI(isRecording: Bool) {
        if isRecording {
            self.setBackgroundColor(UIColor(hexString: "#C6C7CB"), forState: .normal)
            self.setBackgroundColor(UIColor(hexString: "#F3F4F8"), forState: .highlighted)
        } else {
            self.setBackgroundColor(UIColor(hexString: "#F3F4F8"), forState: .normal)
            self.setBackgroundColor(UIColor(hexString: "#C6C7CB"), forState: .highlighted)
        }
    }
}

extension UIButton {
    /**
     Set UIButton's backgroundColor with a UIImage
     
     - parameter color:    color
     - parameter forState: UIControlState
     */
    public func setBackgroundColor(_ color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()?.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(theImage, for: forState)
    }
}
