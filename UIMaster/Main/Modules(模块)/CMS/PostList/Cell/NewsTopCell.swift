//
//  NewsTopCell.swift
//  UIMaster
//
//  Created by hobson on 2018/7/5.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

class NewsTopCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var badgeLabel: UILabel!

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
