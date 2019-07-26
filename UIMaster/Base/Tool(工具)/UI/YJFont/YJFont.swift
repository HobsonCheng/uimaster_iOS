//
//  YJFont.swift
//  YJ
//
//  Created by Hobson on 2018/3/13.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    func setRightViewYJIcon(icon: YJType, rightViewMode: UITextFieldViewMode = .always, orientation: UIImageOrientation = UIImageOrientation.down, textColor: UIColor = .black, backgroundColor: UIColor = .clear, size: CGSize? = nil) {
        FontLoader.loadFontIfNeeded()

        let image = UIImage(icon: icon, size: size ?? CGSize(width: 30, height: 30), orientation: orientation, textColor: textColor, backgroundColor: backgroundColor)
        let imageView = UIImageView(image: image)

        self.rightView = imageView
        self.rightViewMode = rightViewMode
    }

    func setLeftViewYJIcon(icon: YJType, leftViewMode: UITextFieldViewMode = .always, orientation: UIImageOrientation = UIImageOrientation.down, textColor: UIColor = .black, backgroundColor: UIColor = .clear, size: CGSize? = nil) {
        FontLoader.loadFontIfNeeded()
        let image = UIImage(icon: icon, size: size ?? CGSize(width: 30, height: 30), orientation: orientation, textColor: textColor, backgroundColor: backgroundColor)
        let imageView = UIImageView(image: image)
        self.leftView = imageView
        self.leftViewMode = leftViewMode
    }
}

extension UIBarButtonItem {
    /**
     To set an icon, use i.e. `barName.YJIcon = YJType.YJGithub`
     */
    func setYJIcon(icon: YJType, iconSize: CGFloat) {
        FontLoader.loadFontIfNeeded()
        let font = UIFont(name: YJStruct.FontName, size: iconSize)
        assert(font != nil, YJStruct.ErrorAnnounce)
        setTitleTextAttributes([NSAttributedStringKey.font: font!], for: .normal)
        setTitleTextAttributes([NSAttributedStringKey.font: font!], for: .selected)
        setTitleTextAttributes([NSAttributedStringKey.font: font!], for: .highlighted)
        setTitleTextAttributes([NSAttributedStringKey.font: font!], for: .disabled)
        title = icon.text
    }

    /**
     To set an icon, use i.e. `barName.setYJIcon(YJType.YJGithub, iconSize: 35)`
     */
    var YJIcon: YJType? {
        set {
            FontLoader.loadFontIfNeeded()
            let font = UIFont(name: YJStruct.FontName, size: 23)
            assert(font != nil, YJStruct.ErrorAnnounce)
            setTitleTextAttributes([NSAttributedStringKey.font: font!], for: .normal)
            setTitleTextAttributes([NSAttributedStringKey.font: font!], for: .selected)
            setTitleTextAttributes([NSAttributedStringKey.font: font!], for: .highlighted)
            setTitleTextAttributes([NSAttributedStringKey.font: font!], for: .disabled)
            title = newValue?.text
        }
        get {
            guard let title = title, let index = kYJIcons.index(of: title) else {
                return nil
            }
            return YJType(rawValue: index)
        }
    }

    func setYJText(prefixText: String, icon: YJType?, postfixText: String, size: CGFloat) {
        FontLoader.loadFontIfNeeded()
        let font = UIFont(name: YJStruct.FontName, size: size)
        assert(font != nil, YJStruct.ErrorAnnounce)
        setTitleTextAttributes([NSAttributedStringKey.font: font!], for: .normal)
        setTitleTextAttributes([NSAttributedStringKey.font: font!], for: .selected)
        setTitleTextAttributes([NSAttributedStringKey.font: font!], for: .highlighted)
        setTitleTextAttributes([NSAttributedStringKey.font: font!], for: .disabled)

        var text = prefixText
        if let iconText = icon?.text {
            text += iconText
        }
        text += postfixText
        title = text
    }
}

extension UIButton {
    /**
     To set an icon, use i.e. `buttonName.setYJIcon(YJType.YJGithub, forState: .Normal)`
     */
    func setYJIcon(icon: YJType, forState state: UIControlState) {
        FontLoader.loadFontIfNeeded()
        guard let titleLabel = titleLabel else {
            return
        }
        setAttributedTitle(nil, for: state)
        let font = UIFont(name: YJStruct.FontName, size: titleLabel.font.pointSize)
        assert(font != nil, YJStruct.ErrorAnnounce)
        titleLabel.font = font!
        setTitle(icon.text, for: state)
    }

    func setYJIconWithCode(iconCode: String, forState state: UIControlState) {
        FontLoader.loadFontIfNeeded()
        guard let titleLabel = titleLabel, !iconCode.isEmpty else {
            return
        }
        setAttributedTitle(nil, for: state)
        let font = UIFont(name: YJStruct.FontName, size: titleLabel.font.pointSize)
        assert(font != nil, YJStruct.ErrorAnnounce)
        titleLabel.font = font!
        let index = iconCode.index(iconCode.startIndex, offsetBy: 2)
        let endIndex = iconCode.index(of: ";") ?? iconCode.endIndex
        let subString = iconCode[index..<endIndex]
        let str = String(subString)
        guard let num = Int(str, radix: 16) else {
            return
        }
        if let scalar = UnicodeScalar(num) {
            let value = String(scalar)
            setTitle(value, for: state)
        }
    }
    /**
     To set an icon, use i.e. `buttonName.setYJIcon(YJType.YJGithub, iconSize: 35, forState: .Normal)`
     */
    func setYJIcon(icon: YJType, iconSize: CGFloat, forState state: UIControlState) {
        setYJIcon(icon: icon, forState: state)
        guard let fontName = titleLabel?.font.fontName else {
            return
        }
        titleLabel?.font = UIFont(name: fontName, size: iconSize)
    }
    func setYJIcon(iconCode: String, iconSize: CGFloat, forState state: UIControlState) {
        setYJIconWithCode(iconCode: iconCode, forState: state)
        guard let fontName = titleLabel?.font.fontName else {
            return
        }
        titleLabel?.font = UIFont(name: fontName, size: iconSize)
    }
    func setYJText(prefixText: String, icon: YJType?, postfixText: String, size: CGFloat?, forState state: UIControlState, iconSize: CGFloat? = nil) {
        setTitle(nil, for: state)
        FontLoader.loadFontIfNeeded()
        guard let titleLabel = titleLabel else {
            return
        }
        let attributedText = attributedTitle(for: .normal) ?? NSAttributedString()
        let startFont = attributedText.length == 0 ? nil : attributedText.attribute(NSAttributedStringKey.font, at: 0, effectiveRange: nil) as? UIFont
        let endFont = attributedText.length == 0 ? nil : attributedText.attribute(NSAttributedStringKey.font, at: attributedText.length - 1, effectiveRange: nil) as? UIFont
        var textFont = titleLabel.font
        if let font = startFont, font.fontName != YJStruct.FontName {
            textFont = font
        } else if let font = endFont, font.fontName != YJStruct.FontName {
            textFont = font
        }
        if let fontSize = size {
            textFont = textFont?.withSize(fontSize)
        }
        var textColor: UIColor = .black
        attributedText.enumerateAttribute(NSAttributedStringKey.foregroundColor, in: NSRange(location: 0, length: attributedText.length), options: .longestEffectiveRangeNotRequired) { value, _, _ in
            if value != nil {
                textColor = value as? UIColor ?? .black
            }
        }

        let textAttributes = [NSAttributedStringKey.font: textFont!, NSAttributedStringKey.foregroundColor: textColor] as [NSAttributedStringKey: Any]
        let prefixTextAttribured = NSMutableAttributedString(string: prefixText, attributes: textAttributes)

        if let iconText = icon?.text {
            let iconFont = UIFont(name: YJStruct.FontName, size: iconSize ?? size ?? titleLabel.font.pointSize)!
            let iconAttributes = [NSAttributedStringKey.font: iconFont, NSAttributedStringKey.foregroundColor: textColor] as [NSAttributedStringKey: Any]

            let iconString = NSAttributedString(string: iconText, attributes: iconAttributes)
            prefixTextAttribured.append(iconString)
        }
        let postfixTextAttributed = NSAttributedString(string: postfixText, attributes: textAttributes)
        prefixTextAttribured.append(postfixTextAttributed)

        setAttributedTitle(prefixTextAttribured, for: state)
    }

    func setYJTitleColor(color: UIColor, forState state: UIControlState = .normal) {
        FontLoader.loadFontIfNeeded()

        let attributedString = NSMutableAttributedString(attributedString: attributedTitle(for: state) ?? NSAttributedString())
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: NSRange(location: 0, length: attributedString.length))

        setAttributedTitle(attributedString, for: state)
        setTitleColor(color, for: state)
    }
}

extension UILabel {
    /**
     To set an icon, use i.e. `labelName.YJIcon = YJType.YJGithub`
     */
    var YJIcon: YJType? {
        set {
            guard let newValue = newValue else {
                return
            }
            FontLoader.loadFontIfNeeded()
            let fontAwesome = UIFont(name: YJStruct.FontName, size: self.font.pointSize)
            assert(font != nil, YJStruct.ErrorAnnounce)
            font = fontAwesome!
            text = newValue.text
        }
        get {
            guard let text = text, let index = kYJIcons.index(of: text) else {
                return nil
            }
            return YJType(rawValue: index)
        }
    }

    /**
     To set an icon, use i.e. `labelName.setYJIcon(YJType.YJGithub, iconSize: 35)`
     */
    func setYJIcon(icon: YJType, iconSize: CGFloat) {
        YJIcon = icon
        font = UIFont(name: font.fontName, size: iconSize)
    }

    func setYJColor(color: UIColor) {
        FontLoader.loadFontIfNeeded()
        let attributedString = NSMutableAttributedString(attributedString: attributedText ?? NSAttributedString())
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: NSRange(location: 0, length: attributedText!.length))
        textColor = color
    }

    func setYJText(prefixText: String, icon: YJType?, postfixText: String, size: CGFloat?, iconSize: CGFloat? = nil) {
        text = nil
        FontLoader.loadFontIfNeeded()

        let attrText = attributedText ?? NSAttributedString()
        let startFont = attrText.length == 0 ? nil : attrText.attribute(NSAttributedStringKey.font, at: 0, effectiveRange: nil) as? UIFont
        let endFont = attrText.length == 0 ? nil : attrText.attribute(NSAttributedStringKey.font, at: attrText.length - 1, effectiveRange: nil) as? UIFont
        var textFont = font
        if let font = startFont, font.fontName != YJStruct.FontName {
            textFont = font
        } else if let font = endFont, font.fontName != YJStruct.FontName {
            textFont = font
        }
        let textAttribute = [NSAttributedStringKey.font: textFont!]
        let prefixTextAttribured = NSMutableAttributedString(string: prefixText, attributes: textAttribute)

        if let iconText = icon?.text {
            let iconFont = UIFont(name: YJStruct.FontName, size: iconSize ?? size ?? font.pointSize)!
            let iconAttribute = [NSAttributedStringKey.font: iconFont]

            let iconString = NSAttributedString(string: iconText, attributes: iconAttribute)
            prefixTextAttribured.append(iconString)
        }
        let postfixTextAttributed = NSAttributedString(string: postfixText, attributes: textAttribute)
        prefixTextAttribured.append(postfixTextAttributed)

        attributedText = prefixTextAttribured
    }
}

// Original idea from https://github.com/thii/FontAwesome.swift/blob/master/FontAwesome/FontAwesome.swift
extension UIImageView {
    /**
     Create UIImage from YJType
     */
    func setYJIconWithName(icon: YJType, textColor: UIColor, orientation: UIImageOrientation = UIImageOrientation.down, backgroundColor: UIColor = UIColor.clear, size: CGSize? = nil) {
        FontLoader.loadFontIfNeeded()
        self.image = UIImage(icon: icon, size: size ?? frame.size, orientation: orientation, textColor: textColor, backgroundColor: backgroundColor)
    }
    /**
     Create UIImage from iconCode
     */
    func setYJIconWithCode(iconCode: String, textColor: UIColor, orientation: UIImageOrientation = UIImageOrientation.down, backgroundColor: UIColor = UIColor.clear, size: CGSize? = nil) {
        FontLoader.loadFontIfNeeded()
        self.image = UIImage(iconCode: iconCode, size: size ?? frame.size, orientation: orientation, textColor: textColor, backgroundColor: backgroundColor)
    }
}

extension UITabBarItem {
    func setYJIcon(icon: YJType, size: CGSize? = nil, orientation: UIImageOrientation = UIImageOrientation.down, textColor: UIColor = UIColor.black, backgroundColor: UIColor = UIColor.clear, selectedTextColor: UIColor = UIColor.black, selectedBackgroundColor: UIColor = UIColor.clear) {
        FontLoader.loadFontIfNeeded()
        let tabBarItemImageSize = size ?? CGSize(width: 30, height: 30)

        image = UIImage(icon: icon, size: tabBarItemImageSize, orientation: orientation, textColor: textColor, backgroundColor: backgroundColor).withRenderingMode(UIImageRenderingMode.alwaysOriginal)

        selectedImage = UIImage(icon: icon, size: tabBarItemImageSize, orientation: orientation, textColor: selectedTextColor, backgroundColor: selectedBackgroundColor).withRenderingMode(UIImageRenderingMode.alwaysOriginal)

        setTitleTextAttributes([NSAttributedStringKey.foregroundColor: textColor], for: .normal)
        setTitleTextAttributes([NSAttributedStringKey.foregroundColor: selectedTextColor], for: .selected)
    }
}

extension UISegmentedControl {
    func setYJIcon(icon: YJType, forSegmentAtIndex segment: Int) {
        FontLoader.loadFontIfNeeded()
        let font = UIFont(name: YJStruct.FontName, size: 23)
        assert(font != nil, YJStruct.ErrorAnnounce)
        setTitleTextAttributes([NSAttributedStringKey.font: font!], for: .normal)
        setTitle(icon.text, forSegmentAt: segment)
    }
}

extension UIStepper {
    func setYJBackgroundImage(icon: YJType, forState state: UIControlState) {
        FontLoader.loadFontIfNeeded()
        let backgroundSize = CGSize(width: 47, height: 29)
        let image = UIImage(icon: icon, size: backgroundSize)
        setBackgroundImage(image, for: state)
    }

    func setYJIncrementImage(icon: YJType, forState state: UIControlState) {
        FontLoader.loadFontIfNeeded()
        let incrementSize = CGSize(width: 16, height: 16)
        let image = UIImage(icon: icon, size: incrementSize)
        setIncrementImage(image, for: state)
    }

    func setYJDecrementImage(icon: YJType, forState state: UIControlState) {
        FontLoader.loadFontIfNeeded()
        let decrementSize = CGSize(width: 16, height: 16)
        let image = UIImage(icon: icon, size: decrementSize)
        setDecrementImage(image, for: state)
    }
}

extension UIImage {
    convenience init(icon: YJType, size: CGSize, orientation: UIImageOrientation = UIImageOrientation.down, textColor: UIColor = UIColor.black, backgroundColor: UIColor = UIColor.clear) {
        FontLoader.loadFontIfNeeded()
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.center

        let fontAspectRatio: CGFloat = 1.285_714_29
        let fontSize = min(size.width / fontAspectRatio, size.height)
        let font = UIFont(name: YJStruct.FontName, size: fontSize)
        assert(font != nil, YJStruct.ErrorAnnounce)
        let attributes = [NSAttributedStringKey.font: font!, NSAttributedStringKey.foregroundColor: textColor, NSAttributedStringKey.backgroundColor: backgroundColor, NSAttributedStringKey.paragraphStyle: paragraph]

        let attributedString = NSAttributedString(string: icon.text!, attributes: attributes)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        attributedString.draw(in: CGRect(x: 0, y: (size.height - fontSize) * 0.5, width: size.width, height: fontSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        if let image = image {
            var imageOrientation = image.imageOrientation

            if orientation != UIImageOrientation.down {
                imageOrientation = orientation
            }

            self.init(cgImage: image.cgImage!, scale: image.scale, orientation: imageOrientation)
        } else {
            self.init()
        }
    }
    convenience init(iconCode: String, size: CGSize, orientation: UIImageOrientation = UIImageOrientation.down, textColor: UIColor = UIColor.black, backgroundColor: UIColor = UIColor.clear) {
        FontLoader.loadFontIfNeeded()
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.center

        let fontAspectRatio: CGFloat = 1.285_714_29
        let fontSize = min(size.width / fontAspectRatio, size.height)
        let font = UIFont(name: YJStruct.FontName, size: fontSize)
        assert(font != nil, YJStruct.ErrorAnnounce)
        let attributes = [NSAttributedStringKey.font: font!, NSAttributedStringKey.foregroundColor: textColor, NSAttributedStringKey.backgroundColor: backgroundColor, NSAttributedStringKey.paragraphStyle: paragraph]

        let attributedString = NSAttributedString(string: YJType.getIconText(iconCode: iconCode), attributes: attributes)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        attributedString.draw(in: CGRect(x: 0, y: (size.height - fontSize) * 0.5, width: size.width, height: fontSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        if let image = image {
            var imageOrientation = image.imageOrientation
            if orientation != UIImageOrientation.down {
                imageOrientation = orientation
            }

            self.init(cgImage: image.cgImage!, scale: image.scale, orientation: imageOrientation)
        } else {
            self.init()
        }
    }
    convenience init(bgIcon: YJType, topIcon: YJType, orientation: UIImageOrientation = UIImageOrientation.down, bgTextColor: UIColor = .black, bgBackgroundColor: UIColor = .clear, topTextColor: UIColor = .black, bgLarge: Bool = true, size: CGSize? = nil) {
        var bgSize: CGSize = .zero
        var topSize: CGSize = .zero
        var bgRect: CGRect = .zero
        var topRect: CGRect = .zero

        if bgLarge {
            topSize = size ?? CGSize(width: 30, height: 30)
            bgSize = CGSize(width: 2 * topSize.width, height: 2 * topSize.height)
        } else {
            bgSize = size ?? CGSize(width: 30, height: 30)
            topSize = CGSize(width: 2 * bgSize.width, height: 2 * bgSize.height)
        }

        let bgImage = UIImage(icon: bgIcon, size: bgSize, orientation: orientation, textColor: bgTextColor)
        let topImage = UIImage(icon: topIcon, size: topSize, orientation: orientation, textColor: topTextColor)

        if bgLarge {
            bgRect = CGRect(x: 0, y: 0, width: bgSize.width, height: bgSize.height)
            topRect = CGRect(x: topSize.width / 2, y: topSize.height / 2, width: topSize.width, height: topSize.height)
            UIGraphicsBeginImageContextWithOptions(bgImage.size, false, 0.0)
        } else {
            topRect = CGRect(x: 0, y: 0, width: topSize.width, height: topSize.height)
            bgRect = CGRect(x: bgSize.width / 2, y: bgSize.height / 2, width: bgSize.width, height: bgSize.height)
            UIGraphicsBeginImageContextWithOptions(topImage.size, false, 0.0)
        }

        bgImage.draw(in: bgRect)
        topImage.draw(in: topRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if let image = image {
            var imageOrientation = image.imageOrientation

            if orientation != UIImageOrientation.down {
                imageOrientation = orientation
            }

            self.init(cgImage: image.cgImage!, scale: image.scale, orientation: imageOrientation)
        } else {
            self.init()
        }
    }
}

extension UIViewController {
    var YJTitle: YJType? {
        set {
            FontLoader.loadFontIfNeeded()
            let font = UIFont(name: YJStruct.FontName, size: 23)
            assert(font != nil, YJStruct.ErrorAnnounce)
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: font!]
            title = newValue?.text
        }
        get {
            guard let title = title, let index = kYJIcons.index(of: title) else {
                return nil
            }
            return YJType(rawValue: index)
        }
    }
}
extension UISlider {
    func setYJMaximumValueImage(icon: YJType, orientation: UIImageOrientation = UIImageOrientation.down, customSize: CGSize? = nil) {
        maximumValueImage = UIImage(icon: icon, size: customSize ?? CGSize(width: 25, height: 25), orientation: orientation)
    }

    func setYJMinimumValueImage(icon: YJType, orientation: UIImageOrientation = UIImageOrientation.down, customSize: CGSize? = nil) {
        minimumValueImage = UIImage(icon: icon, size: customSize ?? CGSize(width: 25, height: 25), orientation: orientation)
    }
}

private enum FontLoader {
    static func loadFontIfNeeded() {
        if UIFont.fontNames(forFamilyName: YJStruct.FontName).isEmpty {
            let bundle = Bundle.main
            guard let path = bundle.url(forResource: "YJ", withExtension: ".ttf") else {
                return
            }
            guard let data = (try? Data(contentsOf: path)) else {
                return
            }
            let provider = CGDataProvider(data: data as CFData)
            let font = CGFont(provider!)

            var error: Unmanaged<CFError>?

            if CTFontManagerRegisterGraphicsFont(font!, &error) == false {
                let errorDescription: CFString = CFErrorCopyDescription(error!.takeUnretainedValue())
                guard let nsError = error?.takeUnretainedValue() as AnyObject as? NSError else {
                    return
                }
                NSException(name: NSExceptionName.internalInconsistencyException, reason: errorDescription as String, userInfo: [NSUnderlyingErrorKey: nsError]).raise()
            }
        }
    }
}

private enum YJStruct {
    static let FontName = "iconfont"
    static let ErrorAnnounce = "******  font not found in the bundle or not associated with Info.plist when manual installation was performed. ******"
}
