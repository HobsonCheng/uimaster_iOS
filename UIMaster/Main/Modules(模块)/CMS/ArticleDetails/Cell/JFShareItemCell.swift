//
//  JFShareItemCell.swift
//  WindSpeedVPN
//
//  Created by bai on 2016/11/30.
//  Copyright © 2016年 bai. All rights reserved.
//

import SnapKit
import UIKit

class JFShareItemCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 准备UI
    private func prepareUI() {
        backgroundColor = UIColor.clear
        contentView.addSubview(shareIconImageView)
        contentView.addSubview(shareTitleLabel)

        shareIconImageView.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(40)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }

        shareTitleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(contentView)
            make.top.equalTo(shareIconImageView.snp.bottom).offset(15)
        }
    }

    // MARK: - 懒加载
    /// 标题
    private lazy var shareTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: 0x0D0D0D, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()

    /// 图标
    private lazy var shareIconImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
}
