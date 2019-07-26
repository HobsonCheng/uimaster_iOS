//
//  Post.swift
//  UIMaster
//
//  Created by hobson on 2018/7/6.
//  Copyright © 2018年 one2much. All rights reserved.
//
import Eureka
import RxSwift
import UIKit

class PostModel: BaseData {
    var styles: PostStyles?
    var events: [String: EventsData]?
    var fields: PostFields?
}

class PostStyles: BaseStyleModel {
    var optionsButton: Int?
    var articleStyle: Int?
    var opacity: Int?
    var borderColor: String?
    var borderShow: Int?
    var lineHeight: Int?
    var title: String?
    var borderWidth: Int?
}

class PostFields: BaseData {
    // swiftlint:disable identifier_name
    var Button: Int?
    // swiftlint:enable identifier_name
    var articleStyle: Int?
    var faceButton: Int?
    var imgButton: Int?
    var optionsButton: Int?
    var optionsMenu: Int?
    var speechButton: Int?
    var textContent: String?
    var textTitle: String?
    var title: Int?
}

class Post: UIView, PageModuleAble {
    // MARK: - 模块相关的配置属性
    private var button = 1//
    private var articleStyle = 1//
    private var bgColor = "255,255,255,1"//
    private var bgImg = ""//
    private var bgImgMode = 0//
    private var borderColor = "232,232,232,1"//
    private var borderShow = 1//
    private var borderWidth = 0//
    private var faceButton = 1//
    private var imgButton = 1//
    private var lineHeight = 0//
    private var marginBottom = 0//
    private var marginLeft = 0//
    private var marginRight = 0//
    private var marginTop = 0//
    private var opacity = 1//
    private var optionsButton = 0//
    private var optionsMenu = 1//
    private var radius: CGFloat = 0//
    private var speechButton = 1//
    private var textContent = "33333"//
    private var textTitle = "266"//
    private var title = "226"//
    //    private var title = 1//
    weak var moduleDelegate: ModuleRefreshDelegate?
    private let disposeBag = DisposeBag()
    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let postModel = PostModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                //self.button = postModel.fields?.button ?? self.button
                self.articleStyle = postModel.styles?.articleStyle ?? self.articleStyle
                self.articleStyle = postModel.fields?.articleStyle ?? self.articleStyle
                self.bgColor = postModel.styles?.bgColor ?? self.bgColor
                self.bgImg = postModel.styles?.bgImg ?? self.bgImg
                self.bgImgMode = postModel.styles?.bgImgMode ?? self.bgImgMode
                self.borderColor = postModel.styles?.borderColor ?? self.borderColor
                self.borderShow = postModel.styles?.borderShow ?? self.borderShow
                self.borderWidth = postModel.styles?.borderWidth ?? self.borderWidth
                self.faceButton = postModel.fields?.faceButton ?? self.faceButton
                self.imgButton = postModel.fields?.imgButton ?? self.imgButton
                self.lineHeight = postModel.styles?.lineHeight ?? self.lineHeight
                self.opacity = postModel.styles?.opacity ?? self.opacity
                self.optionsButton = postModel.styles?.optionsButton ?? self.optionsButton
                self.optionsButton = postModel.fields?.optionsButton ?? self.optionsButton
                self.optionsMenu = postModel.fields?.optionsMenu ?? self.optionsMenu
                self.speechButton = postModel.fields?.speechButton ?? self.speechButton
                self.textContent = postModel.fields?.textContent ?? self.textContent
                self.textTitle = postModel.fields?.textTitle ?? self.textTitle
                self.title = postModel.styles?.title ?? self.title
                self.radius = postModel.styles?.radius ?? self.radius
                //渲染UI
                renderUI()
            }
        }
    }
    var moduleParams: Dictionary<String, Any>? {
        didSet {
            self.groupData = moduleParams?[GroupData.getClassName] as? GroupData
        }
    }

    deinit {
        dPrint("post deinit")
    }
    // MARK: - 模块特有属性
    private var pageNum: Int = 1//如果涉及到数据分页，需要此变量
    private var formVC = BaseFormVC(style: .plain)
    private var groupData: GroupData?

    // MARK: init方法
    override init(frame: CGRect) {
        super.init(frame: frame)

        NotificationCenter.default.rx.notification(Notification.Name(kPostNotification)).takeUntil(self.rx.deallocated).subscribe(onNext: {
            [weak self] ntf in
            if let moduleId = ntf.object as? String {
                if self?.moduleCode == moduleId {
                    self?.postTopic()
                }
            }
        }).disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 网络请求
extension Post {
    //发布帖子
    private func postTopic() {
        let form = self.formVC.form
        let errors = form.validate()
        for error in errors {
            HUDUtil.msg(msg: error.msg, type: .warning)
            return
        }
        let title = form.rowBy(tag: "title")?.baseValue as? String ?? ""
        let content = form.rowBy(tag: "content")?.baseValue as? String ?? ""
        let imageRow = form.rowBy(tag: "images") as? PickImageRow
        if !UserUtil.isValid() {
            PageRouter.shared.router(to: .login)
            return
        }
        imageRow?.cell.uplaodImages { [weak self] in
            let images = imageRow?.baseValue as? [String]
            var attechmentValue = ""
            for imageUrl in images ?? [] {
                if attechmentValue == ""{
                    attechmentValue = imageUrl
                } else {
                    attechmentValue += ",\(imageUrl)"
                }
            }
            NetworkUtil.request(target: .addInvitation(title: title, summarize: title, content: content, attachment_value: attechmentValue, group_pid: self?.groupData?.pid ?? 0, group_id: self?.groupData?.id ?? 0, can_reply: "1", can_replay: "2", can_store: "1", can_out: "1", can_see_reply: "2", use_signature: "1", attechment: "1", pay_type: "1"), success: { [weak self] _ in
                let postListRefreshNotification = Notification(name: Notification.Name(rawValue: kPostListRefreshNotification), object: self?.groupData, userInfo: nil)
                NotificationCenter.default.post(postListRefreshNotification)
                VCController.pop(with: VCAnimationBottom.defaultAnimation())
            }) { error in
                HUDUtil.stopLoadingHUD(ok: false, callback: nil, hint: "失败")
                dPrint(error)
            }
        }
    }
}

// MARK: - UI&事件处理
extension Post {
    //渲染UI
    private func renderUI() {
        self.backgroundColor = self.bgColor.toColor()
        self.layer.cornerRadius = self.radius
        self.layer.masksToBounds = true
        //背景图
        if self.bgImg != ""{
            let bgImageView = UIImageView(frame: self.bounds)
            bgImageView.kf.setImage(with: URL(string: self.bgImg))
            self.addSubview(bgImageView)
        }
        self.formVC.form
            +++ Section {
                $0.header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                $0.header?.height = { 20 }
                $0.footer = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                $0.footer?.height = { CGFloat.leastNormalMagnitude }
            }
        <<< TextAreaRow("title") { row in
                row.placeholder = "加个标题呦~"
                row.cell.backgroundColor = .clear
                row.cell.textView.backgroundColor = .clear
                row.textAreaHeight = .fixed(cellHeight: 50)
                row.validationOptions = .validatesOnChange
                row.cell.contentView.bottomLine(style: .leftGap(margin: 10), color: .lightGray)
                let rule = RuleClosure<String>(closure: { rowValue -> ValidationError? in
                    if rowValue == nil || rowValue == ""{
                        return  ValidationError(msg: "请添加标题")
                    }
                    return nil
                })
                row.add(rule: rule)
                let rule2 = RuleClosure<String>(closure: { rowValue -> ValidationError? in
                    if rowValue?.count > 60 {
                        row.value = row.value?.subStr(from: 0, length: 60)
                        row.updateCell()
                        HUDUtil.msg(msg: "标题最多60字哦~", type: .info)
                    }
                    return nil
                })
                row.add(rule: rule2)
        }
                +++ Section { [weak self] in
                    var header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                    header.onSetupView = { view, section in
                        view.rx.tapGesture().subscribe(onNext: { [weak self] _ in
                            self?.endEditing(true)
                        }).disposed(by: self?.rx.disposeBag ?? DisposeBag())
                    }
                    $0.header = header
                    $0.header?.height = { 40 }
                    $0.footer = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                    $0.footer?.height = { 1 }
                }
            <<< TextAreaRow("content") { row in
                row.placeholder = "来吧，尽情发挥吧~"
                row.textAreaHeight = .fixed(cellHeight: 150)
                row.cell.backgroundColor = .clear
                row.cell.textView.backgroundColor = .clear
                let rule = RuleClosure<String>(closure: { rowValue -> ValidationError? in
                    if rowValue == nil || rowValue == ""{
                        return  ValidationError(msg: "请填写内容")
                    }
                    return nil
                })
                row.add(rule: rule)
//                let rule2 = RuleClosure<String>.init(closure: { (rowValue) -> ValidationError? in
//                    if rowValue?.count > 50{
//                        HUDUtil.msg(msg: "最多只能评论60字哦~", type: .info)
//                    }
//                    return nil
//                })
//                row.add(rule: rule2)
            }
            <<< PickImageRow("images") { row in
                row.cell.backgroundColor = .clear
                row.cell.height = { 260 }
            }
        self.moduleDelegate?.assemble(with: formVC)
        self.addSubview(formVC.view)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        formVC.view.frame = self.bounds
        formVC.tableView.bounces = false
    }

    // MARK: 事件处理
    @objc func touchItem(btn: UIButton) {
    }
}
