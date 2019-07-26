//
//  ContactsNoInfoCell.swift
//  UIMaster
//
//  Created by hobson on 2018/8/28.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

class ContactsNoInfoCell: UITableViewCell {
    @IBOutlet weak var departmentInto: UILabel!
    @IBOutlet weak var departmentName: UILabel!

    var spacing: CGFloat = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cornerRadius = 2
        self.maskToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override var frame: CGRect {
        didSet {
            var newFrame = frame
            newFrame.origin.x += spacing
            newFrame.size.width -= spacing * 2
            newFrame.origin.y += spacing
            newFrame.size.height -= spacing
            super.frame = newFrame
        }
    }
}
