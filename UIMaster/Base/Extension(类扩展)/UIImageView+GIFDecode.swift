//
//  UIImageView+GIFDecode.swift
//  UIMaseter
//
//  Created by gongcz on 2018/4/18.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

extension UIImageView {
    func decode(with data: Data?) {
        // 设置动画图片
        var arrayImages = [AnyHashable]()
        let source = CGImageSourceCreateWithData(data! as CFData, nil)
        if let src = source {
            //获取gif的帧数
            let frameCount: Int = CGImageSourceGetCount(src)
            //获取GfiImage的基本数据
            for idx in 0..<frameCount {
                //得到每一帧的CGImage
                if let img = CGImageSourceCreateImageAtIndex(src, idx, nil) {
                    //把CGImage转化为UIImage
                    let frameImage = UIImage(cgImage: img)
                    arrayImages.append(frameImage)
                }
            }
        }
        animationImages = arrayImages as? [UIImage]
        animationDuration = 2
        animationRepeatCount = 0
        startAnimating()
    }
}
