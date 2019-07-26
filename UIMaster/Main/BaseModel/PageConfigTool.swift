//
//  PageConfigTool.swift
//  UIMaseter
//
//  Created by one2much on 2018/4/24.
//  Copyright © 2018年 one2much. All rights reserved.
//

import SwiftyJSON
import UIKit

///页面配置工具
class PageConfigTool {
    /// 所有页面信息
    var pageConfigList: [String: PageConfigData]?

    fileprivate static let singleton = PageConfigTool()

    /// tabbar
    var tabbar: TabbarConfigModel?

    /// 单例
    static var shared: PageConfigTool {
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
        let appID = GlobalConfigTool.shared.appId ?? 0
        self.readInfo(appID: appID)
        if self.pageConfigList != nil {
            return
        }
        //取出bundle中的UIAppinfo.json中的数据
        let file = FileHandle(forReadingAtPath: R.file.uiPageListJson.path() ?? "")
        let tmpData = file?.readDataToEndOfFile()
        guard let safeData = tmpData else {
            return
        }
        do {
            // 解析数据，获取appID
            let json = try JSON(data: safeData)
            let appID = GlobalConfigTool.shared.appId
            guard let safeID = appID else {
                return
            }

            //目标路径
            var desPath = SandboxTool.getFilePath(of: "", in: .applicationSupport, subPathStr: "com.one2much.app\(safeID)")
            desPath += kPageListJSON
            if SandboxTool.isFileExist(in: desPath) {
                return
            }
            //移动文件
            SandboxTool.moveBundleDataToLibrary(of: kPageListJSON, is: .text, desPath: .applicationSupportDirectory, subPathStr: "com.one2much.app\(safeID)")
            // 读取文件数据
            self.pageConfigList = PageConfigModel.deserialize(from: json.dictionaryObject)?.data
        } catch {
            dPrint(error)
        }
    }

    /// 当json数据变化时，重新读取数据
    ///
    /// - Parameter appID: 切换的AppID
    func readInfo(appID: Int) {
//        let path = Path.userApplicationSupport + "com.one2much.app\(appID)" + kPageListJSON
        let content = SandboxTool.readData(fileName: kPageListJSON, dir: .applicationSupport, subPath: "com.one2much.app\(appID)", type: SandboxFileType.text)
        let str = String(data: content, encoding: String.Encoding.utf8)
        let model = PageConfigModel.deserialize(from: str)
        self.pageConfigList = model?.data
    }
}

// MARK: 页面配置模型
class PageConfigModel: BaseModel {
    var data: [String: PageConfigData]?
}

class PageConfigData: BaseData {
    var styles: PageStyle?
    var fields: PageFields?
    var events: [String: EventsData]?
    var items: [String: Any]?
    var naviBar: NavibarConfigModel?
    var naviTab: NaviTabbarConfigModel?
    var tabBar: TabbarConfigModel?
    var buttons: SideMenuBtnConfigModel?
    var pageKey: String?
    var attachment: Any?

    ///tabbarItemsData
    var tabbarItemsData: [TabbarItems] {
        let tabbarData = self.tabBar
        let itemNames = tabbarData?.fields?.itemList ?? []
        let items = tabbarData?.items ?? [:]
        var temArr = [TabbarItems]()
        for name in itemNames {
            temArr.append(items[name] ?? TabbarItems())
        }
        return temArr
    }
    var leftPan: EventsData? {
        guard let events = self.events else {
            return nil
        }
        guard let leftPanEvent = events["leftPan"]  else {
            return nil
        }
        return leftPanEvent
    }
    var rightPan: EventsData? {
        guard let events = self.events else {
            return nil
        }
        guard let rightPanEvent = events["rightPan"]  else {
            return nil
        }
        return rightPanEvent
    }
}
// MARK: - 页面
class PageStyle: BaseData {
    var bgColor: String?
    var bgImg: String?
    var bgImgMode: Int?
}

class PageFields: BaseData {
    var version: String?
    var pageStyle: Int?
    var itemList: [String]?
    var canPullToRefresh: Int?
    var tempData: AnyObject?//特殊页面中保存值
    var isHiddenStatusBar: Int?
    var isLightContentStatusBar: Int?
    var naviBarShow: Int?
}
// MARK: - Navibar
class NavibarConfigModel: BaseData {
    var fields: NavibarFields?
    var styles: NaviBarStyle?
    var events: [String: EventsData]?
    var items: [String: NavibarItemsModel]?
}
class NavibarFields: BaseData {
    var leftItems: [String]?
    var middle: String?
    var rightItems: [String]?
}
class NaviBarStyle: BaseData {
    var bgColor: String?
    var bgImg: String?
    var bgImgMode: String?
    var fontSize: CGFloat?
    var color: String?
    var splitterColor: String?
    var splitterShow: Int?
    var splitterWidth: CGFloat?
    var heightNaviBar: CGFloat?
}
// MARK: Navibaritems
class NavibarItemsModel: BaseData {
    var events: [String: EventsData]?
    var fields: NavibarItemFields?
    var items: Any?
    var styles: NavibarItemStyle?
}
class NavibarItemFields: BaseData {
    var fonticon: String?
    var fonticonSel: String?
    var normalIcon: String?
    var selectedIcon: String?
    var title: String?
    var type: Int?
}
class NavibarItemStyle: BaseData {
    var color: String?
    var selColor: String?
    var bgColor: String?
    var fontSize: CGFloat?
    var imgWidth: CGFloat?
    var imgHeight: CGFloat?
    var itemHeight: CGFloat?
}
// MARK: naviTabbar
class NaviTabbarConfigModel: BaseData {
    var fields: NaviTabbarFields?
    var styles: NaviTabbarStyles?
    var items: [String: NaviTabbarItems]?
    var events: [String: EventsData]?

    var itemsData: [NaviTabbarItems]? {
        var arr = [NaviTabbarItems]()
        for name in self.fields?.itemList ?? [] {
            if let item = self.items?[name] {
                arr.append(item)
            }
        }
        return arr
    }
}
class NaviTabbarStyles: BaseData {
    var color: String?
    var colorSelected: String?
    var bgColor: String?
    var bgImg: String?
    var fontSize: CGFloat?
    var fontSizeSelected: CGFloat?
    var heightNaviTab: CGFloat?
    var selectStyle: Int?
}
class NaviTabbarFields: BaseData {
    var itemList: [String]?
}
class NaviTabbarItems: BaseData {
    var events: [String: EventsData]?
    var fields: NaviTabbarItemFields?
}
class NaviTabbarItemFields: BaseData {
    var title: String?
}
// MARK: 悬浮按钮
class SideMenuBtnConfigModel: BaseData {
    var fields: SideMenuBtnFieldsData?
    var items: [String: SideMenuBtnItemsData]?
    var events: [String: EventsData]?

    var itemsArr: [SideMenuBtnItemsData] {
        var arr = [SideMenuBtnItemsData]()
        for name in fields?.itemList ?? [] {
            if let item = self.items?[name] {
                arr.append(item)
            }
        }
        return arr
    }
}
class SideMenuBtnFieldsData: BaseData {
    var itemList: [String]?
}
class SideMenuBtnItemsData: BaseData {
    var events: [String: EventsData]?
    var fields: SideMenuBtnItemFieldsData?
    var styles: SideMenuBtnItemsStyle?
}
class SideMenuBtnItemFieldsData: BaseData {
    var name: String?
    var normalIcon: String?
    var selectedIcon: String?
    var title: String?
}
class SideMenuBtnItemsStyle: BaseData {
    var color: String?
    var colcolorSelected: String?
    var fontSize: CGFloat?
    var fontSizeSelected: CGFloat?
    var showType: Int?
    var textAlign: Int?
    var textAlignSelected: Int?
}
// MARK: - 状态栏
class StateBarStyleData: BaseData {
    var lightContent = false
}
