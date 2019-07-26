import Alamofire
import Eureka
import KeychainAccess
import Kingfisher
import SwiftyJSON
import UIKit

// swiftlint:disable identifier_name
class InviteModel: BaseData {
    var data: InviteData?
}

class InviteData: BaseData {
    var pid: Int?
    var code_type: Int?
    var can_use_num: Int?
    var point_x: Int?
    var code_id: Int?
    var out_time: String?
    var code_from: Int?
    var uid: Int?
    var status: Int?
    var code: String?
    var add_time: String?
    var p_name: String?
    var url: String?
    var point_y: Int?
}

class VersionModel: BaseData {
    var data: VersionData?
}

class VersionData: BaseData {
    var data_update: Int?
    var build_update: Int?
    var last_version: String?
    var force_update: Int?
    var download: String?
    var url: String?
    var search: Int?
    var invitation: Int?
}

class AppSetModel: BaseData {
    var events: [String: EventsData]?
    var fields: AppSetFields?
    var status: Int?
    var styles: AppSetStyles?
}

class AppSetFields: BaseData {
    var feedback: Int?
    var messageSetting: Int?
    var privacySettings: Int?
    var userProtocol: Int?
    var aboutUs: Int?
    var accountSecurity: Int?
    var checkUpdate: Int?
}

class AppSetStyles: BaseStyleModel {
    var borderColor: String?
    var borderShow: Int?
    var borderWidth: Int?
    var opacity: Double?
}

// swiftlint:enable identifier_name
//  模块通用模板,保持整体完整性，
//  不需要的部分可以先注释掉，之后完成后，再统一删掉
//  可以参考AppSet模块，如果涉及到分页显示数据，请参考GroupListTopic模块

class AppSet: UIView, PageModuleAble, UIShareAble {
    // MARK: - 模块相关的配置属性
    private var aboutUs = 1//关于我们
    private var accountSecurity = 1//修改密码
    private var bgColor = "0,195,184,1"//背景 颜色
    private var bgImg = ""//背景 图片
    private var bgImgMode = 0//背景 平铺
    private var borderColor = "15,216,205,1"//边框 颜色
    private var borderShow = 1//边框 是否显示
    private var borderWidth = 0//边框 宽度
    private var checkUpdate = 1//检查更新
    private var feedback = 1//反馈意见
    private var messageSetting = 1//消息通知
    private var opacity = 0.62//背景 透明度
    private var privacySettings = 1//隐私设置
    private var radius: CGFloat = 0//圆角
    private var userProtocol = 1//用户协议
    private var events: [String: EventsData]?

    weak var moduleDelegate: ModuleRefreshDelegate?
    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let appSetModel = AppSetModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.aboutUs = appSetModel.fields?.aboutUs ?? self.aboutUs
                self.accountSecurity = appSetModel.fields?.accountSecurity ?? self.accountSecurity
                self.bgColor = appSetModel.styles?.bgColor ?? self.bgColor
                self.bgImg = appSetModel.styles?.bgImg ?? self.bgImg
                self.bgImgMode = appSetModel.styles?.bgImgMode ?? self.bgImgMode
                self.borderColor = appSetModel.styles?.borderColor ?? self.borderColor
                self.borderShow = appSetModel.styles?.borderShow ?? self.borderShow
                self.borderWidth = appSetModel.styles?.borderWidth ?? self.borderWidth
                self.checkUpdate = appSetModel.fields?.checkUpdate ?? self.checkUpdate
                self.feedback = appSetModel.fields?.feedback ?? self.feedback
                self.messageSetting = appSetModel.fields?.messageSetting ?? self.messageSetting
                self.opacity = appSetModel.styles?.opacity ?? self.opacity
                self.privacySettings = appSetModel.fields?.privacySettings ?? self.privacySettings
                self.userProtocol = appSetModel.fields?.userProtocol ?? self.userProtocol
                self.radius = appSetModel.styles?.radius ?? self.radius
                self.events = appSetModel.events
                //渲染UI
                renderUI()
                checkOtherRowEnable()
                getUserRemind()
            }
        }
    }

    // MARK: - 模块特有属性
    private var formVC = BaseFormVC()
    private var hiddenSearch = true

    // MARK: init方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.rx.notification(Notification.Name(kPersonalInfoChangeNotification))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                self?.formVC.form.removeAll()
                self?.renderUI()
            })
            .disposed(by: rx.disposeBag)
        NotificationCenter.default.rx.notification(Notification.Name(kLogoutNotification))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                self?.formVC.form.removeAll()
                self?.renderUI()
            })
            .disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 网络请求
extension AppSet {
    private func setUserRemind(remind: Int) {
        NetworkUtil.request(
            target: .setUserRemind(remind: remind),
            success: { _ in
                dPrint("修改成功")
            }
        ) { error in
            dPrint(error)
        }
    }

    private func getUserRemind() {
        guard UserUtil.isValid() else {
            return
        }
        NetworkUtil.request(
            target: .getUserRemind,
            success: { [weak self] json in
                let value = JSON(parseJSON: json ?? "").dictionary?["data"]?.intValue ?? 0
                DispatchQueue.main.async {
                    let row = self?.formVC.form.rowBy(tag: "msgNotify") as? SwitchRow
                    row?.value = value == 1
                    row?.updateCell()
                }
            }
        ) { error in
            dPrint(error)
        }
    }

    //    private func getProjectVersion() {
    //        let params = NSMutableDictionary()
    //        ApiUtil.share.getProjectVersion(params: params, fininsh: { [weak self](_, data, _) in
    //            HUDUtil.msg(msg: "已经是最新版本", type: .successful)
    //        })
    //    }

    /// 上架Appstore的app 检测更新
    private func checkAppstoreUpdate() {
        //        Alamofire.request("http://itunes.apple.com/lookup?id=1397894182").response { (res) in
        //            if res.error != nil{
        //                HUDUtil.msg(msg: "获取版本信息失败", type: .error)
        //                return
        //            }
        ////            1.获取新版本
        //            let json = JSON.init(parseJSON: res.response?.description ?? "")
        //            let newVersion = json["version"].string
        ////            2.获取当前版本
        //            let infoDic = Bundle.main.infoDictionary
        //            let appVersion = infoDic?["CFBundleShortVersionString"] as? String
        ////            3.比较版本
        //            let newInts = newVersion?.split(separator: ".") ?? []
        //            let localInts = appVersion?.split(separator: ".") ?? []
        ////            3.1计算最小下标 1.0.1   1.2
        //            let count = newInts.count > localInts.count ? localInts.count : newInts.count
        ////            3.2比较得到结果
        //            for i in 0..<count {
        //                if Int(newInts[i]) > Int(localInts[i]){
        //                    HUDUtil.msg(msg: "需要更新", type: .info)
        //                    return
        //                }
        //            }
        ////            4.特殊情况 1.2   1.2.1
        //            if newInts.count > localInts.count{
        //                HUDUtil.msg(msg: "需要更新", type: .info)
        //                return
        //            }
        ////            5.最新版本
        //            HUDUtil.msg(msg: "当前是最新版", type: .info)
        //        }
        if let safeUrl = URL(string: "itms-apps://itunes.apple.com/cn/app/id1397894182?mt=8") {
            UIApplication.shared.open(safeUrl, options: [:], completionHandler: nil)
        }
    }

    /// 检测是否显示邀请、切换项目等是否显示
    private func checkOtherRowEnable() {
        let infoDic = Bundle.main.infoDictionary
        let appVersion = infoDic?["CFBundleVersion"] as? String ?? ""
        NetworkUtil.request(
            target: .forceUpdateVersion(app_id: GlobalConfigTool.shared.globalData?.appId ?? 0, version: GlobalConfigTool.shared.global?.version ?? "", app_version: appVersion),
            success: { [weak self] json in
                let versionData = VersionModel.deserialize(from: json)?.data
                self?.checkOtherRow(versionData: versionData)
            }
        ) { error in
            dPrint(error)
        }
    }

    /// 企业版APP版本检测更新
    private func updateVersion() {
        // 获取App的版本号
        let infoDic = Bundle.main.infoDictionary
        let appVersion = infoDic?["CFBundleVersion"] as? String ?? ""
        NetworkUtil.request(
            target: .forceUpdateVersion(app_id: GlobalConfigTool.shared.globalData?.appId ?? 0, version: GlobalConfigTool.shared.global?.version ?? "", app_version: appVersion),
            success: { [weak self] json in
                let versionData = VersionModel.deserialize(from: json)?.data
                if versionData?.build_update == 1 {
                    let alert = UIAlertController(style: .alert, title: "您的App有新的版本需要更新", message: "")
                    alert.addAction(image: nil, title: "立即更新", color: nil, style: .default, isEnabled: true) { _ in
                        let url = URL(string: versionData?.download ?? "")
                        if let safeURL = url {
                            if UIApplication.shared.canOpenURL(safeURL) {
                                if #available(iOS 10.0, *) {
                                    UIApplication.shared.open(safeURL, options: [:], completionHandler: nil)
                                } else {
                                    UIApplication.shared.openURL(safeURL)
                                }
                            } else {
                                HUDUtil.msg(msg: "无效的下载地址", type: .error)
                            }
                        }
                    }
                    alert.addAction(image: nil, title: "查看更新", color: nil, style: .default, isEnabled: true) { _ in
                        let url = URL(string: versionData?.url ?? "")
                        if let safeURL = url {
                            if UIApplication.shared.canOpenURL(safeURL) {
                                if #available(iOS 10.0, *) {
                                    UIApplication.shared.open(safeURL, options: [:], completionHandler: nil)
                                } else {
                                    UIApplication.shared.openURL(safeURL)
                                }
                            } else {
                                HUDUtil.msg(msg: "无效的下载地址", type: .error)
                            }
                        }
                    }
                    alert.addAction(title: "下次再说", style: .cancel, handler: nil)
                    alert.show()
                } else {
                    self?.dataUpdate()
                }
            }
        ) { error in
            dPrint(error)
        }
    }

    //数据更新
    fileprivate func dataUpdate() {
        let infoDic = Bundle.main.infoDictionary
        let appVersion = infoDic?["CFBundleVersion"] as? String ?? ""
        NetworkUtil.request(
            target: .forceUpdateVersion(app_id: GlobalConfigTool.shared.globalData?.appId ?? 0, version: GlobalConfigTool.shared.globalData?.global?.version ?? "", app_version: appVersion),
            success: { json in
                let versionData = VersionModel.deserialize(from: json)?.data
                if versionData?.data_update == 1 {
                    HUDUtil.msg(msg: "您的App有新的数据需要更新", type: .info)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        _ = VCController.pop(toHomeVCThenPush: RefreshDataVC(), with: VCAnimationClassic.defaultAnimation())
                    })
                } else {
                    HUDUtil.msg(msg: "当前是最新版本", type: .info)
                }
            }
        ) { error in
            dPrint(error)
        }
    }
}

// MARK: - UI&事件处理
extension AppSet {
    //渲染UI
    private func renderUI() {
        self.layer.cornerRadius = CGFloat(self.radius)
        self.layer.masksToBounds = true
        //FIXME: 样式绑定
        self.backgroundColor = UIColor(hexString: "#eeeeee")
        formVC.form
            +++ Section {
            $0.header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
            $0.header?.height = {
                CGFloat.leastNormalMagnitude
            }
            $0.footer = HeaderFooterView<UIView>(HeaderFooterProvider.class)
            $0.footer?.height = {
                CGFloat.leastNormalMagnitude
            }
            }
            <<< LabelRow("changePassword") { [weak self] row in
            row.title = "修改密码"
            row.cell.accessoryType = .disclosureIndicator
            row.cell.backgroundColor = self?.bgColor.toColor()
            row.onCellSelection({ _, _ in
                let resetPasswordEvent = self?.events?[kResetPassword]
                let result = EventUtil.handleEvents(event: resetPasswordEvent)
                EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
            })
            row.hidden = Condition.function(["privacySetting"], { _ -> Bool in
                UserUtil.share.appUserInfo == nil
            })
            row.evaluateHidden()
            }
            +++ Section {
            $0.header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
            $0.header?.height = {
                20
            }
            $0.footer = HeaderFooterView<UIView>(HeaderFooterProvider.class)
            $0.footer?.height = {
                CGFloat.leastNormalMagnitude
            }
            $0.hidden = Condition.function([""], { [weak self] _ -> Bool in
                self?.privacySettings == 0 || UserUtil.share.appUserInfo == nil
            })
            }
            <<< LabelRow("privacySetting") { [weak self] row in
            row.title = "隐私设置"
            row.cell.backgroundColor = self?.bgColor.toColor()
            row.cell.accessoryType = .disclosureIndicator
            let separator = UIView()
            separator.backgroundColor = UIColor(hexString: "#eeeeee")
            row.cell.addSubview(separator)
            separator.snp.makeConstraints({ make in
                make.bottom.equalToSuperview()
                make.height.equalTo(1)
                make.left.equalTo(15)
                make.width.equalToSuperview().offset(-25)
            })
            row.onCellSelection({ _, _ in
                let privacySettingsEvent = self?.events?[kPrivacySettings]
                let result = EventUtil.handleEvents(event: privacySettingsEvent)
                EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
            })
            row.hidden = Condition.function([""], { [weak self] _ -> Bool in
                self?.privacySettings == 0 || UserUtil.share.appUserInfo == nil
            })
            }
            <<< SwitchRow("msgNotify") { [weak self] row in
            row.title = "消息通知"
            row.cell.switchControl.tintColor = .gray
            row.hidden = Condition.function([""], { _ -> Bool in
                self?.messageSetting == 0 || UserUtil.share.appUserInfo == nil
            })
            row.onChange({ [weak self] row in
                self?.setUserRemind(remind: (row.value ?? false) ? 1 : 0)
            })
            }
            +++ Section {
            $0.header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
            $0.header?.height = {
                20
            }
            $0.footer = HeaderFooterView<UIView>(HeaderFooterProvider.class)
            $0.footer?.height = {
                CGFloat.leastNormalMagnitude
            }
            }
            <<< LabelRow("checkUpdate") { [weak self] row in
            row.title = "检测更新"
            //                row.value = "有新版本可用"
            row.cell.backgroundColor = self?.bgColor.toColor()
            row.cell.accessoryType = .disclosureIndicator
            let infoDic = Bundle.main.infoDictionary
            row.value = "当前版本 " + ((infoDic?["CFBundleShortVersionString"] as? String) ?? "")
            let separator = UIView()
            separator.backgroundColor = UIColor(hexString: "#eeeeee")
            row.cell.addSubview(separator)
            separator.snp.makeConstraints({ make in
                make.bottom.equalToSuperview()
                make.height.equalTo(1)
                make.left.equalTo(15)
                make.width.equalToSuperview().offset(-25)
            })
            row.onCellSelection({ [weak self] _, _ in
                if !AppUtil.isAlone {
                    self?.checkAppstoreUpdate()
                } else {
                    self?.updateVersion()
                }
            })
            row.hidden = Condition.function([""], { [weak self]_ -> Bool in
                self?.checkUpdate == 0
            })
            }

            <<< LabelRow("feedback") { [weak self] row in
            row.title = "反馈意见"
            row.cell.backgroundColor = self?.bgColor.toColor()
            row.cell.accessoryType = .disclosureIndicator
            row.onCellSelection({ _, _ in
                let feedbackEvent = self?.events?[kFeedback]
                let result = EventUtil.handleEvents(event: feedbackEvent)
                EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
            })
            row.hidden = Condition.function([""], { [weak self] _ -> Bool in
                self?.feedback == 0
            })
            }
            +++ Section {
            $0.header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
            $0.header?.height = {
                20
            }
            $0.footer = HeaderFooterView<UIView>(HeaderFooterProvider.class)
            $0.footer?.height = {
                CGFloat.leastNormalMagnitude
            }
            }
            <<< LabelRow("userDeal") { [weak self] row in
            row.title = "用户协议"
            row.cell.backgroundColor = self?.bgColor.toColor()
            row.cell.accessoryType = .disclosureIndicator
            let separator = UIView()
            separator.backgroundColor = UIColor(hexString: "#eeeeee")
            row.cell.addSubview(separator)
            separator.snp.makeConstraints({ make in
                make.bottom.equalToSuperview()
                make.height.equalTo(1)
                make.left.equalTo(15)
                make.width.equalToSuperview().offset(-25)
            })
            row.onCellSelection({ [weak self] _, _ in
                let builtInWebEvent = self?.events?[kUserProtocolInWeb]
                let result = EventUtil.handleEvents(event: builtInWebEvent)
                EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
            })
            row.hidden = Condition.function([""], { [weak self] _ -> Bool in
                self?.userProtocol == 0
            })
            }
            <<< LabelRow("aboutUs") { [weak self] row in
            row.title = "关于我们"
            row.cell.backgroundColor = self?.bgColor.toColor()
            row.cell.accessoryType = .disclosureIndicator
            row.onCellSelection({ [weak self] _, _ in
                let builtInWebEvent = self?.events?[kAboutUsInWeb]
                let result = EventUtil.handleEvents(event: builtInWebEvent)
                EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
            })
            row.hidden = Condition.function([""], { _ -> Bool in
                self?.aboutUs == 0
            })
            }
            +++ Section {
            $0.header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
            $0.header?.height = {
                20.0
            }
            $0.footer = HeaderFooterView<UIView>(HeaderFooterProvider.class)
            $0.footer?.height = {
                CGFloat.leastNormalMagnitude
            }
            }
            <<< LabelRow("addToScreen") { [weak self] row in
            row.title = "添加到桌面"
            row.cell.backgroundColor = self?.bgColor.toColor()
            row.cell.accessoryType = .disclosureIndicator
            let separator = UIView()
            separator.backgroundColor = UIColor(hexString: "#eeeeee")
            row.cell.addSubview(separator)
            separator.snp.makeConstraints({ make in
                make.bottom.equalToSuperview()
                make.height.equalTo(1)
                make.left.equalTo(15)
                make.width.equalToSuperview().offset(-25)
            })
            row.onCellSelection({ _, _ in
                let appID = GlobalConfigTool.shared.appId ?? 0
                let pid = GlobalConfigTool.shared.pid
                let icon = GlobalConfigTool.shared.icon
                let name = GlobalConfigTool.shared.name
                AppUtil.addToScreen(appID: appID, pid: pid, name: name, icon: icon)
            })
            row.hidden = Condition.function([""], { _ -> Bool in
                AppUtil.isAlone || !UserUtil.isValid() || UserUtil.share.appUserInfo?.uid == 60
            })
            row.evaluateHidden()
            }
            <<< LabelRow("share") { [weak self] row in
            row.title = "邀请"
            row.cell.backgroundColor = self?.bgColor.toColor()
            row.cell.accessoryType = .disclosureIndicator
            let separator = UIView()
            separator.backgroundColor = UIColor(hexString: "#eeeeee")
            row.cell.addSubview(separator)
            separator.snp.makeConstraints({ make in
                make.bottom.equalToSuperview()
                make.height.equalTo(1)
                make.left.equalTo(15)
                make.width.equalToSuperview().offset(-25)
            })
            row.onCellSelection({ _, _ in
                let alertVC = UIAlertController(title: "", message: "请选择邀请的具体类型", preferredStyle: UIAlertControllerStyle.actionSheet)
                alertVC.addAction(UIAlertAction(title: "邀请他人注册账号", style: .default, handler: { [weak self] _ in
                    NetworkUtil.request(
                        target: .applyForCode(out_time: 10, can_use_num: 10, code_type: 0),
                        success: { json in
                            let model = InviteModel.deserialize(from: json)?.data
                            let logo = ImageCache.default.retrieveImageInDiskCache(forKey: kLogoCacheKey) ?? UIImage(named: "AppIcon60x60")
                            let image = QRCodeUtil.shared.createCenterImageQRCode(byImage: logo, withStr: model?.url ?? "")
                            guard let safeImage = image else {
                                HUDUtil.msg(msg: "生成二维码失败", type: .error)
                                return
                            }
                            self?.shareToOthers(text: "\(UserUtil.share.appUserInfo?.zh_name ?? "")邀请您使用APP", imageName: nil, orImage: safeImage, linkStr: model?.url)
                        }
                    ) { error in
                        dPrint(error)
                    }
                }))
                alertVC.addAction(UIAlertAction(title: "邀请他人创建新APP", style: .default, handler: { [weak self] _ in
                    NetworkUtil.request(
                        target: .applyForCode(out_time: 10, can_use_num: 10, code_type: 1),
                        success: { json in
                            let model = InviteModel.deserialize(from: json)?.data
                            let image = QRCodeUtil.shared.createCenterImageQRCode(byImage: UIImage(named: "AppIcon60x60"), withStr: model?.url ?? "")
                            guard let safeImage = image else {
                                HUDUtil.msg(msg: "生成二维码失败", type: .error)
                                return
                            }
                            self?.shareToOthers(text: "\(UserUtil.share.appUserInfo?.zh_name ?? "")邀请您创建APP", imageName: nil, orImage: safeImage, linkStr: model?.url)
                        }
                    ) { error in
                        dPrint(error)
                    }
                }))
                alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                alertVC.show()
            })
            row.hidden = Condition.function([""], { _ -> Bool in
                AppUtil.isAlone || !UserUtil.isValid() || UserUtil.share.appUserInfo?.uid == 60
            })
            row.evaluateHidden()
            }
            <<< LabelRow("switchProject") { [weak self] row in
            row.title = "切换项目"
            row.cell.backgroundColor = self?.bgColor.toColor()
            row.cell.accessoryType = .disclosureIndicator
            row.onCellSelection({ [weak self] _, _ in
                let searchProjectEvent = self?.events?[kSearchProject]
                let result = EventUtil.handleEvents(event: searchProjectEvent)
                EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
            })
            row.hidden = Condition.function([""], { _ -> Bool in
                false
//                    return AppUtil.isAlone || !UserUtil.isValid() || UserUtil.share.appUserInfo?.uid == 60
            })
            row.evaluateHidden()
            }
            +++ ButtonRow { [weak self] row in
            row.title = "退出当前账号"
            row.cell.backgroundColor = self?.bgColor.toColor()
            row.onCellSelection({ _, _ in
                let alertVC = UIAlertController(title: "是否退出", message: nil, preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "是", style: .destructive, handler: { _ in
                    let keychain = Keychain(service: "com.one2much.uuid")
                    let uuid = keychain["deviceuuid"] ?? ""
                    dPrint("用户离线UUID:\(uuid)")
                    //设置用户离线，然后退出
                    NetworkUtil.request(
                        target: .setUserOffline(device_id: uuid),
                        success: { _ in
                            NetworkUtil.request(
                                target: .userLogout,
                                success: { _ in
                                    HUDUtil.msg(msg: "退出成功", type: .successful)
                                    UserUtil.share.removerUser()
                                    VCController.pop(with: VCAnimationClassic.defaultAnimation())
                                }
                            ) { error in
                                HUDUtil.msg(msg: "退出失败", type: .error)
                                dPrint(error)
                            }
                        }
                    ) { error in
                        dPrint(error)
                    }
                }))
                alertVC.addAction(UIAlertAction(title: "否", style: .cancel, handler: nil))
                kWindowRootVC?.present(alertVC, animated: true, completion: nil)
            })
            row.hidden = Condition.function(["aboutUs"], { _ in
                UserUtil.share.appUserInfo == nil
            })
            row.evaluateHidden()
            }
        self.addSubview(formVC.view)
    }

    /// 邀请、切换项目等按钮是否可用
    func checkOtherRow(versionData: VersionData?) {
        //        switchProject
        //        self.hiddenSearch = false
//        self.formVC.form.rowBy(tag: "switchProject")?.hidden = versionData?.search == 0 ? true : false
//        self.formVC.form.rowBy(tag: "switchProject")?.evaluateHidden()
//        self.formVC.form.rowBy(tag: "share")?.hidden = versionData?.invitation == 0 ? true : false
//        self.formVC.form.rowBy(tag: "share")?.evaluateHidden()
        //        self.formVC.form.rowBy(tag: "switchProject")?.hidden = Condition.function(["aboutUs"], { form in
        //            return false
        //        })
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        formVC.view.frame = self.bounds
        formVC.tableView.separatorColor = .clear
        formVC.tableView.isScrollEnabled = true
    }
}
