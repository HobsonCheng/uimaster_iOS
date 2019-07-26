//
//  RecentConversationModel.swift
//  UIMaster
//
//  Created by hobson on 2018/8/20.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

class RecentConversationModel: BaseData {
    var events: [String: EventsData]?
    var fields: RecentConversationFields?
    var styles: RecentConversationStyles?
}
class RecentConversationFields: BaseData {
    var buttonImage: String?
    var buttonStyle: Int?
    var buttonTitle: String?
    var limitSwitch: Int?
    var more: Int?
}
class RecentConversationStyles: BaseStyleModel {
    var heightColumn: CGFloat?
    var limits: Int?
    var opacity: Int?
    var opacityList: Int?
    var splitterTypeList: String?
    var splitterWidthList: CGFloat?
    var bgImgList: String?
    var unreadMessageStyle: Int?
    var titleTitle: String?
    var borderColor: String?
    var borderShow: Int?
    var borderShowList: Int?
    var iconTitle: String?
    var splitterColorList: String?
    var bgImgModeList: Int?
    var borderWidth: CGFloat?
    var bgColorList: String?
    var colorListName: String?
    var splitterShowList: Int?
//    var splitterWidthList: CGFloat?
}
//class RecentConversationModel: BaseData{
//    var events: [String:EventsData]?
//    var fields: RecentConversationFields?
//    var styles: RecentConversationStyles?
//}
//class RecentConversationFields: BaseData{
//    var buttonImage: String?
//    var buttonStyle: Int?
//    var buttonTitle: String?
//    var limitSwitch: Int?
//    var more: Int?
//}
//class RecentConversationStyles: BaseData{
//    var heightColumn: CGFloat?
//    var limits: Int?
//    var opacity: Int?
//    var opacityList: Int?
//    var splitterTypeList: String?
//    var splitterWidthList: Int?
//    var bgImgList: String?
//    var unreadMessageStyle: Int?
//    var titleTitle: String?
//    var bgImg: String?
//    var borderColor: String?
//    var borderShow: Int?
//    var borderShowList: Int?
//    var iconTitle: String?
//    var radius: Int?
//    var splitterColorList: String?
//    var bgColor: String?
//    var bgImgModeList: Int?
//    var height: CGFloat?
//    var bgImgMode: Int?
//    var borderWidth: Int?
//    var bgColorList: String?
//}
