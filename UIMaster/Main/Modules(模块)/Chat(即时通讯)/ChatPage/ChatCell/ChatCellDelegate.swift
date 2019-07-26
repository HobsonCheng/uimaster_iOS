//
//  ChatCellDelegate.swift
//  TSWeChat
//
//  Created by Hilen on 1/29/16.
//  Copyright © 2016 Hilen. All rights reserved.
//

import Foundation

@objc protocol ChatCellDelegate: AnyObject {
    /**
     点击了 cell 本身
     */
    @objc optional func cellDidTaped(_ cell: ChatBaseCell)

    /**
     点击了 cell 的头像
     */
    func cellDidTapedAvatarImage(_ cell: ChatBaseCell)

    /**
     点击了 cell 的图片
     */
    func cellDidTapedImageView(_ cell: ChatBaseCell)
    /**
     点击了声音 cell 的文件 button
     */
    func cellDidTapedFileButton(_ cell: ChatFileCell)
    /**
     点击了 cell 中文字的 URL
     */
    func cellDidTapedLink(_ cell: ChatBaseCell, linkString: String)

    /**
     点击了 cell 中文字的 电话
     */
    func cellDidTapedPhone(_ cell: ChatBaseCell, phoneString: String)

    /**
     点击了声音 cell 的播放 button
     */
    func cellDidTapedVoiceButton(_ cell: ChatVoiceCell, isPlayingVoice: Bool)
}
