//
//  ChatPageList+Refresh.swift
//  UIMaster
//
//  Created by hobson on 2018/9/27.
//  Copyright © 2018 one2much. All rights reserved.
//

import Foundation

import SwiftyJSON

// MARK: - @extension TSChatViewController
// 聊天测试数据 , 仅仅是测试
extension ChatPageList {
    //第一次请求的数据
    func firstFetchMessageList() {
        self.startIndex = 0
        self.fetchData(finish: { [weak self] msgArr in
            DispatchQueue.main.async {
                guard let list = msgArr else {
                    return
                }
                if list.count < self?.queryNum ?? 0 {
                    self?.listTableView.tableHeaderView = nil
                }
                self?.itemList.insert(contentsOf: list.reversed(), at: 0)
                self?.listTableView.reloadData {
                    self?.isReloading = false
                }
                guard let indexPath = self?.listTableView.lastIndexPath else {
                    return
                }
                self?.listTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
//                self?.listTableView.setContentOffset(CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude), animated: true)
            }
        })
    }

    /**
     下拉加载更多请求，模拟一下请求时间
     */
    func pullToLoadMore() {
        if self.listTableView.tableHeaderView == nil { return }
        if isReloading == true { return }
        self.isEndRefreshing = false
        self.indicatorView.startAnimating()
        self.isReloading = true

        let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        backgroundQueue.async(execute: {
            self.fetchData { [weak self] listData in
                guard let list = listData?.reversed() else {
                    self?.indicatorView.stopAnimating()
                    self?.isReloading = false
                    return
                }

                DispatchQueue.main.async(execute: { () -> Void in
                    self?.indicatorView.stopAnimating()
                    if list.isEmpty {
                        self?.listTableView.tableHeaderView = nil
                    }
                    self?.itemList.insert(contentsOf: list, at: 0)
                    //            self!.listTableView.tableHeaderView = nil
                    self?.updateTableWithNewRowCount(list.count)
                    self?.isEndRefreshing = true
                    self?.isReloading = false
                })
            }
        })
    }

    //获取聊天列表数据
    func fetchData(finish:@escaping ([ChatMessageModel]?) -> Void) {
        DatabaseTool.shared.queryMessageList(byID: currentSessionModel.session_id, chatType: currentSessionModel.chat_type, index: startIndex, pageing: queryNum) { [weak self] modelList in
            self?.startIndex = (self?.startIndex ?? 0) + (self?.queryNum ?? 0)
            var temp: ChatMessageModel?
            var tempArr: [ChatMessageModel] = []
            for model in modelList {
                //如果是最后一个，先添加消息，再添加时间
                //注意：消息最终会倒叙显示
                if modelList.last?.msg_id == model.msg_id {
                    tempArr.append(model)
                    let chatTimeModel = ChatMessageModel()
                    chatTimeModel.kind = ChatMessageType.time.rawValue
                    chatTimeModel.serverid = model.msg_id
                    chatTimeModel.content = Date(timeIntervalSince1970: TimeInterval(model.msg_id / 1_000)).chatTimeString
                    tempArr.insert(chatTimeModel, at: tempArr.count)
                } else if model.isLateForThreeMinutes(timestamp: temp?.msg_id ?? 0) && temp != nil {
                    if let safeID = temp?.msg_id {
                        let chatTimeModel = ChatMessageModel()
                        chatTimeModel.kind = ChatMessageType.time.rawValue
                        chatTimeModel.serverid = model.msg_id
                        chatTimeModel.content = Date(timeIntervalSince1970: TimeInterval(safeID / 1_000)).chatTimeString
                        tempArr.insert(chatTimeModel, at: tempArr.count)
                    }
                    tempArr.append(model)
                } else {
                    tempArr.append(model)
                }

                temp = model
            }
            finish(tempArr)
        }
    }

    //下拉刷新加载数据， inert rows
    func updateTableWithNewRowCount(_ count: Int) {
        var contentOffset = self.listTableView.contentOffset

        UIView.setAnimationsEnabled(false)
        self.listTableView.beginUpdates()

        var heightForNewRows: CGFloat = 0
        var indexPaths = [IndexPath]()
        for index in 0 ..< count {
            let indexPath = IndexPath(row: index, section: 0)
            indexPaths.append(indexPath)

            heightForNewRows += self.tableView(self.listTableView, heightForRowAt: indexPath)
        }
        contentOffset.y += heightForNewRows

        self.listTableView.insertRows(at: indexPaths, with: UITableViewRowAnimation.none)
        self.listTableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        self.listTableView.setContentOffset(contentOffset, animated: false)
    }
}
