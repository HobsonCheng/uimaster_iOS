//
//  ChatChatGroupAvatorCell.swift
//  UIMaster
//
//  Created by hobson on 2018/10/21.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit

class ChatGroupAvatarCell: UITableViewCell {
    private lazy var titleLabel = UILabel()
    private lazy var avatarView = UIImageView()
    var title: String {
        get {
            return self.titleLabel.text!
        }
        set {
            return self.titleLabel.text = newValue
        }
    }

    var avatar: UIImage? {
        get {
            return avatarView.image
        }
        set {
            avatarView.image = newValue
        }
    }
    var avatarUrlStr: String? {
        didSet {
            avatarView.kf.setImage(with: URL(string: avatarUrlStr ?? ""))
        }
    }
    var model: UserInfoData? {
        didSet {
            self.avatarView.kf.setImage(with: URL(string: model?.head_portrait ?? ""), placeholder: R.image.defaultPortrait(), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    // MARK: - private func
    private func setupUI() {
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.textColor = UIColor(red: 17, green: 17, blue: 17)
        self.bottomLine(style: .leftGap(margin: 10), color: .lightGray)
        avatarView.contentMode = .scaleAspectFill
        avatarView.image = R.image.defaultPortrait()
        avatarView.clipsToBounds = true

        contentView.addSubview(avatarView)
        contentView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(contentView.snp.centerX)
            make.centerY.equalToSuperview()
            make.height.equalTo(22.5)
        }

        avatarView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(36)
        }
    }
}
