//
//  EventUtil.swift
//  UIMaster
//
//  Created by YJHobson on 2018/5/12.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Kingfisher
import UIKit

// MARK: - 事件
let kClickEvent = "click"//点击事件
let kMoreEvent = "more"//更多事件
let kSingleEvent = "single"//liebiao
let kPrivacySettings = "privacySettings"
let kPersonalDetails = "detail"//个人详情事件
let kPostList = "post"//发帖事件
let kGroupEvent = "group"//群组事件
let kFriendsEvent = "friend"//好友事件
let kChatEvent = "chat"//聊天事件
let kFunEvent = "fan"//粉丝事件
let kFollowEvent = "follow"//关注列表事件
let kMessageList = "message"//消息列表事件
let kGroupEdit = "edit"//编辑群组事件
let kResetPassword = "accountSecurity"//重置密码
let kRetrievePassword = "retrieve" //找回密码
let kHeadEvent = "head"//头像
let kAboutUsInWeb = "aboutUs"//关于我们
let kSearchProject = "searchProject"
let kUserProtocolInWeb = "userProtocol"//用户协议
let kFeedback = "feedback"//意见反馈事件
let kAgreement = "agreement"//注册协议
let kArticleEvent = "article"//文章详情
let kPersonEvent = "person" //个人中心
let kDepartmentEvent = "department" //部门详情
let kContact = "contact"//联系人
let kOneEvent = "one"//单条

/// 事件类型
enum EventType: Int {
    case none = -1//无事件
    case page = 0// 页面
    case action//1 动作
    case menu//2 气泡菜单
    case url// url
    case modal// 底部弹出层
    case app// 其他app
    case article//文章详情
}

// 页面的类型
enum PageType: Int {
    case nobar = 0
    case navibar //单导航
    case naviTab // 导航标签
    case naviAndTab // 导航+标签
    case tabbar //tabbar
}

enum ActionType: Int {
    case back = 0
    case refresh = 1
    case loadMore = 2
    case leftPan = 3
    case rightPan = 4
    case toTop = 5
    case share = 6
    case save = 1_004//创建
    case post = 1_002//发表
    case deleteArticel = 1_005
    case updatePersonInfo = 1_003//更新个人信息
}

///事件结果返回
class EventResult {
    ///设置好pageKey的页面结果
    var newPageVC: NaviBarVC?
    ///气泡菜单
    var popOverView: PopOverView?
    ///modal视图
    var modalVC: AssembleVC?
}

///处理事件
class EventUtil: UIShareAble {
    // 底部弹出层key
    static var bottomPanKey: String?

    /// 处理事件顶层方法
    ///
    /// - Parameters:
    ///   - event: 需处理的事件
    /// - Returns: 事件结果
    static func handleEvents(event: EventsData?) -> EventResult {
        let eventResult = EventResult()
        guard let safeEvent = event else {
            return eventResult
        }
        switch EventType(rawValue: safeEvent.type ?? 0) ?? .page {
        case .none:
            dPrint("无事件")
            break
        case .page:
            eventResult.newPageVC = handlePageEvent(event: safeEvent)
        case .action:
            handleActionEvent(event: safeEvent)
        case .menu:
            eventResult.popOverView = handleMenuEvent(event: safeEvent)
        case .url:
            handleUrl(event: safeEvent)
        case .app:
            handleApp(event: safeEvent)
        case .modal:
           eventResult.modalVC = handleModal(event: safeEvent)
        case .article:
            hanleArticleEvent(event: safeEvent)
        }
        return eventResult
    }
}
// MARK: - 文章详情页
extension EventUtil {
    static func hanleArticleEvent(event: EventsData) {
        dPrint("当前是文章详情事件")
        let articlePageKey = GlobalConfigTool.shared.global?.articlePageKey
        guard let safePageKey = articlePageKey else {
            HUDUtil.debugMsg(msg: "没有该页面", type: .error)
            return
        }
        guard let pageModel = getPageModel(byKey: safePageKey) else {
            HUDUtil.debugMsg(msg: "没有找到页面数据", type: .info)
            return
        }
        let topicData = TopicData()
        topicData.id = event.groupInvitationId
        topicData.group_pid = event.groupPid
        pageModel.attachment = [TopicData.getClassName: topicData]
        let vc = AssembleVC(pageModel: pageModel)
        VCController.push(vc, with: VCAnimationClassic.defaultAnimation())
    }
}
// MARK: - 底部弹层modal 事件
extension EventUtil {
    private static func handleModal(event: EventsData) -> AssembleVC? {
        dPrint("当前是modal弹出层事件")
        guard let pageKey = bottomPanKey else {
            HUDUtil.debugMsg(msg: "没有该页面", type: .error)
            return nil
        }
        guard let pageModel = getPageModel(byKey: pageKey) else {
            HUDUtil.debugMsg(msg: "没有找到页面数据", type: .info)
            let vc = AssembleVC()
            vc.isFloatingMenu = true
            return vc
        }
        let vc = AssembleVC(pageModel: pageModel)
        vc.isFloatingMenu = true
        return vc
    }
}

// MARK: - 气泡菜单 事件
extension EventUtil {
    ///通过event对象处理menu气泡
    private static func handleMenuEvent(event: EventsData) -> PopOverView? {
        dPrint("当前是弹出气泡事件")
        //数据模型
        guard let menuModel = GlobalConfigTool.shared.menuModel else {
            return nil
        }
        //取出对应的menu数据
        let menuName = event.menu ?? ""
        let menuData = menuModel[menuName]
        //获得menu配置项
        let config = generateConfig(styles: menuData?.styles)
        //获得menu
        let menu = generateMenu(fields: menuData?.fields, items: menuData?.items, styles: menuData?.styles, config: config)
        return menu
    }
    //生成气泡menu
    private static func generateMenu(fields: MenuFields?, items: [String: MenuItems]?, styles: MenuStyles?, config: PopOverVieConfiguration?) -> PopOverView? {
        guard let safeFields = fields else {
            return nil
        }
        guard let safeItems = items else {
            return nil
        }
        //通过名字从字典中取出item
        let itemNames = safeFields.itemList ?? []
        var itemArr = [MenuItems]()
        for itemName in itemNames {
            itemArr.append(safeItems[itemName] ?? MenuItems())
        }
        // 生成popview
        let height = itemArr.count * (styles?.heightMenus ?? 35)
        let popView = PopOverView(bounds: CGRect(x: 0, y: 0, width: Int(styles?.widthMenus ?? 100), height: height), config: config, itemArr: itemArr, type: styles?.showType ?? 4)
        return popView
    }

    /// 配置项
    private static func generateConfig(styles: MenuStyles?) -> PopOverVieConfiguration? {
        guard let safeStyles = styles else {
            return nil
        }
        let config = PopOverVieConfiguration()
        config.isNeedAnimate = true
        config.separatorColor = safeStyles.splitterColor?.toColor()
        config.textColor = safeStyles.color?.toColor()
        switch safeStyles.textAlignment {
        case 0:
            config.textAlignment = .left
        case 1:
            config.textAlignment = .center
        case 2:
            config.textAlignment = .right
        default:
            break
        }
        config.font = UIFont.systemFont(ofSize: CGFloat(safeStyles.fontSize ?? 15))
        config.defaultRowHeight = Float(safeStyles.heightMenus ?? 35)
//        config.containerViewCornerRadius = Float(safeStyles.radius ?? 0)
        config.selectColor = safeStyles.bgColorSelected?.toColor() ?? .lightGray
        config.tableBackgroundColor = safeStyles.bgColor?.toColor()
        config.alignStyle = CPAlignStyle(rawValue: safeStyles.arrowType ?? 0) ?? .center
        // TODO: 加一个bool值判断是否显示小三角比如：showTri
        config.triAngelHeight = 0
        config.triAngelWidth = 0
        return config
    }
}

// MARK: - 页面
extension EventUtil {
    //处理页面类型的事件
    private static  func handlePageEvent(event: EventsData) -> NaviBarVC? {
        return handleNewPage(pageKey: event.pageKey, attachment: event.attachment)
    }

    static func handleNewPage(pageKey: String?, attachment: [String: Any]?) -> NaviBarVC? {
        let pageModel = getPageModel(byKey: pageKey)
        guard let safeModel = pageModel else {
            HUDUtil.debugMsg(msg: "没有找到该页面", type: .info)
            return nil
        }
        switch safeModel.fields?.pageStyle ?? 0 {
        case PageType.navibar.rawValue:
            let vc = AssembleVC(pageModel: safeModel)
            vc.pageParams = attachment ?? [:]
            return vc
        case PageType.naviAndTab.rawValue:
            let vc = PageVC(pageModel: safeModel)
            vc.pageModel = pageModel
            vc.pageParams = attachment ?? [:]
            return vc
        case PageType.naviTab.rawValue:
            let vc = PageVC(pageModel: safeModel)
            vc.pageModel = pageModel
            vc.pageParams = attachment ?? [:]
            vc.showOnNavigationBar = true
            return vc
        case PageType.tabbar.rawValue:
            let vc = PageVC(pageModel: safeModel)
            vc.showOnBottom = true
            vc.pageParams = attachment ?? [:]
            VCController.push(vc, with: VCAnimationClassic.defaultAnimation())
            return nil
        default:
            let vc = AssembleVC(pageModel: safeModel)
            vc.pageParams = attachment ?? [:]
            return vc
        }
    }
    ///通过pagekey获得pageModel
    static func getPageModel(byKey pageKey: String?) -> PageConfigData? {
        guard let safeKey = pageKey else {
            return nil
        }
        let pageList = PageConfigTool.shared.pageConfigList ?? [:]
        let pageModel = pageList[safeKey]
        return pageModel
    }

    static func gotoPage(with pageKey: String, attachment: [String: Any]? = nil) {
        let vc = handleNewPage(pageKey: pageKey, attachment: attachment)
        if vc == nil {
            return
        }
        VCController.push(vc, with: VCAnimationClassic.defaultAnimation())
    }
}
// MARK: - 动作
extension EventUtil {
    private static func handleActionEvent(event: EventsData) {
        guard let action = event.action else {
            return
        }
        switch action {
        case ActionType.back.rawValue:
            VCController.pop(with: VCAnimationClassic.defaultAnimation())
        case ActionType.leftPan.rawValue:
            kMainVC.showLeftSlider(isShow: true)
        case ActionType.rightPan.rawValue:
            kMainVC.showRightSlider(isShow: true)
        case ActionType.save.rawValue:
            NotificationCenter.default.post(name: Notification.Name(rawValue: kSaveNotification), object: event.module)
        case ActionType.post.rawValue:
            let postNotification = Notification(name: Notification.Name(rawValue: kPostNotification), object: event.module, userInfo: nil)
            NotificationCenter.default.post(postNotification)
        case ActionType.updatePersonInfo.rawValue:
            let postNotification = Notification(name: Notification.Name(rawValue: kUpdatePersonalInfoNotification), object: event.module, userInfo: nil)
            NotificationCenter.default.post(postNotification)
        case ActionType.share.rawValue:
            handleShareAction(with: event)
        case ActionType.deleteArticel.rawValue:
            NotificationCenter.default.post(name: Notification.Name(kDeleteArticleNotification), object: nil)
        default:
            HUDUtil.msg(msg: "未知的动作类型", type: .info)
        }
    }

    ///处理右侧滑
    private static func handleRightSlidePage(pageKey: String?) {
        guard GlobalConfigTool.shared.rightSideslip?.fields?.showRight == 1 else {
            HUDUtil.msg(msg: "没有开启右侧滑页", type: .info)
            return
        }
        guard let vc = handleNewPage(pageKey: pageKey, attachment: nil) else {
            HUDUtil.debugMsg(msg: "没有找到该页面", type: .error)
            initRightSideslip(with: AssembleVC())
            kMainVC.showRightSlider(isShow: true)
            return
        }
        initRightSideslip(with: vc)
        kMainVC.showRightSlider(isShow: true)
    }

    ///处理左侧滑
    private static func handleLeftSlidePage(pageKey: String?) {
        guard GlobalConfigTool.shared.leftSideslip?.fields?.showLeft == 1 else {
            HUDUtil.msg(msg: "没有开启左侧滑页", type: .info)
            return
        }
        kMainVC.showLeftSlider(isShow: true)
    }

    //左侧滑
    static func initLeftSideslip(with vc: NaviBarVC) {
        let leftSideslipModel = GlobalConfigTool.shared.leftSideslip
        //左侧滑
//        if hasInitLeftPan {
//            kMainVC.update(left: vc)
//        }else
        if leftSideslipModel?.fields?.showLeft == 1 {
            let rate = leftSideslipModel?.styles?.leftWidth ?? 0.5
            vc.widthRate = rate
            vc.isHideNaviBar = true
            vc.isHandleStatusBar = false
            if leftSideslipModel?.styles?.showType == 1 {//推开
                kMainVC.set(left: vc, mode: .rearWidthRate(rWidthR: rate))
            } else {//盖住
                kMainVC.set(left: vc, mode: .frontWidthRate(fWidthR: rate))
            }
        } else {
            kMainVC.draggable = false
        }
    }

    //右侧滑
    static func initRightSideslip(with vc: NaviBarVC) {
        let rightSideslipModel = GlobalConfigTool.shared.rightSideslip
        //右侧滑
//        if hasInitRightPan {
//            kMainVC.update(right: vc)
//        }else
            if rightSideslipModel?.fields?.showRight == 1 {
            let rate = rightSideslipModel?.styles?.rightWidth ?? 0.5
            vc.widthRate = rate
            vc.isHideNaviBar = true
            vc.isHandleStatusBar = false
            if rightSideslipModel?.styles?.showType == 1 {//推开
                kMainVC.set(right: vc, mode: .rearWidthRate(rWidthR: rate))
            } else {//盖住
                kMainVC.set(right: vc, mode: .frontWidthRate(fWidthR: rate))
            }
        } else {
            kMainVC.draggable = false
        }
    }

    //分享
    private static func handleShareAction(with event: EventsData) {
        let infoDic = Bundle.main.infoDictionary
        let appVersion = infoDic?["CFBundleVersion"] as? String ?? ""
        let name = infoDic?["CFBundleDisplayName"] as? String ?? ""

        NetworkUtil.request(target: .forceUpdateVersion(app_id: GlobalConfigTool.shared.globalData?.appId ?? 0, version: GlobalConfigTool.shared.global?.version ?? "", app_version: appVersion), success: { json in
            let versionData = VersionModel.deserialize(from: json)?.data
            let logo = ImageCache.default.retrieveImageInDiskCache(forKey: kLogoCacheKey)
            shareToOthersStatic(text: name, imageName: nil, orImage: logo, linkStr: versionData?.url)
        }) { error in
            dPrint(error)
        }
    }
}
// MARK: - URL
extension EventUtil {
    private static func handleUrl(event: EventsData) {
        if (event.url == nil || event.url == "") {
            HUDUtil.msg(msg: "空的url", type: .error)
            return
        }
        let otherweb = OtherWebVC(name: "webview")
        otherweb.urlString = (event.url == nil || event.url == "") ? "https://www.one2much.com" : event.url
        VCController.push(otherweb, with: VCAnimationClassic.defaultAnimation())
    }
}
// MARK: - 打开App
extension EventUtil {
    private static func handleApp(event: EventsData) {
        let scheme = event.iosSchema ?? ""
        if let url = URL(string: scheme) {
            let result = UIApplication.shared.canOpenURL(url)
            if result {//ok
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    })
                } else {
                    UIApplication.shared.openURL(url)
                }
            } else {
                HUDUtil.msg(msg: "暂未安装该app", type: .info)
            }
        }
    }
}
extension EventUtil {
    /// 触发得到的事件结果
    ///
    /// - Parameters:
    ///   - result: 事件结果
    ///   - delegate: 气泡菜单代理
    static func eventTrigger(with result: EventResult, on view: UIView?, delegate: PopOverViewDelegate?) {
        if let safeVc = result.newPageVC {
            if safeVc.title == "发帖"{
                VCController.push(safeVc, with: VCAnimationBottom.defaultAnimation())
            } else {
                VCController.push(safeVc, with: VCAnimationClassic.defaultAnimation())
            }
        } else if let safeMenu = result.popOverView {
            safeMenu.show(from: view)
            safeMenu.delegate = delegate
        } else if let safeModal = result.modalVC {
            VCController.push(safeModal, with: VCAnimationBottom.defaultAnimation())
        }
    }
}
