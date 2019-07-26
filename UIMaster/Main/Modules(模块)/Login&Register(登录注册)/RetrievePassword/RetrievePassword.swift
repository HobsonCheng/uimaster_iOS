//  模块通用模板,保持整体完整性，
//  不需要的部分可以先注释掉，之后完成后，再统一删掉
//  可以参考RetrievePassword模块，如果涉及到分页显示数据，请参考GroupListTopic模块

import NSObject_Rx
import RxCocoa
import RxSwift
import SwiftyJSON
import UIKit

class RetrievePasswordModel: BaseData {
    var fields: RetrievePasswordFields?
    var styles: RetrievePasswordStyles?
    var events: [String: EventsData]?
}

class RetrievePasswordFields: BaseData {
    var textBackPassword: String?
    var textGetVerificationCode: String?
}

class RetrievePasswordStyles: BaseStyleModel {
    var bgImgFindBtnAct: String?
    var borderShowAuthCode: Int?
    var heightAuthCodeHeight: CGFloat?
    var bgImgAuthCode: String?
    var borderColor: String?
    var borderWidth: CGFloat?
    var bgColorAuthCode: String?
    var bgImgModeFindBtn: Int?
    var bgImgModeFindBtnAct: Int?
    var opacityAuthCode: Int?
    var opacityAuthCodeSel: Int?
    var bgColorFindBtnAct: String?
    var borderShow: Int?
    var titleNewPassword: String?
    var titleVerificationCode: String?
    var bgColorAuthCodeSel: String?
    var iconVerificationCode: String?
    var opacityFindBtn: Int?
    var heightFindBtnHeight: CGFloat?
    var iconNewPassword: String?
    var iconNickName: String?
    var opacity: Int?
    var bgColorFindBtn: String?
    var bgImgAuthCodeSel: String?
    var borderWidthAuthCode: Int?
    var opacityFindBtnAct: Int?
    var titleNickName: String?
    var widthFindBtnWidth: CGFloat?
    var bgImgModeAuthCodeSel: Int?
    var borderColorAuthCode: String?
    var widthAuthCodeWidth: CGFloat?
    var bgImgFindBtn: String?
    var bgImgModeAuthCode: Int?
}

class RetrievePassword: UIView, PageModuleAble {
    // MARK: - 模块相关的配置属性
    private var bgColor = "255,255,255,1"//录入框背景 颜色
    private var bgColorAuthCode = "34,153,238,1"//验证码默认背景 颜色
    private var bgColorAuthCodeSel = "194,194,194,1"//验证码点击后背景 颜色
    private var bgColorFindBtn = "166,214,248,1"//默认背景 颜色
    private var bgColorFindBtnAct = "34,153,238,1"//激活背景 颜色
    private var bgImg = ""//录入框背景 背景图片
    private var bgImgAuthCode = ""//验证码默认背景 图片
    private var bgImgAuthCodeSel = ""//验证码点击后背景 图片
    private var bgImgFindBtn = ""//默认背景 图片
    private var bgImgFindBtnAct = ""//激活背景 图片
    private var bgImgMode = 0//录入框背景 背景平铺
    private var bgImgModeAuthCode = 0//验证码默认背景 平铺
    private var bgImgModeAuthCodeSel = 0//验证码点击后背景 平铺
    private var bgImgModeFindBtn = 0//默认背景 平铺
    private var bgImgModeFindBtnAct = 0//激活背景 平铺
    private var borderColor = "230,230,230,1"//录入框边框 颜色
    private var borderColorAuthCode = "233,233,233,1"//验证码边框 颜色
    private var borderShow = 1//录入框边框 是否显示
    private var borderShowAuthCode = 1//验证码边框 是否显示
    private var borderWidth: CGFloat = 1//录入框边框 宽度
    private var borderWidthAuthCode = 0//验证码边框 宽度
    private var heightAuthCodeHeight: CGFloat = 30//验证码按钮高度
    private var heightFindBtnHeight: CGFloat = 40//找回密码按钮高度
    private var iconNewPassword = ""//内容 新密码 图片
    private var iconNickName = ""//内容  用户名图标
    private var iconVerificationCode = ""//内容 验证码 图标
    private var opacity = 1//录入框背景 透明度
    private var opacityAuthCode = 1//验证码默认背景 透明度
    private var opacityAuthCodeSel = 1//验证码点击后背景 透明度
    private var opacityFindBtn = 1//默认背景 透明度
    private var opacityFindBtnAct = 1//激活背景 透明度
    private var radius: CGFloat = 5//圆角
    private var textBackPassword = "找回密码"//内容 找回密码按钮 找回密码
    private var textGetVerificationCode = "获取验证码"//内容 获取验证按钮 获取验证码
    private var titleNewPassword = "请输入新密码"//内容 新密码 提示
    private var titleNickName = "请输入手机号/邮箱"//内容 用户名提示
    private var titleVerificationCode = "请输入验证码"//内容 验证码 提示
    private var widthAuthCodeWidth: CGFloat = 87//验证码按钮宽度
    private var widthFindBtnWidth: CGFloat = 290//找回密码按钮宽度

    weak var moduleDelegate: ModuleRefreshDelegate?
    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let retrievePasswordModel = RetrievePasswordModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.bgColor = retrievePasswordModel.styles?.bgColor ?? self.bgColor
                self.bgColorAuthCode = retrievePasswordModel.styles?.bgColorAuthCode ?? self.bgColorAuthCode
                self.bgColorAuthCodeSel = retrievePasswordModel.styles?.bgColorAuthCodeSel ?? self.bgColorAuthCodeSel
                self.bgColorFindBtn = retrievePasswordModel.styles?.bgColorFindBtn ?? self.bgColorFindBtn
                self.bgColorFindBtnAct = retrievePasswordModel.styles?.bgColorFindBtnAct ?? self.bgColorFindBtnAct
                self.bgImg = retrievePasswordModel.styles?.bgImg ?? self.bgImg
                self.bgImgAuthCode = retrievePasswordModel.styles?.bgImgAuthCode ?? self.bgImgAuthCode
                self.bgImgAuthCodeSel = retrievePasswordModel.styles?.bgImgAuthCodeSel ?? self.bgImgAuthCodeSel
                self.bgImgFindBtn = retrievePasswordModel.styles?.bgImgFindBtn ?? self.bgImgFindBtn
                self.bgImgFindBtnAct = retrievePasswordModel.styles?.bgImgFindBtnAct ?? self.bgImgFindBtnAct
                self.bgImgMode = retrievePasswordModel.styles?.bgImgMode ?? self.bgImgMode
                self.bgImgModeAuthCode = retrievePasswordModel.styles?.bgImgModeAuthCode ?? self.bgImgModeAuthCode
                self.bgImgModeAuthCodeSel = retrievePasswordModel.styles?.bgImgModeAuthCodeSel ?? self.bgImgModeAuthCodeSel
                self.bgImgModeFindBtn = retrievePasswordModel.styles?.bgImgModeFindBtn ?? self.bgImgModeFindBtn
                self.bgImgModeFindBtnAct = retrievePasswordModel.styles?.bgImgModeFindBtnAct ?? self.bgImgModeFindBtnAct
                self.borderColor = retrievePasswordModel.styles?.borderColor ?? self.borderColor
                self.borderColorAuthCode = retrievePasswordModel.styles?.borderColorAuthCode ?? self.borderColorAuthCode
                self.borderShow = retrievePasswordModel.styles?.borderShow ?? self.borderShow
                self.borderShowAuthCode = retrievePasswordModel.styles?.borderShowAuthCode ?? self.borderShowAuthCode
                self.borderWidth = retrievePasswordModel.styles?.borderWidth ?? self.borderWidth
                self.borderWidthAuthCode = retrievePasswordModel.styles?.borderWidthAuthCode ?? self.borderWidthAuthCode
                self.heightAuthCodeHeight = retrievePasswordModel.styles?.heightAuthCodeHeight ?? self.heightAuthCodeHeight
                self.heightFindBtnHeight = retrievePasswordModel.styles?.heightFindBtnHeight ?? self.heightFindBtnHeight
                self.iconNewPassword = retrievePasswordModel.styles?.iconNewPassword ?? self.iconNewPassword
                self.iconNickName = retrievePasswordModel.styles?.iconNickName ?? self.iconNickName
                self.iconVerificationCode = retrievePasswordModel.styles?.iconVerificationCode ?? self.iconVerificationCode
                self.opacity = retrievePasswordModel.styles?.opacity ?? self.opacity
                self.opacityAuthCode = retrievePasswordModel.styles?.opacityAuthCode ?? self.opacityAuthCode
                self.opacityAuthCodeSel = retrievePasswordModel.styles?.opacityAuthCodeSel ?? self.opacityAuthCodeSel
                self.opacityFindBtn = retrievePasswordModel.styles?.opacityFindBtn ?? self.opacityFindBtn
                self.opacityFindBtnAct = retrievePasswordModel.styles?.opacityFindBtnAct ?? self.opacityFindBtnAct
                self.radius = retrievePasswordModel.styles?.radius ?? self.radius
                self.textBackPassword = retrievePasswordModel.fields?.textBackPassword ?? self.textBackPassword
                self.textGetVerificationCode = retrievePasswordModel.fields?.textGetVerificationCode ?? self.textGetVerificationCode
                self.titleNewPassword = retrievePasswordModel.styles?.titleNewPassword ?? self.titleNewPassword
                self.titleNickName = retrievePasswordModel.styles?.titleNickName ?? self.titleNickName
                self.titleVerificationCode = retrievePasswordModel.styles?.titleVerificationCode ?? self.titleVerificationCode
                self.widthAuthCodeWidth = retrievePasswordModel.styles?.widthAuthCodeWidth ?? self.widthAuthCodeWidth
                self.widthFindBtnWidth = retrievePasswordModel.styles?.widthFindBtnWidth ?? self.widthFindBtnWidth

                //渲染UI
                renderUI()
            }
        }
    }

    // MARK: init方法
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI&事件处理
extension RetrievePassword {
    //渲染UI
    private func renderUI() {
        let scrollView = UIScrollView().then { [weak self] in
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.contentSize = CGSize(width: self?.width ?? 0, height: 500)
        }
        //创建页面信息
        // 创建 协议组件
        //        let iconImgV = UIImageView()
        //        iconImgV.sd_setImage(with: URL.init(string: self.model?.styles?.iconAppPic ?? ""), completed: nil)
        //        iconImgV.contentMode = .scaleAspectFill
        //        iconImgV.layer.masksToBounds = true
        //        iconImgV.layer.cornerRadius = 5

        let accountField = initAccountField {
        }
        accountField.backgroundColor = self.bgColor.toColor()
        let passwordField = initPasswordField {
        }
        passwordField.backgroundColor = self.bgColor.toColor()
        let (smsCodeField, phoneCodeBt) = initSMSCode {
        }
        smsCodeField.backgroundColor = self.bgColor.toColor()
        let (loginBtnView, loginBtn) = initLoginBtnView(showFP: false) { event in
            dPrint(event.title ?? "")
        }

        NetworkUtil.request(
            target: .authCodeKey,
            success: { [weak self] json in
                let dic = JSON(parseJSON: json ?? "")["data"].dictionaryObject
                let codeKey = dic?["code_key"] as? String
                let regService = RetrievePasswordService(input: (accountField, smsCodeField, passwordField, loginBtn, phoneCodeBt), codekey: nil)

                regService.loginBtnEnable
                    .drive(onNext: { beel in
                        loginBtn.isEnabled = beel
                        if beel {
                            //                    loginBtn.titleLabel?.textColor = self?.colorLoginBtnAct.toColor()
                            loginBtn.backgroundColor = self?.bgColorFindBtnAct.toColor()
                            if self?.bgImgFindBtnAct.isEmpty ?? false {
                                loginBtn.kf.setBackgroundImage(with: URL(string: (self?.bgImgFindBtnAct ?? "")), for: .normal)
                            }
                        } else {
                            if self?.bgImgFindBtn.isEmpty ?? false {
                                loginBtn.kf.setBackgroundImage(with: URL(string: (self?.bgImgFindBtn ?? "")), for: .normal)
                            }
                            loginBtn.backgroundColor = self?.bgColorFindBtn.toColor()
                            //                    loginBtn.titleLabel?.textColor = self?.colorLoginBtn.toColor()
                        }
                    })
                    .disposed(by: (self?.rx.disposeBag)!)

                regService.getCodeBtEnable
                    .drive(onNext: { beel in
                        phoneCodeBt.isEnabled = beel
                        if beel {
                            //                    phoneCodeBt.titleLabel?.textColor = self?.colorLoginBtnAct.toColor()
                            phoneCodeBt.backgroundColor = self?.bgColorAuthCode.toColor()

                            if self?.bgImgAuthCodeSel.isEmpty ?? false {
                                phoneCodeBt.kf.setBackgroundImage(with: URL(string: (self?.bgImgAuthCodeSel ?? "")), for: .normal)
                            }
                        } else {
                            if self?.bgImgAuthCode.isEmpty ?? false {
                                phoneCodeBt.kf.setBackgroundImage(with: URL(string: (self?.bgImgAuthCode ?? "")), for: .normal)
                            }
                            phoneCodeBt.backgroundColor = self?.bgColorAuthCodeSel.toColor()

                            //                    phoneCodeBt.titleLabel?.textColor = self?.colorLoginBtn.toColor()
                        }
                    })
                    .disposed(by: (self?.rx.disposeBag)!)

                regService.loginResult.drive().disposed(by: (self?.rx.disposeBag)!)

                regService.getCodeResult
                    .drive(
                        onNext: { params in
                            let phone = params.object(forKey: "phone_Email_num") as? String ?? ""
                            NetworkUtil.request(
                                target: .getPhoneEmailAuthCode(auth_type: "retrieve_password", code_key: codeKey ?? "", phone_Email_num: phone),
                                success: { _ in
                                    phoneCodeBt.startTime()
                                }) { error in
                                phoneCodeBt.isUserInteractionEnabled = true
                                phoneCodeBt.setTitle("获取失败请重试", for: UIControlState.normal)
                                dPrint(error)
                            }
                        })
                    .disposed(by: (self?.rx.disposeBag)!)
            }) { error in
            dPrint(error)
        }

        // 添加
        //        addSubview(iconImgV)

        scrollView.addSubview(accountField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(smsCodeField)
        scrollView.addSubview(loginBtnView)
        self.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(kScreenW)
        }

        // 布局
        //        iconImgV.snp.makeConstraints { (make) in
        //            make.width.equalTo(80)
        //            make.height.equalTo(80)
        //            make.centerX.equalToSuperview()
        //            make.top.equalToSuperview().offset(MetricGlobal.margin * 2)
        //        }

        accountField.snp.makeConstraints { make in
            make.left.right.equalTo(loginBtnView)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
            make.height.equalTo(Metric.fieldHeight)
        }

        smsCodeField.snp.makeConstraints { make in
            make.left.right.equalTo(loginBtnView)
            make.centerX.equalToSuperview()
            make.top.equalTo(accountField.snp.bottom).offset(20)
            make.height.equalTo(Metric.fieldHeight)
        }

        passwordField.snp.makeConstraints { make in
            make.left.right.equalTo(loginBtnView)
            make.centerX.equalToSuperview()
            make.top.equalTo(smsCodeField.snp.bottom).offset(20)
            make.height.equalTo(Metric.fieldHeight)
        }

        loginBtnView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(passwordField.snp.bottom).offset(MetricGlobal.margin * 2)
            make.width.equalTo(widthFindBtnWidth)
            make.height.equalTo(heightFindBtnHeight)
        }
    }

    // MARK: - 登录按钮部分
    func initLoginBtnView(showFP: Bool, onNext: @escaping (_ event: AccountLoginEvent) -> Void) -> (UIView, UIButton) {
        // 创建
        let btnView = UIView().then {
            $0.backgroundColor = .clear
        }

        let loginBtn = UIButton()
            .then {
                $0.layer.masksToBounds = true
                $0.layer.cornerRadius = Metric.cornerRadius
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 17)
                $0.setTitleColor(kThemeWhiteColor, for: .normal)
                //            if let hColor = btnTitleHighlightedColor {
                //                $0.setTitleColor(hColor, for: .highlighted)
                //            }
                $0.setTitle(Metric.forgetBtnTitle, for: .normal)
                $0.backgroundColor = kNaviBarBackGroundColor

                //            if bgImgFindBtn.length > 0 {
                //                $0.sd_setBackgroundImage(with: URL(string: bgImgFindBtn), for: .normal, completed: nil)
                //            } else if bgColorFindBtn.length > 0 {
                //                $0.setBackgroundImage(UIImage.from(color: kNaviBarBackGroundColor), for: .normal)
                //            }
                //
                //
                //            if bgImgFindBtnAct.length > 0 {
                //                $0.sd_setBackgroundImage(with: URL(string: bgImgFindBtnAct), for: .highlighted, completed: nil)
                //            } else if bgColorFindBtnAct.length > 0 {
                //                $0.setBackgroundImage(UIImage.from(color: bgColorFindBtnAct.toColor()), for: .highlighted)
                //            }
                $0.rx.tap
                    .do(onNext: {
                        onNext(AccountLoginEvent(type: .login, title: "找回密码按钮"))
                    })
                    .subscribe()
                    .disposed(by: rx.disposeBag)
            }

        // 添加
        btnView.addSubview(loginBtn)

        // 布局
        loginBtn.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(Metric.loginBtnHeight)
        }

        return (btnView, loginBtn)
    }

    // MARK: - 账号输入框
    func initAccountField(onNext: @escaping () -> Void) -> UITextField {
        let field = UITextField().then {
            $0.leftView = self.accountLeftView()
            $0.placeholder = "请输入手机号/邮箱"
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

        fieldObservable
            .map { (valid: Bool) -> UIColor in
                let color = valid ? kThemeGainsboroColor : kThemeOrangeRedColor
                return color
            }
            .subscribe(onNext: { color in
                DispatchQueue.main.async {
                    field.layer.borderColor = color.cgColor
                }
            })
            .disposed(by: rx.disposeBag)

        return field
    }

    // MARK: - 密码输入框
    func initPasswordField(onNext: @escaping () -> Void) -> UITextField {
        let field = UITextField().then {
            $0.leftView = self.passwordLeftView()
            $0.placeholder = Metric.passswordPlaceholder
            configTxtField(txf: $0)
        }

        // 输入内容 校验
        let fieldObservable = field.rx.text.skip(1).throttle(0.1, scheduler: MainScheduler.instance).map { (input: String?) -> Bool in
            guard let input = input, input.count >= 6 else {
                return false
            }
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

    fileprivate func configTxtField(txf: UITextField?) {
        _ = txf?.then {
            $0.layer.masksToBounds = true
            $0.layer.borderColor = kThemeGainsboroColor.cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = Metric.cornerRadius
            $0.borderStyle = .none
            $0.leftViewMode = .always
            $0.font = UIFont.systemFont(ofSize: 17)
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
            make.width.equalTo(Metric.tipBtnWidth)
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
            make.width.equalTo(Metric.tipBtnWidth)
        }

        return leftView
    }

    // MARK: - 手机短信验证码入口
    func initSMSCode(onNext: @escaping () -> Void) -> (UITextField, UIButton) {
        let (rightView, button) = self.SMSCodeRight()

        let field = UITextField().then {
            $0.leftViewMode = .always
            $0.leftView = self.SMSCodeLeft()
            $0.rightViewMode = .always
            $0.rightView = rightView
            $0.placeholder = Metric.imgCodePlaceholder
            configTxtField(txf: $0)
        }

        // 输入内容 校验
        let fieldObservable = field.rx.text.skip(1).throttle(0.1, scheduler: MainScheduler.instance).map { (input: String?) -> Bool in
            guard let input = input else {
                return false
            }
            dPrint("\(input)")
            return !input.isEmpty
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
            make.width.equalTo(Metric.tipBtnWidth)
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
}
