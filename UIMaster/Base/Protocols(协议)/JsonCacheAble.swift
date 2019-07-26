//
//  JsonCacheAble.swift
//  UIMaster
//
//  Created by hobson on 2018/11/19.
//  Copyright © 2018 one2much. All rights reserved.
//

import Cache
import UIKit

protocol JsonCacheAble {}

extension JsonCacheAble {
    /// 获取缓存的json数据
    ///
    /// - Parameters:
    ///   - key: 缓存key
    ///   - callBack: 返回缓存的数据
    func getCacheJson(key: String, callBack:(_ json: String) -> Void) {
        do {
            let storage = try Storage(diskConfig: DiskConfig(name: "cache"), memoryConfig: MemoryConfig(), transformer: TransformerFactory.forData())
            let data = try storage.object(forKey: key)
            let str = String(data: data, encoding: String.Encoding.utf8)
            if let safeStr = str {
                callBack(safeStr)
            }
        } catch {
            dPrint(error)
        }
    }

    /// 缓存数据
    ///
    /// - Parameters:
    ///   - key: 缓存key
    ///   - json: 缓存的json
    func cacheJson(key: String, json: String?) {
        do {
            let storage = try Storage(diskConfig: DiskConfig(name: "cache"), memoryConfig: MemoryConfig(), transformer: TransformerFactory.forData())
            if let safeData = json?.data(using: String.Encoding.utf8) {
                try storage.setObject(safeData, forKey: key)
            }
        } catch {
            dPrint(error)
        }
    }

    /// 移除所有缓存
    func removeAllCache() {
        do {
            let storage = try Storage(diskConfig: DiskConfig(name: "cache"), memoryConfig: MemoryConfig(), transformer: TransformerFactory.forData())
            try storage.removeAll()
        } catch {
            dPrint(error)
        }
    }

    /// 移除指定缓存
    ///
    /// - Parameter ket: 缓存key
    func removeCacheForKey(key: String) {
        do {
            let storage = try Storage(diskConfig: DiskConfig(name: "cache"), memoryConfig: MemoryConfig(), transformer: TransformerFactory.forData())
            try storage.removeObject(forKey: key)
        } catch {
            dPrint(error)
        }
    }
}
