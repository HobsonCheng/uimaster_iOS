////
////  GrapCell.swift
////  UIDS
////
////  Created by one2much on 2018/1/25.
////  Copyright © 2018年 one2much. All rights reserved.
////
//
import UIKit
//import SwiftyJSON
//import RxCocoa
//import RxSwift
//import NSObject_Rx
//
class GrapCell: UITableViewCell {
//
//    @IBOutlet weak var content: UILabel!
//    @IBOutlet weak var eventbt: UIButton!
//    @IBOutlet weak var fromName: UILabel!
//    @IBOutlet weak var iconButton: UIButton!
//
//    @IBOutlet weak var platForm: UILabel!
//    @IBOutlet weak var userName: UILabel!
//
//    @IBOutlet weak var addtime: UILabel!
//    var dispose: Disposable?
//
//    var cellData: OrderCData? {
//        didSet {
//            if cellData != nil {
//
//                let getStr = JSON.init(parseJSON: (cellData?.value)!).rawString()?.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "").replacingOccurrences(of: "\"", with: "")
//                content.text = getStr
//                userName.text = cellData?.user_name
//                platForm.text = "来自：\(cellData?.platform_name ?? "未知")"
//                fromName.text = cellData?.classify_name
//                iconButton.kf.setImage(with: URL.init(string: cellData?.head_portrait ?? ""), for: .normal)
//                addtime.text = cellData?.add_time
//
//                changebtnTitle(itemData: cellData!)
//            }
//        }
//    }
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//
//        self.iconButton.layer.cornerRadius = 20
//        self.iconButton.layer.masksToBounds = true
//
//        self.eventbt.layer.cornerRadius = 6
//        self.eventbt.layer.masksToBounds = true
//        self.eventbt.setTitle("等待接单", for: .normal)
//
//    }
//    //根据订单状态切换Title
//    func changebtnTitle(itemData: OrderCData) {
//        let status = itemData.form_status
//        if status == 0 {
//            self.isUserInteractionEnabled = true
//            let userInfo = UserUtil.share.appUserInfo
//            if itemData.platform_uid == userInfo?.uid {
//                dispose?.dispose()
//                self.eventbt.setTitle("取消订单", for: .normal)
//                dispose = self.eventbt.rx.tap.do(onNext: { [weak self] in
//                    let vc = UIAlertController(title: "确定取消订单？", message: nil, preferredStyle: .alert)
//                    let action = UIAlertAction.init(title: "确定", style: .destructive, handler: { (_) in
//                        let params = NSMutableDictionary()
//                        params.setObject(self?.cellData?.id ?? "", forKey: "form_id" as NSCopying)
//                        params.setObject(self?.cellData?.pid ?? "", forKey: "form_pid" as NSCopying)
//
//                        ApiUtil.share.cancelSubscribe(params: params, finish: { (_, _, msg) in
//                            HUDUtil.msg(msg: "已取消", type: .successful)
//                        })
////                        if let messagePool = self?.superview as? MessagePool {
////                            _ = messagePool.reloadViewData()
////                            messagePool.reloadOver!()
////                        }
//                        if let table = self?.superview as? UITableView {
//                            table.mj_header.beginRefreshing()
//                        }
//
//                    })
//                    let action2 = UIAlertAction.init(title: "点错了", style: .cancel, handler: nil)
//                    vc.addAction(action)
//                    vc.addAction(action2)
//                    VCController.getTopVC()?.present(vc, animated: true, completion: nil)
//                }).subscribe()
//            } else {
//                dispose?.dispose()
//                self.eventbt.setTitle("处理订单", for: .normal)
//
//                dispose =  self.eventbt.rx.tap.do(onNext: {[weak self] in //触发点击抢单
//
//                    let params = NSMutableDictionary()
//                    params.setObject(self?.cellData?.id ?? "", forKey: "form_id" as NSCopying)
//                    params.setObject(self?.cellData?.pid ?? "", forKey: "form_pid" as NSCopying)
//
//                    ApiUtil.share.orderSubscribe(params: params, fininsh: { (_, _, msg) in
//                        HUDUtil.msg(msg: "抢单成功", type: .successful)
//                        if let table = self?.superview as? UITableView {
//                            table.mj_header.beginRefreshing()
//                        }
////                        if let messagePool = self?.superview as? MessagePool {
////                            _ = messagePool.reloadViewData()
////                            messagePool.reloadOver!()
////                        }
//                    })
//
//                }).subscribe()
//            }
//        } else if status == 1 {
//            self.eventbt.setTitle("点击完成", for: .normal)
//            self.eventbt.backgroundColor = UIColor.init(hexString: "#FC614C")
//            dispose?.dispose()
//            dispose =  self.eventbt.rx.tap.do(onNext: {[weak self] in //触发完成
//                let vc = UIAlertController(title: "完成订单？", message: nil, preferredStyle: .alert)
//                let action = UIAlertAction.init(title: "确定", style: .destructive, handler: { (_) in
//                    let params = NSMutableDictionary()
//                    params.setValue(self?.cellData?.order_id ?? "", forKey: "order_id")
//
//                    ApiUtil.share.confirmSubscribe(params: params, fininsh: { (_, _, msg) in
//
//                        HUDUtil.msg(msg: "订单完成", type: .successful)
//                        if let table = self?.superview as? UITableView {
//                            table.mj_header.beginRefreshing()
//                        }
////                        if let messagePool = self?.superview as? MessagePool {
////                            _ = messagePool.reloadViewData()
////                            messagePool.reloadOver!()
////                        }
//                    })
//                })
//                let action2 = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
//                vc.addAction(action)
//                vc.addAction(action2)
//                VCController.getTopVC()?.present(vc, animated: true, completion: nil)
//            }).subscribe()
//        } else if status == 2 {
//            self.eventbt.setTitle("已完成 ✓", for: .normal)
//            self.eventbt.backgroundColor = UIColor.init(hexString: "#5A5A5A")
//        } else if status == 3 {
//            self.eventbt.setTitle("已取消 ✕", for: .normal)
//            self.eventbt.backgroundColor = UIColor.init(hexString: "#C1C1C1")
//        } else {
//            self.eventbt.setTitle("处理订单", for: .normal)
//        }
//
//    }
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//    @IBAction func goPersonCenter(_ sender: UIButton) {
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
