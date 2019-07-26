//
//  InitiatorModel.swift
//  UIDS
//
//  Created by one2much on 2018/2/12.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

//M2 数据
class LaunchPadDataModel: BaseData {
    var data: [LaunchPadData]?
}
class LaunchPadData: BaseData {
    var fields: LaunchPadDataFields?
    var events: [String: EventsData]?
}
class LaunchPadDataFields: BaseData {
    var selectedIcon: String?
    var name: String?
    var title: String?
    var type: Int?
    var normalIcon: String?
    var index: Int?
}

//数据模型
class LaunchPadModel: BaseData {
    var fields: LaunchPadFields?
    var styles: LaunchPadStyle?
}
class LaunchPadFields: BaseData {
    var sliderTab: Int?
    var sliderText: Int?
}

class LaunchPadStyle: BaseStyleModel {
    var gap: CGFloat?
    var fontSize: CGFloat?
    var bgImgIndicator: String?
    var bgImgModeIndicator: Int?
    var opacityIndicator: Int?
    var showTypeRow: Int?
    var textAlign: Int?
    var bgColorIndicator: String?
    var showTypeShape: Int?
    var bgImgIndicatorSel: String?
    var color: String?
    var showTypeColumn: Int?
    var bgColorIndicatorSel: String?
    var bgImgModeIndicatorSel: Int?
    var borderShow: Int?
}
