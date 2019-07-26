//
//  DiskCache.swift
//  DiskCache
//
//  Created by duzhe on 16/3/2.
//  Copyright © 2016年 dz. All rights reserved.
//

import UIKit

private let page = DiskCache(type: .object)
private let image = DiskCache(type: .image)
private let voice = DiskCache(type: .voice)

//会在cache下创建目录管理
enum CacheFor: String {
    case object = "zzObject"     //页面对象缓存 (缓存的对象)
    case image = "zzImage"  //图片缓存 (缓存NSData)
    case voice = "zzVoice"  //语音缓存 (缓存NSData)
}

open class DiskCache {
    fileprivate let defaultCacheName = "zz_default"
    fileprivate let cachePrex = "com.zz.zzdisk.cache."
    fileprivate let ioQueueName = "com.zz.zzdisk.cache.ioQueue."

    fileprivate var fileManager: FileManager!
    fileprivate let ioQueue: DispatchQueue
    var diskCachePath: String
    // 针对Page
    open class var sharedCacheObj: DiskCache {
        return page
    }

    // 针对Image
    open class var sharedCacheImage: DiskCache {
        return image
    }

    // 针对Voice
    open class var sharedCacheVoice: DiskCache {
        return voice
    }

    fileprivate var storeType: CacheFor

    init(type: CacheFor) {
        self.storeType = type
        let cacheName = cachePrex + type.rawValue
        ioQueue = DispatchQueue(label: ioQueueName + type.rawValue, attributes: [])
        //获取缓存目录
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)

        diskCachePath = (paths.first! as NSString).appendingPathComponent(cacheName)

        ioQueue.sync { () -> Void in
            self.fileManager = FileManager()
            //先创建好对象的文件夹
            do {
                try self.fileManager.createDirectory(atPath: self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
            } catch _ {}
        }
    }

    /**
     存储
     
     - parameter key:             键
     - parameter value:           值
     - parameter image:           图像
     - parameter data:            data
     - parameter completeHandler: 完成回调
     */
    open func stroe(_ key: String, value: Any? = nil, image: UIImage?, data: Data?, completeHandler:(() -> Void)? = nil) {
        /**
         对象存储 归档操作后写入文件
         
         - parameter key:   键
         - parameter value: 值
         - parameter path: 路径
         - parameter completeHandler: 完成后回调
         */
        func stroeObject(_ key: String, value: Any?, path: String, completeHandler:(() -> Void)? = nil) {
            ioQueue.async {
                let data = NSMutableData()
                var keyArchiver: NSKeyedArchiver!
                keyArchiver = NSKeyedArchiver(forWritingWith: data)
                keyArchiver.encode(value, forKey: key.MD5Str)  //对key进行MD5加密
                keyArchiver.finishEncoding() //归档完毕

                do {
                    try data.write(toFile: path, options: NSData.WritingOptions.atomic)  //存储
                    //完成回调
                    completeHandler?()
                } catch let err {
                    dPrint("err:\(err)")
                }
            }
        }

        /**
         图像存储
         
         - parameter image:           image
         - parameter key:             键
         - parameter path:            路径
         - parameter completeHandler: 完成回调
         */
        func storeImage(_ image: UIImage, forKey key: String, path: String, completeHandler:(() -> Void)? = nil) {
            ioQueue.async {
                let data = UIImageJPEGRepresentation(image.zz_normalizedImage(), 0.9)
                if let data = data {
                    self.fileManager.createFile(atPath: path, contents: data, attributes: nil)
                }
            }
        }

        /**
         存储声音
         
         - parameter data:            data
         - parameter key:             键
         - parameter path:            路径
         - parameter completeHandler: 完成回调
         */
        func storeVoice(_ data: Data?, forKey key: String, path: String, completeHandler:(() -> Void)? = nil) {
            ioQueue.async {
                if let data = data {
                    self.fileManager.createFile(atPath: path+".ima4", contents: data, attributes: nil)
                }
            }
        }

        let path = self.cachePathForKey(key)
        switch storeType {
        case .object:
            stroeObject(key, value: value, path: path, completeHandler: completeHandler)
        case .image:
            if let image = image {
                storeImage(image, forKey: key, path: path, completeHandler: completeHandler)
            }
        case .voice:
            storeVoice(data, forKey: key, path: path, completeHandler: completeHandler)
        }
    }

    /**
     获取数据的方法
     
     - parameter key:              键
     - parameter objectGetHandler: 对象完成回调
     - parameter imageGetHandler:  图像完成回调
     - parameter voiceGetHandler:  音频完成回调
     */
    open func retrieve(_ key: String, objectGetHandler:((_ obj: Any?) -> Void)? = nil, imageGetHandler:((_ image: UIImage?) -> Void)? = nil, voiceGetHandler:((_ data: Data?) -> Void)?) {
        func retrieveObject(_ key: String, path: String, objectGetHandler:((_ obj: Any?) -> Void)?) {
            //反归档 获取
            DispatchQueue.global().async { () -> Void in
                if self.fileManager.fileExists(atPath: path) {
                    let mdata = NSMutableData(contentsOfFile: path)
                    let unArchiver = NSKeyedUnarchiver(forReadingWith: mdata! as Data)
                    let obj = unArchiver.decodeObject(forKey: key)
                    objectGetHandler?(obj)
                } else {
                    objectGetHandler?(nil)
                }
            }
        }

        func retrieveImage(_ path: String, imageGetHandler:((_ image: UIImage?) -> Void)?) {
            DispatchQueue.global().async { () -> Void in
                if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                    if let image = UIImage(data: data) {
                        imageGetHandler?(image)
                    }
                } else {
                    imageGetHandler?(nil)
                }
            }
        }

        func retrieveVoice(_ path: String, voiceGetHandler:((_ data: Data?) -> Void)?) {
            DispatchQueue.global().async { () -> Void in
                if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                    voiceGetHandler?(data)
                } else {
                    voiceGetHandler?(nil)
                }
            }
        }

        let path = self.cachePathForKey(key)
        switch storeType {
        case .object:
            retrieveObject(key.MD5Str, path: path, objectGetHandler: objectGetHandler)
        case .image:
            retrieveImage(path, imageGetHandler: imageGetHandler)
        case .voice:
            retrieveVoice(path, voiceGetHandler: voiceGetHandler)
        }
    }
}

extension DiskCache {
    func cachePathForKey(_ key: String) -> String {
        var fileName: String = ""
        if self.storeType == CacheFor.voice {
            fileName = cacheFileNameForKey(key)+".wav"     //对name进行MD5加密
        } else {
            fileName = cacheFileNameForKey(key)
        }

        return (diskCachePath as NSString).appendingPathComponent(fileName)
    }

    func cacheFileNameForKey(_ key: String) -> String {
        return key.MD5Str
    }
}

extension UIImage {
    func zz_normalizedImage() -> UIImage {
        if imageOrientation == .up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage!
    }
}
