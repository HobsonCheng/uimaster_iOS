//
//  JFCommentCell.swift
//  UIDS
//
//  Created by bai on 16/5/18.
//  Copyright © 2016年 bai. All rights reserved.
//

import UIKit

protocol JFCommentCellDelegate: AnyObject {
    func didTappedStarButton(_ button: UIButton, commentModel: ReplyData)
}

class JFCommentCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    //    @IBOutlet weak var starButton: UIButton!
    //    @IBOutlet weak var commentButton: UIButton!
    var delegate: JFCommentCellDelegate?

    var commentModel: ReplyData? {
        didSet {
            guard commentModel != nil else { return }
            avatarImageView.kf.setImage(with: URL(string: commentModel?.user_info.head_portrait ?? "commentModel.userpic!"), placeholder: UIImage(named: "default－portrait.png"), options: nil, progressBlock: nil, completionHandler: nil)
            usernameLabel.text = commentModel?.user_info.zh_name
            timeLabel.text = commentModel?.add_time
            contentLabel.text = commentModel?.content
            //            starButton.setTitle("\(10)", for: UIControlState())
        }
    }

    func getCellHeight(_ commentModel: ReplyData) -> CGFloat {
        self.commentModel = commentModel
        layoutIfNeeded()
        return contentLabel.frame.maxY + 10
    }

    /**
     点击了赞
     */
    @IBAction func didTappedStarButton(_ sender: UIButton) {
        delegate?.didTappedStarButton(sender, commentModel: commentModel!)
    }
}
