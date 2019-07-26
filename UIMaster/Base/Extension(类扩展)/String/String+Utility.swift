//
//  NSString+Utility.swift
//  UIMaseter
//
//  Created by gongcz on 2018/4/17.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

infix operator ??? : AdditionPrecedence
extension String {
    /// String 转 class
    var getClass: AnyClass? {
        return NSClassFromString(self)
    }

    // MARK: Valid
    func isRangeValid(from index: Int, withSize rangeSize: Int) -> Bool {
        let stringLength: Int = self.count
        if (stringLength - index) < rangeSize {
            return false
        } else {
            return true
        }
    }
    // 截取字符串
    func subStr(from: Int, length: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(startIndex, offsetBy: length)
        return String(self[startIndex..<endIndex])
    }
    // MARK: - - get Random String
    func getRandomString(byLength len: Int) -> String? {
        if len <= 0 {
            return nil
        }
        var data = [UInt8](repeating: 0, count: len)
        var xLength = 0
        while xLength < len {
            let idx = Int(arc4random_uniform(3))
            if idx % 3 == 0 {
                data[xLength] = UInt8("A".utf8CString.first! + Int8(arc4random_uniform(26)))
                xLength += 1
            } else if idx % 3 == 1 {
                data[xLength] = UInt8("a".utf8CString.first! + Int8(arc4random_uniform(26)))
                xLength += 1
            } else {
                data[xLength] = UInt8("0".utf8CString.first! + Int8(arc4random_uniform(10)))
                xLength += 1
            }
        }
        return String(bytes: data, encoding: .utf8)
    }

    // 字符串哈希值
    static func hashString(_ data: String?, withSalt salt: String?) -> String? {
        if !((data?.count ?? 0) > 0) || !((salt?.count ?? 0) > 0) {
            return nil
        }
        let cKey = salt!.cString(using: .utf8)
        let cData = data!.cString(using: .utf8)
        var cHMAC = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        // 用的OC的库CommonCrypto
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), cKey, strlen(cKey ?? []), cData, strlen(cData ?? []), &cHMAC)
        var hash: String
        var output = "" /* TODO: .reserveCapacity(CC_SHA256_DIGEST_LENGTH * 2) */
        for idx in 0..<CC_SHA256_DIGEST_LENGTH {
//            if let char: UInt8 = cHMAC[Int(i)] {
                output += String(format: "%02x", cHMAC[Int(idx)])
//            }
        }
        hash = output
        return hash
    }

    // MARK: Trim Space
    func trimSpaceString() -> String {
        return trimmingCharacters(in: CharacterSet.whitespaces)
    }

    // 十六进制转换为普通字符串的
    func string(fromHexString hexString: String?) -> String? {
        let myBuffer = malloc((hexString?.count ?? 0) / 2 + 1) as UnsafeMutableRawPointer
        let bytes = myBuffer.bindMemory(to: CChar.self, capacity: (hexString?.count)!-1)
        bzero(myBuffer, (hexString?.count ?? 0) / 2 + 1)
        var idx = 0
        while idx < (hexString?.count ?? 0) - 1 {
//            var anInt: UnsafeMutablePointer<UInt32>?
            var anInt: UInt32 = 0
            let hexCharStr = (hexString as NSString?)?.substring(with: NSRange(location: idx, length: 2))
            let scanner = Scanner(string: hexCharStr ?? "")
            scanner.scanHexInt32(&anInt)
//            let bufferData = Unmanaged<AnyObject>.fromOpaque(myBuffer).takeRetainedValue()
            bytes[idx / 2] = CChar(anInt)
            idx += 2
        }
        let utf8String = String(cString: bytes, encoding: .utf8)
        free(myBuffer)
        return utf8String
    }

    func base64StringToUIImage() -> UIImage? {
        var imageStr = self
        // 1、判断用户传过来的base64的字符串是否是以data开口的，如果是以data开头的，那么就获取字符串中的base代码，然后在转换，如果不是以data开头的，那么就直接转换
        if self.hasPrefix("data:image") {
            guard let newBase64String = self.components(separatedBy: ",").last else {
                return nil
            }
            imageStr = newBase64String
        }
        // 2、将处理好的base64String代码转换成NSData
        guard let imgData = Data(base64Encoded: imageStr, options: Data.Base64DecodingOptions(rawValue: 0)) else {
            return nil
        }
        // 3、将NSData的图片，转换成UIImage
        guard let codeImage = UIImage(data: imgData) else {
            return nil
        }
        return codeImage
    }

    //普通字符串转换为十六进制的
    func hexString(from string: String?) -> String? {
        var myD: Data? = string?.data(using: .utf8)
//        var bytes = myD?.bytes as? Byte
        let bytes = myD?.withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start: $0, count: myD?.count ?? 0))
        }
        //下面是Byte 转换为16进制。
        var hexStr = ""
        for idx in 0..<(myD?.count ?? 0) {
            ///16进制数
            let newHexStr = String(format: "%X", UInt8(bytes![idx]) & 0xff)
            if newHexStr.count == 1 {
                hexStr += "0\(newHexStr)"
            } else {
                hexStr += "\(newHexStr)"
            }
        }
        return hexStr
    }

    /**
     *  @brief  反转字符串
     *
     *  @param strSrc 被反转字符串
     *
     *  @return 反转后字符串
     */
    static func reverse(_ strSrc: String?) -> String? {
        var reverseString = String()
        var charIndex: Int = strSrc?.count ?? 0
        while charIndex > 0 {
            charIndex -= 1
            let subStrRange = NSRange(location: charIndex, length: 1)
            reverseString += (strSrc as NSString?)?.substring(with: subStrRange) ?? ""
        }
        return reverseString
    }

    /// 将格式为"255,255,255,0.5" 字符串转换成颜色
    ///
    /// - Parameter color: 格式为"255,255,255,0.5"的rgba字符串
    /// - Returns: 转换得到的颜色
    func toColor() -> UIColor? {
        let arr = self.split(separator: ",")
        if arr.count < 4 {
            return nil
        }
        var arrNew: [CGFloat] = []
        for item in arr {
            let value = Double(String(item))
            arrNew.append(CGFloat(value ?? 0))
        }
        return UIColor(red: arrNew[0]/255, green: arrNew[1]/255, blue: arrNew[2]/255, alpha: arrNew[3])
    }

    /// 校验是否为nil 或者为 “”，当为上述情况时，返回默认值
    ///
    /// - Parameters:
    ///   - left: 要校验的字符串
    ///   - right: 默认值
    /// - Returns: 不为nil或""的值
    static func ???(left: String?, right: String) -> String {
        if let safeLeft = left, left != "" {
            return safeLeft
        } else {
            return right
        }
    }
}

// MARK: 时间处理
extension String {
    func getTimeTip(formateStr: String = "YYYY-MM-dd HH:mm:ss") -> String {
        //字符串转Date
        let formatter = DateFormatter()
        formatter.dateFormat = formateStr
        let date = formatter.date(from: self) ?? Date()
        //分解日期
        let calendarComponents = Calendar.current.dateComponents([.year, .month, .hour, .day, .hour, .minute], from: date)
        let year = calendarComponents.year ?? 0
        let month = calendarComponents.month ?? 0
        let day = calendarComponents.day ?? 0
        let hour = calendarComponents.hour ?? 0
        let minute = calendarComponents.minute ?? 0
        //时间间隔
        let curentYear = Calendar.current.dateComponents([.year], from: Date()).year ?? 0
        let minuteGap = Calendar.current.dateComponents([.minute], from: date, to: Date()).minute ?? 0
        let hourGap = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour ?? 0
        //返回时间信息
        if Calendar.current.isDateInToday(date) {
            if  minuteGap <= 1 {
                return "1分钟前"
            } else if hourGap < 1 {
                return "\(minuteGap)分钟前"
            } else {
                return "\(hourGap)小时前"
            }
        } else if Calendar.current.isDateInYesterday(date) {
            return String(format: "昨天 %02d:%02d", arguments: [hour, minute])
        } else if year == curentYear {
            return String(format: "%02d-%02d %02d:%02d", arguments: [month, day, hour, minute])
        } else {
            return "\(year)-\(month)-\(day) \(hour):\(minute)"
        }
    }
}
