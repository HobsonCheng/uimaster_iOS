//
//  AppInfo.swift
//  UIMaseter
//
//  Created by gongcz on 2018/4/19.
//  Copyright © 2018年 one2much. All rights reserved.
//

import CoreLocation
import UIKit

class AppInfo {
    var coordinate = CLLocationCoordinate2D()
    var city = ""
    var code = ""

    private static let singleSelf = AppInfo()

    static func shareAppInfo() -> AppInfo {
        return singleSelf
    }

    fileprivate init() {
        code = "110105"
        city = "北京市"
    }

    /// 获取当前App所占屏幕的大小
    ///
    /// - Returns: 返回屏幕大小
    class func appFrame() -> CGRect {
        return (UIApplication.shared.delegate as? AppDelegate)?.window?.frame ?? .zero
    }

    /// 版本号
    class var systemVersion: String {
        return UIDevice.current.systemVersion
    }

    /// 给出URL不包含Scheme header的部分，根据所使用的客户端天假Scheme头
    ///
    /// - Parameter string: URL除去Scheme头的部分
    /// - Returns: 返回添加了Scheme Header后的URL字符串
    class func appIPhoneSchemeString(_ string: String?) -> String? {
        let UIMasterString = "UIMaster://\(string ?? "")"
        return UIMasterString
    }
}
