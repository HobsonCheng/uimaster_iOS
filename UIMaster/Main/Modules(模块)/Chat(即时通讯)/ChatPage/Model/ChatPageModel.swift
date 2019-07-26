//
//  ChatPageModel.swift
//  UIMaster
//
//  Created by hobson on 2018/8/20.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

class ChatPageModel: BaseData {
    var events: [String: EventsData]?
    var fields: ChatPageFields?
    var styles: ChatPageStyles?
}
class ChatPageFields: BaseData {
    var photo: Int?
    var photograph: Int?
    var position: Int?
    var text: String?
    var video: Int?
    var card: Int?
    var inputPrompt: Int?
}
class ChatPageStyles: BaseStyleModel {
    var borderWidthMy: Int?
    var heightInput: CGFloat?
    var heightMenu: CGFloat?
    var articleListStyle: Int?
    var bgImgMenu: String?
    var bgImgModeMenu: Int?
    var borderShowSys: Int?
    var borderWidth: Int?
    var iconNormalPhoto: String?
    var iconPhotograph: String?
    var opacitySwitchButton: Int?
    var titlePhoto: String?
    var bgImgModeSysMsg: Int?
    var bgImgSysMsg: String?
    var iconNormalVoice: String?
    var bgImgModeSwitchButtonSelected: Int?
    var bgImgModeYour: Int?
    var bgImgMy: String?
    var borderWidthLabel: Int?
    var iconNormalPosition: String?
    var bgColorSysMsg: String?
    var bgImgModeSwitchButton: Int?
    var heightLabel: CGFloat?
    var bgColorSwitchButton: String?
    var iconSelectedCamera: String?
    var opacitySwitchButtonSelected: Int?
    var opacitySysMsg: Int?
    var bgColorSys: String?
    var bgImgLabel: String?
    var bgImgSwitchButtonSelected: String?
    var heightSysMsg: CGFloat?
    var bgImgModeMy: Int?
    var bgImgSwitchButton: String?
    var opacityMy: Int?
    var titlePhotograph: String?
    var iconSelectedVideo: String?
    var bgImgInput: String?
    var bgImgModeLabel: Int?
    var borderShowInput: Int?
    var borderWidthInput: Int?
    var iconSelectedPosition: String?
    var iconPosition: String?
    var borderColorLabel: String?
    var borderColorSys: String?
    var borderShow: Int?
    var borderWidthYour: Int?
    var iconNormalFace: String?
    var bgColorMenu: String?
    var bgColorMy: String?
    var borderColorInput: String?
    var opacityLabel: Int?
    var bgColorLabel: String?
    var borderColor: String?
    var borderShowLabel: Int?
    var iconSelectedPhoto: String?
    var iconSelectedFace: String?
    var bgColorInput: String?
    var bgColorYour: String?
    var bgImgYour: String?
    var iconCard: String?
    var iconPhoto: String?
    var titlePosition: String?
    var bgColorSwitchButtonSelected: String?
    var borderColorMy: String?
    var iconVideo: String?
    var opacityYour: Int?
    var titleVideo: String?
    var bgImgModeSys: Int?
    var iconNormalCamera: String?
    var iconSelectedVoice: String?
    var opacityInput: Int?
    var opacityMenu: Int?
    var opacitySys: Int?
    var bgImgSys: String?
    var borderColorYour: String?
    var borderShowMy: Int?
    var borderShowYour: Int?
    var iconNormalMenu: String?
    var titleCard: String?
    var bgImgModeInput: Int?
    var borderWidthSys: Int?
    var iconNormalVideo: String?
    var iconSelectedMenu: String?
    var imgTextMargin: CGFloat?
}
