//
//  AccountLoginable.swift
//  UIDS
//
//  Created by one2much on 2018/1/17.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Foundation
import NSObject_Rx
import RxCocoa
import RxSwift
import SwiftyJSON
import Then
import UIKit

// MARK: - 事件
struct AccountLoginEvent {
    // MARK: - 事件类型
    enum AccountLoginType {
        case login
        case forget
        case weixin
        case weibo
        case qq
        case regist
    }

    var type: AccountLoginType
    var title: String?

    init(type: AccountLoginType, title: String?) {
        self.type = type
        self.title = title
    }
}

struct Metric {
    static let fieldHeight: CGFloat = 45.0

    static let tipBtnWidth: CGFloat = 40.0
    static let borderWidth: CGFloat = 1.0
    static let cornerRadius: CGFloat = 3.0

    static let fontSize = UIFont.systemFont(ofSize: 18)

    static let loginBtnHeight: CGFloat = 40.0
    static let loginBtnFontSize = UIFont.systemFont(ofSize: 16)
    static let forgetFontSize = UIFont.systemFont(ofSize: 13)
    static let loginBtnTitle = "登录"
    static let regBtnTitle = "注册"
    static let regNowBtnTitle = "立即注册"
    static let forgetBtnTitle = "找回密码"
    static let accountLeftTip = "+86"
    static let accountPlaceholder = "请输入手机号/邮箱"
    static let passswordPlaceholder = "请输入密码"
    static let imgCodePlaceholder = "请输入验证码"

    static let leftTitle = "账号密码登录"
    static let rightTitle = "快捷免密登录"

    static let pagerBarFontSize = UIFont.systemFont(ofSize: 15.0)
    static let pagerBarHeight: CGFloat = 49.0
}

protocol AccountLoginable {
}
// MARK: - 自定义组件
private var keyConfigModel: Void?

extension AccountLoginable where Self: UIView {
    //    var configModel: LoginViewConfiguration? {
    //        set {
    //            objc_setAssociatedObject(self, &key_configModel, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    //        }
    //        get {
    //            return objc_getAssociatedObject(self, &key_configModel) as? LoginViewConfiguration
    //        }
    //    }

    // MARK: - 其他登录方式
    //    func initOtherLoginView(onNext: @escaping (_ event: AccountLoginEvent)->Void) -> UIView {
    //        // 创建
    //        let otherLoginView = OtherLoginModeView.loadFromXib() as! OtherLoginModeView
    //
    //        otherLoginView.weixinBtn.rx.tap.do(onNext: {
    //
    //            HUDUtil.msg(msg: "通用版APP无法第三方授权登录", type: .info)
    //
    //            onNext(AccountLoginEvent.init(type: .weixin, title: "微信登陆"))
    //        }).subscribe().disposed(by: rx.disposeBag)
    //
    //        otherLoginView.weiboBtn.rx.tap.do(onNext: {
    //
    //            HUDUtil.msg(msg: "通用版APP无法第三方授权登录", type: .info)
    //
    //            onNext(AccountLoginEvent.init(type: .weibo, title: "微博登陆"))
    //        }).subscribe().disposed(by: rx.disposeBag)
    //
    //        otherLoginView.qqBtn.rx.tap.do(onNext: {
    //            HUDUtil.msg(msg: "通用版APP无法第三方授权登录", type: .info)
    //            onNext(AccountLoginEvent.init(type: .qq, title: "QQ登陆"))
    //        }).subscribe().disposed(by: rx.disposeBag)
    //
    //        return otherLoginView
    //    }

    // MARK: - 登录按钮部分
    func initLoginBtnView() -> (UIView, UIButton) {
        // 创建
        let btnView = UIView().then {
            $0.backgroundColor = .clear
        }

        let loginBtn = UIButton().then {
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = Metric.cornerRadius
            //            $0.titleLabel?.font = UIFont.systemFont(ofSize: configModel?.btnTitleFont ?? 17)
            //            $0.setTitleColor(configModel?.btnTitleNormalColor ?? kThemeWhiteColor, for: .normal)
            //            if let hColor = configModel?.btnTitleHighlightedColor {
            //                $0.setTitleColor(hColor, for: .highlighted)
            //            }
            $0.setTitle(Metric.loginBtnTitle, for: .normal)
            $0.backgroundColor = kNaviBarBackGroundColor

            //            if let normalImgUrl = configModel?.btnBackgroundNormalImageURL {
            //                $0.sd_setBackgroundImage(with: URL(string: normalImgUrl), for: .normal, completed: nil)
            //            } else if let normalBackColor = configModel?.btnBackgroundNormalColor {
            //                $0.setBackgroundImage(UIImage.from(color: normalBackColor), for: .normal)
            //            }

            //            if let highlightedImgUrl = configModel?.btnBackgroundHighlightedImageURL {
            //                $0.sd_setBackgroundImage(with: URL(string: highlightedImgUrl), for: .highlighted, completed: nil)
            //            } else if let highlightedBackColor = configModel?.btnBackgroundHighlightedColor {
            //                $0.setBackgroundImage(UIImage.from(color: highlightedBackColor), for: .highlighted)
            //            }
            //            $0.rx.tap.do(onNext: {
            //                onNext(AccountLoginEvent.init(type: .login, title: "登陆按钮"))
            //            }).subscribe().disposed(by: rx.disposeBag)
        }
        // 添加
        btnView.addSubview(loginBtn)

        // 布局
        loginBtn.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }

        return (btnView, loginBtn)
    }
    func initRegistAndForgetPassword(showButtons: Bool, onNext: @escaping (_ event: AccountLoginEvent) -> Void) -> (UIView, UIButton, UIButton) {
        let btnView = UIView().then {
            $0.backgroundColor = .clear
        }

        let registBtn = UIButton().then {
            $0.setTitle(Metric.regNowBtnTitle, for: .normal)
            $0.setTitleColor(kThemeGreyColor, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            $0.rx.tap
                .do(onNext: {
                    onNext(AccountLoginEvent(type: .regist, title: "立即注册"))
                })
                .subscribe()
                .disposed(by: rx.disposeBag)
        }

        let forgetBtn = UIButton().then {
            //            $0.isHidden = true
            $0.setTitle(Metric.forgetBtnTitle, for: .normal)
            $0.setTitleColor( kThemeGreyColor, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            $0.rx.tap
                .do(
                    onNext: {
                        onNext(AccountLoginEvent(type: .forget, title: "忘记密码"))
                    }
                )
                .subscribe()
                .disposed(by: rx.disposeBag)
        }
        let separatorView = UIView().then {
            $0.backgroundColor = "34,153,238,1".toColor()
        }
        if showButtons {
            btnView.addSubview(registBtn)
            btnView.addSubview(forgetBtn)
            btnView.addSubview(separatorView)

            registBtn.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalTo(90)
                make.centerX.equalToSuperview().offset(-41)
                //            if let width = registBtn.titleLabel?.text?.getSize(font: Metric.forgetFontSize).width {
                //                make.width.equalTo(width)
                //            }
            }
            separatorView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.left.equalTo(registBtn.snp.right)
                make.height.equalTo(registBtn)
                make.width.equalTo(1)
            }
            forgetBtn.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalTo(90)
                //                if let width = forgetBtn.titleLabel?.text?.getSize(font: Metric.forgetFontSize).width {
                //                    make.width.equalTo(width)
                //                }
                make.left.equalTo(separatorView.snp.right)
            }
        }
        return (btnView, registBtn, forgetBtn)
    }
    // MARK: - 账号输入框
    func initAccountField(placeholder: String, onNext: @escaping () -> Void) -> UITextField {
        let field = UITextField().then {
            $0.leftView = self.accountLeftView()
            $0.placeholder = "请输入\(placeholder)"
            configTxtField(txf: $0)
        }

        // 输入内容 校验
        let fieldObservable = field.rx.text.skip(1).throttle(0.1, scheduler: MainScheduler.instance).map { (account: String?) -> Bool in
            if InputValidator.isValidPhone(phoneNum: account ?? "") || InputValidator.isValidEmail(email: account ?? "") {
                return true
            } else {
                return false
            }
        }

        fieldObservable.map { (valid: Bool) -> UIColor in
            let color = valid ? kThemeGainsboroColor : kThemeOrangeRedColor
            return color
        }.subscribe(onNext: { color in
                DispatchQueue.main.async {
                    field.layer.borderColor = color.cgColor
                }
            }).disposed(by: rx.disposeBag)

        return field
    }

    // MARK: - 密码输入框
    func initPasswordField(onNext: @escaping () -> Void) -> UITextField {
        let field = UITextField().then {
            $0.leftView = self.passwordLeftView()
            $0.placeholder = Metric.passswordPlaceholder
            $0.clearsOnBeginEditing = false
            $0.isSecureTextEntry = true
            configTxtField(txf: $0)
        }

        // 输入内容 校验
        let fieldObservable = field.rx.text.skip(1).throttle(0.1, scheduler: MainScheduler.instance).map { (input: String?) -> Bool in
            guard let input = input else { return false }
            dPrint("\(input)")
            return !(input.isEmpty || input.count < 6)
        }

        fieldObservable.map { (valid: Bool) -> UIColor in
            let color = valid ? kThemeGainsboroColor : kThemeOrangeRedColor
            return color
        }.subscribe(onNext: { color in
                DispatchQueue.main.async {
                    field.layer.borderColor = color.cgColor
                }
            }).disposed(by: rx.disposeBag)

        return field
    }

    fileprivate func configTxtField(txf: UITextField?) {
        _ = txf?.then {
            $0.layer.masksToBounds = true
            $0.layer.borderColor = kThemeGainsboroColor.cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = Metric.cornerRadius
            $0.borderStyle = .none
            $0.leftViewMode = .always

            $0.font = UIFont.systemFont(ofSize: 17)
            //            $0.textColor = configModel?.txfTextColor
            $0.setValue(UIFont.systemFont(ofSize: 17), forKeyPath: "_placeholderLabel.font")
            $0.setValue(UIColor(red: 0, green: 0, blue: 0.1, alpha: 0.22), forKeyPath: "_placeholderLabel.textColor")
        }
    }

    // MARK: - 账号输入框 左视图
    private func accountLeftView() -> UIView {
        let leftView = UIView().then {
            $0.frame = CGRect(x: 0, y: 0, width: 40, height: 44)
        }

        let tipLab = UILabel().then {
            $0.textAlignment = .center
            $0.font = Metric.fontSize
            $0.textColor = kThemeTitielColor
            $0.setYJIcon(icon: .account, iconSize: 18)
        }

        // 添加
        leftView.addSubview(tipLab)

        tipLab.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(MetricGlobal.margin)
            make.right.equalToSuperview().offset(-MetricGlobal.margin)
        }

        return leftView
    }

    // MARK: - 密码输入框 左视图
    private func passwordLeftView() -> UIView {
        let leftView = UIView().then {
            $0.frame = CGRect(x: 0, y: 0, width: 40, height: 44)
        }

        let tipBtn = UIButton().then {
            $0.contentMode = .scaleAspectFit
            $0.isUserInteractionEnabled = false
            $0.setTitleColor(kThemeTitielColor, for: UIControlState.normal)
            $0.setYJIcon(icon: .password, iconSize: 18, forState: UIControlState.normal)
        }

        // 添加
        leftView.addSubview(tipBtn)

        tipBtn.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(MetricGlobal.margin)
            make.right.equalToSuperview().offset(-MetricGlobal.margin)
        }

        return leftView
    }

    // MARK: - 图片验证码入口
    func initImgCodeView(type: String, onNext: @escaping (_ codekey: String?) -> Void) -> UITextField {
        let field = UITextField().then {
            $0.leftViewMode = .always
            $0.leftView = self.imgCodeViewLeft()
            $0.rightViewMode = .always
            $0.rightView = self.imgCodeViewRight(type: type, callback: { codekey in
                onNext(codekey)
            })
            $0.placeholder = Metric.imgCodePlaceholder
            configTxtField(txf: $0)
        }

        // 输入内容 校验
        let fieldObservable = field.rx.text.skip(1).throttle(0.1, scheduler: MainScheduler.instance).map { (input: String?) -> Bool in
            guard let input = input else { return false }
            dPrint("\(input)")
            return !(input.isEmpty)
        }

        fieldObservable
            .map { (valid: Bool) -> UIColor in
                let color = valid ? kThemeGainsboroColor : kThemeOrangeRedColor
                return color
            }
            .subscribe(onNext: { color in
                DispatchQueue.main.async {
                    field.layer.borderColor = color.cgColor
                }
            }
            )
            .disposed(by: rx.disposeBag)

        return field
    }

    private func imgCodeViewLeft() -> UIView {
        let leftView = UIView().then {
            $0.frame = CGRect(x: 0, y: 0, width: 40, height: 44)
        }

        let tipBtn = UIButton().then {
            $0.contentMode = .scaleAspectFit
            $0.isUserInteractionEnabled = false
            $0.setTitleColor(kThemeTitielColor, for: UIControlState.normal)
            $0.contentMode = .center
            $0.layer.masksToBounds = true
            $0.setYJIcon(icon: .authCode2, iconSize: 18, forState: UIControlState.normal)
        }

        // 添加
        leftView.addSubview(tipBtn)

        tipBtn.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(MetricGlobal.margin)
            make.right.equalToSuperview().offset(-MetricGlobal.margin)
        }

        return leftView
    }
    func getImgCode(type: String, callback: @escaping (_ image: UIImage?, _ codekey: String?) -> Void) {
        NetworkUtil.request(target: .authCodeKey, success: { json in
            let codeKey = JSON(parseJSON: json ?? "")["data"].stringValue
            NetworkUtil.request(target: .getAuthCode(auth_type: type, code_key: codeKey), success: { json in
                let res = JSON(parseJSON: json ?? "")["data"].stringValue
                let img = res.base64StringToUIImage()
                callback(img, codeKey)
            }) { error in
                dPrint(error)
            }
        }) { error in
            dPrint(error)
        }
    }
    private func imgCodeViewRight(type: String, callback: @escaping (_ codekey: String?) -> Void) -> UIView {
        let rightView = UIView().then {
            $0.frame = CGRect(x: 0, y: 0, width: 130, height: 44)
        }

        let tipBtn = UIButton().then {
            $0.contentMode = .scaleToFill
        }

        var mycodeKey: String?

        getImgCode(type: type) { img, codekey in
            mycodeKey = codekey
            tipBtn.setImage(img, for: .normal)
            callback(codekey)
        }
        // 通知图形验证码更新
        NotificationCenter.default.rx.notification(Notification.Name(kImageCodeUpdate)).takeUntil(self.rx.deallocated).subscribe(onNext: {
            [weak self] _ in
            self?.updateImageCode(tipBtn: tipBtn, codeKey: mycodeKey, type: type, callback: callback)
        }).disposed(by: rx.disposeBag)
        //点击更新图形验证码
        tipBtn.rx.tap.do(onNext: { [weak self] in
            self?.updateImageCode(tipBtn: tipBtn, codeKey: mycodeKey, type: type, callback: callback)
        }).subscribe().disposed(by: rx.disposeBag)

        // 添加
        rightView.addSubview(tipBtn)

        tipBtn.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }

        return rightView
    }

    /// 更新图形验证码
    func updateImageCode(tipBtn: UIButton, codeKey: String?, type: String, callback:@escaping (_ codekey: String?) -> Void) {
        getImgCode(type: type) { img, codekey in
            tipBtn.setImage(img, for: .normal)
            callback(codekey)
        }
    }

    // MARK: - 手机短信验证码入口

    func initSMSCode(onNext: @escaping () -> Void) -> (UITextField, UIButton) {
        let (rightview, button) = self.SMSCodeRight()

        let field = UITextField().then {
            $0.leftViewMode = .always
            $0.leftView = self.SMSCodeLeft()
            $0.rightViewMode = .always
            $0.rightView = rightview
            $0.placeholder = Metric.imgCodePlaceholder
            configTxtField(txf: $0)
        }

        // 输入内容 校验
        let fieldObservable = field.rx.text.skip(1).throttle(0.1, scheduler: MainScheduler.instance).map { (input: String?) -> Bool in
            guard let input = input else { return false }
            dPrint("\(input)")
            return !input.isEmpty
        }

        fieldObservable.map { (valid: Bool) -> UIColor in
            let color = valid ? kThemeGainsboroColor : kThemeOrangeRedColor
            return color
        }.subscribe(onNext: { color in
                field.layer.borderColor = color.cgColor
            }).disposed(by: rx.disposeBag)

        return (field, button)
    }
    private func SMSCodeLeft() -> UIView {
        let leftView = UIView().then {
            $0.frame = CGRect(x: 0, y: 0, width: 40, height: 44)
        }

        let tipBtn = UIButton().then {
            $0.contentMode = .scaleAspectFit
            $0.isUserInteractionEnabled = false
            $0.setTitleColor(kThemeTitielColor, for: UIControlState.normal)
            $0.setYJIcon(icon: .authCode2, forState: .normal)
        }

        // 添加
        leftView.addSubview(tipBtn)

        tipBtn.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(MetricGlobal.margin)
            make.right.equalToSuperview().offset(-MetricGlobal.margin)
        }

        return leftView
    }

    private func SMSCodeRight() -> (UIView, UIButton) {
        let rightView = UIView().then {
            $0.frame = CGRect(x: 0, y: 0, width: 120, height: 30)
        }

        let tipBtn = UIButton().then {
            $0.contentMode = .scaleAspectFit
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            $0.backgroundColor = kNaviBarBackGroundColor
            $0.setTitle("获取验证码", for: UIControlState.normal)
            $0.layer.cornerRadius = 4
            $0.layer.masksToBounds = false
            $0.setTitleColor(UIColor.white, for: UIControlState.normal)
        }

        // 添加
        rightView.addSubview(tipBtn)

        tipBtn.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(-5)
        }

        return (rightView, tipBtn)
    }

    //    private func getCode(button: UIButton) {
    //
    //        button.isUserInteractionEnabled = false

    //        Util.getSMSCode { (code) in
    //
    //            if code != nil {
    //                button.startTime()
    //            }else{
    //                button.isUserInteractionEnabled = true
    //                button.setTitle("获取失败请重试", for: UIControlState.normal)
    //            }
    //        }
    //    }

}
