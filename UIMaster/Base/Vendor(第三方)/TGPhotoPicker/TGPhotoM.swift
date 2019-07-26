//
//  TGPhotoM.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/12.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import Photos
import UIKit

class TGPhotoM: NSObject {
    var smallImage: UIImage?
    var bigImage: UIImage?
    var imageData: Data?
    static var originImage = false
    var asset: PHAsset? {
        didSet {
            if self.asset?.mediaType == .video {
                if self.asset?.duration == nil {
                    self.videoLength = ""
                } else {
                    self.videoLength = TGPhotoM.getNewTimeFromDuration(duration: (self.asset?.duration)!)
                }
            }
        }
    }
    var order: Int = 0

    var videoLength: String?

    convenience init(asset: PHAsset) {
        self.init()

        let imageManeger = PHImageManager()

        let smallOptions = PHImageRequestOptions()
        smallOptions.deliveryMode = .opportunistic
        smallOptions.resizeMode = .fast

        let bigOptions = PHImageRequestOptions()
        bigOptions.deliveryMode = .opportunistic
        bigOptions.resizeMode = .exact

        self.asset = asset

        let bigSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        imageManeger.requestImage(for: asset, targetSize: bigSize, contentMode: PHImageContentMode(rawValue: 0)!, options: bigOptions, resultHandler: { image, _ in
            if image != nil {
                self.bigImage = image!
            }
        })

        let smallSize = CGSize(width: TGPhotoPickerConfig.shared.selectWH * UIScreen.main.scale, height: TGPhotoPickerConfig.shared.selectWH * UIScreen.main.scale)
        imageManeger.requestImage(for: asset, targetSize: smallSize, contentMode: PHImageContentMode(rawValue: 0)!, options: smallOptions, resultHandler: { image, _ in
            if image != nil {
                self.smallImage = image!
            }
        })

        imageManeger.requestImageData(for: asset, options: bigOptions, resultHandler: { data, _, _, _ in
            if data != nil {
                self.imageData = data!
            }
        })
    }

    class func getImagesAndDatas(photos: [PHAsset], imageData:@escaping(_ photoArr: [TGPhotoM]) -> Void) {
        let smallOptions = PHImageRequestOptions()
        smallOptions.deliveryMode = .fastFormat
        smallOptions.resizeMode = .fast
        smallOptions.isNetworkAccessAllowed = true
        smallOptions.deliveryMode = .fastFormat

        let bigOptions = PHImageRequestOptions()
        bigOptions.deliveryMode = .highQualityFormat
        bigOptions.resizeMode = .exact
        bigOptions.isNetworkAccessAllowed = true

        let imageManeger = PHImageManager.default()
//        let smallSize = CGSize(width: TGPhotoPickerConfig.shared.mainCellWH * UIScreen.main.scale, height: TGPhotoPickerConfig.shared.mainCellWH * UIScreen.main.scale)

//        PHImageManagerMaximumSize
        //CGSize(width:, height:)
        var modelArr = [TGPhotoM]()
        var tempCount = 0
        for idx in 0..<photos.count {
            let asset = photos[idx]
            let photoWidth = UIScreen.main.bounds.size.width
            let aspectRatio = asset.pixelWidth / asset.pixelHeight
            let multiple = UIScreen.main.scale
            let pixelWidth = photoWidth * multiple
            let pixelHeight = pixelWidth / CGFloat(aspectRatio)
            let bigSize = CGSize(width: pixelWidth, height: pixelHeight)
            let model = TGPhotoM()
            let option = PHImageRequestOptions()
            option.isNetworkAccessAllowed = true
            option.resizeMode = PHImageRequestOptionsResizeMode.fast
            model.asset = asset
            model.order = idx
            imageManeger.requestImageData(for: asset, options: option) { data, _, _, _ in
                tempCount += 1
                model.bigImage = UIImage(data: data!)
                model.smallImage = UIImage(data: data!)
                modelArr.append(model)
                if tempCount == photos.count {
                    originImage = false
//                    DispatchQueue.main.async {
                        imageData(modelArr.sorted(by: { $0.order < $1.order }))
//                    }
                }
            }
//            imageManeger.requestImage(for: asset, targetSize: originImage ? PHImageManagerMaximumSize : bigSize, contentMode: .aspectFit, options: option, resultHandler: { (image, info) in
//                tempCount += 1
//                model.bigImage = image
//                model.smallImage = image
//                modelArr.append(model)
//                if tempCount == photos.count{
//                    originImage = false
//                    DispatchQueue.main.async {
//                        imageData(modelArr.sorted(by: { return $0.order < $1.order }))
//                    }
//                }
//
////                if let bigImg = image{
////                    model.bigImage = bigImg
////                    imageManeger.requestImage(for: asset, targetSize: smallSize, contentMode: .aspectFit, options: smallOptions, resultHandler: { (image, info) in
////                        tempCount += 1
////                        if let smallImg = image {
////                            model.smallImage = smallImg
////
////                            if let data = UIImageJPEGRepresentation(bigImg, 1) {
////                                model.imageData = data
////                                modelArr.append(model)
////                                if tempCount == photos.count{
////                                    DispatchQueue.main.async {
////                                        imageData(modelArr.sorted(by: { return $0.order < $1.order }))
////                                    }
////                                }
////                            }
////                        }
////                    })
////                }else{
////                    tempCount += 1
////                }
//            })
        }
    }

    static func getNewTimeFromDuration(duration: Double) -> String {
        var newTimer = ""
        if duration < 10 {
            newTimer = String(format: "0:0%d", arguments: [Int(duration)])
            return newTimer
        } else if duration < 60 && duration >= 10 {
            newTimer = String(format: "0:%.0f", arguments: [duration])
            return newTimer
        } else {
            let min = Int(duration / 60)
            let sec = Int(duration - (Double(min) * 60))
            if sec < 10 {
                newTimer = String(format: "%d:0%d", arguments: [min, sec])
                return newTimer
            } else {
                newTimer = String(format: "%d:%d", arguments: [min, sec])
                return newTimer
            }
        }
    }
}
