//
//  MainTabberVC.swift
//  UIDS
//
//  Created by one2much on 2018/2/11.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

class MainTabbarVC: UITabBarController {
    //自定义的底部TabbarView
    var mainTabBarView: MainTabBarView?
    //tabbar数据模型
    var tabbarModel: [TabbarItems]?
    //记录tabbar上特殊按钮的下标
    var otherActionIndex = [Int]()
    //modal出的vc
    var modalVc = AssembleVC()
    /// 缓存左侧滑VC
    var leftPanArr = [NaviBarVC]()
    /// 缓存右侧滑VC
    var rightPanArr = [NaviBarVC]()

    init(tabBarModel: [TabbarItems]) {
        //tabbar数据模型
        self.tabbarModel = tabBarModel
        //调用父类的初始化方法
        super.init(nibName: nil, bundle: nil)
        //创建视图控制器
        self.createControllers()
        //创建自定义TabBarView
        self.createMainTabBarView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    //创建视图控制器
    fileprivate func createControllers() {
        //初始化导航控制器数组
        var navArray = [UIViewController]()
        //取出tabbarModel中保存的item数据
        let items = self.tabbarModel ?? []
        //生成VC,添加其他事件
        for (index, item) in items.enumerated() {
            guard let events = item.events else {
                continue
            }
            let result = EventUtil.handleEvents(event: events["click"])
            if let safeVC = result.newPageVC {
                safeVC.isHomePage = true
                navArray.append(safeVC)
//                //添加侧滑页VC到缓存数组
                let leftPanVC = EventUtil.handleNewPage(pageKey: safeVC.pageModel?.leftPan?.pageKey, attachment: nil)
                leftPanArr.append(leftPanVC ?? NaviBarVC())
                let rightPanVC = EventUtil.handleNewPage(pageKey: safeVC.pageModel?.rightPan?.pageKey, attachment: nil)
                rightPanArr.append(rightPanVC ?? NaviBarVC())
            } else if let safeModalVc = result.modalVC {
                self.modalVc = safeModalVc
                self.otherActionIndex.append(index)
                navArray.append(UIViewController())
                leftPanArr.append(NaviBarVC())
                rightPanArr.append(NaviBarVC())
            }
        }

        EventUtil.initLeftSideslip(with: leftPanArr[0])
        EventUtil.initRightSideslip(with: rightPanArr[0])
        self.viewControllers = navArray
    }

//创建自定义Tabbar
    private func createMainTabBarView() {
        //1.计算frame
        var tabbarHeight = GlobalConfigTool.shared.tabbar?.styles?.heightTabBar ?? 49
        tabbarHeight += kIsiPhoneX ? 34.0 : 0
        let tabBarFrame = CGRect(x: 0, y: kScreenH - tabbarHeight, width: kScreenW, height: tabbarHeight)
        //2.隐藏系统自带的tabbar
        self.tabBar.isHidden = true
        //3.使用得到的frame，和plist数据创建自定义标签栏
        mainTabBarView = MainTabBarView(frame: tabBarFrame, tabBarConfig: GlobalConfigTool.shared.tabbar)
        mainTabBarView?.delegate = self
        self.view.addSubview(mainTabBarView!)
    }
}
// MARK: - MainTabBarDelegate
extension MainTabbarVC: MainTabBarDelegate {
    func didChooseItem(itemIndex: Int) {
        for index in otherActionIndex where index == itemIndex {
            VCController.push(self.modalVc, with: VCAnimationBottom.defaultAnimation())
            return
        }
        if let safeVC = self.viewControllers?[itemIndex] as? NaviBarVC {
            kCurrentTabbarVC = safeVC
            if let pageKey = safeVC.pageModel?.events?["bottomPan"]?.pageKey, pageKey.isEmpty {
                EventUtil.bottomPanKey = pageKey
            }
        }
//        var vc = leftPanArr[itemIndex]
//        var vc2 = rightPanArr[itemIndex]
        EventUtil.initLeftSideslip(with: leftPanArr[itemIndex])
        EventUtil.initRightSideslip(with: rightPanArr[itemIndex])

        self.selectedIndex = itemIndex
        //初始化侧滑页
    }
}
