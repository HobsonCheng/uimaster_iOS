//
//  NetworkUtil.swift
//  UIMaster
//
//  Created by hobson on 2018/6/27.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Moya
import SwiftyJSON
import UIKit

class NetworkUtil {
    // 请求成功的回调
    typealias SuccessCallback = (_ jsonStr: String?) -> Void
    // 请求失败的回调
    typealias FailureCallback = (_ error: String) -> Void

    // 单例
    static let provider = MoyaProvider<NetworkService>()

    // 发送网络请求
    static func request(
        target: NetworkService,
        success: SuccessCallback?,
        failure: FailureCallback?
        ) {
        provider.request(target) { result in
            switch result {
            case let .success(moyaResponse):
                let request = moyaResponse.request?.description ?? ""
                let params = String(data: (moyaResponse.request?.httpBody)!, encoding: String.Encoding.utf8) ?? ""
                switch target {
                case .findGlobal, .findPageList:
                    dPrint(request+"?"+params)
                default:
                    dPrint(request+"?"+params)
                }
                let jsonStr = JSON(moyaResponse.data)
                let code = jsonStr.dictionaryValue["code"]?.stringValue
                let msg = jsonStr.dictionaryValue["msg"]?.stringValue ?? ""
                if code == "0203"{
                    UserUtil.share.removerUser()
                    PageRouter.shared.router(to: .login)
                    if params.contains("codeUse") && params.contains("invitation") {
                        HUDUtil.msg(msg: "请先登录，然后再点链接进群", type: .info)
                    }
                    failure?("")
                    return
                } else if code == "8203"{
                    HUDUtil.msg(msg: "请在”找回密码“中，设置登录密码", type: .info)
                    failure?(msg)
                    return
                } else if code != "0" &&  code != ""{
                    HUDUtil.msg(msg: msg, type: .error)
                    failure?(msg)
                    return
                }
                dPrint(jsonStr)
                if let safeCB = success {
                    safeCB(jsonStr.description)
                }
            case let .failure(error):
                if let safeCB = failure {
                    safeCB(error.failureReason ?? "")
                }
            }
        }
    }
}

extension Task {
    public var parameters: String {
        switch self {
        case .requestParameters(let parameters, _):
            return "\(parameters)"
        case .requestCompositeData(_, let urlParameters):
            return "\(urlParameters)"
        case let .requestCompositeParameters(bodyParameters, _, urlParameters):
            return "\(bodyParameters)\(urlParameters)"
        default:
            return ""
        }
    }
}
