//
//  GlobalConst.swift
//  UIMaseter
//
//  Created by gongcz on 2018/4/12.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

// MARK: - 布局参数
/// 适配iPhoneX的状态栏高度
let kStatusBarHeight: CGFloat = kIsiPhoneX ? 44.0 : 20.0
/// 适配iPhoneX的导航栏高度
let kNavigationBarHeight: CGFloat = kIsiPhoneX ? 88.0 : 64.0
/// 适配iPhoneX的tabBar高度
let kTabBarHeight: CGFloat = kIsiPhoneX ? 49.0 + 34.0 : 49.0
/// home indicator
let kScreenFrame = (UIApplication.shared.delegate as? AppDelegate)?.window?.frame ?? .zero
let kiPhoneXBottomH: CGFloat = kIsiPhoneX ? 34.0 : 0.0
let kiPhoneXTopH: CGFloat = kIsiPhoneX ? 24.0 : 0.0
// 屏幕宽度
let kScreenH = UIScreen.main.bounds.height
// 屏幕高度
let kScreenW = UIScreen.main.bounds.width
//是否是iPhoneX
let kIsiPhoneX = (kScreenW >= 375.0 && kScreenH >= 812.0 ? true : false)
//屏幕
enum ScreenType {
    case small
    case middle
    case big
}

let kScreenType: ScreenType = {
    if kScreenW <= 320.0 {
        return .small
    } else if kScreenW <= 375.0 {
        return .middle
    } else {
       return .big
    }
}()

//log
func dPrint(_ item: @autoclosure() -> Any, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    print("\(file.split(separator: "/").last?.split(separator: ".").first ?? ""):(\(line))\(item())")
    #else
    #endif
}
// MARK: 存储 user set 信息
func saveUserDefaults(key: String, value: Any?) {
    let userDefault = UserDefaults.standard

    userDefault.set(value, forKey: key)
    userDefault.synchronize()
}

func getUserDefaults(key: String) -> Any? {
    let userd = UserDefaults.standard
    return userd.object(forKey: key)
}

func removeUserDefaults(key: String) {
    let userd = UserDefaults.standard
    userd.removeObject(forKey: key)
    userd.synchronize()
}

var kLogoCacheKey: String {
    let aid = GlobalConfigTool.shared.appId ?? 0
    let pid = GlobalConfigTool.shared.pid
    return "logo\(aid)_\(pid)"
}

// MARK: - 常用颜色
///主题色
var kThemeColor = UIColor(hexString: "#2298ef")
/** 白色*/
let kThemeWhiteColor = UIColor(hexString: "0xFFFFFF")
/** 白烟色*/
let kThemeWhiteSmokeColor = UIColor(hexString: "0xF5F5F5")
/** 亮灰色*/
let kThemeGainsboroColor = UIColor(hexString: "0xF3F4F5")
/**  橙红色*/
let kThemeOrangeRedColor = UIColor(hexString: "0xFF4500")
/** 雪白色*/
let kThemeSnowColor = UIColor(hexString: "0xFFFAFA")
/** 浅灰色*/
let kThemeLightGreyColor = UIColor(hexString: "0xD3D3D3")
/** 深灰色*/
let kThemeGreyColor = UIColor(hexString: "0xA9A9A9")
/** 联合国蓝*/
let kThemeTomatoColor = UIColor(hexString: "0x5c92e0")
/** 暗灰色*/
let kThemeDimGrayColor = UIColor(hexString: "0x696969")
/** 黑色*/
let kThemeBlackColor = UIColor(hexString: "0x000000")
/** 沙漠白*/
let kThemeBackgroundColor = UIColor(hexString: "0xF4F4F4")
/** 星空灰*/
let kThemeTitielColor = UIColor(hexString: "0x9E9E9E")
/** 导航栏默认背景色*/
let kNaviBarBackGroundColor = UIColor(hexString: "#0094f3")

// MARK: - 名字
let kAppInfoJSON = "UIAppInfo.json"
let kPageListJSON = "UIPageList.json"
let kUCSetInfoJSON = "UCSetInfo.json"
let kTabbarIcon = "tabBar_icon_1@2x.png"
let kAuthorization = "Authorization_"
let kPCRelatios = "PCRelatios"
let kPCInfo = "PCInfo"
let kRC4Key = "RC4Key"
let kLastMessageID = "lastMessageID"
let kCurrentAPPID = "currentAPPID"

// MARK: - URL
let kQinuiTokenUrl = "https://pic.uidashi.com/getuptoken"
let kAppVersion = "KEY_APP_VERSION"
var kBaseUrl: String?

// MARK: - 通知
let kSaveNotification = "saveNotification"
let kPostNotification = "PostNotification"
let kUpdatePersonalInfoNotification = "UpdatePersonalInfoNotification"
let kResetPasswordNotification = "ResetPasswordNotification"
let kDidCommentNotification = "didCommentNotification"//发表评论通知
let kPostListRefreshNotification = "PostListRefreshNotification"
let kPersonalInfoChangeNotification = "personalInfoChangeNotification"
let kReloadGroupNotification = "reloadGroupNotification"//刷新群组通知
let kNoMoreDataNotification = "noMoreDataNotification"//没有更多数据
let kLogoutNotification = "logoutNotification"//退出登录通知
let kBeginCommentNotification = "beginCommentNotification"//开始评论的通知
let kGroupInfoChangeNotification = "groupInfoChangeNotification"//群信息更改
let kChatSessionListDataChange = "chatSessionListDataChange"// session列表修改了
let kChatAddMessageNotification = "chatAddMessageNotification"// message列表修改了
let kChatMessageSingleDataChage = "chatMessageSingleDataChage"// message单条消息修改
let kChatSessionSingleDataChage = "chatSessionSingleDataChage"// message单条消息修改
let kDeleteArticleNotification = "deleteArticleNotification"// 删除帖子
let kChatGroupInfoChangeNotification = "chatGroupInfoChangeNotification" //群信息更新
let kImageCodeUpdate = "imageCodeUpdate"//图形验证码错误

// MARK: - VC
///主vc 里面是tabbarvc
var kMainVC = MainVC()//这里只是给个默认值，会在ViewController里赋值，为了不用解包
///window的rootvc
let kWindowRootVC = UIApplication.shared.keyWindow?.rootViewController
///根VC window的rootvc
var kRootBaseVC: BaseNameVC = VCController.shared.rootBaseVController ?? BaseNameVC()
///当前tabbar选中的vc
var kCurrentTabbarVC = NaviBarVC()
///当前的VC
var kCurrentVC = VCController.getTopVC()
///当前pageModel
var kCurrentPageModel = PageConfigData()
///window
var kWindow = UIApplication.shared.keyWindow ?? UIWindow()
/// tabbarVC
var kMainTabbarVC: MainTabbarVC?
