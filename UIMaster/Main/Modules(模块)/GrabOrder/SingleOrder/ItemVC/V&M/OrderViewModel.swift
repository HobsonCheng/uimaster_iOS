////
////  OrderViewModel.swift
////  UIDS
////
////  Created by one2much on 2018/1/26.
////  Copyright © 2018年 one2much. All rights reserved.
////
//
//import Foundation
//import RxSwift
//import RxDataSources
//
//public enum OrderViewModelType {
//    case grap                             // 抢单
//    case oning                             // 正在进行
//    case over                          // 完成
//}
//
//class OrderViewModel: NSObject {
//
//    //创建监听对象
//    var orderList = Variable([SectionModel<String, OrderCData>]())
//
//    func getGarp(params: NSMutableDictionary, callback: @escaping ()->Void) {
//    
//        let paramsAll = NSMutableDictionary()
//        paramsAll.setObject("1", forKey: "page" as NSCopying)
//        paramsAll.setObject("30", forKey: "page_context" as NSCopying)
//        ApiUtil.share.getWaitSubscribeList(params: paramsAll) {[weak self] (_, data, _) in
//
//            let datalist  = OrderCModel.deserialize(from: data)?.data
//
//            let section = [SectionModel(model: "", items: datalist!)]
//
//            self?.orderList.value = section
//
//            callback()
//        }
//    }
//
//    func getOrderList(params: NSMutableDictionary, callback: @escaping ()->Void) {
//        ApiUtil.share.getUserFormList(params: params) {[weak self] (_, data, _) in
//            let datalist  = OrderCModel.deserialize(from: data)?.data
//            if datalist == nil || datalist?.count == 0 {
//                return
//            }
//            let section = [SectionModel(model: "", items: datalist!)]
//
//            self?.orderList.value = section
//
//            callback()
//        }
////        ApiUtil.share.getUserSubscribeList(params: params) {[weak self] (status, data, msg) in
////
////            let datalist  = OrderCModel.deserialize(from: data)?.data
////
////            let section = [SectionModel(model: "", items: datalist!)]
////
////            self?.orderList.value = section
////
////            callback()
////
////        }
//    }
//}
