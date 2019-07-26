//
//  addFriendCell.swift
//  UIMaster
//
//  Created by hobson on 2018/7/26.
//  Copyright © 2018年 one2much. All rights reserved.
//

import RxSwift
import UIKit

class AddFriendCell: UITableViewCell {
    //    @IBOutlet weak var unapplyBtn: UIButton!
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var headName: UILabel!
    @IBOutlet weak var headImgPic: UIImageView!
    /// cell的间距
    var spacing: CGFloat = 0
    var cellModel: MessageData? {
        didSet {
            timeLabel.text = cellModel?.update_time?.getTimeTip()
            let userId = cellModel?.sender ?? 0
            let userPid = cellModel?.sender_pid ?? 0
            NetworkUtil.request(
                target: .getInfo(user_id: userId, user_pid: userPid),
                success: { json in
                    let userInfo = UserInfoModel.deserialize(from: json)?.data
                    DispatchQueue.main.async {
                        self.headName.text = userInfo?.zh_name
                        self.headImgPic.kf.setImage(with: URL(string: userInfo?.head_portrait ?? ""), placeholder: R.image.defaultPortrait(), options: nil, progressBlock: nil, completionHandler: nil)
                        if userInfo?.is_friend == 1 {
                            self.applyBtn.backgroundColor = .clear
                            self.applyBtn.layer.borderWidth = 1
                            self.applyBtn.layer.borderColor = UIColor.black.cgColor
                            self.applyBtn.layer.cornerRadius = 5
                            self.applyBtn.setTitle("已添加", for: .normal)
                            self.applyBtn.setTitleColor(.black, for: .normal)
                            self.applyBtn.isEnabled = false
                        }
                    }
                }
            ) { error in
                dPrint(error)
            }
        }
    }
    var addTime: String? {
        didSet {
            timeLabel.text = addTime?.getTimeTip()
        }
    }
    var friendInfo: UserInfoData? {
        didSet {
            self.headName.text = friendInfo?.zh_name
            self.headImgPic.kf.setImage(with: URL(string: friendInfo?.head_portrait ?? ""), placeholder: R.image.defaultPortrait(), options: nil, progressBlock: nil, completionHandler: nil)
            if friendInfo?.is_friend == 1 {
                self.applyBtn.backgroundColor = .clear
                self.applyBtn.layer.borderWidth = 1
                self.applyBtn.layer.borderColor = UIColor.black.cgColor
                self.applyBtn.setTitle("已添加", for: .normal)
                self.applyBtn.setTitleColor(.black, for: .normal)
                self.applyBtn.isEnabled = false
            }
        }
    }

    deinit {
        dPrint("cell 被销毁了")
    }

    override var frame: CGRect {
        didSet {
            var newFrame = frame
            newFrame.origin.y += spacing
            newFrame.size.height -= spacing
            super.frame = newFrame
        }
    }

    @IBAction func agreeClick(_ sender: Any) {
        var uid: Int64 = 0
        var pid: Int64 = 0
        if let userInfo = friendInfo {
            uid = userInfo.uid ?? 0
            pid = userInfo.pid ?? 0
        }
        if let model = cellModel {
            uid = model.sender ?? 0
            pid = model.sender_pid ?? 0
        }
        NetworkUtil.request(
            target: .agreeFriend(friend_uid: uid, friend_pid: pid),
            success: { _ in
                DispatchQueue.main.async {
                    self.applyBtn.backgroundColor = .clear
                    self.applyBtn.layer.borderWidth = 1
                    self.applyBtn.layer.borderColor = UIColor.black.cgColor
                    self.applyBtn.setTitle("已添加", for: .normal)
                    self.applyBtn.setTitleColor(.black, for: .normal)
                    self.applyBtn.isEnabled = false
                }
                HUDUtil.msg(msg: "添加成功", type: .successful)
            }
        ) { error in
            dPrint(error)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
//        unapplyBtn.layer.borderWidth = 1
//        unapplyBtn.layer.borderColor = UIColor.black.cgColor
//        unapplyBtn.layer.cornerRadius = 5
//        unapplyBtn.layer.masksToBounds = true
        applyBtn.layer.cornerRadius = 5
        applyBtn.layer.masksToBounds = true
        headImgPic.layer.cornerRadius = 20
        headImgPic.layer.masksToBounds = true
        self.selectionStyle = .none
        headImgPic.rx.tapGesture()
            .subscribe(onNext: { [weak self] _ in
                guard let safeInfo = self?.friendInfo else {
                    return
                }
                PageRouter.shared.router(to: PageRouter.RouterPageType.personalCenter(model: safeInfo))
            })
            .disposed(by: rx.disposeBag)
        self.bottomLine(style: .full, color: UIColor(hexString: "#cccccc"))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
