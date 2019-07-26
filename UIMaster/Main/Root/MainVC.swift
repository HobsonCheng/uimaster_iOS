//
//  MainVC.swift
//  UIDS
//
//  Created by one2much on 2018/1/10.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

//var kBaseUrl = "http://16039v3s49.imwork.net:14032" //线上

class MainVC: DrawerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 如果已登录，开启聊天连接
        UserUtil.share.initUserInfo {
            // 初始化用户数据库
            let tool = DatabaseTool.shared
            tool.createUserDatabase()
        }
        // 打印当前沙盒目录
        dPrint(SandboxTool.getFilePath(of: "", in: .library))
        // 测试
        if AppUtil.isTest {
            NetworkUtil.request(target: .findGlobal(app_id: AppUtil.appID ?? 7, group_id: 0, client: nil, project_id: AppUtil.projectID ), success: { jsonStr in
                GlobalConfigTool.shared.globalData = GlobalModel.deserialize(from: jsonStr)?.data
                kBaseUrl = "https://\(GlobalConfigTool.shared.global?.host ?? "")"
                NetworkUtil.request(target: .findPageList(app_id: AppUtil.appID ?? 7, group_id: 0, client: nil, project_id: AppUtil.projectID), success: { jsonStr in
                    PageConfigTool.shared.pageConfigList = PageConfigModel.deserialize(from: jsonStr)?.data
                    self.initTabber()
                }, failure: nil)
            }, failure: nil)
        } else {
            self.initTabber()
        }
        // 数据刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.dataUpdate {}
        }
        // 渲染悬浮按钮
        SuspensionUtil.shared.configButton { btn in
            btn.setImage(R.image.searchp(), for: .normal)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if GlobalConfigTool.shared.appId == 10 { return }
        SuspensionUtil.shared.showSuspensionButton(show: true)
    }

    /// 初始化tabbar
    func initTabber() {
        let tabbarModel = GlobalConfigTool.shared.tabbarItemsData
        let tabBarController = MainTabbarVC(tabBarModel: tabbarModel)
        kMainTabbarVC = tabBarController
        isShowMask = true
        super.set(main: tabBarController)
    }
}

// MARK: - 检测 更新
extension MainVC {
    private func updateVersion() {
        // 获取App的版本号
        let infoDic = Bundle.main.infoDictionary
        let appVersion = infoDic?["CFBundleVersion"] as? String ?? ""
        //软件更新
        NetworkUtil.request(target: .forceUpdateVersion(app_id: GlobalConfigTool.shared.globalData?.appId ?? 0, version: GlobalConfigTool.shared.global?.version ?? "", app_version: appVersion), success: { [weak self] json in
            let versionData = VersionModel.deserialize(from: json)?.data
            if versionData?.build_update == 1 {
                let alert = UIAlertController(style: .alert, title: "您的App有新的版本需要更新", message: "")
                alert.addAction(image: nil, title: "立即更新", color: nil, style: .default, isEnabled: true) { _ in
                    let url = URL(string: versionData?.download ?? "")
                    if let safeURL = url {
                        if UIApplication.shared.canOpenURL(safeURL) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(safeURL, options: [:], completionHandler: nil)
                            } else {
                                UIApplication.shared.openURL(safeURL)
                            }
                        } else {
                            HUDUtil.msg(msg: "无效的下载地址", type: .error)
                        }
                    }
                }
                alert.addAction(image: nil, title: "查看更新", color: nil, style: .default, isEnabled: true) { _ in
                    let url = URL(string: versionData?.url ?? "")
                    if let safeURL = url {
                        if UIApplication.shared.canOpenURL(safeURL) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(safeURL, options: [:], completionHandler: nil)
                            } else {
                                UIApplication.shared.openURL(safeURL)
                            }
                        } else {
                            HUDUtil.msg(msg: "无效的下载地址", type: .error)
                        }
                    }
                }
                alert.addAction(title: "下次再说", style: .cancel, handler: nil)
                alert.show()
            } else {
                self?.dataUpdate {
                }
            }
        }) { error in
            dPrint(error)
        }
    }

    //数据更新
    fileprivate func dataUpdate(finish:@escaping () -> Void) {
        let infoDic = Bundle.main.infoDictionary
        let appVersion = infoDic?["CFBundleVersion"] as? String ?? ""
        NetworkUtil.request(target: .forceUpdateVersion(app_id: GlobalConfigTool.shared.globalData?.appId ?? 0, version: GlobalConfigTool.shared.globalData?.global?.version ?? "", app_version: appVersion), success: { json in
            let versionData = VersionModel.deserialize(from: json)?.data
            if versionData?.data_update == 1 {
                HUDUtil.msg(msg: "有新的样式需要更新", type: .info)
                _ = VCController.popAllThenPush(newVC: RefreshDataVC(), with: VCAnimationClassic.defaultAnimation())
            } else {
                finish()
            }
        }) { error in
            finish()
            dPrint(error)
        }
    }
}
