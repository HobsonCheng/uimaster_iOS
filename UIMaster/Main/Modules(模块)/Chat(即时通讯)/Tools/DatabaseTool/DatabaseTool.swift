//
//  DatabaseTool.swift
//  UIMaster
//
//  Created by hobson on 2018/9/21.
//  Copyright © 2018年 one2much. All rights reserved.
//

import FMDB
import KeychainAccess
import UIKit

class DatabaseTool {
    /// 单例
    static let shared = DatabaseTool()

    private init() {
    }

    /// 数据库
    var dbQueue: FMDatabaseQueue?
    /// 钥匙串
    let keychain = Keychain(service: "com.one2much.uuid")
    /// RC4解密Key
    var key: String {
        return (getUserDefaults(key: kRC4Key) as? String) ?? ""
    }
    /// 记录正在请求的个人信息数据
    fileprivate var requestingUserInfo = [(Int64, Int64)]()
    fileprivate var requestingGroupInfo = [(Int64, Int64)]()

    /// 串行队列
    func dispatchDatabaseSafelyQueue(database: FMDatabase? = nil, _ block: @escaping (FMDatabase) -> Void) {
        if let safeDatabase = database {
            block(safeDatabase)
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let dbQueue = self?.dbQueue else {
                    HUDUtil.debugMsg(msg: "数据库初始化异常", type: .error)
                    self?.createUserDatabase()
                    self?.dbQueue?.inDatabase({ database in
                        block(database)
                    })
                    return
                }
                dbQueue.inDatabase({ database in
                    block(database)
                })
            }
        }
    }
}

// MARK: - insert
extension DatabaseTool {
    /// 创建数据库
    ///
    /// - Parameter userID: 用户ID
    func createUserDatabase() {
        //   判断数据库是否存在
        //   获取用户id
        guard UserUtil.isValid() else {
            return
        }
        let id = UserUtil.share.appUserInfo?.uid
        let appID = UserUtil.share.appUserInfo?.pid
        guard let uid = id, let pid = appID else {
            return
        }
        // 文件夹路径
        guard let dirURL = try? FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("com.one2much/YJ_\(pid)_\(uid)") else {
            return
        }
        // 文件路径
        let fileURL = dirURL.appendingPathComponent("uid_\(uid).db")

        // 如果存在，直接打开数据库
        if FileManager.default.fileExists(atPath: fileURL.path) {
            self.dbQueue = FMDatabaseQueue(url: fileURL)
//            self.dbQueue?.inDatabase({ (db) in
//                guard let password = keychain["dbpassword\(pid)_\(uid)"] else{
//                    HUDUtil.msg(msg: "数据库解密失败", type: .error)
//                    return
//                }
//                dPrint(password)
//                let success = db.setKey(password)
//                let result = success ? "成功" : "失败"
//                HUDUtil.debugMsg(msg: "数据库解密\(result)", type: .info)
//            })
        } else {// 如果不存在，创建文件夹
            try? FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
            // 创建文件
            FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
            // 打开数据库
            self.dbQueue = FMDatabaseQueue(url: fileURL)
            // 设置加密
//            let timeStr = Date().description
//            dPrint("加密前：\(timeStr)")
//            let encryptCode = timeStr.MD5Str.sha256Str
//            keychain["dbpassword\(pid)_\(uid)"] = encryptCode
//            dPrint("数据库加密码为：\(encryptCode)")
//            self.dbQueue?.inDatabase({ (db) in
//                let success = db.setKey(encryptCode)
//                let result = success ? "成功" : "失败"
//                HUDUtil.debugMsg(msg: "数据库加密\(result)", type: .info)
//            })
            // 创建通知表
            self.createNotificationTable()
            // 创建Message表
            self.createMessageTable()
            // 创建会话
            self.createSessionTable()
            // 创建联系人表
            self.createContactTable()
            // 创建聊天群表
            self.createChatGroupTable()
        }
    }

    // 创建通知表
    fileprivate func createNotificationTable(database: FMDatabase? = nil) {
        dispatchDatabaseSafelyQueue(database: database) { database in
            do {
                var sql = """
                          CREATE TABLE IF NOT EXISTS `notification` (
                          `mid` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT ,
                          `id` varchar(4096) NOT NULL DEFAULT '',
                          `pid` INTEGER NOT NULL DEFAULT '0',
                          `level` INTEGER NOT NULL DEFAULT '0',
                          `sender` INTEGER NOT NULL DEFAULT '0',
                          `sender_pid` INTEGER NOT NULL DEFAULT '0',
                          `target` INTEGER NOT NULL DEFAULT '0',
                          `target_pid` INTEGER NOT NULL DEFAULT '0',
                          `target_type` INTEGER NOT NULL DEFAULT '0',
                          `content` varchar(4096) NOT NULL DEFAULT '',
                          `action` INTEGER NOT NULL DEFAULT '0',
                          `action_pid` INTEGER NOT NULL DEFAULT '0',
                          `action_object` varchar(4096) NOT NULL DEFAULT '',
                          `action_object_type` INTEGER NOT NULL DEFAULT '0',
                          `add_time` datetime NOT NULL,
                          `expired_time` datetime NOT NULL,
                          `send_count` INTEGER NOT NULL DEFAULT '0',
                          `message_info` varchar(4096) NOT NULL DEFAULT '',
                          `unread` INTEGER NOT NULL DEFAULT '1'
                          );
                          """
                try database.executeUpdate(sql, values: nil)
                //            2.3创建索引
                sql = "CREATE INDEX \"main\".\"action_type\" ON \"notification\" (\"action\" DESC)"
                try database.executeUpdate(sql, values: nil)
            } catch {
                HUDUtil.debugMsg(msg: "测试：添加notification表失败", type: .error)
                dPrint("添加notification表失败: \(error.localizedDescription)")
            }
        }
    }

    // 创建Message表
    fileprivate func createMessageTable(database: FMDatabase? = nil) {
        dispatchDatabaseSafelyQueue(database: database) { database in
            do {
                var sql = """
                          CREATE TABLE IF NOT EXISTS `message` (
                          `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT ,
                          `msg_id` BIGINT NOT NULL ,
                          `groupPid` BIGINT NOT NULL ,
                          `filename` varchar(4096) NOT NULL DEFAULT '',
                          `session_id` BIGINT NOT NULL ,
                          `sender` BIGINT NOT NULL ,
                          `sender_pid` BIGINT NOT NULL,
                          `receiver` BIGINT NOT NULL ,
                          `receiver_pid` BIGINT NOT NULL,
                          `chat_type` INTEGER NOT NULL DEFAULT '0',
                          `kind` INTEGER NOT NULL DEFAULT '0',
                          `serverid` BIGINT NOT NULL DEFAULT '0',
                          `direction` INTEGER NOT NULL ,
                          `unread` INTEGER NOT NULL DEFAULT '1',
                          `played` INTEGER NOT NULL DEFAULT '0',
                          `send_state` INTEGER NOT NULL DEFAULT '1',
                          `category` INTEGER NOT NULL DEFAULT '0',
                          `online` INTEGER NOT NULL DEFAULT '0',
                          `msg_users` varchar(4096) NOT NULL DEFAULT '',
                          `content` varchar(4096) NOT NULL ,
                          `notificationID` varchar(4096) NOT NULL DEFAULT '',
                          `resource` varchar(255) NOT NULL DEFAULT '',
                          `client_time` datetime NOT NULL ,
                          `server_time` datetime NOT NULL ,
                          `receipt` INTEGER NOT NULL DEFAULT '0',
                          `localStoreName` varchar(4096) DEFAULT '',
                          `localOriginalStoreName` varchar(4096) DEFAULT '',
                          `imageWidth` INTEGER DEFAULT 0,
                          `imageHeight` INTEGER DEFAULT 0
                          );
                          """
                try database.executeUpdate(sql, values: nil)
                //            2.3创建索引
                sql = "CREATE INDEX \"main\".\"send\" ON \"message\" (\"send_state\" DESC)"
                try database.executeUpdate(sql, values: nil)
                //            2.4创建唯一键
                sql = "CREATE UNIQUE INDEX \"main\".\"sessionMsg\" ON \"message\" (\"session_id\" ASC,\"msg_id\" DESC)"
                try database.executeUpdate(sql, values: nil)
            } catch {
                HUDUtil.debugMsg(msg: "测试：添加Message表失败", type: .error)
                dPrint("添加Message表失败: \(error.localizedDescription)")
            }
        }
    }

    //创建Session表
    fileprivate func createSessionTable(database: FMDatabase? = nil) {
        dispatchDatabaseSafelyQueue(database: database) { database in
            do {
                var sql = """
                          CREATE TABLE IF NOT EXISTS `session` (
                          `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT ,
                          `groupPid` BIGINT NOT NULL DEFAULT '0',
                          `session_id` BIGINT NOT NULL ,
                          `chat_type` INTEGER NOT NULL DEFAULT '0' ,
                          `msg_kind` INTEGER NOT NULL DEFAULT '0',
                          `sender` BIGINT NOT NULL ,
                          `sender_pid` BIGINT NOT NULL,
                          `receiver` BIGINT NOT NULL ,
                          `receiver_pid` BIGINT NOT NULL,
                          `msg_direction` INTEGER NOT NULL ,
                          `unread_num` INTEGER NOT NULL DEFAULT '0' ,
                          `unread_remind_num` INTEGER NOT NULL DEFAULT '0',
                          `is_top` INTEGER NOT NULL DEFAULT '0' ,
                          `remind` INTEGER NOT NULL DEFAULT '1' ,
                          `draft_content` varchar(2048) NOT NULL DEFAULT '',
                          `update_time` datetime NOT NULL ,
                          `add_time` datetime NOT NULL ,
                          `last_msg_id` INTEGER NOT NULL ,
                          `last_content` varchar(4096) NOT NULL ,
                          `last_send_state` INTEGER NOT NULL DEFAULT '1',
                          `nickname` varchar(4096) NOT NULL DEFAULT '',
                          `avatar` varchar(4096) NOT NULL DEFAULT ''
                          )
                          """
                try database.executeUpdate(sql, values: nil)
                //            2.3创建索引
                sql = "CREATE INDEX \"main\".\"list\" ON \"session\" (\"update_time\" DESC)"
                try database.executeUpdate(sql, values: nil)
                //            2.4创建唯一键
                sql = "CREATE UNIQUE INDEX \"main\".\"id\" ON \"session\" (\"session_id\",\"chat_type\")"
                try database.executeUpdate(sql, values: nil)
            } catch {
                HUDUtil.debugMsg(msg: "测试：添加Session表失败", type: .error)
                dPrint("添加Session表失败: \(error.localizedDescription)")
            }
        }
    }

    /// 创建联系人表
    fileprivate func createContactTable(database: FMDatabase? = nil) {
        dispatchDatabaseSafelyQueue(database: database) { database in
            do {
                var sql = """
                          CREATE TABLE IF NOT EXISTS `contacts` (
                          `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT ,
                          `uid` BIGINT NOT NULL,
                          `pid` BIGINT NOT NULL,
                          `nickname` varchar(4096) NOT NULL DEFAULT '',
                          `avatar` varchar(4096) NOT NULL DEFAULT '',
                          `chat_type` INTEGER NOT NULL
                          );
                          """
                try database.executeUpdate(sql, values: nil)
                // 创建索引
                sql = "CREATE INDEX \"main\".\"user\" ON \"contacts\" (\"uid\",\"pid\" )"
                try database.executeUpdate(sql, values: nil)
            } catch {
                dPrint("添加联系人信息表失败: \(error.localizedDescription)")
            }
        }
    }

    /// 创建聊天群
    fileprivate func createChatGroupTable(database: FMDatabase? = nil) {
        dispatchDatabaseSafelyQueue(database: database) { database in
            do {
                var sql = """
                          CREATE TABLE IF NOT EXISTS `chatGroup` (
                          `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT ,
                          `gid` BIGINT NOT NULL,
                          `pid` BIGINT NOT NULL,
                          `avatar` varchar(4096) NOT NULL DEFAULT '',
                          `join_type` INTEGER,
                          `icon` varchar(4096) NOT NULL DEFAULT '',
                          `nickname_display` INTEGER,
                          `nickname_visual` INTEGER,
                          `background` varchar(4096) NOT NULL DEFAULT '',
                          `name` varchar(4096) NOT NULL DEFAULT '',
                          `can_share` INTEGER,
                          `add_time` datetime,
                          `update_time` datetime,
                          `status` INTEGER,
                          `notice` varchar(4096) NOT NULL DEFAULT '',
                          `banned` INTEGER,
                          `set_top` INTEGER,
                          `creator_id` INTEGER
                          );
                          """
                try database.executeUpdate(sql, values: nil)
                // 创建索引
                sql = "CREATE INDEX \"main\".\"groupid\" ON \"chatGroup\" (\"gid\",\"pid\" )"
                try database.executeUpdate(sql, values: nil)
            } catch {
                dPrint("添加聊天群失败: \(error.localizedDescription)")
            }
        }
    }

    /// 添加通知
    ///
    /// - Parameters:
    ///   - database: 数据库
    ///   - notificationArr: 通知对象数组
    func insertNotification(database: FMDatabase? = nil, with notificationArr: [NotificationMessageData]) {
        guard !(notificationArr.isEmpty) else {
            return
        }
        dispatchDatabaseSafelyQueue(database: database) { database in
            var sql = "INSERT INTO notification (id,pid,action,add_time,action_object,action_object_type,action_pid,content,expired_time,level,message_info,send_count,sender,sender_pid,target,target_pid,target_type) VALUES "
            var valueStr = ""
            for notification in notificationArr {//同一个session的消息
                valueStr += "('\(notification.id ?? "")',\(notification.pid ?? 0),\(notification.action ?? 0),'\(notification.add_time ?? "")','\(notification.action_object ?? "")',\(notification.action_object_type ?? 0),\(notification.action_pid ?? 0),'\(notification.content ?? "")','\(notification.expired_time ?? "")',\(notification.level ?? 0),'\(notification.message_info ?? "")',\(notification.send_count ?? 0),\(notification.sender ?? 0),\(notification.sender_pid ?? 0),\(notification.target ?? 0),\(notification.target_pid ?? 0),\(notification.target_type ?? 0)),"
            }
            // 3.2 移除最后一个逗号
            valueStr.removeLast()
            sql += valueStr
            do {
                try database.executeUpdate(sql, values: nil)
            } catch {
                dPrint("创建notification失败: \(error.localizedDescription)")
                HUDUtil.debugMsg(msg: "测试：创建notification失败", type: .error)
            }
        }
    }

    /// 创建新会话session
    ///
    /// - Parameter sessionID: 会话ID
    /// - Returns: 是否成功
    func createChatSession(database: FMDatabase? = nil, by message: ChatMessageModel) {
        dispatchDatabaseSafelyQueue(database: database) { database in
            let sql = "INSERT INTO session (session_id,groupPid,chat_type,sender,sender_pid,receiver,receiver_pid,msg_direction,unread_num,update_time,add_time,last_msg_id,last_content) VALUES (\(message.session_id),\(message.groupPid),\(message.chat_type),\(message.sender),\(message.sender_pid),\(message.receiver),\(message.receiver_pid),\(message.direction),\(message.unread),\(Date().getTimeIntervalSince1970()),\(Date().getTimeIntervalSince1970()),\(message.msg_id),'\(message.content.base64EncodeStr)')"
            do {
                try database.executeUpdate(sql, values: nil)
            } catch {
                dPrint("创建会话session失败: \(error.localizedDescription)")
                HUDUtil.debugMsg(msg: "测试：创建会话session失败", type: .error)
            }
        }
    }

    /// 添加联系人
    ///
    /// - Parameters:
    ///   - uid: 用户id
    ///   - pid: 用户pid
    ///   - avatar: 头像
    ///   - nickname: 昵称
    func insertContacts(database: FMDatabase? = nil, uid: Int64, pid: Int64, avatar: String, nickname: String, type: Int, message: ChatMessageModel?) {
        dispatchDatabaseSafelyQueue(database: database) { [weak self] database in
            let sql = "INSERT INTO contacts (uid,pid,avatar,nickname,chat_type) VALUES (\(uid),\(pid),'\(avatar.base64EncodeStr)','\(nickname.base64EncodeStr)',\(type))"
            do {
                try database.executeUpdate(sql, values: nil)
                self?.querySingleSession(database: database, sessionID: message?.session_id ?? 0, chatType: 0, finish: { sessionModel in
                    NotificationCenter.default.post(name: Notification.Name(kChatSessionSingleDataChage), object: sessionModel)
                })
                NotificationCenter.default.post(name: Notification.Name(kChatMessageSingleDataChage), object: message)
            } catch {
                dPrint("更新联系人信息失败: \(error.localizedDescription)")
            }
        }
    }

    /// 插入群信息
    ///
    /// - Parameter chatGroupInfo: 群信息
    func insertChatGroupInfo(database: FMDatabase? = nil, chatGroupInfo: ChatGroupDetailData) {
        dispatchDatabaseSafelyQueue(database: database) { [weak self] database in
            do {
                let sql = "INSERT INTO chatGroup (icon,name,gid,pid,notice,status,can_share,set_top,update_time,add_time,nickname_visual,background,join_type,creator_id) VALUES ('\(chatGroupInfo.icon?.base64EncodeStr ?? "")','\(chatGroupInfo.name?.base64EncodeStr ?? "")',\(chatGroupInfo.id ?? 0),\(chatGroupInfo.pid ?? 0),'\(chatGroupInfo.notice?.base64EncodeStr ?? "")',\(chatGroupInfo.status ?? 0),\(chatGroupInfo.can_share ?? 1),\(chatGroupInfo.set_top ?? 0),'\(chatGroupInfo.update_time ?? "")','\(chatGroupInfo.add_time ?? "")',\(chatGroupInfo.nickname_visual ?? 1),'\(chatGroupInfo.background?.base64EncodeStr ?? "")',\(chatGroupInfo.join_type ?? 0),\(chatGroupInfo.creator_id ?? 0))"
                try database.executeUpdate(sql, values: nil)
                let sid = ((chatGroupInfo.id ?? 0) >> 32) + (chatGroupInfo.pid ?? 0)
                self?.querySingleSession(database: database, sessionID: sid, chatType: 1, finish: { sessionModel in
                    NotificationCenter.default.post(name: Notification.Name(kChatGroupInfoChangeNotification), object: sessionModel)
                })
            } catch {
                dPrint("修改联系人信息失败: \(error.localizedDescription)")
                HUDUtil.debugMsg(msg: "测试：修改联系人信息失败", type: .error)
            }
        }
    }

    /// 添加消息
    ///
    /// - Parameter messageArr: 消息数组
    func insertMessages(database: FMDatabase? = nil, with msgArr: [ChatMessageModel]) {
        dispatchDatabaseSafelyQueue(database: database) { [weak self] database in
            //        1.没数据直接返回
            guard !msgArr.isEmpty else {
                return
            }
            // 2.0 整合消息，同会话消息放到一起
            var messageDic = [Int64: [ChatMessageModel]]()
            for newMsg in msgArr {
                if var messageArr = messageDic[newMsg.session_id] {
                    messageArr.append(newMsg)
                    messageDic[newMsg.session_id] = messageArr
                } else {
                    var messageArr = [ChatMessageModel]()
                    messageArr.append(newMsg)
                    messageDic[newMsg.session_id] = messageArr
                }
            }
            //2.遍历消息数组，RC4解密content数据
            for (sessionID, messageArr) in messageDic {
                var unReadCount = 0
                var valueStr = ""
                do {
                    // 3.添加到Message表中
                    // 3.1 拼接数据字符串
                    var sql = "INSERT INTO message (msg_id,session_id,groupPid,filename,serverid,chat_type,sender,sender_pid,receiver,receiver_pid,kind,direction,send_state,content,client_time,server_time,imageHeight,imageWidth,localStoreName,localOriginalStoreName,notificationID,unread) VALUES "
                    for newMsg in messageArr {//同一个session的消息
                        valueStr += "(\(newMsg.msg_id),\(newMsg.session_id),\(newMsg.groupPid),'\(newMsg.filename.base64EncodeStr)',\(newMsg.serverid),\(newMsg.chat_type),\(newMsg.sender),\(newMsg.sender_pid),\(newMsg.receiver),\(newMsg.receiver_pid),\(newMsg.kind),\(newMsg.direction),\(newMsg.send_state),'\(newMsg.content.base64EncodeStr)','\(newMsg.client_time)','\(newMsg.server_time)',\(newMsg.imageHeight),\(newMsg.imageWidth),'\(newMsg.localStoreName.base64EncodeStr)','\(newMsg.localOriginalStoreName.base64EncodeStr)','\(newMsg.notificationID)',\(newMsg.unread)),"
                        if newMsg.otherNewMsg == true {
                            unReadCount += 1
                            self?.updateUserInfo(uid: newMsg.sender, pid: newMsg.sender_pid, immediate: false, message: newMsg)
                            if IMService.shared.currentSessionID == sessionID {
                                self?.addNewMessage(database: database, msg: newMsg)
                            }
                        }
                    }

                    // 3.2 移除最后一个逗号
                    valueStr.removeLast()
                    sql += valueStr
                    // 3.3执行语句
                    try database.executeUpdate(sql, values: nil)

                    //   4.更新session表
                    // 4.1 判断是否有该会话
                    sql = "SELECT * FROM session WHERE session_id = \(sessionID)"
                    let sessionRs = try database.executeQuery(sql, values: nil)
                    guard let newMsg = messageArr.last else {
                        continue
                    }
                    if sessionRs.next() {// 有直接更新
                        sessionRs.close()
                        sql = "UPDATE session SET msg_kind= \(newMsg.kind),unread_num= \(newMsg.direction == ChatDirection.sendToOthers.rawValue ? 0 : 1),update_time='\(newMsg.client_time)',last_msg_id=\(newMsg.msg_id),last_content='\(newMsg.content.base64EncodeStr)',last_send_state = \(newMsg.send_state) WHERE session_id= \(newMsg.session_id) AND chat_type=\(newMsg.chat_type)"
                        try database.executeUpdate(sql, values: nil)
                    } else {// 没有，往表里面添加
                        sessionRs.close()
                        let sender = newMsg.sender == UserUtil.share.appUserInfo?.uid ? newMsg.sender : newMsg.receiver
                        let senderPid = newMsg.sender == UserUtil.share.appUserInfo?.uid ? newMsg.sender_pid : newMsg.receiver_pid
                        var reciever = newMsg.sender == UserUtil.share.appUserInfo?.uid ? newMsg.receiver : newMsg.sender
                        var recieverPid = newMsg.sender == UserUtil.share.appUserInfo?.uid ? newMsg.receiver_pid : newMsg.sender_pid
                        reciever = newMsg.chat_type == 1 ? ((newMsg.session_id - newMsg.groupPid) >> 32) : reciever
                        recieverPid = newMsg.chat_type == 1 ? newMsg.groupPid : recieverPid
                        sql = "INSERT INTO session (session_id,groupPid,msg_kind,chat_type,sender,sender_pid,receiver,receiver_pid,msg_direction,unread_num,update_time,add_time,last_msg_id,last_content,last_send_state) VALUES (\(newMsg.session_id),\(newMsg.groupPid),\(newMsg.kind),\(newMsg.chat_type),\(sender),\(senderPid),\(reciever),\(recieverPid),\(newMsg.direction),\(newMsg.unread),'\(newMsg.server_time)','\(newMsg.client_time)',\(newMsg.msg_id),'\(newMsg.content.base64EncodeStr)',\(newMsg.send_state))"
                        try database.executeUpdate(sql, values: nil)
                    }

                    self?.updateSessionDetail(database: database, msg: messageArr.first ?? ChatMessageModel())
                    if unReadCount == 0 {
                        continue
                    }
                    self?.modifyUnreadState(database: database, with: sessionID, chatType: messageArr.first?.chat_type ?? 0, unreadNum: unReadCount, updateUI: true)
                } catch {
                    dPrint("添加消息失败: \(error.localizedDescription)")
                }
            }
        }
    }

    // 更新会话UI
    func updateSessionDetail(database: FMDatabase? = nil, msg: ChatMessageModel) {
        dispatchDatabaseSafelyQueue(database: database) { [weak self] database in
            if msg.chat_type == 0 { // 私聊
                self?.queryContactsInfo(database: database, uid: msg.sender, pid: msg.sender_pid, finish: { info in
                    if info != nil && info?.uid != nil {
                        self?.querySingleSession(database: database, sessionID: msg.session_id, chatType: 0, finish: { sessionModel in
                            sessionModel?.avatar = info?.head_portrait ?? ""
                            sessionModel?.nickname = info?.nick_name ?? ""
                            NotificationCenter.default.post(name: Notification.Name(kChatSessionSingleDataChage), object: sessionModel)
                        })
                    } else {
                        self?.updateUserInfo(database: database, uid: msg.sender, pid: msg.sender_pid, immediate: false, message: msg)
                    }
                })
            } else if msg.chat_type == 1 { // 群聊
                let gid = (msg.session_id - msg.groupPid) >> 32
                self?.queryChatGroupInfo(database: database, gid: gid, pid: msg.groupPid, finish: { info in
                    if info != nil {
                        self?.querySingleSession(database: database, sessionID: msg.session_id, chatType: 1, finish: { sessionModel in
                            sessionModel?.avatar = info?.icon ?? ""
                            sessionModel?.nickname = info?.name ?? ""
                            NotificationCenter.default.post(name: Notification.Name(kChatSessionSingleDataChage), object: sessionModel)
                        })
                    } else {
                        self?.updateChatGroupInfo(database: database, gid: gid, pid: msg.groupPid, immediate: false)
                    }
                })
            }
        }
    }

    // 添加新消息
    func addNewMessage(database: FMDatabase? = nil, msg: ChatMessageModel) {
        dispatchDatabaseSafelyQueue(database: database) { [weak self] database in
            //查询和显示信息
            self?.queryContactsInfo(database: database, uid: msg.sender, pid: msg.sender_pid, finish: { info in
                if info != nil && info?.uid != nil {
                    msg.avatar = info?.head_portrait ?? ""
                    msg.nickname = info?.zh_name ?? ""
                }
                NotificationCenter.default.post(name: Notification.Name(kChatAddMessageNotification), object: msg)
            })
        }
    }
}

// MARK: - modify
extension DatabaseTool {
    /// 修改联系人
    ///
    /// - Parameters:
    ///   - uid: 联系人uid
    ///   - pid: 联系人pid
    ///   - avatar: 联系人头像
    ///   - nickname: 联系人昵称
    func modifyContacts(database: FMDatabase? = nil, uid: Int64, pid: Int64, avatar: String, nickname: String, type: Int, message: ChatMessageModel?) {
        dispatchDatabaseSafelyQueue(database: database) { [weak self] database in
            do {
                let sql = "UPDATE contacts SET avatar = '\(avatar.base64EncodeStr)' , nickname = '\(nickname.base64EncodeStr)' WHERE uid=\(uid) AND pid=\(pid) AND chat_type=\(type)"
                try database.executeUpdate(sql, values: nil)
                self?.querySingleSession(database: database, sessionID: message?.session_id ?? 0, chatType: 0, finish: { sessionModel in
                    NotificationCenter.default.post(name: Notification.Name(kChatSessionSingleDataChage), object: sessionModel)
                }
                )
                NotificationCenter.default.post(name: Notification.Name(kChatMessageSingleDataChage), object: message)
            } catch {
                dPrint("修改联系人信息失败: \(error.localizedDescription)")
                HUDUtil.debugMsg(msg: "测试：修改联系人信息失败", type: .error)
            }
        }
    }

    /// 修改群信息
    ///
    /// - Parameter chatGroupInfo: 群信息
    func modifyChatGroupInfo(database: FMDatabase? = nil, chatGroupInfo: ChatGroupDetailData) {
        dispatchDatabaseSafelyQueue(database: database) { [weak self] database in
            do {
                let sql = "UPDATE chatGroup SET icon = '\(chatGroupInfo.icon?.base64EncodeStr ?? "")' , name = '\(chatGroupInfo.name?.base64EncodeStr ?? "暂无")' ,notice = '\(chatGroupInfo.notice?.base64EncodeStr ?? "")' ,banned = '\(chatGroupInfo.banned ?? 0)' , status = '\(chatGroupInfo.status ?? 0)' , can_share = '\(chatGroupInfo.can_share ?? 1)' ,set_top = \(chatGroupInfo.set_top ?? 0) , update_time = '\(chatGroupInfo.update_time ?? "")' ,add_time = '\(chatGroupInfo.add_time ?? "")' , nickname_visual = \(chatGroupInfo.nickname_visual ?? 1) , background = '\(chatGroupInfo.background?.base64EncodeStr ?? "")' , creator_id = \(chatGroupInfo.creator_id ?? 0)  WHERE gid=\(chatGroupInfo.id ?? 0) AND pid=\(chatGroupInfo.pid ?? 0)"
                try database.executeUpdate(sql, values: nil)
                let sid = (chatGroupInfo.id ?? 0) << 32 + (chatGroupInfo.pid ?? 0)
                self?.querySingleSession(database: database, sessionID: sid, chatType: 1, finish: { sessionModel in
                    NotificationCenter.default.post(name: Notification.Name(kChatGroupInfoChangeNotification), object: sessionModel)
                })
            } catch {
                dPrint("修改联系人信息失败: \(error.localizedDescription)")
                HUDUtil.debugMsg(msg: "测试：修改联系人信息失败", type: .error)
            }
        }
    }

    /// 拉取更新个人信息
    ///
    /// - Parameters:
    ///   - uid: 用户的uid
    ///   - pid: 用户的pid
    ///   - immediate: true 为更新数据 false 不更新数据
    ///   - refreshUI: true 刷新UI false 不刷新UI
    func updateUserInfo(database: FMDatabase? = nil, uid: Int64, pid: Int64, immediate: Bool, refreshUI: Bool = true, message: ChatMessageModel?) {
        if UserUtil.share.appUserInfo?.uid == uid && UserUtil.share.appUserInfo?.pid == pid {
            return
        }
        dispatchDatabaseSafelyQueue(database: database) { [weak self] database in
            self?.isContactsInfoExsist(uid: uid, pid: pid, finish: { isExist in
                if !immediate && isExist {
                    return
                }
                let infoTuple = (uid, pid)
                for info in self?.requestingUserInfo ?? [] {
                    if info.0 == uid && info.1 == pid {
                        return
                    }
                }
                self?.requestingUserInfo.append(infoTuple)
                NetworkUtil.request(
                    target: .getInfo(user_id: uid, user_pid: pid),
                    success: { [weak self] json in
                        let info = UserInfoModel.deserialize(from: json)?.data
                        guard let uid = info?.uid, let pid = info?.pid else {
                            return
                        }
                        if uid == 0 && pid == 0 {
                            return
                        }
                        message?.avatar = info?.head_portrait ?? ""
                        message?.nickname = info?.zh_name ?? ""
                        if isExist {
                            self?.modifyContacts(database: database, uid: uid, pid: pid, avatar: info?.head_portrait ?? "", nickname: info?.zh_name ?? "", type: 0, message: message)
                        } else {
                            self?.insertContacts(database: database, uid: uid, pid: pid, avatar: info?.head_portrait ?? "", nickname: info?.zh_name ?? "", type: 0, message: message)
                        }
                    }
                ) { error in
                    dPrint(error)
                }
            })
        }
    }

    /// 更新群信息
    ///
    /// - Parameters:
    ///   - sessionID: 群ID
    ///   - pid: 群pid
    ///   - immediate: true 更新数据 fasle 不更新数据
    func updateChatGroupInfo(database: FMDatabase? = nil, gid: Int64, pid: Int64, immediate: Bool) {
        dispatchDatabaseSafelyQueue(database: database) { [weak self] database in
            self?.isChatGroupInfoExsist(gid: gid, pid: pid, finish: { isExist in
                if !immediate && isExist {
                    return
                }
                NetworkUtil.request(
                    target: NetworkService.getChatGroup(group_id: gid, group_pid: pid),
                    success: { [weak self] json in
                        guard let groupModel = ChatGroupModel.deserialize(from: json)?.data else {
                            return
                        }
                        if isExist {
                            self?.modifyChatGroupInfo(database: database, chatGroupInfo: groupModel)
                        } else {
                            self?.insertChatGroupInfo(database: database, chatGroupInfo: groupModel)
                        }
                    }
                ) { error in
                    dPrint(error)
                }
            })
        }
    }

    /// 修改用户信息
    ///
    /// - Parameters:
    ///   - sessionID: 会话ID
    ///   - userInfo: 用户信息
    func modifySessionUserInfo(database: FMDatabase? = nil, sessionID: Int64, chatType: Int, userInfo: UserInfoData?) {
        dispatchDatabaseSafelyQueue(database: database) { [weak self] database in
            do {
                let sql = "UPDATE session SET avatar = '\(userInfo?.head_portrait?.base64EncodeStr ?? "")' , nickname = '\(userInfo?.zh_name?.base64EncodeStr ?? "")' WHERE session_id=\(sessionID) AND chat_type = \(chatType)"
                try database.executeUpdate(sql, values: nil)
                self?.querySingleSession(database: database, sessionID: sessionID, chatType: 0, finish: { sessionModel in
                    NotificationCenter.default.post(name: Notification.Name(kChatSessionSingleDataChage), object: sessionModel)
                })
            } catch {
                dPrint("修改用户信息失败: \(error.localizedDescription)")
            }
        }
    }

    /// 修改会话信息
    ///
    /// - Parameters:
    ///   - sessionID: 会话ID
    ///   - userInfo: 会话model
    func modifySessionInfo(database: FMDatabase? = nil, sessionModel: ChatSessionModel) {
        dispatchDatabaseSafelyQueue(database: database) { [weak self] database in
            do {
                let sql = "UPDATE session SET session_id = \(sessionModel.session_id),groupPid = \(sessionModel.groupPid),msg_kind = \(sessionModel.msg_kind),chat_type = \(sessionModel.chat_type),sender = \(sessionModel.sender),sender_pid = \(sessionModel.sender_pid),receiver = \(sessionModel.receiver),receiver_pid = \(sessionModel.receiver_pid),unread_num = \(sessionModel.unread_num),update_time = '\(sessionModel.update_time)',add_time = '\(sessionModel.add_time)',last_msg_id = \(sessionModel.last_msg_id),last_content = '\(sessionModel.last_content.base64EncodeStr)',last_send_state = '\(sessionModel.last_send_state) WHERE session_id=\(sessionModel.session_id) AND chat_type = \(sessionModel.chat_type)"
                try database.executeUpdate(sql, values: nil)
                self?.querySingleSession(database: database, sessionID: sessionModel.session_id, chatType: sessionModel.chat_type, finish: { sessionModel in
                    NotificationCenter.default.post(name: Notification.Name(kChatSessionSingleDataChage), object: sessionModel)
                })
            } catch {
                dPrint("修改用户信息失败: \(error.localizedDescription)")
            }
        }
    }

    /// 修改发送状态
    ///
    /// - Parameter sessionID: 会话ID
    func modifySendState(database: FMDatabase? = nil, sessionID: Int64, chatType: Int, msgID: Int64, state: Int) {
        dispatchDatabaseSafelyQueue(database: database) { [weak self] database in
            do {
                var sql = "UPDATE  message SET send_state=\(state) WHERE session_id=\(sessionID) AND msg_id=\(msgID)"
                try database.executeUpdate(sql, values: nil)
                sql = "UPDATE  session SET last_send_state=\(state) WHERE session_id=\(sessionID) and chat_type = \(chatType)"
                try database.executeUpdate(sql, values: nil)

                self?.querySingleMessage(database: database, sessionID: sessionID, chatType: chatType, msgID: msgID, finish: { messageModel in
                    NotificationCenter.default.post(name: Notification.Name(kChatMessageSingleDataChage), object: messageModel)
                })
                self?.querySingleSession(database: database, sessionID: sessionID, chatType: chatType, finish: { sessionModel in
                    NotificationCenter.default.post(name: Notification.Name(kChatSessionSingleDataChage), object: sessionModel)
                })
            } catch {
                dPrint("修改未读标识失败: \(error.localizedDescription)")
            }
        }
    }

    /// 修改消息是否确认收到状态
    ///
    /// - Parameters:
    ///   - notificationID: 通知ID
    ///   - state: 确认状态
    func modifyReceiptState(database: FMDatabase? = nil, notificationID: String, state: Int) {
        dispatchDatabaseSafelyQueue(database: database) { database in
            do {
                let sql = "UPDATE  message SET receipt=\(state) WHERE notificationID='\(notificationID)' AND receipt=\(state == 0 ? 1 : 0)"
                try database.executeUpdate(sql, values: nil)
            } catch {
                dPrint("修改未读标识失败: \(error.localizedDescription)")
            }
        }
    }

    /// 修改通知消息 是否已读
    ///
    /// - Parameters:
    ///   - database: 数据库对象
    ///   - notificationID: 通知id
    ///   - state: 状态
    func modifyNotificationReceiptState(database: FMDatabase? = nil, action: NotificationActionType, state: Int) {
        dispatchDatabaseSafelyQueue(database: database) { database in
            do {
                let sql = "UPDATE  notification SET unread=\(state) WHERE action='\(action.rawValue)'"
                try database.executeUpdate(sql, values: nil)
            } catch {
                dPrint("修改通知未读标识失败: \(error.localizedDescription)")
            }
        }
    }

    /// 修改Message
    ///
    /// - Parameter sessionID: 会话ID
    func modifyPicMessage(database: FMDatabase? = nil, with messageID: Int64, model: ChatMessageModel) {
        dispatchDatabaseSafelyQueue(database: database) { database in
            do {
                let sql = "UPDATE message SET content = '\(model.content.base64EncodeStr)',imageWidth = \(model.imageWidth),imageHeight = \(model.imageHeight),send_state = \(model.send_state),localStoreName = '\(model.localStoreName.base64EncodeStr)',localOriginalStoreName = '\(model.localOriginalStoreName.base64EncodeStr)' WHERE msg_id = \(messageID) AND chat_type = \(model.chat_type)"
                try database.executeUpdate(sql, values: nil)
            } catch {
                dPrint("修改Message失败: \(error.localizedDescription)")
            }
        }
    }

    /// 修改文件消息本地缓存路径
    ///
    /// - Parameter sessionID: 会话ID
    func modifyFileMessage(database: FMDatabase? = nil, with messageID: Int64, sessionID: Int64, chatType: Int, filePath: String) {
        dispatchDatabaseSafelyQueue(database: database) { database in
            do {
                let sql = "UPDATE message SET localStoreName = '\(filePath.base64EncodeStr)' WHERE msg_id = \(messageID) AND session_id=\(sessionID) AND chat_type=\(chatType)"
                try database.executeUpdate(sql, values: nil)
            } catch {
                dPrint("修改Message失败: \(error.localizedDescription)")
            }
        }
    }

    /// 修改会话未读标识
    ///
    /// - Parameter sessionID: 会话ID
    func modifyUnreadState(database: FMDatabase? = nil, with sessionID: Int64, chatType: Int, unreadNum: Int, reset: Bool = false, updateUI: Bool = false) {
        dispatchDatabaseSafelyQueue(database: database) { [weak self] database in
            self?.querySingleSession(database: database, sessionID: sessionID, chatType: chatType, finish: { sessionModel in
                guard let safeModel = sessionModel else {
                    return
                }
                do {
                    var unreadRemindNum = safeModel.unread_remind_num + (unreadNum == 0 ? -1 : unreadNum)
                    if reset {
                        unreadRemindNum = unreadNum == 0 ? 0 : 1
                    }
                    let sql = "UPDATE  session SET  unread_remind_num = \(unreadRemindNum),unread_num = \(unreadNum) WHERE session_id= \(sessionID) AND chat_type = \(chatType)"
                    try database.executeUpdate(sql, values: nil)
                    if updateUI {
                        NotificationCenter.default.post(name: Notification.Name(kChatSessionListDataChange), object: sessionModel)
                    }
                } catch {
                    dPrint("修改未读标识失败: \(error.localizedDescription)")
                }
            })
        }
    }

    /// 修改消息未读标识
    /// - Parameters:
    ///   - notifacationID: 消息通知ID
    ///   - state: 0 已读，1未读
    func modifyUnreadMessageState(database: FMDatabase? = nil, with notificationID: String, state: Int) {
        dispatchDatabaseSafelyQueue(database: database) { database in
            do {
                let sql = "UPDATE  message SET  unread = \(state) WHERE notificationID= '\(notificationID)'"
                try database.executeUpdate(sql, values: nil)
            } catch {
                dPrint("修改消息未读标识失败: \(error.localizedDescription)")
            }
        }
    }

    /// 修改草稿
    ///
    /// - Parameter sessionID: 会话ID
    func modifyDraft(database: FMDatabase? = nil, with sessionID: Int64, chatType: Int, content: String) {
        dispatchDatabaseSafelyQueue(database: database) { [weak self] database in
            do {
                let sql = "UPDATE session SET draft_content= '\(content.base64EncodeStr)' WHERE session_id=\(sessionID) and chat_type = \(chatType)"
                try database.executeUpdate(sql, values: nil)
                self?.querySingleSession(database: database, sessionID: sessionID, chatType: chatType, finish: { model in
                    NotificationCenter.default.post(name: Notification.Name(kChatSessionSingleDataChage), object: model)
                })
            } catch {
                dPrint("修改草稿失败: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - delete
extension DatabaseTool {
    /// 删除会话
    ///
    /// - Parameter sessionID: 会话ID
    /// - Returns: 是否删除成功
    func deleteChatSession(database: FMDatabase? = nil, by sessionID: Int64, type: Int) {
        dispatchDatabaseSafelyQueue(database: database) { database in
            do {
                //        1.删除Message表中，该sessionID的记录
                var sql = "DELETE FROM message WHERE session_id=\(sessionID) AND chat_type = \(type)"
                try database.executeUpdate(sql, values: nil)
                //        2.删除Session表中，该sessionID的记录
                sql = "DELETE FROM session WHERE session_id=\(sessionID) AND chat_type = \(type)"
                try database.executeUpdate(sql, values: nil)
                NotificationCenter.default.post(name: Notification.Name(kChatSessionListDataChange), object: nil)
            } catch {
                HUDUtil.debugMsg(msg: "测试：删除会话失败", type: .error)
                dPrint("删除会话失败: \(error.localizedDescription)")
            }
        }
    }
}
