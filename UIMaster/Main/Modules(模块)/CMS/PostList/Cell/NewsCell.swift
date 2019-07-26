//
//  NewsCell.swift
//  UIMaster
//
//  Created by hobson on 2018/7/5.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var delBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentNum: UILabel!
    @IBOutlet weak var soureceLabel: UILabel!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleImageView: UIImageView!

    var cellModel: TopicData?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func layoutSubviews() {
        let source = cellModel?.source
        let time = cellModel?.add_time
        let title = cellModel?.title
//        let summarize = cellModel?.summarize
        self.titleLabel.text = title ?? ""
        self.timeLabel.text = time ?? ""
        self.soureceLabel.text = source ?? ""
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
