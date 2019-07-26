//
//  DepartmentCell.swift
//  UIMaster
//
//  Created by hobson on 2018/10/7.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit

class DepartmentCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var departmentNameLabel: UILabel!
    @IBOutlet weak var phoneCallBtn: UIButton!
    @IBOutlet weak var placeholderLabel: UILabel!

    var model: OrgnizationStructData? {
        didSet {
            departmentNameLabel.text = model?.name
            if let phone = model?.phone, !phone.isEmpty {
                self.phoneCallBtn.isHidden = false
            } else {
                self.phoneCallBtn.isHidden = true
            }

            if let headUrlStr = model?.head_portrait, !headUrlStr.isEmpty {
                placeholderLabel.isHidden = true
                iconImageView.isHidden = false
                iconImageView.kf.setImage(with: URL(string: headUrlStr), placeholder: R.image.defaultPortrait(), options: nil, progressBlock: nil, completionHandler: nil)
            } else {
                placeholderLabel.isHidden = false
                iconImageView.isHidden = true
                placeholderLabel.text = model?.name?.first?.description ?? ""
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        iconImageView.cornerRadius = 25.5
        iconImageView.maskToBounds = true
        placeholderLabel.cornerRadius = 25.5
        placeholderLabel.maskToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func makePhoneCall(_ sender: Any) {
        DeviceTool.makePhoneCall(with: model?.phone)
    }
}
