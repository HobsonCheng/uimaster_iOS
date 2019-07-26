//
//  ReplyModel.swift
//  UIDS
//
//  Created by one2much on 2018/1/24.
//  Copyright © 2018年 one2much. All rights reserved.
// swiftlint:disable identifier_name

import UIKit

class ArticleDetailsModel: BaseData {
    var events: [String: EventsData]?
    var fields: ArticleDetailsFields?
    var status: Int?
    var styles: ArticleDetailsStyles?
}
class ArticleDetailsFields: BaseData {
    var head: Int?
    var collection: Int?
    var comment: Int?
    var commentList: Int?
    var forward: Int?
    var time: Int?
    var title: Int?
    var admin: Int?
    var commentFarm: Int?
    var fans: Int?
    var nickName: Int?
    var back: Int?
    var adminTime: Int?
    var column: Int?
    var like: Int?
    var optionsMenu: Int?
}
class ArticleDetailsStyles: BaseStyleModel {
    var lineHight: Int?
    var opacityOptionButton: Int?
    var borderWidth: Int?
    var bgImgOptionButton: String?
    var borderColor: String?
    var contentLineHight: Int?
    var opacity: Int?
    var borderShow: Int?
    var bgColorOptionButton: String?
    var bgImgModeOptionButton: Int?
    var buttonStyle: Int?
}

class ReplyModel: BaseModel {
    var data: ReplyData?
}
class ReplyListModel: BaseModel {
    var data: [ReplyData]!
}

class ReplyData: BaseData {
    var add_time: String!
    var address: String!
    var area_id: Int!
    var block_id: Int!
    var build_uid: Int!
    var reply_pid: Int64?
    var reply_uid: Int64?
    var city_id: Int!
    var content: String!
    var country_id: Int!
    var group_id: Int!
    var group_pid: Int?
    var id: Int!
    var index_id: String!
    var invitation_id: Int!
    var invitation_pid: Int?
    var last_version: Int!
    var parent_id: Int!
    var praised: Int?
    var pid: Int!
    var praise_num: Int!
    var pro_id: Int!
    var reply: [ReplyData]?
    var reply_id: Int!
    var reply_num: Int!
    var status: Int!
    var topic_id: Int!
    var use_signature: Int!
    var user_authority: Int!
    var user_info: UserInfoData!
    var x_coord: Int!
    var y_coord: Int!
    var reply_user_name: String?
    /// 缓存行高
    var rowHeight: CGFloat = 0
    /// 缓存回复高度 add by gcz 2018-08-22 02:00:04
    var replyHeight: CGFloat = 0
}
