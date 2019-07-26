//
//  DiskCacheHelper.swift
//  DiskCache
//
//  Created by duzhe on 16/3/3.
//  Copyright © 2016年 dz. All rights reserved.
//

import UIKit

//typealias `$` = DiskCacheHelper
public struct DiskCacheHelper {
    /**
      本地缓存对象
     */
    static func saveObj(_ key: String, value: Any?, completeHandler:(() -> Void)? = nil) {
        DiskCache.sharedCacheObj.stroe(key, value: value, image: nil, data: nil, completeHandler: completeHandler)
    }

    /**
      本地缓存图片
     */
    static func saveImg(_ key: String, image: UIImage?, completeHandler:(() -> Void)? = nil) {
        DiskCache.sharedCacheImage.stroe(key, value: nil, image: image, data: nil, completeHandler: completeHandler)
    }

    /**
     本地缓存音频 或者其他 NSData类型
     */
    static func saveVoc(_ key: String, data: Data?, completeHandler:(() -> Void)? = nil) {
        DiskCache.sharedCacheVoice.stroe(key, value: nil, image: nil, data: data, completeHandler: completeHandler)
    }

    /**
      获得本地缓存的对象
     */
    static func getObj(_ key: String, compelete:@escaping ((_ obj: Any?) -> Void)) {
        DiskCache.sharedCacheObj.retrieve(key, objectGetHandler: compelete, imageGetHandler: nil, voiceGetHandler: nil)
    }

    /**
     获得本地缓存的图像
     */
    static func getImg(_ key: String, compelete:@escaping ((_ image: UIImage?) -> Void)) {
        DiskCache.sharedCacheImage.retrieve(key, objectGetHandler: nil, imageGetHandler: compelete, voiceGetHandler: nil)
    }

    /**
     获得本地缓存的音频数据文件
     */
    static func getVoc(_ key: String, compelete:@escaping ((_ data: Data?) -> Void)) {
        DiskCache.sharedCacheVoice.retrieve(key, objectGetHandler: nil, imageGetHandler: nil, voiceGetHandler: compelete)
    }
}
