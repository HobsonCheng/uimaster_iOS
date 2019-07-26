//
//  GroupModel.swift
//  UIDS
//
//  Created by bai on 2018/1/20.
//  Copyright © 2018年 one2much. All rights reserved.
// swiftlint:disable identifier_name

import UIKit
class GroupListTopicModel: BaseData {
    var events: [String: EventsData]?
    var fields: GroupListTopicFields?
    var styles: GroupListTopicStyles?
}
class GroupListTopicFields: BaseData {
    var text: String?
    var showTypeInfinite: Int?
    var getFunction: String?
}
class GroupListTopicStyles: BaseStyleModel {
    var iconTitle: String?
    var titleContent: String?
    var bgImgTitle: String?
    var colorDetail: String?
    var fontSizeName: CGFloat?
    var iconContent: String?
    var splitterColor: String?
    var splitterWidth: CGFloat?
    var maxCount: Int?
    var colorRightTitle: String?
    var fontSizeDetail: CGFloat?
    var colorName: String?
    var fontSizeRightTitle: CGFloat?
    var titleTitle: String?
    var colorTitle: String?
    var bgColorTitle: String?
    var bgImgModeTitle: Int?
    var heightTitle: CGFloat?
    var fontSizeTitle: CGFloat?
}

class GroupModel: BaseModel {
    var data: [GroupData]?
}
class SingleGroupModel: BaseModel {
    var data: GroupData?
}
class GroupData: BaseData {
    var add_time: String!
    var add_type: Int!
    var address: String!
    var area_id: Int!
    var attachment: Int!
    var block_id: Int!
    var build_uid: Int64!
    var can_out: Int!
    var can_share: Int!
    var can_subscribe: Int!
    var city_id: Int!
    var classify_id: Int!
    var country_id: Int!
    var current_top: Int!
    var master_id: Int?
    var group_stencil: Int!
    var group_type: Int!
    var hasSign_in: Int!
    var id: Int!
    var identify: Int!
    var index_id: String!
    var index_pic: String!
    var introduction: String!//简介
    var invitation_authority: Int!
    var invitation_num: Int?
    var invitation_types: String!
    var labels: String!
    var max_bm: Int!
    var max_top: Int!
    var max_user: Int!
    var name: String!//标题
    var name_code: Int!
    var payPerpetual_money: Int!
    var payTemporary_money: String!
    var pay_type: Int!
    var pid: Int!
    var pro_id: Int!
    var replay_authority: Int!
    var reply_authority: Int!
    var score_rule: String!
    var status: Int!
    var update_time: String!
    var use_jurisdiction: Int!
    var user_authority: Int!
    var user_num: Int!
    var x_coord: Int!
    var y_coord: Int!
    var member_id: Int!
}
