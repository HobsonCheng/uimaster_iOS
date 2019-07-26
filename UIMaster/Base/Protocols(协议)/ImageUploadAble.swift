//
// Created by hobson on 2018/11/28.
// Copyright (c) 2018 one2much. All rights reserved.
//

import UIKit

@objc protocol ImageUploadAble {}
extension ImageUploadAble {
    // MARK: 上传图片
    func uplaodImage(images: [UIImage]?, showProgress: Bool = true, uploadFinish:@escaping ([String]?) -> Void) {
        //图片为空返回
        guard let safeImages = images else {
            HUDUtil.msg(msg: "图片数据为空", type: .error)
            return
        }
        //上传七牛云
        let handler = HUDUtil.upLoadProgres()
        UploadImageTool.uploadImages(imageArray: safeImages, progress: { _, progress in
            if showProgress {
                DispatchQueue.main.async {
                    handler(CGFloat(progress))
                }
            }
        }, success: { urlArr in
            dPrint("url:\(urlArr)")
            DispatchQueue.main.async {
                HUDUtil.stopLoadingHUD(callback: nil)
            }
            uploadFinish(urlArr)
        }) { errorMsg in
            DispatchQueue.main.async {
                HUDUtil.stopLoadingHUD(callback: nil)
            }
            HUDUtil.msg(msg: errorMsg, type: .error)
        }
    }
}
