//
//  MessageCell2.swift
//  UIMaster
//
//  Created by package on 2018/8/28.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

class MessageCell2: UITableViewCell {
    @IBOutlet weak var timeNow: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var postText: UILabel!
    var spacing: CGFloat = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override var frame: CGRect {
        didSet {
            var newFrame = frame
            //            newFrame.origin.x += spacing/2
            //            newFrame.size.width -= spacing
            newFrame.origin.y += spacing
            newFrame.size.height -= spacing
            super.frame = newFrame
        }
    }
}
