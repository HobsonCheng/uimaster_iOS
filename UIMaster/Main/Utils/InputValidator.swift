//
//  InputValidator.swift
//  UIDS
//
//  Created by one2much on 2018/1/17.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

//验证规则总入口

class InputValidator: NSObject {
    class func isCheckUsername(username: String) -> Bool {
        if username.isEmpty {
            return false
        }
        var ischeck = true
        let regustList = AllRestrictionHandler.shared.ucSetConfig?.regist_qualified
        if (regustList != nil) && (Int((regustList?.count)!)) > 0 {
            for itemObj in regustList! where itemObj.status == 0 {
                //限定位置（0邮箱后缀，1开头内容，2包含内容，3结尾内容）
                    let qualifiedPlace = itemObj.qualified_place
                    let contenlist = itemObj.qualified_content?.components(separatedBy: ",") ?? [String]()
                    for contentItem in contenlist {
                        if qualifiedPlace == 1 {
                            //^
                            let pattern = "^\(contentItem)"
                            if isRegexMatch(with: pattern, in: username) {
                                return true
                            }
                        } else if qualifiedPlace == 2 || qualifiedPlace == 0 {
                            //包含
                            let pattern = "\(contentItem)"
                            if isRegexMatch(with: pattern, in: username) {
                                return true
                            }
                        } else if qualifiedPlace == 3 {
                            //$
                            let pattern = "\(contentItem)$"
                            if isRegexMatch(with: pattern, in: username) {
                                return true
                            }
                        }
                    }
            }

            ischeck = false
        }

        return ischeck
    }

    class func isValidPhone(phoneNum: String) -> Bool {
        if phoneNum.isEmpty {
            return false
        }
        if self.isCheckUsername(username: phoneNum) {
            let re = try? NSRegularExpression(pattern: "^[1][3,4,5,6,7,8][0-9]{9}$", options: .caseInsensitive)
            if let re = re {
                let range = NSRange(location: 0, length: phoneNum.count)
                let result = re.matches(in: phoneNum, options: .reportProgress, range: range)
                return !result.isEmpty
            }
        }

        return false
    }

    class func isValidEmail(email: String) -> Bool {
        if email.isEmpty {
            return false
        }
        if self.isCheckUsername(username: email) {
            let re = try? NSRegularExpression(pattern: "^\\S+@\\S+\\.\\S+$", options: .caseInsensitive)

            if let re = re {
                let range = NSRange(location: 0, length: email.count)
                let result = re.matches(in: email, options: .reportProgress, range: range)
                return !result.isEmpty
            }
        }

        return false
    }

    class func isvalidationPassword(password: String) -> Bool {
        if password.isEmpty {
            return false
        }
        //检测密码
        let pwdType = AllRestrictionHandler.shared.ucSetConfig?.project_set?.pwd_condition
        if pwdType?.isEmpty ?? true {
            return false
        }
        let pwdTypeBeytes = strToByte(str: pwdType!)

        let pwdCombination = AllRestrictionHandler.shared.ucSetConfig?.project_set?.pwd_combination ?? 0

        let capital = checkHaveCapital(str: password)//包含大写字母
        let minuscule = checkHaveMinuscule(str: password)//包含小写字母
        let number = checkHaveNumber(str: password)//包含数字
        let symbol = checkHaveSymbol(str: password)//包含特殊符号

        let pwdLength = AllRestrictionHandler.shared.ucSetConfig?.project_set?.pwd_min_bit ?? 0

        var pwdOK = 0
        var allPwdOK = 0

        if pwdTypeBeytes[0] == "1" {//大写字母
            if capital {
                pwdOK += 1
            }
        }
        if pwdTypeBeytes[1] == "1" {//小写字母
            if minuscule {
                pwdOK += 1
            }
        }
        if pwdTypeBeytes[2] == "1" {//数字
            if number {
                pwdOK += 1
            }
        }
        if pwdTypeBeytes[3] == "1" {//特殊符号
            if symbol {
                pwdOK += 1
            }
        }

        if capital {
           allPwdOK += 1
        }
        if minuscule {
            allPwdOK += 1
        }
        if number {
            allPwdOK += 1
        }
        if symbol {
            allPwdOK += 1
        }
        if allPwdOK >= pwdCombination {
            if pwdCombination <= pwdOK {
                if Int(password.count) >= pwdLength {
                    return true
                }
            }
        }
        return false
    }
    /// 正则校验
    ///
    /// - Parameters:
    ///   - pattern: 正则pattern
    ///   - input: 待校验的输入
    /// - Returns: 文字中是否包含pattern
    static func isRegexMatch(with pattern: String, in input: String) -> Bool {
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        if let matches = regex?.matches(in: input, options: [], range: NSRange(location: 0, length: input.count)) {
            return !matches.isEmpty
        } else {
            return false
        }
    }
    /**
     正则表达式获取目的值
     - parameter pattern: 一个字符串类型的正则表达式
     - parameter str: 需要比较判断的对象
     - imports: 这里子串的获取先转话为NSString的[以后处理结果含NS的还是可以转换为NS前缀的方便]
     - returns: 返回目的字符串结果值数组(目前将String转换为NSString获得子串方法较为容易)
     - warning: 注意匹配到结果的话就会返回true，没有匹配到结果就会返回false
     */
    static func regexGetSub(pattern: String, str: String) -> [String] {
        var subStr = [String]()
        let regex = try? NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        let results = regex?.matches(in: str, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: str.count))

        //解析出子串
        for  rst in results! {
            let nsStr = str as  NSString  //可以方便通过range获取子串
            subStr.append(nsStr.substring(with: rst.range))
            //str.substring(with: Range<String.Index>) //本应该用这个的，可以无法直接获得参数，必须自己手动获取starIndex 和 endIndex作为区间
        }
        return subStr
    }
    static func strToByte(str: String) -> [Character] {
        var bytes: [Character] = [Character]()
        for ch in str {
            bytes.append(ch)
        }
        return bytes
    }

    // MARK: - 检测是否包含数字
    static func checkHaveNumber(str: String) -> Bool {
        let pattern = "[0-9]+"
        if isRegexMatch(with: pattern, in: str) {
            return true
        } else {
            return false
        }
    }
    // MARK: - 检测大写字母 包含
    static func checkHaveCapital(str: String) -> Bool {
        let pattern = "[A-Z]+"
        if isRegexMatch(with: pattern, in: str) {
            return true
        } else {
            return false
        }
    }
    // MARK: - 检测包含小写字母
    static func checkHaveMinuscule(str: String) -> Bool {
        let pattern = "[a-z]+"
        if isRegexMatch(with: pattern, in: str) {
            return true
        } else {
            return false
        }
    }
    // MARK: - 检测是否包含特殊符号
    static func checkHaveSymbol(str: String) -> Bool {
        let pattern = "[`~!@#$^&*()=|{}':;',\\[\\].<>/?~！@#￥……&*（）——|{}【】‘；：”“'。，、？]+"
        if isRegexMatch(with: pattern, in: str) {
            return true
        } else {
            return false
        }
    }
}
