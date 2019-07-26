//
//  ChatBaseCell.swift
//  TSWeChat
//
//  Created by Hilen on 1/11/16.
//  Copyright © 2016 Hilen. All rights reserved.
//

import RxSwift
import SnapKit
import UIKit

//import RxBlocking

private let kChatNicknameLabelHeight: CGFloat = 20  //昵称 label 的高度
let kChatAvatarMarginLeft: CGFloat = 10             //头像的 margin left
let kChatAvatarMarginTop: CGFloat = 0               //头像的 margin top
let kChatAvatarWidth: CGFloat = 40                  //头像的宽度

class ChatBaseCell: UITableViewCell {
    weak var delegate: ChatCellDelegate?

    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.backgroundColor = UIColor.clear
            avatarImageView.width = kChatAvatarWidth
            avatarImageView.height = kChatAvatarWidth
        }
    }
    @IBOutlet weak var nicknameLabel: UILabel! {
        didSet {
            nicknameLabel.font = UIFont.systemFont(ofSize: 11)
            nicknameLabel.textColor = UIColor.darkGray
        }
    }
    var model: ChatMessageModel?
    let disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        self.avatarImageView.image = nil
        self.nicknameLabel.text = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear

        //头像点击
        let tap = UITapGestureRecognizer()
        self.avatarImageView.addGestureRecognizer(tap)
        self.avatarImageView.isUserInteractionEnabled = true
        tap.rx.event
            .subscribe { [weak self] _ in
                if let strongSelf = self {
                    guard let delegate = strongSelf.delegate else {
                        return
                    }
                    delegate.cellDidTapedAvatarImage(strongSelf)
                }
            }
            .disposed(by: self.disposeBag)
    }

    func setCellContent(_ model: ChatMessageModel) {
        self.model = model
        if model.fromMe {
            let avatarURL = UserUtil.share.appUserInfo?.head_portrait ?? ""
            self.avatarImageView.kf.setImage(with: URL(string: avatarURL), placeholder: R.image.defaultPortrait(), options: nil, progressBlock: nil, completionHandler: nil)
        } else {
            let avatarURL = self.model?.avatar ?? ""
            self.avatarImageView.kf.setImage(with: URL(string: avatarURL), placeholder: R.image.defaultPortrait(), options: nil, progressBlock: nil, completionHandler: nil)
        }

        self.setNeedsLayout()
    }

    override func layoutSubviews() {
        guard let model = self.model else {
            return
        }
        if model.fromMe {
            self.nicknameLabel.height = 0
            self.avatarImageView.left = kScreenW - kChatAvatarMarginLeft - kChatAvatarWidth
        } else {
            self.nicknameLabel.text = model.nickname
            self.nicknameLabel.height = model.chat_type == 0 ? 0 : 15
            self.avatarImageView.left = kChatAvatarMarginLeft
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
