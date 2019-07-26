//  模块通用模板,保持整体完整性，
//  不需要的部分可以先注释掉，之后完成后，再统一删掉
//  可以参考GroupSet模块，如果涉及到分页显示数据，请参考GroupListTopic模块

import Eureka
import Kingfisher
import RxSwift
import UIKit

class GroupSetModel: BaseData {
    var events: [String: EventsData]?
    var fields: GroupSetFields?
    var status: Int?
    var styles: GroupSetStyles?
}
class GroupSetFields: BaseData {
    var textContent: String?
    var textTitle: String?
}
class GroupSetStyles: BaseStyleModel {
    var bgImgModeList: Int?
    var fontSizeSys: CGFloat?
    var opacityList: Int?
    var splitterColor: String?
    var borderColor: String?
    var icon: String?
    var opacity: Int?
    var bgColorList: String?
    var colorSys: String?
    var splitterWidth: Int?
    var textAlignSys: Int?
    var bgImgList: String?
    var fontSizeContent: CGFloat?
    var splitterShow: Int?
    var textAlignContent: Int?
    var title: String?
    var borderShow: Int?
    var borderWidth: Int?
    var fontSizeGroup: CGFloat?
    var colorContent: String?
    var textAlignGroup: Int?
    var colorGroup: String?
    var splitterType: String?
}

class GroupSet: UIView, PageModuleAble, ImageUploadAble {
    weak var moduleDelegate: ModuleRefreshDelegate?
    // MARK: - 模块相关的配置属性
    private var bgColor = "255,255,255,1"//背景 颜色
    private var bgColorList = "255,255,255,1"//列表背景 颜色
    private var bgImg = ""//背景 图片
    private var bgImgList = ""//列表背景 图片
    private var bgImgMode = 0//背景 平铺
    private var bgImgModeList = 0//列表背景 平铺
    private var borderColor = "84,84,84,1"//边框 颜色
    private var borderShow = 1//边框 是否显示
    private var borderWidth = 0//边框 宽度
    private var colorContent = "84,84,84,1"//内容文字 颜色
    private var colorGroup = "218,59,59,1"//分组文字 颜色
    private var colorSys = "20,13,199,1"//设置项文字 颜色
    private var fontSizeContent: CGFloat = 16//内容文字 大小
    private var fontSizeGroup: CGFloat = 17//分组文字 大小
    private var fontSizeSys: CGFloat = 16//设置项文字 大小
    private var icon = ""//图标 图片
    private var opacity = 1//背景 透明度
    private var opacityList = 1//列表背景 透明度
    private var splitterColor = "236,0,0,1"//分割线 颜色
    private var splitterShow = 1//分割线 是否显示
    private var splitterType = "solid"//分割线 样式
    private var splitterWidth = 2//分割线 宽度
    private var textAlignContent = 0//内容文字 位置
    private var textAlignGroup = 1//分组文字 位置
    private var textAlignSys = 0//设置项文字 位置
    private var textContent = ""//内容区 正文提示文字内容控制
    private var textTitle = ""//内容区 标题提示文字内容控制
    private var title = ""//图标 提示
    private var radius: CGFloat = 0 //圆角

    var moduleParams: [String: Any]? {
        didSet {
            self.groupData = moduleParams?[GroupData.getClassName] as? GroupData
            //获取数据
            reloadViewData()
        }
    }
    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let groupSetModel = GroupSetModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.bgColor = groupSetModel.styles?.bgColor ?? self.bgColor
                self.bgColorList = groupSetModel.styles?.bgColorList ?? self.bgColorList
                self.bgImg = groupSetModel.styles?.bgImg ?? self.bgImg
                self.bgImgList = groupSetModel.styles?.bgImgList ?? self.bgImgList
                self.bgImgMode = groupSetModel.styles?.bgImgMode ?? self.bgImgMode
                self.bgImgModeList = groupSetModel.styles?.bgImgModeList ?? self.bgImgModeList
                self.borderColor = groupSetModel.styles?.borderColor ?? self.borderColor
                self.borderShow = groupSetModel.styles?.borderShow ?? self.borderShow
                self.borderWidth = groupSetModel.styles?.borderWidth ?? self.borderWidth
                self.colorContent = groupSetModel.styles?.colorContent ?? self.colorContent
                self.colorGroup = groupSetModel.styles?.colorGroup ?? self.colorGroup
                self.colorSys = groupSetModel.styles?.colorSys ?? self.colorSys
                self.fontSizeContent = groupSetModel.styles?.fontSizeContent ?? self.fontSizeContent
                self.fontSizeGroup = groupSetModel.styles?.fontSizeGroup ?? self.fontSizeGroup
                self.fontSizeSys = groupSetModel.styles?.fontSizeSys ?? self.fontSizeSys
                self.icon = groupSetModel.styles?.icon ?? self.icon
                self.opacity = groupSetModel.styles?.opacity ?? self.opacity
                self.opacityList = groupSetModel.styles?.opacityList ?? self.opacityList
                self.splitterColor = groupSetModel.styles?.splitterColor ?? self.splitterColor
                self.splitterShow = groupSetModel.styles?.splitterShow ?? self.splitterShow
                self.splitterType = groupSetModel.styles?.splitterType ?? self.splitterType
                self.splitterWidth = groupSetModel.styles?.splitterWidth ?? self.splitterWidth
                self.textAlignContent = groupSetModel.styles?.textAlignContent ?? self.textAlignContent
                self.textAlignGroup = groupSetModel.styles?.textAlignGroup ?? self.textAlignGroup
                self.textAlignSys = groupSetModel.styles?.textAlignSys ?? self.textAlignSys
                self.textContent = groupSetModel.fields?.textContent ?? self.textContent
                self.textTitle = groupSetModel.fields?.textTitle ?? self.textTitle
                self.title = groupSetModel.styles?.title ?? self.title
                self.radius = groupSetModel.styles?.radius ?? self.radius
            }
        }
    }

    // MARK: - 模块特有属性
    private var formVC = BaseFormVC()
    var groupData: GroupData?
    private var uploadImageUrl: String?
    private var disposeBag = DisposeBag()
    // MARK: init方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.rx.notification(Notification.Name(kSaveNotification)).takeUntil(self.rx.deallocated).subscribe(onNext: {
            [weak self] ntf in
            self?.endEditing(true)
            if let moduleId = ntf.object as? String {
                if self?.moduleCode == moduleId {
                    self?.updateGroup()
                }
            }
        }).disposed(by: disposeBag)
    }
    deinit {
        dPrint("groupSet die")
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 网络请求
extension GroupSet {
    //页面刷新时会调用该方法
    func reloadViewData() {
        //请求M2数据信息
        self.requestGroupSetData()
    }
    //获取GroupSet数据getGroup
    private func requestGroupSetData() {
        NetworkUtil.request(target: .getGroup(group_pid: self.groupData?.pid ?? 0, group_id: self.groupData?.id ?? 0), success: { [weak self] json in
            self?.groupData = SingleGroupModel.deserialize(from: json)?.data
            //渲染UI
            self?.renderUI()
        }) { error in
            HUDUtil.msg(msg: "获取信息失败", type: .error)
            dPrint(error)
        }
    }

    @objc func updateGroup() {
        let form = self.formVC.form
        let icon = self.uploadImageUrl ?? self.groupData?.index_pic ?? ""
        let name = (form.rowBy(tag: "name") as? TextRow)?.value ?? ""
        if name.trim() == ""{
            HUDUtil.msg(msg: "群名称不能为空", type: .error)
            return
        }
        let intro = (form.rowBy(tag: "titleLabel") as? TextAreaRow)?.value ?? ""
        let newCreate = (form.rowBy(tag: "create") as? SwitchRow)?.value ?? true
        let newDelete = (form.rowBy(tag: "delete") as? SwitchRow)?.value ?? true
        let newShow = (form.rowBy(tag: "isShow") as? SwitchRow)?.value ?? true
        //        let choose = (form.rowBy(tag: "isOpen") as? PickerInputRow)?.value ?? ""
        //        var isOpen = 0
        //        if choose == "审核"{
        //            isOpen = 1
        //        }
        var type = 0
        type += newCreate ? 1 : 0
        type += newDelete ? 4 : 0

        NetworkUtil.request(target: .updateGroup(invitation_authority: type, name: name, introduction: intro, group_pid: self.groupData?.pid ?? 0, group_id: self.groupData?.id ?? 0, can_out: newShow ? 1 : 0, reply_authority: 1, index_pic: icon), success: { json in
            let groupData = SingleGroupModel.deserialize(from: json)?.data
            HUDUtil.msg(msg: "更改成功", type: .successful)
            NotificationCenter.default.post(name: Notification.Name(kGroupInfoChangeNotification), object: groupData)
        }) { error in
            HUDUtil.msg(msg: "更改失败", type: .error)
            dPrint(error)
        }
    }
}

// MARK: - UI&事件处理
extension GroupSet {
    //渲染UI
    private func renderUI() {
        if self.bgImg != ""{
            let imgView = UIImageView(frame: self.bounds)
            imgView.kf.setImage(with: URL(string: self.bgImg))
            self.addSubview(imgView)
        }
        self.backgroundColor = self.bgColor.toColor()
        self.layer.cornerRadius = self.radius
        self.layer.masksToBounds = true

//        formVC.form.inlineRowHideOptions = InlineRowHideOptions.AnotherInlineRowIsShown.union(.FirstResponderChanges)
        self.addSubview(formVC.view)
        formVC.form
            +++ Section { section in
                var header = HeaderFooterView<UIView>(.class)
                header.height = { 0 }
                header.onSetupView = { view, _ in
                    view.backgroundColor = .clear
                }
                section.header = header
                var footer = HeaderFooterView<UIView>(.class)
                footer.height = { 0 }
                footer.onSetupView = { view, _ in
                    view.backgroundColor = .clear
                }
                section.footer = footer
            }
            <<< TextRow("name") {[weak self] row in
                row.title = "群组名称"
                if groupData?.name == "" || groupData?.name == nil {
                    row.placeholder = "无群名"
                } else {
                    row.value = self?.groupData?.name ?? ""
                }
                row.cell.backgroundColor = self?.bgColorList.toColor()
//                let lineView = UIView()
//                row.cell.addSubview(lineView)
//                lineView.backgroundColor = self?.splitterColor.toColor() ?? .gray
//                lineView.snp.makeConstraints { (make) in
//                    make.left.equalTo(10)
//                    make.right.equalTo(row.cell.snp.right)
//                    make.bottom.equalTo(row.cell.snp.bottom)
//                    make.height.equalTo(self?.splitterWidth ?? 0)
//                }
                row.onChange({ textRow in
                    if (textRow.value?.trim().count ?? 0) >= 15 {
                        row.value = textRow.value?.subStr(from: 0, length: 15)
                        row.cell.update()
                    }
                })
                row.cellUpdate({ cell, row in
                    row.cell.textLabel?.textColor = .black
                    row.cell.detailTextLabel?.textColor = .gray
                })
            }
            <<< ImageRow("icon") {[weak self] row in
                row.cell.backgroundColor = self?.bgColorList.toColor()
                row.title = "群组头像"
                if let safeUrlStr = URL(string: self?.groupData?.index_pic ?? "") {
                    ImageDownloader.default.downloadImage(with: safeUrlStr, options: [], progressBlock: nil) {
                        image, _, _, _ in
                        row.value = image
                        row.updateCell()
                    }
                }
//                let lineView = UIView()
//                row.cell.addSubview(lineView)
//                lineView.backgroundColor = self?.splitterColor.toColor() ?? .gray
//                lineView.snp.makeConstraints { (make) in
//                    make.left.equalTo(10)
//                    make.right.equalTo(row.cell.snp.right)
//                    make.bottom.equalTo(row.cell.snp.bottom)
//                    make.height.equalTo(self?.splitterWidth ?? 0)
//                }
                let image = row.value
                row.onChange({ row in
                    if image == nil { return }
                    if let safeImage = row.value {
                        self?.uplaodImage(images: [safeImage]) { urlArr in
                            self?.uploadImageUrl = urlArr?.first
                            HUDUtil.stopLoadingHUD(callback: nil)
                        }
                    }
                })
            }

            <<< LabelRow("groupInfo") { [weak self] row in
                row.title = "群组介绍"
                row.cellUpdate({ cell, row in
                    row.cell.textLabel?.textColor = .black
                })
                //            let lineView = UIView()
                //            row.cell.addSubview(lineView)
                //            lineView.backgroundColor = self?.splitterColor.toColor() ?? .gray
                //            lineView.snp.makeConstraints { (make) in
                //                make.left.equalTo(10)
                //                make.right.equalTo(row.cell.snp.right)
                //                make.bottom.equalTo(row.cell.snp.bottom)
                //                make.height.equalTo(self?.splitterWidth ?? 0)
                //            }
                row.onChange({[weak self] _ in
                    self?.updateGroup()
                })
                row.cell.backgroundColor = self?.bgColorList.toColor()
            }
            <<< TextAreaRow("titleLabel") { [weak self] row in
                row.cell.textView.backgroundColor = .clear
                row.cell.backgroundColor = .clear
                row.textAreaHeight = .dynamic(initialTextViewHeight: 80)
//                let lineView = UIView()
//                row.cell.addSubview(lineView)
//                lineView.backgroundColor = self?.splitterColor.toColor() ?? .gray
//                lineView.snp.makeConstraints { (make) in
//                    make.left.equalTo(10)
//                    make.right.equalTo(row.cell.snp.right)
//                    make.bottom.equalTo(row.cell.snp.bottom)
//                    make.height.equalTo(self?.splitterWidth ?? 1)
//                }
                if groupData?.introduction == "" || groupData?.introduction == nil {
                    row.placeholder = "加个群简介吧"
                } else {
                    row.value = groupData?.introduction
                }
                row.onChange({ textRow in
                    if (textRow.value?.trim().count ?? 0) > 60 {
                        HUDUtil.msg(msg: "简介做多60字哦~", type: .info)
                        row.value = textRow.value?.subStr(from: 0, length: 60)
                        row.cell.update()
                    }
                })
                row.cell.backgroundColor = self?.bgColorList.toColor()
                row.cellUpdate({ cell, row in
                    row.cell.textLabel?.textColor = .gray
                    row.cell.detailTextLabel?.textColor = .black
                    row.cell.textView.backgroundColor = .clear
                })
            }

            +++ Section("帖子权限")
            <<< SwitchRow("create") {[weak self] row in
                let auth = (self?.groupData?.invitation_authority ?? 15) & 1
                row.title = "创建"
                row.cell.switchControl.tintColor = .gray
                row.cell.backgroundColor = self?.bgColorList.toColor()
                row.value = auth == 1
//                let lineView = UIView()
//                row.cell.addSubview(lineView)
//                lineView.backgroundColor = self?.splitterColor.toColor() ?? .gray
//                lineView.snp.makeConstraints { (make) in
//                    make.left.equalTo(10)
//                    make.right.equalTo(row.cell.snp.right)
//                    make.bottom.equalTo(row.cell.snp.bottom)
//                    make.height.equalTo(self?.splitterWidth ?? 0)
//                }
            }
            <<< SwitchRow("delete") {[weak self] row in
                let auth = (self?.groupData?.invitation_authority ?? 15) & 4
                row.title = "删除"
                row.cell.switchControl.tintColor = .gray
                row.cell.backgroundColor = self?.bgColorList.toColor()
                row.value = auth > 0
//                let lineView = UIView()
//                row.cell.addSubview(lineView)
//                lineView.backgroundColor = self?.splitterColor.toColor() ?? .gray
//                lineView.snp.makeConstraints { (make) in
//                    make.left.equalTo(10)
//                    make.right.equalTo(row.cell.snp.right)
//                    make.bottom.equalTo(row.cell.snp.bottom)
//                    make.height.equalTo(self?.splitterWidth ?? 0)
//                }
            }
            <<< SwitchRow("isShow") {[weak self] row in
                let open = self?.groupData?.can_out ?? 0
                row.title = "合作单位可见"
                row.cell.switchControl.tintColor = .gray
                row.cell.backgroundColor = self?.bgColorList.toColor()
                row.value = open == 1
//                let lineView = UIView()
//                row.cell.addSubview(lineView)
//                lineView.backgroundColor = self?.splitterColor.toColor() ?? .gray
//                lineView.snp.makeConstraints { (make) in
//                    make.left.equalTo(10)
//                    make.right.equalTo(row.cell.snp.right)
//                    make.bottom.equalTo(row.cell.snp.bottom)
//                    make.height.equalTo(self?.splitterWidth ?? 0)
//                }
            }
            //        <<< PickerInputRow<String>("isOpen"){[weak self] row in
            //            let index = self?.groupData?.add_type ?? 0
            //            row.title = "加入方式"
            //            row.options = ["开放","审核"]
            //            row.value = row.options[index]
            //            row.cell.backgroundColor = .clear
            //        }
            +++ ButtonRow("deleteGroup") {[weak self] row in
                row.title = "删除群组"
//                let lineView = UIView()
//                row.cell.addSubview(lineView)
//                lineView.backgroundColor = self?.splitterColor.toColor() ?? .gray
//                lineView.snp.makeConstraints { (make) in
//                    make.left.equalTo(10)
//                    make.right.equalTo(row.cell.snp.right)
//                    make.bottom.equalTo(row.cell.snp.bottom)
//                    make.height.equalTo(self?.splitterWidth ?? 0)
//                }
//                row.cell.backgroundColor = self?.bgColorList.toColor()
                row.cell.textLabel?.textColor = .red
                let alert = UIAlertController(style: .alert, title: "删除该群组？", message: "群组中所有的帖子将会被删除")
                alert.addAction(title: "点错了", style: .cancel, handler: nil)
                alert.addAction(title: "确定", style: .destructive, handler: { _ in
                    NetworkUtil.request(target: .delGroup(group_pid: self?.groupData?.pid ?? 0, group_id: self?.groupData?.id ?? 0), success: { _ in
                        HUDUtil.msg(msg: "删除成功", type: .successful)
                        NotificationCenter.default.post(name: Notification.Name(kReloadGroupNotification), object: nil)
                        VCController.pop(with: VCAnimationClassic.defaultAnimation())
                        VCController.pop(with: VCAnimationClassic.defaultAnimation())
                    }) { error in
                        HUDUtil.msg(msg: "删除失败", type: .error)
                        dPrint(error)
                    }
                })

                row.onCellSelection({ _, _ in
                    alert.show()
                })
            }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    // MARK: 事件处理
    @objc func touchItem(btn: UIButton) {
    }
}
