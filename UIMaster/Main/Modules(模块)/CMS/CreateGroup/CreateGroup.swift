//
//  CreateGroup.swift
//  UIMaster
//
//  Created by hobson on 2018/6/26.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Eureka
import IQKeyboardManagerSwift
import RxSwift
import Then
import UIKit

class ClassifyTypesModel: BaseData {
    var data: [ClassifyTypes]?
}
class ClassifyTypes: BaseData {
    var id: Int?
    var name: String?
    var subclass: [ClassifySonTypes]?
}
class ClassifySonTypes: BaseData {
    var id: Int?
    var name: String?
}
class CreateGroupModel: BaseData {
    var styles: CreateGroupStylesModel?
    var events: EventsData?
}
class CreateGroupStylesModel: BaseStyleModel {
    var tipColor: String?
    var tipFontSize: CGFloat?
    var settingColor: String?
    var settingFontSize: CGFloat?
}
//  模块通用模板,保持整体完整性，
//  不需要的部分可以先注释掉，之后完成后，再统一删掉
//  可以参考LaunchPad模块，如果涉及到分页显示数据，请参考GroupListTopic模块

class CreateGroup: BaseNameVC, PageModuleAble, ImageUploadAble {
    // MARK: 模块相关的配置属性
    private var settingColor = "42,42,42,1"//设置项颜色
    private var settingFontSize: CGFloat = 17//设置项字号
    private var tipFontSize: CGFloat = 14//提示文字字号
    private var tipColor = "104,104,104,1"//提示文字颜色
    private var bgColor = "255,255,255,1"//背景色
    private var bgImg = ""//背景图
    private var borderColor = "#239bf2"//边框颜色

    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let createGroupModel = CreateGroupModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.settingColor = createGroupModel.styles?.settingColor ?? self.settingColor
                self.tipFontSize = createGroupModel.styles?.tipFontSize ?? self.tipFontSize
                self.bgImg = createGroupModel.styles?.bgImg ?? self.bgImg
                self.settingFontSize = createGroupModel.styles?.settingFontSize ?? self.settingFontSize
                self.bgColor = createGroupModel.styles?.bgColor ?? self.bgColor
                self.tipColor = createGroupModel.styles?.tipColor ?? self.tipColor
                //渲染UI
                renderUI()
            }
        }
    }

    //模块特有属性
    private var pickImageBtn = UIButton()
    private var formVC = BaseFormVC(style: .plain)
    private var classifyIdDic = [String: Int]()
    weak var parentVC: UIViewController?
    private var types: [String]?
    weak var moduleDelegate: ModuleRefreshDelegate?
    private var disposeBag = DisposeBag()
    // MARK: init方法
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.rx.notification(Notification.Name(kSaveNotification)).takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] ntf in
            if let moduleId = ntf.object as? String {
                if self?.moduleCode == moduleId {
                    self?.createGroup()
                }
            }
        }).disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
}

// MARK: - 网络请求
extension CreateGroup {
    func createGroup() {
        let form = self.formVC.form
        let errors = form.validate()
        for error in errors {
            HUDUtil.msg(msg: error.msg, type: .warning)
            return
        }

        let name = (form.rowBy(tag: "title") as? TextRow)?.value?.trim() ?? ""
        let introduction = (form.rowBy(tag: "introduction") as? TextAreaRow)?.value?.trim() ?? ""
        let typeName = form.rowBy(tag: "picker")?.baseValue as? String ?? ""
        let type = classifyIdDic[typeName] ?? 1
        guard let img = (form.rowBy(tag: "icon") as? IconUploadRow)?.value?.uploadImage  else {
            return
        }
        uplaodImage(images: [img]) { urls in
            NetworkUtil.request(target: .addGroup(classify_id: type, name: name, index_pic: urls?.first ?? "", introduction: introduction), success: { json in
                let groupData = SingleGroupModel.deserialize(from: json)?.data
                NotificationCenter.default.post(name: Notification.Name(kReloadGroupNotification), object: groupData)
                HUDUtil.msg(msg: "创建成功", type: .successful)
                VCController.pop(with: VCAnimationClassic.defaultAnimation())
            }) { error in
                dPrint(error)
            }
        }
    }
}

// MARK: - UI&事件处理
extension CreateGroup {
    //渲染UI
    private func renderUI() {
        self.view.backgroundColor = self.bgColor.toColor() ?? .white
        formVC.form
            +++ IconUploadRow("icon") { [weak self] row in
//                row.value = IconUploadInfo(title: "群组头像", subIconUpload: "为您的群组添加一张有代表性的图片", uploadImage: "")
                row.cell.titleLabel.font = UIFont.systemFont(ofSize: (self?.settingFontSize)!)
                row.cell.titleLabel.textColor = self?.settingColor.toColor() ?? .black
                row.cell.titleLabel.textAlignment = .center
                row.cell.height = { 220 }
                row.cell.titleLabel.font = UIFont.systemFont(ofSize: (self?.settingFontSize)!)
                row.cell.titleLabel.textColor = self?.settingColor.toColor() ?? .black
                row.cell.subIconUploadLabel.font = UIFont.systemFont(ofSize: (self?.tipFontSize)!)
                row.cell.subIconUploadLabel.textColor = self?.tipColor.toColor() ?? .black
                row.cell.uploadImageBtn.setYJIcon(icon: .addImage, iconSize: 40, forState: .normal)
                row.cell.uploadImageBtn.setYJTitleColor(color: UIColor(hexString: borderColor))
                row.cell.uploadImageBtn.drawDashLine(color: UIColor(hexString: borderColor), width: 1, radius: 0)
                let ruleRequiredClosure = RuleClosure<IconUploadInfo> { rowValue in
                    if rowValue?.uploadImage == nil {
                        return  ValidationError(msg: "请点击按钮上传图片")
                    }
                    return nil
                }
                row.add(rule: ruleRequiredClosure)
            }
            +++ TextRow("title") { [weak self] row in
                row.title = "群组名称"
                row.placeholder = "给群组起个响亮的名称(15个字以内)"
                row.cell.height = { 60 }
                row.cell.backgroundColor = .clear
                let ruleRequiredViaClosure = RuleClosure<String> { rowValue in
                    if (rowValue == nil || rowValue!.isEmpty) {
                        return  ValidationError(msg: "请填写群组名称")
                    }
                    return nil
                }
                row.onChange({ textRow in
                    if (textRow.value?.trim().count ?? 0) >= 15 {
                        textRow.value = textRow.value?.subStr(from: 0, length: 15)
                        textRow.updateCell()
                    }
                })

                row.add(rule: ruleRequiredViaClosure)
                row.validationOptions = .validatesOnChange//校验时机
                row.cellUpdate({ cell, _ in
                    cell.textLabel?.textColor = self?.settingColor.toColor()
                    cell.textLabel?.font = UIFont.systemFont(ofSize: (self?.settingFontSize)!)
                    cell.textField.textColor = self?.tipColor.toColor()
                    cell.textField.font = UIFont.systemFont(ofSize: (self?.tipFontSize)!)
                    cell.textField.textAlignment =  .left
                    cell.textField.clearButtonMode =  .whileEditing
                })
            }
            +++ LabelRow("picker") {[weak self] row in
                row.cell.backgroundColor = .clear
                row.title = "请选择类型"
                row.cellSetup({ cell, _ in
                    cell.textLabel?.textColor = self?.settingColor.toColor()
                    cell.textLabel?.font = UIFont.systemFont(ofSize: (self?.settingFontSize)!)
                })
                let alert = UIAlertController(style: .actionSheet, title: "选择类型", message: "请选择您文章的分类")
                alert.addAction(title: "完成", style: .cancel, handler: nil)
                let vc = alert.value(forKey: "contentViewController") as? PickerViewViewController
                vc?.preferredContentSize.height = 100

                var pickerViewValues = [[String]]()
                let userPid = UserUtil.share.appUserInfo?.pid ?? 0
                NetworkUtil.request(target: .getClassifyList(do_pid: userPid, parent: 0), success: { json in
                    let types = ClassifyTypesModel.deserialize(from: json)?.data ?? []
                    var names = [String]()
                    for type in types {
                        guard let subs = type.subclass else {
                            continue
                        }
                        for sub in subs {
                            self?.classifyIdDic[sub.name ?? ""] = sub.id ?? 1
                            names.append(sub.name ?? "")
                        }
                    }
                    row.value = names[0]
                    row.updateCell()
                    pickerViewValues = [names]
                    let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: 0)
                    alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { _, _, index, values in
                        let arr = values[index.column]
                        row.value = arr[index.row]
                        row.updateCell()
                    }
                }, failure: nil)

                row.onCellSelection({ _, _ in
                    alert.show()
                })
            }
            +++ TextAreaRow("introduction") {[weak self] row in
                row.title = "群组简介"
                row.placeholder = "为你的群组写一段介绍吧！60字以内哦~~"
                row.validationOptions = .validatesOnChange
                row.cell.textView.backgroundColor = .clear
                row.cell.backgroundColor = .clear
                row.cellSetup({ cell, _ in
                    cell.textLabel?.textColor = self?.settingColor.toColor()
                    cell.textLabel?.font = UIFont.systemFont(ofSize: self?.settingFontSize ?? 14)
                    cell.textView.textColor = self?.tipColor.toColor()
                    cell.textView.font = UIFont.systemFont(ofSize: self?.tipFontSize ?? 14)
                    cell.placeholderLabel?.font = UIFont.systemFont(ofSize: self?.tipFontSize ?? 14)
                    cell.textView.textAlignment =  .left
                })
                let ruleRequiredViaClosure = RuleClosure<String> { rowValue in
                    if (rowValue == nil || rowValue!.isEmpty) {
                        return  ValidationError(msg: "请填写群简介")
                    }
                    return nil
                }
                row.textAreaHeight = .dynamic(initialTextViewHeight: 110)
                row.add(rule: ruleRequiredViaClosure)
                let ruleMaxLengthClosure = RuleClosure<String> { rowValue in
                    if (rowValue?.count ?? 0) > 60 {
                        return  ValidationError(msg: "群简介超出60字~~")
                    }
                    return nil
                }
                row.onChange({ textRow in
                    if (textRow.value?.trim().count ?? 0) > 60 {
                        HUDUtil.msg(msg: "已经60字了哦~~", type: .info)
                        row.value = textRow.value?.subStr(from: 0, length: 60)
                        row.cell.update()
                    }
                })
                row.add(rule: ruleMaxLengthClosure)
            }
        self.addChildViewController(formVC)
        self.view.addSubview(formVC.view)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        formVC.view.frame = self.view.bounds
        formVC.tableView.isScrollEnabled = true
    }
}
