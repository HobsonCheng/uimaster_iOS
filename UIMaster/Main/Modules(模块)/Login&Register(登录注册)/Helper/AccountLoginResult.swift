//
//  AccountLoginResult.swift
//  RxXMLY
//
//  Created by sessionCh on 2018/1/3.
//  Copyright © 2018年 sessionCh. All rights reserved.
//

import RxCocoa
import RxSwift
import SwiftyJSON
import UIKit

enum AccountLoginResult {
    case success(message:String)
    case empty
    case failed(message:String)
    case params(paramsObj: NSMutableDictionary)
}

extension AccountLoginResult {
    var paramsObj: NSMutableDictionary {
        switch self {
        case let .params(paramsObj):
            return paramsObj
        default:
            return NSMutableDictionary()
        }
    }
}

extension AccountLoginResult {
    var description: String {
        switch self {
        case let .success(message):
            return message
        case .empty:
            return ""
        case let .failed(message):
            return message
        case .params:
            return ""
        }
    }
}

extension AccountLoginResult {
    var borderColor: CGColor {
        switch self {
        case .success:
            return kThemeGainsboroColor.cgColor
        case .empty:
            return kThemeOrangeRedColor.cgColor
        case .failed:
            return kThemeOrangeRedColor.cgColor
        case .params:
            return kThemeGainsboroColor.cgColor
        }
    }
}

extension Reactive where Base: UITextField {
    var validationResult: Binder<AccountLoginResult> {
        return Binder(self.base) { field, result in
            field.layer.borderColor = result.borderColor
        }
    }
}
