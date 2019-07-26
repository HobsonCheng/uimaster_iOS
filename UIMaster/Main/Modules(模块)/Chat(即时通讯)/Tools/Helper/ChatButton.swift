//
//  ChatButton.swift
//  UIMaster
//
//  Created by hobson on 2018/9/26.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit

class ChatButton: UIButton {
    var showTypingKeyboard: Bool

    required init(coder aDecoder: NSCoder) {
        self.showTypingKeyboard = true
        super.init(coder: aDecoder)!
    }
}
