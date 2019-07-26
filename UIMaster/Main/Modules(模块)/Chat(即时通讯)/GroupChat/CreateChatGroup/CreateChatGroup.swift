//
//  CreateGroup.swift
//  UIMaster
//
//  Created by hobson on 2018/6/26.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Eureka
import Then
import UIKit
// swiftlint:disable identifier_name
class ChatGroupModel: BaseModel {
    var data: ChatGroupDetailData?
}
class ChatGroupDetailData: BaseData {
    var join_type: Int?
    var icon: String?
    var pid: Int64?
    var nickname_visual: Int?
    var background: String?
    var name: String?
    var id: Int64?
    var can_share: Int?
    var add_time: String?
    var update_time: String?
    var status: Int?
    var notice: String?
    var banned: Int?
    var creator_id: Int64?
    var set_top: Int?
}
// swiftlint:enable identifier_name
class CreateChatGroup: UIView, PageModuleAble, UIShareAble, ImageUploadAble {
    // MARK: 模块相关的配置属性
    private var settingColor = "42,42,42,1"//设置项颜色
    private var settingFontSize: CGFloat = 17//设置项字号
    private var tipFontSize: CGFloat = 17//提示文字字号
    private var tipColor = "104,104,104,1"//提示文字颜色
    private var bgColor = "255,255,255,1"//背景色
    private var bgImg = ""//背景图
    private var borderColor = "#239bf2"//边框颜色

    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            renderUI()
        }
    }

    weak var moduleDelegate: ModuleRefreshDelegate?
    //模块特有属性
    private var pickImageBtn = UIButton()
    private var formVC = BaseFormVC(style: .plain)

    // MARK: init方法
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 网络请求
extension CreateChatGroup {
    func createChatGroup() {
        guard UserUtil.isValid() else {
            HUDUtil.msg(msg: "未登录", type: .error)
            return
        }

        let form = self.formVC.form
        let errors = form.validate()
        for error in errors {
            HUDUtil.msg(msg: error.msg, type: .warning)
            return
        }
        let name = (form.rowBy(tag: "title") as? TextRow)?.value ?? ""
        guard let image = (form.rowBy(tag: "icon") as? ChatGroupIconUploadRow)?.value else {
            return
        }
        self.uplaodImage(images: [image]) { urlArr in
             ChatHelper.addChatGroup(imgUrl: urlArr?.first ?? "", name: name, img: image)
        }
    }
}

// MARK: - UI&事件处理
extension CreateChatGroup {
    //渲染UI
    private func renderUI() {
        self.backgroundColor = self.bgColor.toColor() ?? .white
        formVC.form
            +++ ChatGroupIconUploadRow("icon") { row in
                row.cell.height = { 220 }
                row.cell.uploadImageBtn.setYJIcon(icon: .addImage, iconSize: 40, forState: .normal)
                row.cell.uploadImageBtn.setYJTitleColor(color: UIColor(hexString: borderColor))
                row.cell.uploadImageBtn.drawDashLine(color: UIColor(hexString: borderColor), width: 1, radius: 0)
                let ruleRequiredClosure = RuleClosure<UIImage> { rowValue in
                    if rowValue == nil {
                        return  ValidationError(msg: "请点击按钮上传图片")
                    }
                    return nil
                }
                row.add(rule: ruleRequiredClosure)
            }
            +++ TextRow("title") {[weak self] row in
                row.placeholder = "请输入群聊名称"
                row.cell.backgroundColor = .clear
                row.placeholderColor = UIColor(hexString: "#64BBEA")
                row.cell.textField.textAlignment = .center
                row.cell.textField.textColor = self?.tipColor.toColor()
                row.cell.bottomLine(style: SeparatorStyle.gap(margin: 30), color: UIColor(hexString: "#64BBEA"))
                row.cell.textField.clearButtonMode = .never
                row.cell.textField.font = UIFont.systemFont(ofSize: (self?.tipFontSize)!)
                let ruleRequiredViaClosure = RuleClosure<String> { rowValue in
                    if (rowValue == nil || rowValue!.isEmpty) {
                        return  ValidationError(msg: "请填写群名称")
                    }
                    return nil
                }
                row.onChange({ textRow in
                    if (textRow.value?.trim().count ?? 0) >= 15 {
                        row.value = textRow.value?.subStr(from: 0, length: 15)
                        row.updateCell()
                    }
                })
                row.add(rule: ruleRequiredViaClosure)
                row.validationOptions = .validatesOnChange//校验时机
                row.cellUpdate({ cell, _ in
                   cell.textField.textAlignment = .center
                })
            }
            +++ Section {
                $0.header = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                $0.header?.height = { 50 }
                $0.footer = HeaderFooterView<UIView>(HeaderFooterProvider.class)
                $0.footer?.height = { CGFloat.leastNormalMagnitude }
            }

            <<< ButtonRow { [weak self] row in
                let label = UILabel()
                row.cell.addSubview(label)
                label.text = "提交"
                label.layer.borderColor = UIColor.lightGray.cgColor
                label.layer.borderWidth = 0.5
                label.textAlignment = .center
                label.snp.makeConstraints({ make in
                    make.height.equalTo(40)
                    make.width.equalTo(120)
                    make.center.equalToSuperview()
                })
                label.rx.tapGesture().when(UIGestureRecognizerState.recognized).subscribe(onNext: { _ in
                    self?.createChatGroup()
                }).disposed(by: rx.disposeBag)
                row.cellUpdate({ btn, _ in
                    btn.selectionStyle = .none
                })
                row.cell.backgroundColor = self?.bgColor.toColor()
                row.cell.textLabel?.textColor = self?.tipColor.toColor()
            }
//            +++ LabelRow("picker"){[weak self] row in
//                row.cell.backgroundColor = .clear
//                row.title = "请选择类型"
//                row.cellSetup({ (cell, row) in
//                    cell.textLabel?.textColor = self?.settingColor.toColor()
//                    cell.textLabel?.font = UIFont.systemFont(ofSize: (self?.settingFontSize)!)
//                })
//                let alert = UIAlertController(style: .actionSheet, title: "选择类型", message: "请选择您文章的分类")
//                alert.addAction(title: "完成", style: .cancel,handler: nil)
//                let vc = alert.value(forKey: "contentViewController") as? PickerViewViewController
//                vc?.preferredContentSize.height = 100
//
//                var pickerViewValues = [[String]]()
//                let userPid = UserUtil.share.appUserInfo?.pid ?? 0
//                NetworkUtil.request(target: .getClassifyList(ac: nil, sn: nil, do_pid: userPid, parent: 0), success: { (json) in
//                    let types = ClassifyTypesModel.deserialize(from: json)?.data ?? []
//                    var names = [String]()
//                    for type in types{
//                        guard let subs = type.subclass else{
//                            continue
//                        }
//                        for sub in subs{
//                            self?.classifyIdDic[sub.name ?? ""] = sub.id ?? 1
//                            names.append(sub.name ?? "")
//                        }
//                    }
//                    row.value = names[0]
//                    row.updateCell()
//                    pickerViewValues = [names]
//                    let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: 0)
//                    alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
//                        let arr = values[index.column]
//                        row.value = arr[index.row]
//                        row.updateCell()
//                    }
//                }, failure: nil)
//
//
//                row.onCellSelection({ (cell, row) in
//                    alert.show()
//                })
//            }
//            +++ TextAreaRow("introduction"){[weak self] row in
//                row.title = "群组简介"
//                row.placeholder = "为你的群组写一段介绍吧！200字以内哦~~"
//                row.validationOptions = .validatesOnChange
//                row.cell.textView.backgroundColor = .clear
//                row.cell.backgroundColor = .clear
//                row.cellSetup({ (cell, row) in
//                    cell.textLabel?.textColor = self?.settingColor.toColor()
//                    cell.textLabel?.font = UIFont.systemFont(ofSize: self?.settingFontSize ?? 14)
//                    cell.textView.textColor = self?.tipColor.toColor()
//                    cell.textView.font = UIFont.systemFont(ofSize: self?.tipFontSize ?? 14)
//                    cell.placeholderLabel?.font = UIFont.systemFont(ofSize: self?.tipFontSize ?? 14)
//                    cell.textView.textAlignment =  .left
//                })
//                let ruleRequiredViaClosure = RuleClosure<String> { rowValue in
//                    if (rowValue == nil || rowValue!.isEmpty){
//                        return  ValidationError(msg: "请填写群简介")
//                    }
//                    return nil
//                }
//                row.cell.height = 100
//                row.add(rule: ruleRequiredViaClosure)
//                let ruleMaxLengthClosure = RuleClosure<String>{ rowValue in
//                    if (rowValue?.count ?? 0) > 200{
//                        HUDUtil.msg(msg: "超过200字了哦~~", type: .info)
//                        return  ValidationError(msg: "简介超过200字了哦~~")
//                    }
//                    return nil
//                }
//                row.add(rule: ruleMaxLengthClosure)
//            }
        self.moduleDelegate?.assemble(with: formVC)
        self.addSubview(formVC.view)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        formVC.view.frame = self.bounds
        formVC.tableView.isScrollEnabled = true
        formVC.tableView.separatorStyle = .none
    }
}
