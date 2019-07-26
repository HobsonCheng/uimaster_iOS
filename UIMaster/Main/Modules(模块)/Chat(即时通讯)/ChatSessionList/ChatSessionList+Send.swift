////
////  ChatSessionList+Send.swift
////  UIMaster
////
////  Created by hobson on 2018/10/11.
////  Copyright © 2018 one2much. All rights reserved.
////
//
//import Foundation
//
//
//// MARK: - @extension TSChatViewController
//extension ChatSessionList {
//    /**
//     发送文字
//     */
//    func chatSendText() {
//        dispatch_async_safely_to_main_queue({[weak self] in
//            guard let strongSelf = self else { return }
//            guard let textView = strongSelf.chatActionBarView.inputChatView else {return }
//
//            // 1. 发送内容校验
//            // 1.1 不能超1000字
//            guard textView.text.count < 1000 else {
//                self?.hideAllKeyboard()
//                HUDUtil.msg(msg: "超出字数限制", type: .error)
//                return
//            }
//            // 1.2 不能发送空白消息
//            let text = textView.text.trimmingCharacters(in: CharacterSet.whitespaces)
//            if text.count == 0 {
//                self?.hideAllKeyboard()
//                HUDUtil.msg(msg: "不能发送空白消息", type: .error)
//                return
//            }
//            // 2. 生成数据模型
//            let string = strongSelf.chatActionBarView.inputChatView.text
//            let model = ChatMessageModel()
//            model.content = string ?? ""
//            model.msg_id = Int64(Date().getTimeIntervalSince1970())
//            model.session_id = self?.currentModel?.session_id ?? 0
//            model.client_time = Date.currentTimeStr
//            model.direction = ChatDirection.sendToOthers.rawValue
//            model.kind = ChatMessageType.text.rawValue
//            model.receiver = self?.currentModel?.receiver ?? 0
//            model.groupPid = self?.currentModel?.groupPid ?? 0
//            model.receiver_pid = self?.currentModel?.receiver_pid ?? 0
//            model.sender = self?.currentModel?.sender ?? 0
//            model.sender_pid = self?.currentModel?.sender_pid ?? 0
//            model.send_state = ChatSendStatus.sending.rawValue
//            model.chat_type = self?.currentModel?.chat_type ?? 0
//
//            //3. 写入数据库
//            DatabaseTool.shared.insertMessages(with: [model])
//
//            //4. 发送请求
//            NetworkUtil.request(target: NetworkService.addMessage(msg_type: model.kind, content: model.content.rc4EncodeStr, target_pid: model.receiver_pid, send_time: model.client_time, session: Int64(model.session_id), file_name: "", client_id: Int64(model.msg_id), target: model.receiver), success: { (json) in
//                var status = ChatSendStatus.success.rawValue
//                if BaseModel.deserialize(from: json)?.code != "0"{
//                    status = ChatSendStatus.fail.rawValue
//                }
//                DatabaseTool.shared.modifySendState(sessionID: model.session_id, msgID: model.msg_id, state: status)
//            }, failure: { (error) in
//                DatabaseTool.shared.modifySendState(sessionID: model.session_id, msgID: model.msg_id, state: ChatSendStatus.fail.rawValue)
//            })
//            //5. 扫尾
//            //5.1 清空输入框
//            textView.text = ""
//            //5.2 调整输入框高度
//            strongSelf.textViewDidChange(strongSelf.chatActionBarView.inputChatView)
//            //5.3 收起键盘
//            self?.chatActionBarView.resignKeyboard()
//        })
//    }
//
//    /**
//     发送声音
//     */
//    func chatSendVoice(_ audioModel: ChatMessageModel) {
//        //        dispatch_async_safely_to_main_queue({[weak self] in
//        //            guard let strongSelf = self else { return }
//        //            let model = ChatModel(audioModel: audioModel)
//        //            strongSelf.itemDataSouce.append(model)
//        //            let insertIndexPath = IndexPath(row: strongSelf.itemDataSouce.count - 1, section: 0)
//        //            strongSelf.listTableView.insertRowsAtBottom([insertIndexPath])
//        //        })
//    }
//
//    /**
//     发送图片
//     */
//    func chatSendImage(_ imageModel: ChatMessageModel) {
//        dispatch_async_safely_to_main_queue({
//            DatabaseTool.shared.insertMessages(with: [imageModel])
//        })
//    }
//
//    /**
//     发送文件
//     */
//    func chatSendFile(_ fileModel: ChatMessageModel) {
//        dispatch_async_safely_to_main_queue({
////            let lastModel = self.itemList.last
//            var modelArr = [ChatMessageModel]()
//            modelArr.append(fileModel)
//            DatabaseTool.shared.insertMessages(with: modelArr)
//        })
//    }
//}
