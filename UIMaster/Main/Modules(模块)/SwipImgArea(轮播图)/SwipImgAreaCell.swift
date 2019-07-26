//
//  SwipImgAreaCell.swift
//  UIDS
//
//  Created by one2much on 2018/1/10.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

class SwipImgAreaCell: UICollectionViewCell {
    // 标题
    var title: String = "" {
        didSet {
            titleLabel.text = "\(title)"
            if !(title.isEmpty) {
                titleBackView.isHidden = false
                titleLabel.isHidden = false
            } else {
                titleBackView.isHidden = true
                titleLabel.isHidden = true
            }
        }
    }

    // 标题颜色
    var titleLabelTextColor = UIColor.white {
        didSet {
            titleLabel.textColor = titleLabelTextColor
        }
    }

    // 标题字体
    var titleFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            titleLabel.font = titleFont
        }
    }

    // 文本行数
    var titleLines: NSInteger = 2 {
        didSet {
            titleLabel.numberOfLines = titleLines
        }
    }

    // 标题文本x轴间距
    var titleLabelLeading: CGFloat = 15 {
        didSet {
            setNeedsDisplay()
        }
    }

    // 标题背景色
    var titleBackViewBackgroundColor = UIColor.black.withAlphaComponent(0.3) {
        didSet {
            titleBackView.backgroundColor = titleBackViewBackgroundColor
        }
    }

    var titleBackView = UIView()

    // 标题Label高度
    var titleLabelHeight: CGFloat = 56 {
        didSet {
            layoutSubviews()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
        setupLabelBackView()
        setupTitleLabel()
    }

    // 图片
    var imageView = UIImageView()
    fileprivate var titleLabel = UILabel()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Setup ImageView
    fileprivate func setupImageView() {
        imageView = UIImageView()
        // 默认模式
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.contentView.addSubview(imageView)
    }

    // Setup Label BackView
    fileprivate func setupLabelBackView() {
        titleBackView = UIView()
        titleBackView.backgroundColor = titleBackViewBackgroundColor
        titleBackView.isHidden = true
        self.contentView.addSubview(titleBackView)
    }

    // Setup Title
    fileprivate func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.isHidden = true
        titleLabel.textColor = titleLabelTextColor
        titleLabel.numberOfLines = titleLines
        titleLabel.font = titleFont
        titleLabel.backgroundColor = UIColor.clear
        titleBackView.addSubview(titleLabel)
    }

    // MARK: layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()

        imageView.frame = self.bounds
        titleBackView.frame = CGRect(x: 0, y: self.height - titleLabelHeight, width: self.width, height: titleLabelHeight)
        titleLabel.frame = CGRect(x: titleLabelLeading, y: 0, width: self.width - titleLabelLeading - 5, height: titleLabelHeight)
    }
}
