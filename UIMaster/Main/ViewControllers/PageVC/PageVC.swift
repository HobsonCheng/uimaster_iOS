//
//  PageVC.swift
//  UIMaseter
//
//  Created by gongcz on 2018/4/25.
//  Copyright © 2018年 one2much. All rights reserved.
//

import SwiftyJSON
import UIKit

class PageVC: PageController {
    override init(pageModel: PageConfigData) {
        super.init(pageModel: pageModel)
        self.dataSource = self
        self.delegate = self
        self.pageAnimatable = true
        //设置导航标签栏
        setNaviTab()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
//        kRootBaseVC.isHiddeStatesBar = self.pageModel?.fields?.isHiddenStatusBar == 1
//        kRootBaseVC.statusBarStyle = self.pageModel?.fields?.isLightContentStatusBar == 1 ? .lightContent : .default
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //设置导航栏
        configureNavibar()
    }

    /// 配置标签栏
    func setNaviTab() {
        // 导航标签
        if self.pageModel?.fields?.pageStyle == 3 {//双栏
            //标签栏背景色
            self.menuBGColor = self.pageModel?.naviTab?.styles?.bgColor?.toColor() ?? .clear
            self.menuView?.backgroundColor = self.pageModel?.naviTab?.styles?.bgColor?.toColor() ?? kThemeSnowColor
            //标签栏高度
            self.menuHeight = self.pageModel?.naviTab?.styles?.heightNaviTab ?? 35
            //背景图
            self.imgUrl = self.pageModel?.naviTab?.styles?.bgImg
        }
        //文字颜色
        self.titleColorNormal = self.pageModel?.naviTab?.styles?.color?.toColor() ?? kThemeBlackColor
        self.titleColorSelected = self.pageModel?.naviTab?.styles?.colorSelected?.toColor() ?? kThemeOrangeRedColor
        //文字大小
        self.titleSizeNormal = self.pageModel?.naviTab?.styles?.fontSize ?? 14
        self.titleSizeSelected = self.pageModel?.naviTab?.styles?.fontSizeSelected ?? 16
        //选中样式
        self.menuViewStyle = MenuViewStyle.line
    }

    /// 配置导航栏
    fileprivate func configureNavibar() {
        let naviBarStyle = self.pageModel?.naviBar?.styles
        let naviBarFields = self.pageModel?.naviBar?.fields
        let naviBarItems = self.pageModel?.naviBar?.items
        //导航栏背景色、背景图
        self.naviBar?.bgImgStr = naviBarStyle?.bgImg
        self.naviBar?.backgroundColor = naviBarStyle?.bgColor?.toColor()
        //导航栏item
        let leftItems = naviBarFields?.leftItems
        let rightItems = naviBarFields?.rightItems
        let centralItem = [naviBarFields?.middle ?? ""]
        //导航栏高度
        let barHeight = (naviBarStyle?.heightNaviBar ?? 44) + 20
        self.naviBar?.height = kIsiPhoneX ? barHeight + 24 : barHeight
        //生成item
        let leftItemArr = generateNavibarItems(itemNames: leftItems, naviBarItems: naviBarItems, action: #selector(touchLeft(item:)), itemStyle: naviBarStyle)
        let rightItemArr = generateNavibarItems(itemNames: rightItems, naviBarItems: naviBarItems, action: #selector(touchCenter(item:)), itemStyle: naviBarStyle)
        //添加到导航栏上
        self.naviBar?.setLeftBarItems(with: leftItemArr)
        self.naviBar?.setRightBarItems(with: rightItemArr)
        //中间视图
        if !showOnNavigationBar {
            let middleItems = generateNavibarItems(itemNames: centralItem, naviBarItems: naviBarItems, action: #selector(touchRight(item:)), itemStyle: naviBarStyle)
            if let items = middleItems {
                if !items.isEmpty {
                    self.naviBar?.titleView = items[0]
                }
            }
        }
//        let navibarHeight = pageModel?.naviBar?.styles?.heightNaviBar ?? 44
//        let tabbarHeight = GlobalConfigTool.shared.tabbar?.styles?.heightTabBar ?? 49
////        self.customVcHeight = view.height - (showOnNavigationBar ?  navibarHeight : (navibarHeight + menuHeight)) - (isHomePage ? tabbarHeight: 0)
    }

    /// 生成导航按钮
    fileprivate func generateNavibarItems(itemNames: [String]?, naviBarItems: [String: NavibarItemsModel]?, action: Selector, itemStyle: NaviBarStyle?) -> [NaviBarItem]? {
        guard let itemNames = itemNames else {
            return nil
        }
        guard let naviBarItems = naviBarItems else {
            return nil
        }
        var itemArr = [NaviBarItem]()//存放item
        for itemName in itemNames {
            guard let item = naviBarItems[itemName] else {
                return nil
            }
            if item.styles == nil {
                item.styles = NavibarItemStyle()
            }
            item.styles?.color = itemStyle?.color
            item.styles?.fontSize = itemStyle?.fontSize
            let naviItem = NaviBarItem(withItemData: item, target: self, selector: action)
            guard let events = item.events else {
                return nil
            }
            naviItem.event = events["click"]
            itemArr.append(naviItem)
        }
        return itemArr
    }

    @objc func touchLeft(item: NaviBarItem) {
        handleEvents(with: item)
    }

    @objc func touchRight(item: NaviBarItem) {
        handleEvents(with: item)
    }

    @objc func touchCenter(item: NaviBarItem) {
        handleEvents(with: item)
    }

    //对不同事件作出响应
    func handleEvents(with item: NaviBarItem) {
        guard let safeEvent = item.event else {
            return
        }
        let eventResult = EventUtil.handleEvents(event: safeEvent)
        EventUtil.eventTrigger(with: eventResult, on: item, delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - PageControllerDataSource
extension PageVC {
    func pageController(_ pageController: PageController, lazyLoadViewController viewController: UIViewController, withInfo info: NSDictionary) {
        if let assembleVC = viewController as? AssembleVC {
            assembleVC.submoduleDelegate?.reloadViewData()
        }
    }

    func pageController(_ pageController: PageController, viewControllerAtIndex index: Int) -> UIViewController {
        //获取itemNmae
        let itemNameJson = JSON(self.pageModel?.naviTab?.fields?.itemList ?? [])
        let vcName = itemNameJson[index].stringValue
        //获取item
        let itemJson = JSON(self.pageModel?.naviTab?.items ?? [:])
        let items = itemJson.dictionaryObject
        if let safeItems = items {
            if let safeItem = safeItems[vcName] as? NaviTabbarItems {
                //event
                let eventJson = JSON(safeItem.events ?? [:])
                if let safeEvents = eventJson.dictionaryObject {
                    if let safeEvent = safeEvents["click"] as? EventsData {
                        //vc
                        guard let pageModel = EventUtil.getPageModel(byKey: safeEvent.pageKey) else {
                            return UIViewController()
                        }
                        let assemble = AssembleVC(pageModel: pageModel)
                        assemble.isHideNaviBar = true
                        assemble.isHandleStatusBar = false
                        assemble.isPageVc = true
                        return assemble
                    }
                }
            }
        }
        let childVC = UIViewController()
        return childVC
    }

    func pageController(_ pageController: PageController, titleAtIndex index: Int) -> String {
        return self.pageModel?.naviTab?.itemsData?[index].fields?.title ?? "title"
    }

    func numberOfControllersInPageController(_ pageController: PageController) -> Int {
        return self.pageModel?.naviTab?.fields?.itemList?.count ?? 0
    }

    override func menuView(_ menuView: MenuView, widthForItemAtIndex index: Int) -> CGFloat {
        let fontSize = titleSizeSelected > titleSizeNormal ? titleSizeSelected : titleSizeNormal
        let title = self.pageModel?.naviTab?.itemsData?[index].fields?.title ?? "title"
        let size = title.getSize(fontSize: fontSize)
        return size.width
    }

    override func menuView(_ menuView: MenuView, itemMarginAtIndex index: Int) -> CGFloat {
        return 10
    }
}

// 气泡菜单代理
extension PageVC: PopOverViewDelegate {
    func popOverViewDidShow(_ pView: PopOverView?) {
    }

    func popOverViewDidDismiss(_ pView: PopOverView?) {
    }

    func popOverView(_ pView: PopOverView?, didClickMenuIndex index: Int) {
        guard let safeView = pView else {
            return
        }
        let events = pView?.events ?? []
        if !events.isEmpty {
            let event = events[index]
            let result = EventUtil.handleEvents(event: event)
            EventUtil.eventTrigger(with: result, on: safeView, delegate: self)
        }
    }
}
