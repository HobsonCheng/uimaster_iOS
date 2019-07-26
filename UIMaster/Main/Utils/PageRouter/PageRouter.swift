//
//  PageRouter.swift
//  UIMaster
//
//  Created by hobson on 2018/11/2.
//  Copyright © 2018 one2much. All rights reserved.
//

import Bugly
import UIKit

class PageRouter {
    /// 路由类型
    ///
    /// - personalCenterT: 个人中心 传递 uid 和pid
    /// - personalCenter: 个人中心 传递 个人数据
    /// - chatPage: 聊天页
    /// - articelDetail: 文章详情页
    /// - login: 登录010
    enum RouterPageType {
        case personalCenterT(tuple:(Int64, Int64))
        case personalCenter(model:UserInfoData)
        case chatPage(mdoel:ChatSessionModel)
        case articelDetail(model:TopicData, cell:PostListCell?)
        case articelAndComment(articleModel: TopicData, replyModel: ReplyData)
        case articelParams(params: [String: Any])
        case login
        case frientApply
        case searchProject
    }

    /// 单例
    static let shared = PageRouter()
    private init() {}

    func router(to pageType: RouterPageType) {
        var params = [String: Any]()
        //1.得到pageKey
        var pageKey: String?
        switch pageType {
        case let .personalCenterT(tuple):
            params["PCTuple"] = tuple
            pageKey = GlobalConfigTool.shared.global?.personalCenterPageKey
        case let .personalCenter(model):
            params[UserInfoData.getClassName] = model
            pageKey = GlobalConfigTool.shared.global?.personalCenterPageKey
        case .login:
            //  移除用户信息
            UserUtil.share.removerUser()
            // 获取pageKey
            pageKey = GlobalConfigTool.shared.global?.loginPageKey
        case let .chatPage(model):
            params[ChatSessionModel.getClassName] = model
            pageKey = GlobalConfigTool.shared.global?.groupChatKey
        case let .articelDetail(model, cell):
            params[TopicData.getClassName] = model
            params[PostListCell.getClassName] = cell
            pageKey = GlobalConfigTool.shared.global?.articlePageKey
        case let .articelAndComment(articleModel, replyModel):
            params[TopicData.getClassName] = articleModel
            params[ReplyData.getClassName + "Notification"] = replyModel
            pageKey = GlobalConfigTool.shared.global?.articlePageKey
        case let .articelParams(articleParams):
            params = articleParams
            pageKey = GlobalConfigTool.shared.global?.articlePageKey
        case .frientApply:
            pageKey = GlobalConfigTool.shared.global?.friendApply
        case .searchProject:
            pageKey = GlobalConfigTool.shared.global?.searchProject
        }
        //2.获得页面模型数据
        guard let safeKey = pageKey else {
            HUDUtil.debugMsg(msg: "页面pageKey为空", type: .error)
            return
        }
        let pageModel = getPageModel(with: safeKey)
        //3.生成页面实例 设置页面参数
        guard let safeModel = pageModel else {
            HUDUtil.debugMsg(msg: "页面数据模型不存在", type: .error)
            return
        }
        let vc = getNewVC(pageModel: safeModel, params: params)
        DispatchQueue.main.async {
            //进入登录
            if let assmbleVC = VCController.getTopVC() as? AssembleVC {
                if assmbleVC.pageModel?.pageKey == GlobalConfigTool.shared.globalData?.global?.loginPageKey {
                    return
                }
            }

            if let pageVc = VCController.getTopVC() as? PageVC {
                if pageVc.pageModel?.pageKey == GlobalConfigTool.shared.globalData?.global?.loginPageKey {
                    return
                }
            }
            //5.跳转
            VCController.push(vc, with: VCAnimationClassic.defaultAnimation())
        }
    }

    /// 获取页面的数据模型
    ///
    /// - Parameter pageKey: pageKye用户获取页面
    /// - Returns: 返回页面配置数据模型
    fileprivate func getPageModel(with pageKey: String?) -> PageConfigData? {
        guard let safeKey = pageKey else {
            return nil
        }
        let pageList = PageConfigTool.shared.pageConfigList ?? [:]
        let pageModel = pageList[safeKey]
        return pageModel
    }

    /// 根据数据模型获取VC
    ///
    /// - Parameters:
    ///   - pageModel: 页面数据模型
    ///   - attachment: 数据
    /// - Returns: 控制器
    fileprivate func getNewVC(pageModel: PageConfigData?, params: [String: Any]?) -> NaviBarVC? {
        guard let safeModel = pageModel else {
            HUDUtil.msg(msg: "没有找到该页面", type: .info)
            return nil
        }
        let params = params ?? [String: Any]()
        switch safeModel.fields?.pageStyle ?? 0 {
        case PageType.navibar.rawValue:
            let vc = AssembleVC(pageModel: safeModel)
            vc.pageParams = params
            return vc
        case PageType.naviAndTab.rawValue:
            let vc = PageVC(pageModel: safeModel)
            vc.pageParams = params
            vc.pageModel = pageModel
            return vc
        case PageType.naviTab.rawValue:
            let vc = PageVC(pageModel: safeModel)
            vc.pageParams = params
            vc.pageModel = pageModel
            vc.showOnNavigationBar = true
            return vc
        case PageType.tabbar.rawValue:
            let vc = PageVC(pageModel: safeModel)
            vc.pageParams = params
            vc.showOnBottom = true
            return vc
        default:
            return nil
        }
    }
}
