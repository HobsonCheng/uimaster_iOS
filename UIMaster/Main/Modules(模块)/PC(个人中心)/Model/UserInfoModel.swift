//
//  UserInfoModel.swift
//  UIDS
//
//  Created by one2much on 2018/1/16.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit
// swiftlint:disable identifier_name
class UserInfoModel: BaseModel {
    var data: UserInfoData?
}

class UserInfoData: BaseData {
    var birthday: String?
    var explanation: String?//简介 说明
    var gender: Int?
    var head_portrait: String?//头像
    var id: Int?
    var interests: String?
    var labels: String?
    var login_name: String?//账号
    var nick_name: String?//昵称
    var pid: Int64?
    var signature: String?//个性签名
    var uid: Int64?
    var appkey: String?
    var add_time: String?
    var header: String?
    var status: Int?
    var update_time: String?
    var user_code: String?
    var user_code_code: Int?
    var user_name: String?
    var username_code: Int?
    var zh_name: String?
    var admin: Int?
    var black_num: Int?
    var browse_num: Int?
    var company_id: Int?
    var email: String?
    var faculty_id: Int?
    var fan_num: Int?
    var follow_num: Int?
    var friend_num: Int?
    var follow_status: Int?
    var is_friend: Int?

    var state_last_update: String?
    var trade_id: Int?

    var relations: [Relation]?

    var authorization: String?
}

class RC4KeyModel: BaseModel {
    var data: RC4KeyData?
}
class RC4KeyData: BaseData {
    var interval: Int?
    var key: String?
    var persistent: Int?
}
class UserListModel: BaseModel {
    var data: [UserInfoData]?
}
class RelationModel: BaseModel {
    var data: [Relation]?
}
class Relation: BaseData {
    var add_time: String?
    var color: String?
    var icon: String?
    var id: Int?
    var num: Int?
    var order_number: Int?
    var pid: Int?
    var relation_name: String?
    var relation_type: Int?
    var relation_url: String?
    var type_define: Int?
    var status: Int?
    var uid: Int?
}
