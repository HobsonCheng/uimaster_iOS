//
//  PickImageRow.swift
//  UIMaster
//
//  Created by hobson on 2018/7/7.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Eureka
import UIKit

class PickImageCell: Cell<[String]>, CellType {
    lazy var picker = TGPhotoPicker(kMainVC, frame: CGRect(x: 10, y: 10, width: kScreenW - 20, height: 300)) { config in
        config.type = .wechat
        config.immediateTapSelect = true
        config.isShowPreviewButton = true
        config.maxImageCount = 9
        switch kScreenType {
        case .small:
            config.mainCellWH = 60
        case .middle, .big:
            config.mainCellWH = 80
        }

        config.padding = 10
    }

    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setup() {
        super.setup()
        selectionStyle = .none
        picker.collectionView?.backgroundColor = .clear
        picker.backgroundColor = .clear
        self.addSubview(picker)
    }

    override func update() {
        super.update()
    }

    // MARK: 选取图片
    //    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    //        picker.dismiss(animated: true)
    //
    //        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
    //            dPrint("No image found")
    //            return
    //        }
    //        self.uploadImage = image
    //        uplaodImage()
    //    }
    deinit {
        dPrint("销毁")
    }
    // MARK: 上传图片
    func uplaodImages(finishCB:@escaping () -> Void) {
        //图片为空返回
        var imageArray = [UIImage]()
        for model in picker.tgphotos {
            imageArray.append(model.bigImage!)
        }
        if imageArray.isEmpty {
            finishCB()
            return
        }
        let handler = HUDUtil.upLoadProgres()
        UploadImageTool.uploadImages(imageArray: imageArray, progress: { _, progress in
            handler(CGFloat(progress))
//            HUDUtil.upLoadProgres(progressNum: CGFloat(progress))
        }, success: {[weak self] urls in
            self?.row.value = urls
            dPrint(urls)
            finishCB()
        }) { _ in
            MBMasterHUD.hide {
                 MBMasterHUD.showSuccess(title: "上传失败")
            }
        }
        //        //上传七牛云
        //        UploadImageTool.uploadImage(image: safeImage, progress: { (url, progress) in
        //            DispatchQueue.main.async {
        //                HUDUtil.upLoadProgres(progressNum: CGFloat(progress))
        //            }
        //        }, success: { (url) in
        //            dPrint("url:\(url)")
        ////            self.row.value?.imgUrl = url
        //            self.update()
        //        }) { (errorMsg) in
        //            HUDUtil.msg(msg: errorMsg, type: .error)
        //        }
    }
}

final class PickImageRow: Row<PickImageCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
    }
}
