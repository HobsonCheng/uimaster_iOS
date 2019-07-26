//
//  GroupCell.swift
//  UIDS
//
//  Created by bai on 2018/1/20.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!

    @IBOutlet weak var line: UILabel!
    @IBOutlet weak var groupInfo: UILabel!
    @IBOutlet weak var groupName: UILabel!
    var cellObj: GroupData?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func layoutSubviews() {
        if self.cellObj?.index_pic == "" || self.cellObj?.index_pic == nil {
            self.icon.image = UIImage(named: "groupHead")
            self.icon.backgroundColor = .clear
        } else {
            self.icon.kf.setImage(with: URL(string: cellObj?.index_pic ?? ""), placeholder: UIImage(named: "groupHead"), options: nil, progressBlock: nil, completionHandler: nil)
            self.icon.backgroundColor = .clear
        }
        if self.cellObj?.introduction == "" || self.cellObj?.introduction == nil {
            self.groupInfo.text = "群组简介 暂无"
        } else {
            self.groupInfo.text = self.cellObj?.introduction
        }
        if self.cellObj?.name == "" || self.cellObj?.name == nil {
            self.groupName.text = "暂无标题"
        } else {
            self.groupName.text = self.cellObj?.name
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func showData() {
        if self.cellObj != nil {
            self.icon.image = UIImage(named: "2.png")
            self.icon.layer.cornerRadius = 4
            self.icon.layer.masksToBounds = true
            self.icon.layer.borderColor = UIColor.lightGray.cgColor
            self.icon.layer.borderWidth = 0.5
            self.groupName.text = self.cellObj?.name
//            self.creatTime.text = String.init(format: "创建时间：%@", (self.cellObj?.add_time)!)
//            self.topicNum.text = String.init(format: "帖子%zd", (self.cellObj?.invitation_num ?? 0)!)

        }
    }

    private func touchcell() {
//        let getPage = OpenVC.share.getPageKey(pageType: PAGE_TYPE_TopicList, actionType: PAGE_TYPE_TopicList)
//        getPage?.fields?.tempData = self.cellObj
//        if (getPage != nil) {
//            //TODO: 跳转
//            //            OpenVC.share.goToPage(pageType: (getPage?.page_type)!, pageInfo: getPage)
//        }
    }

    private func addNewButton() {
//        cellButton = UIButton().then({
//            $0.backgroundColor = UIColor.clear
//            $0.rx.tap.do(onNext: { [weak self] _ in
//                self?.touchcell()
//            }).subscribe().disposed(by: rx.disposeBag)
//            $0.frame = CGRect.init(x: 0, y: 0, width: kScreenW, height: self.height)
//        })
//
//        self.addSubview(cellButton!)

    }
}
