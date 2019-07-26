//
//  ExtImage.swift
//  UIDS
//
//  Created by one2much on 2018/1/24.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

extension UIImage {
    /*
     将图片等比例缩放, 缩放到图片的宽度等屏幕的宽度
     */
    func displaySize() -> CGSize {
        // 新的高度 / 新的宽度 = 原来的高度 / 原来的宽度

        // 新的宽度
        let newWidth = kScreenH

        // 新的高度
        let newHeight = newWidth * size.height / size.width

        let newSize = CGSize(width: newWidth, height: newHeight)
        return newSize
    }

    /**
     缩放图片到指定的尺寸
     
     - parameter newSize: 需要缩放的尺寸
     
     - returns: 返回缩放后的图片
     */
    func resizeImageWithNewSize(_ newSize: CGSize) -> UIImage {
        var rect = CGRect.zero
        let oldSize = self.size

        if newSize.width / newSize.height > oldSize.width / oldSize.height {
            rect.size.width = newSize.height * oldSize.width / oldSize.height
            rect.size.height = newSize.height
            rect.origin.x = (newSize.width - rect.size.width) * 0.5
            rect.origin.y = 0
        } else {
            rect.size.width = newSize.width
            rect.size.height = newSize.width * oldSize.height / oldSize.width
            rect.origin.x = 0
            rect.origin.y = (newSize.height - rect.size.height) * 0.5
        }

        UIGraphicsBeginImageContext(newSize)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.clear.cgColor)
        UIRectFill(CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

    static func imageWithColor(_ color: UIColor) -> UIImage {
    let rect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    context?.setFillColor(color.cgColor)
    context?.fill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return image!
    }
}
