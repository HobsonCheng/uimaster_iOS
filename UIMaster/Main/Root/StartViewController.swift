//
//  ViewController.swift
//  UIMaseter
//
//  Created by one2much on 2018/4/9.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    var introView: SwiftIntroView?

    override func viewDidLoad() {
        super.viewDidLoad()

        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        // 保存了版本号，代表已经展示过引导图
        let hasShown = (getUserDefaults(key: "version_" + version) as? Bool) ?? false
        // 如果没展示过引导图 且 设置了引导图 就展示引导页
        if !hasShown && GlobalConfigTool.shared.global?.welcome != 0 && GlobalConfigTool.shared.global?.welcome != nil {
            //保存版本
            saveUserDefaults(key: "version_" + version, value: true)
            //加载引导页
            introView = SwiftIntroView(frame: self.view.frame)
            introView?.delegate = self
            self.view.addSubview(introView!)
        } else { //否则直接进入App
            moveTabberIcon()
            self.openMainVC()
        }
    }

    private func moveTabberIcon() {
        //由于bundle中的数据无法修改，将tabbar移动到library目录中，方便统一管理
        guard let appID = GlobalConfigTool.shared.appId, appID == 10 else {
            return
        }
        let subPath = "Application Support/com.one2much.app\(appID)"
        if !SandboxTool.isFileExist(of: kTabbarIcon, in: .library, subPath: subPath) {
            for index in 1...6 {
                let iconName = "tabBar_icon_\(index)@2x.png"
                SandboxTool.moveBundleDataToLibrary(of: iconName, is: .image, subPathStr: subPath)
                let selIconName = "tabBar_icon_\(index)_sel@2x.png"
                SandboxTool.moveBundleDataToLibrary(of: selIconName, is: .image, subPathStr: subPath)
            }
        }
    }

    private func openMainVC() {
        let mainVC = MainVC()
        mainVC.vcName = "MainVC"
        kMainVC = mainVC
        VCController.push(mainVC, with: nil)
    }
}

// MARK: - 引导页代理
extension StartViewController: SwiftIntroViewDelegate {
    func doneButtonClick() {
        self.moveTabberIcon()
        self.openMainVC()

        UIView.animate(
            withDuration: 1,
            animations: { () -> Void in
                self.introView?.alpha = 0
            }
        ) { _ -> Void in
            self.introView?.removeFromSuperview()
        }
    }
}
