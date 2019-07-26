//
//  BaseModel.swift
//  UIDS
//
//  Created by one2much on 2018/1/15.
//  Copyright © 2018年 one2much. All rights reserved.
//

import HandyJSON
import UIKit

class BaseModel: NSObject, HandyJSON {
    var code: String?
    var msg: String?

    override required init() {}
}

class BaseData: NSObject, HandyJSON {
    override required init() {}
}

/// 给只需要解析data的json使用
class CommonModel: HandyJSON {
    var data: String?
    var code: String?
    var msg: String?

    required init() {}
}
