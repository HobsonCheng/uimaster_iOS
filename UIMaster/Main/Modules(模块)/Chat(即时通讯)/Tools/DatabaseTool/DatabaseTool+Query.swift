//
//  DatabaseTool+Query.swift
//  UIMaster
//
//  Created by hobson on 2019/4/13.
//  Copyright © 2019 one2much. All rights reserved.
//

import FMDB
import Foundation

// MARK: - query
extension DatabaseTool {
    /// 根据通知类型查询通知
    ///
    /// - Parameters:
    ///   - action: 通知类型
    ///   - database: 数据库对象
    ///   - finish: 完成后的回调
    func queryNotification(action: NotificationActionType, database: FMDatabase? = nil, finish: @escaping (([NotificationMessageData]) -> Void)) {
        dispatchDatabaseSafelyQueue(database: database) { database in
            do {
                let sql = "SELECT * FROM notification WHERE action = \(action.rawValue)"
                let result = try database.executeQuery(sql, values: nil)
                var arr = [NotificationMessageData]()
                while result.next() {
                    guard let notification = NotificationMessageData.deserialize(from: result.resultDictionary as NSDictionary?) else { continue }
                    arr.append(notification)
                }
                finish(arr)
            } catch {
                finish([])
                dPrint("修改未读标识失败: \(error.localizedDescription)")
            }
        }
    }

    /// 通知是否存在
    ///
    /// - Parameters:
    ///   - database: 数据库对象
    ///   - finish: 完成后的回调
    func isNotificationExist(notificationID id: String, database: FMDatabase? = nil, finish: @escaping ((NotificationMessageData?) -> Void)) {
        dispatchDatabaseSafelyQueue(database: database) { database in
            do {
                let sql = "SELECT * FROM notification WHERE id = '\(id)'"
                let result = try database.executeQuery(sql, values: nil)
                if result.next() {
                    let notification = NotificationMessageData.deserialize(from: result.resultDictionary as NSDictionary?)
                    finish(notification)
                    return
                }
                finish(nil)
            } catch {
                finish(nil)
                dPrint("修改未读标识失败: \(error.localizedDescription)")
            }
        }
    }

    /// 获取所有会话数据
    ///
    /// - Returns: 返回所有会话的集合
    func querySessionList(database: FMDatabase? = nil, finish: @escaping (([ChatSessionModel]) -> Void)) {
        dispatchDatabaseSafelyQueue(database: database) { [weak self] database in
            do {
                let sql = "SELECT * FROM session ORDER BY update_time DESC"
                let result = try database.executeQuery(sql, values: nil)
                var sessionArr = [ChatSessionModel]()
                var tempArr = [ChatSessionModel]()
                while result.next() {
                    let session = ChatSessionModel.deserialize(from: result.resultDictionary as NSDictionary?)
                    if let safeSession = session {
                        sessionArr.append(safeSession)
                    }
                }
                if sessionArr.isEmpty { finish(sessionArr) }
                for safeSession in sessionArr {
                    safeSession.last_content = safeSession.last_content.base64DecodeStr
                    safeSession.draft_content = safeSession.draft_content.base64DecodeStr
                    if safeSession.chat_type == 0 {
                        self?.queryContactsInfo(database: database, uid: safeSession.receiver, pid: safeSession.receiver_pid, finish: { userInfo in
                            safeSession.avatar = userInfo?.head_portrait ?? ""
                            safeSession.nickname = userInfo?.zh_name ?? ""
                            tempArr.append(safeSession)
                            if tempArr.count == sessionArr.count {
                                finish(sessionArr)
                            }
                        })
                    } else {
                        let sid = (safeSession.session_id - safeSession.groupPid) >> 32
                        self?.queryChatGroupInfo(database: database, gid: sid, pid: safeSession.groupPid, finish: { chatGroup in
                            safeSession.avatar = chatGroup?.icon ?? ""
                            safeSession.nickname = chatGroup?.name ?? ""
                            tempArr.append(safeSession)
                            if tempArr.count == sessionArr.count {
                                finish(sessionArr)
                            }
                        })
                    }
                }
            } catch {
                finish([ChatSessionModel]())
                dPrint("获取消息失败: \(error.localizedDescription)")
            }
        }
    }

    /// 获取单条会话数据
    ///
    /// - Parameters:
    ///   - sessionID: 会话id
    /// - Returns: 消息模型
    func querySingleSession(database: FMDatabase? = nil, sessionID: Int64, chatType: Int, finish: @escaping ((ChatSessionModel?) -> Void)) {
        dispatchDatabaseSafelyQueue(database: database) { [weak self] database in
            do {
                let sql = "SELECT * FROM session WHERE session_id=\(sessionID) AND chat_type = \(chatType)"
                let result = try database.executeQuery(sql, values: nil)
                if result.next() {
                    let session = ChatSessionModel.deserialize(from: result.resultDictionary as NSDictionary?)
                    result.close()
                    session?.last_content = session?.last_content.base64DecodeStr ?? ""
                    session?.draft_content = session?.draft_content.base64DecodeStr ?? ""
                    if session?.chat_type == 0 {
                        self?.queryContactsInfo(database: database, uid: session?.receiver ?? 0, pid: session?.receiver_pid ?? 0, finish: { userInfo in
                            session?.avatar = userInfo?.head_portrait ?? ""
                            session?.nickname = userInfo?.zh_name ?? ""
                            finish(session)
                        })
                    } else {
                        let gid = ((session?.session_id ?? 0) - (session?.groupPid ?? 0)) >> 32
                        self?.queryChatGroupInfo(database: database, gid: gid, pid: session?.groupPid ?? 0, finish: { chatGroup in
                            session?.avatar = chatGroup?.icon ?? ""
                            session?.nickname = chatGroup?.name ?? ""
                            finish(session)
                        })
                    }
                } else {
                    finish(nil)
                }
            } catch {
                finish(nil)
                dPrint("修改未读标识失败: \(error.localizedDescription)")
            }
        }
    }

    /// 获取单条数据
    ///
    /// - Parameters:
    ///   - sessionID: 会话id
    ///   - msgID: 消息id
    /// - Returns: 消息模型
    func querySingleMessage(database: FMDatabase? = nil, sessionID: Int64, chatType: Int, msgID: Int64, pickOthers: Bool = false, finish: @escaping ((ChatMessageModel?) -> Void)) {
        dispatchDatabaseSafelyQueue(database: database) { [weak self] database in
            do {
                let sql = "SELECT * FROM message WHERE session_id = \(sessionID) AND chat_type = \(chatType) " + (pickOthers ? " AND direction = \(ChatDirection.sendToSelf.rawValue)" : " AND msg_id=\(msgID)")
                let result = try database.executeQuery(sql, values: nil)
                if result.next() {
                    let message = ChatMessageModel.deserialize(from: result.resultDictionary as NSDictionary?)
                    result.close()
                    message?.content = message?.content.base64DecodeStr ?? ""
                    message?.filename = message?.filename.base64DecodeStr ?? ""
                    message?.localOriginalStoreName = message?.localOriginalStoreName.base64DecodeStr ?? ""
                    message?.localStoreName = message?.localStoreName.base64DecodeStr ?? ""
                    message?.resource = message?.resource.base64DecodeStr ?? ""
                    self?.queryContactsInfo(database: database, uid: message?.receiver ?? 0, pid: message?.receiver_pid ?? 0, finish: { userInfo in
                        message?.avatar = userInfo?.head_portrait ?? ""
                        message?.nickname = userInfo?.zh_name ?? ""
                        finish(message)
                    })
                } else {
                    finish(nil)
                }
            } catch {
                finish(nil)
                dPrint("修改未读标识失败: \(error.localizedDescription)")
            }
        }
    }

    /// 个人信息是否存在
    ///
    /// - Parameters:
    ///   - uid: 用户的uid
    ///   - pid: 用户的pid
    ///   - type: 类型
    /// - Returns: 是否存在
    func isContactsInfoExsist(database: FMDatabase? = nil, uid: Int64, pid: Int64, finish: @escaping ((Bool) -> Void)) {
        dispatchDatabaseSafelyQueue(database: database) { database in
            do {
                let sql = "SELECT * FROM contacts WHERE uid=\(uid) AND pid=\(pid)"
                let result = try database.executeQuery(sql, values: nil)
                if result.next() {
                    finish(true)
                    result.close()
                } else {
                    finish(false)
                }
            } catch {
                finish(false)
                dPrint("查找联系人信息失败: \(error.localizedDescription)")
            }
        }
    }

    /// 是否存在
    ///
    /// - Parameters:
    ///   - notificationID: 通知id
    func isMessageExsist(database: FMDatabase? = nil, notificationID: String, finish: @escaping ((ChatMessageModel?) -> Void)) {
        dispatchDatabaseSafelyQueue(database: database) { database in
            do {
                let sql = "SELECT * FROM message WHERE notificationID = '\(notificationID)' "
                let result = try database.executeQuery(sql, values: nil)
                if result.next() {
                    let message = ChatMessageModel.deserialize(from: result.resultDictionary as NSDictionary?)
                    message?.content = message?.content.base64DecodeStr ?? ""
                    message?.filename = message?.filename.base64DecodeStr ?? ""
                    message?.localOriginalStoreName = message?.localOriginalStoreName.base64DecodeStr ?? ""
                    message?.localStoreName = message?.localStoreName.base64DecodeStr ?? ""
                    message?.resource = message?.resource.base64DecodeStr ?? ""
                    message?.avatar = message?.avatar.base64DecodeStr ?? ""
                    message?.nickname = message?.nickname.base64DecodeStr ?? ""
                    finish(message)
                    result.close()
                } else {
                    finish(nil)
                }
            } catch {
                finish(nil)
                dPrint("查找联系人信息失败: \(error.localizedDescription)")
            }
        }
    }

    /// 获取会话的未读消息
    ///
    /// - Parameters:
    ///   - sessionID: 会话id
    func getUnreadMessages(database: FMDatabase? = nil, sessionID: Int64?, chatType: Int?, finish: @escaping (([ChatMessageModel]?) -> Void)) {
        dispatchDatabaseSafelyQueue(database: database) { database in
            do {
                var messageArr: [ChatMessageModel]? = [ChatMessageModel]()
                var sql = ""
                if let safeID = sessionID, let type = chatType {
                    sql = "SELECT * FROM message WHERE session_id = \(safeID) AND unread=1 AND chat_type = \(type)"
                } else {
                    sql = "SELECT * FROM message WHERE unread = 1"
                }
                let result = try database.executeQuery(sql, values: nil)
                while result.next() {
                    guard let model = ChatMessageModel.deserialize(from: result.resultDictionary as NSDictionary?) else { continue }
                    model.content = model.content.base64DecodeStr
                    model.filename = model.filename.base64DecodeStr
                    model.localOriginalStoreName = model.localOriginalStoreName.base64DecodeStr
                    model.localStoreName = model.localStoreName.base64DecodeStr
                    model.resource = model.resource.base64DecodeStr
                    model.avatar = model.avatar.base64DecodeStr
                    model.nickname = model.nickname.base64DecodeStr
                    messageArr?.append(model)
                }
                finish(messageArr)
            } catch {
                finish([ChatMessageModel]())
                dPrint("查找联系人信息失败: \(error.localizedDescription)")
            }
        }
    }

    /// 获取用户信息
    ///
    /// - Parameters:
    ///   - uid: 用户的uid
    ///   - pid: 用户的pid
    ///   - type: 类型
    /// - Returns: 用户数据
    func queryContactsInfo(database: FMDatabase? = nil, uid: Int64, pid: Int64, finish: @escaping ((UserInfoData?) -> Void)) {
        dispatchDatabaseSafelyQueue(database: database) {  database in
            do {
                let sql = "SELECT * FROM contacts WHERE uid=\(uid) AND pid=\(pid)"
                let result = try database.executeQuery(sql, values: nil)
                let userInfo = UserInfoData()
                if result.next() {
                    userInfo.head_portrait = result.string(forColumn: "avatar")?.base64DecodeStr
                    userInfo.zh_name = result.string(forColumn: "nickname")?.base64DecodeStr
                    userInfo.uid = Int64(result.long(forColumn: "uid"))
                    userInfo.pid = Int64(result.long(forColumn: "pid"))
                    result.close()
                }
                finish(userInfo)
            } catch {
                finish(nil)
                dPrint("修改未读标识失败: \(error.localizedDescription)")
            }
        }
    }

    /// 群组信息是否存在
    ///
    /// - Parameters:
    ///   - gid: 群id
    ///   - pid: 群pid
    /// - Returns: 是否存在
    func isChatGroupInfoExsist(database: FMDatabase? = nil, gid: Int64, pid: Int64, finish: @escaping ((Bool) -> Void)) {
        dispatchDatabaseSafelyQueue(database: database) {  database in
            do {
                let sql = "SELECT * FROM chatGroup WHERE gid=\(gid) AND pid=\(pid)"
                let result = try database.executeQuery(sql, values: nil)
                if result.next() {
                    finish(true)
                    result.close()
                } else {
                    finish(false)
                }
            } catch {
                finish(false)
                dPrint("查找群信息失败: \(error.localizedDescription)")
            }
        }
    }

    /// 获取群信息
    ///
    /// - Parameters:
    ///   - gid: 群id
    ///   - pid: 群pid
    /// - Returns: 群信息
    func queryChatGroupInfo(database: FMDatabase? = nil, gid: Int64, pid: Int64, finish: @escaping ((ChatGroupDetailData?) -> Void)) {
        dispatchDatabaseSafelyQueue(database: database) { database in
            do {
                let sql = "SELECT * FROM chatGroup WHERE gid=\(gid) AND pid=\(pid)"
                let result = try database.executeQuery(sql, values: nil)
                if result.next() {
                    let id = Int64(result.long(forColumn: "gid"))
                    let groupInfo = ChatGroupDetailData.deserialize(from: result.resultDictionary as NSDictionary?)
                    groupInfo?.id = id
                    groupInfo?.name = groupInfo?.name?.base64DecodeStr
                    groupInfo?.background = groupInfo?.background?.base64DecodeStr
                    groupInfo?.icon = groupInfo?.icon?.base64DecodeStr
                    groupInfo?.notice = groupInfo?.notice?.base64DecodeStr
                    finish(groupInfo)
                    result.close()
                } else {
                    finish(nil)
                }
            } catch {
                finish(nil)
                dPrint("修改未读标识失败: \(error.localizedDescription)")
            }
        }
    }

    /// 获取会话里所有的图片
    ///
    /// - Parameter sessionID: 会话ID
    /// - Returns: 所有图片的地址url
    func queryAllPicUrl(database: FMDatabase? = nil, with sessionID: Int64, chatType: Int, finish: @escaping (([(Int64, String, String)]) -> Void)) {
        dispatchDatabaseSafelyQueue(database: database) { database in
            do {
                var picStrArr = [(Int64, String, String)]()
                let sql = "SELECT msg_id,content,localOriginalStoreName FROM message WHERE session_id=\(sessionID) AND kind = 1 AND chat_type = \(chatType) ORDER BY msg_id ASC"
                let result = try database.executeQuery(sql, values: nil)
                while result.next() {
                    let urlStr = result.string(forColumn: "content")?.base64DecodeStr
                    let msgID = Int64(result.long(forColumn: "msg_id"))
                    let originalPic = result.string(forColumn: "localOriginalStoreName")?.base64DecodeStr
                    picStrArr.append((msgID, urlStr ?? "", originalPic ?? ""))
                }
                finish(picStrArr)
            } catch {
                finish([(Int64, String, String)]())
                dPrint("获取图片信息失败: \(error.localizedDescription)")
            }
        }
    }

    /// 会话是否存在
    ///
    /// - Parameter sessionID: 会话ID
    /// - Returns: 会话是否存在
    func isSessionExist(database: FMDatabase? = nil, sessionID: Int64, chatType: Int, finish: @escaping (Bool) -> Void) {
        dispatchDatabaseSafelyQueue(database: database) {  database in
            do {
                let result = try database.executeQuery("SELECT * FROM session  WHERE session_id = \(sessionID) AND chat_type = \(chatType)", values: nil)
                if result.next() {
                    finish(true)
                } else {
                    finish(false)
                }
            } catch {
                finish(false)
                dPrint("判断会话是否存在失败: \(error.localizedDescription)")
            }
        }
    }

    /// 消息是否确认收到
    ///
    /// - Parameter msgID: 通知ID
    /// - Returns: 消息是否确认收到
    func isMessageReceipt(database: FMDatabase? = nil, notifyID: String, finish: @escaping (Bool) -> Void) {
        dispatchDatabaseSafelyQueue(database: database) { database in
            do {
                let result = try database.executeQuery("SELECT receipt FROM message  WHERE notificationID = '\(notifyID)' ", values: nil)
                if result.next() {
                    finish(true)
                } else {
                    finish(false)
                }
            } catch {
                finish(false)
                dPrint("判断消息是否确认收到失败: \(error.localizedDescription)")
            }
        }
    }

    /// 获取最新的消息id
    ///
    /// - Returns: 最新的消息id
    func getLastServerID(database: FMDatabase? = nil, finish: @escaping (Int64) -> Void) {
        dispatchDatabaseSafelyQueue(database: database) { database in
            do {
                let sql = "SELECT serverid FROM message ORDER BY serverid DESC"
                let result = try database.executeQuery(sql, values: nil)
                if result.next() {
                    finish(Int64(result.long(forColumn: "serverid")))
                    result.close()
                } else {
                    finish(0)
                }
            } catch {
                finish(0)
                dPrint("获取最新id失败: \(error.localizedDescription)")
            }
        }
    }
    /// 获取未发送的消息
    ///
    /// - Returns: 未发送消息集合
    func queryUnSendMessageList(database: FMDatabase? = nil, finish: @escaping ([ChatMessageModel]) -> Void) {
        dispatchDatabaseSafelyQueue(database: database) { [weak self] database in
            //        按时间降序，根据分页参数和sessionID取得消息数据
            do {
                let sql = "SELECT * FROM message WHERE send_state = 0"
                let result = try database.executeQuery(sql, values: nil)
                var messageArr = [ChatMessageModel]()
                var tmpArr = [ChatMessageModel]()
                while result.next() {
                    let message = ChatMessageModel.deserialize(from: result.resultDictionary as NSDictionary?)
                    message?.content = message?.content.base64DecodeStr ?? ""
                    message?.filename = message?.filename.base64DecodeStr ?? ""
                    message?.localOriginalStoreName = message?.localOriginalStoreName.base64DecodeStr ?? ""
                    message?.localStoreName = message?.localStoreName.base64DecodeStr ?? ""
                    message?.resource = message?.resource.base64DecodeStr ?? ""
                    if let safeMessage = message {
                        messageArr.append(safeMessage)
                    }
                }
                if messageArr.isEmpty { finish(messageArr) }
                for safeMessage in messageArr {
                    self?.queryContactsInfo(database: database, uid: safeMessage.receiver, pid: safeMessage.receiver_pid, finish: { userInfo in
                        safeMessage.avatar = userInfo?.head_portrait ?? ""
                        safeMessage.nickname = userInfo?.zh_name ?? ""
                        tmpArr.append(safeMessage)
                        if tmpArr.count == messageArr.count {
                            DispatchQueue.main.async {
                                finish(tmpArr)
                            }
                        }
                    })
                }
            } catch {
                finish([ChatMessageModel]())
                dPrint("获取消息失败: \(error.localizedDescription)")
            }
        }
    }

    /// 获取
    func queryUnRemindNum(database: FMDatabase? = nil, finish: @escaping (Int) -> Void) {
        guard UserUtil.isValid() else {
            finish(0)
            return
        }
        dispatchDatabaseSafelyQueue(database: database) { database in
            do {
                let sql = "SELECT unread_remind_num FROM session WHERE unread_remind_num > 0"
                let result = try database.executeQuery(sql, values: nil)
                var totalNum = 0
                while result.next() {
                    totalNum += Int(result.int(forColumn: "unread_remind_num"))
                }
                finish(totalNum)
            } catch {
                finish(0)
                dPrint("获取个数失败: \(error.localizedDescription)")
            }
        }
    }
    /// 获取聊天数据
    ///
    /// - Parameters:
    ///   - sessionID: 会话ID
    ///   - index: 从第几页开始
    ///   - pageing: 取多少数据
    func queryMessageList(database: FMDatabase? = nil, byID sessionID: Int64, chatType: Int, index: Int, pageing: Int, finish: @escaping ([ChatMessageModel]) -> Void) {
        dispatchDatabaseSafelyQueue(database: database) { [weak self] database in
            //        按时间降序，根据分页参数和sessionID取得消息数据
            do {
                let sql = "SELECT * FROM message WHERE session_id=\(sessionID) AND chat_type = \(chatType) ORDER BY msg_id DESC Limit \(index),\(pageing)"
                let result = try database.executeQuery(sql, values: nil)
                var messageArr = [ChatMessageModel]()
                var tmpArr = [ChatMessageModel]()
                while result.next() {
                    let message = ChatMessageModel.deserialize(from: result.resultDictionary as NSDictionary?)
                    if message?.kind == ChatMessageType.interior.rawValue {
                        continue
                    }
                    if let safeMessage = message {
                        messageArr.append(safeMessage)
                    }
                }
                if messageArr.isEmpty {
                    finish(messageArr)
                    return
                }
                for message in messageArr {
                    self?.queryContactsInfo(database: database, uid: message.sender, pid: message.sender_pid, finish: { userInfo in
                        message.avatar = userInfo?.head_portrait ?? ""
                        message.nickname = userInfo?.zh_name ?? ""
                        message.content = message.content.base64DecodeStr
                        message.filename = message.filename.base64DecodeStr
                        message.localStoreName = message.localStoreName.base64DecodeStr
                        message.localOriginalStoreName = message.localOriginalStoreName.base64DecodeStr
                        message.resource = message.resource.base64DecodeStr
                        tmpArr.append(message)
                        if tmpArr.count == messageArr.count {
                            finish(tmpArr)
                        }
                    })
                }
            } catch {
                dPrint("获取消息失败: \(error.localizedDescription)")
                return finish([ChatMessageModel]())
            }
        }
    }
}
