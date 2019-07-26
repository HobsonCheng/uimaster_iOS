//
//  ConfigureRefresh.swift
//  UIDS
//
//  Created by one2much on 2018/1/22.
//  Copyright © 2018年 one2much. All rights reserved.
//  页面的刷新机制

import Foundation
import MJRefresh
import RxSwift
// MARK: - 增加刷新机制
extension AssembleVC {
    func configureRefresh() {
        // 记录页面模块的个数
        self.moduleCount = self.pageModel?.fields?.itemList?.count ?? 0

        //是否开启刷新
        if isFloatingMenu || pageModel?.fields?.canPullToRefresh == 0 {
            return
        }

        // 顶部刷新
        let header = MJRefreshNormalHeader { [weak self] in
            self?.refresh()
        }
        header?.setTitle("下拉刷新", for: .idle)
        header?.setTitle("松开刷新", for: .pulling)
        header?.setTitle("正在刷新", for: .refreshing)
        header?.lastUpdatedTimeLabel.isHidden = true

        // 设置header
        self.mainView?.mj_header = header
    }

    /// 页面下拉刷新调用此方法
    private func refresh() {
        // 模块container中的模块个数
        let subviews = self.topViewContainer.subviews
        // 没有模块直接return
        if subviews.isEmpty {
            return
        }
        // 遍历
        for sonView in subviews {
            if let safeView = sonView as? PageModuleAble {
                safeView.reloadViewData()
            }
            if let safeView = sonView.ownerVC() as? PageModuleAble {
                safeView.reloadViewData()
            }
        }
        // 8秒超时后，停止刷新动画
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            self.mainView?.mj_header.endRefreshing()
        }
    }

    //遍历mainView，重新排列子模块
    @objc func reloadMainScroll() {
        //1. 初始化Y坐标
        self.startY = 0
        //2. 获取模块
        let subviews = self.topViewContainer.subviews
        if subviews.isEmpty {
            return
        }
        //3. 遍历子模块，计算出所有模块的总高
        for sonView in subviews {
            if let safeView = sonView as? PageModuleAble {
                sonView.top = self.startY + (safeView.marginTop ?? 0)
                self.startY = sonView.bottom + (safeView.marginBottom ?? 0)
                continue
            }
            if let ownerVC = sonView.ownerVC() as? PageModuleAble {
                sonView.top = self.startY + (ownerVC.marginTop ?? 0)
                self.startY = sonView.bottom + (ownerVC.marginBottom ?? 0)
            }
        }
        //4.0 如果模块容器在mainView上，表示页面没有无限滚动列表
        if self.mainView?.subviews.contains(topViewContainer) ?? false {
            //4.01 设置模块容器高度为模块总高
            self.topViewContainer.height = self.startY
            //4.02 如果总高大于mainView的高度，那么需要更改mainView的contentSize
            if self.startY > self.mainView?.height ?? kScreenH {
                self.mainView?.contentSize = CGSize(width: 0, height: self.startY)
            }
        } else {//4.1 如果模块容器没在mainv上，表示有无限滚动列表
            //4.11 设置模块容器高度为模块总高
            self.topViewContainer.height = self.startY
            //4.12 将模块容器设置为最下面滚动列表的header
            self.mainTable?.tableHeaderView = self.topViewContainer
            //4.13 重置空白视图
//            self.mainTable?.reloadEmptyDataSet()
        }
    }
}
