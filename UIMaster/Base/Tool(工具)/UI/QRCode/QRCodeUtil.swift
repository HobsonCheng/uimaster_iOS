//
//  QRCodeUtil.swift
//  UIMaster
//
//  Created by hobson on 2018/8/31.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Kingfisher
import UIKit

class QRCodeUtil {
    private static let singleton = QRCodeUtil()

    static let shared = {
        singleton
    }()

    private init() {}

    /// 生成带中间logo的二维码
    ///
    /// - Parameters:
    ///   - image: 中间的logo图
    ///   - str: 二维码链接
    func createCenterImageQRCode(byImage image: UIImage?, withStr str: String) -> UIImage? {
        //创建滤镜
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        //设置数据
        let data = str.data(using: String.Encoding.utf8)
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        //高清处理
        let transform = CGAffineTransform(scaleX: 20, y: 20)
        let outputImage = filter?.outputImage?.transformed(by: transform)
        guard let safeOutput = outputImage else {
            HUDUtil.msg(msg: "生成图片失败", type: .error)
            return nil
        }
        //CIImage转换成UIImage
        let resultImage = UIImage(ciImage: safeOutput)
        //返回结果
        return getNewImage(sourceImage: resultImage, center: image)
    }
    /// 绘制小图到二维码上
    ///
    /// - Parameters:
    ///   - sourceImage: 二维码图
    ///   - center: 小图
    /// - Returns: 结果图片
    func getNewImage(sourceImage: UIImage, center: UIImage?) -> UIImage? {
        //开启图形上下文
        let size = sourceImage.size
        UIGraphicsBeginImageContext(size)
        //绘制大图
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        //绘制小图
        let width: CGFloat = 120
        let height: CGFloat = 120
        let x: CGFloat = (size.width - width) / 2
        let y: CGFloat = (size.height - height) / 2
        //绘制小图边框
        let path = UIBezierPath(rect: CGRect(x: x - 15, y: y - 15, width: width + 30, height: height + 30))
        UIColor.white.setFill()
        path.fill()
        let logo = ImageCache.default.retrieveImageInDiskCache(forKey: kLogoCacheKey) ?? UIImage(named: "AppIcon60x60")
        logo?.draw(in: CGRect(x: x, y: y, width: width, height: height))
        //取出结果
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        //返回结果
        return resultImage
    }
}
