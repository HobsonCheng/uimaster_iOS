//
//  OrgnizationStruct.swift
//  UIMaster
//
//  Created by hobson on 2018/10/7.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit

class OrgnizationStruct: BaseNameVC, PageModuleAble {
    var events: [String: EventsData]?
    weak var moduleDelegate: ModuleRefreshDelegate?

    var styleDic: [String: Any]? {
        didSet {
            if let model = OrgnizationConfigModel.deserialize(from: styleDic) {
                self.events = model.events
            }
            self.moduleDelegate?.setfullPageTableModule(table: listTableView)
        }
    }

    lazy var listTableView: BaseTableView = {
        let listTableView = BaseTableView(frame: CGRect.zero, style: .plain)
        listTableView.configRefresh()
        listTableView.parentVC = self
        listTableView.mj_footer.isHidden = true
        listTableView.dataSource = self
        listTableView.delegate = self
        listTableView.backgroundColor = UIColor.clear
        listTableView.separatorStyle = .none
        return listTableView
    }()

    lazy var itemList: [[OrgnizationStructData]] = []
    var originalList: [OrgnizationStructData]?

    override func viewDidLoad() {
        super.viewDidLoad()
        renderUI()
        self.getCacheJson(key: OrgnizationStruct.getClassName) { [weak self] json in
            let modelArr = OrgnizationStructModel.deserialize(from: json)?.data ?? []
            self?.originalList = modelArr
            //一级部门
            for sub in modelArr {
                //                sub.type = .level1
                //                self?.itemList[index].append(sub)
                //二级部门
                var level2 = [OrgnizationStructData]()
                for sub2 in sub.childDepartment ?? [] {
                    sub2.type = .level2
                    level2.append(sub2)
                    //二级部门下的成员
                    for sub3 in sub2.childPeople ?? [] {
                        sub3.type = .user
                        level2.append(sub3)
                    }
                }
                self?.itemList.append(level2)
            }

            DispatchQueue.main.async {
                self?.listTableView.reloadData()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.reloadViewData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func renderUI() {
        self.listTableView.rowHeight = 70
        self.view.addSubview(listTableView)
        self.listTableView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        self.listTableView.register(UINib(nibName: "DepartmentCell", bundle: nil), forCellReuseIdentifier: "departmentCell")
        self.listTableView.register(UINib(nibName: "EmployeeCell", bundle: nil), forCellReuseIdentifier: "employeeCell")
    }
}

// MARK: - 网络请求
extension OrgnizationStruct {
    func reloadViewData() {
        NetworkUtil.request(
            target: NetworkService.getDepartmentListAll(parent_id: 0),
            success: { [weak self] json in
                self?.cacheJson(key: OrgnizationStruct.getClassName, json: json)
                self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
                let modelArr = OrgnizationStructModel.deserialize(from: json)?.data ?? []
                self?.originalList = modelArr
                self?.itemList.removeAll()
                //一级部门
                for sub in modelArr {
//                sub.type = .level1
//                self?.itemList[index].append(sub)
                    //二级部门
                    var level2 = [OrgnizationStructData]()
                    for sub2 in sub.childDepartment ?? [] {
                        sub2.type = .level2
                        level2.append(sub2)
                        //二级部门下的成员
                        for sub3 in sub2.childPeople ?? [] {
                            sub3.type = .user
                            level2.append(sub3)
                        }
                    }
                    self?.itemList.append(level2)
                }

                DispatchQueue.main.async {
                    self?.listTableView.reloadData()
                }
            }
        ) { [weak self] error in
            self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
            dPrint("error:\(error)")
        }
    }
}

// MARK: - 代理
extension OrgnizationStruct: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.originalList?[section].name
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemList[section].count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.originalList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) is DepartmentCell {
            let event = self.events?[kDepartmentEvent]
            event?.attachment = [OrgnizationStructData.getClassName: self.itemList[indexPath.section][indexPath.row]]
            let result = EventUtil.handleEvents(event: event)
            EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
//            let vc = DepartMentDetailVC()
//            vc.model =
//            VCController.push(vc, with: VCAnimationClassic.defaultAnimation())
        } else {
            if let cell = tableView.cellForRow(at: indexPath) as? EmployeeCell {
                guard let uid = cell.model?.uid, let pid = cell.model?.pid else {
                    return
                }
                if uid == 0 || pid == 0 {
                    return
                }
                //跳转个人中心
                PageRouter.shared.router(to: PageRouter.RouterPageType.personalCenterT(tuple: (uid, pid)))
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.itemList[indexPath.section][indexPath.row]
        if model.type == .user {
            let cell = tableView.dequeueReusableCell(withIdentifier: "employeeCell") as? EmployeeCell ?? EmployeeCell()
            cell.selectionStyle = .none
            cell.model = model
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "departmentCell") as? DepartmentCell ?? DepartmentCell()
        cell.model = model
        cell.selectionStyle = .none
        return cell
    }
}
