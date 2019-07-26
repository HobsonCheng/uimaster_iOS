//
//  AVPermissionCheckAble.swift
//  UIMaster
//
//  Created by hobson on 2018/11/19.
//  Copyright © 2018 one2much. All rights reserved.
//

import Photos
import UIKit

@objc protocol AVPermissionCheckAble {
}

extension AVPermissionCheckAble {
    /// 检测相机是否授权，并且回调
    ///
    /// - Parameter authorized: 授权后的回调
    func authorizationCameraPermission(authorized:() -> Void) {
        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .notDetermined {
            self.checkCameraPermission()
        } else if authStatus == .restricted || authStatus == .denied {
            let alertVC = UIAlertController(title: "提示", message: "请在iPhone的“设置-隐私-相机”选项中，允许单位APP访问您的相机", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "前往设置", style: .default, handler: { _ in
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            }))
            alertVC.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: nil))
            kWindowRootVC?.present(alertVC, animated: true, completion: nil)
        } else if authStatus == .authorized {
            authorized()
        }
    }

    /// 检测相机授权
    func checkCameraPermission() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {granted in
            if !granted {
                let alertVC = UIAlertController(title: "提示", message: "请在iPhone的“设置-隐私-相机”选项中，允许单位APP访问您的相机", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "前往设置", style: .default, handler: { _ in
                    UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                }))
                alertVC.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: nil))
                kWindowRootVC?.present(alertVC, animated: true, completion: nil)
            }
        })
    }
}
