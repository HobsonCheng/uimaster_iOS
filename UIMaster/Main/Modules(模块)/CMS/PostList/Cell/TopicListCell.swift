//
//  TopicCell.swift
//  UIMaster
//
//  Created by hobson on 2018/7/5.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

class TopicListCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    @IBOutlet weak var btnContainer: UIStackView!
    @IBOutlet weak var contentLabelHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var delBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var praiseBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var reportBtn: UIButton!

    var cellModel: TopicData?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
