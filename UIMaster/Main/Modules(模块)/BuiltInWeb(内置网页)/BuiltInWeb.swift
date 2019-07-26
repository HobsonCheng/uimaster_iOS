import NVActivityIndicatorView
import UIKit
import WebKit

class BuiltInWebModel: BaseData {
    var styles: BuiltInWebStyles?
    var fields: BuiltInWebFields?
    var events: [String: EventsData]?
}

class BuiltInWebStyles: BaseStyleModel {
    var borderColor: String?
    var borderWidth: Int?
    var borderShow: Int?
    var opacity: Int?
    var textAlign: Int?
    var color: String?
    var fontSize: CGFloat?
}

class BuiltInWebFields: BaseStyleModel {
    var getFunction: String?
}

enum AgreementType: String {
    case getUserAgreement
    case getRegisterAgreement
    case getHtmlByModel
    case getAppAbout
}

class BuiltInWeb: WKWebView, PageModuleAble {
    // MARK: 模块相关的配置属性
    private var bgColor = "255,255,255,1"//背景 颜色
    private var bgImg = ""//背景 图片
    private var bgImgMode = 0//背景 平铺
    private var borderColor = "238,0,0,1"//边框 颜色
    private var borderShow = 1//边框 是否显示
    private var borderWidth = 0//边框 宽度
    private var color = "42,42,42,1"//页面文字 颜色
    private var fontSize: CGFloat = 14//页面文字 大小
    private var opacity = 1//背景 透明度
    private var textAlign = 0//页面文字 位置
    private var functionType = AgreementType.getAppAbout
    private var webDetailData: DetailData?

    var moduleParams: [String: Any]? {
        didSet {
            //获取数据
            reloadViewData()
        }
    }
    weak var moduleDelegate: ModuleRefreshDelegate?
    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let builtInWebModel = BuiltInWebModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.bgColor = builtInWebModel.styles?.bgColor ?? self.bgColor
                self.bgImg = builtInWebModel.styles?.bgImg ?? self.bgImg
                self.bgImgMode = builtInWebModel.styles?.bgImgMode ?? self.bgImgMode
                self.borderColor = builtInWebModel.styles?.borderColor ?? self.borderColor
                self.borderShow = builtInWebModel.styles?.borderShow ?? self.borderShow
                self.borderWidth = builtInWebModel.styles?.borderWidth ?? self.borderWidth
                self.color = builtInWebModel.styles?.color ?? self.color
                self.fontSize = builtInWebModel.styles?.fontSize ?? self.fontSize
                self.opacity = builtInWebModel.styles?.opacity ?? self.opacity
                self.textAlign = builtInWebModel.styles?.textAlign ?? self.textAlign
                self.functionType = AgreementType(rawValue: (builtInWebModel.fields?.getFunction ?? "")) ?? AgreementType.getAppAbout
            }
        }
    }

    //模块特有属性
    private var htmlData: BuiltInWebSetData?//保存M2请求回来的数据
    private var pageNum: Int = 1//如果涉及到数据分页，需要此变量
    var parentVC: AssembleVC?

    lazy var activityView = { () -> NVActivityIndicatorView in
        let activityView = NVActivityIndicatorView(frame: self.bounds, type: NVActivityIndicatorType.lineScale, color: UIColor.gray, padding: kScreenW - 170)
        activityView.height -= 250
        self.addSubview(activityView)
        return activityView
    }()

    // MARK: init方法
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        let config = WKWebViewConfiguration()
        config.dataDetectorTypes = .all
        super.init(frame: frame, configuration: config)
        activityView.startAnimating()
        NotificationCenter.default.rx.notification(Notification.Name(kPersonalInfoChangeNotification)).takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                self?.reloadViewData()
            })
            .disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 网络请求
extension BuiltInWeb {
    //页面刷新时会调用该方法
    func reloadViewData() {
        switch functionType {
        case .getAppAbout:
            self.getAppAbout()
        case .getRegisterAgreement:
            self.getRegisterAgreement()
        case .getUserAgreement:
            self.getUserAgreement()
        case .getHtmlByModel:
            self.getHtmlByModel()
        }
    }

    //关于我们
    private func getAppAbout() {
        NetworkUtil.request(
            target: .getAppAbout,
            success: { [weak self] json in
                let data = AboutUsModel.deserialize(from: json)?.data
                let model = BuiltInWebSetData()
                model.agreement = data
                self?.htmlData = model
                self?.renderUI()
            }
        ) { error in
            self.activityView.stopAnimating()
            dPrint(error)
        }
    }

    //注册协议
    private func getRegisterAgreement() {
        NetworkUtil.request(
            target: .getRegisterAgreement,
            success: { [weak self] json in
                self?.htmlData = BuiltInWebDataModel.deserialize(from: json)?.data
                self?.renderUI()
            }
        ) { error in
            self.activityView.stopAnimating()
            dPrint(error)
        }
    }

    //用户协议
    private func getUserAgreement() {
        NetworkUtil.request(
            target: .getUserAgreement,
            success: { [weak self] json in
                self?.htmlData = BuiltInWebDataModel.deserialize(from: json)?.data
                self?.renderUI()
            }
        ) { error in
            self.activityView.stopAnimating()
            dPrint(error)
        }
    }

    //用户协议
    private func getHtmlByModel() {
        NetworkUtil.request(
            target: .getHtmlByModel(group_id: UserUtil.getGroupId(), page: self.pageKey ?? "", code: self.moduleCode ?? ""),
            success: { [weak self] json in
                self?.webDetailData = DetailModel.deserialize(from: json)?.data
                guard let detail = self?.webDetailData else {
                    return
                }
                let data = BuiltInWebSetData()
                data.agreement = detail.content
                self?.htmlData = data
                self?.renderUI()
            }
        ) { error in
            self.activityView.stopAnimating()
            dPrint(error)
        }
    }
}

// MARK: - UI&事件处理
extension BuiltInWeb {
    //渲染UI
    private func renderUI() {
        self.backgroundColor = self.bgColor.toColor()
        self.navigationDelegate = self
        self.uiDelegate = self
        self.scrollView.isScrollEnabled = false
        // 从本地加载网页模板
        let templatePath = Bundle.main.path(forResource: "index.html", ofType: nil)!
        var template = (try? String(contentsOfFile: templatePath, encoding: String.Encoding.utf8))
        //替换模板内容
        template = template?.replacingOccurrences(of: "<div class=\"content\"></div>", with: self.htmlData?.agreement ?? "")
        //加载模板
        let baseURL = URL(fileURLWithPath: templatePath)
        self.loadHTMLString(template ?? "", baseURL: baseURL)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

// MARK: - 代理方法
/**
 1.协议的采纳放到该扩展上。
 2.代理方法统一放到这里，不同的代理用//MARK: 分开
 */
extension BuiltInWeb: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityView.stopAnimating()
        self.evaluateJavaScript("document.body.offsetHeight;") { [weak self] result, _ in
            if let height = result as? CGFloat {
                self?.height = height + 20
                self?.moduleDelegate?.moduleLayoutDidRefresh()
            }
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let urlStr = navigationAction.request.url?.absoluteString.stringByDecodingURLFormat()
        if urlStr?.hasPrefix("http") ?? true || urlStr?.hasPrefix("https") ?? true {
            let otherWebVC = OtherWebVC(name: "webview")
            otherWebVC.urlString = urlStr
            VCController.push(otherWebVC, with: VCAnimationClassic.defaultAnimation())
            decisionHandler(WKNavigationActionPolicy.cancel)
        } else {
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }
}
