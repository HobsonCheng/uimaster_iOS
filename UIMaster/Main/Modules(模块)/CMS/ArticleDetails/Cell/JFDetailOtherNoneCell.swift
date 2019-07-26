//
//  JFDetailOtherCell.swift
//  UIDS
//
//  Created by bai on 16/2/24.
//  Copyright © 2016年 bai. All rights reserved.
//

import UIKit

class JFDetailOtherNoneCell: UITableViewCell {
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var befromLabel: UILabel!
    @IBOutlet weak var showNumLabel: UILabel!

    var model: String? {
        didSet {
//            articleTitleLabel.text = model!.title!
//            befromLabel.text = model!.classname!
//            showNumLabel.text = model!.onclick!
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        articleTitleLabel.preferredMaxLayoutWidth = kScreenW - 30
    }

    /**
     计算行高
     */
    func getRowHeight(_ model: String) -> CGFloat {
        self.model = model
        layoutIfNeeded()
        return showNumLabel.frame.maxY + 15
    }
}
