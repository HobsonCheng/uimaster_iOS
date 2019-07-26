//
//  FriendApplyVC.swift
//  UIMaster
//
//  Created by hobson on 2018/10/16.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit

class FriendApplyVC: BaseNameVC, PageModuleAble {
    /// 样式
    var styleDic: [String: Any]? {
        didSet {
            self.moduleDelegate?.setfullPageTableModule(table: self.listTableView)
        }
    }
    /// 参数
    var moduleParams: [String: Any]? {
        didSet {
            reloadViewData()
        }
    }
    /// 代理
    weak var moduleDelegate: ModuleRefreshDelegate?

    lazy var listTableView: BaseTableView = {
        let table = BaseTableView(frame: self.view.bounds, style: .plain)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.rowHeight = 80
        self.view.addSubview(table)
        table.snp.makeConstraints({ make in
            make.left.right.bottom.height.equalToSuperview()
        })
        return table
    }()
    private var itemList: [UserInfoData]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.listTableView.register(FriendApplyCell.getNib(), forCellReuseIdentifier: FriendApplyCell.getIdentifier)
//        DatabaseTool.shared.modifyNotificationReceiptState(database: nil, action: .applyForFriend, state: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension FriendApplyVC {
    func reloadViewData() {
        NetworkUtil.request(
            target: NetworkService.getApplyFriendList(page_index: 1, page_context: 100),
            success: { [weak self] json in
                let userInfo = UserListModel.deserialize(from: json)?.data
                self?.itemList = userInfo
                self?.listTableView.reloadData()
            }
        ) { error in
            dPrint(error)
        }
    }
}

extension FriendApplyVC: UITableViewDelegate, UITableViewDataSource, FriendApplyCellDelegate {
    func agreeApply(cell: FriendApplyCell) {
        let userInfo = cell.model
        NetworkUtil.request(
            target: .agreeFriend(friend_uid: userInfo?.uid ?? 0, friend_pid: userInfo?.pid ?? 0),
            success: { _ in
                DispatchQueue.main.async {
                    cell.backgroundColor = .clear
                    cell.agreeBtn.setTitle("已添加", for: .normal)
                    cell.agreeBtn.isEnabled = false
                    cell.agreeBtn.setTitleColor(.black, for: .normal)
                }
                HUDUtil.msg(msg: "添加成功", type: .successful)
            }
        ) { error in
            dPrint(error)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FriendApplyCell.getIdentifier) as? FriendApplyCell else {
            return UITableViewCell()
        }
        cell.model = self.itemList?[indexPath.row]
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
}
