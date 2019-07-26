//
//  AssembleVC+RenderModule.swift
//  UIDS
//
//  Created by one2much on 2018/1/10.
//  Copyright © 2018年 one2much. All rights reserved.
//  生成模块组件

import Foundation
import MJRefresh
import SwiftyJSON

enum NavibarPositionType {
    case left(index:Int)
    case middle(title:String)
    case right(index:Int)
}
extension AssembleVC: ModuleRefreshDelegate {
    func setfullPageTableModule(table: BaseTableView) {
        self.mainTable = table
    }

    func moduleLayoutDidRefresh() {
        self.reloadMainScroll()
    }

    func moduleDataDidRefresh(noMore: Bool) {
        self.mainTable?.endRefreshCB?(noMore)
        self.moduleCount -= 1
        if self.moduleCount <= 0 {
            self.moduleCount = self.moduleList?.count ?? 0
            //返回主线程，取消刷新
            DispatchQueue.main.async {
                if let header = self.mainTable?.mj_header {
                    header.endRefreshing()
                }
                if let header = self.mainView?.mj_header {
                    header.endRefreshing()
                }
            }
        }
    }

    func handleNavibarItems(isHidden: Bool, position: NavibarPositionType, params: [String: Any]?) {
        var item: NaviBarItem?
        switch position {
        case let .left(index):
            item = self.naviBar?.getLeftBarItems()?[index]
        case let .middle(title):
            item = self.naviBar?.titleView as? NaviBarItem
            item?.setTitle(title, for: .normal)
        case let .right(index):
            item = self.naviBar?.getRightBarItems()?[index]
        }

        item?.isHidden = isHidden
        guard let value = params else {
            return
        }
        item?.event?.attachment = value
    }

    func assemble(with subVC: UIViewController) {
        self.addChildViewController(subVC)
//        if let safeView = view{
//            self.view.addSubview(view)
//        }
    }
}

extension AssembleVC {
    // MARK: 生成组件
    func renderModuleList() {
        var moduleMap = [
            "Slider": LaunchPad.getFullClassName,
            "NoticeList": NoticeList.getFullClassName,
            "SwipImgArea": SwipImgAreaView.getFullClassName,
            "PostList": PostList.getFullClassName,
            "Post": Post.getFullClassName,
//            "OneImg": OneImg.getFullClassName,
            "Login": Login.getFullClassName,
            "QuickLogin": QuickLogin.getFullClassName,
            "Regist": Regist.getFullClassName,
            "RetrievePassword": RetrievePassword.getFullClassName,
            "RecentConversation": ChatSessionList.getFullClassName,
            "AddressBook": ContactsVC.getFullClassName,
            "FriendApply": FriendApplyVC.getFullClassName,
            "ContactDetail": ContactDetail.getFullClassName,
            "Organization": OrgnizationStruct.getFullClassName,
            "DepartmentDetail": DepartmentDetailVC.getFullClassName,
            "ChatGroupDetail": ChatGroupDetailVC.getFullClassName,
            "ChatPage": ChatPageList.getFullClassName,
            "CreateGroup": CreateGroup.getFullClassName,
            "GroupListTopic": GroupListTopic.getFullClassName,
            "BuiltInWeb": BuiltInWeb.getFullClassName,
            "GroupDetail": GroupDetail.getFullClassName,
            "GroupSet": GroupSet.getFullClassName,
            "ArticleDetails": ArticleDetails.getFullClassName,
            "Comment": Comment.getFullClassName,
            "CreateChatGroup": CreateChatGroup.getFullClassName,
            "PersonalCenter": PersonalCenter.getFullClassName,
            "PersonalDetails": PersonalDetails.getFullClassName,
            "FriendsList": FriendsList.getFullClassName,
            "InformationFlow": InformationFlow.getFullClassName,
            "Feedback": Feedback.getFullClassName,
            "AppSet": AppSet.getFullClassName,
            "MessageList": MessageList.getFullClassName,
            "PrivacySettings": PrivacySettings.getFullClassName,
            "ResetPassword": ResetPassword.getFullClassName,
            "SearchProject": AppSearchNavVC.getFullClassName
        ]
        //不需要页面刷新功能的模块 可以滚动
        let noRefreshModule = ["ResetPassword", "ChatGroupDetail", "RetrievePassword", "BuiltInWeb", "Feedback", "Post", "Login", "QuickLogin", "Regist", "DepartmentDetail", "PrivacySettings", "AppSet", "CreateGroup", "ChatPage", "CreateChatGroup", "GroupSet", "PersonalDetails", "RecentConversation", "ContactDetail", "SearchProject"]
        //分析页面模块
        let modelNames = self.pageModel?.fields?.itemList
        var modelDic = self.pageModel?.items ?? [:]
        self.moduleCount = modelNames?.count ?? 0
        var subVCArr = [UIViewController]()
        dPrint("当前页面models:\(modelNames ?? [])")
        dPrint("当前页面pageKey:\(pageModel?.pageKey ?? "")")

        for item in modelNames ?? [] { //module201_AppSet_nodel

            //获取模块信息
            let compList = item.components(separatedBy: "_")
            let moduleId = compList[0] //module201
            let moduleName = compList[1]//AppSet
            let moduleDic = JSON(modelDic[moduleId] ?? [:]).dictionaryObject
            if noRefreshModule.contains(moduleName) {
                pageModel?.fields?.canPullToRefresh = 0
            }
            if (pageParams["hideModule"] as? String) == moduleName {
                moduleCount -= 1
                continue
            }
            //生成模块
            let cls = moduleMap[moduleName]?.getClass as? UIResponder.Type
            let model = BaseConfigModel.deserialize(from: moduleDic)
            //计算尺寸
            let height = CGFloat(model?.styles?.heightSwipImgArea ?? model?.styles?.height ?? self.mainView?.height ?? 300)
            let top = model?.styles?.marginTop ?? 0
            let left = model?.styles?.marginLeft ?? 0
            let right = model?.styles?.marginRight ?? 0
            let width = (self.mainView?.width ?? kScreenW) - left - right
            //如果模块是VC
            if let vcClass = cls as? UIViewController.Type {
                var vc = UIViewController()

                if Bundle.main.path(forResource: vcClass.getClassName, ofType: "nib") != nil {
                    vc = vcClass.init(nibName: vcClass.getClassName, bundle: nil)
                } else {
                    vc = vcClass.init()
                }
                vc.view.frame = CGRect(x: left, y: 0, width: width, height: height)
                guard let module = vc as? PageModuleAble else {
                    return
                }
                //模块Id
                module.moduleCode = moduleId
                module.pageKey = self.pageModel?.pageKey
                //模块代理
                module.moduleDelegate = self
                //设置模块数据模型
                module.styleDic = moduleDic
                //页面公共参数
                module.moduleParams = pageParams
                //上下间距
                module.marginTop = top
                module.marginBottom = model?.styles?.marginBottom ?? 0
                //是否是全屏显示的模块
                if self.mainTable == nil {
                    self.topViewContainer.height += height
                    self.topViewContainer.addSubview(vc.view)
                    subVCArr.append(vc)
                } else {
                    self.addChildViewController(vc)
                    self.mainView?.isScrollEnabled = false
                    self.mainView?.addSubview(vc.view)
                    for subVC in subVCArr {
                        vc.addChildViewController(subVC)
                        subVCArr.remove(subVC)
                    }
                    vc.view.height = self.mainView?.height ?? 0
                    self.mainTable?.tableHeaderView = self.topViewContainer
                }
                //底部评论视图
                if moduleName == "ArticleDetails" && UserUtil.isValid() && (pageParams["hideModule"] as? String) != "Comment" {
                    let bottomBarView = Bundle.main.loadNibNamed("CLBottomCommentView", owner: nil, options: nil)?.last as? CLBottomCommentView ?? CLBottomCommentView()
                    self.view.addSubview(bottomBarView)
                    bottomBarView.topicData = pageParams[TopicData.getClassName] as? TopicData
                    bottomBarView.snp.makeConstraints { make in
                        make.left.right.bottom.equalTo(0)
                        make.height.equalTo(kIsiPhoneX ? kiPhoneXBottomH + 45 : 45)
                    }
                    let scrollCB: (() -> Void)? = { [weak self] in
                        self?.mainTable?.setContentOffset(CGPoint(x: 0, y: vc.view.bottom), animated: true)
                    }
                    bottomBarView.scrollCB = scrollCB
                    (vc as? ArticleDetails)?.bottomView = bottomBarView as? CLBottomCommentView
                }
            }
            //如果模块是View
            if let viewClass = cls as? UIView.Type {
                //生成模块
                let view = viewClass.init(frame: CGRect(x: left, y: 0, width: width, height: height))
                guard let module = view as? PageModuleAble else {
                    return
                }
                //模块Id
                module.moduleCode = moduleId
                module.pageKey = self.pageModel?.pageKey
                //模块代理
                module.moduleDelegate = self
                //设置模块数据模型
                module.styleDic = moduleDic
                //页面公共参数
                module.moduleParams = pageParams
                //上下间距
                module.marginTop = top
                module.marginBottom = model?.styles?.marginBottom ?? 0
                //是否是全屏显示的模块
                if self.mainTable == nil {
                    self.topViewContainer.addSubview(view)
                    self.topViewContainer.height += view.height
                } else {
                    self.mainView?.isScrollEnabled = false
                    self.mainView?.addSubview(view)
                    view.height = self.mainView?.height ?? 0
                    self.mainTable?.tableHeaderView = self.topViewContainer
                }
            }
        }

        for subVC in subVCArr {
            self.addChildViewController(subVC)
        }

        if self.startY > (self.mainView?.height ?? 0) {
            self.mainView?.contentSize = CGSize(width: 0, height: self.startY)
        } else {
            self.mainView?.contentSize = CGSize(width: 0, height: (self.mainView?.height ?? 0))
        }

        self.reloadMainScroll()
    }
}
