//
//  ChatGroupButtonCell.swift
//  UIMaster
//
//  Created by hobson on 2018/10/21.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit

@objc public protocol ChatGroupButtonCellDelegate: NSObjectProtocol {
    func buttonCell(clickButton button: UIButton)
}

class ChatGroupButtonCell: UITableViewCell {
    open weak var delegate: ChatGroupButtonCellDelegate?

    var buttonTitle: String {
        get {
            return (button.titleLabel?.text)!
        }
        set {
            button.setTitle(newValue, for: .normal)
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
    }

    private lazy var button: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(clickBtn(_:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = .red
        button.setTitle("退出登录", for: .normal)
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true

        return button
    }()

    // MARK: - private func
    private func setupUI() {
        backgroundColor = .clear

        contentView.addSubview(button)

        button.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-25)
            make.top.bottom.equalToSuperview()
        }
    }

    // MARK: - click func
    @objc func clickBtn(_ sender: UIButton) {
        delegate?.buttonCell(clickButton: sender)
    }
}
