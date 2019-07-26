//
//  MessageCell.swift
//  UIMaster
//
//  Created by YJHobson on 2018/7/16.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Kingfisher
import UIKit
import YYText

class MessageCell: UITableViewCell {
    @IBOutlet weak var headerAllView: UIView!
    @IBOutlet weak var replyText: UITextField!
    @IBOutlet weak var titleLabel: YYLabel!
    @IBOutlet weak var articleImg: UIImageView!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var btnReply: UIButton!
    @IBOutlet weak var messageTime: UILabel!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var headImg: UIImageView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var gapConstraint: NSLayoutConstraint!
    var spacing: CGFloat = 0
    var events: [String: EventsData]?
    var topicModel: TopicData? {
        didSet {
            comment.text = topicModel?.content
            let title = topicModel?.invitation?.title
            let ownerName = topicModel?.invitation?.user_info?.zh_name ?? ""
            if !ownerName.isEmpty {
                let titleText = ownerName + "：" + (title ?? "")
                let attText = NSMutableAttributedString(string: titleText)
                setHighlightText(attText: attText, range: NSRange(location: 0, length: ownerName.count + 1), uid: topicModel?.invitation?.user_info?.uid, pid: topicModel?.invitation?.user_info?.pid)
                titleLabel.attributedText = attText
            } else {
                titleLabel.text = title
            }

            let imgArr = topicModel?.invitation?.attachment_value.split(separator: ",")
            if !(imgArr?.isEmpty ?? true) {
                articleImg.isHidden = false
                articleImg.kf.setImage(with: URL(string: String(imgArr?[0] ?? "")), placeholder: UIImage(named: "placeholder.png"), options: nil, progressBlock: nil, completionHandler: nil)
                gapConstraint.constant = 5
            } else {
                articleImg.isHidden = true
                gapConstraint.constant = -50
            }
            messageTime.text = topicModel?.add_time?.getTimeTip()
            nickName.text = topicModel?.user_info?.zh_name
            if topicModel?.user_info?.admin != 0 {
                headImg.kf.setImage(with: URL(string: topicModel?.user_info?.head_portrait ?? ""), placeholder: UIImage(named: "admin.png"), options: nil, progressBlock: nil, completionHandler: nil)
            } else {
                headImg.kf.setImage(with: URL(string: topicModel?.user_info?.head_portrait ?? ""), placeholder: UIImage(named: "defaultPortrait.png"), options: nil, progressBlock: nil, completionHandler: nil)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        headImg.layer.cornerRadius = headImg.height / 2
        headImg.layer.masksToBounds = true
        detailView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showArticleDetail)))
        headImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gotoPersonalCenter)))
    }

    @objc func showArticleDetail() {
        if self.topicModel?.invitation?.id == 0 {
            return
        }
        if let articleEvent = events?[kArticleEvent], let invitation = self.topicModel?.invitation {
            articleEvent.attachment = [TopicData.getClassName: invitation]
            let result = EventUtil.handleEvents(event: articleEvent)
            EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @objc func gotoPersonalCenter() {
        guard let userInfo = self.topicModel?.user_info else {
            return
        }
        let event = self.events?[kHeadEvent]
        event?.attachment = [UserInfoData.getClassName: userInfo]
        let result = EventUtil.handleEvents(event: event)
        EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
    }
    /// 设置高亮的用户名，用于跳转到个人中心
    ///
    /// - Parameters:
    ///   - range: 名字的范围
    ///   - uid: 用户的uid
    ///   - pid: 用户的pid
    ///   - attText: 富文本
    func setHighlightText(attText: NSMutableAttributedString, range: NSRange, uid: Int64?, pid: Int64?) {
        attText.yy_setTextHighlight(range, color: UIColor.blue, backgroundColor: nil) { [weak self] _, _, _, _ in
            let event = self?.events?[kHeadEvent]

            event?.attachment = ["PCTuple": (uid, pid)]
            let result = EventUtil.handleEvents(event: event)
            EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
        }
    }

    override var frame: CGRect {
        didSet {
            var newFrame = frame
            //            newFrame.origin.x += spacing/2
            //            newFrame.size.width -= spacing
            newFrame.origin.y += spacing
            newFrame.size.height -= spacing
            super.frame = newFrame
        }
    }
}
