//  AppDelegate.swift
//  UIMaseter
//
//  Created by one2much on 2018/4/9.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Alamofire
import AMapLocationKit
import Bugly
import IQKeyboardManagerSwift
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    /// 网络状态管理职
    private let networkManager = NetworkReachabilityManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //初始化跟控制器
        rootControllerInit()
        //申请通知权限
        applyNotificationPermission()
        //初始化bugly
        buglyInit()
        //初始化IQ键盘
        IQKeyboardInit()
        //监测网络状态
        networkListening()
        //初始化定位
        AMapServices.shared().apiKey = "bb2ab1ce7ae870b27f135beea139621e"
        //初始化讯飞
        let IFlyAppID = "5c401cba"
        IFlySpeechUtility.createUtility("appid=\(IFlyAppID)")
        //显示硬件设备信息
        showDevicePerformance()
        //InjectionIII
        #if DEBUG
        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
        #endif
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        IMService.shared.isNeedSound = false
    }

    func applicationWillTerminate(_ application: UIApplication) {
        #if DEBUG
        GDPerformanceMonitor.sharedInstance.stopMonitoring()
        #endif
        IMService.shared.resetBadgeNum()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        guard UserUtil.isValid() else {
            application.applicationIconBadgeNumber = 0
            return
        }
        IMService.shared.resetBadgeNum()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if UserUtil.isValid() {
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            IMService.shared.requestUnreceiptMessage()
        }
    }
}

// MARK: - 推送
extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //token转字符串
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        // 跟后台连接
        IMService.shared.connectToServer(token: token)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //        IMService.shared.startService(serviceType: .polling)
        dPrint(error.localizedDescription)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //获取消息的内容
        let content = userInfo["aps"] as? [String: Any]
        // 获取消息的id
        let id = content?["msg_id"] as? String ?? ""
        // 如果消息不存在，再去请求消息
        switch application.applicationState {
        case UIApplicationState.active://应用在前台
            IMService.shared.isNeedSound = true
            IMService.shared.requestUnreceiptMessage()
        case UIApplicationState.inactive://点击进入
            IMService.shared.notificationID = id
        case .background:
            break
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }

    /// 申请通知权限
    func applyNotificationPermission() {
        let unCenter = UNUserNotificationCenter.current()
        unCenter.delegate = self
        unCenter.requestAuthorization(options: UNAuthorizationOptions(rawValue: UNAuthorizationOptions.alert.rawValue + UNAuthorizationOptions.sound.rawValue + UNAuthorizationOptions.badge.rawValue)) { _, _ in }
    }
}

// MARK: - 调试工具初始化
extension AppDelegate {
    func showDevicePerformance() {
        #if DEBUG
        //        手机信息提示
        //        GDPerformanceMonitor.sharedInstance.startMonitoring()
        //        GDPerformanceMonitor.sharedInstance.configure(configuration: { (textLabel) in
        //            textLabel?.backgroundColor = UIColor.init(white: 0, alpha: 0.6)
        //            textLabel?.textColor = .white
        //            textLabel?.layer.borderColor = UIColor.black.cgColor
        //            textLabel?.font = UIFont.systemFont(ofSize: 10)
        //        })
        //        // 隐藏版本号
        ////        GDPerformanceMonitor.sharedInstance.appVersionHidden = true
        ////        GDPerformanceMonitor.sharedInstance.deviceVersionHidden = true
        //        LifetimeTracker.setup(onUpdate: LifetimeTrackerDashboardIntegration(visibility: .alwaysVisible, style: .bar).refreshUI)
        #endif
    }

    /// 初始化根控制器
    func rootControllerInit() {
        window = UIWindow()
        window?.backgroundColor = .white
        let rootVc = StartViewController()
        window?.rootViewController = rootVc
        window?.makeKeyAndVisible()
    }

    /// 初始化 IQKeyboard
    func IQKeyboardInit() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
    }

    /// bugly初始化
    func buglyInit() {
        let buglyConfig = BuglyConfig()
        buglyConfig.reportLogLevel = .warn
        buglyConfig.debugMode = true
        buglyConfig.blockMonitorEnable = true
        buglyConfig.blockMonitorTimeout = 1.5
        Bugly.start(withAppId: "31d83ca04f", config: buglyConfig)
    }

    /// 检测网络状态
    func networkListening() {
        networkManager?.listener = { status in
            switch status {
            case .notReachable:
                HUDUtil.msg(msg: "网络好像出了点问题~~", type: .info)
                DispatchQueue.main.async {
                    HUDUtil.stopLoadingHUD(callback: nil)
                }
            case .unknown:
                //如果登录了就注册推送
                if UserUtil.isValid() {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                dPrint("~~未知的网络~~")
            case .reachable(.ethernetOrWiFi):
                //如果登录了就注册推送
                if UserUtil.isValid() {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                dPrint("~~wifi")
            case .reachable(.wwan):
                //如果登录了就注册推送
                if UserUtil.isValid() {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                dPrint("~~流量")
            }
        }
        networkManager?.startListening()
    }
}

// MARK: - scheme唤起App
extension AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.scheme == "uimaster" { /// 是通过快捷方式点进来的
            switch url.host {
            case "invitation"://邀请进群
                inviteToChatGroup(with: url)
            case "open": //打开App
                openApp(with: url)
            default:
                break
            }
        }
        return true
    }

    /// 外链启动App邀请进群
    ///
    /// - Parameter url: 唤起App的链接
    func inviteToChatGroup(with url: URL) {
        //1. 解析数据
        var inviteCode = ""
        var groupJson = ""
        if let components = URLComponents(string: url.absoluteString) {
            let items = components.queryItems ?? []
            for item in items {
                if item.name == "code"{
                    inviteCode = item.value ?? ""
                }
                if item.name == "info"{
                    groupJson = item.value?.removingPercentEncoding ?? ""
                }
            }
        }
        guard let groupModel = ChatGroupDetailData.deserialize(from: groupJson) else { return }
        //2. 数据库插入
        DatabaseTool.shared.insertChatGroupInfo(chatGroupInfo: groupModel)
        //3. 发送请求添加
        ChatHelper.applyForChatGroup(code: inviteCode, groupModel: groupModel)
    }
    /// 通用端切换APP
    ///
    /// - Parameter url: 唤起的链接
    func openApp(with url: URL) {
        UserUtil.share.signout { finish in
            if finish {
                var appID = 0
                var projectID = 0
                var name = ""
                var icon = ""
                if let components = URLComponents(string: url.absoluteString) {
                    let items = components.queryItems ?? []
                    for item in items {
                        if item.name == "AID"{
                            appID = Int(item.value ?? "") ?? 0
                        }
                        if item.name == "PID"{
                            projectID = Int(item.value ?? "") ?? 0
                        }
                        if item.name == "name"{
                            name = item.value ?? ""
                        }
                        if item.name == "icon"{
                            icon = item.value ?? ""
                        }
                    }
                }
                if SandboxTool.isFileExist(of: "", in: .applicationSupport, subPath: "com.one2much.app\(appID)") {//直接加载
                    let id = GlobalConfigTool.shared.appId ?? 0
                    if id == appID {//1.就是当前的App
                        return
                    } else {//2.不是当前的App加载本地已保存数据
                        let vc = RefreshDataVC()
                        DiskCacheHelper.getObj(HistoryKey.HistoryKeyPhone) { obj in
                            if obj != nil {
                                let tmpObj: String = obj as? String ?? ""
                                let modelList = ProjectList.deserialize(from: tmpObj) ?? ProjectList(data: [Project]())
                                for model in modelList.data {
                                    if model.app_id == appID && model.pid == projectID {//本地已有数据，直接加载
                                        vc.pObj = model
                                        VCController.push(vc, with: VCAnimationClassic.defaultAnimation())
                                        return
                                    }
                                }
                            }
                            var model = Project()
                            model.app_id = appID
                            model.pid = projectID
                            model.name = name
                            model.icon = icon
                            vc.pObj = model
                            DispatchQueue.main.async {
                                VCController.push(vc, with: VCAnimationClassic.defaultAnimation())
                            }
                        }
                    }
                } else {//跳到下载页下载
                    let vc = RefreshDataVC()
                    DiskCacheHelper.getObj(HistoryKey.HistoryKeyPhone) { obj in
                        if obj != nil {
                            let tmpObj: String = obj as? String ?? ""
                            let modelList = ProjectList.deserialize(from: tmpObj) ?? ProjectList(data: [Project]())
                            for model in modelList.data {
                                if model.app_id == appID && model.pid == projectID {//本地已有数据，直接加载
                                    vc.pObj = model
                                    VCController.push(vc, with: VCAnimationClassic.defaultAnimation())
                                    return
                                }
                            }
                        }
                        var model = Project()
                        model.app_id = appID
                        model.pid = projectID
                        model.name = name
                        model.icon = icon
                        vc.pObj = model
                        DispatchQueue.main.async {
                            VCController.push(vc, with: VCAnimationClassic.defaultAnimation())
                        }
                    }
                }
            } else {
                return
            }
        }
    }
}
