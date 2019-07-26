//
//  UIImage+Utility.swift
//  UIMaseter
//
//  Created by gongcz on 2018/4/17.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Accelerate
import CoreGraphics
import QuartzCore
import UIKit

extension UIImage {
    /// 通过沙盒路径获取图片对象
    ///
    /// - Parameter path: 路径
    /// - Returns: 图片对象可能为空
    class func getImage(in path: String) -> UIImage? {
//        var image = UIImage(named: path)
//        if image == nil {
        if !SandboxTool.isFileExist(in: path) {
            return R.image.icon256()
        }
        let image = UIImage(contentsOfFile: path)
//        }
        return image
    }

    class func grayscale(_ anImage: UIImage?, type: Int8) -> UIImage? {
//        var imageRef: CGImage?
        guard let imageRef: CGImage = anImage?.cgImage else {
            return nil
        }

        let width: size_t = imageRef.width
        let height: size_t = imageRef.height
        // ピクセルを構成するRGB各要素が何ビットで構成されている
        var bitsPerComponent: size_t
        bitsPerComponent = imageRef.bitsPerComponent
        // ピクセル全体は何ビットで構成されているか
        var bitsPerPixel: size_t
        bitsPerPixel = imageRef.bitsPerPixel
        // 画像の横1ライン分のデータが、何バイトで構成されているか
        var bytesPerRow: size_t
        bytesPerRow = imageRef.bytesPerRow
        // 画像の色空間
        var colorSpace: CGColorSpace?
        colorSpace = imageRef.colorSpace
        // 画像のBitmap情報
        var bitmapInfo: CGBitmapInfo
        bitmapInfo = imageRef.bitmapInfo
        // 画像がピクセル間の補完をしているか
        var shouldInterpolate: Bool
        shouldInterpolate = imageRef.shouldInterpolate
        // 表示装置によって補正をしているか
        var intent: CGColorRenderingIntent
        intent = imageRef.renderingIntent
        // 画像のデータプロバイダを取得する
        var dataProvider: CGDataProvider?
        dataProvider = imageRef.dataProvider
        // TODO: swift4无法操作指针
        // データプロバイダから画像のbitmap生データ取得
        var data: CFData?
        var buffer: UnsafePointer<UInt8>?
        data = dataProvider?.data
        buffer = CFDataGetBytePtr(data)
//        let bytes = buffer.mem
        // 1ピクセルずつ画像を処理
        for yIndex in 0..<Int(height) {
            for xIndex in 0..<Int(width) {
                var tmp: UnsafeMutablePointer<UInt8>!
                tmp = UnsafeMutablePointer(mutating: buffer!) + yIndex * bytesPerRow + xIndex * 4
                // RGBAの4つ値をもっているので、1ピクセルごとに*4してずらす
                // RGB値を取得
                var red: UInt8
                var green: UInt8
                var blue: UInt8
                red = (tmp + 0).pointee
                green = (tmp + 1).pointee
                blue = (tmp + 2).pointee

                switch type {
                case 1:
                    //モノクロ
                    // 輝度計算
                    let brightness: UInt8 = red
                    (tmp + 0).pointee = brightness
                    (tmp + 1).pointee = brightness
                    (tmp + 2).pointee = brightness
                case 2:
                    //セピア
                    (tmp + 0).pointee = red
                    (tmp + 1).pointee = UInt8(Double(green) * 0.7)
                    (tmp + 2).pointee = UInt8(Double(blue) * 0.4)
                case 3:
                    //色反転
                    (tmp + 0).pointee = 255 - red
                    (tmp + 1).pointee = 255 - green
                    (tmp + 2).pointee = 255 - blue
                default:
                    (tmp + 0).pointee = red
                    (tmp + 1).pointee = green
                    (tmp + 2).pointee = blue
                }
            }
        }
        // 効果を与えたデータ生成
        var effectedData: CFData?
        effectedData = CFDataCreate(nil, buffer, CFDataGetLength(data))
        // 効果を与えたデータプロバイダを生成
        var effectedDataProvider: CGDataProvider?
        effectedDataProvider = CGDataProvider(data: effectedData!)
        // 画像を生成
        var effectedCgImage: CGImage?
        var effectedImage: UIImage?
        effectedCgImage = CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: colorSpace!, bitmapInfo: bitmapInfo, provider: effectedDataProvider!, decode: nil, shouldInterpolate: shouldInterpolate, intent: intent)
        if let anImage = effectedCgImage {
            effectedImage = UIImage(cgImage: anImage)
        }
        // データの解放
//        CGImageRelease(effectedCgImage!)
        return effectedImage
    }

    /// 彩色图片置灰，灰度图片
    public func grayImage(sourceImage: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue)
        context?.draw(sourceImage.cgImage!, in: CGRect(x: 0, y: 0, width: sourceImage.size.width, height: sourceImage.size.height))
        let cgImage = context!.makeImage()
        let grayImage = UIImage(cgImage: cgImage!)
        return grayImage
    }

    static func from(color: UIColor?) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor((color?.cgColor)!)
        context?.fill(rect)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension UIImage {
    /**
     Fix the image's orientation
     
     - parameter src: the source image
     
     - returns: new image
     */
    class func fixImageOrientation(_ src: UIImage) -> UIImage {
        if src.imageOrientation == UIImageOrientation.up {
            return src
        }

        var transform = CGAffineTransform.identity

        switch src.imageOrientation {
        case UIImageOrientation.down, UIImageOrientation.downMirrored:
            transform = transform.translatedBy(x: src.size.width, y: src.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
        case UIImageOrientation.left, UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: src.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
        case UIImageOrientation.right, UIImageOrientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: src.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi))
            break
        case UIImageOrientation.up, UIImageOrientation.upMirrored:
            break
        }

        switch src.imageOrientation {
        case UIImageOrientation.upMirrored, UIImageOrientation.downMirrored:
            transform.translatedBy(x: src.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImageOrientation.leftMirrored, UIImageOrientation.rightMirrored:
            transform.translatedBy(x: src.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImageOrientation.up, UIImageOrientation.down, UIImageOrientation.left, UIImageOrientation.right:
            break
        }

        let ctx = CGContext(data: nil, width: Int(src.size.width), height: Int(src.size.height), bitsPerComponent: src.cgImage!.bitsPerComponent, bytesPerRow: 0, space: src.cgImage!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

        ctx.concatenate(transform)

        switch src.imageOrientation {
        case UIImageOrientation.left, UIImageOrientation.leftMirrored, UIImageOrientation.right, UIImageOrientation.rightMirrored:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.height, height: src.size.width))
            break
        default:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.width, height: src.size.height))
            break
        }

        let cgimage: CGImage = ctx.makeImage()!
        let image = UIImage(cgImage: cgimage)

        return image
    }
}

extension UIImage {
    //https://github.com/melvitax/AFImageHelper/blob/master/AFImageHelper%2FAFImageExtension.swift
    public enum UIImageContentModeType {
        case scaleToFill, scaleAspectFit, scaleAspectFill
    }

    /**
     Creates a resized copy of an image.
     
     - Parameter size: The new size of the image.
     - Parameter contentMode: The way to handle the content in the new size.
     - Parameter quality:     The image quality
     
     - Returns A new image
     */
    public func resize(_ size: CGSize, contentMode: UIImageContentModeType = .scaleToFill, quality: CGInterpolationQuality = .medium) -> UIImage? {
        let horizontalRatio = size.width / self.size.width
        let verticalRatio = size.height / self.size.height
        var ratio: CGFloat!

        switch contentMode {
        case .scaleToFill:
            ratio = 1
        case .scaleAspectFill:
            ratio = max(horizontalRatio, verticalRatio)
        case .scaleAspectFit:
            ratio = min(horizontalRatio, verticalRatio)
        }

        let rect = CGRect(x: 0, y: 0, width: size.width * ratio, height: size.height * ratio)

        // Fix for a colorspace / transparency issue that affects some types of
        // images. See here: http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/comment-page-2/#comment-39951

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(rect.size.width), height: Int(rect.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)

        let transform = CGAffineTransform.identity

        // Rotate and/or flip the image if required by its orientation
        context?.concatenate(transform)

        // Set the quality level to use when rescaling
        context!.interpolationQuality = quality

        //CGContextSetInterpolationQuality(context, CGInterpolationQuality(kCGInterpolationHigh.value))

        // Draw into the context; this scales the image
        context?.draw(self.cgImage!, in: rect)

        // Get the resized image from the context and a UIImage
        let newImage = UIImage(cgImage: (context?.makeImage()!)!, scale: self.scale, orientation: self.imageOrientation)
        return newImage
    }

    public func crop(_ bounds: CGRect) -> UIImage? {
        return UIImage(cgImage: (self.cgImage?.cropping(to: bounds)!)!, scale: 0.0, orientation: self.imageOrientation)
    }

    public func cropToSquare() -> UIImage? {
        let size = CGSize(width: self.size.width * self.scale, height: self.size.height * self.scale)
        let shortest = min(size.width, size.height)
        let left: CGFloat = size.width > shortest ? (size.width - shortest) / 2 : 0
        let top: CGFloat = size.height > shortest ? (size.height - shortest) / 2 : 0
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let insetRect = rect.insetBy(dx: left, dy: top)
        return crop(insetRect)
    }
}
