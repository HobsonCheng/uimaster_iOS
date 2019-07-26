//
//  AssembleVC+ConfigureUI.swift
//  UIDS
//
//  Created by one2much on 2018/1/15.
//  Copyright © 2018年 one2much. All rights reserved.
// 配置页面相关UI ： 页面背景、导航栏、导航栏item

import Foundation
import SwiftyJSON

// MARK: - 配置页面相关UI
extension AssembleVC {
    func configurePageUI() {
        //配置导航栏
        self.configureNaviBar()
        //配置scrollView容器
        self.configureMainScrollView()
        //配置页面
        self.configurePage()
        //配置悬浮按钮
        self.configSideMenuButton()
    }

    // MARK: 悬浮按钮
    /// 配置悬浮按钮
    func configSideMenuButton() {
        guard let models = pageModel?.buttons else {
            return
        }
        for model in models.itemsArr {
            let hasNav = !self.isHideNaviBar
            let sideMenuBtn = SideMenuButton(parentWidth: self.mainView?.width ?? kScreenW, parentHeight: self.view.height - (self.naviBar?.height ?? 0), model: model, target: self, action: #selector(handleEvent(btn:)), hasNavBar: hasNav)
            self.view.addSubview(sideMenuBtn)
        }
    }

    /// 处理事件
    ///
    /// - Parameter btn: 被点击的按钮
    @objc func handleEvent(btn: SideMenuButton) {
        guard let events = btn.model?.events else {
            return
        }
        let event = events["click"]
        let result = EventUtil.handleEvents(event: event)
        EventUtil.eventTrigger(with: result, on: btn, delegate: self)
    }

    // MARK: MainScrollView
    func configureMainScrollView() {
        var naviBarHeight: CGFloat = 0.0
        if let barBottom = self.naviBar?.bottom {
            if !isHideNaviBar {
                naviBarHeight = barBottom
            }
        }
        self.mainView = MainScrollView(frame: CGRect(x: 0, y: naviBarHeight, width: self.view.width * widthRate, height: self.view.height - naviBarHeight))
        if isPageVc {
            self.mainView?.height = self.pageVCViewHeight
        }
        self.mainView?.showsVerticalScrollIndicator = false
        self.mainView?.showsHorizontalScrollIndicator = false
        if self.isHomePage {
            self.mainView?.height = (self.mainView?.height ?? 0) - (GlobalConfigTool.shared.tabbar?.styles?.heightTabBar ?? 0)
        }
        self.view.addSubview(self.mainView!)
   }

    // MARK: 配置页面
    /// 配置页面样式
    fileprivate func configurePage() {
        if let pageKey = pageModel?.events?["bottomPan"]?.pageKey, pageKey.isEmpty {
            EventUtil.bottomPanKey = pageKey
        }
        //弹出层
        if isFloatingMenu {
            let panModel = GlobalConfigTool.shared.bottomPan
            //背景色
            self.mainView?.height = (panModel?.styles?.panHeight ?? 1) * self.view.height - kStatusBarHeight
            self.mainView?.top = self.view.height - (self.mainView?.height ?? 0)
            self.mainView?.backgroundColor = panModel?.styles?.bgColor?.toColor()
            self.view.backgroundColor = panModel?.styles?.bgColorCover?.toColor()
            //背景图
            if let bgImgCover = panModel?.styles?.bgImgCover {
                let imageView = UIImageView(frame: self.view.bounds)
                imageView.contentMode = .scaleAspectFill
                imageView.kf.setImage(with: URL(string: bgImgCover))
                self.view.addSubview(imageView)
            }
            if let bgImg = panModel?.styles?.bgImg {
                let imageView = UIImageView(frame: self.mainView?.bounds ?? .zero)
                imageView.kf.setImage(with: URL(string: bgImg))
                self.mainView?.addSubview(imageView)
            }
            //创建一个模糊效果
//            let blurEffect = UIBlurEffect(style: .light)
//            let blurView = UIVisualEffectView(effect: blurEffect)
//            blurView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
//            self.view.insertSubview(blurView, at: 0)
            self.canRightPan = false
            // 创建一个关闭按钮
            let closeBtn = UIButton(type: .custom)
//            closeBtn.setImage(UIImage(named: "hud_error"), for: .normal)
            if panModel?.fields?.buttonStyle == 1 {
                closeBtn.setTitle(panModel?.fields?.buttonTitle, for: .normal)
            } else if panModel?.fields?.buttonStyle == 2 {
                closeBtn.kf.setImage(with: URL(string: (panModel?.fields?.buttonImage ?? "")), for: .normal)
            }

            closeBtn.addTarget(self, action: #selector(goDismiss(_:)), for: .touchUpInside)
            closeBtn.backgroundColor = panModel?.styles?.bgColorClose?.toColor()
            closeBtn.kf.setBackgroundImage(with: URL(string: panModel?.styles?.bgImgClose ?? ""), for: .normal)
            self.view.addSubview(closeBtn)
            var closeH: CGFloat = 0
            if let closeHeight = panModel?.styles?.heightClose {
                closeH = closeHeight + kTabBarHeight - 49
            } else {
                closeH = kTabBarHeight
            }
            closeBtn.snp.makeConstraints { make in
                make.bottom.equalTo(0)
                make.centerX.equalTo(self.mainView!)
                make.width.equalTo(self.mainView!)
                make.height.equalTo(closeH)
            }
        } else {//普通页面
            self.view.backgroundColor = self.pageModel?.styles?.bgColor?.toColor() ?? kThemeLightGreyColor
            //背景图
            if let imgUrl = self.pageModel?.styles?.bgImg {
                self.bgImgView = UIImageView().then({
                    $0.kf.setImage(with: URL(string: imgUrl))
                    $0.frame = self.mainView?.frame ?? .zero
                })
                self.view?.addSubview(self.bgImgView!)
                self.view?.sendSubview(toBack: self.bgImgView!)
            }
        }
    }

    // MARK: 配置导航栏
    fileprivate func configureNaviBar() {
        if self.pageModel?.fields?.naviBarShow == 0 {
            self.isHideNaviBar = true
            return
        }
        let naviBarStyle = self.pageModel?.naviBar?.styles
        let naviBarFields = self.pageModel?.naviBar?.fields
        let naviBarItems = self.pageModel?.naviBar?.items
        //导航栏高度
        let barHeight = (naviBarStyle?.heightNaviBar ?? 44) + 20
        self.naviBar?.height = kIsiPhoneX ? barHeight + 24 : barHeight
        //导航栏背景色、背景图
        self.naviBar?.bgImgStr = naviBarStyle?.bgImg
        self.naviBar?.backgroundColor = naviBarStyle?.bgColor?.toColor()
        //分割线
//        if naviBarStyle?.splitterShow == 1{
//            let lineView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.naviBar?.width ?? 0, height: naviBarStyle?.splitterWidth ?? 0))
//            lineView.backgroundColor = naviBarStyle?.splitterColor?.toColor()
//            lineView.top = (self.naviBar?.height ?? kNavigationBarHeight) - (naviBarStyle?.splitterWidth ?? 0)
//            self.naviBar?.addSubview(lineView)
//        }
        //导航栏item
        let leftItems = naviBarFields?.leftItems
        let rightItems = naviBarFields?.rightItems
        let centralItem = [naviBarFields?.middle ?? ""]

        let leftItemArr = generateNavibarItems(itemNames: leftItems, naviBarItems: naviBarItems, action: #selector(touchNavibarItem(item:)), itemStyle: naviBarStyle)
        let rightItemArr = generateNavibarItems(itemNames: rightItems, naviBarItems: naviBarItems, action: #selector(touchNavibarItem(item:)), itemStyle: naviBarStyle)
        let middleItems = generateNavibarItems(itemNames: centralItem, naviBarItems: naviBarItems, action: #selector(touchNavibarItem(item:)), itemStyle: naviBarStyle)
        self.naviBar?.setLeftBarItems(with: leftItemArr)
        self.naviBar?.setRightBarItems(with: rightItemArr)
        if let items = middleItems {
            if !(items.isEmpty) {
                self.naviBar?.titleView = items[0]
            }
        }
    }

    /// 生成导航栏按钮
    ///
    /// - Parameters:
    ///   - itemNames: 按钮名字数组
    ///   - naviBarItems: 按钮对应的数据模型
    ///   - action: 按钮点击事件
    ///   - style: 按钮样式
    /// - Returns: 生成的按钮数组
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
            if item.styles == nil { item.styles = NavibarItemStyle() }
            item.styles?.color = itemStyle?.color
            item.styles?.fontSize = itemStyle?.fontSize
            item.styles?.itemHeight = itemStyle?.heightNaviBar
            let naviItem = NaviBarItem(withItemData: item, target: self, selector: action)
            guard let events = item.events else {
                return nil
            }
            naviItem.event = events["click"]
            naviItem.event?.attachment = pageParams
            itemArr.append(naviItem)
        }
        return itemArr
    }

    /// 点击了导航栏按钮
    ///
    /// - Parameter item: 导航栏按钮
    @objc func touchNavibarItem(item: NaviBarItem) {
        guard let safeEvent = item.event else {
            return
        }
        let result = EventUtil.handleEvents(event: safeEvent)
        EventUtil.eventTrigger(with: result, on: item, delegate: self)
    }
}

// MARK: - 气泡按钮的 delegate
extension AssembleVC: PopOverViewDelegate {
    func popOverView(_ pView: PopOverView?, didClickMenuIndex index: Int) {
        let events = pView?.events ?? []
        guard let safeView = pView else {
            return
        }
        if !(events.isEmpty) {
            let event = events[index]
            let result = EventUtil.handleEvents(event: event)
            EventUtil.eventTrigger(with: result, on: safeView, delegate: self)
        }
    }
}
