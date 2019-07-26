//
//  orderTwoCell.swift
//  UIDS
//
//  Created by bai on 2018/1/28.
//  Copyright © 2018年 one2much. All rights reserved.
//

import NSObject_Rx
import RxCocoa
import RxSwift
import SwiftyJSON
import UIKit

class OrderTwoCell: UITableViewCell {
    @IBOutlet weak var eventbt: UIButton!
    @IBOutlet weak var fromName: UILabel!
    @IBOutlet weak var iconButton: UIButton!

    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var userName: UILabel!

    @IBOutlet weak var platForm: UILabel!
    @IBOutlet weak var addtime: UILabel!

    var cellData: OrderCData? {
        didSet {
            if cellData != nil {
                let getStr = JSON(parseJSON: (cellData?.value)!).rawString()?.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "").replacingOccurrences(of: "\"", with: "")
                fromName.text = cellData?.classify_name
                content.text = getStr

                addtime.text = cellData?.add_time
                iconButton.kf.setImage(with: URL(string: cellData?.order_header ?? ""), for: .normal)
                userName.text = cellData?.order_nickname
                platForm.text = "来自：\(cellData?.platform_name ?? "UI大师")"
                if cellData?.form_status == 2 {
                    eventbt.setTitle("已完成", for: UIControlState.normal)
                    eventbt.backgroundColor = UIColor(hexString: "#007dff")
                } else if cellData?.form_status == 3 {
                    eventbt.setTitle("已取消", for: UIControlState.normal)
                    eventbt.backgroundColor = .gray
                } else if cellData?.form_status == 4 {
                    eventbt.setTitle("已取消", for: .normal)
                    eventbt.backgroundColor = .gray
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.iconButton.layer.cornerRadius = 20
        self.iconButton.layer.masksToBounds = true

        self.eventbt.layer.cornerRadius = 6
        self.eventbt.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func gotoPersonalCenter(_ sender: Any) {
//        let getPage = OpenVC.share.getPageKey(pageType: PAGE_TYPE_PersonInfo, actionType: "PersonInfo")
//        let user = UserInfoData()
//        user.uid = self.cellData?.order_uid
//        user.pid = self.cellData?.order_pid
//        getPage?.fields?.tempData = user
//        if (getPage != nil) {
//            //TODO: 跳转
////            OpenVC.share.goToPage(pageType: (getPage?.page_type)!, pageInfo: getPage)
//        }
    }
}
