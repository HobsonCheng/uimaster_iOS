//
//  Bundle+Module.swift
//  UIMaseter
//
//  Created by gongcz on 2018/4/18.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

extension Bundle {
    private static let kMaxSupportScreenScale = 3
    private static var kModuleBundleMap = [AnyHashable: Any]()

    class func b_BundlePath() -> String? {
        return Bundle.main.bundlePath
    }

    class func moduleName(_ name: String?) -> Bundle? {
        guard let moduleName = name else {
            return nil
        }
        var bundle = kModuleBundleMap[moduleName] as? Bundle
        if bundle != nil {
            return bundle!
        }
        bundle = Bundle.searchBundle(withModuleName: moduleName)
        if bundle != nil {
            kModuleBundleMap[moduleName] = bundle
        }
        return bundle!
    }

    class func searchBundle(withModuleName moduleName: String?) -> Bundle? {
        if moduleName == nil || (moduleName?.count ?? 0) <= 0 {
            return nil
        }
        var bundle: Bundle?
        if bundle == nil && moduleName?.hasSuffix(".bundle") == true {
            bundle = Bundle(path: "\(Bundle.b_BundlePath() ?? "")/\(moduleName ?? "")")
        }
        if bundle == nil && moduleName?.hasSuffix(".framework") == true {
            bundle = Bundle(path: "\(Bundle.b_BundlePath() ?? "")/\(moduleName ?? "")")
        }
        if bundle == nil {
            bundle = Bundle(path: "\(Bundle.b_BundlePath() ?? "")/\(moduleName ?? "").bundle")
        }
        if bundle == nil {
            bundle = Bundle(path: "\(Bundle.b_BundlePath() ?? "")/\(moduleName ?? "")Bundle.bundle")
        }
        if bundle == nil {
            bundle = Bundle(path: "\(Bundle.b_BundlePath() ?? "")/\(moduleName ?? "").framework")
        }
        return bundle
    }

    class func pathWihResource(_ resourceName: String?, inModule moduleName: String?) -> String? {
        if resourceName == nil || (resourceName?.count ?? 0) <= 0 {
            return nil
        }

        let bundle = Bundle.moduleName(moduleName)
        if bundle == nil {
            return nil
        }
        var path: String?
        let resourceExtension = URL(fileURLWithPath: resourceName ?? "").pathExtension
        let resourceNoExtension = URL(fileURLWithPath: resourceName ?? "").deletingPathExtension().absoluteString
        if (resourceExtension.lowercased() == "png") == true {
            let scale = Int(UIScreen.main.scale)
            path = bundle?.path(forResource: "\(resourceNoExtension)\(scale)", ofType: resourceExtension)
            if path == nil {
                var idx = kMaxSupportScreenScale
                while idx > 0 {
                    path = bundle?.path(forResource: "\(resourceNoExtension)\(Int(idx))", ofType: resourceExtension)
                    if path != nil {
                        break
                    }
                    idx -= 1
                }
            }
        }
        if path == nil {
            path = bundle?.path(forResource: resourceNoExtension, ofType: resourceExtension)
        }
        if path == nil {
            if (resourceExtension.lowercased() == "png") == true {
                path = bundle?.path(forResource: resourceNoExtension, ofType: "tiff")
            }
        }
        return path
    }
}
