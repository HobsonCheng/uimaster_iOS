//
//  JFDetailOtherCell.swift
//  UIDS
//
//  Created by bai on 16/2/24.
//  Copyright © 2016年 bai. All rights reserved.
//

import UIKit

class JFDetailOtherCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var befromLabel: UILabel!
    @IBOutlet weak var showNumLabel: UILabel!

    var model: String? {
        didSet {
            if model != nil {
                iconImageView.isHidden = false
//                model?.titlepic = model?.titlepic?.hasPrefix("http") == true ? titlepic : "http://www.baokan.name\(titlepic)"
                iconImageView.image = UIImage(named: "placeholder_logo.png")
            } else {
                iconImageView.isHidden = true
            }

//            articleTitleLabel.text = "model?.title"
//            befromLabel.text = "model?.classname"
//            showNumLabel.text = "model?.onclick"
        }
    }
}
