//
//  AppModel.swift
//  UIMaster
//
//  Created by hobson on 2018/8/17.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

/// app数据模型
class AppModel: BaseData {
    var alone: Int?
    var appID: Int?
    var test: Int?
    var projectID: Int?
}

class AppVersion: BaseModel {
    var data: Int?
}
enum AppUtil {
    /// 根据App.json,返回是不是独立端
    ///
    /// - Returns: 当前是不是独立端
    static var isAlone: Bool = {
        let fileName = SandboxTool.getFilePath(of: "App.json", in: .bundle)
        let file = FileHandle(forReadingAtPath: fileName)
        let tmpData = file?.readDataToEndOfFile()
        let jsonStr = String(data: tmpData!, encoding: String.Encoding.utf8)
        let isAlone = AppModel.deserialize(from: jsonStr)?.alone
        return isAlone == 1 ? true : false
    }()
    /// 根据App.json,是不是测试环境
    ///
    /// - Returns: 当前是测试环境还是打包环境
    static var isTest: Bool = {
        let fileName = SandboxTool.getFilePath(of: "App.json", in: .bundle)
        let file = FileHandle(forReadingAtPath: fileName)
        let tmpData = file?.readDataToEndOfFile()
        guard let safeData = tmpData else {
            return false
        }
        let jsonStr = String(data: safeData, encoding: String.Encoding.utf8)
        let isTest = AppModel.deserialize(from: jsonStr)?.test
        return isTest == 1 ? true : false
    }()

    /// 获取App的ID
    static var appID: Int? = {
        let fileName = SandboxTool.getFilePath(of: "App.json", in: .bundle)
        let file = FileHandle(forReadingAtPath: fileName)
        let tmpData = file?.readDataToEndOfFile()
        guard let safeData = tmpData else {
            return nil
        }
        let jsonStr = String(data: safeData, encoding: String.Encoding.utf8)
        let appID = AppModel.deserialize(from: jsonStr)?.appID
        return appID
    }()
    /// 获取App的ID
    static var projectID: Int? = {
        let fileName = SandboxTool.getFilePath(of: "App.json", in: .bundle)
        let file = FileHandle(forReadingAtPath: fileName)
        let tmpData = file?.readDataToEndOfFile()
        guard let safeData = tmpData else {
            return nil
        }
        let jsonStr = String(data: safeData, encoding: String.Encoding.utf8)
        let appID = AppModel.deserialize(from: jsonStr)?.projectID
        return appID
    }()

    static func addToScreen(appID: Int, pid: Int, name: String, icon: String) {
        let name = name.addingPercentEncoding(withAllowedCharacters: .letters) ?? ""
        let icon = icon.addingPercentEncoding(withAllowedCharacters: .letters) ?? ""
        guard let url = URL(string: "http://m.uidashi.com/#/ios?aid=\(appID)&pid=\(pid)&name=\(name)&icon=\(icon)") else {
            HUDUtil.msg(msg: "无法找到资源", type: .error)
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            HUDUtil.msg(msg: "无法找到资源", type: .error)
        }
    }
}
