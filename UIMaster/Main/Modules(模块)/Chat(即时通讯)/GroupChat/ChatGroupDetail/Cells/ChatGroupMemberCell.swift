//
//  ChatGroupMemberCell.swift
//  UIMaster
//
//  Created by hobson on 2018/10/22.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit

class ChatGroupMemberCell: UICollectionViewCell {
    var avatar: UIImage? {
        get {
            return avatarView.image
        }
        set {
            nickname.text = ""
            avatarView.image = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    var userInfo: UserInfoData? {
        didSet {
            nickname.text = userInfo?.zh_name
            self.avatarView.kf.setImage(with: URL(string: userInfo?.head_portrait ?? ""), placeholder: R.image.defaultPortrait(), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    private var avatarView = UIImageView()
    private var nickname = UILabel()
    private lazy var userDefaultIcon = R.image.defaultPortrait()

    private func setupUI() {
        nickname.font = UIFont.systemFont(ofSize: 14)
        nickname.textColor = UIColor(red: 17, green: 17, blue: 17)
        nickname.textAlignment = .center
        avatarView.layer.cornerRadius = 5
        avatarView.layer.masksToBounds = true
        addSubview(avatarView)
        addSubview(nickname)

        avatarView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-10)
            make.width.height.equalTo(50)
            make.centerX.equalToSuperview()
        }

        nickname.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(15)
            make.top.equalTo(avatarView.snp.bottom).offset(5)
        }
    }
}
