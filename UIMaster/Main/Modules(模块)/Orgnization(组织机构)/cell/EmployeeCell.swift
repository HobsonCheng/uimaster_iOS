//
//  EmployeeCell.swift
//  UIMaster
//
//  Created by hobson on 2018/10/7.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit

class EmployeeCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!

    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var msgBtn: UIButton!
    var model: OrgnizationStructData? {
        didSet {
            nickNameLabel.text = model?.name
            jobLabel.text = model?.post
            if let phone = model?.phone, phone != ""{
                self.phoneBtn.isHidden = false
                self.separatorView.isHidden = false
                self.msgBtn.isHidden = false
            } else {
                self.phoneBtn.isHidden = true
                self.separatorView.isHidden = true
                self.msgBtn.isHidden = true
            }

            if let headUrlStr = model?.head_portrait, headUrlStr != ""{
                placeHolderLabel.isHidden = true
                iconImageView.isHidden = false
                iconImageView.kf.setImage(with: URL(string: headUrlStr), placeholder: R.image.defaultPortrait(), options: nil, progressBlock: nil, completionHandler: nil)
            } else {
                placeHolderLabel.isHidden = false
                iconImageView.isHidden = true
                placeHolderLabel.text = model?.post?.first?.description ?? ""
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        iconImageView.cornerRadius = 20
        iconImageView.maskToBounds = true
        placeHolderLabel.cornerRadius = 20
        placeHolderLabel.maskToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func makePhoneCall(_ sender: Any) {
        DeviceTool.makePhoneCall(with: model?.phone)
    }

    @IBAction func sendMessage(_ sender: Any) {
        DeviceTool.sendSMS(with: model?.phone)
    }
}
