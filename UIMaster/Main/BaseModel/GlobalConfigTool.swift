//
//  GlobleStyle.swift
//  UIMaseter
//
//  Created by one2much on 2018/4/23.
//  Copyright © 2018年 one2much. All rights reserved.
//

import HandyJSON
import SwiftyJSON
import UIKit

/// 全局样式
class GlobalConfigTool {
    /// 所有的全局数据
    var globalData: GlobalData? {
        didSet {
            self.appId = self.globalData?.appId
            self.groupId = self.globalData?.groupId
            self.tabbar = self.globalData?.tabBar
            self.leftSideslip = self.globalData?.leftPan
            self.rightSideslip = self.globalData?.rightPan
            self.menuModel = self.globalData?.menus
            self.bottomPan = self.globalData?.bottomPan
            self.global = self.globalData?.global
        }
    }

    /// appID
    var appId: Int?
    /// pid
    var pid: Int = 22
    var name: String = "一几网络"
    var icon: String = "http://up.uidashi.com/Frt9qHdTOVerCA7PW3Qdn5MlKIfR"
    /// groupID
    var groupId: Int?
    /// tabbar
    var tabbar: TabbarConfigModel?

    ///tabbar按钮
    var tabbarItemsData: [TabbarItems] {
        let tabbarData = self.tabbar
        let itemNames = tabbarData?.fields?.itemList ?? []
        let items = tabbarData?.items ?? [:]
        var temArr = [TabbarItems]()
        for name in itemNames {
            temArr.append(items[name] ?? TabbarItems())
        }
        return temArr
    }
    var global: GlobalPageModel?
    ///气泡
    var menuModel: [String: MenuModel]?
    ///侧滑
    var leftSideslip: SideslipModel?
    var rightSideslip: SideslipModel?
    ///弹出层
    var bottomPan: BottomPanModel?

    fileprivate static let singleton = GlobalConfigTool()
    /// 单例
    static var shared: GlobalConfigTool {
        return singleton
    }

    fileprivate init() {
        if AppUtil.isTest {
            return
        }
        initData()
    }

    //创建文件夹，并移动文件数据
    fileprivate func initData() {
        //判断之前有没进入过其他APP
        let currentAPPID = getUserDefaults(key: kCurrentAPPID) as? Int
        if let id = currentAPPID {
            readInfo(appID: id)
            saveUserDefaults(key: kCurrentAPPID, value: id)
            return
        }
        //取出bundle中的UIAppinfo.json中的数据
        let file = FileHandle(forReadingAtPath: R.file.uiAppInfoJson.path() ?? "")
        let tmpData = file?.readDataToEndOfFile()
        guard let safeData = tmpData else {
            return
        }
        do {
            // 解析数据，获取appID
            let json = try JSON(data: safeData).dictionary?["data"]
            let appID = json?.dictionary?["appId"]?.intValue
            guard let safeID = appID else {
                return
            }
            //目标路径
            var desPath = SandboxTool.getFilePath(of: "", in: .applicationSupport, subPathStr: "com.one2much.app\(safeID)")
            SandboxTool.createDir(path: desPath)
            desPath += kAppInfoJSON
            if SandboxTool.isFileExist(in: desPath) {
                return
            }
            //移动文件
            SandboxTool.moveBundleDataToLibrary(of: kAppInfoJSON, is: .text, desPath: .applicationSupportDirectory, subPathStr: "com.one2much.app\(safeID)")
            // 读取文件数据
            self.globalData = GlobalData.deserialize(from: json?.dictionaryObject)
            //保存当前AppID
            saveUserDefaults(key: kCurrentAPPID, value: appID ?? 0)
        } catch {
            dPrint(error)
        }
    }

    /// 当json数据变化时，重新读取数据
    ///
    /// - Parameter appID: 切换的AppID
    func readInfo(appID: Int) {
        let content = SandboxTool.readData(fileName: kAppInfoJSON, dir: .applicationSupport, subPath: "com.one2much.app\(appID)", type: SandboxFileType.text)
        let str = String(data: content, encoding: String.Encoding.utf8)
        let model = GlobalModel.deserialize(from: str)
        self.globalData = model?.data
    }
}

// MARK: - 全局模型
class GlobalModel: BaseModel {
    var data: GlobalData?
}
class GlobalData: BaseData {
    var appId: Int?
    var groupId: Int?
    var global: GlobalPageModel?
    var tabBar: TabbarConfigModel?
    var leftPan: SideslipModel?
    var rightPan: SideslipModel?
    var bottomPan: BottomPanModel?
    var menus: [String: MenuModel]?
    var naviBar: NavibarConfigModel?
}
class GlobalPageModel: BaseData {
    var events: [String: EventsData]?
    var pages: [String: String]?
    var host: String?
    var version: String?
    var welcome: Int?
    var loginPageKey: String {
        return pages?["Login"] ?? ""
    }
    var articlePageKey: String {
        return pages?["Article"] ?? ""
    }
    var personalCenterPageKey: String {
        return pages?["Person"] ?? ""
    }
    var groupChatKey: String {
        return pages?["GroupChat"] ?? ""
    }
    var friendApply: String {
        return pages?["ApplyFriend"] ?? ""
    }
    var searchProject: String {
        return pages?["SearchProject"] ?? ""
    }
}
// MARK: - tabbar
class TabbarConfigModel: BaseData {
    var fields: TabbarFields?
    var styles: TabbarStyles?
    var items: [String: TabbarItems]?
}
class TabbarFields: BaseData {
    var itemList: [String]?
}
class TabbarStyles: BaseData {
    var bgImg: String?
    var bgImgMode: String?
    var bgColor: String?
    var borderShow: Int?
    var borderWidth: Int?
    var borderColor: String?
    var heightTabBar: CGFloat?
}
// MARK: - tabbar的item
class TabbarItems: BaseData {
    var events: [String: EventsData]?
    var fields: TabbarItemsFields?
    var styles: TabbarItemStyle?
}
class TabbarItemsFields: BaseData {
    var title: String?
    var normalIcon: String?
    var selectedIcon: String?
}
class TabbarItemStyle: BaseData {
    var tabBarStyle: Int?
    var color: String?
    var colorSelected: String?
    var fontSize: CGFloat?
    var fontSizeSelected: CGFloat?
}
// MARK: - 底部浮层
class BottomPanModel: BaseData {
    var styles: BottomPanStyles?
    var events: [String: EventsData]?
    var fields: BottomPanFields?
}
class BottomPanFields: BaseData {
    var buttonImage: String?
    var buttonStyle: Int?
    var buttonTitle: String?
    var sliderText: Int?
}
class BottomPanStyles: BaseData {
    var fontSizeSelected: CGFloat?
    var opacityClose: Int?
    var splitterColor: String?
    var bgColor: String?
    var bgImg: String?
    var bgImgClose: String?
    var bgImgCover: String?
    var fontSize: CGFloat?
    var splitterType: String?
    var splitterWidth: Int?
    var textAlign: Int?
    var opacity: Double?
    var showType: Int?
    var bgColorClose: String?
    var bgImgMode: Int?
    var closePosition: Int?
    var heightClose: CGFloat?
    var panHeight: CGFloat?
    var bgImgModeClose: Int?
    var bgImgModeCover: Int?
    var color: String?
    var bgColorCover: String?
    var colorSelected: String?
    var opacityCover: Double?
    var splitterShow: Int?
    var textAlignSelected: Int?
}
// MARK: - 侧滑页
class SideslipModel: BaseData {
    var events: [String: EventsData]?
    var fields: SideslipFieldsData?
    var styles: SideslipStylesData?
}
class SideslipFieldsData: BaseData {
    var showLeft: Int?
    var showRight: Int?
}
class SideslipStylesData: BaseData {
    var leftWidth: CGFloat?
    var rightWidth: CGFloat?
    var showType: Int?
}
// MARK: - 气泡菜单
class MenuModel: BaseData {
    var fields: MenuFields?
    var styles: MenuStyles?
    var items: [String: MenuItems]?
}
class MenuFields: BaseData {
    var itemList: [String]?
}
class MenuStyles: BaseData {
    var bgColor: String?
    var color: String?
    var bgImg: String?
    var bgImgMode: Int?
    var bgImgModelSelected: Int?
    var bgImgSelected: String?
    var colorSelected: String?
    var fontSize: Int?
    var fontSizeSelected: Int?
    var heightMenus: Int?
    var menuStyle: Int?
    var opacity: CGFloat?
    var opacitySelected: CGFloat?
    var splitterColor: String?
    var splitterWidth: CGFloat?
    var bgColorSelected: String?
    var arrowType: Int?
    var textAlignment: Int?
    var showType: Int?
    var widthMenus: CGFloat?
}
class MenuItems: BaseData {
    var events: [String: EventsData]?
    var fields: MenuItemFields?
}
class MenuItemFields: BaseData {
    var title: String?
    var normalIcon: String?
    var selectedIcon: String?
    var iconfont: String?
}
// MARK: - 事件
class EventsData: BaseData {
    var action: Int?
    var menu: String?
    var name: String?
    var pageKey: String?
    var pageMode: Int?
    var type: Int?
    var url: String?
    var androidDownUrl: String?
    var iosAppId: String?
    var iosDownUrl: String?
    var iosIcon: String?
    var iosSchema: String?
    var module: String?
    var groupPid: Int?
    var groupInvitationId: Int?
    ///特殊事件携带数据
    var attachment = [String: Any]()
    ///左侧滑时的pageKey
    var leftPanKey: String?
    ///右侧滑时的pageKey
    var rightPanKey: String?
}
