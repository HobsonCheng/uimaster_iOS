//
//  PrivacySetModel.swift
//  UIMaster
//
//  Created by YJHobson on 2018/7/23.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

class PrivacySetModel: BaseData {
    var data: PrivacySetData?
}
// swiftlint:disable identifier_name
class PrivacySetData: BaseData {
    var pid: Int?
    var info_id: Int?
    var friend_answer: String?
    var uid: Int?
    var friend_question: String?
    var friend_apply: Int?
    var status: Int?
    var message_authority: String?
    var friend_authority: String?
    var browse_authority: String?
    var notice: String?
    var add_time: String?
    var follow_authority: Int?
    var group_authority: Int?
    var guest_authority: String?
}
