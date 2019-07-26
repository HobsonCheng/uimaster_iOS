//
//  OrderCModel.swift
//  UIDS
//
//  Created by one2much on 2018/1/26.
//  Copyright © 2018年 one2much. All rights reserved.
//

import HandyJSON
import UIKit
// swiftlint:disable identifier_name

class OrderCModel: BaseModel {
    var data: [OrderCData]!
}

struct OrderCData: HandyJSON {
    var add_time: String!
    var classify_id: Int!
    var classify_name: String!
    var form_status: Int!
    var id: Int!
    var notify_id: Int!
    var order_id: Int!
    var order_pid: Int!
    var order_time: String!
    var order_uid: Int!
    var order_header: String!
    var order_nickname: String!
    var order_user: OrderUser!
    var pid: Int!
    var platform_id: Int!
    var platform_uid: Int!
    var platform_name: String!
    var status: Int!
    var value: String!
    var form_user: OrderUser!
    var order_status: Int!
    var head_portrait: String!
    var user_name: String!
}

class OrderUser: BaseData {
    var birthday: String!
    var explanation: String!
    var gender: Int!
    var head_portrait: String!
    var id: Int!
    var interests: String!
    var labels: String!
    var nick_name: String!
    var pid: Int!
    var signature: String!
    var uid: Int!
    var zh_name: String!
    var user_name: String!
}
