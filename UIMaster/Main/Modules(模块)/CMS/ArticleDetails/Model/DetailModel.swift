//
//  DetailModel.swift
//  UIMaster
//
//  Created by hobson on 2018/7/31.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Foundation
// swiftlint:disable identifier_name
class DetailModel: BaseModel {
    var data: DetailData?
}

class DetailData: BaseData {
    var add_time: String!
    var address: String!
    var all_val_num: Int!
    var area_id: Int!
    var attachment: Int!
    var attachment_download: Int!
    var attachment_size: Int!
    var attachment_value: String!
    var best: Int!
    var block_id: Int!
    var build_uid: Int!
    var can_delete: Int!
    var can_out: Int!
    var can_replay: Int!
    var can_reply: Int!
    var can_see_reply: Int!
    var can_store: Int!
    var city_id: Int!
    var content: String!
    var country_id: Int!
    var group_id: Int!
    var group_invitation_id: Int!
    var group_pid: Int!
    var id: Int!
    var identify: Int!
    var index_id: String!
    var intra_id: Int!
    var invitation_type: Int!
    var is_empty: Int!
    var labels: String!
    var last_read_url: String!
    var last_reply_time: String!
    var last_version: Int!
    var pay_perpetual_money: Int!
    var pay_temporary_money: String!
    var pay_type: Int!
    var pid: Int!
    var praise_num: Int!
    var praised: Int!
    var pro_id: Int!
    var read_num: Int!
    var remarks: String!
    var replay: String!
    var replay_num: Int!
    var source: String!
    var source_pid: Int!
    var status: Int!
    var store_num: Int!
    var subclass: Int!
    var summarize: String!
    var task: String!
    var title: String!
    var topic_id: Int!
    var topic_pid: Int!
    var update_time: String!
    var use_signature: Int!
    var user_authority: Int!
    var user_info: UserInfoData?
    var vote: String!
    var x_coord: Int!
    var y_coord: Int!
}
