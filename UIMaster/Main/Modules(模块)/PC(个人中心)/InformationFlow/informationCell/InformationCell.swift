//
//  Information.swift
//  UIMaster
//
//  Created by YJHobson on 2018/7/16.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

class InformationCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userIcon: UIButton!
    @IBOutlet weak var introductLabel: UILabel!
    @IBOutlet weak var articlIcon: UIImageView!
    @IBOutlet weak var headTitle: UILabel!
    @IBOutlet weak var reportBtn: UIButton!
    @IBOutlet weak var praiseBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!

    var praiseNum = 0
    var cellModel: TopicData? {
        didSet {
            if let headTitle = self.headTitle {
                headTitle.text = cellModel?.title
            }
            if let timeLabel = self.timeLabel {
                timeLabel.text = cellModel?.add_time?.getTimeTip()
            }
            if let introductLabel = self.introductLabel {
                introductLabel.text = cellModel?.summarize
            }
            if let iconView = self.userIcon {
                iconView.kf.setImage(with: URL(string: cellModel?.user_info?.head_portrait ?? ""), for: .normal, placeholder: UIImage(named: "default－portrait"), options: nil, progressBlock: nil, completionHandler: nil)
            }

            if let nickname = self.userName {
                nickname.text = cellModel?.user_info?.zh_name
            }

            if let praiseBtn = self.praiseBtn {
                let tip = cellModel?.praise_num == 0 ? "点赞" : "\(cellModel?.praise_num ?? 0)"
                praiseBtn.setYJText(prefixText: "", icon: .praise, postfixText: " " + tip, size: 15, forState: .normal)
                praiseBtn.setYJText(prefixText: "", icon: .praised, postfixText: " " + tip, size: 15, forState: .selected)
                praiseBtn.isSelected = cellModel?.praised == 1 ? true : false
                praiseBtn.addTarget(self, action: #selector(praised), for: .touchUpInside)
                praiseNum = cellModel?.praise_num ?? 0
            }

            if let commentBtn = self.commentBtn {
                commentBtn.setYJText(prefixText: "", icon: .comment, postfixText: " 评论", size: 15, forState: .normal)
                commentBtn.addTarget(self, action: #selector(comment), for: .touchUpInside)
            }
            if let reportBtn = self.reportBtn {
                reportBtn.setYJText(prefixText: "", icon: YJType.report, postfixText: " 举报", size: 15, forState: .normal)
                reportBtn.addTarget(self, action: #selector(report), for: .touchUpInside)
            }
            if let articlIcon = self.articlIcon {
                let arr = cellModel?.attachment_value.components(separatedBy: ",")
                if (arr?.count ?? 0) < 0 {
                    return
                }
                articlIcon.kf.setImage(with: URL(string: arr?[0] ?? ""))
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// MARK: 事件处理
extension InformationCell {
    @objc func praised(_ sender: UIButton) {
        let id = cellModel?.id ?? 0
        let pid = cellModel?.group_pid ?? 0
        //发送请求记录按钮状态
        NetworkUtil.request(
            target: .praiseInvitation(praise: !sender.isSelected, group_invitation_id: id, group_pid: pid),
            success: { [weak self] _ in
                //请求成功，切换按钮状态
                DispatchQueue.main.async(execute: {
                    self?.handlePraiseBtnState()
                })
            }
        ) { error in
            dPrint(error)
        }
    }

    func handlePraiseBtnState() {
        //点击之后，选中状态置反
        let isSelected = !self.praiseBtn.isSelected
        if isSelected {
            praiseNum += 1
            self.praiseBtn.setYJText(prefixText: "", icon: .praised, postfixText: " \(praiseNum)", size: 14, forState: .selected)
        } else {
            praiseNum -= 1
            let unPraisedTip = praiseNum == 0 ? " 点赞" : " \(praiseNum)"
            self.praiseBtn.setYJText(prefixText: "", icon: .praise, postfixText: unPraisedTip, size: 14, forState: .normal)
        }
        self.praiseBtn.isSelected = isSelected
    }

    @objc func comment() {
//        if let safeDelegate = delegate{
//            safeDelegate.comment(topicData: cellModel ?? TopicData())
//        }
    }

    @objc func report() {
        let id = cellModel?.id ?? 0
        let pid = cellModel?.group_pid ?? 0
        var reason = ""
        let alertVC = UIAlertController(title: "举报", message: "请选择举报的类型", preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "侵权举报", style: .destructive, handler: { _ in
            reason = "侵权举报"
            NetworkUtil.request(
                target: .tipOffInvitation(reason: reason, group_invitation_id: id, group_pid: pid),
                success: { _ in
                    HUDUtil.msg(msg: "举报成功", type: .successful)
                }
            ) { error in
                dPrint(error)
            }
        }))
        alertVC.addAction(UIAlertAction(title: "有害信息举报", style: .destructive, handler: { _ in
            reason = "有害信息举报"
            NetworkUtil.request(
                target: .tipOffInvitation(reason: reason, group_invitation_id: id, group_pid: pid),
                success: { _ in
                    HUDUtil.msg(msg: "举报成功", type: .successful)
                }
            ) { error in
                dPrint(error)
            }
        }))
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        kWindowRootVC?.present(alertVC, animated: true, completion: nil)
    }
}
