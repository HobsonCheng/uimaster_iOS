//
//  RefreshDataVC.swift
//  UIDS
//
//  Created by one2much on 2018/2/2.
//  Copyright © 2018年 one2much. All rights reserved.
//

import KeychainAccess
import Kingfisher
import SwiftyJSON
import UIKit

enum HistoryKey {
    static let HistoryKeyPhone = "HistoryKey_Phone"
    static let HistoryKeyPhoneItem = "HistoryKey_Phone_item"
}

class RefreshDataVC: BaseNameVC {
    @IBOutlet weak var newTips: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var warningTips: UILabel!
    @IBOutlet weak var mainTips: UILabel!
    @IBOutlet weak var appIcon: UIImageView!
    //项目数据model
    var pObj: Project?
    //临时变量
    private var globalDataTmp: String?
    private var pageListDataTmp: String?
    // 本地是否有要加载的json
    private var hasJSON: Bool = false
    // 需要下载tabbar图片个数
    private var tabbarIconCount = 0
    private var tabbarDataDic = [String: Data]()
    //提示信息
    private var tipList: [String] = ["单位APP将会成为您工作上的得力助手，领导满意，同事便利。", "单位APP整合资源，将所有的办公应用汇总，触手可及。", "单位APP可以完全独立部署在单位自己的服务器，数据更安全。"]

    override init() {
        super.init(nibName: "RefreshDataView", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.appIcon.layer.cornerRadius = 6
        self.appIcon.layer.masksToBounds = true
        self.canRightPan = false
        // 展示提示
        self.showTip()
        // 如果是更新，直接加载数据
        if pObj == nil {
            var project = Project()
            let global = GlobalConfigTool.shared
            project.pid = global.pid
            project.name = global.name
            project.host = global.global?.host
            project.app_id = global.appId
            self.pObj = project
            requestGlobalData()
        } else {
            // 修改host
            kBaseUrl = self.pObj?.host
            // 请求json
            self.getAppInfo()
        }
        // 展示数据
        let appName = pObj?.name?.replacingOccurrences(of: "<em>", with: "").replacingOccurrences(of: "</em>", with: "") ?? "加载中..."
        self.mainTips.text = appName
        self.warningTips.text = self.warningTips.text?.replacingOccurrences(of: "APP", with: appName)
        self.appIcon.kf.setImage(with: URL(string: pObj?.icon ?? ""), placeholder: R.image.icon256()!, options: nil, progressBlock: nil, completionHandler: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    //展示进度
    func progressTip(num: Float) {
        self.progress.setProgress(num, animated: true)
    }

    /// 展示提示
    func showTip() {
        let index = Int.random(in: 0..<3)
        let tmpTip = tipList[index]
        self.newTips.text = tmpTip
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.showTip()
        }
    }
}

// MARK: - 启动downApp 流程
extension RefreshDataVC {
    // MARK: 第一步，获取AppInfo，并写到json文件中
    func getAppInfo() {
        dPrint("第一步：下载APPInfo")
        // 1. 读取本地json
        let jsonData = SandboxTool.readData(fileName: kAppInfoJSON, dir: SandboxType.applicationSupport, subPath: "com.one2much.app\(pObj?.app_id ?? 0)", type: .text)
        // 2. 判断有无json
        if let safeStr = String(data: jsonData, encoding: String.Encoding.utf8), !safeStr.isEmpty {
            let globalModel = GlobalModel.deserialize(from: safeStr)
            hasJSON = true
            //检测更新
            checkForUpdate(globalModel: globalModel)
        } else {// 获取全局json
            let appID = pObj?.app_id ?? 0
            let path = SandboxTool.getFilePath(of: "", in: .applicationSupport, subPathStr: "com.one2much.app\(appID)")
            if !SandboxTool.isFileExist(in: path) { // 如果不存在，创建文件夹
                do {
                    let dirURL = try FileManager.default
                        .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                        .appendingPathComponent("com.one2much.app\(appID)")
                    try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    onloadError(hasJSON: hasJSON)
                    dPrint(error)
                }
            }
            requestGlobalData()
        }
    }

    fileprivate func checkForUpdate(globalModel: GlobalModel?) {
        let infoDic = Bundle.main.infoDictionary
        let appVersion = infoDic?["CFBundleVersion"] as? String ?? ""
        NetworkUtil.request(
            target: .forceUpdateVersion(app_id: globalModel?.data?.appId ?? 0, version: globalModel?.data?.global?.version ?? "", app_version: appVersion),
            success: { [weak self] json in
                let versionData = VersionModel.deserialize(from: json)?.data
                if versionData?.data_update == 1 {//需要更新
                    self?.progressTip(num: 0.3)
                    self?.requestGlobalData()
                } else {
                    self?.progressTip(num: 0.8)
                    //FIXME： 加载global
                    GlobalConfigTool.shared.readInfo(appID: self?.pObj?.pid ?? 0)
                    //打开APP
                    self?.launchApp()
                }
            }
        ) { [weak self]error in
            self?.onloadError(hasJSON: self?.hasJSON ?? false)
            dPrint(error)
        }
    }

    //请求全局数据
    fileprivate func requestGlobalData() {
        self.progressTip(num: 0.5)
        NetworkUtil.request(
            target: .findGlobal(app_id: pObj?.app_id ?? 0, group_id: 0, client: 1, project_id: pObj?.pid ?? 0),
            success: { [weak self] json in
                // 先保存，最后统一写入到文件
                self?.globalDataTmp = json
                // 请求pageList数据
                self?.getPageList()
            }
        ) { [weak self] error in
            self?.onloadError(hasJSON: self?.hasJSON ?? false)
            dPrint(error)
        }
    }

    // MARK: 第二步，获取pageList，并写到json文件中
    func getPageList() {
        dPrint("第二步：下载图标")
        self.progressTip(num: 0.6)
        NetworkUtil.request(
            target: .findPageList(app_id: pObj?.app_id ?? 0, group_id: 0, client: nil, project_id: pObj?.pid ?? 0),
            success: { [weak self] jsonStr in
                // 先保存，最后统一写入到文件
                self?.pageListDataTmp = jsonStr
                // tabbar图片下载
                self?.downicons()
            },
            failure: { [weak self] error in
                self?.onloadError(hasJSON: self?.hasJSON ?? false)
                dPrint(error)
            }
        )
    }

    // MARK: 第三步，获取UCSet，写到Json中
    func downUCSetJson() {
//        self.progressTip(num: 0.4, tip: "第三步完成")
//        let appID = GlobalConfigTool.shared.globalData?.appId ?? 0
//        if !needUpdate && loadMode == .load && SandboxTool.isFileExist(of: kUCSetInfoJSON, in: .applicationSupport, subPath: "com.one2much.app\(appID)") {
//            AllRestrictionHandler.shared.init_ucSetConfig()
//            self.downicons()
//            return
//        }
//        NetworkUtil.request(target: .allRestriction(pid: GlobalConfigTool.shared.globalData?.appId ?? 0), success: { [weak self] (json) in
//            guard let safeJson = json else{
//                return
//            }
//            //写入文件
//            SandboxTool.writeData(from: Data(safeJson.utf8), to: .applicationSupportDirectory, name: kUCSetInfoJSON,subPathStr: "com.one2much.app\(appID)")
//            //读取到model
//            AllRestrictionHandler.shared.init_ucSetConfig()
//            //进行第四步
//            self?.downicons()
//            self?.gobackBtn.isHidden = true
//        }) { [weak self] (error) in
//            self?.gobackBtn.isHidden = false
//            HUDUtil.msg(msg: "失败", type: .error)
//            dPrint(error)
//        }
    }

    // MARK: 第四步，下载图标，保存到本地
    func downicons() {
        self.progressTip(num: 0.7)
        dPrint("第四步：下载图标")
        let globalModel = GlobalModel.deserialize(from: globalDataTmp)
        let tabbarData = globalModel?.data?.tabBar
        let itemNames = tabbarData?.fields?.itemList ?? []
        let items = tabbarData?.items ?? [:]
        var temArr = [TabbarItems]()
        for name in itemNames {
            temArr.append(items[name] ?? TabbarItems())
        }
        let tabbarItemsData = temArr
        self.tabbarIconCount = temArr.count * 2
        for (index, itemData) in tabbarItemsData.enumerated() {
            //图片路径
            let imageStr = itemData.fields?.normalIcon ??? "http://up.uidashi.com/FsG9elekiIm447RwiN1Mi6DzW-9N"
            let imageSelStr = itemData.fields?.selectedIcon ??? "http://up.uidashi.com/FsG9elekiIm447RwiN1Mi6DzW-9N"
            //去除图片路径下的图片尺寸
            let originStr = imageStr.replacingOccurrences(of: "?imageMogr2/thumbnail/50x50!", with: "").replacingOccurrences(of: "?imageMogr2/thumbnail/60x60!", with: "")
            let originSelStr = imageSelStr.replacingOccurrences(of: "?imageMogr2/thumbnail/50x50!", with: "").replacingOccurrences(of: "?imageMogr2/thumbnail/60x60!", with: "")
            //如果大图显示，尺寸140x140,小图46x46
            if itemData.styles?.tabBarStyle == 1 {
                let finalUrlStr = "\(originStr)?imageMogr2/thumbnail/140x140!"
                let finalSelUrlStr = "\(originSelStr)?imageMogr2/thumbnail/140x140!"
                downloadTabbarIcons(downUrl: finalUrlStr, iconName: "tabBar_icon_\(index + 1)@2x.png")
                downloadTabbarIcons(downUrl: finalSelUrlStr, iconName: "tabBar_icon_\(index + 1)_sel@2x.png")
            } else {
                let finalUrlStr = "\(originStr)?imageMogr2/thumbnail/46x46!"
                let finalSelUrlStr = "\(originSelStr)?imageMogr2/thumbnail/46x46!"
                downloadTabbarIcons(downUrl: finalUrlStr, iconName: "tabBar_icon_\(index + 1)@2x.png")
                downloadTabbarIcons(downUrl: finalSelUrlStr, iconName: "tabBar_icon_\(index + 1)_sel@2x.png")
            }
        }
    }

    //下载Tabbar图标
    func downloadTabbarIcons(downUrl: String, iconName: String) {
        if let safeUrl = URL(string: downUrl) {
            ImageDownloader.default.downloadImage(with: safeUrl, options: [], progressBlock: nil) { [weak self] _, error, _, data in
                if error != nil {
                    HUDUtil.debugMsg(msg: error?.description ?? "", type: .error)
                }
                self?.tabbarDataDic[iconName] = data ?? Data()
                if self?.tabbarDataDic.count == self?.tabbarIconCount {
                    self?.saveData()
                }
            }
        }
    }

    /// 保存json
    func saveData() {
        guard let global = globalDataTmp else {
            onloadError(hasJSON: hasJSON)
            return
        }
        guard let pageList = pageListDataTmp else {
            onloadError(hasJSON: hasJSON)
            return
        }
        let globalData = Data(global.utf8)
        let pageListData = Data(pageList.utf8)
        let appID = pObj?.app_id ?? 0
        SandboxTool.writeData(from: globalData, to: .applicationSupportDirectory, name: kAppInfoJSON, subPathStr: "com.one2much.app\(appID)")
        SandboxTool.writeData(from: pageListData, to: .applicationSupportDirectory, name: kPageListJSON, subPathStr: "com.one2much.app\(appID)")
        for (key, data) in tabbarDataDic {
            SandboxTool.removeData(from: .applicationSupportDirectory, name: key, subPathStr: "com.one2much.app\(appID)")
            SandboxTool.writeData(from: data, to: .applicationSupportDirectory, name: key, subPathStr: "com.one2much.app\(appID)")
        }
        //打开App
        self.launchApp()
    }

    /// 进入新App
    func launchApp() {
        self.progressTip(num: 0.99)
        GlobalConfigTool.shared.readInfo(appID: pObj?.app_id ?? 0)
        PageConfigTool.shared.readInfo(appID: pObj?.app_id ?? 0)
        GlobalConfigTool.shared.pid = pObj?.pid ?? 0
        GlobalConfigTool.shared.name = pObj?.name ?? "一几网络"
        GlobalConfigTool.shared.icon = pObj?.icon ?? "http://up.uidashi.com/Frt9qHdTOVerCA7PW3Qdn5MlKIfR"
        saveUserDefaults(key: kCurrentAPPID, value: pObj?.app_id ?? 0)
        //进入App
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let mainvc = MainVC()
            mainvc.vcName = "MainVC"
            VCController.popAllThenPush(newVC: mainvc, with: VCAnimationClassic.defaultAnimation())
        }
    }

    /// 加载出错
    func onloadError(hasJSON: Bool) {
        if hasJSON {
            launchApp()
        } else {
            HUDUtil.msg(msg: "加载出错，请重新尝试", type: .error)
            kBaseUrl = GlobalConfigTool.shared.global?.host
            VCController.pop(with: nil)
        }
    }
}
