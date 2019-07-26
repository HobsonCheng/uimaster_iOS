//
//  UIShareAble.swift
//  UIMaster
//
//  Created by hobson on 2018/11/16.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit

protocol UIShareAble {}
extension UIShareAble {
    /// 调用系统分享
    ///
    /// - Parameters:
    ///   - text: 标题
    ///   - imageName: bundle图片名
    ///   - orImage: 图片
    ///   - linkStr: 链接
    func shareToOthers(text: String?, imageName: String?, orImage: UIImage? = nil, linkStr: String?) {
        Self.shareToOthersStatic(text: text, imageName: imageName, orImage: orImage, linkStr: linkStr)
    }

    /// 调用系统分享
    ///
    /// - Parameters:
    ///   - text: 标题
    ///   - imageName: bundle图片名
    ///   - orImage: 图片
    ///   - linkStr: 链接
    static func shareToOthersStatic(text: String?, imageName: String?, orImage: UIImage? = nil, linkStr: String?) {
        let shareText = text
        let url = URL(string: linkStr ?? "")
        let image = UIImage(named: imageName ?? "")
        var shareArr = [Any]()
        if let url = url {
            shareArr.append(url)
        }
        if let image = image {
            shareArr.append(image)
        }
        if let image = orImage {
            shareArr.append(image)
        }
        if let text = shareText {
            shareArr.append(text)
        }

        let activityVC = UIActivityViewController(activityItems: shareArr, applicationActivities: nil)
        activityVC.isModalInPopover = true
        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList, .init(rawValue: "com.apple.reminders.RemindersEditorExtension")]

        kWindowRootVC?.present(activityVC, animated: true, completion: nil)

        activityVC.completionWithItemsHandler = { type, complete, back, error in
            if complete {
                HUDUtil.msg(msg: "分享成功", type: .successful)
            }
            if error != nil {
                HUDUtil.msg(msg: "分享失败", type: .error)
            }
        }
    }
}
