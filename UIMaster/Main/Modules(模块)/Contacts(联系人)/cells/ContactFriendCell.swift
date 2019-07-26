//
//  ContactTableViewCell.swift
//  TSWeChat
//
//  Created by Hilen on 11/26/15.
//  Copyright © 2015 Hilen. All rights reserved.
//

import UIKit

class ContactFriendCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var identifierImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
//        avatarImageView.cornerRadius = 5
//        avatarImageView.maskToBounds = true
//        placeholderLabel.cornerRadius = 5
//        placeholderLabel.maskToBounds = true

    }

    func setCellContnet(_ model: ContactPersonData) {
        self.avatarImageView.kf.setImage(with: URL(string: model.head_portrait ?? ""), placeholder: R.image.icon_avatar(), options: nil, progressBlock: nil, completionHandler: nil)
        self.usernameLabel.text = model.full_name
        if model.user_id == nil || model.user_id == 0 {
            placeholderLabel.isHidden = false
            placeholderLabel.text = model.full_name?.first?.description
            identifierImageView.isHidden = true
            avatarImageView.isHidden = true
        } else {
            placeholderLabel.isHidden = true
            identifierImageView.isHidden = false
            avatarImageView.isHidden = false
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
