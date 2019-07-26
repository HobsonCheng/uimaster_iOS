//
//  UIColor+Utility.swift
//  UIMaseter
//
//  Created by gongcz on 2018/4/17.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

func kUIColorOfHex(_ hexColor: Int?) -> UIColor {
    return UIColor(hex: hexColor!, alpha: 1)
}

extension UIColor {
    convenience init(argb ARGBValue: Int) {
        self.init(red: CGFloat((Float((ARGBValue & 0xff0000) >> 16)) / 255.0), green: CGFloat((Float((ARGBValue & 0xff00) >> 8)) / 255.0), blue: CGFloat((Float(ARGBValue & 0xff)) / 255.0), alpha: CGFloat((Float((ARGBValue & 0xff0000) >> 24)) / 255.0))
    }
    convenience init(hexString hexColor: String?) {
        self.init(hexString: hexColor, alpha: 1)
    }
    convenience init(hexString hexColor: String?, alpha: CGFloat) {
        var cString = hexColor?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        // String should be 6 or 8 characters
        if (cString?.count ?? 0) < 6 {
            self.init() //            UIColor.clear
            return
        }
        // strip 0X if it appears
        if cString?.hasPrefix("0X") ?? false {
            cString = (cString as NSString?)?.substring(from: 2)
        } else if cString?.hasPrefix("#") ?? false {
            cString = (cString as NSString?)?.substring(from: 1)
        }
        if (cString?.count ?? 0) != 6 {
            self.init() //            UIColor.clear
            return
        }
        let scanner = Scanner(string: cString!)
        scanner.scanLocation = 0

        var rgbValue: UInt64 = 0

        scanner.scanHexInt64(&rgbValue)

        let red = (rgbValue & 0xff0000) >> 16
        let green = (rgbValue & 0xff00) >> 8
        let blue = rgbValue & 0xff

        self.init(
            red: CGFloat(red) / 0xff,
            green: CGFloat(green) / 0xff,
            blue: CGFloat(blue) / 0xff, alpha: alpha
        )
    }
    //主色：ff2600
    class func mainNav() -> UIColor? {
        return UIColor(hex: 0xff2600, alpha: 1.0)
    }
    //底色：f6f6f6
    class func bottom() -> UIColor? {
        return UIColor(hex: 0xf6f6f6, alpha: 1.0)
    }
    //背景色： ffffff
    class func backGround() -> UIColor? {
        return UIColor(hex: 0xffffff, alpha: 1.0)
    }
    //部分按钮或配色: ff8401
    class func other() -> UIColor? {
        return UIColor(hex: 0xff8401, alpha: 1.0)
    }
    //字体
    //主大标题：2b2b2b
    class func mainText() -> UIColor? {
        return UIColor(hex: 0x2b2b2b, alpha: 1.0)
    }
    //标题：ff2600
    class func titleText() -> UIColor? {
        return UIColor(hex: 0xff2600, alpha: 1.0)
    }
    //有背景色字: ffffff
    class func backGroundText() -> UIColor? {
        return UIColor(hex: 0xffffff, alpha: 1.0)
    }
    //副标题 ： 5a5a5a
    class func ftitle() -> UIColor? {
        return UIColor(hex: 0x5a5a5a, alpha: 1.0)
    }
    //内容：bbbbbb
    class func context() -> UIColor? {
        return UIColor(hex: 0xbbbbbb, alpha: 1.0)
    }
    //内容2：888888
    class func contextTwo() -> UIColor? {
        return UIColor(hex: 0x888888, alpha: 1.0)
    }
    //辅色：ffc90d
    class func help() -> UIColor? {
        return UIColor(hex: 0xffc90d, alpha: 1.0)
    }
    //辅色2：329ce0
    class func helpTwo() -> UIColor? {
        return UIColor(hex: 0x329ce0, alpha: 1.0)
    }
}
