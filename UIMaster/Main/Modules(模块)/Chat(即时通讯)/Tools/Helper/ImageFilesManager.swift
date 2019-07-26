//
//  ImageFilesManager.swift
//  UIMaster
//
//  Created by hobson on 2018/9/27.
//  Copyright © 2018 one2much. All rights reserved.
//

import Foundation
import Kingfisher

/*
 围绕 Kingfisher 构建的缓存器，先预存图片名称，等待上传完毕后改成 URL 的名字。
 https://github.com/onevcat/Kingfisher/blob/master/Sources%2FImageCache.swift#l625
 */

class ImageFilesManager {
    let imageCacheFolder = KingfisherManager.shared.cache

    @discardableResult
    class func cachePathForKey(_ key: String) -> String? {
        let fileName = key.MD5Str
        return (KingfisherManager.shared.cache.diskCachePath as NSString).appendingPathComponent(fileName)
    }

    class func storeImage(_ image: UIImage, key: String, completionHandler: (() -> Void)?) {
        KingfisherManager.shared.cache.removeImage(forKey: key)
        KingfisherManager.shared.cache.store(image, forKey: key, toDisk: true, completionHandler: completionHandler)
    }

    /**
     修改文件名称
     
     - parameter originPath:      原路径
     - parameter destinationPath: 目标路径
     
     - returns: 目标路径
     */
    @discardableResult
    class func renameFile(_ originPath: URL, destinationPath: URL) -> Bool {
        do {
              try FileManager.default.moveItem(atPath: originPath.path, toPath: destinationPath.path)
            return true
        } catch let error as NSError {
            dPrint("error:\(error)")
            return false
        }
    }
}

class ImageScaler {
    /**
     获取缩略图的尺寸
     
     - parameter originalSize: 原始图的尺寸 size
     
     - returns: 返回的缩略图尺寸
     */
    class func getThumbImageSize(_ originalSize: CGSize) -> CGSize {
        let imageRealHeight = originalSize.height
        let imageRealWidth = originalSize.width

        var resizeThumbWidth: CGFloat
        var resizeThumbHeight: CGFloat
        /**
         *  1）如果图片的高度 >= 图片的宽度 , 高度就是最大的高度，宽度等比
         *  2）如果图片的高度 < 图片的宽度 , 以宽度来做等比，算出高度
         */
        if imageRealHeight >= imageRealWidth {
            let scaleWidth = imageRealWidth * kChatImageMaxHeight / imageRealHeight
            resizeThumbWidth = (scaleWidth > kChatImageMinWidth) ? scaleWidth : kChatImageMinWidth
            resizeThumbHeight = kChatImageMaxHeight
        } else {
            let scaleHeight = imageRealHeight * kChatImageMaxWidth / imageRealWidth
            resizeThumbHeight = (scaleHeight > kChatImageMinHeight) ? scaleHeight : kChatImageMinHeight
            resizeThumbWidth = kChatImageMaxWidth
        }

        return CGSize(width: resizeThumbWidth, height: resizeThumbHeight)
    }
}
