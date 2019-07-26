//
//  ChatHelper+ChatGroup.swift
//  UIMaster
//
//  Created by hobson on 2019/3/14.
//  Copyright © 2019 one2much. All rights reserved.
//

import SwiftyJSON
import UIKit

// MARK: - 聊天群
extension ChatHelper {
    /// 进入聊天群
    ///
    /// - Parameters:
    ///   - code: 邀请码
    ///   - groupModel: 群数据模型
    static func applyForChatGroup(code: String, groupModel: ChatGroupDetailData) {
        NetworkUtil.request(
            target: NetworkService.codeUse(code: code),
            success: { _ in
                let message = ChatMessageModel()
                message.kind = ChatMessageType.system.rawValue
                message.groupPid = groupModel.pid ?? 0
                message.session_id = (groupModel.id ?? 0) << 32 + (groupModel.pid ?? 0)
                message.content = "欢迎加入"
                message.msg_id = Int64(Date().getTimeIntervalSince1970())
                message.client_time = Date.currentTimeStr
                message.server_time = Date.currentTimeStr
                message.direction = ChatDirection.sendToOthers.rawValue
                message.chat_type = 1
                message.receiver = groupModel.id ?? 0
                message.receiver_pid = groupModel.pid ?? 0
                message.sender = UserUtil.share.appUserInfo?.uid ?? 0
                message.sender_pid = UserUtil.share.appUserInfo?.pid ?? 0
                message.send_state = ChatSendStatus.success.rawValue
                DatabaseTool.shared.insertMessages(with: [message])
                DatabaseTool.shared.querySingleSession(sessionID: message.session_id, chatType: 1) { model in
                    if let safeModel = model, safeModel.session_id != IMService.shared.currentSessionID {
                        PageRouter.shared.router(to: PageRouter.RouterPageType.chatPage(mdoel: safeModel))
                        return
                    }
                }
            }
        ) { error in
            dPrint(error)
        }
    }

    /// 后台添加群聊
    ///
    /// - Parameters:
    ///   - imgUrl: 群头像
    ///   - name: 群名称
    ///   - img: 本地群头像图片
    static func addChatGroup(imgUrl: String, name: String, img: UIImage?) {
        NetworkUtil.request(
            target: NetworkService.addChatGroup(name: name, notice: "", icon: imgUrl, backgroup: "", nick_name_display: 1, join_type: 0, can_share: 1, banned: 0),
            success: { json in
                //1. 解析数据获取sessionID
                let json = JSON(parseJSON: json ?? "")
                let groupID = json.dictionary?["data"]?.int64
                guard let gid = groupID else {
                    return
                }
                let pid = UserUtil.share.appUserInfo?.pid ?? 0
                //2. 更新头像、昵称的信息数据
                let groupDetail = ChatGroupDetailData()
                groupDetail.id = gid
                groupDetail.pid = pid
                groupDetail.name = name
                groupDetail.icon = imgUrl
                DatabaseTool.shared.insertChatGroupInfo(chatGroupInfo: groupDetail)
                //3. 添加消息和会话
                let sid = gid << 32 + pid
                self.createChatGroup(groupID: gid, pid: pid)
                //4. 提示用户创建成功
                // 退出当前页面
                VCController.pop(with: VCAnimationClassic.defaultAnimation())
                let alertVC = UIAlertController(title: "创建成功", message: "您可以在聊天群详情中邀请群成员", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "我知道了", style: .cancel, handler: { _ in
                    // 推出群聊页
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        let pageKey = GlobalConfigTool.shared.global?.groupChatKey ?? ""
                        DatabaseTool.shared.querySingleSession(sessionID: Int64(sid), chatType: 1) { sessionModel in
                            guard let safeModel = sessionModel else {
                                return
                            }
                            EventUtil.gotoPage(with: pageKey, attachment: [ChatSessionModel.getClassName: safeModel])
                        }
                    })
                }))
                alertVC.addAction(UIAlertAction(title: "立即邀请", style: .default, handler: { _ in
                    // 退出当前页面
                    VCController.pop(with: VCAnimationClassic.defaultAnimation())
                    shareGroupToMember(gid: gid, pid: pid, title: name, image: img)
                }))
                alertVC.show()
            }
        ) { error in
            dPrint(error)
        }
    }

    /// 分享群给成员
    ///
    /// - Parameters:
    ///   - gid: 群id
    ///   - pid: 群pid
    private static func shareGroupToMember(gid: Int64, pid: Int64, title: String, image: UIImage?) {
        NetworkUtil.request(
            target: NetworkService.getGroupInvitation(group_id: Int(gid), group_pid: Int(pid), out_day: 10, point_x: 0, point_y: 0),
            success: { json in
                guard let safeJson = json else {
                    return
                }
                let linkStr = JSON(parseJSON: safeJson)["data"].string
                shareToOthersStatic(text: title, imageName: nil, orImage: image, linkStr: linkStr)
            }
        ) { error in
            dPrint(error)
        }
    }

    /// 本地创建群聊
    ///
    /// - Parameters:
    ///   - groupID: 群id
    ///   - pid: 群pid
    static func createChatGroup(groupID: Int64, pid: Int64) {
        let sessionID = groupID << 32 + pid
        let msgModel = ChatMessageModel()
        msgModel.content = "创建群聊成功"
        msgModel.msg_id = Int64(Date().getTimeIntervalSince1970())
        msgModel.session_id = Int64(sessionID)
        msgModel.sender = UserUtil.share.appUserInfo?.uid ?? 0
        msgModel.sender_pid = UserUtil.share.appUserInfo?.pid ?? 0
        msgModel.receiver = Int64(groupID)
        msgModel.receiver_pid = UserUtil.share.appUserInfo?.pid ?? 0
        msgModel.groupPid = pid
        msgModel.chat_type = 1
        msgModel.kind = ChatMessageType.system.rawValue
        msgModel.client_time = Date.currentTimeStr
        msgModel.server_time = Date.currentTimeStr
        msgModel.direction = ChatDirection.sendToSelf.rawValue
        msgModel.kind = ChatMessageType.system.rawValue
        msgModel.send_state = ChatSendStatus.success.rawValue
        DatabaseTool.shared.insertMessages(with: [msgModel])
    }
}
