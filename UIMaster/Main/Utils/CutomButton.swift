//
// Created by YJHobson on 2018/5/28.
// Copyright (c) 2018 one2much. All rights reserved.
//

import UIKit

enum ImagePosition {
    case left  //default
    case right
    case top
    case bottom
}
struct CustomButtonConfig {
    ///图文间距
    var margin: CGFloat = 8
    ///图片位置
    var imagePosition: ImagePosition = .top
    ///是否有标题
    var hasTitle: Int = 1
    ///图片宽度
    var imageWidth: CGFloat = 60
    ///图片高度
    var imageHeight: CGFloat = 60
    ///文字高度
    var titleHeight: CGFloat = 14
    ///图片
    var imageUrl: String = ""
    ///文字
    var title: String = ""
    ///图片形状
    var shape: IconShape = .square
}

class CustomButton: UIButton {
    var config = CustomButtonConfig()
    var isOrigin = false

    init(frame: CGRect, config: CustomButtonConfig) {
        self.config = config
        super.init(frame: frame)
        self.kf.setImage(with: URL(string: config.imageUrl), for: .normal)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let width = config.imageWidth
        let height = config.imageHeight
        let startX = (self.width - width) / 2
        let startY = config.margin
        self.imageView?.frame = CGRect(x: startX, y: startY, width: width, height: height)
        if config.hasTitle == 1 {
            self.titleLabel?.frame = CGRect(x: 0, y: ((self.imageView?.bottom ?? 0) + config.margin), width: self.width, height: config.titleHeight)
            self.titleLabel?.textAlignment = .center
            self.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            self.setTitle(config.title, for: .normal)
            self.titleLabel?.textColor = .black
        }
        if config.shape == .round {
            self.imageView?.layer.cornerRadius = width / 2
            self.imageView?.layer.masksToBounds = true
        }
    }
}
