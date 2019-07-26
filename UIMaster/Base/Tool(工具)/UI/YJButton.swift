//
//  YJButton.swift
//  YJButton
//
//  Created by hobson on 2018/8/6.
//  Copyright © 2018年 hobson. All rights reserved.
//

import UIKit

/// 上图下文 上文下图 左文右图 右文左图
class YJButton: UIButton {
    /// 图片尺寸
    var imageSize = CGSize(width: 60, height: 60)
    /// 图文间距
    var margin: CGFloat = 0
    /// 图片位置 只支持左|上|右|下 其余按左对待
    var imagePostion: UIViewContentMode = .left {
        didSet {
            switch imagePostion {
            case .left:
                self.titleLabel?.textAlignment = .left
            case .right:
                self.titleLabel?.textAlignment = .right
            case .top:
                self.titleLabel?.textAlignment = .center
            case .bottom:
                self.titleLabel?.textAlignment = .center
            default:
                self.titleLabel?.textAlignment = .left
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleLabel?.numberOfLines = 1
    }
    override func awakeFromNib() {
        super.awakeFromNib()
         self.titleLabel?.numberOfLines = 1
    }
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var x: CGFloat = 0
        var y: CGFloat = 0
        switch imagePostion {
        case .left:
            x = contentRect.origin.x + margin
            y = (contentRect.size.height - imageSize.height) / 2
        case .right:
            x = contentRect.width - imageSize.width - margin
            y = (contentRect.size.height - imageSize.height) / 2
        case .top:
            x = (contentRect.width - imageSize.height) / 2
            y = margin
        case .bottom:
            x = (contentRect.width - imageSize.width) / 2
            y = contentRect.height - imageSize.height - margin
        default:
            x = contentRect.origin.x + margin
            y = (contentRect.size.height - imageSize.height) / 2
        }
        return CGRect(x: x, y: y, width: imageSize.width, height: imageSize.height)
    }

    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var width: CGFloat = 0
        var height: CGFloat = 0
        switch imagePostion {
        case .left:
            x = contentRect.origin.x + margin + imageSize.width + margin
            y = 0
            width = contentRect.size.width - x - margin
            height = contentRect.size.height
        case .right:
            x = contentRect.origin.x + margin
            y = 0
            width = contentRect.width - imageSize.width - margin * 3
            height = contentRect.size.height
        case .top:
            x = margin
            y = imageSize.height + margin * 2
            width = contentRect.width - margin * 2
            height = contentRect.height - imageSize.height - margin * 2
        case .bottom:
            x = margin
            y = margin
            width = contentRect.width - margin * 2
            height = contentRect.height - imageSize.height - margin * 3
        default:
            x = contentRect.origin.x + margin + imageSize.width + margin
            y = 0
            width = contentRect.size.width - x - margin
            height = contentRect.size.height
        }
        return CGRect(x: x, y: y, width: width, height: height)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
