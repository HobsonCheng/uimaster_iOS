//
//  AdressBookModel.swift
//  UIMaster
//
//  Created by hobson on 2018/8/20.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

class AddressBookModel: BaseData {
    var events: [String: EventsData]?
    var fields: AddressBookFields?
    var styles: AddressBookStyles?
}
class AddressBookFields: BaseData {
    var controlNumberInfinite: Int?
    var more: Int?
    var buttonTitle: String?
}
class AddressBookStyles: BaseStyleModel {
    var bgImgModeTitle: Int?
    var fontSizeName: CGFloat?
    var fontSizeTitleMore: CGFloat?
    var textAlignName: Int?
    var bgImgTitle: String?
    var borderColor: String?
    var colorTime: String?
    var heightTitle: CGFloat?
    var bgColorTitle: String?
    var colorAbstract: String?
    var heightList: CGFloat?
    var splitterColorTitle: String?
    var textAlignAbstract: Int?
    var barsNumber: Int?
    var colorTitle: String?
    var colorTitleMore: String?
    var fontSizeTitle: CGFloat?
    var showShape: Int?
    var splitterTypeList: String?
    var bgImgModeList: Int?
    var splitterShowList: Int?
    var splitterWidthList: CGFloat?
    var bgImgList: String?
    var fontSizeTime: CGFloat?
    var splitterColorList: String?
    var splitterTypeTitle: String?
    var splitterWidthTitle: CGFloat?
    var fontSizeAbstract: CGFloat?
    var splitterShowTitle: Int?
    var bgColorList: String?
    var colorName: String?
    var title: String?
    var buttonStyle: Int?
    var buttonImage: String?
}
