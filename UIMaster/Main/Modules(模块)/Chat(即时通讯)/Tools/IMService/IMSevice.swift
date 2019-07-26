//
// Created by hobson on 2018/9/24.
// Copyright (c) 2018 one2much. All rights reserved.
//

import AudioToolbox
import KeychainAccess
import SwiftyJSON
import UIKit

class NotificationMessageModel: BaseModel {
    var data: [NotificationMessageData]?
}

class NotificationSingleMessageModel: BaseModel {
    var data: NotificationMessageData?
}
// swiftlint:disable identifier_name
class NotificationMessageData: BaseData {
    var id: String?
    var pid: Int?
    var level: Int?
    var sender: Int?
    var sender_pid: Int?
    var target: Int?
    var target_pid: Int?
    var target_type: Int?
    var content: String?
    var action: Int?
    var action_pid: Int?
    var action_object: String?
    var action_object_type: Int?
    var add_time: String?
    var expired_time: String?
    var send_count: Int?
    var message_info: String?
    var unread: Int?
}
// swiftlint:enable identifier_name
/// 通知类型
///
/// - likeInvitation: 帖子点赞
/// - likeComment: 评论点赞
/// - personalChat: 私聊
/// - groupChat: 群聊
/// - comment: 评论
/// - reply: 回复
/// - attention: 关注
/// - applyForFriend: 好友申请
/// - agreeToFriend: 通过好友
/// - newFriend: 有人添加自己为好友 自己设置了加好友不需要验证
enum NotificationActionType: Int {
    case likeInvitation = 10
    case likeComment = 11
    case personalChat = 46
    case groupChat = 47
    case comment = 5
    case reply = 6
    case attention = 4
    case applyForFriend = 3
    case agreeToFriend = 2
    case newFriend = 43
    case notice = 1
    case deleteNotice = 56
}

class IMMessageModel: BaseModel {
    var data: [IMMessageData]?
}

class IMMessageData: BaseData {
    var id: String? //推送消息ID
    var status: Int?
    var sendtime: String? //发送时间
    var clientid: Int64? //msg_id
    var targetpid: Int64?// 接收方pid
    var serverid: Int64?
    var content: String? // 发送内容
    var target: Int64? // 接收方id
    var sendpid: Int64? // 发送方pid
    var sessionid: Int64? // 会话id
    var sender: Int64? // 发送方id
    var type: Int? // 消息类型
    var chattype: Int?//群聊1 私聊0
    var grouppid: Int64? //群pid
    var filename: String? //文件名
}

enum IMServiceType {
    /// 轮询
    case polling
    /// apns 推送
    case push
}
enum ReceiveMessageType {
    case offline
    case online
}

class IMService {
    //    单例
    static let shared = IMService()
    // 定时器
    private lazy var timer: SwiftTimer = {
        SwiftTimer(interval: .seconds(2), repeats: true, leeway: .seconds(0), queue: .global(), handler: { [weak self] _ in
            DispatchQueue.main.async {
                self?.requestMessage()
            }
        })
    }()

    private init() {}
    /// 钥匙串用于保存uuid作为设备id
    let keychain = Keychain(service: "com.one2much.uuid")
    /// 是否需要提示音
    var isNeedSound = false
    /// 当前的会话ID
    var currentSessionID: Int64?
    /// 最后一条消息的ID
    fileprivate var lastID: Int64 = (getUserDefaults(key: kLastMessageID) as? Int64) ?? 0
    /// 服务类型
    var serviceType: IMServiceType?
    var notificationID: String?

    /// 根据服务类型开启服务
    ///
    /// - Parameter serviceType: 服务类型
    func startService(serviceType: IMServiceType) {
        self.serviceType = serviceType
        switch serviceType {
        case .polling:
            self.startPollingSerice()
        case .push:
            self.pausePolling()
            self.startPushService()
        }
    }

    /// 处理新收到的消息
    ///
    /// - Parameter modelArr: 消息集合
    func hanleNewMessage(modelArr: [IMMessageData]) {
        //根据返回的数据模型创建 聊天消息数据模型
        let msgArr = self.createMessageModel(model: modelArr)
        //整合新消息
        self.integrateNewMessages(msessages: msgArr)
    }

    /// 根据数据返回的数据模型，创建消息模型对象
    ///
    /// - Parameter model: 数据模型
    /// - Returns: 所有的消息数据模型
    fileprivate func createMessageModel(model: [IMMessageData]) -> [ChatMessageModel] {
        var msgArr = [ChatMessageModel]()
        for message in model {
            // 1. 计算sessionID
            var sessionID: Int64 = 0
            if message.chattype == 0 {
                sessionID = ((message.sender ?? 0) << 32) + (message.sendpid ?? 0)
            } else if message.chattype == 1 {
                sessionID = message.sessionid ?? 0
            }
            // 2. 创建消息模型对象
            let msgModel = ChatMessageModel()
            msgModel.msg_id = message.clientid ?? 0
            msgModel.session_id = sessionID
            msgModel.kind = message.type ?? 0
            msgModel.sender = message.sender ?? 0
            msgModel.sender_pid = message.sendpid ?? 0
            msgModel.receiver = message.target ?? 0
            msgModel.receiver_pid = message.targetpid ?? 0
            msgModel.content = message.content?.rc4DecodeStr ?? ""
            msgModel.filename = message.filename ?? ""
            msgModel.chat_type = message.chattype ?? 0
            msgModel.notificationID = message.id ?? ""
            msgModel.serverid = message.serverid ?? 0
            msgModel.direction = UserUtil.share.appUserInfo?.uid == message.sender ? ChatDirection.sendToOthers.rawValue : ChatDirection.sendToSelf.rawValue
            msgModel.server_time = message.sendtime ?? ""
            msgModel.client_time = message.sendtime ?? ""
            msgModel.groupPid = message.grouppid ?? 0
            msgModel.send_state = ChatSendStatus.success.rawValue
            msgModel.unread = 1
            msgArr.append(msgModel)
        }
        return msgArr
    }

    /// 整合新消息 包括消息去重 提示音 和 群信息更新
    ///
    /// - Parameter msessages: 新消息集合
    func integrateNewMessages(msessages: [ChatMessageModel]) {
        var msgArr = msessages
        var ring = false
        //这一遍循环为了去重
        for msg in msgArr {
            DatabaseTool.shared.querySingleMessage(sessionID: msg.session_id, chatType: msg.chat_type, msgID: msg.msg_id) { [weak self] message in
                guard let strongSelf = self else {
                    return
                }
                if message != nil {
                    msgArr.remove(msg)
                } else if msg.kind == 5 {
                    msgArr.remove(msg)
                    NetworkUtil
                        .request(
                            target: .confirmAndRemoveUnreadMessage(msg_ids: "[\"\(msg.notificationID)\"]"),
                            success: { _ in
                            }) { error in
                            dPrint(error)
                        }
                    let gid = msg.session_id >> 32
                    DatabaseTool.shared.updateChatGroupInfo(gid: gid, pid: msg.groupPid, immediate: true)
                } else {
                    msg.otherNewMsg = true
                }
                if msg.session_id == msessages.last?.session_id && msg.msg_id == msessages.last?.msg_id {
                    DatabaseTool.shared.insertMessages(with: msgArr)
                    // 当有新消息，并且当前sessionID为空的时候播放音效  chatMessageList也来设置 sessionID
                    for msgModel in msgArr where msgModel.session_id != strongSelf.currentSessionID {
                        ring = true
                    }
                    strongSelf.isNeedSound && ring ? AudioServicesPlaySystemSound(1_007) : nil
                }
            }
        }
    }
}

// MARK: - 长连
extension IMService {
    /// 根据推送ID添加消息
    ///
    /// - Parameters:
    ///   - notificationID: 推送ID
    ///   - inAction: 是否需要进入该聊天页
    //    func addMessageByID(notificationID:String,inAction:Bool){
    //        requestUnreceiptMessage()
    //        NetworkUtil.request(target: .findMessageById(id: notificationID), success: { [weak self] (json) in
    //            let model = NotificationSingleMessageModel.deserialize(from: json)?.data
    //            let messageModel = IMMessageData.deserialize(from:  model?.message_info)
    //            messageModel?.id = model?.id
    //            guard let safeModel = model,let safeMessage = messageModel,messageModel?.clientid != nil else { return }
    //            // 处理消息添加到数据库
    //            IMService.shared.hanleNewMessage(modelArr: [safeMessage])
    //            // 确认收到了消息
    //            if !DatabaseTool.shared.isMessageReceipt(notifyID: safeModel.id ?? "") {// 如果消息没确认，再确认
    //                NetworkUtil.request(target: .confirmReceivedOneMessage(msg_id: safeModel.id ?? ""), success: {  (json) in
    //                    DatabaseTool.shared.modifyReceiptState(notificationID: safeModel.id ?? "", state: 1)
    //                }) { (error) in
    //                    dPrint(error)
    //                }
    //            }
    //            if inAction{
    //                let chatMessageModelArr = self?.createMessageModel(model: [safeMessage])
    //                if chatMessageModelArr?.count > 0,let model = chatMessageModelArr?.first{
    //                    self?.tapInactiveNotification(messageModel: model)
    //                }
    //            }
    //        }) { (error) in
    //            dPrint(error)
    //        }
    //    }
    /// 点击进入聊天页
    func tapInactiveNotification(notificationID: String) {
        DatabaseTool.shared.isNotificationExist(notificationID: notificationID) { [weak self] notificationData in
            //1.1 通知存在
            if notificationData != nil {
                self?.handleNewNotification(notificationData: notificationData)
            } else {//1.2 通知不存在
                DatabaseTool.shared.isMessageExsist(notificationID: notificationID, finish: { messageModel in
                    guard let safeModel = messageModel else {
                        HUDUtil.debugMsg(msg: "找不到对应的通知", type: .error)
                        return
                    }
                    // 找到该会话
                    DatabaseTool.shared.querySingleSession(sessionID: safeModel.session_id, chatType: safeModel.chat_type) { sessionModel in
                        if sessionModel == nil { return }
                        // 如果当前没在对应的聊天页，再进入该聊天页
                        if self?.currentSessionID == nil {
                            PageRouter.shared.router(to: PageRouter.RouterPageType.chatPage(mdoel: sessionModel!))
                        }
                    }
                })
            }
        }
    }

    private func handleNewNotification(notificationData: NotificationMessageData?) {
        //2.1 通知类型为空，提示然后退出
        guard let actionType = NotificationActionType(rawValue: notificationData?.action ?? 0) else {
            HUDUtil.debugMsg(msg: "通知类型为空", type: .error)
            return
        }
        // 2.2 根据类型来跳转到对应的位置
        switch  actionType {
        case .likeInvitation:
            guard let topic = TopicData.deserialize(from: notificationData?.message_info) else {
                return
            }
            PageRouter.shared.router(to: .articelDetail(model: topic, cell: nil))
        case .likeComment, .comment, .reply:
            let infoDic = JSON(parseJSON: notificationData?.message_info ?? "").dictionary
            // 帖子数据
            let invitationDic = infoDic?["invitation"]?.dictionaryObject
            guard let topicData = TopicData.deserialize(from: invitationDic) else {
                return
            }
            // 评论数据
            guard let replyData = ReplyData.deserialize(from: notificationData?.message_info ?? "") else {
                return
            }
            let parentReplyDic = infoDic?["parent"]?.dictionaryObject
            if let parentReplyData = ReplyData.deserialize(from: parentReplyDic) {
                parentReplyData.reply = [replyData]
                PageRouter.shared.router(to: .articelAndComment(articleModel: topicData, replyModel: parentReplyData))
            } else {
                PageRouter.shared.router(to: .articelAndComment(articleModel: topicData, replyModel: replyData))
            }
        case .applyForFriend:
            PageRouter.shared.router(to: .frientApply)
        case .agreeToFriend, .newFriend, .attention:
            guard let userInfo = UserInfoData.deserialize(from: notificationData?.message_info) else {
                return
            }
            PageRouter.shared.router(to: .personalCenter(model: userInfo))
        case .notice:
            guard let noticeData = NoticeData.deserialize(from: notificationData?.message_info) else {
                return
            }
            var params = [String: Any]()
            let topic = TopicData()
            topic.id = noticeData.invitation_id
            topic.group_pid = noticeData.pid
            params[TopicData.getClassName] = topic
            params["hideModule"] = Comment.getClassName
            PageRouter.shared.router(to: PageRouter.RouterPageType.articelParams(params: params))
        default:
            HUDUtil.debugMsg(msg: "消息处理异常", type: .error)
        }
    }

    /// 标记会话的消息为已读
    ///
    /// - Parameter sessionID: 会话ID
    func setSessionMessagesRead(sessionID: Int64, chatType: Int, finish: (() -> Void)? = nil) {
        DatabaseTool.shared.getUnreadMessages(sessionID: sessionID, chatType: chatType) { messageArr in
            var ids = messageArr?.compactMap { model -> String? in
                model.notificationID
            } ?? []
            ids.removeAll("")
            if ids.count == 0 {
                finish?()
                return
            }
            let idStr = JSON(ids).rawString()?.replacingOccurrences(of: "\n", with: "") ?? ""
            if idStr == "[]" {
                finish?()
                return
            }
            NetworkUtil.request(
                target: .confirmAndRemoveUnreadMessage(msg_ids: idStr),
                success: { _ in
                    DatabaseTool.shared.modifyUnreadState(with: sessionID, chatType: chatType, unreadNum: 0, reset: true, updateUI: true)
                    for id in ids {
                        DatabaseTool.shared.modifyUnreadMessageState(with: id, state: 0)
                    }
                    finish?()
                }) { error in
                dPrint(error)
            }
        }
    }

    /// 设置最后一条别人发的消息未读
    ///
    /// - Parameter sessionModel: 会话模型
    ///   - state: 0 已读 1 未读
    func setLastMessageUnreadState(sessionModel: ChatSessionModel) {
        DatabaseTool.shared.querySingleMessage(sessionID: sessionModel.session_id, chatType: sessionModel.chat_type, msgID: sessionModel.last_msg_id, pickOthers: true) { message in
            guard let id = message?.notificationID else {
                return
            }
            NetworkUtil.request(
                target: .addUnreadMessage(msg_id: id),
                success: { _ in
                    DatabaseTool.shared.modifyUnreadMessageState(with: id, state: 1)
                }) { error in
                dPrint(error)
            }
        }
    }

    /// 跟服务器建立连接
    ///
    /// - Parameter token: apns推送token
    func connectToServer(token: String) {
        //获取设备ID
        var uuid =  ""
        if let safeID = keychain["deviceuuid"] {
            uuid = safeID
        } else {
            keychain["deviceuuid"] = UIDevice.current.identifierForVendor?.uuidString ?? ""
            uuid = UIDevice.current.identifierForVendor?.uuidString ?? ""
        }
        dPrint("手机启动UUID:\(uuid)")
        let deviceName = DeviceTool.deviceName
        dPrint("devicetoken为：\(token)")
        //把token发送给后台
        NetworkUtil.request(target: .getKey(device_name: deviceName, device_id: uuid, token: token, develop: 1), success: { [weak self] json in
            let code = JSON(parseJSON: json ?? "")["code"].stringValue
            if code == "0" {
                self?.startService(serviceType: .push)
            } else {
                self?.startService(serviceType: .polling)
            }
        }) { error in
            //            self?.startService(serviceType: .polling)
            dPrint(error)
        }
    }
    /// 开启推送服务
    func startPushService() {
        self.requestOfflineMessage()
        self.requestUnreceiptMessage()
        self.reSendingMessage()
    }

    /// 拉离线消息
    func requestOfflineMessage() {
        NetworkUtil
            .request(
                target: .getOfflineMessage,
                success: { [weak self] json in
                    guard let safeJSON = json else {
                        return
                    }
                    self?.hanleUnreceiptMessage(json: safeJSON, type: .offline)
                }
            ) { error in
                dPrint(error)
            }
    }

    /// 拉未被确认的消息
    func requestUnreceiptMessage() {
        guard self.serviceType == .push else {
            return
        }
        NetworkUtil
            .request(
                target: .selectWaitMessageByUid,
                success: { [weak self] json in
                    guard let safeJSON = json else {
                        return
                    }
                    self?.hanleUnreceiptMessage(json: safeJSON, type: .online)
                    if let id = self?.notificationID {
                        self?.tapInactiveNotification(notificationID: id)
                        self?.notificationID = nil
                    }
                }
            ) { error in
                dPrint(error)
            }
    }

    /// 处理未确认消息
    ///
    /// - Parameter json: json
    func hanleUnreceiptMessage(json: String, type: ReceiveMessageType) {
        // 1. 定义存储变量
        var notificationArr = [NotificationMessageData]() // 存放除了聊天的通知
        var notificationIDArr = [String]() // 存放除聊天的通知ID，用于确认已读
        var confirmIDArr = [String]() // 存放需要确认的通知id
        // 2. 获取所有消息集合
        let modelArr = NotificationMessageModel.deserialize(from: json)?.data
        guard let safeArr = modelArr  else {
            return
        }
        // 3. 处理消息，保存需要确认接收和确认已读的消息，返回所有通知的消息集合
        let messageArr = safeArr.compactMap({ data -> IMMessageData? in
            if let id = data.id {
                confirmIDArr.append(id)
            }
            if data.action != NotificationActionType.personalChat.rawValue && data.action != NotificationActionType.groupChat.rawValue {
                notificationArr.append(data)
                if let id = data.id {
                    notificationIDArr.append(id)
                }
                return nil
            }
            let model = IMMessageData.deserialize(from: data.message_info)
            model?.id = data.id
            return model
        })
        // 4. 将通知添加到数据库
        if notificationArr.count != 0 {
            // 如果是公告，发送通知刷新
            for notification in notificationArr {
                if notification.action == 1 || notification.action == 56 {
                    NotificationCenter.default.post(name: Notification.Name("noticeRefresh"), object: nil)
                    break
                }
            }
            // 通知添加到数据库
            DatabaseTool.shared.insertNotification(with: notificationArr)
        }
        // 5. 聊天消息添加到数据库
        if messageArr.count != 0 {
            self.hanleNewMessage(modelArr: messageArr)
        }
        // 6. 确认消息
        //        if type == .offline {
        //            let messageIDArr = safeArr.compactMap({ data -> String? in
        //                data.id
        //            })
        //            let idStr = JSON(messageIDArr).rawString()?.replacingOccurrences(of: "\n", with: "") ?? ""
        //            if idStr == "[]" { return }
        //            NetworkUtil.request(target: .confirmReceivedOffLineMessage(msg_ids: idStr), success: { _ in
        //                for id in messageIDArr {
        //                    DatabaseTool.shared.modifyReceiptState(notificationID: id, state: 1)
        //                }
        //            }) { error in
        //                dPrint(error)
        //            }
        //        } else {
        let setReadIDStr = JSON(notificationIDArr).rawString()?.replacingOccurrences(of: "\n", with: "") ?? ""
        let confirmIDStr = JSON(confirmIDArr).rawString()?.replacingOccurrences(of: "\n", with: "") ?? ""
        let confirmService = type == .offline ? NetworkService.confirmReceivedWaitMessage(msg_ids: confirmIDStr) : NetworkService.confirmReceivedOffLineMessage(msg_ids: confirmIDStr)
        if confirmIDStr != "[]" {
            NetworkUtil
                .request(
                    target: confirmService,
                    success: { json in
                        dPrint(json ?? "")
                        if setReadIDStr != "[]" {
                            NetworkUtil
                                .request(
                                    target: .confirmAndRemoveUnreadMessage(msg_ids: setReadIDStr),
                                    success: { json in
                                        dPrint(json ?? "")
                                    }) { error in
                                    dPrint(error)
                                }
                        }
                    }) { error in
                    dPrint(error)
                }
        }
        //        }
    }

    /// 创建聊天会话
    ///
    ///   - Parameters:
    ///   - ownUid: 自己的uid
    ///   - ownPid: 自己的pid
    ///   - otherUid: 对方的uid
    ///   - OtherPid: 对方的pid
    /// - Returns: 会话模型
    func createChatSession(ownUid: Int64, ownPid: Int64, otherUid: Int64, otherPid: Int64) -> ChatSessionModel {
        let ssessionID: Int64 = otherUid << 32 + otherPid

        //        if !DatabaseTool.shared.isSessionExist(sessionID: ssessionID) {
        //            let chatTimeModel = ChatMessageModel.init()
        //            chatTimeModel.kind = ChatMessageType.time.rawValue
        //            chatTimeModel.content = Date().chatTimeString
        //            chatTimeModel.session_id = Int64(ssessionID)
        //            chatTimeModel.sender = selfUid
        //            chatTimeModel.receiver = othersUid
        //            chatTimeModel.sender_pid = selfPid
        //            chatTimeModel.receiver_pid = othersPid
        //            chatTimeModel.send_state = ChatSendStatus.success.rawValue
        ////            chatTimeModel.kind = ChatMessageType.time.rawValue
        ////            DatabaseTool.shared.insertMessages(with: [chatTimeModel])
        //            let _ = DatabaseTool.shared.createChatSession(by: chatTimeModel)
        //        }
        //        let vc = ChatPageList.init()
        let sessionModel = ChatSessionModel()
        sessionModel.session_id = Int64(ssessionID)
        sessionModel.sender = ownUid
        sessionModel.receiver = otherUid
        sessionModel.sender_pid = ownPid
        sessionModel.receiver_pid = otherPid
        //        sessionModel.nickname = userInfo?.zh_name ?? ""
        sessionModel.chat_type = 0
        return sessionModel
    }
}
// MARK: - 轮询
extension IMService {
    /// 开启轮询
    func startPollingSerice() {
        timer.start()
        // 重发旧消息
        self.reSendingMessage()
    }

    /// 重新开启轮询
    func restartPolling() {
        timer.start()
        self.reSendingMessage()
    }

    /// 暂停轮询
    func pausePolling() {
        timer.suspend()
    }
    /// 获取最新的消息
    @objc fileprivate func requestMessage() {
        guard UserUtil.isValid() else {
            PageRouter.shared.router(to: PageRouter.RouterPageType.login)
            self.pausePolling()
            return
        }
        //    获取最新消息的ID
        DatabaseTool.shared.getLastServerID { [weak self] id in
            self?.lastID = id > self?.lastID ? id : self?.lastID ?? 0
            saveUserDefaults(key: kLastMessageID, value: self?.lastID)
            //    发送请求
            NetworkUtil.request(target: .getNewMessage(last_id: (self?.lastID ?? 0)), success: { [weak self] data in
                //1. 解析数据
                let modelArr = IMMessageModel.deserialize(from: data)?.data ?? []
                //2. 处理数据
                self?.hanleNewMessage(modelArr: modelArr)
                }, failure: { error in
                    dPrint(error)
            })
        }
    }

    /// 设置角标
    func resetBadgeNum() {
        DatabaseTool.shared.queryUnRemindNum { badgeNum in
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = badgeNum
            }
        }
    }
}

// MARK: - 重发消息
extension IMService {
    func reSendingMessage() {
        DatabaseTool.shared.queryUnSendMessageList { messageArr in
            for model in messageArr {
                ChatHelper.reSendMsg(type: ChatMessageType(rawValue: model.kind ) ?? .text, model: model)
            }
        }
    }
}
