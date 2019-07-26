//
//  ConfigModel.swift
//  UIDS
//
//  Created by one2much on 2018/1/15.
//  Copyright © 2018年 one2much. All rights reserved.
//

import HandyJSON
import UIKit

class BaseConfigModel: BaseData {
    var events: [String: EventsData]?
    var styles: BaseStyleModel?
}

/// 抽取出的样式数据模型
class BaseStyleModel: BaseData {
    var bgColor: String?
    var bgImg: String?
    var marginLeft: CGFloat?
    var marginRight: CGFloat?
    var marginTop: CGFloat?
    var marginBottom: CGFloat?
    var height: CGFloat?
    var radius: CGFloat?
    var bgImgMode: Int?
    var heightSwipImgArea: CGFloat?
}
