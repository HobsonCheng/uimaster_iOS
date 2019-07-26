////
////  ImageBrowserAble.swift
////  UIMaster
////
////  Created by hobson on 2018/10/23.
////  Copyright © 2018 one2much. All rights reserved.
////
//
//import UIKit
//import JXPhotoBrowser
//
//protocol ImageBrowserAble: PhotoBrowserDelegate{
//    var browserLocalImageArr:[UIImage]? {get set}
//    var browserImageUrlStr:[String]? {get set}
//    var browserShowFromView: UIView? {get set}
//    func showImage(with images:[UIImage])
//    /// 初始化图片浏览器和图片各种资源，showImage默认图片浏览器
//    func setupBrowserAndAssets()
//}
//extension ImageBrowserAble{
//    func showImage(){
//        // 创建图片浏览器
//        let browser = PhotoBrowser(animationType: .fade, delegate: self, originPageIndex: 0)
//        // 光点型页码指示器
//        browser.cellPlugins = [ProgressViewPlugin()]
//        // 显示
//        browser.show(from: kWindowRootVC)
//    }
//}
//extension ImageBrowserAble{
//    /// 图片总数量
//    func numberOfPhotos(in photoBrowser: PhotoBrowser) -> Int {
//        return browserImageUrlStr?.count ?? browserLocalImageArr?.count ?? 0
//    }
//    
//    /// 缩略图所在 view
//    func photoBrowser(_ photoBrowser: PhotoBrowser, thumbnailViewForIndex index: Int) -> UIView? {
//        return self.browserShowFromView
//    }
//    
//    /// 缩略图图片，在加载完成之前用作 placeholder 显示
//    func photoBrowser(_ photoBrowser: PhotoBrowser, thumbnailImageForIndex index: Int) -> UIImage? {
//        return nil
//    }
//    
//    /// 高清图
//    func photoBrowser(_ photoBrowser: PhotoBrowser, highQualityUrlForIndex index: Int) -> URL? {
//        return browserImageUrlStr?[index].flatMap {
//            if $0.hasPrefix("http://") || $0.hasPrefix("https://"){
//                return URL(string: $0)
//            }else{
//                return URL(string: "http://\($0)")
//            }
//        }
//    }
//    
//    func photoBrowser(_ photoBrowser: PhotoBrowser, localImageForIndex index: Int) -> UIImage? {
//        return self.clickedCell?.model?.localoriginalStoreImage
//    }
//    /// 原图
//    func photoBrowser(_ photoBrowser: PhotoBrowser, rawUrlForIndex index: Int) -> URL? {
//        return browserImageUrlStr?[index].rawUrl.flatMap {
//            if $0.hasPrefix("http://") || $0.hasPrefix("https://"){
//                return URL(string: $0)
//            }else{
//                return URL(string: "http://\($0)")
//            }        }
//    }
//    
//    // 保存到手机
//    func photoBrowser(_ photoBrowser: PhotoBrowser, didLongPressForIndex index: Int, image: UIImage) {
//        let actionSheet = UIAlertController.init()
//        actionSheet.addAction(title: "保存到手机") {[weak self] (action) in
//            UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
//        }
//        actionSheet.addAction(title: "取消",style:.cancel, handler: nil)
//        photoBrowser.present(actionSheet, animated: true, completion: nil)
//    }
//    
//    @objc func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
//        if error == nil {
//            HUDUtil.msg(msg: "保存成功", type: .successful)
//        } else {
//            HUDUtil.msg(msg: "保存失败，请重试", type: .error)
//        }
//    }
//}
