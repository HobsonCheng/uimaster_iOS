import Bugly
import Kingfisher
import UIKit

class Login: UIView, PageModuleAble {
    // MARK: 模块相关的配置属性
    private var appPic = 1//是否有图标
    private var loginStyle = 0//样式
    private var showType = 1//App 图标开关控制
    private var textBackPassword = "zh"//登陆内容 注册/找回密码 找回密码显示文字
    private var textImmediateRegistration = "zc"//登陆内容 注册/找回密码 注册显示文字
    private var textLoginButton = "dl"//登陆内容 登录按钮 显示文字
    private var bgColor = "255,255,255,1"
    private var borderWidth: CGFloat = 0//录入框边框 粗细
    private var fontSizeBtnAct: CGFloat = 15//按钮激活文字大小
    private var heightBtn: CGFloat = 30//登录按钮 高度
    private var iconAppPic = ""//内容 App图标
    private var marginLeft: CGFloat = 3//左边距
    private var titlePassword = "8"//内容 密码 提示文字
    private var bgImgInput = ""//录入框背景 图片
    private var borderShow = 1//录入框边框 是否显示
    private var iconPassword = ""//内容 密码
    private var marginRight: CGFloat = 5//右边距
    private var showShape = 1//App图形控制
    private var loginStyleChoose = 0
    private var titleVerifyingCode = "9"//内容 验证码 提示文字
    private var borderColor = "0,255,255,1"//录入框边框 颜色
    private var widthBtn: CGFloat = 280//登录按钮宽度
    private var opacityInput = 1//录入框背景 透明度
    private var bgImgBtn = ""//按钮默认背景 图片
    private var colorBtnAct = "212,212,212,1"//按钮激活文字 颜色
    private var fontSizeBtn = 17//按钮默认文字 大小
    private var fontSizeInput = 14//录入文字 大小
    private var marginBottom = 0//下边距
    private var textAlign = 1//注册找回密码文字 位置
    private var titleNickName = "7"//内容 用户名 提示文字
    private var bgColorBtnAct = "210,16,80,1"//默认背景激活 颜色
    private var bgImgModeInput = 1//录入框背景 平铺
    private var colorInput = "0,253,0,1"//录入文字 颜色
    private var colorInputTips = "104,104,255,1"//录入框提示文字 颜色
    private var fontSize = 14//注册找回密码文字 大小
    private var bgImgModeBtnAct = 2//默认激活背景 平铺
    private var colorBtn = "255,255,255,1"//默认按钮文字 颜色
    private var fontSizeInputTips = 18//录入框提示文字 大小
    private var marginTop = 2//上边距
    private var color = "255,0,0,1"//注册找回密码文字 颜色
    private var bgImgBtnAct = ""//默认激活背景 图片
    private var bgImgModeBtn = 0//默认背景 平铺
    private var iconVerifyingCode = ""//内容 验证码
    private var opacityBtnAct = 1//激活按钮背景 平铺
    private var bgColorBtn = "0,255,255,1"//默认按钮背景 颜色
    private var iconNickName = ""//内容 用户名
    private var opacityBtn = 1//默认按钮 透明度
    private var textAlignInput = 0//录入文字 位置
    private var textAlignInputTips = 1//录入框提示文字 位置
    private var titleAppPic = "6"// 内容 App图标 下面的字
    private var bgColorInput = "255,0,0,1"//录入框背景 颜色
    private var events: [String: EventsData]?

    weak var moduleDelegate: ModuleRefreshDelegate?
    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let loginModel = LoginModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.appPic = loginModel.fields?.appPic ?? self.appPic
                self.bgColorBtn = loginModel.styles?.bgColorBtn ?? self.bgColorBtn
                self.bgColorBtnAct = loginModel.styles?.bgColorBtnAct ?? self.bgColorBtnAct
                self.bgColorInput = loginModel.styles?.bgColorInput ?? self.bgColorInput
                self.bgImgBtn = loginModel.styles?.bgImgBtn ?? self.bgImgBtn
                self.bgImgBtnAct = loginModel.styles?.bgImgBtnAct ?? self.bgImgBtnAct
                self.bgImgInput = loginModel.styles?.bgImgInput ?? self.bgImgInput
                self.bgImgModeBtn = loginModel.styles?.bgImgModeBtn ?? self.bgImgModeBtn
                self.bgImgModeBtnAct = loginModel.styles?.bgImgModeBtnAct ?? self.bgImgModeBtnAct
                self.bgImgModeInput = loginModel.styles?.bgImgModeInput ?? self.bgImgModeInput
                self.borderColor = loginModel.styles?.borderColor ?? self.borderColor
                self.borderShow = loginModel.styles?.borderShow ?? self.borderShow
                self.borderWidth = loginModel.styles?.borderWidth ?? self.borderWidth
//                self.client_type = loginModel.styles?.client_type ?? self.client_type
                self.heightBtn = loginModel.styles?.heightBtn ?? self.heightBtn
                self.heightBtn = loginModel.styles?.heightBtn ?? self.heightBtn
                self.iconAppPic = loginModel.styles?.iconAppPic ?? self.iconAppPic
                self.iconNickName = loginModel.styles?.iconNickName ?? self.iconNickName
                self.iconPassword = loginModel.styles?.iconPassword ?? self.iconPassword
                self.iconVerifyingCode = loginModel.styles?.iconVerifyingCode ?? self.iconVerifyingCode
                self.loginStyleChoose = loginModel.styles?.loginStyleChoose ?? self.loginStyleChoose
                self.opacityBtn = loginModel.styles?.opacityBtn ?? self.opacityBtn
                self.opacityBtnAct = loginModel.styles?.opacityBtnAct ?? self.opacityBtnAct
                self.opacityInput = loginModel.styles?.opacityInput ?? self.opacityInput
                self.showShape = loginModel.styles?.showShape ?? self.showShape
                self.textBackPassword = loginModel.fields?.textBackPassword ?? self.textBackPassword
                self.textImmediateRegistration = loginModel.fields?.textImmediateRegistration ?? self.textImmediateRegistration
                self.textLoginButton = loginModel.fields?.textLoginButton ?? self.textLoginButton
                self.titleAppPic = loginModel.styles?.titleAppPic ?? self.titleAppPic
                self.titleNickName = loginModel.styles?.titleNickName ?? self.titleNickName
                self.titlePassword = loginModel.styles?.titlePassword ?? self.titlePassword
                self.titleVerifyingCode = loginModel.styles?.titleVerifyingCode ?? self.titleVerifyingCode
                self.widthBtn = loginModel.styles?.widthBtn ?? self.widthBtn
                self.widthBtn = loginModel.styles?.widthBtn ?? self.widthBtn
                self.events = loginModel.events

                //渲染UI
                renderUI()
                //获取数据
//                reloadViewData()
            }
        }
    }

    //模块特有属性
    private var pageNum: Int = 1//如果涉及到数据分页，需要此变量
    private var getCodeKey: String?

    // MARK: init方法
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI&事件处理
extension Login: AccountLoginable {
    //渲染UI
    private func renderUI() {
        self.backgroundColor = self.bgColor.toColor()
        //点击空白取消输入
        self.rx.tapGesture()
            .do(onNext: { [weak self] _ in
                self?.endEditing(true)
            })
            .subscribe()
            .disposed(by: rx.disposeBag)
        // MARK: 初始化输入框和登录按钮
        // 创建 容器
        let scrollView = UIScrollView().then {
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.contentSize = CGSize(width: self.width, height: 500)
        }
        // 创建 logo
        let iconImgV = UIImageView()
        let picUrlStr = GlobalConfigTool.shared.icon
        if let safeUrl = URL(string: picUrlStr) {
            let imageResource = ImageResource(downloadURL: safeUrl, cacheKey: kLogoCacheKey)
//            iconImgV.kf.setImage(with: URL.init(string: picUrlStr), placeholder: R.image.icon256()!, options: nil, progressBlock: nil, completionHandler: nil)
            iconImgV.kf.setImage(with: imageResource)
        }

        iconImgV.contentMode = .scaleAspectFill
        if showShape == 2 {
            iconImgV.layer.cornerRadius = 32.5
            iconImgV.layer.masksToBounds = true
        } else {
            iconImgV.layer.masksToBounds = true
            iconImgV.layer.cornerRadius = 5
        }

        // 账号输入框
        let accountField = initAccountField(placeholder: "手机号/邮箱") {
        }
//        accountField.bordersWidth = self.borderWidth
//        accountField.bordersColor = self.borderColor.toColor()
        accountField.backgroundColor = self.bgColorInput.toColor()
        // 密码
        let passwordField = initPasswordField {
        }
        passwordField.delegate = self
//        passwordField.bordersWidth = self.borderWidth
//        passwordField.bordersColor = self.borderColor.toColor()
        passwordField.backgroundColor = self.bgColorInput.toColor()
        // 图形验证码
        let imgCodeField = initImgCodeView(type: "login") { [weak self] codekey in
            self?.getCodeKey = codekey
        }
//        imgCodeField.bordersWidth = self.borderWidth
//        imgCodeField.bordersColor = self.borderColor.toColor()
        imgCodeField.backgroundColor = self.bgColorInput.toColor()
        //加入 短信验证或者邮箱验证入(密码登录没有短信验证码)
        //let (smsCodeField, phoneCodeBt) = initSMSCode { }
        //创建两侧的按钮
        let (bottomBtnView, registBtn, forgetPasswordBtn) = initRegistAndForgetPassword(showButtons: true) { event in
            if event.type == .regist { // 跳转注册页面
                let registEvent = self.events?["register"]
                let result = EventUtil.handleEvents(event: registEvent)
                EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
            } else if event.type == .forget { // 忘记密码
                let registEvent = self.events?["retrieve"]
                let result = EventUtil.handleEvents(event: registEvent)
                EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
            }
        }
        bottomBtnView.backgroundColor = .clear
        registBtn.setTitleColor("34,163,238,1".toColor(), for: .normal)
        forgetPasswordBtn.setTitleColor("34,163,238,1".toColor(), for: .normal)
        //创建登录按钮
        let (loginBtnView, loginBtn) = initLoginBtnView()
        loginBtnView.backgroundColor = .clear
        loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(self.fontSizeBtn))
        loginBtn.setTitle(self.textLoginButton, for: .normal)

        // 创建 视图模型
        let accountLoginView = AccountLoginViewModel(input: (accountField, passwordField, loginBtn, imgCodeField, nil), service: AccountLoginService.shareInstance)
        accountLoginView.accountUseable.drive(accountField.rx.validationResult).disposed(by: rx.disposeBag)
        accountLoginView.passwordUseable.drive(passwordField.rx.validationResult).disposed(by: rx.disposeBag)
        accountLoginView.loginBtnEnable
            .drive(onNext: { [weak self] beel in
                loginBtn.isEnabled = beel
                if beel {
//                loginBtn.titleLabel?.textColor = self?.colorBtnAct.toColor()
                    loginBtn.backgroundColor = self?.bgColorBtnAct.toColor()
                    if !(self?.bgImgBtnAct.isEmpty ?? true) {
                        loginBtn.kf.setBackgroundImage(with: URL(string: (self?.bgImgBtnAct ?? "")), for: .normal)
                    }
                } else {
                    if !(self?.bgImgBtn.isEmpty ?? true) {
                        loginBtn.kf.setBackgroundImage(with: URL(string: (self?.bgImgBtn ?? "")), for: .normal)
                    }
                    loginBtn.backgroundColor = self?.bgColorBtn.toColor()
//                loginBtn.titleLabel?.textColor = self?.colorBtn.toColor()
                }
            })
            .disposed(by: rx.disposeBag)

        //获取验证码(密码登录不用获取了 edit by gcz 2018-07-14 20:55:48)
        //        accountLoginView.smsBtnEnable.drive(onNext: { (params) in
        //            if params.object(forKey: "phone_Email_num") != nil {
        //                let phone = params.object(forKey: "phone_Email_num")
        //                let auth_code = params.object(forKey: "auth_code")
        //
        //                Util.getSMSCode(type: "login", phone: phone as! String, codekey: getCodeKey!, auth_code: auth_code as! String, callback: { (code) in
        //
        //                    if code != nil {
        //                        phoneCodeBt.startTime()
        //                    } else {
        //                        phoneCodeBt.isUserInteractionEnabled = true
        //                        phoneCodeBt.setTitle("获取失败请重试", for: UIControlState.normal)
        //                    }
        //                })
        //            }
        //
        //        }).disposed(by: rx.disposeBag)

        accountLoginView.loginResult
            .drive(onNext: { result in
                let userName = result.paramsObj.value(forKey: "username") as? String ?? ""
                let password = result.paramsObj.value(forKey: "password") as? String ?? ""
                let authCode = result.paramsObj.value(forKey: "auth_code") as? String ?? ""
                NetworkUtil.request(
                    target: .userLogin(username: userName, password: password, code_key: self.getCodeKey ?? "", auth_code: authCode),
                    success: { [weak self] json in
                        HUDUtil.msg(msg: "登录成功", type: .successful)
                        //保存authorization
                        let model = UserInfoModel.deserialize(from: json)?.data
                        let authorization = model?.authorization ?? ""
                        saveUserDefaults(key: kAuthorization + "\(GlobalConfigTool.shared.appId ?? 0)", value: authorization)

                        //获取聊天RC4加密key
                        NetworkUtil.request(
                            target: NetworkService.getRC4Key,
                            success: { data in
                                let key = RC4KeyModel.deserialize(from: data)?.data?.key ?? ""
                                saveUserDefaults(key: kRC4Key, value: key)
                            },
                            failure: nil)

                        //获取完整个人信息
                        NetworkUtil.request(
                            target: .getInfo(user_id: model?.uid ?? 0, user_pid: model?.pid ?? 0),
                            success: { json in
                                UserUtil.share.saveUser(userInfo: json)
                                DispatchQueue.global().sync {
                                    DatabaseTool.shared.createUserDatabase()
                                    NotificationCenter.default.post(name: Notification.Name(kChatSessionListDataChange), object: nil)
                                }
                                //开启聊天
                                UIApplication.shared.registerForRemoteNotifications()
                            }
                        ) { error in
                            dPrint(error)
                        }
                        //收起键盘
                        self?.endEditing(true)
                        //通知个人信息变化
                        NotificationCenter.default.post(name: Notification.Name(kPersonalInfoChangeNotification), object: nil)
                        //退出当前页面
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            _ = VCController.pop(with: VCAnimationBottom.defaultAnimation())
                        }
                    }
                ) { error in
                    NotificationCenter.default.post(name: Notification.Name(kImageCodeUpdate), object: nil)
                    dPrint(error)
                }
            })
            .disposed(by: rx.disposeBag)

        // 添加
        self.addSubview(scrollView)
        scrollView.addSubview(iconImgV)
        scrollView.addSubview(accountField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginBtnView)
        scrollView.addSubview(imgCodeField)
        scrollView.addSubview(bottomBtnView)
        //        scrollView.addSubview(otherLoginView)
        //        scrollView.addSubview(smsCodeField)
        // 布局
        scrollView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }

        iconImgV.snp.makeConstraints { make in
            make.width.equalTo(65)
            make.height.equalTo(65)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
        }

        accountField.snp.makeConstraints { make in
            make.left.right.equalTo(loginBtnView)
            make.centerX.equalToSuperview()
            //            make.top.equalToSuperview().offset(MetricGlobal.margin * 2)
            make.top.equalTo(iconImgV.snp.bottom).offset(30)
            make.height.equalTo(Metric.fieldHeight)
        }

        imgCodeField.snp.makeConstraints { make in
            make.left.equalTo(accountField.snp.left)
            make.right.equalTo(accountField.snp.right)
            make.top.equalTo(accountField.snp.bottom).offset(10)
            make.height.equalTo(Metric.fieldHeight)
        }

        passwordField.snp.makeConstraints { make in
            make.left.right.equalTo(accountField)
            make.centerX.equalToSuperview()
            //            make.top.equalToSuperview().offset(MetricGlobal.margin * 2)
            make.top.equalTo(imgCodeField.snp.bottom).offset(10)
            make.height.equalTo(Metric.fieldHeight)
        }

        loginBtnView.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(widthBtn)
            make.height.equalTo(heightBtn)
        }
        bottomBtnView.snp.makeConstraints { make in
            make.top.equalTo(loginBtnView.snp.bottom).offset(10)
            make.height.equalTo(30)
            make.left.equalTo(loginBtnView.snp.left)
            make.right.equalTo(loginBtnView.snp.right)
        }

        //        smsCodeField.snp.makeConstraints { (make) in
        //
        //            make.left.equalTo(imgCodeView.snp.left)
        //            make.right.equalTo(imgCodeView.snp.right)
        //            make.top.equalTo(imgCodeView.snp.bottom).offset(MetricGlobal.margin * 1)
        //
        //            //单纯验证码
        //            let  auth_code_type = AllRestrictionHandler.shared.ucSetCofig?.project_set?.login_auth_code_type
        //
        //            if auth_code_type == 0 {//图片验证码
        //                 make.height.equalTo(0)
        //            } else { //  if auth_code_type == 1
        //
        //                 make.height.equalTo(Metric.fieldHeight)
        //            }
        //
        //        }
        //        otherLoginView.snp.makeConstraints { (make) in
        //
        //            if kScreenW <= 320 {
        //                make.left.equalTo(accountField.snp.left).offset(-MetricGlobal.margin * 1)
        //            } else {
        //                make.left.equalTo(accountField.snp.left).offset(-MetricGlobal.margin * 2)
        //            }
        //            make.centerX.equalToSuperview()
        //            make.top.equalTo(loginBtnView.snp.bottom)
        //            make.bottom.equalToSuperview()
        //        }
        //
        //        otherLoginView.isHidden = true

    }

    // MARK: 事件处理
    @objc func touchItem(btn: UIButton) {
    }
}

// MARK: - 网络请求
extension Login {
    //页面刷新时会调用该方法
    func reloadViewData() {
        //加载更多时，分页数加1，不需要分页可以去掉下面这行
        self.pageNum = 1
        //请求M2数据信息
        self.requestLoginData()
    }

    func loadMoreData() {
        self.pageNum += 1
        self.requestLoginData()
    }

    //获取Login数据
    private func requestLoginData() {
//        let params = NSMutableDictionary()
//        params.setValue(self.pageNum, forKey: "page")//涉及分页需要此字段
//        params.setValue("20", forKey: "page_context")//涉及分页需要此字段
//        params.setValue(<#value#>, forKey: <#key#>)
//
//        ApiUtil.share.<#api名#>(params: params ) { [weak self] (status, data, _) in
//            //请求成功
//            if status == ResponseStatus.success {
//                //转成对应的数据模型，不分页
//                self?.itemList = LoginModel.deserialize(from: data)?.data
//                //如果数据需要分页，使用下面的代码
//                let tmpList = LoginModel.deserialize(from: data)?.data
//                guard let safeTmpList = tmpList else{
//                    return
//                }
//                if self?.page == 1 {
//                    self?.itemList = safeTmpList
//                } else if let safeList = self?.itemList{
//                    self?.itemList = safeList + safeTmpList
//                }
//
//                //tableview需要刷新数据
//                //self?.reloadData()
//                //处理UI
//                self?.renderItems()
//            }
//            //请求完成，回调告知AssembleVC停止刷新
//            if let safeCB = self?.checkRefreshCB {
//                safeCB()
//            }
//        }
    }
}

// MARK: - 代理方法
/**
 1.协议的采纳放到该扩展上。
 2.代理方法统一放到这里，不同的代理用//MARK: 分开
 */
//extension Login: <#LoginDelegate#> {
//    
//}
extension Login: UITextFieldDelegate {
    //监听输入值的变化
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let toBeString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
//        if textField.isSecureTextEntry {
//            textField.text = toBeString
//            return false
//        }
//        return true
//    }

}
