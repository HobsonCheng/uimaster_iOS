//
//  UserUtil.swift
//  UIDS
//
//  Created by one2much on 2018/1/19.
//  Copyright © 2018年 one2much. All rights reserved.
//

import KeychainAccess
import SwiftyJSON
import UIKit

private var userIdentifier: String {
    return kAuthorization + "\(GlobalConfigTool.shared.appId ?? 0)"
}

class UserUtil: NSObject, JsonCacheAble {
    var appUserInfo: UserInfoData?

    //存储登录信息
    static let share = UserUtil()

    override private init() {
        super.init()
    }

    // MARK: 是否登录
    /// 是否已登录
    ///
    /// - Returns: 是否已登录
    static func isValid() -> Bool {
        let authoration = getUserDefaults(key: userIdentifier)
        dPrint("登录授权码：\(authoration ?? "")")
        if authoration != nil {
            return true
        }
        return false
    }

    static func getGroupId() -> Int {
        //TODO: 分群组
        let global = GlobalConfigTool.shared.globalData
        return global?.groupId ?? 0
//        if isValid(){
//            return appInfo?.app_group_info?[1].group_id ?? 0
//        }else{
//            return appInfo?.app_group_info?[0].group_id ?? 0
//        }
    }

    /// 保存用户信息
    ///
    /// - Parameter userInfo: 用户信息json
    func saveUser(userInfo: String?) {
        if userInfo?.isEmpty ?? true {
            return
        }
        self.appUserInfo = UserInfoModel.deserialize(from: userInfo)?.data
        cacheJson(key: userIdentifier, json: userInfo)
    }

    /// 从缓存中取出用户信息
    ///
    /// - Parameter callback: 用户信息初始化后的回调
    func initUserInfo(callback:@escaping () -> Void) {
        getCacheJson(key: userIdentifier) { [weak self] json in
            self?.appUserInfo = UserInfoModel.deserialize(from: json)?.data
            callback()
        }
    }

    /// 移除用户数据
    func removerUser() {
        // 停止轮询
        IMService.shared.pausePolling()
        removeUserDefaults(key: kLastMessageID)
        removeUserDefaults(key: kAuthorization + "\(GlobalConfigTool.shared.appId ?? 0)")
        self.appUserInfo = nil
        //移除缓存的json
        removeCacheForKey(key: ContactsVC.getClassName)
        removeCacheForKey(key: OrgnizationStruct.getClassName)
        removeCacheForKey(key: kPCRelatios)

        removeCacheForKey(key: userIdentifier)
        NotificationCenter.default.post(name: Notification.Name(kLogoutNotification), object: nil)
    }

    func signout(finish:@escaping ((_ success: Bool) -> Void)) {
        if UserUtil.isValid() {
            // 退出登录
            let keychain = Keychain(service: "com.one2much.uuid")
            let uuid = keychain["deviceuuid"] ?? ""
            NetworkUtil.request(
                target: .setUserOffline(device_id: uuid),
                success: { _ in
                    NetworkUtil.request(
                        target: .userLogout,
                        success: {[weak self] _ in
                            //不是刷新本单位App 不需要移除用户数据
                            self?.removerUser()
                            //移除前一个App的用户信息
                            let appID = getUserDefaults(key: kCurrentAPPID) as? Int
                            removeUserDefaults(key: kAuthorization + "\(appID ?? 0)")
                            finish(true)
                        }
                    ) { error in
                        finish(false)
                        HUDUtil.msg(msg: "退出账号失败请重试", type: .error)
                        dPrint(error)
                    }
                }
            ) { error in
                finish(false)
                HUDUtil.msg(msg: "退出账号失败请重试", type: .error)
                dPrint(error)
            }
        } else {
            finish(true)
        }
    }
}
