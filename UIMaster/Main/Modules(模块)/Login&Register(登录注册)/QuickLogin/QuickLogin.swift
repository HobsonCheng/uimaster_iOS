//  模块通用模板,保持整体完整性，
//  不需要的部分可以先注释掉，之后完成后，再统一删掉
//  可以参考QuickLogin模块，如果涉及到分页显示数据，请参考GroupListTopic模块

import SwiftyJSON
import UIKit

class QuickLoginModel: BaseData {
    var events: [String: EventsData]?
    var fields: QuickLoginFields?
    var styles: QuickLoginStyles?
}

class QuickLoginFields: BaseData {
    var controlNumberInfinite: Int?
    var textAccountPassword: String?
    var textGetVerificationCode: String?
    var textLoginButton: String?
}

class QuickLoginStyles: BaseStyleModel {
    var bgColorLoginBtnAct: String?
    var bgImgModeAuthCode: Int?
    var opacityLoginBtn: Int?
    var heightLoginBtnHeight: CGFloat?
    var textAlignLoginBtn: Int?
    var fontSizeAuthCodeTime: CGFloat?
    var opacityAuthCode: Int?
    var textAlignInput: Int?
    var titleAppPic: String?
    var titleVerificationCode: String?
    var bgColorLoginBtn: String?
    var bgImgAuthCodeSel: String?
    var fontSizeLink: CGFloat?
    var colorAuthCode: String?
    var colorPlaceholder: String?
    var textAlignAuthCodeTime: Int?
    var bgColorAuthCodeSel: String?
    var bgImgInput: String?
    var borderWidthInput: CGFloat?
    var colorAuthCodeTime: String?
    var colorLink: String?
    var iconAppPic: String?
    var textAlignLink: Int?
    var appShapeShape: Int?
    var borderColorInput: String?
    var heightAuthCodeHeight: CGFloat?
    var iconPhoneNumber: String?
    var textAlignPlaceholder: Int?
    var fontSizeLoginBtn: CGFloat?
    var fontSizeLoginBtnAct: CGFloat?
    var opacityAuthCodeSel: Int?
    var opacityInput: Int?
    var bgImgLoginBtnAct: String?
    var bgImgModeAuthCodeSel: Int?
    var titlePhoneNumber: String?
    var widthAuthCodeWidth: CGFloat?
    var colorLoginBtn: String?
    var fontSizeAuthCode: CGFloat?
    var fontSizeInput: CGFloat?
    var textAlignLoginBtnAct: Int?
    var borderShowInput: Int?
    var colorInput: String?
    var fontSizePlaceholder: CGFloat?
    var bgColorAuthCode: String?
    var bgImgModeInput: Int?
    var borderShow: Int?
    var widthLoginBtnWidth: CGFloat?
    var bgColorInput: String?
    var bgImgLoginBtn: String?
    var bgImgModeLoginBtnAct: Int?
    var borderColor: String?
    var textAlignAuthCode: Int?
    var bgImgAuthCode: String?
    var bgImgModeLoginBtn: Int?
    var borderWidth: CGFloat?
    var opacityLoginBtnAct: Int?
    var colorLoginBtnAct: String?
    var iconVerificationCode: String?
}

class QuickLogin: UIView, PageModuleAble {
    weak var moduleDelegate: ModuleRefreshDelegate?
    // MARK: 模块相关的配置属性
    private var appShapeShape = 1//APP图形形状
    private var bgColor = "255,255,255,1" //背景色
    private var bgColorAuthCode = "34,153,238,1.0"//默认背景 颜色
    private var bgColorAuthCodeSel = "194,194,194,1.0"//点击后背景
    private var bgColorInput = "255,255,255,1.0"//录入框背景 颜色
    private var bgColorLoginBtn = "166,214,248,1.0"//登录按钮默认背景 颜色
    private var bgColorLoginBtnAct = "34,253,238,1.0"//登录按钮激活背景 颜色
    private var bgImgAuthCode = ""//默认背景 图片
    private var bgImgAuthCodeSel = ""//点击后背景 图片
    private var bgImgInput = ""//录入框背景 图片
    private var bgImgLoginBtn = ""//登录按钮 图片
    private var bgImgLoginBtnAct = ""//登陆激活按钮 图片
    private var bgImgModeAuthCode = 0//默认背景 平铺
    private var bgImgModeAuthCodeSel = 0//点击后背景 平铺
    private var bgImgModeInput = 0//录入框背景 平铺
    private var bgImgModeLoginBtn = 0//登陆按钮 平铺
    private var bgImgModeLoginBtnAct = 0//登陆激活按钮 平铺
    private var borderColor = "233,233,233,1"//边框 颜色
    private var borderColorInput = "233,233,233,1"//录入框边框 颜色
    private var borderShow = 1//边框 是否显示
    private var borderShowInput = 1//录入框边框 是否显示
    private var borderWidth: CGFloat = 0//边框 宽度
    private var borderWidthInput: CGFloat = 0//录入框边框 宽度
    private var colorAuthCode = "255,255,255,1"//默认文字 颜色
    private var colorAuthCodeTime = "255,255,255,1"//时间数字 颜色
    private var colorInput = "34,34,34,1"//录入文字 颜色
    private var colorLink = "34,153,238,1"//账号密码登陆文字 颜色
    private var colorLoginBtn = "222,239,252,1"//登陆按钮默认文字 颜色
    private var colorLoginBtnAct = "255,255,255,1"//登陆按钮激活文字 颜色
    private var colorPlaceholder = "212,212,212,1"//占位文字 颜色
    private var controlNumberInfinite = 1//App图标
    private var fontSizeAuthCode = 15//默认文字 大小
    private var fontSizeAuthCodeTime = 15//时间数字 大小
    private var fontSizeInput = 15//录入文字 大小
    private var fontSizeLink = 15//账号密码登陆文字 大小
    private var fontSizeLoginBtn = 15//登陆按钮默认 大小
    private var fontSizeLoginBtnAct = 15//登陆按钮激活 大小
    private var fontSizePlaceholder = 15//占位文字 大小
    private var heightAuthCodeHeight = 30//验证码按钮高度
    private var heightLoginBtnHeight = 40//登陆按钮 高度
    private var iconAppPic = ""//内容 APP图标 图片
    private var iconPhoneNumber = ""//内容 手机号 图片
    private var iconVerificationCode = ""//内容 提示 图片
    private var opacityAuthCode = 1//默认背景 透明度
    private var opacityAuthCodeSel = 1//点击后背景 透明度
    private var opacityInput = 1//录入框背景 透明度
    private var opacityLoginBtn = 1//登陆按钮 透明度
    private var opacityLoginBtnAct = 1//登录按钮激活 透明度
    private var textAccountPassword = ""//内容 账号密码登录 显示文字
    private var textAlignAuthCode = 1//默认文字 位置
    private var textAlignAuthCodeTime = 1//事件数字 位置
    private var textAlignInput = 0//录入框文字 位置
    private var textAlignLink = 1//账号密码登陆文字 位置
    private var textAlignLoginBtn = 1//登陆按钮 文字
    private var textAlignLoginBtnAct = 1//登陆激活按钮 文字
    private var textAlignPlaceholder = 0//占位文字 位置
    private var textGetVerificationCode = ""//内容 获取验证码按钮 显示文字
    private var textLoginButton = ""//内容 登陆按钮 显示文字
    private var titleAppPic = ""//内容 APP图标 提示
    private var titlePhoneNumber = ""//内容 手机号 提示
    private var titleVerificationCode = ""//内容 验证码
    private var widthAuthCodeWidth = 87//验证码按钮宽度
    private var widthLoginBtnWidth = 280//登路按钮 宽度

    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let quickLoginModel = QuickLoginModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.bgColor = quickLoginModel.styles?.bgColor ?? self.bgColor
                self.appShapeShape = quickLoginModel.styles?.appShapeShape ?? self.appShapeShape
                self.bgColorAuthCode = quickLoginModel.styles?.bgColorAuthCode ?? self.bgColorAuthCode
                self.bgColorAuthCodeSel = quickLoginModel.styles?.bgColorAuthCodeSel ?? self.bgColorAuthCodeSel
                self.bgColorInput = quickLoginModel.styles?.bgColorInput ?? self.bgColorInput
                self.bgColorLoginBtn = quickLoginModel.styles?.bgColorLoginBtn ?? self.bgColorLoginBtn
                self.bgColorLoginBtnAct = quickLoginModel.styles?.bgColorLoginBtnAct ?? self.bgColorLoginBtnAct
                self.bgImgAuthCode = quickLoginModel.styles?.bgImgAuthCode ?? self.bgImgAuthCode
                self.bgImgAuthCodeSel = quickLoginModel.styles?.bgImgAuthCodeSel ?? self.bgImgAuthCodeSel
                self.bgImgInput = quickLoginModel.styles?.bgImgInput ?? self.bgImgInput
                self.bgImgLoginBtn = quickLoginModel.styles?.bgImgLoginBtn ?? self.bgImgLoginBtn
                self.bgImgLoginBtnAct = quickLoginModel.styles?.bgImgLoginBtnAct ?? self.bgImgLoginBtnAct
                self.bgImgModeAuthCode = quickLoginModel.styles?.bgImgModeAuthCode ?? self.bgImgModeAuthCode
                self.bgImgModeAuthCodeSel = quickLoginModel.styles?.bgImgModeAuthCodeSel ?? self.bgImgModeAuthCodeSel
                self.bgImgModeInput = quickLoginModel.styles?.bgImgModeInput ?? self.bgImgModeInput
                self.bgImgModeLoginBtn = quickLoginModel.styles?.bgImgModeLoginBtn ?? self.bgImgModeLoginBtn
                self.bgImgModeLoginBtnAct = quickLoginModel.styles?.bgImgModeLoginBtnAct ?? self.bgImgModeLoginBtnAct
                self.borderColor = quickLoginModel.styles?.borderColor ?? self.borderColor
                self.borderColorInput = quickLoginModel.styles?.borderColorInput ?? self.borderColorInput
                self.borderShow = quickLoginModel.styles?.borderShow ?? self.borderShow
                self.borderShowInput = quickLoginModel.styles?.borderShowInput ?? self.borderShowInput
                self.borderWidth = quickLoginModel.styles?.borderWidth ?? self.borderWidth
                self.borderWidthInput = quickLoginModel.styles?.borderWidthInput ?? self.borderWidthInput
                self.colorAuthCode = quickLoginModel.styles?.colorAuthCode ?? self.colorAuthCode
                self.colorAuthCodeTime = quickLoginModel.styles?.colorAuthCodeTime ?? self.colorAuthCodeTime
                self.colorInput = quickLoginModel.styles?.colorInput ?? self.colorInput
                self.colorLink = quickLoginModel.styles?.colorLink ?? self.colorLink
                self.colorLoginBtn = quickLoginModel.styles?.colorLoginBtn ?? self.colorLoginBtn
                self.colorLoginBtnAct = quickLoginModel.styles?.colorLoginBtnAct ?? self.colorLoginBtnAct
                self.colorPlaceholder = quickLoginModel.styles?.colorPlaceholder ?? self.colorPlaceholder
                self.controlNumberInfinite = quickLoginModel.fields?.controlNumberInfinite ?? self.controlNumberInfinite
//                self.fontSizeAuthCode = quickLoginModel.styles?.fontSizeAuthCode ?? self.fontSizeAuthCode
//                self.fontSizeAuthCodeTime = quickLoginModel.styles?.fontSizeAuthCodeTime ?? self.fontSizeAuthCodeTime
//                self.fontSizeInput = quickLoginModel.styles?.fontSizeInput ?? self.fontSizeInput
//                self.fontSizeLink = quickLoginModel.styles?.fontSizeLink ?? self.fontSizeLink
//                self.fontSizeLoginBtn = quickLoginModel.styles?.fontSizeLoginBtn ?? self.fontSizeLoginBtn
//                self.fontSizeLoginBtnAct = quickLoginModel.styles?.fontSizeLoginBtnAct ?? self.fontSizeLoginBtnAct
//                self.fontSizePlaceholder = quickLoginModel.styles?.fontSizePlaceholder ?? self.fontSizePlaceholder
//                self.heightAuthCodeHeight = quickLoginModel.styles?.heightAuthCodeHeight ?? self.heightAuthCodeHeight
//                self.heightLoginBtnHeight = quickLoginModel.styles?.heightLoginBtnHeight ?? self.heightLoginBtnHeight
                self.iconAppPic = quickLoginModel.styles?.iconAppPic ?? self.iconAppPic
                self.iconPhoneNumber = quickLoginModel.styles?.iconPhoneNumber ?? self.iconPhoneNumber
                self.iconVerificationCode = quickLoginModel.styles?.iconVerificationCode ?? self.iconVerificationCode
                self.opacityAuthCode = quickLoginModel.styles?.opacityAuthCode ?? self.opacityAuthCode
                self.opacityAuthCodeSel = quickLoginModel.styles?.opacityAuthCodeSel ?? self.opacityAuthCodeSel
                self.opacityInput = quickLoginModel.styles?.opacityInput ?? self.opacityInput
                self.opacityLoginBtn = quickLoginModel.styles?.opacityLoginBtn ?? self.opacityLoginBtn
                self.opacityLoginBtnAct = quickLoginModel.styles?.opacityLoginBtnAct ?? self.opacityLoginBtnAct
                self.textAccountPassword = quickLoginModel.fields?.textAccountPassword ?? self.textAccountPassword
                self.textAlignAuthCode = quickLoginModel.styles?.textAlignAuthCode ?? self.textAlignAuthCode
                self.textAlignAuthCodeTime = quickLoginModel.styles?.textAlignAuthCodeTime ?? self.textAlignAuthCodeTime
                self.textAlignInput = quickLoginModel.styles?.textAlignInput ?? self.textAlignInput
                self.textAlignLink = quickLoginModel.styles?.textAlignLink ?? self.textAlignLink
                self.textAlignLoginBtn = quickLoginModel.styles?.textAlignLoginBtn ?? self.textAlignLoginBtn
                self.textAlignLoginBtnAct = quickLoginModel.styles?.textAlignLoginBtnAct ?? self.textAlignLoginBtnAct
                self.textAlignPlaceholder = quickLoginModel.styles?.textAlignPlaceholder ?? self.textAlignPlaceholder
                self.textGetVerificationCode = quickLoginModel.fields?.textGetVerificationCode ?? self.textGetVerificationCode
                self.textLoginButton = quickLoginModel.fields?.textLoginButton ?? self.textLoginButton
                self.titleAppPic = quickLoginModel.styles?.titleAppPic ?? self.titleAppPic
                self.titlePhoneNumber = quickLoginModel.styles?.titlePhoneNumber ?? self.titlePhoneNumber
                self.titleVerificationCode = quickLoginModel.styles?.titleVerificationCode ?? self.titleVerificationCode
//                self.widthAuthCodeWidth = quickLoginModel.styles?.widthAuthCodeWidth ?? self.widthAuthCodeWidth
//                self.widthLoginBtnWidth = quickLoginModel.styles?.widthLoginBtnWidth ?? self.widthLoginBtnWidth
//
                //渲染UI
                renderUI()
                //获取数据
//                reloadViewData()
            }
        }
    }

    //模块特有属性
    private var pageNum: Int = 1//如果涉及到数据分页，需要此变量

    // MARK: init方法
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.rx.tapGesture()
            .do(onNext: { [weak self] _ in
                self?.endEditing(true)
            })
            .subscribe()
            .disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 网络请求
extension QuickLogin {
    //页面刷新时会调用该方法
//    func reloadViewData() {
//        //加载更多时，分页数加1，不需要分页可以去掉下面这行
//        self.pageNum = isLoadMore ? self.pageNum + 1 : 1
//        //请求M2数据信息
//        self.requestQuickLoginData()
//    }
}

// MARK: - UI&事件处理
extension QuickLogin: AccountLoginable {
    //渲染UI
    private func renderUI() {
        self.backgroundColor = self.bgColor.toColor()
        // 创建 容器组件
        let scrollView = UIScrollView().then {
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.contentSize = CGSize(width: self.width, height: 500)
        }
        //创建页面信息
        // 创建 协议组件
        let iconImgV = UIImageView()
        let picUrlStr = GlobalConfigTool.shared.icon
        iconImgV.kf.setImage(with: URL(string: picUrlStr), placeholder: R.image.icon256()!, options: nil, progressBlock: nil, completionHandler: nil)
        iconImgV.contentMode = .scaleAspectFill
        if self.appShapeShape == 2 {
            iconImgV.layer.cornerRadius = 32.5
            iconImgV.layer.masksToBounds = true
        } else {
            iconImgV.layer.masksToBounds = true
            iconImgV.layer.cornerRadius = 5
        }
        //账户名
        let accountField = initAccountField(placeholder: "手机号") {
        }
//        accountField.bordersWidth = self.borderWidthInput >= 1 ? 1 : 0
//        accountField.bordersColor = self.borderColorInput.toColor()
        accountField.backgroundColor = self.bgColorInput.toColor()
        let (smsCodeField, phoneCodeBt) = initSMSCode {
        }
//        smsCodeField.bordersWidth = self.borderWidthInput >= 1 ? 1 : 0
//        smsCodeField.bordersColor = self.borderColorInput.toColor()
        smsCodeField.backgroundColor = self.bgColorInput.toColor()
        let (loginBtnView, loginBtn) = initLoginBtnView()
//            if event.type == .regist { // 跳转注册页面
//                let reg = RegVC.init(registModel: RegistModel())
//                VCController.push(reg, with: VCAnimationClassic.defaultAnimation())
//            }
//        }
        loginBtnView.backgroundColor = .clear
        loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(self.fontSizeLoginBtn))
        loginBtn.setTitle(self.textLoginButton, for: .normal)

        NetworkUtil.request(
            target: .authCodeKey,
            success: { [weak self] json in
                let dic = JSON(parseJSON: json ?? "")["data"].dictionaryObject
                let codeKey = dic?["code_key"] as? String
                let regServise = PhoneService(input: (accountField, nil, smsCodeField, loginBtn, phoneCodeBt), codekey: nil)

                regServise.loginBtnEnable
                    .drive(onNext: { beel in
                        loginBtn.isEnabled = beel
                        if beel {
                            loginBtn.setTitleColor(self?.colorLoginBtnAct.toColor(), for: .normal)
                            loginBtn.backgroundColor = self?.bgColorLoginBtnAct.toColor()
                            if !(self?.bgImgLoginBtnAct.isEmpty ?? true) {
                                loginBtn.kf.setBackgroundImage(with: URL(string: (self?.bgImgLoginBtnAct ?? "")), for: .normal)
                            }
                        } else {
                            if !(self?.bgImgLoginBtn.isEmpty ?? true) {
                                loginBtn.kf.setBackgroundImage(with: URL(string: (self?.bgImgLoginBtn ?? "")), for: .normal)
                            }
                            loginBtn.backgroundColor = self?.bgColorLoginBtn.toColor()
                            loginBtn.setTitleColor(self?.colorLoginBtn.toColor(), for: .normal)
                        }
                    })
                    .disposed(by: (self?.rx.disposeBag)!)

                regServise.getCodeBtEnable
                    .drive(onNext: { beel in
                        phoneCodeBt.isEnabled = beel
                        if beel {
                            phoneCodeBt.backgroundColor = self?.bgColorAuthCode.toColor()
                            phoneCodeBt.setTitleColor(self?.colorAuthCodeTime.toColor(), for: .normal)
                            if !(self?.bgImgLoginBtnAct.isEmpty ?? true) {
                                phoneCodeBt.kf.setBackgroundImage(with: URL(string: (self?.bgImgLoginBtnAct ?? "")), for: .normal)
                            }
                        } else {
                            if !(self?.bgImgLoginBtn.isEmpty ?? true) {
                                phoneCodeBt.kf.setBackgroundImage(with: URL(string: (self?.bgImgLoginBtn ?? "")), for: .normal)
                            }
                            phoneCodeBt.backgroundColor = self?.bgColorAuthCodeSel.toColor()
                            phoneCodeBt.setTitleColor(self?.colorAuthCode.toColor(), for: .normal)
                        }
                    })
                    .disposed(by: (self?.rx.disposeBag)!)

                regServise.loginResult.drive().disposed(by: (self?.rx.disposeBag)!)
                regServise.getCodeResult
                    .drive(onNext: { params in
                        let phone = params.object(forKey: "phone_Email_num") as? String ?? ""
                        NetworkUtil.request(
                            target: .getPhoneEmailAuthCode(auth_type: "phone_login", code_key: codeKey ?? "", phone_Email_num: phone),
                            success: { _ in
                                phoneCodeBt.startTime()
                            }
                        ) { error in
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
        self.addSubview(scrollView)
        scrollView.addSubview(iconImgV)
        scrollView.addSubview(accountField)
        scrollView.addSubview(smsCodeField)
        scrollView.addSubview(loginBtnView)

        // 布局
        scrollView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(kScreenW)
        }
        // Logo 图片
        iconImgV.snp.makeConstraints { make in
            make.width.equalTo(65)
            make.height.equalTo(65)
            make.centerX.equalToSuperview()

            make.top.equalToSuperview().offset(30)
        }
        // 账号输入框
        accountField.snp.makeConstraints { make in
            make.left.right.equalTo(loginBtnView)
            make.centerX.equalToSuperview()
            make.top.equalTo(iconImgV.snp.bottom).offset(30)
            make.height.equalTo(Metric.fieldHeight)
        }

        //        imgCodeView.snp.makeConstraints { (make) in
        //            make.left.equalTo(accountField.snp.left)
        //            make.right.equalTo(accountField.snp.right)
        //            make.top.equalTo(accountField.snp.bottom).offset(MetricGlobal.margin * 2)
        //            make.height.equalTo(Metric.fieldHeight)
        //        }
        // 验证码
        smsCodeField.snp.makeConstraints { make in
            make.left.equalTo(accountField.snp.left)
            make.right.equalTo(accountField.snp.right)
            make.top.equalTo(accountField.snp.bottom).offset(MetricGlobal.margin * 2)
            make.height.equalTo(Metric.fieldHeight)
        }
        // 登陆按钮
        loginBtnView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(smsCodeField.snp.bottom).offset(MetricGlobal.margin * 2)
            make.width.equalTo(widthLoginBtnWidth)
            make.height.equalTo(heightLoginBtnHeight)
        }
    }

    // MARK: 事件处理
    @objc func touchItem(btn: UIButton) {
    }
}
