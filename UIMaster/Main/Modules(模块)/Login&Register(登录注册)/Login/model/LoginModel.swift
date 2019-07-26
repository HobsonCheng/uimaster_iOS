//
// Created by hobson on 2018/8/14.
// Copyright (c) 2018 one2much. All rights reserved.
//

import UIKit
// swiftlint:disable identifier_name
class LoginModel: BaseData {
    var pageEvent: LoginPageEvent?
    var styles: LoginStyles?
    var events: [String: EventsData]?
    var fields: LoginFields?
}
class LoginStyles: BaseStyleModel {
    var heightBtnHeight: CGFloat?
    var iconVerifyingCode: String?
    var loginStyleChoose: Int?
    var opacityBtnAct: Int?
    var opacityInput: Int?
    var bgColorBtn: String?
    var bgColorInput: String?
    var opacityBtn: Int?
    var bgImgModeInput: Int?
    var borderColor: String?
    var titleNickName: String?
    var bgImgBtnAct: String?
    var iconAppPic: String?
    var bgImgModeBtn: Int?
    var borderWidth: CGFloat?
    var client_type: Int?
    var heightBtn: CGFloat?
    var iconNickName: String?
    var iconPassword: String?
    var showShape: Int?
    var titleAppPic: String?
    var bgImgInput: String?
    var bgImgModeBtnAct: Int?
    var widthBtn: CGFloat?
    var bgImgBtn: String?
    var widthBtnWidth: CGFloat?
    var borderShow: Int?
    var titlePassword: String?
    var bgColorBtnAct: String?
    var titleVerifyingCode: String?
}
class LoginFields: BaseData {
    var appPic: Int?
    var textBackPassword: String?
    var textImmediateRegistration: String?
    var textLoginButton: String?
}
class LoginPageEvent: BaseData {
    var register: String?
    var retrieve: String?
}
