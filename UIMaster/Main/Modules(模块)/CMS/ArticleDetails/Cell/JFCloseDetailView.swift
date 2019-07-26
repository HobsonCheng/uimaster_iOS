//
//  JFCloseDetailView.swift
//  LiuAGeIOS
//
//  Created by bai on 16/6/23.
//  Copyright © 2016年 bai. All rights reserved.
//

import UIKit

class JFCloseDetailView: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)

        imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -8)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
