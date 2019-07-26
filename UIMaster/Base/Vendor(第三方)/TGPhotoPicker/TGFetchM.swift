//
//  TGFetchM.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/13.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import Photos
import UIKit

class TGFetchM {
    var fetchResult: PHFetchResult<PHObject>!
    var assetType: PHAssetCollectionSubtype!
    var name: String!

    init(result: PHFetchResult<PHObject>, name: String?, assetType: PHAssetCollectionSubtype) {
        self.fetchResult = result
        self.name = name
        self.assetType = assetType
    }
}
