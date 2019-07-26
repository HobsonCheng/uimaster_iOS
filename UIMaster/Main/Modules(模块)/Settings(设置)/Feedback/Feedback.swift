import Eureka
import RxSwift
import UIKit

class FeedbackModel: BaseData {
    var fields: FeedbackFields?
    var status: Int?
    var styles: FeedbackStyles?
    var events: [String: EventsData]?
}
class FeedbackFields: BaseData {
    var contactInformation: Int?
    var textContact: String?
    var textOpinion: String?
    var textRemarks: String?
}
class FeedbackStyles: BaseStyleModel {
    var borderColor: String?
    var borderWidth: Int?
    var borderShow: Int?
    var feedbackInputStyle: Int?
    var opacity: Double?
}

class Feedback: UIView, PageModuleAble {
    // MARK: - 模块相关的配置属性
    private var bgColor = "42,111,83,1"//背景 颜色
    private var bgImg = ""//背景图片
    private var bgImgMode = 0//背景平铺
    private var borderColor = "255,0,0,1"//边框 颜色
    private var borderShow = 1//边框 是否可见
    private var borderWidth = 0//边框 宽度
    private var contactInformation = 1//联系方式
    private var feedbackInputStyle = 0//意见反馈填写样式
    private var opacity = 0.83//背景 透明度
    private var radius = 11//圆角
    private var textContact = ""//内容 联系方式
    private var textOpinion = ""//内容 内容控制
    private var textRemarks = ""//内容 备注信息

    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let feedbackModel = FeedbackModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.bgColor = feedbackModel.styles?.bgColor ?? self.bgColor
                self.bgImg = feedbackModel.styles?.bgImg ?? self.bgImg
                self.bgImgMode = feedbackModel.styles?.bgImgMode ?? self.bgImgMode
                self.borderColor = feedbackModel.styles?.borderColor ?? self.borderColor
                self.borderShow = feedbackModel.styles?.borderShow ?? self.borderShow
                self.borderWidth = feedbackModel.styles?.borderWidth ?? self.borderWidth
                self.contactInformation = feedbackModel.fields?.contactInformation ?? self.contactInformation
                self.feedbackInputStyle = feedbackModel.styles?.feedbackInputStyle ?? self.feedbackInputStyle
                self.opacity = feedbackModel.styles?.opacity ?? self.opacity
                self.textContact = feedbackModel.fields?.textContact ?? self.textContact
                self.textOpinion = feedbackModel.fields?.textOpinion ?? self.textOpinion
                self.textRemarks = feedbackModel.fields?.textRemarks ?? self.textRemarks

                //渲染UI
                renderUI()
            }
        }
    }

    // MARK: - 模块特有属性
    private var pageNum: Int = 1//如果涉及到数据分页，需要此变量
    private var formVC = BaseFormVC(style: .plain)
    weak var moduleDelegate: ModuleRefreshDelegate?
    private var disposeBag = DisposeBag()
    // MARK: init方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.rx
            .notification(Notification.Name(kPostNotification))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] ntf in
                if let moduleId = ntf.object as? String {
                    if self?.moduleCode == moduleId {
                        self?.sendOpinion()
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    //    init(frame: CGRect){
    //        super.init(frame: frame,style: .plain)
    //    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UI&事件处理
extension Feedback {
    //渲染UI
    private func renderUI() {
        formVC.form
            +++ Section { [weak self] in
                $0.header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                $0.header?.height = { 20 }
                var footer = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                footer.onSetupView = { view, section in
                    view.rx
                        .tapGesture()
                        .subscribe(
                            onNext: { [weak self] _ in
                                self?.endEditing(true)
                            }
                        )
                        .disposed(by: self?.rx.disposeBag ?? DisposeBag())
                }
                $0.footer = footer
                $0.footer?.height = { 40 }
            }
            <<< TextAreaRow("message") { row in
                row.placeholder = "请留下您宝贵的意见"
                row.textAreaHeight = .fixed(cellHeight: 150)
                row.cell.textView.font = UIFont.systemFont(ofSize: 16)
                row.cell.textView.textColor = UIColor(red: 153, green: 153, blue: 153)
            }
            +++ Section {
                $0.header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                $0.header?.height = { CGFloat.leastNormalMagnitude }
                $0.footer = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                $0.footer?.height = { CGFloat.leastNormalMagnitude }
            }
            <<< LabelRow {
                $0.cell.height = { 40 }
                $0.title = "您的联系方式有助于我们沟通和解决问题，仅工作人员可见"
                $0.cellUpdate({ cell, _ in
                    cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
                    cell.textLabel?.numberOfLines = 2
                })
            }
            <<< TextAreaRow("contact") {
                $0.textAreaHeight = .fixed(cellHeight: 35)
                $0.placeholder = "请填写QQ、邮箱或手机等联系方式"
            }
            <<< PickImageRow("images") { row in
                row.cell.height = { 220 }
                row.cell.picker.config.maxImageCount = 8
            }
        self.addSubview(formVC.view)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        formVC.view.frame = self.bounds
        formVC.tableView.backgroundColor = .white
        //        formVC.tableView.isScrollEnabled = false
        //        formVC.tableView.bounces = false
    }
}

// MARK: - 网络请求
extension Feedback {
    //发送意见
    private func sendOpinion() {
        let content = self.formVC.form.rowBy(tag: "message")?.baseValue as? String
        let imageRow = self.formVC.form.rowBy(tag: "images") as? PickImageRow
        let title = self.formVC.form.rowBy(tag: "contact")?.baseValue as? String ?? ""
        guard let safeContent = content else {
            HUDUtil.msg(msg: "请填写反馈内容", type: .info)
            return
        }
        imageRow?.cell.uplaodImages {
            let usrString = imageRow?.value?.joined(separator: ",") ?? ""
            NetworkUtil.request(
                target: .addOpinion(content: safeContent, title: title, attachment_value: usrString),
                success: {  _ in
                    HUDUtil.msg(msg: "发送成功", type: .successful)
                    VCController.pop(with: VCAnimationClassic.defaultAnimation())
                }) { error in
                dPrint(error)
            }
        }
    }
}
