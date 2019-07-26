//
//  SliderModel.swift
//  UIDS
//
//  Created by one2much on 2018/2/9.
//  Copyright © 2018年 one2much. All rights reserved.
//

import HandyJSON
import UIKit

//M2数据
class SwiperImageDataModel: BaseModel {
    var data: [SwiperImageData]?
}
class
        SwiperImageData: BaseModel {
    var fields: SwiperImageDataFields?
    var events: [String: EventsData]?
}
class SwiperImageDataFields: BaseData {
    var name: String?
    var title: String?
    var type: Int?
    var normalIcon: String?
    var index: Int?
    var selectedIcon: String?
}

//M1数据
class SwiperImageModel: BaseData {
    var fields: SwiperImageFieldsData?
    var items: [String: SwiperImageItemsData]?
    var styles: SwiperImageStylesData?

    var imgsArr: [SwiperImageItemsData] {
        let imgItems = self.items
        let itemNames = self.fields?.imageList ?? []
        var temArr = [SwiperImageItemsData]()
        for name in itemNames {
            temArr.append(imgItems?[name] ?? SwiperImageItemsData())
        }
        return temArr
    }
}

class SwiperImageFieldsData: BaseData {
    var imageList: [String]?
}
class SwiperImageItemsData: BaseData {
    var events: [String: EventsData]?
    var fields: SwiperImageItemsFieldsData?
    var styles: SwiperImageItemsStylesData?
}

class SwiperImageStylesData: BaseStyleModel {
    var switchStyle: Int?
    var bgImgIndicatorColorSel: String?
    var bgImgModeIndicatorColorSel: Int?
    var borderColor: String?
    var opacityIndicatorColor: Int?
    var bgImgIndicatorColor: String?
    var opacityIndicatorColorSel: Int?
    var bgColorIndicatorColor: String?
    var bgImgModeIndicatorColor: Int?
    var opacity: Int?
    var switchEffect: Int?
    var bgColorIndicatorColorSel: String?
    var borderShow: Int?
    var borderWidth: Int?
    var buttonPosition: Int?
    var switchTime: Double?
}

class SwiperImageItemsFieldsData: BaseData {
    var index: Int?
    var name: String?
    var title: String?
}

class SwiperImageItemsStylesData: BaseData {
    var normalIcon: String?
    var selectedIcon: String?
}
