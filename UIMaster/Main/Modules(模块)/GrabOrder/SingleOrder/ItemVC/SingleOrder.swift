////
////  SingleOrder.swift
////  UIDS
////
////  Created by one2much on 2018/1/25.
////  Copyright © 2018年 one2much. All rights reserved.
////
//
//import UIKit
////import TYPagerController
//
//private struct MetricSg {
//    static let leftTitle = "抢单"
//    static let centerTitle = "正在进行"
//    static let rightTitle = "已完成"
//}
//
//class SingleOrder: UIView, PageModuleAble {
//
//    var pageVC = TYTabPagerController().then {
//
//        $0.pagerController.scrollView?.backgroundColor = kThemeWhiteColor
//
//        // 设置滚动条 属性
//        $0.tabBarHeight = Metric.pagerBarHeight
//        $0.tabBar.backgroundColor = kThemeWhiteColor
//        $0.tabBar.layout.cellWidth = kScreenW * (1/3)
//        $0.tabBar.layout.progressWidth = Metric.leftTitle.getSize(font: Metric.pagerBarFontSize).width + MetricGlobal.margin * (1/3)
//        $0.tabBar.layout.progressColor = kNaviBarBackGroundColor
//        $0.tabBar.layout.selectedTextColor = kNaviBarBackGroundColor
//        $0.tabBar.layout.progressHeight = 3.0
//        $0.tabBar.layout.cellSpacing = 0
//        $0.tabBar.layout.cellEdging = 0
//        $0.tabBar.layout.normalTextFont = Metric.pagerBarFontSize
//        $0.tabBar.layout.selectedTextFont = Metric.pagerBarFontSize
//    }
//
//    let titles: [String] = [MetricSg.leftTitle, MetricSg.centerTitle, MetricSg.rightTitle]
//    var vcs: [OrderVC] = []
//
//   //控制页面
//    func genderView() {
//        self.buildMenu()
//
//    }
//    func reloadViewData() {
//        self.pageVC.reloadData()
//    }
//}
//
//extension SingleOrder {
//
//    fileprivate func buildMenu() {
//
//        //分页
//        // 给 PageTabBar 添加一个底部细线
//        let bottomLine = UIView().then {
//            $0.backgroundColor = kThemeWhiteColor
//        }
//        self.pageVC.tabBar.addSubview(bottomLine)
//
//        bottomLine.snp.makeConstraints { (make) in
//            make.bottom.left.right.equalToSuperview()
//            make.height.equalTo(1.0)
//        }
//        if VCController.getTopVC() is AssembleVC {
//            let vc = VCController.getVC("AssembleVC_tabber")
//            self.addSubview(self.pageVC.view)
//            vc?.addChildViewController(self.pageVC)
//            self.pageVC.didMove(toParentViewController: vc)
//        } else {
//            VCController.getTopVC()?.addChildViewController(self.pageVC)
//            self.addSubview(self.pageVC.view)
//            self.pageVC.didMove(toParentViewController: VCController.getTopVC())
//        }
//
//        self.pageVC.view.frame = self.bounds
//
//        self.pageVC.delegate = self
//        self.pageVC.dataSource = self
//        self.pageVC.reloadData()
//
//        // 设置起始页
//        self.pageVC.pagerController.scrollToController(at: 0, animate: false)
//
//    }
//
//}
//
////MARK : page vc deleaget
//extension SingleOrder: TYTabPagerControllerDelegate, TYTabPagerControllerDataSource {
//
//    func numberOfControllersInTabPagerController() -> Int {
//        return self.titles.count
//    }
//
//    func tabPagerController(_ tabPagerController: TYTabPagerController, controllerFor index: Int, prefetching: Bool) -> UIViewController {
//
//        let vc = OrderVC()
//
//        if index == 0 {
//            vc.orderType = ORDER_TYPE.grab
//        } else if index == 1 {
//            vc.orderType = ORDER_TYPE.oning
//        } else if index == 2 {
//            vc.orderType = ORDER_TYPE.over
//        }
//
//        return vc
//    }
//
//    func tabPagerController(_ tabPagerController: TYTabPagerController, titleFor index: Int) -> String {
//        return self.titles[index]
//    }
//}
