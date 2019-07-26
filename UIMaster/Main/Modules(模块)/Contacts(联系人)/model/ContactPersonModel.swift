//
//  ContactPersonModel.swift
//  UIMaster
//
//  Created by hobson on 2018/10/15.
//  Copyright © 2018 one2much. All rights reserved.
//

import Foundation
import HandyJSON
class ContactPersonModel: BaseModel {
    var data: [ContactPersonData]?
}
// swiftlint:disable identifier_name
@objc class ContactPersonData: NSObject, HandyJSON {
    var name: String?
    var telephone: String?
    var user_id: Int64?
    var full_name: String?
    var head_portrait: String?
    var user_pid: Int64?
    var is_friend: Int?
    var is_colleague: Int?

    @objc func compareContact(_ contactModel: ContactPersonData) -> ComparisonResult {
        let result = full_name?.compare(full_name!)
        return result!
    }

    override required init() {
    }
}
