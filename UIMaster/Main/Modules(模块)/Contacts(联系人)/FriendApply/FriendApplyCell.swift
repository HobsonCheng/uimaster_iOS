//
//  FriendApplyCell.swift
//  UIMaster
//
//  Created by hobson on 2018/10/16.
//  Copyright © 2018 one2much. All rights reserved.
//

import RxSwift
import UIKit

protocol FriendApplyCellDelegate: AnyObject {
    func agreeApply(cell: FriendApplyCell)
}

class FriendApplyCell: UITableViewCell {
    @IBOutlet weak var agreeBtn: UIButton!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    weak var delegate: FriendApplyCellDelegate?

    var model: UserInfoData? {
        didSet {
            self.nickNameLabel.text = model?.zh_name
            self.iconImageView.kf.setImage(with: URL(string: model?.head_portrait ?? ""), placeholder: R.image.defaultPortrait(), options: nil, progressBlock: nil, completionHandler: nil)
            self.timeLabel.text = model?.add_time
            self.detailLabel.text = model?.signature ??? "暂无简介"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        //头像
        iconImageView.cornerRadius = 5
        iconImageView.maskToBounds = true
        //回复按钮
        agreeBtn.cornerRadius = 5
        agreeBtn.bordersColor = UIColor(hexString: "#777777")
        agreeBtn.bordersWidth = 1
        agreeBtn.maskToBounds = true
        iconImageView.rx
            .tapGesture()
            .subscribe(onNext: { [weak self] _ in
                guard let safeModel = self?.model else {
                    return
                }
                PageRouter.shared.router(to: PageRouter.RouterPageType.personalCenter(model: safeModel))
            })
            .disposed(by: rx.disposeBag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func agreeApply(_ sender: Any) {
        self.delegate?.agreeApply(cell: self)
    }
}
