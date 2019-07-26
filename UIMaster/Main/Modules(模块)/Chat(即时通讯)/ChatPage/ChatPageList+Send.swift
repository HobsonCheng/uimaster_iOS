//
//  ChatPageList+Send.swift
//  UIMaster
//
//  Created by hobson on 2018/9/27.
//  Copyright © 2018 one2much. All rights reserved.
//

import Foundation

// MARK: - @extension TSChatViewController
extension ChatPageList {
    /**
     发送文字
     */
//    func chatSendText() {
//        dispatch_async_safely_to_main_queue({ [weak self] in
//            guard let strongSelf = self else { return }
//            guard let textView = strongSelf.chatActionBarView.inputChatView else { return }
//            guard textView.text.count <= 1000 else {
//                HUDUtil.msg(msg: "超出1000字数限制", type: .error)
//                return
//            }
//
//            let text = textView.text.trimmingCharacters(in: CharacterSet.whitespaces)
//            if text.count == 0 {
//                return
//            }
//            //创建消息
//            let string = strongSelf.chatActionBarView.inputChatView.text
//            var modelArr = [ChatMessageModel]()
//            let model = ChatMessageModel()
//            model.content = string ?? ""
//            model.msg_id = Int64(Date().getTimeIntervalSince1970())
//            model.session_id = self?.currentSessionModel.session_id ?? 0
//            model.client_time = Date.currentTimeStr
//            model.server_time = Date.currentTimeStr
//            model.direction = ChatDirection.sendToOthers.rawValue
//            model.chat_type = self?.currentSessionModel.chat_type ?? 0
//            model.groupPid = self?.currentSessionModel.groupPid ?? 0
//            model.kind = ChatMessageType.text.rawValue
//            model.receiver = self?.currentSessionModel.receiver ?? 0
//            model.receiver_pid = self?.currentSessionModel.receiver_pid ?? 0
//            model.sender = self?.currentSessionModel.sender ?? 0
//            model.sender_pid = self?.currentSessionModel.sender_pid ?? 0
//            model.send_state = ChatSendStatus.sending.rawValue
//            // 添加数据模型
//            modelArr.append(model)
//            //添加时间
//            let lastModel = self?.itemList.last
//
//            if model.isLateForThreeMinutes(timestamp: lastModel?.msg_id ?? 0) {
//                let chatTimeModel = ChatMessageModel.init()
//                chatTimeModel.kind = ChatMessageType.time.rawValue
//                chatTimeModel.session_id = self?.currentSessionModel.session_id ?? 0
//                chatTimeModel.serverid = model.msg_id
//                chatTimeModel.content = Date.init(timeIntervalSince1970: TimeInterval(model.msg_id/1000)).chatTimeString
//                strongSelf.itemList.append(chatTimeModel)
//                let insertIndexPath1 = IndexPath(row: strongSelf.itemList.count - 1, section: 0)
//                strongSelf.listTableView.insertRowsAtBottom([insertIndexPath1])
//            }
//
//            //写入数据库
//            DatabaseTool.shared.insertMessages(with: modelArr)
//
//            //发送请求
//            NetworkUtil.request(target: NetworkService.addMessage(msg_type: model.kind, content: model.content.rc4EncodeStr, target_pid: model.receiver_pid, send_time: model.client_time, session: Int64(model.session_id), file_name: "", client_id: Int64(model.msg_id), target: model.receiver), success: { (json) in
//                var status = ChatSendStatus.success.rawValue
//                if BaseModel.deserialize(from: json)?.code != "0"{
//                    status = ChatSendStatus.fail.rawValue
//                }
//                DatabaseTool.shared.modifySendState(sessionID: model.session_id, msgID: model.msg_id, state: status)
//            }, failure: { (error) in
//                DatabaseTool.shared.modifySendState(sessionID: model.session_id, msgID: model.msg_id, state: ChatSendStatus.fail.rawValue)
//                dPrint(error)
//            })
//
//            strongSelf.itemList.append(model)
//            let insertIndexPath = IndexPath(row: strongSelf.itemList.count - 1, section: 0)
//            strongSelf.listTableView.insertRowsAtBottom([insertIndexPath])
//            textView.text = "" //发送完毕后清空
//            DatabaseTool.shared.modifyDraft(with: self?.currentSessionModel.session_id ?? 0, content: "")
//            strongSelf.textViewDidChange(strongSelf.chatActionBarView.inputChatView)
//        })
//    }

    /**
     发送声音
     */
//    func chatSendVoice(_ audioModel: ChatMessageModel) {
//        dispatch_async_safely_to_main_queue({[weak self] in
//            guard let strongSelf = self else { return }
//            let model = ChatModel(audioModel: audioModel)
//            strongSelf.itemDataSouce.append(model)
//            let insertIndexPath = IndexPath(row: strongSelf.itemDataSouce.count - 1, section: 0)
//            strongSelf.listTableView.insertRowsAtBottom([insertIndexPath])
//        })
//    }

    /**
     发送图片
     */
//    func chatSendImage(_ imageModel: ChatMessageModel) {
//        dispatch_async_safely_to_main_queue({
//            
//            let lastModel = self.itemList.last
//            if imageModel.isLateForThreeMinutes(timestamp: lastModel?.msg_id ?? 0) {
//                let chatTimeModel = ChatMessageModel.init()
//                chatTimeModel.kind = ChatMessageType.time.rawValue
//                chatTimeModel.session_id = self.currentSessionModel.session_id
//                chatTimeModel.serverid = imageModel.msg_id
//                chatTimeModel.content = Date.init(timeIntervalSince1970: TimeInterval(imageModel.msg_id/1000)).chatTimeString
//                self.itemList.append(chatTimeModel)
//                let insertIndexPath = IndexPath(row: self.itemList.count - 1, section: 0)
//                self.listTableView.insertRowsAtBottom([insertIndexPath])
//            }
//            self.itemList.append(imageModel)
//            let insertIndexPath = IndexPath(row: self.itemList.count - 1, section: 0)
//            self.listTableView.insertRowsAtBottom([insertIndexPath])
//            DatabaseTool.shared.insertMessages(with: [imageModel])
//        })
//    }
    /**
     发送文件
     */
//    func chatSendFile(_ fileModel: ChatMessageModel) {
//        dispatch_async_safely_to_main_queue({
//            let lastModel = self.itemList.last
//            if fileModel.isLateForThreeMinutes(timestamp: lastModel?.msg_id ?? 0) {
//                let chatTimeModel = ChatMessageModel.init()
//                chatTimeModel.kind = ChatMessageType.time.rawValue
//                chatTimeModel.session_id = self.currentSessionModel.session_id
//                chatTimeModel.serverid = fileModel.msg_id
//                chatTimeModel.content = Date.init(timeIntervalSince1970: TimeInterval(fileModel.msg_id/1000)).chatTimeString
//                self.itemList.append(chatTimeModel)
//                let insertIndexPath = IndexPath(row: self.itemList.count - 1, section: 0)
//                self.listTableView.insertRowsAtBottom([insertIndexPath])
//            }
//            self.itemList.append(fileModel)
//            let insertIndexPath = IndexPath(row: self.itemList.count - 1, section: 0)
//            self.listTableView.insertRowsAtBottom([insertIndexPath])
//            DatabaseTool.shared.insertMessages(with: [fileModel])
//        })
//    }

}
