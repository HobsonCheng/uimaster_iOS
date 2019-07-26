//
//  FriendListCell.swift
//  UIMaster
//
//  Created by YJHobson on 2018/7/19.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

class FriendListCell: UITableViewCell {
    @IBOutlet weak var infoDetails: UILabel!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var headImg: UIImageView!

    var cellModel: UserInfoData? {
        didSet {
            infoDetails.text = (cellModel?.signature?.isEmpty ?? true) ?  "暂无简介" : cellModel?.signature
            friendName.text = (cellModel?.zh_name?.isEmpty ?? true) ? "无昵称" : cellModel?.zh_name
            headImg.kf.setImage(with: URL(string: cellModel?.head_portrait ?? ""), placeholder: R.image.defaultPortrait()!, options: nil, progressBlock: nil, completionHandler: nil)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
