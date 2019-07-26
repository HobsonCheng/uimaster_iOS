//
//  ChatSystemCell.swift
//  TSWeChat
//
//  Created by Hilen on 1/11/16.
//  Copyright © 2016 Hilen. All rights reserved.
//

import UIKit

private let kChatInfoFont = UIFont.systemFont(ofSize: 13)
private let kChatInfoLabelMaxWdith: CGFloat = kScreenW - 40 * 2
private let kChatInfoLabelPaddingLeft: CGFloat = 8   //左右分别留出 8 像素的留白
private let kChatInfoLabelPaddingTop: CGFloat = 4   //上下分别留出 4 像素的留白
private let kChatInfoLabelMarginTop: CGFloat = 3  //距离顶部
private let kChatInfoLabelMarginBottom: CGFloat = 10 //距离底部

class ChatSystemCell: UITableViewCell {
    @IBOutlet weak var infomationLabel: ChatEdgeLabel! {didSet {
        infomationLabel.font = kChatInfoFont
        infomationLabel.labelEdge = UIEdgeInsets(
            top: 0,
            left: kChatInfoLabelPaddingLeft,
            bottom: 0,
            right: kChatInfoLabelPaddingLeft
        )
        infomationLabel.layer.cornerRadius = 4
        infomationLabel.layer.masksToBounds = true
        infomationLabel.font = kChatInfoFont
        infomationLabel.textColor = UIColor.white
        infomationLabel.backgroundColor = UIColor (red: 190 / 255, green: 190 / 255, blue: 190 / 255, alpha: 0.6 )
        }}
    var model: ChatMessageModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    func setCellContent(_ model: ChatMessageModel) {
        self.model = model
        self.infomationLabel.text = model.content
    }

    override func layoutSubviews() {
        guard let model = self.model else {
            return
        }
        self.infomationLabel.setFrameWithString(model.content, width: kChatInfoLabelMaxWdith)
        self.infomationLabel.width += kChatInfoLabelPaddingLeft * 2  //左右的留白
        self.infomationLabel.height += kChatInfoLabelPaddingTop * 2   //上下的留白
        self.infomationLabel.left = (kScreenW - self.infomationLabel.width) / 2
        self.infomationLabel.top = kChatInfoLabelMarginTop
    }

    class func layoutHeight(_ model: ChatMessageModel) -> CGFloat {
        if model.cellHeight != 0 {
            return model.cellHeight
        }
        var height: CGFloat = 0
        height += kChatInfoLabelMarginTop + kChatInfoLabelMarginTop
        let stringHeight: CGFloat = model.content.heightWithConstrainedWidth(kChatInfoLabelMaxWdith, font: kChatInfoFont)
        height += stringHeight + kChatInfoLabelPaddingTop * 2
        model.cellHeight = height
        return model.cellHeight
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
