//
//  UploadImageTool.swift
//  UIMaseter
//
//  Created by one2much on 2018/4/18.
//  Copyright © 2018年 one2much. All rights reserved.

import Alamofire
import Qiniu
import SwiftyJSON
import UIKit

class QiNiuModel: BaseModel {
    var data: QiNiuData?
}
class QiNiuData: BaseModel {
    var token: String?
    var host: String?
}
class UploadImageTool: NSObject {
    typealias UploadSuccess = (_ url: String) -> Void
    typealias UploadFailure = (_ msg: String) -> Void
    typealias AllUploadSuccess = (_ urls: [String]) -> Void
    private static var uploadConfig = QiNiuData()
    /// 上传单张图片
    ///
    /// - Parameters:
    ///   - image: 要上传的图片
    ///   - progress: 上传进度
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func uploadImage(image: UIImage, progress:@escaping QNUpProgressHandler, success: UploadSuccess?, failure: UploadFailure?) {
        if let token = uploadConfig.token, let host = uploadConfig.host {
            uploadHandler(image: image, progress: progress, success: success, failure: failure, token: token, host: host)
        } else {
            getQiniuUploadToken(success: { token, host in //获取token
                self.uploadConfig.host = host
                self.uploadConfig.token = token
                uploadHandler(image: image, progress: progress, success: success, failure: failure, token: token, host: host)
            }) { msg in
                if let safeFailure = failure {
                    safeFailure(msg)
                }
            }
        }
    }

    /// 上传操作
    ///
    /// - Parameters:
    ///   - image: 要上传的图片
    ///   - progress: 上传进度
    ///   - success: 成功回调
    ///   - failure: 失败回调
    ///   - token: 七牛云token
    ///   - host: 七牛云host
    private static func uploadHandler(image: UIImage, progress:@escaping QNUpProgressHandler, success: UploadSuccess?, failure: UploadFailure?, token: String, host: String) {
        let data = UIImageJPEGRepresentation(image, 1)
        guard let safeData = data else {
            if failure != nil {
                failure!("没有图片数据")
            }
            return
        }
        // 生成七牛管理者和选项
        let qiniuManage = QNUploadManager.sharedInstance(with: nil)
        let qiniuOptions = QNUploadOption(mime: nil, progressHandler: progress, params: nil, checkCrc: false, cancellationSignal: nil)
        //上传得到图片url
        qiniuManage?.put(safeData, key: nil, token: token, complete: { info, _, resp in
            if info?.statusCode == 200 && resp != nil {
                let url = "\(host)/\(resp!["hash"] ?? "")"
                if let safeSuccess = success {
                    safeSuccess(url)
                }
            } else {
                if let safeFailure = failure {
                    HUDUtil.stopLoadingHUD(callback: nil)
                    safeFailure("上传失败")
                }
            }
        }, option: qiniuOptions)
    }

    /// 上传文件
    ///
    /// - Parameters:
    ///   - image: 要上传的文件数据
    ///   - progress: 上传进度
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func uploadFile(filePath: String?, progress:@escaping QNUpProgressHandler, success: UploadSuccess?, failure: UploadFailure?) {
        getQiniuUploadToken(bucketType: "3", success: { token, host in //获取token
            guard var path = filePath else {
                if failure != nil {
                    failure!("没有找到")
                }
                return
            }
            path = path.replacingOccurrences(of: "file://", with: "")
            // 生成七牛管理者和选项
            let qiniuManage = QNUploadManager.sharedInstance(with: nil)
            let qiniuOptions = QNUploadOption(mime: nil, progressHandler: progress, params: nil, checkCrc: false, cancellationSignal: nil)
            //上传得到图片url
            qiniuManage?.putFile(path.removingPercentEncoding, key: nil, token: token, complete: { info, _, resp in
                if info?.statusCode == 200 && resp != nil {
                    let url = "\(host)/\(resp!["hash"] ?? "")"
                    if let safeSuccess = success {
                        safeSuccess(url)
                    }
                } else {
                    if let safeFailure = failure {
                        HUDUtil.stopLoadingHUD(callback: nil)
                        safeFailure("上传失败")
                    }
                }
            }, option: qiniuOptions)
        }) { msg in
            if let safeFailure = failure {
                safeFailure(msg)
            }
        }
    }
    //FIXME: 多图上传有问题，需要修复
    /// 传多张图片,按队列依次上传
    ///
    /// - Parameters:
    ///   - imageArray: 要上传的图片数组
    ///   - progress: 上传进度
    ///   - success: 成功回调
    ///   - failure: 失败回调
    static func uploadImages(imageArray: [UIImage], progress:@escaping QNUpProgressHandler, success:@escaping AllUploadSuccess, failure:@escaping UploadFailure) {
        var urlArr = [String]() //上传的图片后，得到的url数组
        var totalProgress: Float = 0.0 // 总进度
        let partProgress = 1.0 / Float(imageArray.count) //每部分进度
        var index = 0 // 第几张图片
        let uploadHelper = QiniuUploadHelper.shared
        uploadHelper.successCB = { url in
            urlArr.append(url)
            totalProgress += partProgress
            progress("\(index)", Float(totalProgress))
            index += 1
            if urlArr.count == imageArray.count {
                success(urlArr)
            } else {
                if index < imageArray.count {
                    uploadImage(image: imageArray[index], progress: { _, pro in
                        progress("\(index)", Float(totalProgress + pro * partProgress))
                    }, success: uploadHelper.successCB, failure: uploadHelper.failCB)
                }
            }
        }
        uploadHelper.failCB = { msg in
            HUDUtil.stopLoadingHUD(callback: nil)
            failure(msg)
        }
        //上传图片
        uploadImage(image: imageArray[0], progress: { msg, pro in
            progress("0", pro * partProgress)
        }, success: { url in
            uploadHelper.successCB!(url)
        }, failure: { msg in
            uploadHelper.failCB?(msg)
        })
    }
    // MARK: - 私有函数

    /// 获取七牛Token
    ///
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    fileprivate static func getQiniuUploadToken(bucketType: String = "1", success: ((_ token: String, _ host: String) -> Void)?, failure: UploadFailure?) {
        NetworkUtil.request(target: .getImgUploadtoken(bucket_type: bucketType), success: { json in
            let model = QiNiuModel.deserialize(from: json)?.data
            if let token = model?.token, let host = model?.host {
                success?(token, host)
            } else {
                HUDUtil.msg(msg: "获取失败", type: .error)
                if let safeFailure = failure {
                    safeFailure("上传失败")
                }
            }
        }) { error in
            HUDUtil.msg(msg: "获取失败", type: .error)
            dPrint(error)
        }
    }
    //获取当前时间的字符串
    fileprivate static func getDateTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dataStr = formatter.string(from: Date())
        return dataStr
    }
    //获取指定长度的随机字符串
    fileprivate static func randomStringWithLength(len: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var newStr = ""
        for _ in 0...len {
            let position = Int(arc4random_uniform(UInt32(letters.count)))
            let index = letters.index(letters.startIndex, offsetBy: position)
            let charactor = letters[index]
            newStr.append(charactor)
        }
        return newStr
    }
}

typealias Success = (_ : String) -> Void
typealias Failure = (_ : String) -> Void

/// 该类主要用于上传多张图片时，递归调用 成功和失败的回调
private class QiniuUploadHelper {
    var successCB: Success?
    var failCB: Failure?

    private static let singleton = QiniuUploadHelper()

    private init() {}

    static var shared: QiniuUploadHelper {
        return singleton
    }
}
