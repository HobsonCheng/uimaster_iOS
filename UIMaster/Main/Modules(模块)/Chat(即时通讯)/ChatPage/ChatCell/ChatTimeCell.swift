//
//  ChatTimeCell.swift
//  TSWeChat
//
//  Created by Hilen on 1/11/16.
//  Copyright © 2016 Hilen. All rights reserved.
//

import UIKit

private let kChatTimeLabelMaxWidth: CGFloat = kScreenW - 30 * 2
private let kChatTimeLabelPaddingLeft: CGFloat = 6   //左右分别留出 6 像素的留白
private let kChatTimeLabelPaddingTop: CGFloat = 3   //上下分别留出 3 像素的留白
private let kChatTimeLabelMarginTop: CGFloat = 10   //顶部 10 px

class ChatTimeCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel! {didSet {
        timeLabel.layer.cornerRadius = 4
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.layer.masksToBounds = true
        timeLabel.textColor = UIColor.white
        timeLabel.backgroundColor = UIColor (red: 200 / 255, green: 200 / 255, blue: 200 / 255, alpha: 0.6 )
        }}
    var model: ChatMessageModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    }

    func setCellContent(_ model: ChatMessageModel) {
        self.model = model
        self.timeLabel.text = model.content
    }

    override func layoutSubviews() {
        guard let safeModel = model  else {
            return
        }
        let message = safeModel.content
        self.timeLabel.setFrameWithString(message, width: kChatTimeLabelMaxWidth)
        self.timeLabel.width += kChatTimeLabelPaddingLeft * 2  //左右的留白
        self.timeLabel.left = (kScreenW - self.timeLabel.width) / 2
        self.timeLabel.height += kChatTimeLabelPaddingTop * 2
        self.timeLabel.top = kChatTimeLabelMarginTop
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    class func heightForCell() -> CGFloat {
        return 40
    }
}
