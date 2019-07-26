//
//  ImagePickAble.swift
//  UIMaster
//
//  Created by hobson on 2018/10/23.
//  Copyright © 2018 one2much. All rights reserved.
//

import TZImagePickerController
import UIKit

@objc protocol ImagePickAble: UIImagePickerControllerDelegate, UINavigationControllerDelegate, TZImagePickerControllerDelegate, AVPermissionCheckAble, ImageUploadAble {
    @objc optional func pickImages(picNum: Int, needUpload: Bool, pickFinish:@escaping ([UIImage]?, [String]?) -> Void)
    @objc optional func pickSingleImage(pickFinish:@escaping (UIImage, String) -> Void)
}
extension ImagePickAble {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)

        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            dPrint("没有图片")
            return
        }
        uplaodImage(images: [image]) { urlArr in
            guard let safeUrlArr = urlArr, !safeUrlArr.isEmpty else { return }
            //            pickFinish(image,safeUrlArr.last!)
        }
    }
    func pickImages(picNum: Int, needUpload: Bool, pickFinish:@escaping ([UIImage]?, [String]?) -> Void) {
        guard let imagePickerVC = TZImagePickerController(maxImagesCount: 9, delegate: self) else { return }
        imagePickerVC.allowPickingVideo = false
        imagePickerVC.maxImagesCount = 1
        imagePickerVC.didFinishPickingPhotosHandle = { [weak self] images, assets, finish in
            if needUpload {
                self?.uplaodImage(images: images, uploadFinish: { urls in
                    pickFinish(images, urls)
                })
            } else {
                pickFinish(images, nil)
            }
        }
        kWindowRootVC?.present(imagePickerVC, animated: true, completion: nil)
    }

    func pickSingleImage(pickFinish:@escaping (UIImage, String) -> Void) {
        let alert = UIAlertController(title: "选择图片", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "拍照", style: .default, handler: { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                picker.allowsEditing = true
                kWindowRootVC?.present(picker, animated: true, completion: nil)
            } else {
                HUDUtil.msg(msg: "您的设备好像不支持照相机~~", type: .info)
            }
        }))
        alert.addAction(UIAlertAction(title: "选择图片", style: .default, handler: { _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            kWindowRootVC?.present(picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.show()

        // MARK: 选取图片
        //        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //            picker.dismiss(animated: true)
        //
        //            guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
        //                dPrint("没有图片")
        //                return
        //            }
        //            uplaodImage(images: [image]) { (urlArr) in
        //                guard let safeUrlArr = urlArr,safeUrlArr.count > 0 else { return }
        //                pickFinish(image,safeUrlArr.last!)
        //            }
        //        }
    }
}
