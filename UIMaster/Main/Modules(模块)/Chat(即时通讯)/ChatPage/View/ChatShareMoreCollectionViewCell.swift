//
//  ChatShareMoreCollectionViewCell.swift
//  TSWeChat
//
//  Created by Hilen on 12/30/15.
//  Copyright © 2015 Hilen. All rights reserved.
//

import UIKit

class ChatShareMoreCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var itemButton: UIButton!
    @IBOutlet weak var itemLabel: UILabel!
    override var isHighlighted: Bool { didSet {
//        if self.isHighlighted {
//            self.itemButton.setBackgroundImage(Asset.Share.sharemoreOtherHL.image, for: .highlighted)
//        } else {
//            self.itemButton.setBackgroundImage(Asset.Share.sharemoreOther.image, for: UIControlState())
//        }
    }}

    override func awakeFromNib() {
        super.awakeFromNib()
        itemButton.layer.cornerRadius = 10
        itemButton.maskToBounds = true
//        self.contentView.backgroundColor = UIColor.redColor()
        // Initialization code
    }
}
