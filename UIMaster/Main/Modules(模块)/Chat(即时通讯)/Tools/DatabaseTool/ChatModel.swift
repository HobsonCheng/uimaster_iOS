//
//  ChatModel.swift
//  UIMaster
//
//  Created by hobson on 2018/9/21.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Foundation
import HandyJSON
import Kingfisher
import YYText

/// 消息类型
///
/// - text: 文字消息
/// - picture: 图片消息
/// - file: 文件消息
enum ChatMessageType: Int {
    case text = 0
    case picture = 1
    case file = 2
    case time = 3
    case system = 4
    case interior = 5
    case voice = 6
    case shortVideos = 7
    case position = 8
    case businessCard = 9

    func chatCellHeight(_ model: ChatMessageModel) -> CGFloat {
        switch self {
        case .text :
            return ChatTextCell.layoutHeight(model)

        case .picture :
            return ChatImageCell.layoutHeight(model)

        case .voice:
            return ChatVoiceCell.layoutHeight(model)

        case .system:
            return ChatSystemCell.layoutHeight(model)

        case .file:
            return ChatFileCell.layoutHeight(model)

        case .time :
            return ChatTimeCell.heightForCell()

        case .interior:
            return 0

        default:
            return 0
        }
    }

    func chatCell(_ tableView: UITableView, indexPath: IndexPath, model: ChatMessageModel, viewController: ChatPageList) -> UITableViewCell? {
        switch self {
        case .text :
            let cell: ChatTextCell = tableView.dequeueReusableCell(ChatTextCell.self)
            cell.delegate = viewController
            cell.setCellContent(model)
            return cell

        case .picture :
            let cell: ChatImageCell = tableView.dequeueReusableCell(ChatImageCell.self)
            cell.delegate = viewController
            cell.setCellContent(model)
            return cell

        case .voice:
            let cell: ChatVoiceCell = tableView.dequeueReusableCell(ChatVoiceCell.self)
            cell.delegate = viewController
            cell.setCellContent(model)
            return cell

        case .system:
            let cell: ChatSystemCell = tableView.dequeueReusableCell(ChatSystemCell.self)
            cell.setCellContent(model)
            return cell

        case .file:
            let cell: ChatFileCell = tableView.dequeueReusableCell(ChatFileCell.self)
            cell.delegate = viewController
            cell.setCellContent(model)
            return cell

        case .time :
            let cell: ChatTimeCell = tableView.dequeueReusableCell(ChatTimeCell.self)
            cell.setCellContent(model)
            return cell

        case .interior:
            return UITableViewCell()

        default:
            return UITableViewCell()
        }
    }
}
/// 消息是当前用户发出的，还是接收的
///
/// - toSelf: 消息发给当前用户
/// - toOthers: 消息发给别人
// swiftlint:disable identifier_name
enum ChatDirection: Int {
    case sendToSelf = 0
    case sendToOthers
}
enum ChatSendStatus: Int {
    case sending = 0
    case success
    case fail
}
class ChatMessageModel: BaseData {
    /// 消息标识
    var msg_id: Int64 = 0
    /// 会话标识
    var session_id: Int64 = 0
    /// 发送者
    var sender: Int64 = 0
    /// 群的pid
    var groupPid: Int64 = 0
    /// 发送者pid
    var sender_pid: Int64 = 0
    /// 接收者
    var receiver: Int64 = 0
    /// 接收者pid
    var receiver_pid: Int64 = 0
    /// 聊天类型
    var chat_type: Int = 0
    /// 文件名
    var filename: String = ""
    /// 消息类型
    var kind: Int = 0
    /// 服务器id
    var serverid: Int64 = 0
    /// 方向标记,标志己方是sender还是receiver
    var direction: Int = 1
    /// 未读标记
    var unread: Int = 0
    /// 未读标记
//    var unread_num: Int  = 0
    /// 已播放标记
    var played: Int = 0
    var notificationID = ""
    /// 已发送标记
    var send_state: Int = 0
    var category: Int = 0
    var online: Int = 0
    /// @人的集合
    var msg_users: String = ""
    /// 聊天内容
    var content: String = ""
    var resource: String = ""
    /// 客户端时间
    var client_time: String = ""
    /// 服务端时间
    var server_time: String = ""
    /// 发送回执，暂时没用
    var receipt: Int = 0
    /// 去重后确定是别人发给自己的新消息
    var otherNewMsg: Bool = false
    var avatar: String = ""
    var nickname: String = "未知"

    var imageHeight: CGFloat = 0
    var imageWidth: CGFloat = 0
    var duration: CGFloat = 0
    var audioID: String?
    var audioURL: String?
    var bitRate: String?
    var channel: String?
    var createTime: String?
    var filesize: String?
    var formatName: String?
    var keyHansh: String?
    var mimeType: String?

    //以下是为了配合 UI 来使用
    var fromMe: Bool {
        return ChatDirection(rawValue: self.direction) == ChatDirection.sendToOthers
    }

    lazy var thumbURL: String = {
        if self.content.isEmpty {
            return ""
        } else {
            return "\(self.content)?imageMogr2/thumbnail/125"
        }
    }()

    var localStoreName: String = ""  //拍照，选择相机的图片的临时名称
    var localThumbnailImage: UIImage? {  //从 Disk 加载出来的图片
        if localStoreName.isEmpty {
            let path = ImageFilesManager.cachePathForKey(localStoreName)
            return UIImage(contentsOfFile: path!)
        } else {
            return nil
        }
    }

    var localOriginalStoreName: String = "" //缓存原图
    var localoriginalStoreImage: UIImage? {  //从 Disk 加载出来的图片
        if localOriginalStoreName.isEmpty {
            let path = ImageFilesManager.cachePathForKey(localOriginalStoreName)
            return UIImage(contentsOfFile: path!)
        } else {
            return nil
        }
    }

    var cellHeight: CGFloat = 0
    var richTextLayout: YYTextLayout?
    var richTextLinePositionModifier: YYTextLinePositionModifier?
    var richTextAttributedString: NSMutableAttributedString?

    func isLateForThreeMinutes(timestamp: Int64) -> Bool {
        let nextSeconds = self.msg_id / 1_000
        let previousSeconds = timestamp / 1_000
        return abs(nextSeconds - previousSeconds) > 180
    }
}

class ChatSessionModel: BaseData {
    /// 消息标识
    var msg_id: Int64 = 0
    /// 会话标识
    var session_id: Int64 = 0
    /// 群pid
    var groupPid: Int64 = 0
    /// 发送者
    var sender: Int64 = 0
    /// 发送者pid
    var sender_pid: Int64 = 0
    /// 接收者
    var receiver: Int64 = 0
    /// 接受者pid
    var receiver_pid: Int64 = 0
    /// 聊天类型
    var chat_type: Int = 0
    /// 消息类型
    var msg_kind: Int = 0
    /// 未读标记
    var unread_num: Int = 0
    /// 未读提醒数量
    var unread_remind_num: Int = 0
    /// 方向标记,标志己方是sender还是receiver
    var direction: Int = 0
    /// 置顶标记
    var top: Int = 0
    /// 提醒标识
    var remind: Int = 0
    /// 草稿内容
    var draft_content: String = ""
    var update_time: String = ""
    /// 添加会话时间
    var add_time: String = ""
    /// 最后一条消息内容
    var last_content: String = ""
    /// 最后消息标识
    var last_msg_id: Int64 = 0
    /// 最后一条发送状态s
    var last_send_state: Int = 0

    var avatar: String = ""
    var nickname: String = ""
}
