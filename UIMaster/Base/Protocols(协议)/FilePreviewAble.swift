//
//  FilePreviewAble.swift
//  UIMaster
//
//  Created by hobson on 2018/10/29.
//  Copyright © 2018 one2much. All rights reserved.
//

import Foundation
import QuickLook

//@objc protocol FilePreviewAble : UIDocumentInteractionControllerDelegate,QLPreviewControllerDelegate,QLPreviewControllerDataSource{
//    @objc func preViewLocalFile(urlStr: String?)
//    var filePathStr: String?{set get}
//}
//extension FilePreviewAble{
//    
//    func preViewLocalFile(urlStr: String?){
//        filePathStr = urlStr
//        let previewVC = QLPreviewController.init()
//        previewVC.dataSource = self
//        previewVC.delegate = self
//        previewVC.hidesBottomBarWhenPushed = true
//        previewVC.currentPreviewItemIndex = 1
//        kWindowRootVC?.present(previewVC, animated: false, completion: nil)
////        let url =  URL.init(fileURLWithPath: urlStr ?? "")
////        let webView = OtherWebVC.init()
////        webView.localUrlString = urlStr
////        webView.loadLocal()
////        VCController.push(previewVC, with: VCAnimationBottom.defaultAnimation())
////        let document = UIDocumentInteractionController.init(url: url)
////        document.delegate = self
////        document.presentPreview(animated: true)
//    }
//    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
//        return 1
//    }
//    
//    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
//        return URL.init(fileURLWithPath: filePathStr ?? "") as QLPreviewItem
//    }
//}
