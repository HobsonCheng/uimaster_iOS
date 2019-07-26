//
//  OrgnizationStructModel.swift
//  UIMaster
//
//  Created by hobson on 2018/10/7.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit
// swiftlint:disable identifier_name
enum OrgnizationStructType {
    case level1
    case level2
    case user
}

class OrgnizationStructModel: BaseModel {
    var data: [OrgnizationStructData]?
}

class OrgnizationStructData: BaseData {
    var id: Int?
    var pid: Int64?
    var name: String?
    var parent_id: Int?
    var phone: String?
    var address: String?
    var position_x: String?
    var position_y: String?
    var zip_code: String?
    var add_time: String?
    var update_time: String?
    var `private`: Int?
    var child_num: Int?
    var status: Int?
    var url: String?
    var childDepartment: [OrgnizationStructData]?
    var childPeople: [OrgnizationStructData]?
    var uid: Int64?
    var post: String?
    var type: OrgnizationStructType?
    var head_portrait: String?
}

class OrgnizationConfigModel: BaseData {
    var events: [String: EventsData]?
//    var fields: AddressBookFields?
//    var styles: AddressBookStyles?
}
