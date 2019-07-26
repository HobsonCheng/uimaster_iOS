//
//  NSString+URL.swift
//  UIMaseter
//
//  Created by gongcz on 2018/4/18.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Foundation

extension String {
    // MARK: URLEncoding
    func urlEncodedString() -> String? {
        let result = addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return result
    }
    func urlDecodedString() -> String? {
        let result = removingPercentEncoding
        return result
    }
    // MARK: XQueryComponents
    func stringByDecodingURLFormat() -> String? {
        var result = replacingOccurrences(of: "+", with: " ")
        result = result.removingPercentEncoding ?? ""
        return result
    }
    func stringByEncodingURLFormat() -> String? {
        var result = replacingOccurrences(of: " ", with: "+")
        result = (result as NSString).removingPercentEncoding ?? ""
        return result
    }
    func dictionaryFromQueryComponents() -> [AnyHashable: Any]? {
        var queryComponents = [AnyHashable: Any]()
        for keyValuePairString: String in components(separatedBy: "&") {
            let keyValuePairArray = keyValuePairString.components(separatedBy: "=")
            if keyValuePairArray.count < 2 {
                continue
            }
            // Verify that there is at least one key, and at least one value.  Ignore extra = signs
            var key = keyValuePairArray[0].stringByDecodingURLFormat()
            if key == nil {
                key = keyValuePairArray[0]
            }
            var value = keyValuePairArray[1].stringByDecodingURLFormat()
            if value == nil {
                value = keyValuePairArray[1]
            }
            let results = queryComponents[key!] as? [AnyHashable]
            // URL spec says that multiple values are allowed per key
            if results == nil {
                queryComponents[key!] = value
            }
        }
        return queryComponents
    }
}
