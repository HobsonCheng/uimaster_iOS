//
//  SearchModel.swift
//  UIDS
//
//  Created by one2much on 2018/2/2.
//  Copyright © 2018年 one2much. All rights reserved.
//
// swiftlint:disable identifier_name

import HandyJSON
import UIKit

struct SearchModel: HandyJSON {
    var data: SearchData!
}

struct SearchData: HandyJSON {
    //FIXME: projects 改为
    var data_list: [Project]!
    var total: Int!
}

struct ProjectList: HandyJSON {
    var data: [Project]!
}

struct Project: HandyJSON {
    /** app名 */
    var name: String?
    /** app添加时间 */
    var add_time: String!
    /** app icon */
    var icon: String!
    /** 公司名 */
    var pname: String!
    /** app组信息 */
    var app_group_info: [AppGroupInfo]!
    var register_name: String!
    var register_phone: String!
    var app_id: Int?
    var pid: Int?
    var host: String?
}
class AppGroupInfo: BaseData {
    /** app id */
    var app_id: Int?
    /** 组 id */
    var group_id: Int?
    /** 组类别 */
    var group_type: Int?
    /** app名字 */
    var app_name: String?
    var pid: Int?//projectID
}
