//
//  RecordAudioDelegate.swift
//  UIMaster
//
//  Created by hobson on 2018/9/27.
//  Copyright © 2018 one2much. All rights reserved.
//

import Foundation

/**
 *  录音的 delegate 函数
 */
protocol RecordAudioDelegate: AnyObject {
    /**
     更新进度 , 0.0 - 9.0, 浮点数
     */
    func audioRecordUpdateMetra(_ metra: Float)

    /**
     录音太短
     */
    func audioRecordTooShort()

    /**
     录音失败
     */
    func audioRecordFailed()

    /**
     取消录音
     */
    func audioRecordCanceled()

    /**
     录音完成
     
     - parameter recordTime:        录音时长
     - parameter uploadAmrData:     上传的 amr Data
     - parameter fileHash:          amr 音频数据的 MD5 值 (NSData)
     */
    func audioRecordFinish(_ uploadAmrData: Data, recordTime: Float, fileHash: String)
}

/**
 *  播放的 delegate 函数
 */
protocol PlayAudioDelegate: AnyObject {
    /**
     播放开始
     */
    func audioPlayStart()

    /**
     播放完毕
     */
    func audioPlayFinished()

    /**
     播放失败
     */
    func audioPlayFailed()

    /**
     播放被中断
     */
    func audioPlayInterruption()
}

/**
 *  表情键盘的代理方法
 */
//// MARK: - @delegate ChatEmotionInputViewDelegate
//protocol ChatEmotionInputViewDelegate: class {
//    /**
//     点击表情 Cell
//     
//     - parameter cell: 表情 cell
//     */
//    func chatEmoticonInputViewDidTapCell(_ cell: TSChatEmotionCell)
//    
//    /**
//     点击表情退后键
//     
//     - parameter cell: 退后的 cell
//     */
//    func chatEmoticonInputViewDidTapBackspace(_ cell: TSChatEmotionCell)
//    
//    /**
//     点击发送键
//     */
//    func chatEmoticonInputViewDidTapSend()
//    
//}
