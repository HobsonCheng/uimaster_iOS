//
//  ContactCell.swift
//  UIMaster
//
//  Created by package on 2018/8/24.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

class ContactsCell: UITableViewCell {
    @IBOutlet weak var sectionIcon: UIButton!
    @IBOutlet weak var sectionNameLabel: UILabel!
    @IBOutlet weak var locationIconBtn: UIButton!
    @IBOutlet weak var telNumLabel: UILabel!
    @IBOutlet weak var telBtn: UIButton!
    @IBOutlet weak var detailBtn: UIButton!
//    @IBOutlet weak var distanceBtn: UIButton!
    @IBOutlet weak var locationBtn: UIButton!
    var mapUrl: String?
    var spacing: CGFloat = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.cornerRadius = 2
        self.maskToBounds = true
        self.sectionIcon.cornerRadius = 25
        self.sectionIcon.maskToBounds = true
        telNumLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(makeCall(_:))))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction private func openMap(_ sender: Any) {
        if mapUrl?.trim() == nil || mapUrl?.trim() == ""{
            return
        }
        let otherVC = OtherWebVC()
        otherVC.urlString = mapUrl ?? "http://m.qy.u-kor.cn/web/onlyMapInfo.do?shopid=10897&tab=0&tenantid=32068"
        VCController.push(otherVC, with: VCAnimationClassic.defaultAnimation())
    }

    @IBAction private func makeCall(_ sender: Any) {
        let phoneNum = telNumLabel.text ?? ""
        let url = URL(string: "tel:\(phoneNum)")
        let application = UIApplication.shared
        guard let safeUrl = url else {
            return
        }
        if application.canOpenURL(safeUrl) {
            if #available(iOS 10.0, *) {
                application.open(safeUrl, options: [:], completionHandler: nil)
            } else {
                application.openURL(safeUrl)
                // Fallback on earlier versions
            }
        }
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
