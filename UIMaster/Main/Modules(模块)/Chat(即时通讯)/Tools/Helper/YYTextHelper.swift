//
//  YYTextHelper.swift
//  UIMaster
//
//  Created by hobson on 2018/9/27.
//  Copyright © 2018 one2much. All rights reserved.
//

import Foundation
import YYText

private let ascentScale: CGFloat = 0.84
private let descentScale: CGFloat = 0.16

class TextLinePositionModifier: NSObject, YYTextLinePositionModifier {
    internal var font: UIFont // 基准字体 (例如 Heiti SC/PingFang SC)
    fileprivate var paddingTop: CGFloat = 2 //文本顶部留白
    fileprivate var paddingBottom: CGFloat = 2 //文本底部留白
    fileprivate var lineHeightMultiple: CGFloat //行距倍数

    required init(font: UIFont) {
        if (UIDevice.current.systemVersion as NSString).floatValue >= 9.0 {
            self.lineHeightMultiple = 1.23 // for PingFang SC
        } else {
            self.lineHeightMultiple = 1.192_5  // for Heiti SC
        }
        self.font = font
        super.init()
    }

    // MARK: - @delegate YYTextLinePositionModifier
    func modifyLines(_ lines: [YYTextLine], fromText text: NSAttributedString, in container: YYTextContainer) {
        let ascent: CGFloat = self.font.pointSize * ascentScale
        let lineHeight: CGFloat = self.font.pointSize * self.lineHeightMultiple
        for line: YYTextLine in lines {
            var position: CGPoint = line.position
            position.y = self.paddingTop + ascent + CGFloat(line.row) * lineHeight
            line.position = position
        }
    }

    // MARK: - @delegate NSCopying
    func copy(with zone: NSZone?) -> Any {
        let one = type(of: self).init(font: self.font)
        return one
    }

    func heightForLineCount(_ lineCount: Int) -> CGFloat {
        if lineCount == 0 {
            return 0
        }

        let ascent: CGFloat = self.font.pointSize * ascentScale
        let descent: CGFloat = self.font.pointSize * descentScale
        let lineHeight: CGFloat = self.font.pointSize * self.lineHeightMultiple
        return self.paddingTop + self.paddingBottom + ascent + descent + CGFloat((lineCount - 1)) * lineHeight
    }
}

// MARK: - parser
let kChatTextKeyPhone = "phone"
let kChatTextKeyURL = "URL"

class ChatTextParser: NSObject {
    private static var txColor: UIColor = .white
    private static var hilightColor : UIColor = UIColor(hexString: "#1F79FD")
    private static var formMe: Bool = false {
        didSet {
            txColor = formMe ? UIColor.white : UIColor(red: 15, green: 15, blue: 15)
            hilightColor = formMe ? UIColor(hexString: "#f1eb2a") : UIColor(hexString: "#1F79FD")
        }
    }
    
    class func parseText(_ text: String,font: UIFont,fromMe: Bool) -> NSMutableAttributedString? {
        if text.isEmpty {
            return nil
        }
        self.formMe = fromMe
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.yy_font = font
        attributedText.yy_color = txColor

        //匹配电话
        self.enumeratePhoneParser(attributedText)
        //匹配 URL
        self.enumerateURLParser(attributedText)
        //匹配 [表情]
        self.enumerateEmotionParser(attributedText, fontSize: font.pointSize)

        return attributedText
    }

    /**
     匹配电话
     
     - parameter attributedText: 富文本
     */
    fileprivate class func enumeratePhoneParser(_ attributedText: NSMutableAttributedString) {
        guard let phonesResults = TSChatTextParseHelper.regexPhoneNumber?.matches(
            in: attributedText.string,
            options: [.reportProgress],
            range: attributedText.yy_rangeOfAll()
            ) else {
                return
        }
        for phone: NSTextCheckingResult in phonesResults {
            if phone.range.location == NSNotFound && phone.range.length <= 1 {
                continue
            }

            let highlightBorder = TSChatTextParseHelper.highlightBorder
            if attributedText.yy_attribute(YYTextHighlightAttributeName, at: UInt(phone.range.location)) == nil {
                attributedText.yy_setColor(hilightColor, range: phone.range)
                let highlight = YYTextHighlight()
                highlight.setBackgroundBorder(highlightBorder)

                let stringRange = attributedText.string.range(from: phone.range)!
                highlight.userInfo = [kChatTextKeyPhone: attributedText.string.substring(with: stringRange)]
                attributedText.yy_setTextHighlight(highlight, range: phone.range)
            }
        }
    }

    /**
     匹配 URL
     
     - parameter attributedText: 富文本
     */
    fileprivate class func enumerateURLParser(_ attributedText: NSMutableAttributedString) {
        guard let URLsResults = TSChatTextParseHelper.regexURLs?.matches(
            in: attributedText.string,
            options: [.reportProgress],
            range: attributedText.yy_rangeOfAll()
            )else {
                return
        }
        for URL: NSTextCheckingResult in URLsResults {
            if URL.range.location == NSNotFound && URL.range.length <= 1 {
                continue
            }

            let highlightBorder = TSChatTextParseHelper.highlightBorder
            if attributedText.yy_attribute(YYTextHighlightAttributeName, at: UInt(URL.range.location)) == nil {
                attributedText.yy_setColor(hilightColor, range: URL.range)
                let highlight = YYTextHighlight()
                highlight.setBackgroundBorder(highlightBorder)

                let stringRange = attributedText.string.range(from: URL.range)!
                highlight.userInfo = [kChatTextKeyURL: attributedText.string.substring(with: stringRange)]
                attributedText.yy_setTextHighlight(highlight, range: URL.range)
            }
        }
    }

    /**
     /匹配 [表情]
     
     - parameter attributedText: 富文本
     - parameter fontSize:       字体大小
     */
    fileprivate class func enumerateEmotionParser(_ attributedText: NSMutableAttributedString, fontSize: CGFloat) {
        guard let emoticonResults = TSChatTextParseHelper.regexEmotions?.matches(
            in: attributedText.string,
            options: [.reportProgress],
            range: attributedText.yy_rangeOfAll()
            ) else {
                return
        }
        var emoClipLength: Int = 0
        for emotion: NSTextCheckingResult in emoticonResults {
            if emotion.range.location == NSNotFound && emotion.range.length <= 1 {
                continue
            }
            var range: NSRange = emotion.range
            range.location -= emoClipLength
            if attributedText.yy_attribute(YYTextHighlightAttributeName, at: UInt(range.location)) != nil {
                continue
            }
            if attributedText.yy_attribute(YYTextAttachmentAttributeName, at: UInt(range.location)) != nil {
                continue
            }

            let imageName = attributedText.string.substring(with: attributedText.string.range(from: range)!)
            guard let theImageName = emojiDictionary[imageName] else { continue }

            //QQ 表情的文件名称
            let imageString =  "Expression.bundle\(theImageName)"
            let emojiText = NSMutableAttributedString.yy_attachmentString(withEmojiImage: UIImage(named: imageString)!, fontSize: fontSize + 1)
            attributedText.replaceCharacters(in: range, with: emojiText!)

            emoClipLength += range.length - 1
        }
    }
}

class TSChatTextParseHelper {
    /// 高亮的文字背景色
    class var highlightBorder: YYTextBorder {
        let highlightBorder = YYTextBorder()
        highlightBorder.insets = UIEdgeInsets(top: -2, left: 0, bottom: -2, right: 0)
        highlightBorder.fillColor = UIColor(hexString: "#D4D1D1")
        return highlightBorder
    }

    /**
     正则：匹配 [哈哈] [笑哭。。] 表情
     */
    class var regexEmotions: NSRegularExpression? {
        do {
            let regularExpression = try NSRegularExpression(pattern: "\\[[^\\[\\]]+?\\]", options: [.caseInsensitive])
            return regularExpression
        } catch {
            dPrint(error.localizedDescription)
            return nil
        }
    }

    /**
     正则：匹配 www.a.com 或者 http://www.a.com 的类型
     
     ref: http://stackoverflow.com/questions/3809401/what-is-a-good-regular-expression-to-match-a-url
     */
    class var regexURLs: NSRegularExpression? {
        let regex: String = "((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|^[a-zA-Z0-9]+(\\.[a-zA-Z0-9]+)+([-A-Z0-9a-z_\\$\\.\\+!\\*\\(\\)/,:;@&=\\?~#%]*)*"
        do {
            let regularExpression = try NSRegularExpression(pattern: regex, options: [.caseInsensitive])
            return regularExpression
        } catch {
            dPrint(error.localizedDescription)
            return nil
        }
    }

    /**
     正则：匹配 7-25 位的数字, 010-62104321, 0373-5957800, 010-62104321-230
     */
    class var regexPhoneNumber: NSRegularExpression? {
        let regex = "^1[3,8]\\d{9}|14[5,7,9]\\d{8}|15[^4]\\d{8}|17[^2,4,9]\\d{8}$"
        do {
            let regularExpression = try NSRegularExpression(pattern: regex, options: [.caseInsensitive])
            return regularExpression
        } catch {
            dPrint(error.localizedDescription)
            return nil
        }
    }
}

private extension String {
    func nsRange(from range: Range<String.Index>) -> NSRange {
        let utf16view = self.utf16
        if let from = range.lowerBound.samePosition(in: utf16view), let to = range.upperBound.samePosition(in: utf16view) {
            return NSRange(location: utf16view.distance(from: utf16view.startIndex, to: from), length: utf16view.distance(from: from, to: to))
        } else {
            return NSRange(location: 0, length: 0)
        }
    }

    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
}
