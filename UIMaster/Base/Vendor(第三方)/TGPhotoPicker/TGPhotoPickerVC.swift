//
//  TGPhotoPickerVC.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/21.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import Photos
import UIKit

enum TGPageType {
    case list
    case recentAlbum
    case allAlbum
}

protocol TGPhotoPickerDelegate: AnyObject {
    func onImageSelectFinished(images: [PHAsset])
    func onImageSelectFinished(images: [TGPhotoM])
}

typealias HandlePhotosBlock = (_ asset: [PHAsset?], _ smallImage: [UIImage?], _ bigImage: [UIImage?], _ imageData: [Data?]) -> Void
typealias HandlePhotoModelsBlock = (_ photoMs: [TGPhotoM]) -> Void

class TGPhotoPickerVC: UINavigationController {
    var alreadySelectedImageNum = 0
    var assetArr = [PHAsset]()
    weak var imageSelectDelegate: TGPhotoPickerDelegate?
    var callbackPhotos: HandlePhotosBlock?
    var callbackPhotoMs: HandlePhotoModelsBlock?

    deinit {
        dPrint("销毁")
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    init(type: TGPageType) {
        let rootVC = TGPhotoListVC(style: .plain)
        super.init(rootViewController: rootVC)

        self.navigationBar.setBackgroundImage(UIImage.size(width: 1, height: 1).color(TGPhotoPickerConfig.shared.barBGColor).image, for: UIBarMetrics.default)

//        if #available(iOS 9.0, *) {
//            let isVCBased = Bundle.main.infoDictionary?["UIViewControllerBasedStatusBarAppearance"] as? Bool ?? false
//            if !isVCBased {
//                self.preferredStatusBarStyle = .default
//                UIApplication.shared.setStatusBarHidden(false, with: .none)
//            }
//        }else {
//            UIApplication.shared.statusBarStyle = .lightContent
//            UIApplication.shared.setStatusBarHidden(false, with: .none)
//        }
        // swiftlint:disable empty_count
        if type == .recentAlbum || type == .allAlbum {
            let currentType = type == .recentAlbum ? PHAssetCollectionSubtype.smartAlbumRecentlyAdded : PHAssetCollectionSubtype.smartAlbumUserLibrary
            let results = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: currentType, options: nil)
            if results.count > 0 {
                if let model = self.getModel(collection: results[0]) {
                    if model.count > 0 {
                        let layout = TGPhotoCollectionVC.configCustomCollectionLayout()
                        let vc = TGPhotoCollectionVC(collectionViewLayout: layout)
                        vc.fetchResult = model
                        vc.title = TGPhotoPickerConfig.shared.useChineseAlbumName ? TGPhotoPickerConfig.getChineseAlbumName(currentType) : results[0].localizedTitle
                        self.pushViewController(vc, animated: false)
                    }
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func getModel(collection: PHAssetCollection) -> PHFetchResult<PHAsset>? {
        let fetchResult = PHAsset.fetchAssets(in: collection, options: TGPhotoFetchOptions())
        return fetchResult.count > 0 ? fetchResult : nil
    }
    // swiftlint:enable empty_count

    func imageSelectFinish() {
        self.dismiss(animated: true) {[weak self] in
            TGPhotoM.getImagesAndDatas(photos: (self?.assetArr ?? [])) {[weak self] array in
                self?.callbackPhotos?((self?.assetArr ?? []), array.map { $0.smallImage }, array.map { $0.bigImage }, array.map { $0.imageData })
                self?.callbackPhotoMs?(array)
                self?.imageSelectDelegate?.onImageSelectFinished(images: array)
            }
        }
    }
}
