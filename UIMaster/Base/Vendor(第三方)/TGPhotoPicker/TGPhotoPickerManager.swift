//
//  TGPhotoPickerManager.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/25.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import Photos
import TZImagePickerController
import UIKit

class TGPhotoPickerManager: NSObject {
    static let shared = TGPhotoPickerManager()
    var handlePhotosBlock: HandlePhotosBlock?
    var handlePhotoModelsBlock: HandlePhotoModelsBlock?

    override private init() {
        super.init()
    }

    fileprivate lazy var config = TGPhotoPickerConfig.shared

    func takePhotos(_ showCamera: Bool, _ showAlbum: Bool, _ configBlock:((_ config: TGPhotoPickerConfig) -> Void)? = nil, _ completeHandler: @escaping HandlePhotosBlock) {
        configBlock?(self.config)
        self.handlePhotosBlock = completeHandler

        if config.useCustomActionSheet {
            let sheet = TGActionSheet(delegate: self, cancelTitle: config.cancelTitle, otherTitles: [config.cameraTitle, config.selectTitle])
            sheet.show()
            return
        }

        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let action1 = UIAlertAction(title: config.cameraTitle, style: .default) { _ in
            self.actionSheet(actionSheet: nil, didClickedAt: 0)
        }

        let action2 = UIAlertAction(title: config.selectTitle, style: .default) { _ in
            self.actionSheet(actionSheet: nil, didClickedAt: 1)
        }
        showCamera ? ac.addAction(action1) : ()
        showAlbum ? ac.addAction(action2) : ()
        ac.addAction(UIAlertAction(title: config.cancelTitle, style: .cancel, handler: nil))
        UIApplication.shared.keyWindow?.currentVC()?.present(ac, animated: true, completion: nil)
    }

    func takePhotoModels(_ showCamera: Bool, _ showAlbum: Bool, _ configBlock:((_ config: TGPhotoPickerConfig) -> Void)? = nil, _ completeHandler: @escaping HandlePhotoModelsBlock) {
        configBlock?(self.config)
        self.handlePhotoModelsBlock = completeHandler

        if config.useCustomActionSheet {
            let sheet = TGActionSheet(delegate: self, cancelTitle: config.cancelTitle, otherTitles: [config.cameraTitle, config.selectTitle])
            sheet.show()
            return
        }

        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let action1 = UIAlertAction(title: config.cameraTitle, style: .default) { _ in
            self.actionSheet(actionSheet: nil, didClickedAt: 0)
        }

        let action2 = UIAlertAction(title: config.selectTitle, style: .default) { _ in
            self.actionSheet(actionSheet: nil, didClickedAt: 1)
        }
        showCamera ? ac.addAction(action1) : ()
        showAlbum ? ac.addAction(action2) : ()
        ac.addAction(UIAlertAction(title: config.cancelTitle, style: .cancel, handler: nil))
        kWindowRootVC?.present(ac, animated: true, completion: nil)
    }

    func authorizePhotoLibrary(authorizeClosure:@escaping (PHAuthorizationStatus) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            authorizeClosure(status)
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ state in
                DispatchQueue.main.async(execute: {
                    authorizeClosure(state)
                })
            })
        } else {
            let sheet = TGActionSheet(delegate: self, title: config.photoLibraryUsage + "("+config.photoLibraryUsageTip+")", cancelTitle: config.cancelTitle, otherTitles: [config.confirmTitle])
            sheet.name = "photoLibraryAuthorize"
            sheet.show()
            authorizeClosure(status)
        }
    }

    func authorizeCamera(authorizeClosure:@escaping (AVAuthorizationStatus) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)

        if status == .authorized {
            authorizeClosure(status)
        } else if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { granted in
                if granted {
                    authorizeClosure(.authorized)
                }
            })
        } else {
            let sheet = TGActionSheet(delegate: self, title: config.cameraUsage + "("+config.cameraUsageTip+")", cancelTitle: config.cancelTitle, otherTitles: [config.confirmTitle])
            sheet.name = "cameraAuthorize"
            sheet.show()
            authorizeClosure(status)
        }
    }

    static func convertAssetArrToImageArr(assetArr: Array<PHAsset>, scale: CGFloat = TGPhotoPickerConfig.shared.compressionQuality) -> [UIImage] {
        var imageArr = [UIImage]()
        for item in assetArr {
            if item.mediaType == .image {
                getAssetOrigin(asset: item, dealImageSuccess: { img, _ in
                    guard img != nil else { return }
                    if let zipImageData = UIImageJPEGRepresentation(img!, scale) {
                        let image = UIImage(data: zipImageData)
                        imageArr.append(image!)
                    }
                })
            }
        }
        return imageArr
    }

    static func convertAssetArrToAVPlayerItemArr(assetArr: Array<PHAsset>) -> [AVPlayerItem] {
        var videoArr = [AVPlayerItem]()
        for item in assetArr {
            if item.mediaType == .video {
                let videoRequestOptions = PHVideoRequestOptions()
                videoRequestOptions.deliveryMode = .automatic
                videoRequestOptions.version = .current
                videoRequestOptions.isNetworkAccessAllowed = true
                PHImageManager.default().requestPlayerItem(forVideo: item, options: videoRequestOptions) { playItem, _ in
                    if playItem != nil {
                        videoArr.append(playItem!)
                    }
                }
            }
        }
        return videoArr
    }

    static func getAssetOrigin(asset: PHAsset, dealImageSuccess:@escaping (UIImage?, [AnyHashable: Any]?) -> Void) {
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { originImage, info in
            dealImageSuccess(originImage, info)
        }
    }

    deinit {
        //dPrint("TGPhotoPickerManager deinit")
    }
}

extension TGPhotoPickerManager: TGActionSheetDelegate, TZImagePickerControllerDelegate {
    func actionSheet(actionSheet: TGActionSheet?, didClickedAt index: Int) {
        switch actionSheet?.name ?? "" {
        case "photoLibraryAuthorize", "cameraAuthorize":
            switch index {
            case 0:
                let url = URL(string: UIApplicationOpenSettingsURLString)
                if let url = url, UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: {_ in
                            })
                        }
                    } else {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
            default:
                break
            }
        default:
            switch index {
            case 0:
                if TGPhotoPickerConfig.shared.useiOS8Camera {
                    let cameraVC = TGCameraVCForiOS8()
                    cameraVC.callbackPicutureData = { imgData in
                        let bigImg = UIImage(data: imgData!)
                        let imgData = UIImageJPEGRepresentation(bigImg!, TGPhotoPickerConfig.shared.compressionQuality)
                        let smallImg = bigImg
                        let model = TGPhotoM()
                        model.bigImage = bigImg
                        model.imageData = imgData
                        model.smallImage = smallImg
                        self.handlePhotoModelsBlock?([model])
                        self.handlePhotosBlock?([nil], [smallImg], [bigImg], [imgData])
                    }
                    kWindowRootVC?.present(cameraVC, animated: true, completion: nil)
                } else if #available(iOS 10.0, *) {
                    let cameraVC = TGCameraVC()
                    cameraVC.callbackPicutureData = { imgData in
                        let bigImg = UIImage(data: imgData!)
                        let imgData = UIImageJPEGRepresentation(bigImg!, TGPhotoPickerConfig.shared.compressionQuality)
                        let smallImg = bigImg
                        let model = TGPhotoM()
                        model.bigImage = bigImg
                        model.imageData = imgData
                        model.smallImage = smallImg
                        self.handlePhotoModelsBlock?([model])
                        self.handlePhotosBlock?([nil], [smallImg], [bigImg], [imgData])
                    }
                    UIApplication.shared.keyWindow?.currentVC()?.present(cameraVC, animated: true, completion: nil)
                } else {
                    let cameraVC = TGCameraVCForiOS8()
                    cameraVC.callbackPicutureData = { imgData in
                        let bigImg = UIImage(data: imgData!)
                        let imgData = UIImageJPEGRepresentation(bigImg!, TGPhotoPickerConfig.shared.compressionQuality)
                        let smallImg = bigImg
                        let model = TGPhotoM()
                        model.bigImage = bigImg
                        model.imageData = imgData
                        model.smallImage = smallImg
                        self.handlePhotoModelsBlock?([model])
                        self.handlePhotosBlock?([nil], [smallImg], [bigImg], [imgData])
                    }
                    kWindowRootVC?.present(cameraVC, animated: true, completion: nil)
                }
            case 1:
                guard let imagePickerVC = TZImagePickerController(maxImagesCount: 9, delegate: self) else { return }
                imagePickerVC.allowPickingVideo = false
                imagePickerVC.didFinishPickingPhotosHandle = { photos, assets, finish in
//                    for photo in photos ?? []{
//                        self.tgphotos.append(contentsOf: images)
//                        DispatchQueue.main.async {
//                            self.collectionView?.reloadData()
//                        }
//                    }
                }
                kWindowRootVC?.present(imagePickerVC, animated: true, completion: nil)
            default:
                break
            }
        }
    }
}

extension UIWindow {
    func topMostVC() -> UIViewController? {
        var topController = rootViewController
        while let presentedController = kWindowRootVC?.presentedViewController {
            topController = presentedController
        }
        return topController
    }

    func currentVC() -> UIViewController? {
        var currentViewController = topMostVC()
        while currentViewController != nil &&
              currentViewController is UINavigationController &&
            (currentViewController as? UINavigationController)?.topViewController != nil {
            currentViewController = (currentViewController as? UINavigationController)?.topViewController
        }
        return currentViewController
    }
}
