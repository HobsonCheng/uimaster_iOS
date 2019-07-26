//
//  SearchBarFiled.swift
//  model
//
//  Created by Hobson on 2018/3/29.
//  Copyright © 2018年 yiji. All rights reserved.
//

import UIKit

class SearchBarFiled: UITextField {
    var placeholderTextColor: UIColor {
        didSet {
            self.setValue(placeholderTextColor, forKeyPath: "_placeholderLabel.textColor")
        }
    }

    override init(frame: CGRect) {
        self.placeholderTextColor = .gray
        super.init(frame: frame)
        self.placeholder = "请输入您单位的名称"
        self.layer.masksToBounds = true
        self.font = UIFont.systemFont(ofSize: 13)
        self.leftViewMode = .always
        self.clearButtonMode = .whileEditing
        setLeftViewWithImage()
    }
    fileprivate func setLeftViewWithImage() {
        let imgContainer = UIView()
        imgContainer.height = 29
        imgContainer.width = 29
        let imgView = UIImageView()
        imgView.setYJIconWithName(icon: .search, textColor: .white, size: CGSize(width: 18, height: 18))
        imgView.height = imgContainer.height - 10
        imgView.width = imgContainer.width - 10
        imgView.center = imgContainer.center
        imgContainer.addSubview(imgView)
        self.leftView = imgContainer
    }
    func setClearButtonImage() {
        guard let btn = self.value(forKey: "clearButton") as? UIButton else {
            return
        }
        btn.setImage(UIImage(icon: .clear, size: CGSize(width: 18, height: 18), orientation: .up, textColor: .white, backgroundColor: .clear), for: .normal)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
