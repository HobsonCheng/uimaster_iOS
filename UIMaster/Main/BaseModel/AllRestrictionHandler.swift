//
//  AllRestrictionHandler.swift
//  UIDS
//
//  Created by one2much on 2018/2/7.
//  Copyright © 2018年 one2much. All rights reserved.

import UIKit

class AllRestrictionHandler {
    var ucSetConfig: AllRestrictionData?

    private static let shareAHandler = AllRestrictionHandler()
    static var shared: AllRestrictionHandler {
        return shareAHandler
    }

    fileprivate init() {
        init_ucSetConfig()
    }

    func init_ucSetConfig() {
        readInfo()
//        let params = NSMutableDictionary()
//        params.setValue(5, forKey: "pid")
//
//        ApiUtil.share.allRestriction(params: params) { [weak self] (_, data, _) in
//
//            //迁移写入指定文件
//            if data != nil {
//                self?.ucSetCofig = AllRestrictionModel.deserialize(from: data)?.data
//
//            }
//        }

    }

    // MARK: 读取本地json数据
    func readInfo() {
        //如果数据不存在，直接退出
        guard SandboxTool.isFileExist(of: kUCSetInfoJSON, in: .library) else {
            return
        }
        //读取文件数据
        let file = FileHandle(forReadingAtPath: SandboxTool.getFilePath(of: kUCSetInfoJSON, in: .library))
        let tmpData = file?.readDataToEndOfFile()
        if let safeData = tmpData {
            let jsonStr = String(data: safeData, encoding: String.Encoding.utf8)
            //转成数据模型
            self.ucSetConfig = AllRestrictionModel.deserialize(from: jsonStr)?.data
        }
    }
}

// MARK: - model
// swiftlint:disable identifier_name
class AllRestrictionModel: BaseData {
    var code: String?
    var data: AllRestrictionData?
    var key: String?
    var msg: String?
}
class AllRestrictionData: BaseData {
    var project_set: ProjectSet?
    var regist_qualified: [RegistQualified]?
    var register_agreement: String?
}

class RegistQualified: BaseData {
    var add_time: String?
    var id: Int?
    var pid: Int?
    var qualified_content: String?
    var qualified_place: Int?
    var qualified_type: Int?
    var status: Int?
    var update_time: String?
}

class ProjectSet: BaseData {
    var auth_code_login: Int?
    var can_login: String?
    var change_password_long: Int?
    var encrypted_set_num: Int?
    var login_auth_code: Int?
    var login_auth_code_before: Int?
    var login_auth_code_type: Int?
    var login_err: String?
    var old_password_num: Int?
    var only_phone: Int?
    var pid: Int?
    var pwd_combination: Int?
    var pwd_condition: String?
    var pwd_min_bit: Int?
    var regist_auth_code: Int?
    var regist_auth_code_before: Int?
    var regist_auth_code_type: Int?
    var regist_condition: String?
    var regist_invite: Int?
    var regist_type: Int?
    var retrieve_password_code: Int?
    var retrieve_password_encrypted_num: Int?
    var retrieve_password_way: String?
    var security_pwd_type: Int?
}
// swiftlint:enable identifier_name
