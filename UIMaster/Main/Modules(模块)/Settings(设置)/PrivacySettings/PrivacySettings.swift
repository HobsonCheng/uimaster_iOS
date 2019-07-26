//
//  PrivacySettings.swift
//  UIMaster
//
//  Created by hobson on 2018/7/4.
//  Copyright © 2018年 one2much. All rights reserved.
//
import Eureka
import UIKit

class PrivacySettingsModel: BaseData {
    var events: [String: EventsData]?
    var fields: PrivacySettingsFields?
    var styles: PrivacySettingsStyles?
}
class PrivacySettingsFields: BaseData {
    var follow: Int?
    var group: Int?
    var recommendingFriends: Int?
    var reviewPermissions: Int?
    var verification: Int?
}
class PrivacySettingsStyles: BaseStyleModel {
    var borderWidth: Int?
    var opacity: Int?
    var borderColor: String?
    var borderShow: Int?
}

//  模块通用模板,保持整体完整性，
//  不需要的部分可以先注释掉，之后完成后，再统一删掉
//  可以参考PrivacySettings模块，如果涉及到分页显示数据，请参考GroupListTopic模块

class PrivacySettings: UIView, PageModuleAble {
    // MARK: 模块相关的配置属性
    private var bgColor = "255,255,255,1"//背景 背景颜色
    private var bgImg = ""//背景 图片
    private var bgImgMode = 0//背景 平铺
    private var borderColor = "199,99,99,1"//边框 颜色
    private var borderShow = 1//边框 是否显示
    private var borderWidth = 0//边框 宽度
    private var follow = 1//我的关注
    private var group = 1//我的群组
    private var opacity = 1//背景 透明度
    private var radius: CGFloat = 10//圆角
    private var recommendingFriends = 1//允许给我推荐通讯录朋友
    private var reviewPermissions = 1//帖子评论权限
    private var verification = 1//加我好友时需要验证

    weak var moduleDelegate: ModuleRefreshDelegate?
    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let privacySettingsModel = PrivacySettingsModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.bgColor = privacySettingsModel.styles?.bgColor ?? self.bgColor
                self.bgImg = privacySettingsModel.styles?.bgImg ?? self.bgImg
                self.bgImgMode = privacySettingsModel.styles?.bgImgMode ?? self.bgImgMode
                self.borderColor = privacySettingsModel.styles?.borderColor ?? self.borderColor
                self.borderShow = privacySettingsModel.styles?.borderShow ?? self.borderShow
                self.borderWidth = privacySettingsModel.styles?.borderWidth ?? self.borderWidth
                self.follow = privacySettingsModel.fields?.follow ?? self.follow
                self.group = privacySettingsModel.fields?.group ?? self.group
                self.opacity = privacySettingsModel.styles?.opacity ?? self.opacity
                self.radius = privacySettingsModel.styles?.radius ?? self.radius
                self.recommendingFriends = privacySettingsModel.fields?.recommendingFriends ?? self.recommendingFriends
                self.reviewPermissions = privacySettingsModel.fields?.reviewPermissions ?? self.reviewPermissions
                self.verification = privacySettingsModel.fields?.verification ?? self.verification

                //渲染UI
                //                renderUI()
                //获取数据
                requestPrivacySettingsData()
            }
        }
    }

    //模块特有属性
    private var itemList: PrivacySetData?//保存M2请求回来的数据
    private var pageNum: Int = 1//如果涉及到数据分页，需要此变量
    private var formVC = BaseFormVC()
    private var user = UserUtil.share.appUserInfo

    // MARK: init方法
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 网络请求
extension PrivacySettings {
    @objc func updateAuthoritySet() {
        let form = self.formVC.form

        let friAuth = (form.rowBy(tag: "friendAuth") as? SwitchRow)?.value ?? true
        var friendApply = 0
        if friAuth {
            friendApply = 1
        } else {
            friendApply = 0
        }
        let choose = (form.rowBy(tag: "myGroup") as? LabelRow)?.value ?? ""
        var groupChoose: Int = 0
        if choose == "公开" {
            groupChoose = 0
        } else {
            groupChoose = 1
        }

        let chooses = (form.rowBy(tag: "myAttention") as? LabelRow)?.value ?? ""
        var followChoose: Int = 0
        if chooses == "公开" {
            followChoose = 0
        } else {
            followChoose = 1
        }

        NetworkUtil.request(target: .updateAuthoritySet(friend_apply: friendApply, group_apply: groupChoose, follow_apply: followChoose), success: { _ in
        }) { error in
            dPrint(error)
        }
    }

    //获取PrivacySettings数据
    private func requestPrivacySettingsData() {
        NetworkUtil.request(target: .getAuthority, success: { [weak self] json in
            //转成对应的数据模型，不分页
            self?.itemList = PrivacySetModel.deserialize(from: json)?.data
            self?.renderUI()
            //请求完成，回调告知AssembleVC停止刷新
            self?.moduleDelegate?.moduleLayoutDidRefresh()
        }) { error in
            dPrint(error)
        }
    }
}

// MARK: - UI&事件处理
extension PrivacySettings {
    //渲染UI
    private func renderUI() {
        self.layer.cornerRadius = self.radius
        self.layer.masksToBounds = true
        self.backgroundColor = self.bgColor.toColor()
        formVC.form
            //            +++ SwitchRow("friendRecommend"){ row in
            //                row.title = "允许给我推荐通讯录好友"
            //                row.cell.switchControl.tintColor = .gray
            //                row.onChange({ (row) in
            //                    self.updateAuthoritySet()
            //                })
            ////                row.value =  user.?? true
            //            }
            +++ SwitchRow("friendAuth") { row in
                row.title = "加我好友时需要验证"
                row.cell.switchControl.tintColor = .gray
                row.cell.backgroundColor = .clear
                if self.itemList?.friend_apply == 0 {
                    row.value = false
                } else {
                    row.value = true
                }
                row.onChange({ _ in
                    self.updateAuthoritySet()
                })
            }
            //            +++ PickerInputRow<String>("commentJurisdiction"){ row in
            //                row.title = "帖子评论权限"
            //                row.options = ["所有人","不允许评论","仅好友"]
            //                row.onChange({ (row) in
            //                    self.updateAuthoritySet()
            //                })
            //            }
            +++ LabelRow("myGroup") { [weak self] row in
                row.title = "我的群组"
                let limitsArr = [["公开", "不公开"]]
                var pickerViewSelectedValue = (column: 0, row: 0)
                if  self?.itemList?.group_authority == 1 {
                    pickerViewSelectedValue = (column: 0, row: 1)
                }
                let genderName = limitsArr[pickerViewSelectedValue.column]
                let value = genderName[pickerViewSelectedValue.row]
                row.value = value
                row.onCellSelection({ cell, row in
                    let alert = UIAlertController(style: .actionSheet, title: "请选择", message: "是否允许他人看到自己加入的群组")
                    alert.addAction(title: "完成", style: .cancel, handler: nil)
                    alert.addPickerView(values: limitsArr, initialSelection: pickerViewSelectedValue) { _, _, index, _ in
                        let limitsName = limitsArr[index.column]
                        let value = limitsName[index.row]
                        pickerViewSelectedValue = (column: index.column, row: index.row)
                        row.value = value
                        row.cell.update()
                    }
                    let vc = alert.value(forKey: "contentViewController") as? PickerViewViewController
                    vc?.preferredContentSize.height = 80
                    alert.show()
                })
                row.onChange({ _ in
                    self?.updateAuthoritySet()
                })
                row.cellUpdate({ cell, row in
                    row.cell.textLabel?.textColor = .black
                    row.cell.detailTextLabel?.textColor = .black
                })
            }
            <<< LabelRow("myAttention") { [weak self] row in
                row.title = "我的关注"
                let limitsArr = [["公开", "不公开"]]
                var pickerViewSelectedValue = (column: 0, row: 0)
                if  self?.itemList?.follow_authority == 1 {
                    pickerViewSelectedValue = (column: 0, row: 1)
                }
                let genderName = limitsArr[pickerViewSelectedValue.column]
                let value = genderName[pickerViewSelectedValue.row]
                row.value = value
                row.onChange({ _ in
                    self?.updateAuthoritySet()
                })
                row.onCellSelection({ cell, row in
                    let alert = UIAlertController(style: .actionSheet, title: "请选择", message: "是否允许他人看到自己关注的人")
                    alert.addPickerView(values: limitsArr, initialSelection: pickerViewSelectedValue) { _, _, index, _ in
                        let limitsName = limitsArr[index.column]
                        let value = limitsName[index.row]
                        pickerViewSelectedValue = (column: index.column, row: index.row)
                        row.value = value
                        row.cell.update()
                    }
                    alert.addAction(title: "完成", style: .cancel, handler: nil)
                    let vc = alert.value(forKey: "contentViewController") as? PickerViewViewController
                    vc?.preferredContentSize.height = 80
                    alert.show()
                })

                row.cellUpdate({ cell, row in
                    row.cell.textLabel?.textColor = .black
                    row.cell.detailTextLabel?.textColor = .black
                })
            }
            //            +++ LabelRow("myGroup"){ [weak self] row in
            //                row.title = "我的群组"
            //                row.options = ["开放","仅自己"]
            //                if self.itemList?.group_authority == 0 {
            //                    row.value = "开放"
            //                } else {
            //                    row.value = "仅自己"
            //                }
            //                row.onChange({ (row) in
            //                    self.updateAuthoritySet()
            //                })
            //            }
//            <<< PickerInputRow<String>("myAttention"){ row in
//                row.title = "我的关注"
//                row.options = ["开放","仅自己"]
//                if self.itemList?.follow_authority == 0 {
//                    row.value = "开放"
//                } else {
//                    row.value = "仅自己"
//                }
//                row.onChange({ (row) in
//                    self.updateAuthoritySet()
//                })
//        }
        self.addSubview(formVC.view)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        formVC.view.frame = self.bounds
    }
}
