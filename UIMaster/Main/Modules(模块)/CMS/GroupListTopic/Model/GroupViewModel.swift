//
//  GroupViewModel.swift
//  UIMaster
//
//  Created by hobson on 2018/8/15.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Differentiator
import RxSwift
import UIKit

class GroupTopicViewModel {
    var groupList = Variable([SectionModel<String, GroupData>]())
//    
//    func getGroupData(params: NSMutableDictionary, callback: @escaping ()->Void) {
//        
//        ApiUtil.share.getGroupByModel(params: params) { [weak self] (status, data, msg) in
//            if status == ResponseStatus.success{
//                let pageNum = params["page_index"] as? Int
//                var datalist = [GroupData]()
//                let tmpList = GroupModel.deserialize(from: data)?.data
//                guard let safeTmpList = tmpList else{
//                    return
//                }
//                if pageNum == 1 {
//                    datalist = safeTmpList
//                } else if tmpList?.count > 0{
//                    datalist = groupList.value + safeTmpList
//                }
//                let section = [SectionModel(model: "", items: datalist)]
//                self?.groupList.value = section
//                callback()
//            }else{
//                HUDUtil.msg(msg: msg ?? "请求失败", type: .error)
//            }
//        }
//    }
//    func getMyGroupList(params: NSMutableDictionary, callback: @escaping ()->Void) {
//        ApiUtil.share.getMyGroupList(params: params) { [weak self] (status, data, msg) in
//            //停止刷新
//            if let safeCB = self?.checkRefreshCB{
//                safeCB()
//            }
//            self?.activityView.stopAnimating()
//            
//        }
//    }
}
