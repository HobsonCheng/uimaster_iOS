//
//  GroupDetailModel.swift
//  UIMaster
//
//  Created by hobson on 2018/12/1.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit

class GroupDetailModel: BaseData {
    var events: [String: EventsData]?
    var fields: GroupDetailFields?
    var status: Int?
    var styles: GroupDetailStyles?
}
class GroupDetailStyles: BaseStyleModel {
    var bgImgItem: String?
    var bgImgModeItem: Int?
    var borderWidth: CGFloat?
    var opacity: Int?
    var opacityItem: Int?
    var bgColorItem: String?
    var borderColor: String?
    var borderShow: Int?
}
class GroupDetailFields: BaseData {
    var personalNumber: Int?
    var postNumber: Int?
}
