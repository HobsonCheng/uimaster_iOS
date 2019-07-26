//
//  ChatEdgeLabel.swift
//  UIMaster
//
//  Created by hobson on 2018/9/27.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit

final class ChatEdgeLabel: UILabel {
    var labelEdge = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)

    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, labelEdge))
    }
}
