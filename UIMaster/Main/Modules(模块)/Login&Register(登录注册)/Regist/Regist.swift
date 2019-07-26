//  模块通用模板,保持整体完整性，
//  不需要的部分可以先注释掉，之后完成后，再统一删掉
//  可以参考Regist模块，如果涉及到分页显示数据，请参考GroupListTopic模块

import SwiftyJSON
import UIKit

class RegistModel: BaseData {
    var events: [String: EventsData]?
    var fields: RegistFields?
    var styles: RegistStyles?
}

class RegistFields: BaseData {
    var textGetVerifyingCode: String?
    var textLinkText: String?
    var textRegistrationButton: String?
    var textDefaultText: String?
}

class RegistStyles: BaseStyleModel {
    var bgImgRegisterBtnAct: String?//注册按钮激活背景 背景图片
    var colorRegisterAct: String?//注册按钮激活文字 颜色
    var heightAutoCodeHeight: Int?//验证码按钮高度
    var opacityInput: CGFloat?//录入框背景 透明度
    var titleAppPic: String?//内容栏 APP图标 提示
    var titleConfirmPassword: String?//内容 确认密码 提示
    var colorRegisterBtn: String?//注册按钮默认文字 颜色
    var fontSizeTip: CGFloat?//提示文字 大小
    var titleVerificationCode: String?//内容 验证码 提示
    var bgImgModeAutoCodeBtnAct: CGFloat?//点击背景 背景图片
    var borderShowInput: Int?//录入框边框 是否显示
    var textAlignTip: CGFloat?//提示文字 位置
    var colorAutoCodeTime: String?//验证码时间数字 颜色
    var fontSizeAutoCode: CGFloat?//验证码默认文字 大小
    var fontSizeRegisterBtn: CGFloat?//注册按钮默认文字 大小
    var titlePhoneNumber: String?// 内容 手机号 提示
    var widthRegisterBtnWidth: CGFloat?//注册按钮宽度
    var showType: Int?//开关控制App图标
    var bgColorInput: String?//录入框背景 颜色
    var bgColorRegisterBtn: String?//注册按钮默认背景 背景颜色
    var bgImgRegisterBtn: String?//注册按钮默认背景 背景图片
    var opacityAutoCodeBtnAct: CGFloat?//点击背景 透明度
    var textAlignRegisterAct: CGFloat?//注册按钮激活文字 位置
    var bgImgModeAutoCodeBtn: CGFloat?//验证码按钮默认背景 平铺
    var colorLink: String?//注册协议链接文字 颜色
    var colorAutoCode: String?//验证码默认文字 颜色
    var bgImgModeRegisterBtnAct: CGFloat?//注册按钮激活背景 背景图片
    var borderWidthInput: CGFloat?//录入框边框 宽度
    var colorTip: String?//提示文字 颜色
    var fontSizeInput: CGFloat?//录入文字 大小
    var opacityAutoCodeBtn: CGFloat?//验证码按钮默认背景 透明度
    var opacityRegisterBtnAct: CGFloat?//注册按钮激活 透明度
    var textAlignInput: CGFloat?//录入文字 位置
    var textAlignPtc: CGFloat?//注册协议文字 位置
    var bgColorAutoCodeBtnAct: String?//点击背景 背景颜色
    var bgImgInput: String?//录入框背景 背景图片
    var textAlignAutoCode: CGFloat?//验证码默认文字 位置
    var textAlignLink: CGFloat?//注册协议链接文字 位置
    var widthAutoCodeWidth: CGFloat?//验证码按钮宽度
    var bgImgAutoCodeBtnAct: String?//点击后背景 背景图片
    var colorPtc: String?//注册协议文字 颜色
    var titleNickName: String?//内容 昵称 提示
    var bgColorAutoCodeBtn: String?//验证码按钮默认背景 背景颜色
    var fontSizePtc: CGFloat?//注册协议文字 大小
    var textAlignAutoCodeTime: CGFloat?//验证码时间数字 位置
    var bgColorRegisterBtnAct: String?//注册按钮激活背景 背景颜色
    var borderColorAutoCodeBtn: String?//验证码按钮边框 颜色
    var opacityRegisterBtn: CGFloat?//注册按钮默认背景 透明度
    var textAlignRegisterBtn: CGFloat?//注册按钮默认文字 位置
    var bgImgAutoCodeBtn: String?//验证码按钮默认背景 图片
    var bgImgModeInput: CGFloat?//录入框背景 背景平铺
    var borderWidthAutoCodeBtn: CGFloat?//验证码按钮边框 宽度
    var colorInput: String?//录入文字 颜色
    var fontSizeLink: CGFloat?//注册协议链接文字 大小
    var fontSizeRegisterAct: CGFloat?//注册按钮激活文字 大小
    var bgImgModeRegisterBtn: CGFloat?//注册按钮默认背景 背景平铺
    var borderColorInput: String?//录入框边框 颜色
    var borderShowAutoCodeBtn: Int?//验证码按钮边框 是否显示
    var heightRegisterBtnHeight: Int?//注册按钮高度
    var showShape: Int?//开关控制图形形状
    var titlePassword: String?//内容 密码 提示
    var fontSizeAutoCodeTime: CGFloat?//验证码时间数字 大小
    var iconVerificationCode: String?//内容 验证码 图标
    var iconPhoneNumber: String?//内容 手机号 图标
    var iconAppPic: String?//内容 APP 图标
    var iconConfirmPassword: String?//内容 确认密码 图标
    var iconNickName: String?//内容 昵称 图标
}

class Regist: UIView, PageModuleAble {
    // MARK: 模块相关的配置属性
    private var bgColorAutoCodeBtn = "76,217,100,1"//
    private var bgColorAutoCodeBtnAct = "0,60,255,1"//
    private var bgColorInput = "255,255,255,1"//
    private var bgColorRegisterBtn = "0,122,255,1"//
    private var bgColorRegisterBtnAct = "0,122,255,1"//
    private var bgColor = "255,255,255,1"
    private var bgImgAutoCodeBtn = ""//
    private var bgImgAutoCodeBtnAct = ""//
    private var bgImgInput = ""//
    private var bgImgModeAutoCodeBtn = -1//
    private var bgImgModeAutoCodeBtnAct = -1//
    private var bgImgModeInput = -1//
    private var bgImgModeRegisterBtn = 0//
    private var bgImgModeRegisterBtnAct = 0//
    private var bgImgRegisterBtn = ""//
    private var bgImgRegisterBtnAct = ""//
    private var borderColorAutoCodeBtn = "255,235,0,1"//
    private var borderColorInput = "0,255,0,1"//
    private var borderShowAutoCodeBtn = 1//
    private var borderShowInput = 1//
    private var borderWidthAutoCodeBtn: CGFloat = 0//
    private var borderWidthInput: CGFloat = 0//
    private var colorAutoCode = "255,255,255,1"//
    private var colorAutoCodeTime = "255,255,255,1"//
    private var colorInput = "255,0,255,1"//
    private var colorLink = "0,122,255,1"//
    private var colorPtc = "42,42,42,1"//
    private var colorRegisterAct = "255,255,255,1"//
    private var colorRegisterBtn = "255,255,255,1"//
    private var colorTip = "42,42,42,1"//
    private var fontSizeAutoCode: CGFloat = 14//
    private var fontSizeAutoCodeTime: CGFloat = 15//
    private var fontSizeInput: CGFloat = 16//
    private var fontSizeLink: CGFloat = 15//
    private var fontSizePtc: CGFloat = 15//
    private var fontSizeRegisterAct: CGFloat = 15//
    private var fontSizeRegisterBtn: CGFloat = 15//
    private var fontSizeTip: CGFloat = 15//
    private var heightAutoCodeHeight = 35//
    private var heightRegisterBtnHeight = 58//
    private var iconAppPic = ""//
    private var iconConfirmPassword = ""//
    private var iconNickName = ""//
    private var iconPhoneNumber = ""//
    private var iconVerificationCode = ""//
    private var marginBottom = 0//
    private var marginLeft = 1//
    private var marginRight = 0//
    private var marginTop = 0//
    private var opacityAutoCodeBtn = 1//
    private var opacityAutoCodeBtnAct = 1//
    private var opacityInput = 1//
    private var opacityRegisterBtn = 1//
    private var opacityRegisterBtnAct = 1//
    private var showShape = 1//
    private var textAlignAutoCode = 1//
    private var textAlignAutoCodeTime = 1//
    private var textAlignInput = 0//
    private var textAlignLink = 1//
    private var textAlignPtc = 1//
    private var textAlignRegisterAct = 1//
    private var textAlignRegisterBtn = 1//
    private var textAlignTip = 0//
    private var textDefaultText = "999"//
    private var textGetVerifyingCode = "777"//
    private var textLinkText = "1024"//
    private var textRegistrationButton = "888"//
    private var titleAppPic = "111"//
    private var titleConfirmPassword = "555"//
    private var titleNickName = "666"//
    private var titlePassword = "444"//
    private var titlePhoneNumber = "222"//
    private var titleVerificationCode = "333"//
    private var widthAutoCodeWidth: CGFloat = 98//
    private var widthRegisterBtnWidth: CGFloat = 315//
    private var events: [String: EventsData]?

    weak var moduleDelegate: ModuleRefreshDelegate?
    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let registModel = RegistModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.bgColor = registModel.styles?.bgColor ?? self.bgColor
                self.bgColorAutoCodeBtn = registModel.styles?.bgColorAutoCodeBtn ?? self.bgColorAutoCodeBtn
                self.bgColorAutoCodeBtnAct = registModel.styles?.bgColorAutoCodeBtnAct ?? self.bgColorAutoCodeBtnAct
                self.bgColorInput = registModel.styles?.bgColorInput ?? self.bgColorInput
                self.bgColorRegisterBtn = registModel.styles?.bgColorRegisterBtn ?? self.bgColorRegisterBtn
                self.bgColorRegisterBtnAct = registModel.styles?.bgColorRegisterBtnAct ?? self.bgColorRegisterBtnAct
                self.bgImgAutoCodeBtn = registModel.styles?.bgImgAutoCodeBtn ?? self.bgImgAutoCodeBtn
                self.bgImgAutoCodeBtnAct = registModel.styles?.bgImgAutoCodeBtnAct ?? self.bgImgAutoCodeBtnAct
                self.bgImgInput = registModel.styles?.bgImgInput ?? self.bgImgInput
                //                self.bgImgModeAutoCodeBtn = registModel.styles?.bgImgModeAutoCodeBtn ?? self.bgImgModeAutoCodeBtn
                //                self.bgImgModeAutoCodeBtnAct = registModel.styles?.bgImgModeAutoCodeBtnAct ?? self.bgImgModeAutoCodeBtnAct
                //                self.bgImgModeInput = registModel.styles?.bgImgModeInput ?? self.bgImgModeInput
                //                self.bgImgModeRegisterBtn = registModel.styles?.bgImgModeRegisterBtn ?? self.bgImgModeRegisterBtn
                //                self.bgImgModeRegisterBtnAct = registModel.styles?.bgImgModeRegisterBtnAct ?? self.bgImgModeRegisterBtnAct
                self.bgImgRegisterBtn = registModel.styles?.bgImgRegisterBtn ?? self.bgImgRegisterBtn
                self.bgImgRegisterBtnAct = registModel.styles?.bgImgRegisterBtnAct ?? self.bgImgRegisterBtnAct
                self.borderColorAutoCodeBtn = registModel.styles?.borderColorAutoCodeBtn ?? self.borderColorAutoCodeBtn
                self.borderColorInput = registModel.styles?.borderColorInput ?? self.borderColorInput
                self.borderShowAutoCodeBtn = registModel.styles?.borderShowAutoCodeBtn ?? self.borderShowAutoCodeBtn
                self.borderShowInput = registModel.styles?.borderShowInput ?? self.borderShowInput
                self.borderWidthAutoCodeBtn = registModel.styles?.borderWidthAutoCodeBtn ?? self.borderWidthAutoCodeBtn
                self.borderWidthInput = registModel.styles?.borderWidthInput ?? self.borderWidthInput
                self.colorAutoCode = registModel.styles?.colorAutoCode ?? self.colorAutoCode
                self.colorAutoCodeTime = registModel.styles?.colorAutoCodeTime ?? self.colorAutoCodeTime
                self.colorInput = registModel.styles?.colorInput ?? self.colorInput
                self.colorLink = registModel.styles?.colorLink ?? self.colorLink
                self.colorPtc = registModel.styles?.colorPtc ?? self.colorPtc
                self.colorRegisterAct = registModel.styles?.colorRegisterAct ?? self.colorRegisterAct
                self.colorRegisterBtn = registModel.styles?.colorRegisterBtn ?? self.colorRegisterBtn
                self.colorTip = registModel.styles?.colorTip ?? self.colorTip
                self.fontSizeAutoCode = registModel.styles?.fontSizeAutoCode ?? self.fontSizeAutoCode
                self.fontSizeAutoCodeTime = registModel.styles?.fontSizeAutoCodeTime ?? self.fontSizeAutoCodeTime
                self.fontSizeInput = registModel.styles?.fontSizeInput ?? self.fontSizeInput
                self.fontSizeLink = registModel.styles?.fontSizeLink ?? self.fontSizeLink
                self.fontSizePtc = registModel.styles?.fontSizePtc ?? self.fontSizePtc
                self.fontSizeRegisterAct = registModel.styles?.fontSizeRegisterAct ?? self.fontSizeRegisterAct
                self.fontSizeRegisterBtn = registModel.styles?.fontSizeRegisterBtn ?? self.fontSizeRegisterBtn
                self.fontSizeTip = registModel.styles?.fontSizeTip ?? self.fontSizeTip
                self.heightAutoCodeHeight = registModel.styles?.heightAutoCodeHeight ?? self.heightAutoCodeHeight
                self.heightRegisterBtnHeight = registModel.styles?.heightRegisterBtnHeight ?? self.heightRegisterBtnHeight
                self.iconAppPic = registModel.styles?.iconAppPic ?? self.iconAppPic
                self.iconConfirmPassword = registModel.styles?.iconConfirmPassword ?? self.iconConfirmPassword
                self.iconNickName = registModel.styles?.iconNickName ?? self.iconNickName
                self.iconPhoneNumber = registModel.styles?.iconPhoneNumber ?? self.iconPhoneNumber
                self.iconVerificationCode = registModel.styles?.iconVerificationCode ?? self.iconVerificationCode
                //                self.marginBottom = registModel.styles?.marginBottom ?? self.marginBottom
                //                self.marginLeft = registModel.styles?.marginLeft ?? self.marginLeft
                //                self.marginRight = registModel.styles?.marginRight ?? self.marginRight
                //                self.marginTop = registModel.styles?.marginTop ?? self.marginTop
                //                self.opacityAutoCodeBtn = registModel.styles?.opacityAutoCodeBtn ?? self.opacityAutoCodeBtn
                //                self.opacityAutoCodeBtnAct = registModel.styles?.opacityAutoCodeBtnAct ?? self.opacityAutoCodeBtnAct
                //                self.opacityInput = registModel.styles?.opacityInput ?? self.opacityInput
                //                self.opacityRegisterBtn = registModel.styles?.opacityRegisterBtn ?? self.opacityRegisterBtn
                //                self.opacityRegisterBtnAct = registModel.styles?.opacityRegisterBtnAct ?? self.opacityRegisterBtnAct
                self.showShape = registModel.styles?.showShape ?? self.showShape
                //                self.textAlignAutoCode = registModel.styles?.textAlignAutoCode ?? self.textAlignAutoCode
                //                self.textAlignAutoCodeTime = registModel.styles?.textAlignAutoCodeTime ?? self.textAlignAutoCodeTime
                //                self.textAlignInput = registModel.styles?.textAlignInput ?? self.textAlignInput
                //                self.textAlignLink = registModel.styles?.textAlignLink ?? self.textAlignLink
                //                self.textAlignPtc = registModel.styles?.textAlignPtc ?? self.textAlignPtc
                //                self.textAlignRegisterAct = registModel.styles?.textAlignRegisterAct ?? self.textAlignRegisterAct
                //                self.textAlignRegisterBtn = registModel.styles?.textAlignRegisterBtn ?? self.textAlignRegisterBtn
                //                self.textAlignTip = registModel.styles?.textAlignTip ?? self.textAlignTip
                self.textDefaultText = registModel.fields?.textDefaultText ?? self.textDefaultText
                self.textGetVerifyingCode = registModel.fields?.textGetVerifyingCode ?? self.textGetVerifyingCode
                self.textLinkText = registModel.fields?.textLinkText ?? self.textLinkText
                self.textRegistrationButton = registModel.fields?.textRegistrationButton ?? self.textRegistrationButton
                self.titleAppPic = registModel.styles?.titleAppPic ?? self.titleAppPic
                self.titleConfirmPassword = registModel.styles?.titleConfirmPassword ?? self.titleConfirmPassword
                self.titleNickName = registModel.styles?.titleNickName ?? self.titleNickName
                self.titlePassword = registModel.styles?.titlePassword ?? self.titlePassword
                self.titlePhoneNumber = registModel.styles?.titlePhoneNumber ?? self.titlePhoneNumber
                self.titleVerificationCode = registModel.styles?.titleVerificationCode ?? self.titleVerificationCode
                //                self.widthAutoCodeWidth = registModel.styles?.widthAutoCodeWidth ?? self.widthAutoCodeWidth
                //                self.widthRegisterBtnWidth = registModel.styles?.widthRegisterBtnWidth ?? self.widthRegisterBtnWidth
                self.events = registModel.events
                //                //渲染UI
                renderUI()
                //                //获取数据
                //                reloadViewData()
            }
        }
    }

    //模块特有属性
    private var pageNum: Int = 1//如果涉及到数据分页，需要此变量

    // MARK: init方法
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 网络请求
extension Regist {
    //页面刷新时会调用该方法
    func reloadViewData() {
        //加载更多时，分页数加1，不需要分页可以去掉下面这行
        self.pageNum = 1
        //请求M2数据信息
        self.requestRegistData()
    }

    func loadMoreData() {
        self.pageNum += 1
        //请求M2数据信息
        self.requestRegistData()
    }

    //获取Regist数据
    private func requestRegistData() {
        //        let params = NSMutableDictionary()
        //        params.setValue(self.pageNum, forKey: "page")//涉及分页需要此字段
        //        params.setValue("20", forKey: "page_context")//涉及分页需要此字段
        //        params.setValue(<#value#>, forKey: <#key#>)
        //
        //        ApiUtil.share.<#api名#>(params: params ) { [weak self] (status, data, _) in
        //            //请求成功
        //            if status == ResponseStatus.success {
        //                //转成对应的数据模型，不分页
        //                self?.itemList = RegistModel.deserialize(from: data)?.data
        //                //如果数据需要分页，使用下面的代码
        //                let tmpList = RegistModel.deserialize(from: data)?.data
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

// MARK: - UI&事件处理
extension Regist: AccountLoginable {
    //渲染UI
    private func renderUI() {
        self.backgroundColor = self.bgColor.toColor()
        // 创建 容器组件
        let scrollView = UIScrollView().then {
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.contentSize = CGSize(width: self.width, height: 500)
        }

        // 创建 协议组件
        let iconImgV = UIImageView()
        let picUrlStr = GlobalConfigTool.shared.icon
        iconImgV.kf.setImage(with: URL(string: picUrlStr), placeholder: R.image.icon256()!, options: nil, progressBlock: nil, completionHandler: nil)
        iconImgV.contentMode = .scaleAspectFill
        iconImgV.layer.masksToBounds = true
        iconImgV.layer.cornerRadius = self.showShape == 2 ? 0 : 32.5

        let accountField = initOtherField(type: 1, titleStr: "手机号/邮箱") {
        }
        //        accountField.bordersWidth = self.borderWidthInput
        //        accountField.bordersColor = self.borderColorInput.toColor()
        accountField.backgroundColor = self.bgColorInput.toColor()
        let passwordField = initOtherField(type: 2, titleStr: "密码") {
        }
        passwordField.delegate = self
        //        passwordField.bordersWidth = self.borderWidthInput
        passwordField.backgroundColor = self.bgColorInput.toColor()
        //        passwordField.bordersColor = self.borderColorInput.toColor()
        let passwordField2 = initOtherField(type: 2, titleStr: "确认密码", otherField: passwordField) {
        }
        passwordField2.delegate = self
        //        passwordField_2.bordersWidth = self.borderWidthInput
        passwordField2.backgroundColor = self.bgColorInput.toColor()
        //        passwordField_2.bordersColor = self.borderColorInput.toColor()
        let nicknameField = initOtherField(type: 3, titleStr: "昵称") {
        }
        //        nicknameField.bordersWidth = self.borderWidthInput
        //        nicknameField.bordersColor = self.borderColorInput.toColor()
        nicknameField.backgroundColor = self.bgColorInput.toColor()
        let (regBtnView, regBT) = initRegBtnView { event in
            dPrint(event)
        }

        var getcodeo = ""
        //        weak var tmpimgCodeView: UITextField?
        //        tmpimgCodeView = UITextField()

        //加入 短信验证或者邮箱验证入
        let (smsCodeField, phoneCodeBt) = initSMSCode {
        }
        smsCodeField.bordersWidth = self.borderWidthInput
        smsCodeField.bordersColor = self.borderColorInput.toColor()
        smsCodeField.backgroundColor = self.bgColorInput.toColor()
        //单纯验证码
        //        let  auth_code_type = AllRestrictionHandler.shared.ucSetCofig.project_set?.regist_auth_code_type

        //        var imgCodeView: UITextField!
        //        if auth_code_type == 0 {//图片验证码
        //            imgCodeView = initImgCodeView(type: "regist") { [weak self] (codekey) in
        //                getcodeo = codekey!
        //                let regServise = RegVCService(input: (accountField, passwordField, passwordField_2, nicknameField, tmpimgCodeView!, regBT,UITextField()), codekey: getcodeo)
        //
        //                regServise.loginBtnEnable.drive(onNext: { (beel) in
        //
        //                    regBT.isEnabled = beel
        //
        //                }).disposed(by: (self?.rx.disposeBag)!)
        //                regServise.loginResult.drive().disposed(by: (self?.rx.disposeBag)!)
        //
        //            }
        //            tmpimgCodeView = imgCodeView
        //        }else if auth_code_type == 1 {

        //            tmpimgCodeView = UITextField()
        NetworkUtil.request(
            target: .authCodeKey,
            success: { [weak self] json in
                let dic = JSON(parseJSON: json ?? "")["data"].dictionaryObject
                let codeKey = dic?["code_key"] as? String
                getcodeo = codeKey ?? ""
                let regServise = PhoneService(input: (accountField, nil, smsCodeField, regBT, phoneCodeBt), codekey: getcodeo)

                regServise.getCodeBtEnable
                    .drive(onNext: { beel in
                        phoneCodeBt.isEnabled = beel
                        if beel {
                            phoneCodeBt.titleLabel?.textColor = self?.colorAutoCodeTime.toColor()
                            phoneCodeBt.backgroundColor = self?.bgColorAutoCodeBtn.toColor()
                            if !(self?.bgImgAutoCodeBtn.isEmpty ?? true) {
                                phoneCodeBt.kf.setBackgroundImage(with: URL(string: (self?.bgImgAutoCodeBtn ?? "")), for: .normal)
                            }
                        } else {
                            if !(self?.bgImgAutoCodeBtnAct.isEmpty ?? true) {
                                phoneCodeBt.kf.setBackgroundImage(with: URL(string: (self?.bgImgAutoCodeBtnAct ?? "")), for: .normal)
                            }
                            phoneCodeBt.backgroundColor = self?.bgColorAutoCodeBtnAct.toColor()
                            phoneCodeBt.titleLabel?.textColor = self?.colorAutoCode.toColor()
                        }
                    })
                    .disposed(by: (self?.rx.disposeBag)!)

                regServise.getCodeResult
                    .drive(onNext: { params in
                        let phone = params.object(forKey: "phone_Email_num") as? String ?? ""
                        guard InputValidator.isValidPhone(phoneNum: phone) || InputValidator.isValidEmail(email: phone) else {
                            HUDUtil.msg(msg: "手机号或邮箱格式不正确", type: .error)
                            return
                        }
                        //let auth_code = params.object(forKey: "auth_code")
                        NetworkUtil.request(
                            target: .getPhoneEmailAuthCode(auth_type: "regist", code_key: codeKey ?? "", phone_Email_num: phone),
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

                let newregServise = RegVCService(input: (accountField, passwordField, passwordField2, nicknameField, nil, regBT, smsCodeField), codekey: getcodeo)

                newregServise.loginBtnEnable
                    .drive(onNext: { beel in
                        regBT.isEnabled = beel
                        if beel {
                            regBT.titleLabel?.textColor = self?.colorRegisterAct.toColor()
                            regBT.backgroundColor = self?.bgColorRegisterBtnAct.toColor()
                            if !(self?.bgImgRegisterBtnAct.isEmpty ?? true) {
                                regBT.kf.setBackgroundImage(with: URL(string: (self?.bgImgRegisterBtnAct ?? "")), for: .normal)
                            }
                        } else {
                            if !(self?.bgImgRegisterBtn.isEmpty ?? true) {
                                regBT.kf.setBackgroundImage(with: URL(string: (self?.bgImgRegisterBtn ?? "")), for: .normal)
                            }
                            regBT.backgroundColor = self?.bgColorRegisterBtn.toColor()
                            regBT.titleLabel?.textColor = self?.colorRegisterBtn.toColor()
                        }
                    })
                    .disposed(by: (self?.rx.disposeBag)!)
                newregServise.loginResult.drive().disposed(by: (self?.rx.disposeBag)!)
            }) { error in
            dPrint(error)
        }

        //            tmpimgCodeView = imgCodeView
        //        }

        // 添加
        self.addSubview(scrollView)
        scrollView.addSubview(iconImgV)
        scrollView.addSubview(accountField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(passwordField2)
        scrollView.addSubview(nicknameField)
        //        scrollView.addSubview(imgCodeView)
        scrollView.addSubview(smsCodeField)
        scrollView.addSubview(regBtnView)

        // 布局
        scrollView.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(kScreenW)
        }

        iconImgV.snp.makeConstraints { make in
            make.width.equalTo(65)
            make.height.equalTo(65)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
        }

        accountField.snp.makeConstraints { make in
            make.left.right.equalTo(regBtnView)
            make.centerX.equalToSuperview()
            make.top.equalTo(iconImgV.snp.bottom).offset(30)
            make.height.equalTo(Metric.fieldHeight)
        }

        smsCodeField.snp.makeConstraints { make in
            make.left.right.equalTo(regBtnView)
            make.centerX.equalToSuperview()
            make.top.equalTo(accountField.snp.bottom).offset(10)
            make.height.equalTo(Metric.fieldHeight)
        }

        passwordField.snp.makeConstraints { make in
            make.left.right.equalTo(regBtnView)
            make.centerX.equalToSuperview()
            make.top.equalTo(smsCodeField.snp.bottom).offset(10)
            make.height.equalTo(Metric.fieldHeight)
        }

        passwordField2.snp.makeConstraints { make in
            make.left.right.equalTo(regBtnView)
            make.centerX.equalToSuperview()
            make.top.equalTo(passwordField.snp.bottom).offset(10)
            make.height.equalTo(Metric.fieldHeight)
        }

        nicknameField.snp.makeConstraints { make in
            make.left.right.equalTo(regBtnView)
            make.centerX.equalToSuperview()
            make.top.equalTo(passwordField2.snp.bottom).offset(10)
            make.height.equalTo(Metric.fieldHeight)
        }

        regBtnView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nicknameField.snp.bottom).offset(MetricGlobal.margin * 1)
            make.width.equalTo(widthRegisterBtnWidth)
            make.height.equalTo(heightRegisterBtnHeight)
        }

        addUserAgreement(scrollView: scrollView, lastV: regBtnView)
    }

    func addUserAgreement(scrollView: UIScrollView, lastV: UIView) {
        let contentStr = "注册即代表同意《注册协议》" as NSString
        let nameStr = NSMutableAttributedString(string: contentStr as String)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        paragraphStyle.alignment = .center

        nameStr.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: contentStr.length))

        let range = contentStr.range(of: "《注册协议》", options: .regularExpression, range: NSRange(location: 0, length: contentStr.length))
        nameStr.addAttribute(NSAttributedStringKey.link, value: "click://", range: range)
        nameStr.addAttribute(NSAttributedStringKey.foregroundColor, value: kNaviBarBackGroundColor, range: range)

        let textView = UITextView()
        textView.attributedText = nameStr

        textView.isEditable = false
        textView.textColor = .black
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 12)
        scrollView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(lastV.snp.bottom).offset(MetricGlobal.margin)
            make.centerX.equalToSuperview()
            make.width.equalTo(lastV)
            make.height.equalTo(31)
        }
    }

    // MARK: 事件处理
    @objc func touchItem(btn: UIButton) {
    }
}

// MARK: - 代理方法
extension Regist: UITextViewDelegate, UITextFieldDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.scheme == "click" {
            let agreementEvent = self.events?[kAgreement]
            let result = EventUtil.handleEvents(event: agreementEvent)
            EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
            return false
        }
        return true
    }

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
