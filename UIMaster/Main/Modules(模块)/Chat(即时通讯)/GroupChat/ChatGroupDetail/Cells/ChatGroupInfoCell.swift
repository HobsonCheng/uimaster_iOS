//
//  ChatGroupInfoCell.swift
//  UIMaster
//
//  Created by hobson on 2018/10/21.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit

@objc public protocol ChatGroupInfoCellDelegate: NSObjectProtocol {
    func chatGroupInfoCell(clickSwitchButton button: UISwitch, indexPath: IndexPath?)
}

class ChatGroupInfoCell: UITableViewCell {
    weak var delegate: ChatGroupInfoCellDelegate?
    var indexPate: IndexPath?

    var title: String {
        get {
            return titleLabel.text ?? ""
        }
        set {
            return titleLabel.text = newValue
        }
    }

    var detail: String? {
        get {
            return detailLabel.text
        }
        set {
            detailLabel.isHidden = false
            detailLabel.text = newValue
        }
    }

    var isShowSwitch: Bool {
        get {
            return !switchButton.isHidden
        }
        set {
            switchButton.isHidden = !newValue
        }
    }

    var isSwitchOn: Bool {
        get {
            return switchButton.isOn
        }
        set {
            switchButton.isOn = newValue
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

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.textColor = UIColor(red: 17, green: 17, blue: 17)
        titleLabel.backgroundColor = .white
        titleLabel.layer.masksToBounds = true
        return titleLabel
    }()
    private lazy var switchButton: UISwitch = {
        let switchButton = UISwitch()
        switchButton.isHidden = true
        switchButton.addTarget(self, action: #selector(clickSwitch(_:)), for: .valueChanged)
        return switchButton
    }()

    private lazy var detailLabel: UILabel = {
        let detailLabel = UILabel()
        detailLabel.textAlignment = .right
        detailLabel.font = UIFont.systemFont(ofSize: 15)
        detailLabel.textColor = UIColor(red: 164, green: 164, blue: 164)
        detailLabel.isHidden = true
        detailLabel.backgroundColor = .white
        detailLabel.layer.masksToBounds = true
        return detailLabel
    }()

    // MARK: - private func
    private func setupUI() {
        contentView.addSubview(switchButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(contentView.snp.centerX)
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(22.5)
        }
        detailLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(titleLabel.snp.right)
            make.right.equalTo(contentView.snp.right).offset(-10)
            make.height.equalToSuperview()
        }

        switchButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
    }

    @objc func clickSwitch(_ sender: UISwitch) {
        delegate?.chatGroupInfoCell(clickSwitchButton: sender, indexPath: indexPate)
    }
}
