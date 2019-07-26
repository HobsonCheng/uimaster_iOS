//
//  String+GetSize.swift
//  UIDS
//
//  Created by one2much on 2018/1/17.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

extension String {
    // MARK: - 获取字符串大小
    func getSize(fontSize: CGFloat) -> CGSize {
        let str = self as NSString

        let size = CGSize(width: UIScreen.main.bounds.width, height: CGFloat(MAXFLOAT))

        return str.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize)], context: nil).size
    }

    // MARK: - 获取字符串大小
    func getSize(font: UIFont) -> CGSize {
        let str = self as NSString

        let size = CGSize(width: UIScreen.main.bounds.width, height: CGFloat(MAXFLOAT))
        return str.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil).size
    }
    // MARK: - 获取字符串大小
    func getSize(font: UIFont, viewWidth: CGFloat) -> CGSize {
        let str = self as NSString

        let size = CGSize(width: viewWidth, height: CGFloat(MAXFLOAT))

        return str.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil).size
    }
    // MARK: - 获取字符串高度 add by 长老钦此
    func getSizeForString(font: CGFloat, viewWidth: CGFloat) -> CGSize {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: font)
        label.text = self
        label.numberOfLines = 0
        return CGSize(width: viewWidth, height: label.sizeThatFits(CGSize(width: viewWidth, height: CGFloat(MAXFLOAT))).height)
    }

    /**
     Calculate the size of string, and limit the width
     
     - parameter width: width
     - parameter font:     font
     
     - returns: size value
     */
    func sizeWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGSize {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let size: CGSize = self.boundingRect(
            with: constraintRect,
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSAttributedStringKey.font: font],
            context: nil
            ).size
        return size
    }

    /**
     Calculate the height of string, and limit the width
     
     - parameter width: width
     - parameter font:  font
     
     - returns: height value
     */
    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedStringKey.font: font],
            context: nil)
        return boundingBox.height
    }
}
