//
//  ChatGroupDetail.swift
//  UIMaster
//
//  Created by hobson on 2018/8/21.
//  Copyright © 2018年 one2much. All rights reserved.
//

import SwiftyJSON
import UIKit

class ChatGroupMemberModel: BaseModel {
    var data: [ChatGroupMemberData]?
}
// swiftlint:disable identifier_name
class ChatGroupMemberData: BaseData {
    var status: Int?
    var pid: Int64?
    var an_excuse: Int?
    var nickname: String?
    var message_free: Int?
    var add_time: String?
    var update_time: String?
    var uid: Int64?
    var user_pid: Int64?
    var id: Int64?
    var group_id: Int64?
    var set_top: Int?
    var creator: Int64?
    var head_portrait: String?
    var nickname_display: Int?
    var shields: Int?
}
// swiftlint:enable identifier_name
class ChatGroupDetailModel: BaseData {
    var events: [String: EventsData]?
    var styles: ChatGroupDetailStyleModel?
}
class ChatGroupDetailStyleModel: BaseStyleModel {
}

class ChatGroupDetailVC: BaseNameVC, PageModuleAble, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIShareAble {
    weak var moduleDelegate: ModuleRefreshDelegate?
    var styleDic: [String: Any]? {
        didSet {
//            moduleDelegate?.setfullPageTableModule(table: self.tableView)
        }
    }
    var moduleParams: [String: Any]? {
        didSet {
            self.chatGroupDetailModel = moduleParams?[ChatGroupDetailData.getClassName] as? ChatGroupDetailData
            reloadViewData()
        }
    }
    fileprivate var chatGroupDetailModel: ChatGroupDetailData?
    fileprivate var showMore: Bool = false
    fileprivate var avatorCell: ChatGroupAvatarCell?
    fileprivate lazy var tableView: BaseTableView = {
        let table = BaseTableView(frame: .zero, style: .grouped)
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
        table.sectionIndexBackgroundColor = .clear
        table.sectionHeaderHeight = 0.01
        table.sectionFooterHeight = 0.01
//        table.estimatedSectionHeaderHeight = 0.001
//        table.estimatedSectionFooterHeight = 0.001
        table.registerCellClass(ChatGroupSettingCell.self)
        table.registerCellClass(ChatGroupAvatarCell.self)
        table.registerCellClass(ChatGroupInfoCell.self)
        table.registerCellClass(ChatGroupButtonCell.self)
        view.addSubview(table)
        table.snp.makeConstraints { make in
            make.left.right.bottom.top.equalToSuperview()
        }
        return table
    }()

    /// 群成员信息
    fileprivate lazy var memberInfoArr: [ChatGroupMemberData] = []

    /// 是否是字自己的群
    fileprivate var isMyGroup: Bool {
        let cid = self.chatGroupDetailModel?.creator_id
        let uid = UserUtil.share.appUserInfo?.uid
        return uid == cid
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//    NotificationCenter.default.rx.notification(Notification.Name.init(kChatGroupInfoChangeNotification)).takeUntil(self.rx.deallocated).subscribe(onNext: {
//            [weak self] (ntf) in
//            if let sessionModel = ntf.object as? ChatSessionModel {
//                DatabaseTool.shared.queryChatGroupInfo(gid: sessionModel.session_id >> 32, pid: sessionModel.groupPid, finish: {[weak self] (model) in
//                    self?.chatGroupDetailModel = model
//                    DispatchQueue.main.async {
//                        self?.reloadViewData()
//                    }
//                })
//            }
//        }).disposed(by: rx.disposeBag)
    }
}

// MARK: - 网络请求
extension ChatGroupDetailVC {
    func reloadViewData() {
        guard let gid = self.chatGroupDetailModel?.id, let pid = self.chatGroupDetailModel?.pid, gid != 0, pid != 0 else {
            HUDUtil.msg(msg: "群数据有误", type: .info)
            return
        }
        requestChatGroupMember(gid: gid, pid: pid)
        updateChatGroupInfo(gid: gid, pid: pid)
    }

    /// 更新群信息
    func updateChatGroupInfo(gid: Int64, pid: Int64) {
        DatabaseTool.shared.updateChatGroupInfo(gid: gid, pid: pid, immediate: true)
    }

    /// 获取群成员
    func requestChatGroupMember(gid: Int64, pid: Int64) {
        NetworkUtil.request(
            target: NetworkService.selectGroupMemberList(group_id: gid, group_pid: pid),
            success: {[weak self] json in
                let chatUserArr = ChatGroupMemberModel.deserialize(from: json)?.data
                self?.memberInfoArr = chatUserArr ?? []
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        ) { error in
            dPrint(error)
        }
    }

    /// 邀请其他成员入群
    func inviteMember() {
        let gid = chatGroupDetailModel?.id ?? 0
        let groupPid = chatGroupDetailModel?.pid ?? 0
        NetworkUtil.request(
            target: NetworkService.getGroupInvitation(group_id: Int(gid), group_pid: Int(groupPid), out_day: 10, point_x: 0, point_y: 0),
            success: { [weak self] json in
                guard let safeJson = json else {
                    return
                }
                let linkStr = JSON(parseJSON: safeJson)["data"].string
                self?.shareToOthers(text: self?.chatGroupDetailModel?.name, imageName: nil, orImage: self?.avatorCell?.avatar, linkStr: linkStr)
            }
        ) { error in
            dPrint(error)
        }
    }

    /// 更改群信息
    /// - Parameter groupDetailModel: 群信息数据模型
    func changeGroupInfo(groupDetailModel: ChatGroupDetailData) {
        guard let id = groupDetailModel.id, let pid = groupDetailModel.pid, let name = groupDetailModel.name, let icon = groupDetailModel.icon else {
            return
        }
        guard let notice = groupDetailModel.notice, let background = groupDetailModel.background, let nicknameVisual = groupDetailModel.nickname_visual, let joinType = groupDetailModel.join_type, let canShare = groupDetailModel.can_share, let banned = groupDetailModel.banned else {
            return
        }
        NetworkUtil.request(
            target: NetworkService.updateChatGroup(group_id: id, group_pid: pid, name: name, icon: icon, notice: notice, background: background, nick_name_display: nicknameVisual, join_type: joinType, can_share: canShare, banned: banned),
            success: {  _ in
                DatabaseTool.shared.modifyChatGroupInfo(chatGroupInfo: groupDetailModel)
                NotificationCenter.default.post(name: Notification.Name(kChatGroupInfoChangeNotification), object: nil)
            }
        ) { error in
            dPrint(error)
        }
    }

    /// 退出聊天群
    func quitChatGroup() {
        let alertVC = UIAlertController(title: "确定退出该群？", message: "", preferredStyle: .alert)
        alertVC.addAction(
            UIAlertAction(title: "确定", style: .destructive) { [weak self] _ in
                let gid = self?.chatGroupDetailModel?.id ?? 0
                let groupPid = self?.chatGroupDetailModel?.pid ?? 0
                NetworkUtil.request(
                    target: NetworkService.delGroupPersonnel(group_id: Int(gid), group_pid: Int(groupPid)),
                    success: { _ in
                        _ = VCController.popToHomeVC(with: VCAnimationClassic.defaultAnimation())
                        _ = DatabaseTool.shared.deleteChatSession(by: gid << 32 + groupPid, type: 1)
                    }
                ) { error in
                    dPrint(error)
                }
            }
        )
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alertVC.show()
    }

    /// 删除聊天群
    func delChatGroup() {
        let gid = chatGroupDetailModel?.id ?? 0
        let groupPid = chatGroupDetailModel?.pid ?? 0
        NetworkUtil.request(
            target: NetworkService.delChatGroup(group_id: gid, group_pid: groupPid),
            success: { json in
                dPrint(json ?? "")
            }
        ) { error in
            dPrint(error)
        }
    }
}

extension ChatGroupDetailVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        case 2:
            return isMyGroup ? 0 : 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let memberCount = self.memberInfoArr.count
        switch indexPath.section {
        case 0:
            if showMore {
                let row = memberCount / 5 + (memberCount % 5 > 0 ? 1 : 0)
                return CGFloat(row * 90)
            }
            if memberCount > 15 {
                return 314
            }
            if memberCount > 10 {
                return 260
            }
            if memberCount > 5 {
                return 200
            }
            return 100
        case 6:
            return 40
        default:
            return 45
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.000_1
        }
        return 10
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return 40
        }
        return 0.000_1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ChatGroupSettingCell.getIdentifier) as? ChatGroupSettingCell
            cell?.memberInfoArr = self.memberInfoArr
            return cell!
        }
        if indexPath.section == 2 {
            return tableView.dequeueReusableCell(withIdentifier: ChatGroupButtonCell.getIdentifier, for: indexPath)
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatGroupAvatarCell.getIdentifier, for: indexPath) as? ChatGroupAvatarCell else {
                return UITableViewCell()
            }
            cell.title = "群头像"
            cell.accessoryType = isMyGroup ? .disclosureIndicator : .none
            cell.avatarUrlStr = self.chatGroupDetailModel?.icon ?? ""
            avatorCell = cell
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: ChatGroupInfoCell.getIdentifier, for: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        if indexPath.section == 2 {
            guard let cell = cell as? ChatGroupButtonCell else {
                return
            }
            cell.buttonTitle = "删除并退出"
            cell.delegate = self
            return
        }

        if indexPath.section == 0 {
            guard let cell = cell as? ChatGroupSettingCell else {
                return
            }
            cell.delegate = self
            cell.accessoryType = .none
            return
        }
        guard let cell = cell as? ChatGroupInfoCell else {
            return
        }
        if indexPath.section == 1 {
            if indexPath.row == 1 {
                cell.delegate = self
                cell.indexPate = indexPath
                cell.title = "群聊名称"
                cell.detail = self.chatGroupDetailModel?.name ?? "暂无"
                cell.isShowSwitch = false
                cell.accessoryType = isMyGroup ? .disclosureIndicator : .none
                cell.bottomLine(style: .leftGap(margin: 10), color: .lightGray)
            }
            if indexPath.row == 0 {
                cell.delegate = self
                cell.indexPate = indexPath
                cell.title = "群头像"
                cell.detail = self.chatGroupDetailModel?.name ?? "暂无"
                cell.isShowSwitch = false
                cell.accessoryType = isMyGroup ? .disclosureIndicator : .none
            }
            if indexPath.row == 2 {
                cell.delegate = self
                cell.indexPate = indexPath
                cell.title = "邀请成员"
                cell.isShowSwitch = false
                cell.accessoryType = .disclosureIndicator
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 1 {
                guard isMyGroup else {
                    return
                }
                let alert = UIAlertController(title: "请输入群名称", message: nil, preferredStyle: .alert)
                alert.addTextField { [weak self] textField in
                    textField.text = self?.chatGroupDetailModel?.name
                    textField.delegate = self
                }
                alert.addAction(title: "确定") { [weak self] _ in
                    let textField = alert.textFields?.first
                    let groupName = textField?.text
                    self?.chatGroupDetailModel?.name = groupName
                    self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
                    self?.changeGroupInfo(groupDetailModel: self?.chatGroupDetailModel ?? ChatGroupDetailData())
                }
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                alert.show()
            }
            if indexPath.row == 0 {
                guard isMyGroup else { return }
                let alert = UIAlertController(title: "选择图片", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                alert.addAction(UIAlertAction(title: "拍照", style: .default, handler: { _ in
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        let picker = UIImagePickerController()
                        picker.sourceType = .camera
                        picker.delegate = self
                        picker.allowsEditing = true
                        kWindowRootVC?.present(picker, animated: true, completion: nil)
                    } else {
                        HUDUtil.msg(msg: "您的设备好像不支持照相机~~", type: .info)
                    }
                }))
                alert.addAction(UIAlertAction(title: "选择图片", style: .default, handler: { _ in
                    let picker = UIImagePickerController()
                    picker.sourceType = .photoLibrary
                    picker.delegate = self
                    picker.allowsEditing = true
                    kWindowRootVC?.present(picker, animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                alert.show()
            }
            if indexPath.row == 2 {
                inviteMember()
            }
        }

        if indexPath.section == 2 {
            quitChatGroup()
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)

        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            dPrint("没有图片")
            return
        }
        uploadImage(images: [image]) { urlArr in
            guard let safeUrlArr = urlArr, !(safeUrlArr.isEmpty) else {
                return
            }
            self.avatorCell?.avatar = image
            self.chatGroupDetailModel?.icon = urlArr?.first
            self.changeGroupInfo(groupDetailModel: self.chatGroupDetailModel ?? ChatGroupDetailData())
        }
    }
    // MARK: 上传图片
    func uploadImage(images: [UIImage]?, uploadFinish:@escaping ([String]?) -> Void) {
        //图片为空返回
        guard let safeImages = images else {
            HUDUtil.msg(msg: "图片数据为空", type: .error)
            return
        }
        //上传七牛云
        let handler = HUDUtil.upLoadProgres()
        UploadImageTool.uploadImages(imageArray: safeImages, progress: { _, progress in
            DispatchQueue.main.async {
                handler(CGFloat(progress))
            }
        }, success: { urlArr in
            dPrint("url:\(urlArr)")
            DispatchQueue.main.async {
                HUDUtil.stopLoadingHUD(callback: nil)
            }
            uploadFinish(urlArr)
        }) { errorMsg in
            DispatchQueue.main.async {
                HUDUtil.stopLoadingHUD(callback: nil)
            }
            HUDUtil.msg(msg: errorMsg, type: .error)
        }
    }
}

extension ChatGroupDetailVC: ChatGroupInfoCellDelegate, ChatGroupButtonCellDelegate, ChatGroupSettingCellDelegate, UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        if textField.text?.count > 15 {
            HUDUtil.msg(msg: "最多15个字", type: .info)
            return false
        }
        return true
    }
    func chatGroupInfoCell(clickSwitchButton button: UISwitch, indexPath: IndexPath?) {
    }

    func buttonCell(clickButton button: UIButton) {
        self.quitChatGroup()
    }

    func clickMoreButton(clickButton button: UIButton) {
        self.showMore = true
        self.tableView.reloadData()
//        reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: UITableViewRowAnimation.automatic)
    }

    func clickAddCell(cell: ChatGroupSettingCell) {
    }

    func clickRemoveCell(cell: ChatGroupSettingCell) {
    }

    func didSelectCell(cell: ChatGroupSettingCell, indexPath: IndexPath) {
        let index = indexPath.section * 5 + indexPath.row
        let info = cell.memberDetailArr[index]
        guard let safeUid = info.uid, let safePid = info.pid else { return }
        PageRouter.shared.router(to: PageRouter.RouterPageType.personalCenterT(tuple: (safeUid, safePid)))
    }
}
