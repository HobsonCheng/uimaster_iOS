////
////  orderCell.swift
////  UIDS
////
////  Created by bai on 2018/1/28.
////  Copyright © 2018年 one2much. All rights reserved.
////
//
import UIKit
//import SwiftyJSON
//import RxCocoa
//import RxSwift
//import NSObject_Rx
//
//class EventData {
//
//    var eventType: Int? = -1
//    var cellObj: OrderCData?
//
//    init() {
//
//    }
//}
//
class OrderCell: UITableViewCell {
//
//    @IBOutlet weak var overButton: UIButton!
//    @IBOutlet weak var content: UILabel!
//    @IBOutlet weak var fromName: UILabel!
//    @IBOutlet weak var iconButton: UIButton!
//    @IBOutlet weak var cancelButton: UIButton!
//    @IBOutlet weak var bottomIcon: UIButton!
//    @IBOutlet weak var platformLable: UILabel!
//    @IBOutlet weak var userName: UILabel!
//    @IBOutlet weak var orderDeal: UILabel!
//    @IBOutlet weak var addtime: UILabel!
//
//    var changeEvent = Variable(EventData())
//
//    var cellData: OrderCData? {
//        didSet {
//            if cellData != nil {
//                let getStr = JSON.init(parseJSON: (cellData?.value)!).rawString()?.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "").replacingOccurrences(of: "\"", with: "")
//                content.text = getStr
//                fromName.text = cellData?.classify_name
//                addtime.text = cellData?.add_time
//                platformLable.text = "来自：\(cellData?.platform_name ?? "未知")"
//                iconButton.kf.setImage(with: URL.init(string: cellData?.head_portrait ?? ""), for: .normal)
//                bottomIcon.kf.setImage(with: URL.init(string: cellData?.order_header ?? ""), for: .normal)
//                orderDeal.text = "\(cellData?.order_nickname ?? "未知")正在处理订单"
//                userName.text = cellData?.user_name
//            }
//            changeButtonStatus()
//        }
//    }
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        self.iconButton.layer.cornerRadius = 20
//        self.iconButton.layer.masksToBounds = true
//
//        self.overButton.layer.cornerRadius = 6
//        self.overButton.layer.masksToBounds = true
//
//        self.cancelButton.layer.cornerRadius = 6
//        self.cancelButton.layer.masksToBounds = true
//
//        self.bottomIcon.layer.cornerRadius = 10
//        self.bottomIcon.layer.masksToBounds = true
//
//        self.overButton.rx.tap.do(onNext: { [weak self] in
//            let vc = UIAlertController(title: "确定取消订单？", message: nil, preferredStyle: .alert)
//            let action = UIAlertAction.init(title: "确定", style: .destructive, handler: { (_) in
//                let params = NSMutableDictionary()
//                params.setValue(self?.cellData?.order_id ?? "", forKey: "order_id")
//
//                ApiUtil.share.confirmSubscribe(params: params, fininsh: { (_, _, msg) in
//
//                    HUDUtil.msg(msg: "订单完成", type: .successful)
//
//                    let obj = EventData()
//                    obj.eventType = 1
//                    obj.cellObj = self?.cellData
//
//                    self?.changeEvent.value = obj
//
//                })
//            })
//            let action2 = UIAlertAction.init(title: "点错了", style: .cancel, handler: nil)
//            vc.addAction(action)
//            vc.addAction(action2)
//            VCController.getTopVC()?.present(vc, animated: true, completion: nil)
//        }).subscribe().disposed(by: rx.disposeBag)
//
//        self.cancelButton.rx.tap.do(onNext: { [weak self] in
//            let vc = UIAlertController(title: "确定取消订单？", message: nil, preferredStyle: .alert)
//            let action = UIAlertAction.init(title: "确定", style: .destructive, handler: { (_) in
//
//                let params = NSMutableDictionary()
//                params.setValue(self?.cellData?.order_id ?? "", forKey: "order_id")
//                params.setValue(self?.cellData?.order_pid ?? "", forKey: "form_pid")
//
//                ApiUtil.share.cancelOrderSubscribe(params: params, fininsh: { [weak self] (_, _, msg) in
//
//                    HUDUtil.msg(msg: "订单已取消", type: .info)
//
//                    let obj = EventData()
//                    obj.eventType = 2
//                    obj.cellObj = self?.cellData
//
//                    self?.changeEvent.value = obj
//
//                })
//            })
//            let action2 = UIAlertAction.init(title: "点错了", style: .cancel, handler: nil)
//            vc.addAction(action)
//            vc.addAction(action2)
//            VCController.getTopVC()?.present(vc, animated: true, completion: nil)
//        }).subscribe().disposed(by: rx.disposeBag)
//        changeButtonStatus()
//
//    }
//    func changeButtonStatus() {
//        let userInfo = UserUtil.share.appUserInfo
//        if self.cellData?.order_uid == userInfo?.uid && self.cellData?.order_pid == userInfo?.pid {
//            self.overButton.isUserInteractionEnabled = false
//            self.overButton.backgroundColor = UIColor.lightGray
//            self.cancelButton.isUserInteractionEnabled = true
//            self.cancelButton.backgroundColor =  UIColor.init(hexString: "007dff")
//        } else {
//            self.overButton.isUserInteractionEnabled = true
//            self.overButton.backgroundColor = UIColor.init(hexString: "007dff")
//            self.cancelButton.isUserInteractionEnabled = false
//            self.cancelButton.backgroundColor = UIColor.lightGray
//        }
//    }
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//
//    @IBAction func gotoDealerPC(_ sender: Any) {
////        let getPage = OpenVC.share.getPageKey(pageType: PAGE_TYPE_PersonInfo, actionType: "PersonInfo")
////        let user = UserInfoData()
////        user.uid = self.cellData?.order_uid
////        user.pid = self.cellData?.order_pid
////        getPage?.fields?.tempData = user
////        if (getPage != nil) {
////            //TODO:跳转
//////            OpenVC.share.goToPage(pageType: (getPage?.page_type)!, pageInfo: getPage)
////        }
//    }
//    @IBAction func gotosubscribePC(_ sender: Any) {
////        let getPage = OpenVC.share.getPageKey(pageType: PAGE_TYPE_PersonInfo, actionType: "PersonInfo")
////        let user = UserInfoData()
////        user.uid = self.cellData?.platform_uid
////        user.pid = self.cellData?.platform_id
////        getPage?.fields?.tempData = user
////        if (getPage != nil) {
////            //TODO:跳转
//////            OpenVC.share.goToPage(pageType: (getPage?.page_type)!, pageInfo: getPage)
////        }
//    }
}
